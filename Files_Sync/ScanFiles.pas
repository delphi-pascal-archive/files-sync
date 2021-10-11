{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : ScanFiles.pas
|
|  Description : Gestion du thread qui parcoure les répertoires source
|                et cible pour construire le contenu de la TCheckListBox                                                                                 |
|
==============================================================================
}
unit ScanFiles;

interface

uses
  Windows, Forms, Classes, SysUtils, StdCtrls, ExtCtrls, Dialogs,
  Declare, Utils, FilesUtils, Language;


type
  TScanThread = class(TThread)
  private
    { Déclarations privées }
  protected
    procedure Execute; override;
    // Gestion des données d'une entrée.
    procedure RecFileClear;
    function  RecToStr: string;   // Converti le record en string
    procedure ListAdd;
    //
    procedure SynchroCompare;
    procedure TargetUpdate (const sDirTarget, sName: string);
    procedure SourceUpdate (const sDir: string; const SearchRec: TSearchRec);
    procedure ItemsAdd (const cType: Char);
    procedure DirAdd (const sDirSource, sDirTarget: string);
    procedure CtrlFilesTarget (const sDirTarget, sDirSource, sFilter: string;
                               const nAttrib: integer; const bSubDir: boolean);
    procedure ScanDirTarget (const sDirTarget, sDirSource, sFilter: string;
                             const nAttrib: integer; const bSubDir: boolean);
    procedure CtrlFilesSource (const sDirSource, sDirTarget, sFilter: string;
                               const nAttrib: integer; const bSubDir: boolean);
    procedure ScanDirSource (const sDirSource, sDirTarget, sFilter: string;
                             const nAttrib: integer; const bSubDir: boolean);
    procedure ScanCtrl;

  public

  end;

var
  Scan : TScanThread;


implementation

uses
  FormMain, UserControl;


{
==============================================================================
|  Exécution du thread                                                       |
|----------------------------------------------------------------------------|                                              |
|  Exécution du thread et contrôle de vallidité des répetoires source et     |
|  destination et message à l'utilisateur.                                   |
==============================================================================
}
procedure TScanThread.Execute;
var
  sMsg          : string;
  pCharText     : array[0..255] of char;
  pCharCaption  : array[0..255] of char;
begin
  // Teste la validité des répertoires sélectionnés
  if not DirectoryExists(AppliData.sSourcePath) then begin
    // Si accès impossible au répertoire source
    sMsg := Lang.sMsg_ErrDirAccess + ' ' + AppliData.sSourcePath;
    MessageBox(0, StrPcopy(pCharText, sMsg), StrPcopy(pCharCaption, Lang.sTitle_Application), MB_OK);
    exit;
  end
  else if not DirectoryExists(AppliData.sTargetPath) then begin
    // Si accès impossible au répertoire cible
    sMsg := Lang.sMsg_ErrDirAccess + ' ' + AppliData.sTargetPath;
    MessageBox(0, StrPcopy(pCharText, sMsg), StrPcopy(pCharCaption, Lang.sTitle_Application), MB_OK);
    exit;
  end
  else begin
    UserCtrl.SetForCompare (TRUE);
    ScanCtrl;
    UserCtrl.SetForCompare (FALSE);
  end;
  Terminate;
end;

{
======================================
|  Initialisation du record RecFile  |
======================================
}
procedure TScanThread.RecFileClear;
begin
  with AppliData.RecFile do begin
    bChecked := FALSE;
    sSourceName := '';
    nSourceSize := 0;
    dtSourceDate := 0;
    sSync := ' ';
    dtTargetDate := 0;
    nTargetSize := 0;
    sTargetName := '';
  end;
end;

{
============================================
|  Transforme le record RecFile en string  |
============================================
}
function TScanThread.RecToStr: string;
begin
  with AppliData.RecFile do begin
    if bChecked then
      Result := '1' + ';'
    else
      Result := '0' + ';';
    //
    Result := Result + sSourceName + ';';
    Result := Result + IntToStr (nSourceSize) + ';';
    Result := Result + DateTimeToStr (dtSourceDate) + ';';
    Result := Result + sSync + ';';
    Result := Result + DateTimeToStr (dtTargetDate) + ';';
    Result := Result + IntToStr (nTargetSize) + ';';
    Result := Result + sTargetName + ';';
    Result := Result + sType + ';';
  end;
end;

{
============================================================================
|  Ajout d'un élément répertoire ou fichier dans la liste de comparaison   |
============================================================================
}
procedure TScanThread.ListAdd;
var
  sItem : string;
begin
  with FrmMain, AppliData do begin
    sItem := RecToStr;  // Conversion du record en string
    // Ajout de l'item dans la litbox et le checklistbox
    sListFiles.Add (sItem);
    CheckListBox.Items.Append(sItem);
    // Gestion des éléments checked
    with RecFile do begin
      if (sType = sTYPE_FILE)
      and ((sSync = '>') or (sSync = '<')) then begin
        // Contrôle des cases à cocher
        if bChecked then
          CheckListBox.State[CheckListBox.Count - 1] := cbChecked
        else
          CheckListBox.State[CheckListBox.Count - 1] := cbUnchecked;
        // Invalide les cases à cocher des lignes sans synchronsaton
        if sSync = '=' then
          CheckListBox.ItemEnabled[CheckListBox.Count - 1] := FALSE;
      end;
    end;

  end;
end;

{
==============================================================================
|  Comparaison entre les fichier source et destination et décision du mode   |
|  de synchronisation qui en découle (tient conpte de la différence 2s)      |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - nItem  : Numéro de la position dans la liste de comparaison             |
==============================================================================
}
procedure TScanThread.SynchroCompare;
var
  nSource : extended;   // Date du fichier source
  nTarget : extended;   // Date du fichier cible
  nDiff   : extended;   // Différence des dates entre fichiers source et cible
begin
  with AppliData do begin
    nSource := RecFile.dtSourceDate;
    nTarget := RecFile.dtTargetDate;
    nDiff := abs (nSource - nTarget);
    RecFile.bChecked := FALSE;
    //
    if bIgnore2s and (nDiff < (1 / 43200)) then
      RecFile.sSync := '='    // Pour différence NTFS - FAT
    else begin
      if nSource > nTarget then begin
        RecFile.sSync := '>';
        RecFile.bChecked := TRUE;
        nSizeSelSource := nSizeSelSource + RecFile.nSourceSize;
        inc (nNbrTaggedSource);
      end
      else begin
        RecFile.sSync := '<';
        RecFile.bChecked := TRUE;
        nSizeSelTarget := nSizeSelTarget + RecFile.nTargetSize;
        inc (nNbrTaggedTarget);
      end;
    end;
  end;
end;

{
==============================================================================
|  Mise à jour des informations sur le fichier source dans la lite           |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - sDirTarget  : Nom du répertoire cible                                   |
|  - sName       : Nom du fichier                                            |
==============================================================================
}
procedure TScanThread.TargetUpdate (const sDirTarget, sName: string);
var
  Age : integer;
begin
  with AppliData do begin
    // Complète cet élémment avec les propriétés du fichier trouvé
    // nNbrItems est le nombre d'entrée actuel de la liste
    RecFile.sTargetName := sName;
    RecFile.nTargetSize := Files.GetFileSize(sDirTarget + sName);
    Age := FileAge(sDirTarget + sName);
    if Age > -1 then begin
      // Gestion d'un décalage horaire pou les fchiers cibles
      if nShiftTimeZone <> 0 then
        RecFile.dtTargetDate := FileDateToDateTime(Age) + (nShiftTimeZone * (1/24))
      else
        RecFile.dtTargetDate := FileDateToDateTime(Age);
    end;
    inc (nNbrFilesTarget);
  end;
end;

{
==============================================================================
|  Mise à jour des informations sur le fichier cible dans la lite            |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - nItem      : Index de l'èlèment dans la liste de comparaison            |
|  - sDir       : Nom du répertoire source                                   |
|  - SearchRec  : Informations du fichier à comparer                         |
==============================================================================
}
procedure TScanThread.SourceUpdate (const sDir: string; const SearchRec: TSearchRec);
var
  Age : integer;
begin
  with AppliData do begin
    // Complète cet élémment avec les propriétés du fichier trouvé
    RecFile.sSourceName := SearchRec.Name;
    RecFile.nSourceSize := Files.GetFileSize(sDir + SearchRec.Name);
    Age := FileAge(sDir + SearchRec.Name);
    if Age > -1 then
      RecFile.dtSourceDate := FileDateToDateTime(Age);
    inc (nNbrFilesSource);
  end;
end;

{
==============================================================================
|  Ajout d'une entrée fichier dans la liste de comparaison                   |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - cType    : Type de l'entrée : fichier (cTypeFile) ou dossier (cTyprDir) |
==============================================================================
}
procedure TScanThread.ItemsAdd (const cType: Char);
begin
  with AppliData do begin
    RecFileClear;
    RecFile.sType := cType;
  end;
end;

{
===================================================================
|  Ajout d'une répertoire source dans la liste de comparaison     |
|-----------------------------------------------------------------|                                              |
|  Paramètres :                                                   |
|  - sDirSource : Désignation complète du répertoire source       |
|  - sDirTarget : Désignation complète du répertoire destination  |
===================================================================
}
procedure TScanThread.DirAdd (const sDirSource, sDirTarget: string);
begin
  with AppliData do begin
    RecFileClear;
    RecFile.SType := sTYPE_DIR;
    RecFile.bChecked := FALSE;
    RecFile.sSourceName := IncludeTrailingPathDelimiter (sDirSource);
    RecFile.sTargetName := IncludeTrailingPathDelimiter (sDirTarget);
    ListAdd;  // Aoute dans la liste de comparaison
  end;
end;

{
==============================================================================
|  Gestion du scanning des fichiers du répertoire 'cible'                    |
|  Cherche les fichiers 'cible' absents du  répertoire source                |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - sSourcePath  : Répertoire source pour la recherche des fichiers         |
|  - sTargetPath  : Répertoire cible pour la recherchce des fichiers         |
|  - sFileFilter  : Filtre choisi pour la sélection des fichiers             |
|  - nAttrib      : Attributs choisis pour la sélecion des fichiers          |
|  - bSubDir      : Défini si l'on cherche dans les sous-répertoires         |
==============================================================================
}
procedure TScanThread.CtrlFilesTarget (const sDirTarget, sDirSource, sFilter: string;
                                       const nAttrib: integer; const bSubDir: boolean);
var
  nResult     : integer;    // = 0 si fichier trouvé
  sDirTemp    : string;
  sFileFound  : string;     // Fichier cible
  SearchRec   : TSearchRec; // Mémorisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demandée par l'utilisteur
    exit;  // on quitte
  //
  sDirTemp := IncludeTrailingPathDelimiter (sDirTarget);
  nResult := FindFirst (sDirTemp + sFilter, nAttrib, SearchRec);
  while nResult = 0 do begin
    if ((SearchRec.Attr and faDirectory) <= 0) then begin
      // Un fichier a été trouvé (et non pas un dossier)
      with AppliData do begin
        // Teste la présence du fichier cible et met à jour les infos
        sFileFound := IncludeTrailingPathDelimiter (sDirSource) + SearchRec.Name;
        if not FileExists (sFileFound) then begin
          ItemsAdd (sTYPE_FILE);  // Ajout d'un élément à la liste de comparaison
          TargetUpdate (sDirTemp, SearchRec.Name);
          SynchroCompare;
          ListAdd;
        end;
      end;
    end;
    nResult := FindNext(SearchRec);
  end;
  FindClose (SearchRec);
end;

{            
==============================================================================
|  Gestion du scanning des sous-répertoires 'cible'. Recherche si des        |
|  répertoires existent dans la cible et maquent dans la source              |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - sDirTarget   : Répertoire cible pour la recherchce des fichiers         |
|  - sDirSource   : Répertoire source pour la recherche des fichiers         |
|  - sFilter      : Filtre choisi pour la sélection des fichiers             |
|  - nAttrib      : Attributs choisis pour la sélecion des fichiers          |
|  - bSubDir      : Défini si l'on cherche dans les sous-répertoires         |
==============================================================================
}
procedure TScanThread.ScanDirTarget (const sDirTarget, sDirSource, sFilter: string;
                                     const nAttrib: integer; const bSubDir: boolean);
var
  nFilesSource  : integer;    // Nombre de fichiers trouvés dans le répertoire
  nFilesTarget  : integer;    // Nombre de fichiers trouvés dans le répertoire
  SearchRec     : TSearchRec; // Mémorisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demandée par l'utilisteur
    exit;  // on quitte
  //
  // --- Gestion du répertoire cible ---
  FrmMain.EditTargetPath.Text := sDirTarget;
  // Teste si le répertoire surce contient au moins un fichier
  if (Files.FilesCount (sDirTarget, sFilter, FALSE, TRUE) > 0 )
  and ( not DirectoryExists(sDirSource)) then begin
    DirAdd (sDirSource, sDirTarget);
    // Cherche les fichiers 'cible' absents du  répertoire source
    CtrlFilesTarget (sDirTarget, sDirSource, sFilter, nAttrib, bSubDir);
    ListUtils.UpdateStatusBar (nSTAT_BOTH);   // Mise à jour des infos de la barre d'état
  end;
  //
  //--- Si recherche dans les sous-répertoires
  if AppliData.bSubFolder then begin
    // Recherche des sous-répertoires
    if FindFirst (sDirTarget + '*.*', faDirectory + faHidden, SearchRec) = 0 then
    repeat
      if Files.IsChildDir (SearchRec) then begin
        // Appel réentrant de la procédure ScanDirTarget
        ScanDirTarget (sDirTarget + SearchRec.Name + '\', sDirSource + SearchRec.Name + '\', sFilter, nAttrib, bSubDir);
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

{
==============================================================================
|  Recherche les fichiers du répertoire 'source'                             |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - sDirSource   : Répertoire source pour la recherche des fichiers         |
|  - sDirTarget   : Répertoire cible pour la recherchce des fichiers         |
|  - sFilter      : Filtre choisi pour la sélection des fichiers             |
|  - nAttrib      : Attributs choisis pour la sélecion des fichiers          |
|  - bSubDir      : Défini si l'on cherche dans les sous-répertoires         |
==============================================================================
}
procedure TScanThread.CtrlFilesSource (const sDirSource, sDirTarget, sFilter: string;
                                       const nAttrib: integer; const bSubDir: boolean);
var
  nResult     : integer;    // = 0 si fichier trouvé
  sFileFound  : string;     // Fichier cible
  SearchRec   : TSearchRec; // Mémroisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demandée par l'utilisteur
    exit;  // on quitte
  //
  nResult := FindFirst (sDirSource + sFilter, nAttrib, SearchRec);
  while nResult = 0 do begin
    if ((SearchRec.Attr and faDirectory) <= 0) then begin
      // Un fichier a été trouvé(et non pas un dossier)
      with AppliData do begin
        ItemsAdd (sTYPE_FILE);  // Ajout d'un élément à la liste de comparaison
        // Complète les informations du fichier source
        SourceUpdate (sDirSource, SearchRec); // Complète cet élémment
        // Teste la présence du fichier cible et met à jour les infos
        sFileFound := sDirTarget + SearchRec.Name;
        if FileExists (sFileFound) then begin
          TargetUpdate (sDirTarget, SearchRec.Name);
        end;
        SynchroCompare;
        ListAdd;
      end;
    end;
    nResult := FindNext(SearchRec);
  end;
  FindClose (SearchRec);
end;

{
==============================================================================
|  Gestion du scanning des sous-répertoires 'source' pour rechercher         |
|  les fichiers et les sous-réperrtoires                                     |
|----------------------------------------------------------------------------|                                              |
|  Paramètres :                                                              |
|  - sDirSource   : Répertoire source pour la recherche des fichiers         |
|  - sDirTarget   : Répertoire cible pour la recherchce des fichiers         |
|  - sFilter      : Filtre choisi pour la sélection des fichiers             |
|  - nAttrib      : Attributs choisis pour la sélecion des fichiers          |
|  - bSubDir      : Défini si l'on cherche dans les sous-répertoires         |
==============================================================================
}
procedure TScanThread.ScanDirSource (const sDirSource, sDirTarget, sFilter: string;
                                     const nAttrib: integer; const bSubDir: boolean);
var
  bDirAdd         : boolean;    // Indique si le répertoire courant est ajouté à la liste
  nFiles          : integer;    // Nombre de fichiers trouvés dans le répertoire
  SearchRec       : TSearchRec; // Mémorisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demandée par l'utilisteur
    exit;  // on quitte
  //
  // --- Gestion du répertoire source ---
  // Mise à jour du chemin dans l'interface
  FrmMain.EditSourcePath.Text := sDirSource;
  // Teste si le répertoire surce contient au moins un fichier
  nFiles := Files.FilesCount (sDirSource, sFilter, FALSE, TRUE);
  // Ajoute le répertoire source dans la liste
  bDirAdd := FALSE;
  if nFiles > 0 then begin
    DirAdd (sDirSource, sDirTarget);
    bDirAdd := TRUE;
    // Ajoute dans la liste les fichiers du répertoire courant
    CtrlFilesSource (sDirSource, sDirTarget, sFilter, nAttrib, bSubDir);
  end;
  ListUtils.UpdateStatusBar (nSTAT_BOTH);  // Mise à jour des infos de la barre d'état
  // --- Gestion du répertoire cible ---
  // Mise à jour du chemin dans l'interface
  FrmMain.EditTargetPath.Text := sDirTarget + SearchRec.Name;
  // Teste si le répertoire cible contient au moins un fichier
  nFiles := Files.FilesCount (sDirTarget, sFilter, FALSE, TRUE);
  if nFiles > 0 then begin
    if bDirAdd = FALSE then begin
      DirAdd (sDirSource, sDirTarget);
    end;
    // Cherche des fichiers dans le répertoire cible absents du répertoire source
    CtrlFilesTarget (sDirTarget, sDirSource, sFilter, nAttrib, bSubDir);
  end;
  // Cherche des sous-répertoires dans le répertoire cible absents du  répertoire source
  //
  //--- Si recherche dans les sous-répertoires
  if AppliData.bSubFolder then begin
    // Recherche des sous-répertoires
    if FindFirst (sDirSource + '*.*', faDirectory + faHidden, SearchRec) = 0 then
    repeat
      if Files.IsChildDir (SearchRec) then begin
        // Appel réentrant de la procédure ScanDirSource
        ScanDirSource (sDirSource + SearchRec.Name + '\', sDirTarget + SearchRec.Name + '\', sFilter, nAttrib, bSubDir);
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

{
==============================================================================
|  Gestion du scanning des répertoires 'source' et 'cible'                   |
|----------------------------------------------------------------------------|                                              |
|  Gestion de la recherche des fichiers et sous-répertoires du répertoire    |
|  source et du répertoire cible                                             |
==============================================================================
}
procedure TScanThread.ScanCtrl;
var
  sDrive : string;
begin
  with AppliData do begin
    sDrive := ExtractFileDrive (sSourcePath);
    // Initialisation des variables
    nNbrFilesSource := 0;
    nNbrTaggedSource := 0;
    nSizeSelSource := 0;
    nFreeDiskSource := Files.DiskFreeSpace (sSourcePath);
    nNbrFilesTarget := 0;
    nNbrTaggedTarget := 0;
    nSizeSelTarget := 0;
    nFreeDiskTarget := Files.DiskFreeSpace (sTargetPath);
    RecFileClear;
    ListUtils.UpdateStatusBar (nSTAT_CLEAR);
    // Recherche des fichiers
    bScanActive := TRUE;    // Début de la recherche des éléments à afficher
    FrmMain.CheckListBox.Clear;
    sListFiles.Clear;
    ScanDirSource (sSourcePath, sTargetPath, sFileFilter, nAttrib, bSubFolder);
    ScanDirTarget (sTargetPath, sSourcePath, sFileFilter, nAttrib, bSubFolder);
    // Mise à jour de l'interface
    ListUtils.UpdateStatusBar (nSTAT_BOTH);
    bScanActive := FALSE;   // Fin de la recherche des éléments à afficher
    FrmMain.CheckListBox.Refresh;
    FrmMain.EditSourcePath.Clear;
    FrmMain.EditTargetPath.Clear;
  end;
end;


end.
