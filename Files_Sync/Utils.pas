{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : Utils.pas
|
|  Description  : Diverses méthodes utilisées par plusieurs autres fichiers
|
==============================================================================
}
unit Utils;

interface

uses
  Forms, Sysutils, StdCtrls, COntrols, CheckLst,
  FilesUtils, Language, StringUtils, DatesFunc, Declare;

type

  TListUtils = class
    // Pour la liste de synchronisation des fichiers
//    function NbrLinesOnCheckListBox (const CheckList: TCheckListBox): integer;
    procedure ColContent (const sItem: string; var sFields: array of string);  // string en liste
    function  GetFilesInfo (const sItem: string): boolean;
    procedure UpdateStatusBar(const nVal: integer);
    //
    function  SearchPathOfFile (const nIndex, nPath: integer): string;
    function  ExistPath (const nIndex: integer; const sPath: string): boolean;
    procedure CountFilesSelected (var nSource, nTarget: integer);
    procedure CountFilesChecked (var nSource, nTarget: integer;
                                 var nSizeToSource, nSizeToTarget: int64);
    function  ExistCriteriaInDir (const nIndex, nCriteria: integer; const bFirst: boolean): integer;
    procedure RefreshFromCriteria (const nCriteria: integer);
  end;

var
  ListUtils : TListUtils;

implementation

uses
  FormMain, UserControl;


{
==============================================================================
=============  Pour la liste de synchronisation des fichiers  ================
==============================================================================
}
{
================================================================
|  Retourne le nombre de lignes affichées dans un CheckListBox  |
|---------------------------------------------------------------|                                              |
|  Paramètre :                                                  |
|  - CheckList  : le CheckListBox concerné                      |
|---------------------------------------------------------------|                                              |
|  Valeur de retour :                                           |
|  - integer  : le nombre de lignes dans le CheckListBox        |
=================================================================
}
{
function TListUtils.NbrLinesOnCheckListBox (const CheckList: TCheckListBox): integer;
begin
  Result := (CheckList.Height div CheckList.ItemHeight)+ 1;
end;
}

{
===============================================================
|  Extraction du contenu d'un item dans un array de strings   |
|-------------------------------------------------------------|                                              |
|  Paramètres :                                               |
|  - sItem    : string contenant les infos des colonnes       |
|  - sFields  : récupère le contenu de chaque colonne         |
===============================================================
}
procedure TListUtils.ColContent (const sItem: string; var sFields: array of string);
var
  i     : integer;  // Pour itération
begin
  // Extraction des éléments
  for i := 0 to length(sFields) - 1 do begin
    sFields[i] := '';
    sFields[i] := Str.GetToken (sItem, ';', i + 1);
  end;
  // Ctrl de l'existence du fichier côté source
  if sFields[nCOL_SOURCEDATE] = DateTimeToStr (0) then begin
    sFields[nCOL_SOURCESIZE] := ''; // = RecFile.nSourceSize
    sFields[nCOL_SOURCEDATE] := ''; // = RecFile.nSourceDate
  end;
  // Ctrl de l'existence du fichier côté cible
  if sFields[nCOL_TARGETDATE] = DateTimeToStr (0) then begin
    sFields[nCOL_TARGETDATE] := ''; // = RecFile.nSourceDate
    sFields[nCOL_TARGETSIZE] := ''; // = RecFile.nSourceSize
  end;
end;

{
===============================================================
|  Acquisition des informations des fichiers                  |
|-------------------------------------------------------------|                                              |
|  Paramètre :                                                |
|  - sItem  : élément cmplet dune ligne de la liste           |
|-------------------------------------------------------------|                                              |
|  Valeur de retour :                                         |
|  - boolean  : Retourne TRUE di ligne ficihier, sinon FALSE  |
===============================================================
}
function TListUtils.GetFilesInfo (const sItem: string): boolean;
var
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  with AppliData do begin
    ColContent (sItem, sFields);
    if sFields[nCOL_TYPE] = sTYPE_FILE then begin
      if sFields[nCOL_SOURCEDATE] <> '' then begin
        Inc (nNbrFilesSource);
        if sFields[nCOL_SYNC] = '>' then begin
          Inc (nNbrTaggedSource);
          nSizeSelSource := nSizeSelSource + StrToInt (sFields[nCOL_SOURCESIZE]);
        end;
      end;
      if sFields[nCOL_TARGETDATE] <> '' then begin
        Inc (nNbrFilesTarget);
        if sFields[nCOL_SYNC] = '<' then begin
          Inc (nNbrTaggedTarget);
          nSizeSelTarget := nSizeSelTarget + StrToInt (sFields[nCOL_TARGETSIZE]);
        end;
      end;
    end;
  end;
  Result := TRUE;
end;

{
=============================================
|  Affichage du contenu de la barre d'état  |
|-------------------------------------------|
|  Paramètre :                              |
|  - nVal : Défini si c'est côté source ou  |
|           destination qui est mis à jour  |
=============================================
}
procedure TListUtils.UpdateStatusBar (const nVal: integer);
var
  sText : string;
begin
  with FrmMain, AppliData do begin
    if nVal = nSTAT_CLEAR then begin
      StatusBar.Panels[0].Text := '';
      StatusBar.Panels[3].Text := '';
    end
    else if (nVal = nSTAT_SOURCE) or (nVal = nSTAT_BOTH) then begin
      sText := IntToStr (nNbrTaggedSource) + ' ' + Lang.sMsg_FilesOf + ' ';
      sText := sText + IntToStr (nNbrFilesSource) + ' ';
      sText := sText + Lang.sMsg_Files;
      sText := sText + ' (' + Str.FileSizeAutoStr (nSizeSelSource) + ') - ';
      sText := sText + Str.FileSizeAutoStr (nFreeDiskSource) + ' ' + Lang.sMsg_FreeSpace;
      StatusBar.Panels[0].Text := sText;
    end;
    if (nVal = nSTAT_TARGET) or (nVal = nSTAT_BOTH) then begin
      sText := IntToStr (nNbrTaggedTarget) + ' ' + Lang.sMsg_FilesOf + ' ';
      sText := sText + IntToStr (nNbrFilesTarget) + ' ';
      sText := sText + Lang.sMsg_Files;
      sText := sText + ' (' + Str.FileSizeAutoStr (nSizeSelTarget) + ') - ';
      sText := sText + Str.FileSizeAutoStr (nFreeDiskTarget) + ' ' + Lang.sMsg_FreeSpace;
      StatusBar.Panels[3].Text := sText;
    end;
  end;
end;

{
==============================================================
|  Recherche si le chemin existe déjà dans la liste          |
|------------------------------------------------------------|                                              |
|  Paramètre :                                               |
|  - nIndex : Recherche à partir de l'index jusqu'au début   |
|  - sPath  : Nom du chemin/répertoire à chercher            |
|------------------------------------------------------------|                                              |
|  Valeur de retour:                                         |
|  - boolean : RetoUE si trouvé                              |
==============================================================
}
function TListUtils.ExistPath (const nIndex: integer; const sPath: string): boolean;
var
  i       : integer;  // Pour itération
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  Result := FALSE;
  with FrmMain do begin
    for i := (nIndex) downto 0 do begin
      ColContent (CheckListBox.Items[i], sFields);
      if sFields[nCOL_TYPE]= sTYPE_DIR then begin
        if CompareText (sPath, sFields[nCOL_SOURCENAME]) = 0 then begin
          Result := TRUE;
          exit;
        end;
      end;
    end;
  end;
end;

{
==============================================================
|  Recherche du chemin associé au fichier sélectionné        |
|------------------------------------------------------------|                                              |
|  Paramètre :                                               |
|  - nIndex : Index du fichier dans la liste de comparaison  |
|  - bSrc   : Si TRUE pour chemin source sinon destination   |
|------------------------------------------------------------|                                              |
|  Valeur de retour:                                         |
|  - string : Chemin associé au fichier séectionné           |
==============================================================
}
function TListUtils.SearchPathOfFile (const nIndex, nPath: integer): string;
var
  i       : integer;  // Pour itération
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  Result := '';
  with FrmMain do begin
    for i := (nIndex - 1) downto 0 do begin
      ColContent (CheckListBox.Items[i], sFields);
      if sFields[nCOL_TYPE]= sTYPE_DIR then begin
        if nPath = nSOURCE then
          Result := sFields[nCOL_SOURCENAME]
        else
          Result := sFields[nCOL_TARGETNAME];
        exit;
      end;
    end;
  end;
end;

{
=========================================================================
|  Compte le nombre d'éléments sélectionnés côté source et destination  |
|-----------------------------------------------------------------------|
|  Paramètre :                                                          |
|  - nSource  : contient le nombre d'élément du côté source             |
|  - nTarget  : contient le nombre d'élément du côté cible              |
=========================================================================
}
procedure TListUtils.CountFilesSelected (var nSource, nTarget: integer);
var
  i         : integer;    // Pour itération
  DateTime  : TDateTime;  // Pour méthode IsValideDateTime
  sFields   : array[0..8] of string;  // Contenu des colonnes
begin
  nSource := 0;
  nTarget := 0;
  with FrmMain do begin
    for i := 0 to CheckListBox.Count - 1 do begin
      ColContent (CheckListBox.Items[i], sFields);
      if sFields[nCOL_TYPE]= sTYPE_FILE then begin  // Teste si ligne fichier
        if CheckListBox.Selected[i] then begin    // Teste si la ligne est sélectionnée
          // Comptabilise que les lignes qui sont checkées
          if Dates.IsValidDateTime (sFields[nCOL_SOURCEDATE], DateTime) then
            inc (nSource);
          if Dates.IsValidDateTime (sFields[nCOL_TARGETDATE], DateTime) then
            inc (nTarget);
        end;
      end;
    end;
  end;
end;

{
=========================================================================
|  Compte le nombre d'éléments cochés côté source et côté destination   |
|-----------------------------------------------------------------------|
|  Paramètre :                                                          |
|  - nSource        : contient le nombre d'élément du côté source       |
|  - nTarget        : contient le nombre d'élément du côté cible        |
|  - nSizeToSource  : taille des fichiers qui sera ajoutée à la source  |
|  - nSizeToTarget  : taille des fichiers qui sera ajoutéeà la cibe     |
=========================================================================
}
procedure TListUtils.CountFilesChecked (var nSource, nTarget: integer;
                                        var nSizeToSource, nSizeToTarget: Int64);
var
  i         : integer;    // Pour itération
  sFields   : array[0..8] of string;  // Contenu des colonnes
begin
  nSource := 0;
  nTarget := 0;
  nSizeToSource := 0;
  nSizeToTarget := 0;
  with FrmMain do begin
    for i := 0 to CheckListBox.Count - 1 do begin
      if CheckListBox.Checked[i] then begin
        ColContent (CheckListBox.Items[i], sFields);
        if sFields[nCOL_SYNC] = '>' then begin
          inc (nSource);
          nSizeToTarget := nSizeToTarget + (StrToInt64Def (sFields[nCOL_SOURCESIZE], 0) -
                                            StrToInt64Def (sFields[nCOL_TARGETSIZE], 0));
        end
        else if sFields[nCOL_SYNC] = '<' then begin
          inc (nTarget);
          nSizeToSource := nSizeToSource + (StrToInt64Def (sFields[nCOL_TARGETSIZE], 0) -
                                            StrToInt64Def (sFields[nCOL_SOURCESIZE], 0));
        end;
      end;
    end;
  end;
end;

{
===============================================================
|  Compte le nombre d'éléments correspondant au critère       |
|  pour le répertoire concerné                                |
|-------------------------------------------------------------|                                              |
|  Paramètre :                                                |
|  - nIndex     : Position du répertoire dans la liste        |
|  - nCriteria  : Critère de synchronisation choisi           |
|  - bFirst     : Termine la recheche au 1er fichier trouvé   |
|-------------------------------------------------------------|                                              |
|  Valeur de retour :                                         |
|  - Integer  : Nombre d'éléments correspondant existant      |
===============================================================
}
function TListUtils.ExistCriteriaInDir (const nIndex, nCriteria: integer; const bFirst: boolean): integer;
var
  bLoop   : boolean;
  i       : integer;
  nCount  : integer;
  sItem   : string;   // Contenu d'une ligne
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  with AppliData do begin
    bLoop := TRUE;
    i := nIndex;
    nCount := 0;
    repeat
      inc (i);
      if i > (sListFiles.Count - 1) then
        bLoop := FALSE
      else begin
        sItem := sListFiles[i];   // Lecture du contenu de la listbox
          ColContent (sItem, sFields);      // Séparation du contenu des colonnes
        if sFields[nCOL_TYPE] = sTYPE_DIR then
          bLoop := FALSE
        else begin
          // Comptage en fonction du choix de la synchronisation
          case nCriteria of
            nCONTENT_ALL      : inc (nCount);

            nCONTENT_SYNCHRO  : begin
                                  if (sFields[nCOL_SYNC] = '>')
                                  or (sFields[nCOL_SYNC] = '<') then
                                    inc (nCount);
                                end;
            nCONTENT_TOTARGET : begin
                                  if sFields[nCOL_SYNC] = '>' then
                                    inc (nCount);
                                end;
            nCONTENT_TOSOURCE : begin
                                  if sFields[nCOL_SYNC] = '<' then
                                    inc (nCount);
                                end;
            nCONTENT_IDENTICAL: begin
                                  if sFields[nCOL_SYNC] = '=' then
                                    inc (nCount);
                                end;
          end;
          if bFirst and (nCount > 0) then
            bLoop := False;
        end;
      end;
    until bLoop = FALSE;
  end;
  Result := nCount;
end;

{
===============================================================
|  Construit la liste de comparaison en fonction du choix     |
|-------------------------------------------------------------|                                              |
|  Paramètre :                                                |
|  - nCriteria  : choix du critère de sélectio pour affichage |
===============================================================
}
procedure TListUtils.RefreshFromCriteria (const nCriteria: integer);
var
  bDisp     : boolean;
  i         : integer;  // Pour itération
  nTic      : integer;  // Pour déclencher Application.ProcessMessages
  sItem     : string;   // Contenu d'une ligne
  sFields   : array[0..8] of string;  // Contenu des colonnes
begin
  Screen.Cursor := crHourglass;
  UserCtrl.SetForCompare (TRUE);
  UpdateStatusBar (nSTAT_BOTH);
  with FrmMain, AppliData do begin
    // Effacement de la liste de comparaison
    CheckListBox.Clear;
    // Préparation pour les informations sur les fichiers
    nSizeSelSource := 0;
    nSizeSelTarget := 0;
    nNbrTaggedSource := 0;
    nNbrTaggedTarget := 0;
    nNbrFilesSource := 0;
    nNbrFilesTarget := 0;
    nFreeDiskSource := Files.DiskFreeSpace (sSourcePath);
    nFreeDiskTarget := Files.DiskFreeSpace (sTargetPath);
    UpdateStatusBar (nSTAT_BOTH);

    // Ajoute dans la liste de comparaison les élémenst en fonction du critère
    nTic := 0;
    AppliData.bScanActive := TRUE;   // Début de la recherche des éléments à afficher
    for i := 0 to sListFiles.Count - 1 do begin
      if AppliData.bScanActive = FALSE then  // interruption par l'utilisteur
        exit;  // on quitte
      //
      bDisp := FALSE;
      sItem := sListFiles[i];   // Lecture du contenu de la listbox
      ColContent (sItem, sFields);      // Séparation du contenu des colonnes
      if sFields[nCOL_TYPE] = sTYPE_DIR then begin
        if ExistCriteriaInDir (i, nCriteria, TRUE) > 0 then
          bDisp := TRUE;
      end
      else begin
        // Choix si affichage ou non de l'élément
        case nCriteria of
          nCONTENT_ALL      : bDisp := TRUE;
          nCONTENT_SYNCHRO  : begin
                                if (sFields[nCOL_SYNC] = '>')
                                or (sFields[nCOL_SYNC] = '<') then
                                  bDisp := TRUE;
                              end;
          nCONTENT_TOTARGET : begin
                                if sFields[nCOL_SYNC] = '>' then
                                  bDisp := TRUE;
                              end;
          nCONTENT_TOSOURCE : begin
                                if sFields[nCOL_SYNC] = '<' then
                                  bDisp := TRUE;
                              end;
          nCONTENT_IDENTICAL: begin
                                if sFields[nCOL_SYNC] = '=' then
                                  bDisp := TRUE;
                              end;
        end;
      end;
      if bdisp then begin
        CheckListBox.Items.Append(sItem);   // Ajout dans la liste de compraison
        if (sFields[nCOL_TYPE] = sTYPE_FILE)
        and ((sFields[nCOL_SYNC] = '>') or (sFields[nCOL_SYNC] = '<')) then begin
          // Contrôle des cases à cocher
          if sFields[nCOL_CHECKED] = '1' then
            CheckListBox.State[CheckListBox.Count - 1] := cbChecked
          else
            CheckListBox.State[CheckListBox.Count - 1] := cbUnchecked;
          // Invalide les cases à cocher des lignes sans synchronsaton
          if sFields[nCOL_SYNC] = '=' then
            CheckListBox.ItemEnabled[CheckListBox.Count - 1] := FALSE;
        end;
        // Gestin des affichages
        if GetFilesInfo (sItem) then begin
          UpdateStatusBar (nSTAT_BOTH);
          inc (nTic);
          if nTic = 20 then begin
            nTic := 0;
            Application.ProcessMessages;
          end;
        end;
      end;
    end;
    AppliData.bScanActive := FALSE; // Fin de la recherche des àlàments à afficher
  end;
  UserCtrl.SetForCompare (FALSE);
  Screen.Cursor := crDefault;
end;


end.

