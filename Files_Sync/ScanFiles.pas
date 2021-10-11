{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : ScanFiles.pas
|
|  Description : Gestion du thread qui parcoure les r�pertoires source
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
    { D�clarations priv�es }
  protected
    procedure Execute; override;
    // Gestion des donn�es d'une entr�e.
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
|  Ex�cution du thread                                                       |
|----------------------------------------------------------------------------|                                              |
|  Ex�cution du thread et contr�le de vallidit� des r�petoires source et     |
|  destination et message � l'utilisateur.                                   |
==============================================================================
}
procedure TScanThread.Execute;
var
  sMsg          : string;
  pCharText     : array[0..255] of char;
  pCharCaption  : array[0..255] of char;
begin
  // Teste la validit� des r�pertoires s�lectionn�s
  if not DirectoryExists(AppliData.sSourcePath) then begin
    // Si acc�s impossible au r�pertoire source
    sMsg := Lang.sMsg_ErrDirAccess + ' ' + AppliData.sSourcePath;
    MessageBox(0, StrPcopy(pCharText, sMsg), StrPcopy(pCharCaption, Lang.sTitle_Application), MB_OK);
    exit;
  end
  else if not DirectoryExists(AppliData.sTargetPath) then begin
    // Si acc�s impossible au r�pertoire cible
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
|  Ajout d'un �l�ment r�pertoire ou fichier dans la liste de comparaison   |
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
    // Gestion des �l�ments checked
    with RecFile do begin
      if (sType = sTYPE_FILE)
      and ((sSync = '>') or (sSync = '<')) then begin
        // Contr�le des cases � cocher
        if bChecked then
          CheckListBox.State[CheckListBox.Count - 1] := cbChecked
        else
          CheckListBox.State[CheckListBox.Count - 1] := cbUnchecked;
        // Invalide les cases � cocher des lignes sans synchronsaton
        if sSync = '=' then
          CheckListBox.ItemEnabled[CheckListBox.Count - 1] := FALSE;
      end;
    end;

  end;
end;

{
==============================================================================
|  Comparaison entre les fichier source et destination et d�cision du mode   |
|  de synchronisation qui en d�coule (tient conpte de la diff�rence 2s)      |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - nItem  : Num�ro de la position dans la liste de comparaison             |
==============================================================================
}
procedure TScanThread.SynchroCompare;
var
  nSource : extended;   // Date du fichier source
  nTarget : extended;   // Date du fichier cible
  nDiff   : extended;   // Diff�rence des dates entre fichiers source et cible
begin
  with AppliData do begin
    nSource := RecFile.dtSourceDate;
    nTarget := RecFile.dtTargetDate;
    nDiff := abs (nSource - nTarget);
    RecFile.bChecked := FALSE;
    //
    if bIgnore2s and (nDiff < (1 / 43200)) then
      RecFile.sSync := '='    // Pour diff�rence NTFS - FAT
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
|  Mise � jour des informations sur le fichier source dans la lite           |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - sDirTarget  : Nom du r�pertoire cible                                   |
|  - sName       : Nom du fichier                                            |
==============================================================================
}
procedure TScanThread.TargetUpdate (const sDirTarget, sName: string);
var
  Age : integer;
begin
  with AppliData do begin
    // Compl�te cet �l�mment avec les propri�t�s du fichier trouv�
    // nNbrItems est le nombre d'entr�e actuel de la liste
    RecFile.sTargetName := sName;
    RecFile.nTargetSize := Files.GetFileSize(sDirTarget + sName);
    Age := FileAge(sDirTarget + sName);
    if Age > -1 then begin
      // Gestion d'un d�calage horaire pou les fchiers cibles
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
|  Mise � jour des informations sur le fichier cible dans la lite            |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - nItem      : Index de l'�l�ment dans la liste de comparaison            |
|  - sDir       : Nom du r�pertoire source                                   |
|  - SearchRec  : Informations du fichier � comparer                         |
==============================================================================
}
procedure TScanThread.SourceUpdate (const sDir: string; const SearchRec: TSearchRec);
var
  Age : integer;
begin
  with AppliData do begin
    // Compl�te cet �l�mment avec les propri�t�s du fichier trouv�
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
|  Ajout d'une entr�e fichier dans la liste de comparaison                   |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - cType    : Type de l'entr�e : fichier (cTypeFile) ou dossier (cTyprDir) |
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
|  Ajout d'une r�pertoire source dans la liste de comparaison     |
|-----------------------------------------------------------------|                                              |
|  Param�tres :                                                   |
|  - sDirSource : D�signation compl�te du r�pertoire source       |
|  - sDirTarget : D�signation compl�te du r�pertoire destination  |
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
|  Gestion du scanning des fichiers du r�pertoire 'cible'                    |
|  Cherche les fichiers 'cible' absents du  r�pertoire source                |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - sSourcePath  : R�pertoire source pour la recherche des fichiers         |
|  - sTargetPath  : R�pertoire cible pour la recherchce des fichiers         |
|  - sFileFilter  : Filtre choisi pour la s�lection des fichiers             |
|  - nAttrib      : Attributs choisis pour la s�lecion des fichiers          |
|  - bSubDir      : D�fini si l'on cherche dans les sous-r�pertoires         |
==============================================================================
}
procedure TScanThread.CtrlFilesTarget (const sDirTarget, sDirSource, sFilter: string;
                                       const nAttrib: integer; const bSubDir: boolean);
var
  nResult     : integer;    // = 0 si fichier trouv�
  sDirTemp    : string;
  sFileFound  : string;     // Fichier cible
  SearchRec   : TSearchRec; // M�morisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demand�e par l'utilisteur
    exit;  // on quitte
  //
  sDirTemp := IncludeTrailingPathDelimiter (sDirTarget);
  nResult := FindFirst (sDirTemp + sFilter, nAttrib, SearchRec);
  while nResult = 0 do begin
    if ((SearchRec.Attr and faDirectory) <= 0) then begin
      // Un fichier a �t� trouv� (et non pas un dossier)
      with AppliData do begin
        // Teste la pr�sence du fichier cible et met � jour les infos
        sFileFound := IncludeTrailingPathDelimiter (sDirSource) + SearchRec.Name;
        if not FileExists (sFileFound) then begin
          ItemsAdd (sTYPE_FILE);  // Ajout d'un �l�ment � la liste de comparaison
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
|  Gestion du scanning des sous-r�pertoires 'cible'. Recherche si des        |
|  r�pertoires existent dans la cible et maquent dans la source              |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - sDirTarget   : R�pertoire cible pour la recherchce des fichiers         |
|  - sDirSource   : R�pertoire source pour la recherche des fichiers         |
|  - sFilter      : Filtre choisi pour la s�lection des fichiers             |
|  - nAttrib      : Attributs choisis pour la s�lecion des fichiers          |
|  - bSubDir      : D�fini si l'on cherche dans les sous-r�pertoires         |
==============================================================================
}
procedure TScanThread.ScanDirTarget (const sDirTarget, sDirSource, sFilter: string;
                                     const nAttrib: integer; const bSubDir: boolean);
var
  nFilesSource  : integer;    // Nombre de fichiers trouv�s dans le r�pertoire
  nFilesTarget  : integer;    // Nombre de fichiers trouv�s dans le r�pertoire
  SearchRec     : TSearchRec; // M�morisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demand�e par l'utilisteur
    exit;  // on quitte
  //
  // --- Gestion du r�pertoire cible ---
  FrmMain.EditTargetPath.Text := sDirTarget;
  // Teste si le r�pertoire surce contient au moins un fichier
  if (Files.FilesCount (sDirTarget, sFilter, FALSE, TRUE) > 0 )
  and ( not DirectoryExists(sDirSource)) then begin
    DirAdd (sDirSource, sDirTarget);
    // Cherche les fichiers 'cible' absents du  r�pertoire source
    CtrlFilesTarget (sDirTarget, sDirSource, sFilter, nAttrib, bSubDir);
    ListUtils.UpdateStatusBar (nSTAT_BOTH);   // Mise � jour des infos de la barre d'�tat
  end;
  //
  //--- Si recherche dans les sous-r�pertoires
  if AppliData.bSubFolder then begin
    // Recherche des sous-r�pertoires
    if FindFirst (sDirTarget + '*.*', faDirectory + faHidden, SearchRec) = 0 then
    repeat
      if Files.IsChildDir (SearchRec) then begin
        // Appel r�entrant de la proc�dure ScanDirTarget
        ScanDirTarget (sDirTarget + SearchRec.Name + '\', sDirSource + SearchRec.Name + '\', sFilter, nAttrib, bSubDir);
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

{
==============================================================================
|  Recherche les fichiers du r�pertoire 'source'                             |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - sDirSource   : R�pertoire source pour la recherche des fichiers         |
|  - sDirTarget   : R�pertoire cible pour la recherchce des fichiers         |
|  - sFilter      : Filtre choisi pour la s�lection des fichiers             |
|  - nAttrib      : Attributs choisis pour la s�lecion des fichiers          |
|  - bSubDir      : D�fini si l'on cherche dans les sous-r�pertoires         |
==============================================================================
}
procedure TScanThread.CtrlFilesSource (const sDirSource, sDirTarget, sFilter: string;
                                       const nAttrib: integer; const bSubDir: boolean);
var
  nResult     : integer;    // = 0 si fichier trouv�
  sFileFound  : string;     // Fichier cible
  SearchRec   : TSearchRec; // M�mroisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demand�e par l'utilisteur
    exit;  // on quitte
  //
  nResult := FindFirst (sDirSource + sFilter, nAttrib, SearchRec);
  while nResult = 0 do begin
    if ((SearchRec.Attr and faDirectory) <= 0) then begin
      // Un fichier a �t� trouv�(et non pas un dossier)
      with AppliData do begin
        ItemsAdd (sTYPE_FILE);  // Ajout d'un �l�ment � la liste de comparaison
        // Compl�te les informations du fichier source
        SourceUpdate (sDirSource, SearchRec); // Compl�te cet �l�mment
        // Teste la pr�sence du fichier cible et met � jour les infos
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
|  Gestion du scanning des sous-r�pertoires 'source' pour rechercher         |
|  les fichiers et les sous-r�perrtoires                                     |
|----------------------------------------------------------------------------|                                              |
|  Param�tres :                                                              |
|  - sDirSource   : R�pertoire source pour la recherche des fichiers         |
|  - sDirTarget   : R�pertoire cible pour la recherchce des fichiers         |
|  - sFilter      : Filtre choisi pour la s�lection des fichiers             |
|  - nAttrib      : Attributs choisis pour la s�lecion des fichiers          |
|  - bSubDir      : D�fini si l'on cherche dans les sous-r�pertoires         |
==============================================================================
}
procedure TScanThread.ScanDirSource (const sDirSource, sDirTarget, sFilter: string;
                                     const nAttrib: integer; const bSubDir: boolean);
var
  bDirAdd         : boolean;    // Indique si le r�pertoire courant est ajout� � la liste
  nFiles          : integer;    // Nombre de fichiers trouv�s dans le r�pertoire
  SearchRec       : TSearchRec; // M�morisation des informations du fichier courant
begin
  if AppliData.bScanActive = FALSE then  // Interruption demand�e par l'utilisteur
    exit;  // on quitte
  //
  // --- Gestion du r�pertoire source ---
  // Mise � jour du chemin dans l'interface
  FrmMain.EditSourcePath.Text := sDirSource;
  // Teste si le r�pertoire surce contient au moins un fichier
  nFiles := Files.FilesCount (sDirSource, sFilter, FALSE, TRUE);
  // Ajoute le r�pertoire source dans la liste
  bDirAdd := FALSE;
  if nFiles > 0 then begin
    DirAdd (sDirSource, sDirTarget);
    bDirAdd := TRUE;
    // Ajoute dans la liste les fichiers du r�pertoire courant
    CtrlFilesSource (sDirSource, sDirTarget, sFilter, nAttrib, bSubDir);
  end;
  ListUtils.UpdateStatusBar (nSTAT_BOTH);  // Mise � jour des infos de la barre d'�tat
  // --- Gestion du r�pertoire cible ---
  // Mise � jour du chemin dans l'interface
  FrmMain.EditTargetPath.Text := sDirTarget + SearchRec.Name;
  // Teste si le r�pertoire cible contient au moins un fichier
  nFiles := Files.FilesCount (sDirTarget, sFilter, FALSE, TRUE);
  if nFiles > 0 then begin
    if bDirAdd = FALSE then begin
      DirAdd (sDirSource, sDirTarget);
    end;
    // Cherche des fichiers dans le r�pertoire cible absents du r�pertoire source
    CtrlFilesTarget (sDirTarget, sDirSource, sFilter, nAttrib, bSubDir);
  end;
  // Cherche des sous-r�pertoires dans le r�pertoire cible absents du  r�pertoire source
  //
  //--- Si recherche dans les sous-r�pertoires
  if AppliData.bSubFolder then begin
    // Recherche des sous-r�pertoires
    if FindFirst (sDirSource + '*.*', faDirectory + faHidden, SearchRec) = 0 then
    repeat
      if Files.IsChildDir (SearchRec) then begin
        // Appel r�entrant de la proc�dure ScanDirSource
        ScanDirSource (sDirSource + SearchRec.Name + '\', sDirTarget + SearchRec.Name + '\', sFilter, nAttrib, bSubDir);
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

{
==============================================================================
|  Gestion du scanning des r�pertoires 'source' et 'cible'                   |
|----------------------------------------------------------------------------|                                              |
|  Gestion de la recherche des fichiers et sous-r�pertoires du r�pertoire    |
|  source et du r�pertoire cible                                             |
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
    bScanActive := TRUE;    // D�but de la recherche des �l�ments � afficher
    FrmMain.CheckListBox.Clear;
    sListFiles.Clear;
    ScanDirSource (sSourcePath, sTargetPath, sFileFilter, nAttrib, bSubFolder);
    ScanDirTarget (sTargetPath, sSourcePath, sFileFilter, nAttrib, bSubFolder);
    // Mise � jour de l'interface
    ListUtils.UpdateStatusBar (nSTAT_BOTH);
    bScanActive := FALSE;   // Fin de la recherche des �l�ments � afficher
    FrmMain.CheckListBox.Refresh;
    FrmMain.EditSourcePath.Clear;
    FrmMain.EditTargetPath.Clear;
  end;
end;


end.
