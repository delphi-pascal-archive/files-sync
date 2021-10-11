{                            f
==============================================================================
|
|  Unit         : FormSyncFiles.pas
|
|  Description  : Gestion de la synchronisation des fichiers
|
==============================================================================
}
unit FormSyncFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  Language, Language_Lib, Declare, Utils, FilesUtils;


type
  TFrmSync = class(TForm)
    PanelOptions: TPanel;
    ImageDelFromSource: TImage;
    CheckBoxSyncFromSource: TCheckBox;
    ImageDelFromTarget: TImage;
    CheckBoxSyncFromTarget: TCheckBox;
    //
    PanelCopy: TPanel;
    LabelSource: TLabel;
    EditSource: TEdit;
    LabelTarget: TLabel;
    EditTarget: TEdit;
    LabelFileName: TLabel;
    EditFileName: TEdit;
    //
    LabelProgressFile: TLabel;
    ProgressBarFile: TProgressBar;
    LabelPogress: TLabel;
    ProgressBarCopy: TProgressBar;
    //
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonStop: TButton;
    //
    procedure FormCreate(Sender: TObject);
    procedure InitTexts;
    function  CtrlSpaceOfDisks: boolean;
    procedure CtrlButtonOk;
    procedure CtrlPanelsAndButtons (const nPhase: integer);
    function  SynchroFiles: integer;
    procedure CheckBoxSyncFromClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Déclarations privées }
    bLoopSync     : boolean;  // Pour contrôle de la boucle de synchronisation
    nModalResult  : integer;  // Valeur e retour de l boîte de dialogue
    nCountSource  : integer;  // Nombre de fichiers sources cochés
    nCountTarget  : integer;  // Nombre de fichiers cibles cochés
    nSizeToSource : int64;    // Différence de taille des fichiers à copier vers la source
    nSizeToTarget : int64;    // Différence de taille des fichiers à copier vers la cible
  public
    { Déclarations publiques }
  end;


var
  FrmSync: TFrmSync;

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
procedure TFrmSync.FormCreate(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  nModalResult := mrCancel;
  ProgressBarFile.Position := 0;
  ProgressBarCopy.Position := 0;
  ButtonStop.Left := ButtonCancel.Left;
  CtrlPanelsAndButtons (1);
  InitTexts;
  CtrlButtonOk;
  CheckBoxSyncFromSource.Checked := AppliData.bSyncSource;
  CheckBoxSyncFromTarget.Checked := AppliData.bSyncTarget;
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
procedure TFrmSync.InitTexts;

     {-----------------------------------------------
     |  Affichage du texte pour copie des fichiers  |
     -----------------------------------------------}
     procedure CtrlCopyText (CheckBox: TCheckBox; nCount: integer; sText: string);
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
  FrmSync.Caption := Lang.sSyn_Title;
  ButtonOk.Caption := Lang.sSyn_ButtonSync;
  ButtonCancel.Caption := LangLib.sBut_Cancel;
  ButtonStop.Caption := Lang.sDel_ButtonStop;
  // Compte le nombre de fichiers à copier (source et destination)
  ListUtils.CountFilesChecked (nCountSource, nCountTarget,
                               nSizeToSource, nSizeToTarget);
  //
  CheckBoxSyncFromSource.Caption := '  ' + Lang.sSyn_FromSource;
  CheckBoxSyncFromTarget.Caption := '  ' + Lang.sSyn_FromTarget;
  CtrlCopyText (CheckBoxSyncFromSource, nCountSource, Lang.sSyn_FromSource);
  CtrlCopyText (CheckBoxSyncFromTarget, nCountTarget, Lang.sSyn_FromTarget);

  LabelSource.Caption := Lang.sSyn_DirSource;
  LabelTarget.Caption := Lang.sSyn_DirTarget;
  LabelFileName.Caption := Lang.sSyn_FileName;
  LabelProgressFile.Caption := Lang.sSyn_BarProgressFile;
  LabelPogress.Caption := Lang.sSyn_BarProgress;
  ButtonStop.Caption := Lang.sSyn_ButtonStop;
end;

{
======================================================
|  Contrôle la disponibilité du bouton ok (enabled)  |
======================================================
}
procedure TFrmSync.CtrlButtonOk;
begin
  if ((CheckBoxSyncFromSource.Checked) and (nCountSource > 0))
  or ((CheckBoxSyncFromTarget.Checked) and (nCountTarget > 0)) then
    ButtonOk.Enabled := TRUE
  else
    ButtonOk.Enabled := FALSE;
end;

{
==================================================================
|  Gestion de l'affichage des panneaux et des boutons            |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - Integer : Pour gérer les différents états daffichage        |
==================================================================
}
procedure TFrmSync.CtrlPanelsAndButtons (const nPhase: integer);
var
  nButPosY    : integer;
begin
  nButPosY := 0;
  case nPhase of
    1 : begin
          PanelOptions.Visible := TRUE;
          PanelCopy.Visible := FALSE;
          nButPosY := PanelOptions.Top + PanelOptions.Height + 8;
          ButtonStop.Visible  := FALSE;
          ButtonCancel.Visible := TRUE;
        end;
    2 : begin
          PanelOptions.Visible := FALSE;
          PanelCopy.Visible := TRUE;
          PanelCopy.Top := 8;
          nButPosY := PanelCopy.Top + PanelCopy.Height + 8;
          ButtonOk.Enabled := FALSE;
          ButtonStop.Visible := TRUE;
          ButtonCancel.Visible := FALSE;
        end;
    3 : begin
          nButPosY := PanelCopy.Top + PanelCopy.Height + 8;
          ButtonStop.Visible  := FALSE;
          ButtonCancel.Visible := TRUE;
        end;
  end;
  ButtonOk.Top := nButPosY;
  ButtonStop.Top := nButPosY;
  ButtonCancel.Top := nButPosY;
  FrmSync.ClientHeight := nButPosY + ButtonOk.Height + 8;
  Repaint;
end;


{
=========================================================================
|  Contrôle si suffisamment d'espace sur les disques pour synchroniser  |
|-----------------------------------------------------------------------|                                              |
|  Valeur de retour :                                                   |
|  - boolean : Si TRUE, autorise la synchronisation, sinon FALSE        |
=========================================================================
}
function TFrmSync.CtrlSpaceOfDisks: boolean;
var
  sMsg  : string;     // Contenu des messages
  pChar1 : array[0..255] of char;  // pour conversion pour MessageBox
  pChar2 : array[0..255] of char;  // pour conversion pour MessageBox
begin
  sMsg := '';
  Result := TRUE;
  // --- Test du dépassement de la capacité des disques
  // Test le dépassement de capacité de l'unité source
  if CheckBoxSyncFromTarget.Checked
  and (nSizeToSource >= AppliData.nFreeDiskSource) then begin
    Result := FALSE;
    sMsg := Lang.sSyn_NotSpaceSource;
  end;
  // Test le dépassement de capacité de l'unité destination
  if CheckBoxSyncFromSource.Checked
  and (nSizeToTarget >= AppliData.nFreeDiskTarget) then begin
    Result := FALSE;
    if sMsg = '' then
      sMsg := Lang.sSyn_NotSpaceTarget
    else
      sMsg := sMsg + sCRLF + Lang.sSyn_NotSpaceTarget;
  end;
  // Message de dépassement
  if not Result then begin
    MessageBox(0, StrPcopy(pChar1, sMsg), StrPcopy(pChar2, Lang.sSyn_NotSpaceTitle), MB_OK);
  end
  else begin
    // --- Test du dépassement de plus du 80% de la capacité des disques
    sMsg := '';
    // Test si dépassement de plus de 80% de la place de l'unité source
    if CheckBoxSyncFromTarget.Checked
    and (nSizeToSource >= (AppliData.nFreeDiskSource * 0.8)) then begin
      Result := FALSE;
      sMsg := Lang.sSyn_NotSpaceSource80;
    end;
    // Test si dépassement de plus de 80% de la place de l'unité cible
    if CheckBoxSyncFromSource.Checked
    and (nSizeToTarget >= (AppliData.nFreeDiskTarget * 0.8)) then begin
      Result := FALSE;
      if sMsg = '' then
        sMsg := Lang.sSyn_NotSpaceTarget80
      else
        sMsg := sMsg + sCRLF + Lang.sSyn_NotSpaceTarget80;
    end;
    // Confirmation de la synchronisation
    if Not Result then begin
      sMsg := sMsg + sCRLF + sCRLF + Lang.sSyn_ConfirmSynchro;
      if mrOk = MessageBox(0, StrPcopy(pChar1, sMsg), StrPcopy(pChar2, Lang.sSyn_NotSpaceTitle), MB_OKCancel) then
        Result := TRUE
    end;
  end;
end;

{
==================================================================
|  Gestion de la synchronisation des fichiers sélectionnés       |
|----------------------------------------------------------------|                                              |
|  Valeur de retour :                                            |
|  - Integer : mrOk si synchronisation effectuée sinon mrCancel  |
==================================================================
}
function TFrmSync.SynchroFiles: integer;
var
  bCopy     : boolean;  // Si TRUE, alors copie des fichiers
  bCopied   : boolean;  // Si TRUE, le fichier a été copié, sinon FALSE
  i         : integer;  // Pour itération
  nCount    : integer;  // Nombre de fichiers à copier
  sFileFrom : string;   // Fichier d'origine
  sFileTo   : string;   // Fichier de destination
  sPathFrom : string;   // Chemin d'origine du fichier
  sPathTo   : string;   // Chemin de destination du fichier
  sFields   : array[0..8] of string;  // Contenu des colonnes
  pChar     : array[0..255] of char;  // pour conversion pour MessageBox


      {------------------------------------------------------
      |  Gestion de l'affichage de la barre de progression  |
      ------------------------------------------------------}
      procedure SetProgress;
      begin
        inc (nCount);
        ProgressBarCopy.Position := nCount;
        ProgressBarCopy.Repaint;
      end;

      {--------------------------------------------
      |  Affichage des chemins et nom du fichier  |
      --------------------------------------------}
      procedure DispInfos (const sSrc, sDest, sFile: string);
      begin
        EditSource.Text := sSrc;
        EditTarget.Text := sDest;
        EditFileName.Text := sFile;
      end;

      {---------------------------------------------
      |  Copie du fichier source vers destination  |
      ---------------------------------------------}
      procedure CopySrcToDest;
      begin
        if sFields[nCOL_SOURCENAME] <> '' then begin
          if ForceDirectories (sPathTo) = TRUE then begin
            // Copie de la source vers la cible
            sFileFrom := sPathFrom + sFields[nCOL_SOURCENAME];
            sFileTo := sPathTo + sFields[nCOL_SOURCENAME];
            DispInfos(sPathFrom, sPathTo, sFields[nCOL_SOURCENAME]);
            bCopied := Files.CopyFile (sFileFrom, sFileTo, ProgressBarFile);
          end;
          SetProgress;
          Application.ProcessMessages;
        end;
      end;

      {---------------------------------------------
      |  Copie du fichier destination vers source  |
      ---------------------------------------------}
      procedure CopyDestToSrc;
      begin
        if sFields[nCOL_TARGETNAME] <> '' then begin
          if ForceDirectories (sPathFrom) = TRUE then begin
            // Copie de la cible vers la source
            sFileFrom := sPathTo + sFields[nCOL_TARGETNAME];
            sFileTo := sPathFrom + sFields[nCOL_TARGETNAME];
            DispInfos(sPathTo, sPathFrom, sFields[nCOL_TARGETNAME]);
            bCopied := Files.CopyFile(sFileFrom, sFileTo, ProgressBarFile);
          end;
          SetProgress;
          Application.ProcessMessages;
        end;
      end;


begin
  // Teste si utile de boucler dans la liste
  bCopy := FALSE;
  nCount := 0;
  if CheckBoxSyncFromSource.Checked and (nCountSource > 0) then begin
    nCount := nCountSource;
    bCopy := TRUE;
  end;
  if CheckBoxSyncFromTarget.Checked and (nCountTarget > 0) then begin
    nCount := nCount + nCountTarget;
    bCopy := TRUE;
  end;
  // Ajuste la barre de progression
  ProgressBarCopy.Max := nCount;
  ProgressBarCopy.Position := 0;
  // Gestion de la copie des fichiers
  if bCopy then begin
    with FrmMain do begin
      // Boucle dans la liste
      nCount := 0;
      for i := 0 to CheckListBox.Count - 1 do begin
        // Contrôle si abandon de la synchronisation
        if not bLoopSync then begin
          Result := nCount;
          exit;     // Quitte la synhronisation des fichiers
        end;
        // Contrôle si case cochée pour synchronisation
        if CheckListBox.Checked[i] then begin
          // Récupération du contenu de la ligne
          ListUtils.ColContent (CheckListBox.Items[i], sFields);
          // Recherche des chemins source et destination
          sPathFrom := ListUtils.SearchPathOfFile (i, nSOURCE);
          sPathto := ListUtils.SearchPathOfFile (i, nTARGET);
          // Gestion de la copie des fichiers
          bCopied := FALSE;
          // Gestion de la synchronisation
          if CheckBoxSyncFromSource.Checked then begin
            if sFields[nCOL_SYNC] = '>' then
              CopySrcToDest
            else if sFields[nCOL_SYNC] = '<' then
              CopyDestToSrc;
          end;
          // Gestion de la bonne exécution ou non de la copie
          if not bCopied then begin
            // Mémorise l'erreur
            with AppliData do begin
              sErrorFiles.Add(sFileFrom + ';' + sFileTo);
              MessageBox(0, StrPcopy(pChar, sFileFrom), StrPcopy(pChar, sFileTo), MB_OK);
            end;
          end;
        end;
      end;
    end;
  end;
  Result := nCount;
end;

{
==================================================
|  Réponse au click des Checkbox source / cible  |
==================================================
}
procedure TFrmSync.CheckBoxSyncFromClick(Sender: TObject);
begin
  CtrlButtonOk;
end;

{
========================================================
|  Abandon de la suppression des fichiers              |
|------------------------------------------------------|                                              |
|  Quitte le dialogue après avoir abandonner la        |
|  suppression des fichiers                            |
========================================================
}
procedure TFrmSync.ButtonOkClick(Sender: TObject);
var
  nResult : integer;
begin
  if CtrlSpaceOfDisks then begin
    with AppliData do begin
      bSyncSource := CheckBoxSyncFromSource.Checked;
      bSyncTarget := CheckBoxSyncFromTarget.Checked;
      CtrlPanelsAndButtons (2);
      bLoopSync := TRUE;
      nModalResult := mrOk;
      SynchroFiles;
      // Si pas d'interruption par l'utilisateur, on quitte le dialogue
      if bLoopSync = TRUE then
        ModalResult := mrOk
      else
        CtrlPanelsAndButtons (3);   // Sinon on ajuste l'affichage
    end;
  end;
end;

{
================================================
|  Abandon de la synchronisation des fichiers  |
================================================
}
procedure TFrmSync.ButtonStopClick(Sender: TObject);
begin
  bLoopSync := FALSE;
  ButtonStop.Enabled := FALSE;
end;

{
========================================================
|  Abandon de la boîte des dialogue de synhronisation  |
|------------------------------------------------------|                                              |
|  Quitte le dialogue sans lancer la suppression       |
========================================================
}
procedure TFrmSync.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := nModalResult;
end;


end.
