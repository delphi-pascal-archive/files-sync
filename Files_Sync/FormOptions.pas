{
==============================================================================
|
|  Unit         : FormOptions.pas
|
|  Description  : Gestion de la boîte de dialogue des options du programme
|
==============================================================================
}
unit FormOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  Declare, Language, Language_Lib, Spin;

type
  TFrmOptions = class(TForm)
    PageControlOptions: TPageControl;
    // Affichage
    TabSheetDisplay: TTabSheet;
    GroupBoxColor: TGroupBox;
    LabelColorPair: TLabel;
    LabelColorImpair: TLabel;
    PanelColorPair: TPanel;
    PanelColorImpair: TPanel;
    ButtonColorDef: TButton;
    //
    // Comparaison
    TabSheetCompare: TTabSheet;
    GroupBoxCmp_NTFS_FAT: TGroupBox;
    CheckBoxCmp_Ignore_2s: TCheckBox;
    //
    GroupBoxTimezone: TGroupBox;
    LabelTimezone: TLabel;
    SpinEditTimeZone: TSpinEdit;
    LabelHours: TLabel;
    //
    // Historique
    TabSheetHistory: TTabSheet;
    LabelHistory: TLabel;
    ComboBoxHistory: TComboBox;
    ListBoxHistory: TListBox;
    ButtonDelete: TButton;
    ButtonDeleteAll: TButton;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    //
    ColorDialog: TColorDialog;
    CheckBoxColWidth: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure InitTexts;
    procedure InitOptions;
    procedure ColorClick(Sender: TObject);
    procedure OnHistoryActions(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Déclarations privées }
    StrList : TStringList;     // Contient la StringList sélectionnée
  public
    { Déclarations publiques }
  end;

var
  FrmOptions: TFrmOptions;

implementation

uses
  FormMain, UserControl;

  {$R *.dfm}

{
========================================================
|  Gestion de la création de la fenêtre                |
|------------------------------------------------------|                                              |
|  Initilisation des éléments de gestion des options   |
========================================================
}
procedure TFrmOptions.FormCreate(Sender: TObject);
begin
  PageControlOptions.ActivePageIndex := 0;
  InitTexts;
  InitOptions;
  OnHistoryActions (ComboBoxHistory);
  ButtonDelete.Enabled := FALSE;
end;

{
==================================================================
|  Initialisation des textes en fonction de la langue            |
|----------------------------------------------------------------|                                              |
|  - Affectation des textes aux composants                       |
==================================================================
}
procedure TFrmOptions.InitTexts;
begin
  // Textes de la fenêtre principale
  Caption := lang.sTitle_FormOptions;
  ButtonOk.Caption := LangLib.sBut_Accept;
  ButtonCancel.Caption := LangLib.sBut_Cancel;
  //
  // Textes pour les options d'affichage
  TabSheetDisplay.Caption :=Lang.sDisp_Tab;
  GroupBoxColor.Caption := Lang.sDisp_GrpColors;
  LabelColorPair.Caption :=Lang.sDisp_ColorPair;
  LabelColorImpair.Caption :=Lang.sDisp_ColorImpair;
  PanelColorPair.Caption := Lang.sDisp_ClicMe;
  PanelColorImpair.Caption := Lang.sDisp_ClicMe;
  ButtonColorDef.Caption := Lang.sDisp_ColorDef;
  CheckBoxColWidth.Caption := Lang.sDisp_ColWidth;
  //
  // Textes pour la comparaison
  TabSheetCompare.Caption :=Lang.sCmp_Tab;
  GroupBoxCmp_NTFS_FAT.Caption :=Lang.sCmp_NTFS_FAT_Grp;
  CheckBoxCmp_Ignore_2s.Caption := Lang.sCmp_Ignore_2s;
  //
  GroupBoxTimezone.Caption := Lang.sCmp_Timezone;
  LabelTimezone.Caption := Lang.sCmp_ShiftTimeZone;
  LabelHours.Caption := Lang.sCmp_Hours;
  //
  // Textes pour l'historique
  TabSheetHistory.Caption := Lang.sHistory_Tab;
  LabelHistory.Caption := Lang.sHistory_Choice;
  ButtonDelete.Caption := Lang.sHistory_Delete;
  ButtonDeleteAll.Caption := Lang.sHistory_DeleteAll;
  ComboBoxHistory.Items.Add(Lang.sLabel_SourcePath);
  ComboBoxHistory.Items.Add(Lang.sLabel_TargetPath);
  ComboBoxHistory.Items.Add(Lang.sLabel_FileTypes);
  ComboBoxHistory.ItemIndex := 0;
end;

{
==============================================================
|  Initialisation des options                                |
|------------------------------------------------------------|                                              |
|  - Met à jour les éléments de la boîte de dialoggue        |
==============================================================
}
procedure TFrmOptions.InitOptions;
begin
  with AppliData do begin
    PanelColorPair.Color := ColorPair;
    PanelColorImpair.Color := ColorImpair;
    CheckBoxColWidth.Checked := bColon_Auto;
    CheckBoxCmp_Ignore_2s.Checked := bIgnore2s;
    SpinEditTimeZone.Value:= nShiftTimeZone;
  end;
end;

{
================================================================
|  Sélection de la couleur pour les lignes paires et impaires  |
================================================================
}
procedure TFrmOptions.ColorClick(Sender: TObject);
begin
  if (CompareText (TLabel(Sender).Name, 'LabelColorPair') = 0)
  or (CompareText (TLabel(Sender).Name, 'PanelColorPair') = 0) then begin
    if ColorDialog.Execute then
      PanelColorPair.color := ColorDialog.Color;
  end
  else if (CompareText (TLabel(Sender).Name, 'LabelColorPair') = 0)
  or (CompareText (TLabel(Sender).Name, 'PanelColorImpair') = 0) then begin
    if ColorDialog.Execute then
      PanelColorImpair.color := ColorDialog.Color;
    end
  else if (CompareText (TLabel(Sender).Name, 'ButtonColorDef') = 0) then begin
    PanelColorPair.color := clWhite;
  PanelColorImpair.color := clMoneyGreen;
  end;
end;

{
==============================================================
|  Gestion des actions dans l'onglet de l'historique         |
|------------------------------------------------------------|                                              |
|  - Sélection dans le ComboBox                              |
|  - Utilisation du bouton "Effacer"                         |
|  - Utilisation du bouton "Effacer tout"                    |
==============================================================
}
procedure TFrmOptions.OnHistoryActions(Sender: TObject);
var
  i       : integer;
begin
  ButtonDelete.Enabled := FALSE;
  // Récupère la liste de l'historique sélectionnée dans le ComboBox
  case TComboBox(Sender).ItemIndex of
    0 : StrList := AppliData.sSourcePathList;
    1 : StrList := AppliData.sTargetPathList;
    2 : StrList := AppliData.sFileFilterList;
  end;
  //
  if StrList <> nil then begin
    // Initialise le contenu du ListBox en fonction de la sélection du ComboBox
    if (CompareText (TComboBox(Sender).Name, 'ComboBoxHistory') = 0) then begin
      // Rempli la ListBox de l'historique choisie
      ListBoxHistory.Clear;
      for i := 0 to StrList.Count - 1 do
        ListBoxHistory.Items.Add(StrList.Strings[i]);
    end
    //
    // Gestion de la sélection de la listbox
    else if (CompareText (TListBox(Sender).Name, 'ListBoxHistory') = 0) then begin
      if ListBoxHistory.SelCount = 0 then
        ButtonDelete.Enabled := FALSE
      else
        ButtonDelete.Enabled := TRUE;
    end
    //
    // Gestion du bouton "Effacer"
    else if (CompareText (TButton(Sender).Name, 'ButtonDelete') = 0) then begin
      ListBoxHistory.DeleteSelected;    // Supprime la sélection de la ListBox
      // Réinitialise la liste de strings
      StrList.Clear;
      for i := 0 to ListBoxHistory.Count - 1 do
        StrList.Add(ListBoxHistory.Items[i]);
    end
    //
    // Gestion du bouton "Effacer tout"
    else if (CompareText (TButton(Sender).Name, 'ButtonDeleteAll') = 0) then begin
      StrList.Clear;
      ListBoxHistory.Clear;
    end;
  end;
end;

{
========================================================
|  Abandon de la gestion des options                   |
|------------------------------------------------------|                                              |
|  Quitte le dialogue après avoir mémorisé les         |
|  changements des options                             |
========================================================
}
procedure TFrmOptions.ButtonOkClick(Sender: TObject);
var
  i   : integer;
begin
  with FrmMain, AppliData do begin
    // --- Tab pour l'affichage
    ColorPair := PanelColorPair.Color;
    ColorImpair := PanelColorImpair.Color;
    bColon_Auto := CheckBoxColWidth.Checked;
    nShiftTimeZone := SpinEditTimeZone.Value;
    // --- Tab pour la comparaison
    bIgnore2s := CheckBoxCmp_Ignore_2s.Checked;
    //
    // --- Tab pour l'historique
    // Répertoires des sources
    with ComboBoxSourcePath do begin
      Clear;
      for i := 0 to sSourcePathList.Count -1 do
        Items.Add(sSourcePathList.Strings[i]);
      ItemIndex := Items.IndexOf (AppliData.sSourcePath);
    end;
    // Répertoires des destinations
    with ComboBoxTargetPath do begin
      Clear;
      for i := 0 to sTargetPathList.Count -1 do
        Items.Add(sTargetPathList.Strings[i]);
      ItemIndex := Items.IndexOf (AppliData.sTargetPath);
    end;
    // Liste des filtres
    with ComboBoxFileTypes do begin
      Clear;
      for i := 0 to sFileFilterList.Count -1 do
        Items.Add(sFileFilterList.Strings[i]);
      ItemIndex := Items.IndexOf (AppliData.sFileFilter);;
    end;
  end;
  // Force l'ajustement des colonnes si nécessaire
  if CheckBoxColWidth.Checked then 
     UserCtrl.AdjustOnResize (FrmMain);
  Close;
end;

{
========================================================
|  Abandon de la gestion des options                   |
|------------------------------------------------------|                                              |
|  Quitte le programme sans mémoriser les changements  |
========================================================
}
procedure TFrmOptions.ButtonCancelClick(Sender: TObject);
begin
  Close;  // Abandon des changements
end;

end.
