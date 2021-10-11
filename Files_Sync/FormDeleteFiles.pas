{
==============================================================================
|
|  Unit         : FormDeleteFiles.pas
|
|  Description  : Gestion de la suppression des fichiers
|
==============================================================================
}
unit FormDeleteFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  Utils, Declare, Language, Language_Lib, FilesUtils;

type
  TFrmDelete = class(TForm)
    PanelSourceTarget: TPanel;
    ImageDelFromSource: TImage;
    CheckBoxDelFromSource: TCheckBox;
    ImageDelFromTarget: TImage;
    CheckBoxDelFromTarget: TCheckBox;
    //
    PanelConfirm: TPanel;
    ImageConfirm: TImage;
    CheckBoxConfirm: TCheckBox;
    ImageNotRecycle: TImage;
    CheckBoxNotRecycle: TCheckBox;
    //
    PanelProgress: TPanel;
    LabelProgress: TLabel;
    ProgressBarDelete: TProgressBar;
    //
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonStop: TButton;
    procedure FormCreate(Sender: TObject);
    procedure InitTexts;
    procedure CtrlButtonOk;
    procedure CtrlPanelsAndButtons (const nPhase: integer);
    function  DeleteFiles: integer;
    procedure CheckBoxDelClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Déclarations privées }
    bLoopDelete  : boolean;   // Pour contrôle de la boucle de suppression
    nModalResult : integer;   // Valeur e retour de l boîte de dialogue
    nCountSource : integer;   // Nombre de fichiers sources sélectionnés
    nCountTarget : integer;   // Nombre de fichiers cibles sélectionnés
  public
    { Déclarations publiques }
  end;

var
  FrmDelete: TFrmDelete;

implementation

uses
  FormMain, UserControl;

{$R *.dfm}

{
========================================================
|  Gestion de la création de la fenêtre                |
|------------------------------------------------------|                                              |
|  Création et initilisation des éléments nécessaires  |
|  au bon fonctionnement de l'application              |
========================================================
}
procedure TFrmDelete.FormCreate(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  nModalResult := mrCancel;
  ProgressBarDelete.Position := 0;
  ButtonStop.Left := ButtonCancel.Left;
  CtrlPanelsAndButtons (1);
  CtrlButtonOk;
  InitTexts;
  CheckBoxConfirm.Checked := Applidata.bDelConfirm;
  CheckBoxNotRecycle.Checked := AppliData.bDelMoveRecycle;
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
procedure TFrmDelete.InitTexts;

     {----------------------------------------------------
     |  Affichage du texte pour effacement des fichiers  |
     ----------------------------------------------------}
     procedure CtrlDeleteText (CheckBox: TCheckBox; nCount: integer; sText: string);
     begin
       with CheckBox do begin
         if nCount > 1 then
           Caption := ' '  + IntToStr (nCount) + ' ' + Lang.sMsg_Files
         else
           Caption := ' ' + IntToStr (nCount) + ' ' + Lang.sMsg_File;
         Caption := Caption + ' ' + sText;
         if nCount = 0 then
           CheckBox.Enabled := FALSE;
       end;
     end;

begin
  // Lecture des textes en fonction de la langue
  if sLanguage = '' then
    sLanguage := sFRENCH;
  Lang.ReadLanguage (sLanguage);
  // Textes des composants
  FrmDelete.Caption := Lang.sDel_Title;
  CheckBoxConfirm.Caption := ' ' + lang.sDel_Confirmation;
  CheckBoxNotRecycle.Caption := ' ' + lang.sDel_MoveRecycle;
  LabelProgress.Caption := Lang.sDel_Progress;
  ButtonOk.Caption := Lang.sDel_ButtonDelete;
  ButtonCancel.Caption := LangLib.sBut_Cancel;
  ButtonStop.Caption := Lang.sDel_ButtonStop;
  // Textes pour les cases à cocher
  CtrlDeleteText (CheckBoxDelFromSource, nCountSource, Lang.sDel_FromSource);
  CtrlDeleteText (CheckBoxDelFromTarget, nCountTarget, Lang.sDel_Fromtarget);
end;

{
======================================================
|  Contrôle la disponibilité du bouton ok (enabled)  |
======================================================
}
procedure TFrmDelete.CtrlButtonOk;
begin
  // Compte le nombre de fichiers à supprimer
  ListUtils.CountFilesSelected (nCountSource, nCounttarget);
  // Contrôle du bouton Ok
  if ((CheckBoxDelFromSource.Checked) and (nCountSource > 0))
  or ((CheckBoxDelFromTarget.Checked) and (nCountTarget > 0)) then
    ButtonOk.Enabled := TRUE
  else
    ButtonOk.Enabled := FALSE;
end;

{
==================================================================
|  Gestion de l'affichage des panneaux et des boutons            |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - Integer : Pour gérer les différents états d'affichage       |
==================================================================
}
procedure TFrmDelete.CtrlPanelsAndButtons (const nPhase: integer);
var
  nButPosY    : integer;
begin
  nButPosY := 0;
  case nPhase of
    1 : begin
          PanelProgress.Visible := FALSE;
          nButPosY := PanelConfirm.Top + PanelConfirm.Height + 8;
          ButtonStop.Visible  := FALSE;
          ButtonCancel.Visible := TRUE;
        end;
    2 : begin
          PanelProgress.Visible := TRUE;
          nButPosY := PanelProgress.Top + PanelProgress.Height + 8;
          ButtonOk.Enabled := FALSE;
          ButtonStop.Visible := TRUE;
          ButtonCancel.Visible := FALSE;
        end;
    3 : begin
          nButPosY := PanelProgress.Top + PanelProgress.Height + 8;
          ButtonStop.Visible  := FALSE;
          ButtonCancel.Visible := TRUE;
        end;
  end;
  ButtonOk.Top := nButPosY;
  ButtonStop.Top := nButPosY;
  ButtonCancel.Top := nButPosY;
  FrmDelete.ClientHeight := nButPosY + ButtonOk.Height + 8;
  Repaint;
end;

{
==============================================================
|  Gestion de la suppression des fichiers sélectionnés       |
|------------------------------------------------------------|                                              |
|  Valeur de retour :                                        |
|  - Integer : mrOk si supperssion effectuée sinon mrCancel  |
==============================================================
}
function TFrmDelete.DeleteFiles: integer;
var
  i       : integer;  // Pour itération
  nAttrib : integer;  // Attributs du fichier
  nCount  : integer;  // Nombre total de fichiers sélectionnés
  nPos    : integer;  // Pour gérer la barre de progression de l'effacement
  sMsg    : string;   // Pour textes des messages
  sFile   : string;   // Nom du fichier
  sPath   : string;   // Chemin du fichier
  sFields : array[0..8] of string;  // Contenu des colonnes
  pChar1  : array[0..255] of char;  // pour conversion pour MessageBox
  pChar2  : array[0..255] of char;  // pour conversion pour MessageBox


      {---------------------------------------------------------
      |  Suppression avec ou sans déplacement dans la poubelle  |
      -----------------------------------------------------------}
      procedure DelFile (const sFileName: string);
      begin
        // Gestion de l'attributs 'Lecture seule'
        nAttrib := FileGetAttr(sFileName);
        if (nAttrib and faReadOnly) <> 0 then
          FileSetAttr(sFileName, nAttrib - faReadOnly);
        // Suppression du fichier
        if AppliData.bDelMoveRecycle then
          Files.DeleteFileToRecycleBin (sFileName)
        else
          DeleteFile (sFileName);
      end;


begin
  with FrmMain do begin
    nCount := 0;
    sMsg := '';
    Result := mrOk;
    // Nombre total de fichiers
    if CheckBoxDelFromSource.Checked then
      nCount := nCountSource;
    if CheckBoxDelFromTarget.Checked then
      nCount := nCount + nCountTarget;
    // Gestion de la confirmation de suppression
    if AppliData.bDelConfirm then begin
      // Choix du message
      if AppliData.bDelMoveRecycle then begin
        // Si déplacement dans la corbeille
        if nCount > 1 then
          sMsg := Lang.sDel_MsgRecycleAll + ' ' + IntToStr (nCount)
                  + ' ' + Lang.sDel_MsgRecycleFiles
        else
          sMsg := Lang.sDel_MsgRecycleOne;
      end
      else begin
        // Si suppression défnitive
        if nCount > 1 then
          sMsg := Lang.sDel_MsgDeleteAll + ' ' + IntToStr (nCount)
                  + ' ' + Lang.sMsg_Files + ' ?'
        else
          sMsg := Lang.sDel_MsgDeleteOne;
      end;
      // Affichage du message
      Result := MessageBox(0, StrPcopy(pChar1, sMsg), StrPcopy(pChar2, Lang.sDel_Confirmation), MB_OKCancel);
    end;
    //
    if Result = mrOk then begin
      CtrlPanelsAndButtons (2);
      // Ajuste la barre de progression
      nPos := 0;
      ProgressBarDelete.Max := nCount;
      ProgressBarDelete.Position := 0;
      // Parcours de la liste pour suppression des fichiers
      for i := 0 to CheckListBox.Count - 1 do begin
        // Contrôle si abandon de la suppression
        if not bLoopDelete then begin
          Result := mrOk;
          exit;     // Quitte la suppression des fichiers
        end;
        // Contrôle si ligne sélectionnée pour synchronisation
        if CheckListBox.Selected[i] then begin
          // Récupération du contenu de la ligne
          ListUtils.ColContent (CheckListBox.Items[i], sFields);
          // Cherche le chemin correspondant au fichier
          if CheckBoxDelFromSource.Checked then begin
            // Côté source
            sPath := ListUtils.SearchPathOfFile (i, nSOURCE);
            sFile := sFields[nCOL_SOURCENAME];
            DelFile (sPath + sFile);
            inc(nPos);
            ProgressBarDelete.Position := (nPos);
          end;
          if CheckBoxDelFromTarget.Checked then begin
            // Côté cible
            sPath := ListUtils.SearchPathOfFile (i, nTARGET);
            sFile := sFields[nCOL_TARGETNAME];
            DelFile (sPath + sFile);
            inc(nPos);
            ProgressBarDelete.Position := (nPos);
          end;
          ProgressBarDelete.Repaint;
          Application.ProcessMessages;
        end;
      end;
    end;
  end;
end;

{
==================================================
|  Réponse au click des Checkbox source / cible  |
==================================================
}
procedure TFrmDelete.CheckBoxDelClick(Sender: TObject);
begin
  CtrlButtonOk;
end;

{
========================================================
|  Abandon de la gestion de la suppression fichiers    |
|------------------------------------------------------|                                              |
|  Quitte le dialogue après avoir lancer la            |
|  suppression des fichiers                            |
========================================================
}
procedure TFrmDelete.ButtonOkClick(Sender: TObject);
begin
  with AppliData do begin
    nModalResult := mrOk;
    bDelConfirm := CheckBoxConfirm.Checked;
    bDelMoveRecycle := CheckBoxNotRecycle.Checked;
    bLoopDelete := TRUE;
    DeleteFiles;
    // Si pas d'interruption par l'utilisateur, on quitte le dialogue
    if bLoopDelete = TRUE then
      ModalResult := mrOk
    else
      CtrlPanelsAndButtons (3);   // Sinon on ajuste l'affichage
  end;
end;

{
============================================
|  Abandon de la suppression des fichiers  |
============================================
}
procedure TFrmDelete.ButtonStopClick(Sender: TObject);
begin
  bLoopDelete := FALSE;
  ButtonStop.Enabled := FALSE;
end;

{
========================================================
|  Abandon de la gestion des suppressions de fichiers  |
|------------------------------------------------------|                                              |
|  Quitte le dialogue sans lancer la suppression       |
========================================================
}
procedure TFrmDelete.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := nModalResult;
end;

end.
