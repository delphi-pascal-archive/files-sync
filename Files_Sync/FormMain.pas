{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : FormMain.pas
|
|  Description  : Gestion de la fenêtre principale de l'application
|                                                                            
==============================================================================
}
unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, ExtCtrls, Menus, Buttons,
  CheckLst, ImgList, XPMan,
  Declare, Language, Colors, IniFile, UserControl, FilesUtils,
  ScanFiles, StringUtils, Utils, Language_Lib, FormAbout;

        
type
  TFrmMain = class(TForm)
    // --- Composition du menu principa
    MainMenu: TMainMenu;
    // Fichier
    MenuFile: TMenuItem;
    MenuItemOpenSource: TMenuItem;
    MenuItemOpenTarget: TMenuItem;
    Sep11: TMenuItem;
    MenuItemDelete: TMenuItem;
    Sep12: TMenuItem;
    MenuItemQuit: TMenuItem;
    // Menu outils
    MenuTools: TMenuItem;
    MenuItemScanStart: TMenuItem;
    MenuItemScanStop: TMenuItem;
    MenuitemSynchro: TMenuItem;
    Sep21: TMenuItem;
    MenuItemDispAll: TMenuItem;
    MenuItemDispSynchro: TMenuItem;
    MenuItemDispToTarget: TMenuItem;
    MenuItemDispToSource: TMenuItem;
    MenuItemDispIdentical: TMenuItem;
    MenuItemOptions: TMenuItem;
    // Menu affichage
    MenuView: TMenuItem;
    MenuItemCommandBar: TMenuItem;
    MenuItemSelectBar: TMenuItem;
    MenuItemStatusBar: TMenuItem;
    // Menu d'aide
    MenuHelp: TMenuItem;
    MenuItemHelpTo: TMenuItem;
    MenuItemAbout: TMenuItem;
    //
    // --- Composition du popup menu
    PopupMenuList: TPopupMenu;
    PopupItemOpenSource: TMenuItem;
    PopupItemOpenTarget: TMenuItem;
    PopSep1: TMenuItem;
    PopupItemDelete: TMenuItem;
    PopSep2: TMenuItem;
    //
    // Barre d'outils
    ToolsBar: TPanel;
    SpeedButtonScanStart: TSpeedButton;
    SpeedButtonScanStop: TSpeedButton;
    SpeedButtonSynchro: TSpeedButton;
    SpeedButtonDispSynchro: TSpeedButton;
    SpeedButtonDispAll: TSpeedButton;
    SpeedButtonDispToTarget: TSpeedButton;
    SpeedButtonDispToSource: TSpeedButton;
    SpeedButtonDispIdentical: TSpeedButton;
    SpeedButtonDelCleanDir: TSpeedButton;
    SpeedButtonOptions: TSpeedButton;
    SpeedButtonQuit: TSpeedButton;
    //
    // Barre de sélection
    SelectBar: TPanel;
    // Définition de la source
    LabelSourcePath: TLabel;
    ComboBoxSourcePath: TComboBox;
    SpeedButtonSourcePath: TSpeedButton;
    EditSourcePath: TEdit;
    LabelFileTypes: TLabel;
    ComboBoxFileTypes: TComboBox;
    CheckBoxSubFolder: TCheckBox;
    // Définition de la destination
    LabelTargetPath: TLabel;
    ComboBoxTargetPath: TComboBox;
    SpeedButtonTargetPath: TSpeedButton;
    EditTargetPath: TEdit;
    //  Liste de comparaison
    HeaderControl: THeaderControl;
    CheckListBox: TCheckListBox;
    StatusBar: TStatusBar;
    // Divers
    XPManifest1: TXPManifest;
    ImageList32: TImageList;
    ImageList16: TImageList;
    Sep23: TMenuItem;
    Sep22: TMenuItem;
    MenuItemDelCleanDir: TMenuItem;
    //
    // Méthodes
    procedure FormCreate(Sender: TObject);
    procedure InitTexts;
    procedure InitOptions;
    // Gestion des actions de l'utilisateur
    procedure OnUserFileActions(Sender: TObject);
    procedure OnUserSelectActions(Sender: TObject);
    procedure OnUserToolsActions(Sender: TObject);
    procedure OnUserViewActions(Sender: TObject);
    procedure OnUserHelpActions(Sender: TObject);
    procedure HeaderControlSectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    // Gestion de la liste de comparaison
    function  ItemContent (const nIndex: integer; const sFields: array of string): string;
    procedure CheckListBoxDrawItem(Control: TWinControl; Index: Integer;
                                   Rect: TRect; State: TOwnerDrawState);
    procedure CheckListBoxData(Control: TWinControl; Index: Integer;
      var Data: string);
    procedure CheckListBoxClickCheck(Sender: TObject);
    procedure CheckListBoxClick(Sender: TObject);
    procedure CheckListBoxDblClick(Sender: TObject);
    procedure CheckListBoxMouseUp(Sender: TObject; Button: TMouseButton;
                                  Shift: TShiftState; X, Y: Integer);
    // Gestion de la fenêtre
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    icoImg : TIcon;    // Pour image [=>] dans la liste de comparaison
  public
    { Déclarations publiques }
    ScanThread  : TScanThread;
  end;

var
  FrmMain: TFrmMain;

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
procedure TFrmMain.FormCreate(Sender: TObject);
begin
//  SelectBar.DoubleBuffered := TRUE;
//  HeaderControl.DoubleBuffered := TRUE;
  CheckListBox.DoubleBuffered := TRUE;
  CheckListBox.MultiSelect := TRUE;
  // Création des classes
  AppliData := TAppliData.Create;
  IniFileData := TIniFileData.Create;
  Lang := TLanguage.Create;
  LangLib := TLanguageLib.Create;
  ColorsList := TColorsList.Create;
  Str := TStr.Create;
  Files := TFiles.Create;
  icoImg := TIcon.Create;
  icoImg.Transparent := TRUE;
  //
  ColorsList.InitColors;  // Initialise la classe des couleurs
  //
  AppliData.Init;         // Initialisation des données du programme
  ColorsList.InitColors;  // Initialisations des couleurs
  InitTexts;              // Initialisation des textes en fonction du langage
  InitOptions;            // Initialisation des options du fichier .ini
  OnUserViewActions (Self);
  //
  SpeedButtonScanStop.Enabled := FALSE;
  SpeedButtonSynchro.Enabled := FALSE;
  UserCtrl.CreateAboutBox (nDISPMODE_SPLASH, 2000);  // Splash
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
procedure TFrmMain.InitTexts;
begin
  // Lecture des textes en fonction de la langue
  if sLanguage = '' then
    sLanguage := sFRENCH;
  Lang.ReadLanguage (sLanguage);
  LangLib.ReadLanguage (sLanguage);
  //
  // Titre de l'application et Caption
  Application.Title := Lang.sTitle_Application;
  Caption := Lang.sTitle_MainApplic;
  //
  // Menus File
  MenuFile.Caption := LangLib.sMenu_File;
  MenuItemOpenSource.Caption := Lang.sMenu_OpenSource;
  MenuItemOpenTarget.Caption := Lang.sMenu_Opentarget;
  MenuItemDelete.Caption := Lang.sMenu_DeleteFiles;
  MenuItemQuit.Caption := LangLib.sMenu_Quit;
  // Menus Tools
  MenuTools.Caption := Lang.sMenu_Tools;
  MenuItemScanStart.Caption := Lang.sMenu_ScanStart;
  MenuItemScanStop.Caption := Lang.sMenu_ScanStop;
  MenuItemDispAll.Caption := Lang.sMenu_DispAll;
  MenuItemDispSynchro.Caption := Lang.sMenu_DispSynchro;
  MenuItemDispToTarget.Caption := Lang.sMenu_DispToTarget;
  MenuItemDispToSource.Caption := Lang.sMenu_DispToSource;
  MenuItemDispIdentical.Caption := Lang.sMenu_DispIdentical;
  MenuItemDelCleanDir.Caption := Lang.sMenu_DelCleanDir;
  // Menus View
  MenuView.Caption := Lang.sMenu_View;
  MenuItemCommandBar.Caption := Lang.sMenu_CommandBar;
  MenuItemSelectBar.Caption := Lang.sMenu_SelectBar;
  MenuItemStatusBar.Caption := Lang.sMenu_StatusBar;
  //-----
  MenuItemSynchro.Caption := Lang.sMenu_Synchro;
  MenuItemOptions.Caption := LangLib.sMenu_Options;
  // Menus de l'aide
  MenuHelp.Caption := LangLib.sMenu_Help;
  MenuItemHelpTo.Caption := LangLib.sMenu_HelpTo + '  ' + Lang.sMenu_TextApplic;
  MenuItemAbout.Caption := LangLib.sMenu_About + '  ' + Lang.sMenu_TextApplic;
  //
  // Textes pour popup menu de la liste
  PopupMenuList.Items[0].Caption := Lang.sMenu_OpenSource;
  PopupMenuList.Items[1].Caption := Lang.sMenu_Opentarget;
  PopupMenuList.Items[3].Caption := Lang.sMenu_DeleteFiles;
  //
  // Textes pour les hints
  SpeedButtonScanStart.Hint := Lang.sHint_ScanStart;
  SpeedButtonScanStop.Hint := Lang.sHint_ScanStop;
  SpeedButtonSynchro.Hint := Lang.sHint_Synchro;
  SpeedButtonDispAll.Hint := Lang.sHint_DispAll;
  SpeedButtonDispSynchro.Hint := Lang.sHint_DispSynchro;
  SpeedButtonDispToTarget.Hint := Lang.sHint_DispToTarget;
  SpeedButtonDispToSource.Hint := Lang.sHint_DispToSource;
  SpeedButtonOptions.Hint := LangLib.sHint_Options;
  SpeedButtonDispIdentical.Hint := Lang.sHint_DispIdentical;
  SpeedButtonDelCleanDir.Hint := Lang.sMenu_DelCleanDir;
  SpeedButtonQuit.Hint := LangLib.sHint_Quit;
  SpeedButtonSourcePath.Hint := Lang.sHint_Directory;
  SpeedButtonTargetPath.Hint := Lang.sHint_Directory;
  //
  // Panneau de sélection
  LabelSourcePath.Caption := Lang.sLabel_SourcePath;
  LabelFileTypes.Caption := Lang.sLabel_FileTypes;
  LabelTargetPath.Caption := Lang.sLabel_TargetPath;
  CheckBoxSubFolder.Caption := Lang.sCheck_SubFolder;
  //
  // HeaderControl du CheckListBox
  HeaderControl.Sections.Items[0].Text := ' ';
  HeaderControl.Sections.Items[1].Text := ' ' + Lang.sCLB_ColName;
  HeaderControl.Sections.Items[2].Text := ' ' + Lang.sCLB_ColSize;
  HeaderControl.Sections.Items[3].Text := ' ' + Lang.sCLB_ColModified;
  HeaderControl.Sections.Items[4].Text := '  =';
  HeaderControl.Sections.Items[5].Text := ' ' + Lang.sCLB_ColModified;
  HeaderControl.Sections.Items[6].Text := ' ' + Lang.sCLB_ColSize;
  HeaderControl.Sections.Items[7].Text := ' ' + Lang.sCLB_ColName
end;
{
=============================================================
|  Lecture des options du fichier .ini                      |
|-----------------------------------------------------------|                                              |
|  - Lecture de toutes les options                          |
|  - Affectation des valeurs lues aux composants concernés  |
=============================================================
}
procedure TFrmMain.InitOptions;
begin
  IniFileData.ReadIniFile;
  ComboBoxSourcePath.ItemIndex := ComboBoxSourcePath.Items.IndexOf (AppliData.sSourcePath);
  ComboBoxTargetPath.ItemIndex := ComboBoxTargetPath.Items.IndexOf (AppliData.sTargetPath);
  ComboBoxFileTypes.ItemIndex := ComboBoxFileTypes.Items.IndexOf (AppliData.sFileFilter);
  CheckBoxSubFolder.Checked := Applidata.bSubFolder;
  // Si 1ère utilisation, ajout du filtre par défaut
  if ComboBoxFileTypes.Items.Count = 0 then begin
    AppliData.sFileFilter := '*.*';
    ComboBoxFileTypes.Items.Add(Applidata.sFileFilter);
    ComboBoxFileTypes.ItemIndex := 0;
  end;
end;

{
==============================================================================
==================  Gestion des actions de l'utilisateur  ====================
==============================================================================
}
{
===============================================================
|  Gestion des actions du menu fichier                        |
===============================================================
}
procedure TFrmMain.OnUserFileActions(Sender: TObject);
begin
  UserCtrl.UserFileActions (Sender);
end;

{
===============================================================
|  Gestion des actions des éléments du panneau de sélection   |
===============================================================
}
procedure TFrmMain.OnUserSelectActions(Sender: TObject);
begin
  UserCtrl.UserSelectActions (Sender);
end;

{
===============================================================
|  Gestion des actions des options et autres choix possibles  |
===============================================================
}
procedure TFrmMain.OnUserToolsActions(Sender: TObject);
begin
  UserCtrl.UserToolActions (Sender);
end;

{
===============================================================
|  Gestion des actions des options du menu d'affichage        |
|-------------------------------------------------------------|                                              |
|  Récupère les actions de l'utilisateur sur les différentes  |
|  du menu de contrôle de l'affichage                         |
===============================================================
}
procedure TFrmMain.OnUserViewActions(Sender: TObject);
begin
  ToolsBar.Visible := MenuItemCommandBar.Checked;
  SelectBar.Visible := MenuItemSelectBar.Checked;
  StatusBar.Visible := MenuItemStatusBar.Checked;
end;

{
===============================================================
|  Gestion des actions pour l'aide et de "A propos..."        |
===============================================================
}
procedure TFrmMain.OnUserHelpActions(Sender: TObject);
begin
  UserCtrl.UserHelpActions (Sender);
end;

{
==============================================================================
==================  Gestion de la liste de comparaison  =====================
==============================================================================
}
{
=================================================
|  Rafraichissement de la liste au changement   |
|  des dimensions du HeaderControl de la liste  |
=================================================
}
procedure TFrmMain.HeaderControlSectionResize(HeaderControl: THeaderControl;
  Section: THeaderSection);
begin
  CheckListBox.Refresh;
end;

{
===============================================================
|  Extraction du contenu d'un item dans un array de strings   |
|-------------------------------------------------------------|                                              |
|  Paramètres :                                               |
|  - nIndex   : position de l'item dans la liste              |
|  - sFields  : récupère le contenu de chaque colonne         |
===============================================================
}
function TFrmMain.ItemContent (const nIndex: integer; const sFields: array of string): string;
var
  i     : integer;  // Pour itération
begin
  Result := '';
  for i := 0 to Length (sFields) - 1 do begin
    Result := Result + sFields[i] + ';';
  end;
end;

{
=====================================================
|  Mise en forme de l'affichage de la liste en se   |
|  calquant sur les colonnes de l'en-tête           |
=====================================================
}
procedure TFrmMain.CheckListBoxDrawItem(Control: TWinControl; Index: Integer;
                                        Rect: TRect; State: TOwnerDrawState);
var
  nOffset   : integer;  // Offset pour la position des horizoontale des cellules
  RectCell  : TRect;    // Rectangle pour cellule
  sFields   : array[0..8] of string;  // Contenu des colonnes


        {-------------------------------------------
        ¦  Trace le contour extérieur du checkbox  ¦
        -------------------------------------------}
        procedure DrawCheckBox;
        begin
          with CheckListBox.Canvas do begin
            Pen.Width := 3;
            // Haut
            MoveTo (HeaderControl.Sections[0].Left, Rect.Top + 1);
            LineTo (HeaderControl.Sections[0].Left + HeaderControl.Sections[0].Width, Rect.Top + 1);
            // Bas
            MoveTo (HeaderControl.Sections[0].Left, Rect.Top + 15);
            LineTo (HeaderControl.Sections[0].Left + HeaderControl.Sections[0].Width, Rect.Top + 15);
            // Gauche
            Pen.Width := 2;
            MoveTo (HeaderControl.Sections[0].Left + 1, Rect.Top + 3);
            LineTo (HeaderControl.Sections[0].Left + 1, Rect.Bottom - 3);
            // Droite
            MoveTo (HeaderControl.Sections[0].Left + 14, Rect.Top + 3);
            LineTo (HeaderControl.Sections[0].Left + 14, Rect.Bottom - 3);
            Pen.Width := 1;
          end;
        end;

        {-----------------------------------------------------------
        ¦  Gestion de l'affichage des lignes pour les répertoires  ¦
        -----------------------------------------------------------}
        procedure DrawDirLine;
        const
          nMARGE  = 5;
        var
          i       : integer;  // Pour itération
          nWidth  : integer;  // Largeur de la cellule pour le texte
        begin
          with CheckListBox.Canvas, AppliData do begin
            ImageList16.GetIcon(9, icoImg);
            // Couleur du fond de la ligne
            Pen.Color := clBtnFace;
            Brush.Color := clBtnFace;
            // FilleRect (Rect) est plus rapaide que Rectangle (Rect)
            RectCell := Rect;
            RectCell.Left:= RectCell.Left - 15;
            FillRect (RectCell);
            // Bordures des lignes
            Pen.Color := clGray;
            MoveTo (Rect.Left - 15, Rect.Bottom - 1); // Left - 15 : pour zone de la case à cocher
            LineTo (Rect.Right, Rect.Bottom - 1);
            Pen.Color := clWhite;
            MoveTo (Rect.Left - 15, Rect.Top + 1); // Left - 15 : pour zone de la case à cocher
            LineTo (Rect.Right, Rect.Top + 1);
            // Répertoire source
            nWidth := 0;
            draw(Rect.Left - 15, rect.Top, icoImg);
            for i := 1 to 3 do
              nWidth := nWidth + HeaderControl.Sections[i].Width;
            RectCell := Classes.Rect(HeaderControl.Sections[1].Left + nMARGE,
                                     Rect.Top + 2,
                                     HeaderControl.Sections[1].Left + nWidth,
                                     Rect.Bottom - 1);
            TextRect(RectCell, RectCell.Left, RectCell.Top, sFields[nCOL_SOURCENAME]);  // RecFile.sSourceName
            // Répertoire cible
            RectCell := Classes.Rect(HeaderControl.Sections[5].Left + nMARGE,
                                     Rect.Top + 2,
                                     Rect.Right,
                                     Rect.Bottom - 1);
            TextRect(RectCell, RectCell.Left, RectCell.Top, sFields[nCOL_TARGETNAME]);  // RecFile.sSourceName
          end;
        end;

        {--------------------------------------------------------
        ¦  Gestion de l'affichage des lignes pour les fichiers  ¦
        --------------------------------------------------------}
        procedure DrawFileLine;
        const
          nMARGE  = 24;
        var
          i       : integer;  // Pour itération
          nTxtLen : integer;  // Longueur utilisé par le texte
          nTxtShf : integer;  // décalage pour aligner le texte à droite
          sText   : string;   // Texte pour contenu d'une colonne
        begin
          with CheckListBox.Canvas, AppliData do begin
            // Couleur alternée du fond de la ligne
            if CheckListBox.Selected[Index] = TRUE then begin
              Pen.Color := clActiveCaption;
              Brush.Color := clActiveCaption;
            end
            else begin
              if odd (Index) then begin
                Pen.Color := ColorPair;
                Brush.Color := ColorPair
              end
              else begin
                Pen.Color := ColorImpair;
                Brush.Color := ColorImpair;
              end;
            end;
            RectCell := Rect;
            if sFields[nCOL_SYNC] = '=' then
              RectCell.Left:= RectCell.Left - 15;  // Left - 15 : pour zone de la case à cocher
            FillRect (RectCell);  // FilleRect (Rect) est plus rapide que Rectangle (Rect)
            //
            // Couleur du texte et image pour le type de synchronisation
            if sFields[nCOL_SYNC] = '=' then begin
              Font.Color := clBlack;
              ImageList16.GetIcon(5, icoImg);
            end else if sFields[nCOL_SYNC] = '>' then begin
              Font.Color := clBlue;
              ImageList16.GetIcon(6, icoImg);
              DrawCheckBox;
            end else if sFields[nCOL_SYNC] = '<' then begin
              Font.Color := clRed;
              ImageList16.GetIcon(7, icoImg);
              DrawCheckBox;
            end;
            // On parcours les champs en oubliant les champs 1 et 8 (checkbox et type)
            nOffset := 0;
            for i := 1 to length (sFields) - 2 do begin
              nOffset := nOffset + HeaderControl.Sections[i-1].Width;
              sText := sFields[i];
              if (i = nCOL_SOURCESIZE) or (i = nCOL_TARGETSIZE) then begin
                // Mise au format de la taille des fichiers.
                if sText <> '' then
                  sText := Str.FileSizeAutoStr (sFields[i]);
              end;
              // Longueur en pixels du texte à afficher
              nTxtLen := TextWidth (sText) + nMARGE;
              // Gestion des colonnes des tailles des fichiers
              if (i = nCOL_SOURCESIZE) or (i = nCOL_TARGETSIZE) then
                nTxtShf := HeaderControl.Sections[i].Width - nTxtLen + 9
              else
                nTxtShf := 0;
              //
              RectCell := Classes.Rect(Rect.Left + nOffset - 9,
                                       Rect.Top,
                                       Rect.Left + nOffset + HeaderControl.Sections[i].Width - 20,
                                       Rect.Bottom);
              if i = nCOL_SYNC then // Colonne synchronistion
                draw(RectCell.Left, rect.Top, icoImg)
              else // Autres colonnes
                TextRect(RectCell, RectCell.Left + nTxtShf, RectCell.Top, sText);
            end;

          end;
        end;

begin
  ListUtils.ColContent (CheckListBox.Items[Index], sFields);       // Séparation du contenu des colonnes
  // Contrôle de l'affichage des colonnes
  if sFields[nCOL_TYPE] = sTYPE_DIR then
    DrawDirLine     // Lignes pour les répertoires
  else begin
    DrawFileLine;   // Lignes pour les fichiers
  end;
end;

{
===============================================================
|  Réaction à l'événement OnData pour rafraîchir l'affichage  |
===============================================================
}
procedure TFrmMain.CheckListBoxData(Control: TWinControl; Index: Integer;
  var Data: string);
begin
  CheckListBox.Repaint;
end;

{
========================================================
|  Réaction au clic sur une case à cocher de la liste  |
========================================================
}
procedure TFrmMain.CheckListBoxClickCheck(Sender: TObject);
var
  nIndex  : integer;  // Index de la ligne dans la liste
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  CheckListBox.Visible := FALSE;

  nIndex := CheckListBox.ItemIndex;
  ListUtils.ColContent (CheckListBox.Items[nIndex], sFields); // Séparation du contenu des colonnes

  if (sFields[nCOL_TYPE] = sTYPE_FILE) and
  ((sFields[nCOL_SYNC] = '>') or (sFields[nCOL_SYNC] = '<')) then begin
    if CheckListBox.State[nIndex] = cbChecked then
      sFields[nCOL_CHECKED] := '0'
    else
      sFields[nCOL_CHECKED] := '1';
    CheckListBox.Items[nIndex] := ItemContent (nIndex, sFields);
  end;
  CheckListBox.Visible := TRUE;
end;

{
======================================================
|  Réaction au clic sur une ligne du TCheckListBox   |
======================================================
}
procedure TFrmMain.CheckListBoxClick(Sender: TObject);
begin
  CheckListBox.Invalidate;
end;

{
===========================================================
|  Réaction au double-clic du bouton gauche de la souris  |
===========================================================
}
procedure TFrmMain.CheckListBoxDblClick(Sender: TObject);
begin
  UserCtrl.MouseActionDblClick (Sender);
end;

{
=======================================
|  Réaction aux boutons de la souris  |
=======================================
}
procedure TFrmMain.CheckListBoxMouseUp(Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft    : ;
    mbRight   : UserCtrl.PopupMenu (X, Y);
    mbMiddle  : ;
  end;
end;

{
==============================================================================
================  Gestion de la fenêtre de l'application  ====================
==============================================================================
}
{
==============================================================
|  Gestion du redimensionement de la fenêtre                 |
|------------------------------------------------------------|                                              |
|  Ajuste le contenu de la fenêtre lors du redimensionnment  |
==============================================================
}
procedure TFrmMain.FormResize(Sender: TObject);
begin
  UserCtrl.AdjustOnResize (Sender);
end;

{
=====================================================
|  Gestion de la destruction de la fenêtre          |
|---------------------------------------------------|                                              |
|  Libération des éléments créés par l'application  |
=====================================================
}
procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  // Ecriture des options dans le fichier .ini
  IniFileData.WriteIniFile;
  // Libération des instances
  if AppliData <> nil then AppliData.Free;
  if IniFileData <> nil then IniFileData.Free;
  if Lang <> nil then Lang.Free;
  if LangLib <> nil then LangLib.Free;
  if ColorsList <> nil then ColorsList.Free;
  if Str <> nil then Str.Free;
  if Files <> nil then Files.Free;
  if IcoImg <> nil then icoImg.Free;
end;


end.
