unit FormDelCleanDir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ExtCtrls,
  Declare, Language, Language_Lib, FilesUtils;

type
  TFrmDelDir = class(TForm)
    CheckBoxSource: TCheckBox;
    CheckListBoxDirSource: TCheckListBox;
    CheckBoxTarget: TCheckBox;
    CheckListBoxDirTarget: TCheckListBox;
    //
    PanelConfirm: TPanel;
    ImageConfirm: TImage;
    ImageNotRecycle: TImage;
    CheckBoxConfirm: TCheckBox;
    CheckBoxNotRecycle: TCheckBox;
    //
    PanelProgressBar: TPanel;
    LabelProgress: TLabel;
    ProgressBarDelete: TProgressBar;
    //
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonStop: TButton;
    procedure FormCreate(Sender: TObject);
    procedure InitTexts;
    procedure CtrlButtonOk;
    procedure CtrlFormAndButtons (const nPhase: integer);
    procedure CheckListBoxDirClickCheck(Sender: TObject);
    procedure CheckBoxListClick(Sender: TObject);
    function  DirCount (CheckList: TCheckListBox): integer;
    procedure ScanDir (const sDir: string; CheckList: TCheckListBox; var nCount: integer);
    function  SearchCleanDir: integer;
    function  DeleteCleanDir: integer;
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Déclarations privées }
    bLoopDelete     : boolean;  // Pour contrôle de la boucle de suppression
    nSourceChecked  : integer;  // Nombre de répertoires sources vides checkés
    nTargetChecked  : integer;  // Nombre de fichiers cibles vides checkés
  public
    { Déclarations publiques }
  end;

var
  FrmDelDir: TFrmDelDir;

implementation

{$R *.dfm}


{
========================================================
|  Gestion de la création de la fenêtre                |
|------------------------------------------------------|                                              |
|  Création et initilisation des éléments nécessaires  |
|  au bon fonctionnement de l'application              |
========================================================
}
procedure TFrmDelDir.FormCreate(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  ProgressBarDelete.Position := 0;
  ButtonStop.Left := ButtonCancel.Left;
  CtrlFormAndButtons (1);
  InitTexts;
  SearchCleanDir;
  CtrlButtonOk;
  CheckBoxSource.Checked := TRUE;
  CheckBoxTarget.Checked := TRUE;
  CheckBoxConfirm.Checked := Applidata.bDelConfirm2;
  CheckBoxNotRecycle.Checked := AppliData.bDelMoveRecycle2;
  Screen.Cursor := crDefault;
end;

{
==================================================================
|  Initialisation des textes en fonction de la langue            |
|----------------------------------------------------------------|                                              |
|  - Lecture de la langue mémorisée (prévu pour du multilingue)  |
|  - Lecture des textes dans le fichier de la lague choisie      |
|  - Affectation des textes aux composants                       |
==================================================================
}
procedure TFrmDelDir.InitTexts;
begin
  // Lecture des textes en fonction de la langue
  if sLanguage = '' then
    sLanguage := sFRENCH;
  Lang.ReadLanguage (sLanguage);
  // Textes des composants
  FrmDelDir.Caption := Lang.sDel_DirTitle;
  CheckBoxSource.Caption := Lang.sDel_DirCleanSource;
  CheckBoxTarget.Caption := Lang.sDel_DirCleanTarget;
  CheckBoxConfirm.Caption := ' ' + lang.sDel_Confirmation;
  CheckBoxNotRecycle.Caption := ' ' + lang.sDel_MoveRecycle;
  LabelProgress.Caption := Lang.sDel_Progress;
  LabelProgress.Caption := Lang.sDel_Progress;
  ButtonOk.Caption := Lang.sDel_ButtonDelete;
  ButtonCancel.Caption := LangLib.sBut_Cancel;
  ButtonStop.Caption := Lang.sDel_ButtonStop;
end;

{
======================================================
|  Contrôle la disponibilité du bouton ok (enabled)  |
======================================================
}
procedure TFrmDelDir.CtrlButtonOk;
begin
  if (CheckBoxSource.Checked and (nSourceChecked > 0))
  or (CheckBoxTarget.Checked and (nTargetChecked > 0)) then
    ButtonOk.Enabled := TRUE
  else
    ButtonOk.Enabled := FALSE;
end;

{
==================================================================
|  Gestion de l'affichage de la fenêtre et des boutons           |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - nPhase : Pour gérer les différents états d'affichage        |
==================================================================
}
procedure TFrmDelDir.CtrlFormAndButtons (const nPhase: integer);
var
  nButPosY    : integer;
begin
  case nPhase of
    1 : begin
          LabelProgress.Enabled := FALSE;
          ProgressBarDelete.Enabled := FALSE;
          ButtonStop.Visible  := FALSE;
          ButtonCancel.Visible := TRUE;
        end;
    2 : begin
          LabelProgress.Enabled := TRUE;
          ProgressBarDelete.Enabled := TRUE;
          ButtonOk.Enabled := FALSE;
          ButtonStop.Visible := TRUE;
          ButtonCancel.Visible := FALSE;
        end;
  end;
  nButPosY := PanelConfirm.Top + PanelConfirm.Height + 8;
  ButtonOk.Top := nButPosY;
  ButtonStop.Top := nButPosY;
  ButtonCancel.Top := nButPosY;
  FrmDelDir.ClientHeight := nButPosY + ButtonOk.Height + 8;
  Repaint;
end;

{
==================================================================
|  Recherche des sous-répertoires vides et les ajoute à la liste |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - sDir       : Répertoire courrant pour la reherche           |
|  - CheckList  : Le composant TCheckListBox qui tient la lite   |
|  - nCount     : Nombre de sous-répertoires vides rencontrés    |
==================================================================
}
procedure TFrmDelDir.CheckListBoxDirClickCheck(Sender: TObject);
var
  i         : integer;        // Pour itération
  nLen      : integer;        // Longueur du répertoire d'origine
  sDirOrg   : string;         // Répertoire sélectionné
  sDirCmp   : string;         // Répertoire à comparer
  CheckList : TCheckListBox;  // Récupère le TChecklistBox concerné
begin
  CheckList := TCheckListBox (Sender);
  if CheckList.Checked[CheckList.ItemIndex] then begin
    sDirOrg := CheckList.Items[CheckList.ItemIndex];
    nLen := Length (sDirOrg);
    for i := CheckList.ItemIndex + 1 to CheckList.Count - 1do begin
      sDirCmp := Copy(CheckList.Items[i], 1, nLen);
      if sDirOrg = sDirCmp then
        CheckList.Checked[i]:= TRUE
      else
        exit;
    end;
  end;
  nSourceChecked := DirCount (CheckListBoxDirSource);
  nTargetChecked := DirCount (CheckListBoxDirTarget);
  CtrlButtonOk;
end;

{
==================================================================
|  Comptage du nombre de répertoire sélectionnés                 |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - CheckList : Liste des répertoires vides chooisie            |
|----------------------------------------------------------------|                                              |
|  Valeur de retourr :                                           |
|  - integer : Contient le nombre de réeprtoires sélectionnées   |
==================================================================
}
function TFrmDelDir.DirCount (CheckList: TCheckListBox): integer;
var
  i   : integer;      // Pour itération
begin
  Result := 0;
  for i := 0 to CheckList.Count - 1 do begin
    if CheckList.Checked[i] then
      inc (Result)
  end;
end;

{
==================================================================
|  Recherche des sous-répertoires vides et les ajoute à la liste |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - sDir       : Répertoire courrant pour la reherche           |
|  - CheckList  : Le composant TCheckListBox qui tient la lite   |
|  - nCount     : Nombre de sous-répertoires vides rencontrés    |
==================================================================
}
procedure TFrmDelDir.ScanDir (const sDir: string; CheckList: TCheckListBox; var nCount: integer);
var
  nFiles    : integer;    // Nombre de fichiers
  sDirTemp  : string;     // Répertoire temporaire
  SearchRec : TSearchRec; // Mémorisation des informations du fichier courant
begin
	sDirTemp := IncludeTrailingPathDelimiter (sDir);
  if FindFirst (sDirTemp + '*.*', faDirectory + faHidden, SearchRec) = 0 then
  repeat
    if Files.IsChildDir (SearchRec) then begin
      // Teste si pas de fichiers ddans le répertoire courant
      nFiles := Files.FilesCount (sDirTemp + SearchRec.Name, '\*.*', FALSE, TRUE);
      // Si pas de fichiers, scrute aussi les sous-répertoires
      if nFiles = 0 then
        nFiles := Files.FilesCount (sDirTemp + SearchRec.Name, '\*.*', TRUE, FALSE);
      if nFiles = 0 then begin
        // Répertoire vide trouvé
        inc (nCount);
        CheckList.Items.Append(sDirTemp + SearchRec.Name);
        CheckList.Checked[CheckList.Count - 1] := TRUE;
      end;
      // Appel réentrant de la procédure ScanDir
      ScanDir (sDirTemp + SearchRec.Name, CheckList, nCount);
    end;
  until FindNext(SearchRec) <> 0;
  FindClose (SearchRec);
end;

{
======================================================
|  Recherche des répertoires vides sources / cibles  |
======================================================
}
function TFrmDelDir.SearchCleanDir: integer;
begin
  Result := mrOk;
  nSourceChecked := 0;
  nTargetChecked := 0;
  CheckListBoxDirSource.Clear;
  CheckListBoxDirTarget.Clear;
  with AppliData do begin
    ScanDir (sSourcePath, CheckListBoxDirSource, nSourceChecked);
    if not bLoopDelete then // Si pas d'interruption du 1er ScanDir
      ScanDir (sTargetPath, CheckListBoxDirTarget, nTargetChecked);
  end;
  if bLoopDelete then
    Result := mrCancel;
end;

{
========================================================
|  Suppression des répertoires vides sources / cibles  |
========================================================
}
function TFrmDelDir.DeleteCleanDir: integer;
var
  nCount  : integer;  // Nombre total de répertoires vides sélectionnés
  sMsg    : string;   // Pour textes des messages
  pChar1  : array[0..255] of char;  // pour conversion pour MessageBox
  pChar2  : array[0..255] of char;  // pour conversion pour MessageBox


      {----------------------------------------------------------
      |  Suppressionavec ou sans déplacement dans la poubelle  |
      ----------------------------------------------------------}
      procedure DeleteDir (CheckList: TCheckListBox);
      var
        i   : integer;   // Popur itération
      begin
        CtrlFormAndButtons (2);
        ProgressBarDelete.Max := CheckList.Count;
        for i := CheckList.Count - 1 downto 0 do begin
          if not bLoopDelete then
            exit;   // Quitte la boucle de suppression
          ProgressBarDelete.Position := ProgressBarDelete.Position + 1;
          if CheckList.Checked[i] then begin
            if AppliData.bDelMoveRecycle then
              Files.DeleteFileToRecycleBin (CheckList.Items[i])
            else
              RemoveDir (CheckList.Items[i]);
            CheckList.Selected[i] := TRUE;
            CheckList.DeleteSelected;
            Application.ProcessMessages;
          end;
        end;
      end;

begin
  Result := mrOk;
  nCount := 0;
  // Comptage de répertoires sélectionnés
  nSourceChecked := DirCount (CheckListBoxDirSource);
  nTargetChecked := DirCount (CheckListBoxDirTarget);
  if CheckBoxSource.Checked then
    nCount := nSourceChecked;
  if CheckBoxTarget.Checked then
    nCount := nCount + nTargetChecked;
  // Gestion de la confirmation de suppression
  if AppliData.bDelConfirm2 then begin
    // Choix du message
    if AppliData.bDelMoveRecycle2 then begin
      // Si déplacement dans la corbeille
      if nCount > 1 then
        sMsg := Lang.sDel_MsgRecycleAll + ' ' + IntToStr (nCount)
                + ' ' + Lang.sDel_MsgRecycleDir
      else
        sMsg := Lang.sDel_MsgRecyOneDir;
    end
    else begin
      // Si suppression défnitive
      if nCount > 1 then
        sMsg := Lang.sDel_MsgDeleteAll + ' ' + IntToStr (nCount)
                + ' ' + Lang.sMsg_Folders + ' ?'
      else
        sMsg := Lang.sDel_MsgDelOneDir;
    end;
    // Affichage du message
    Result := MessageBox(0, StrPcopy(pChar1, sMsg), StrPcopy(pChar2, Lang.sDel_Confirmation), MB_OKCancel);
  end;
  // Sppression des répertoires
  DeleteDir (CheckListBoxDirSource);
  DeleteDir (CheckListBoxDirTarget);
end;

{
=========================================================
|  Appelé par le clic des checkbox associés aux listes  |
=========================================================
}
procedure TFrmDelDir.CheckBoxListClick(Sender: TObject);
begin
  if (CompareText (TCheckBox(Sender).Name, 'CheckBoxSource') = 0) then
    CheckListBoxDirSource.Enabled := CheckBoxSource.Checked
  else
    CheckListBoxDirTarget.Enabled := CheckBoxTarget.Checked;
  CtrlButtonOk;
end;

{
=========================================================
|  Abandon de la gestion de la suppression répertoires  |
|-------------------------------------------------------|                                              |
|  Quitte le dialogue après avoir lancer la             |
|  suppression des répertoires                          |
=========================================================
}
procedure TFrmDelDir.ButtonOkClick(Sender: TObject);
begin
  with AppliData do begin
    bDelConfirm2 := CheckBoxConfirm.Checked;
    bDelMoveRecycle2 := CheckBoxNotRecycle.Checked;
    bLoopDelete := TRUE;
    DeleteCleanDir;
  end;
  nSourceChecked := DirCount (CheckListBoxDirSource);
  nTargetChecked := DirCount (CheckListBoxDirTarget);
  CtrlButtonOk;
  // Si pas d'interruption par l'utilisateur, on quitte le dialogue
  if bLoopDelete = TRUE then
    ModalResult := mrOk
  else
    CtrlFormAndButtons (1);   // Sinon on ajuste l'affichage
end;

{
===============================================
|  Abandon de la suppression des répertoires  |
===============================================
}
procedure TFrmDelDir.ButtonStopClick(Sender: TObject);
begin
  bLoopDelete := FALSE;
  ButtonStop.Enabled := FALSE;
end;

{
===========================================================
|  Abandon de la gestion des suppressions de répertoires  |
|---------------------------------------------------------|                                              |
|  Quitte le dialogue sans lancer la suppression          |
===========================================================
}
procedure TFrmDelDir.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
