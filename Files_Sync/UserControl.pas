{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : UserControl.pas
|
|  Description  : Gestion des différentes actions de l'utilisateur
|
==============================================================================
}
unit UserControl;

interface

uses
  Windows, Classes, Controls, SysUtils, Forms, StdCtrls, Graphics, Shellapi,
  Menus, Buttons, Types,
  Declare, ScanFiles, Language, Language_Lib, IniFile, Utils,
  FormDeleteFiles, FormSyncFiles, FormOptions, FormAbout,
  FormDelCleanDir, FilesUtils, FormSelectDir;

type
  TUserCtrl = class
    // Méthodes diverses
    procedure ThreadStart;
    procedure SetForCompare (const bActive: boolean);
    // Gestion des actions de l'utilisateur et des options
    procedure AdjustOnResize (Sender: TObject);
    procedure UserFileActions(Sender: TObject);
    procedure UserSelectActions(Sender: TObject);
    procedure UserToolActions(Sender: TObject);
    procedure UserHelpActions(Sender: TObject);
    // Gestion des événements de la liste
    procedure MouseActionDblClick (Sender: TObject);
    procedure PopupMenu (const nPosX, nPosY: integer);
    // Appel des boîtes de dialogue
    procedure CreateAboutBox (const nDispMode, nDelay: integer);
  end;

var
  UserCtrl  : TUserCtrl;

implementation

uses
  FormMain;

{
==============================================================================
==========  Gestion des actions de l'utilisateur et des options  =============
==============================================================================
}

{
================================================================
|  Gestion du démarrage du thread de la recheche des fichiers  |
================================================================
}
procedure TUserCtrl.ThreadStart;
begin

with AppliData do
  Scan := TScanThread.Create(TRUE);   // Création et mode suspendu
  Scan.FreeOnTerminate := TRUE;
  Scan.Resume;                        // Lance l'exécuton
end;

{
========================================================================
|  Gestion des éléments de l'interface pendant pendant la comparaison  |
|----------------------------------------------------------------------|
|  Paramètre :                                                         |
|  - bActive : si TRUE, la comparaison est active                      |
========================================================================
}
procedure TUserCtrl.SetForCompare(const bActive: boolean);
begin
  with FrmMain do begin
    if bActive then begin
      // Barre d'outils
      SpeedButtonScanStart.Enabled := FALSE;
      SpeedButtonScanStop.Enabled := TRUE;
      SpeedButtonSynchro.Enabled := FALSE;
      SpeedButtonDispAll.Enabled := FALSE;
      SpeedButtonDispSynchro.Enabled := FALSE;
      SpeedButtonDispToTarget.Enabled := FALSE;
      SpeedButtonDispToSource.Enabled := FALSE;
      SpeedButtonDispIdentical.Enabled := FALSE;
      SpeedButtonDelCleanDir.Enabled := FALSE;
      SpeedButtonOptions.Enabled := FALSE;
      SpeedButtonQuit.Enabled := FALSE;
      // Barre de sélection
      ComboBoxSourcePath.Enabled := FALSE;
      SpeedButtonSourcePath.Enabled := FALSE;
      ComboBoxFileTypes.Enabled := FALSE;
      CheckBoxSubFolder.Enabled := FALSE;
      ComboBoxTargetPath.Enabled := FALSE;
      SpeedButtonTargetPath.Enabled := FALSE;
      // Menus
      MenuItemQuit.Enabled := FALSE;
      MenuItemScanStart.Enabled := FALSE;
      MenuItemScanStop.Enabled := TRUE;
      MenuItemSynchro.Enabled := FALSE;
      MenuItemDispAll.Enabled := FALSE;
      MenuItemDispSynchro.Enabled := FALSE;
      MenuItemDispToTarget.Enabled := FALSE;
      MenuItemDispToSource.Enabled := FALSE;
      MenuItemDispIdentical.Enabled := FALSE;
      MenuItemOptions.Enabled := FALSE;
      MenuItemQuit.Enabled := FALSE;
    end
    else begin
      // Barre d'outils
      SpeedButtonScanStart.Enabled := TRUE;
      SpeedButtonScanStop.Enabled := FALSE;
      SpeedButtonSynchro.Enabled := TRUE;
      SpeedButtonDispAll.Enabled := TRUE;
      SpeedButtonDispSynchro.Enabled := TRUE;
      SpeedButtonDispToTarget.Enabled := TRUE;
      SpeedButtonDispToSource.Enabled := TRUE;
      SpeedButtonDispIdentical.Enabled := TRUE;
      SpeedButtonDelCleanDir.Enabled := TRUE;
      SpeedButtonOptions.Enabled := TRUE;
      SpeedButtonQuit.Enabled := TRUE;
      // Barre de sélection
      ComboBoxSourcePath.Enabled := TRUE;
      SpeedButtonSourcePath.Enabled := TRUE;
      ComboBoxTargetPath.Enabled := TRUE;
      CheckBoxSubFolder.Enabled := TRUE;
      SpeedButtonTargetPath.Enabled := TRUE;
      ComboBoxFileTypes.Enabled := TRUE;
      // Menus
      MenuItemQuit.Enabled := TRUE;
      MenuItemScanStart.Enabled := TRUE;
      MenuItemScanStop.Enabled := TRUE;
      MenuItemDispSynchro.Enabled := TRUE;
      MenuItemDispAll.Enabled := TRUE;
      MenuItemDispToTarget.Enabled := TRUE;
      MenuItemDispToSource.Enabled := TRUE;
      MenuItemDispIdentical.Enabled := TRUE;
      MenuItemOptions.Enabled := TRUE;
      MenuItemQuit.Enabled := TRUE;
    end;
  end;
end;

{
==============================================================================
=====================  Gestion de l'interface  ===============================
==============================================================================
}
{
==============================================================================
|  Gestion du redimensionement de la fenêtre de la fenêtre                   |
|----------------------------------------------------------------------------|                                              |
|  - Gestion de la position et taille des éléments du panneau de sélection   |
|     - Eléments pour source / destination = 1/3 de la largeur de la fenêtre |
|     - Eléments pour types de fichiers et sous-répertoires = 1/6            |
|  - Gestion de la position et taille des colonnes de la liste des fichiers  |
==============================================================================
}
procedure TUserCtrl.AdjustOnResize(Sender: TObject);
begin
  with FrmMain do begin
    if ClientWidth < nWIDTH_MIN then begin
      ClientWidth := nWIDTH_MIN;
      Exit;
    end;
    if ClientHeight < nHEIGHT_MIN then begin
      ClientHeight := nHEIGHT_MIN;
      Exit;
    end;
    // Positon pour les éléments centraux du panneau de commande
    ComboBoxFileTypes.Left := (ClientWidth - ComboBoxFileTypes.Width) div 2;
    LabelFileTypes.Left := ComboBoxFileTypes.Left;
    CheckBoxSubFolder.Left := LabelFileTypes.Left;
    //
    // Positon pour les éléments à gauche du panneau de commande
    SpeedButtonSourcePath.Left := ComboBoxFileTypes.Left - SpeedButtonSourcePath.Width - 16;
    ComboBoxSourcePath.Width := SpeedButtonSourcePath.Left - ComboBoxSourcePath.Left - 2;
    EditSourcePath.Width := ComboBoxSourcePath.Width;
    //
    // Positon pour les éléments à droite du panneau de commande
    LabelTargetPath.Left := ComboBoxFileTypes.Left + ComboBoxFileTypes.Width + 16;
    ComboBoxTargetPath.Left := LabelTargetPath.Left;
    ComboBoxTargetPath.Width := ComboBoxSourcePath.Width;
    SpeedButtonTargetPath.Left := ComboBoxTargetPath.Left + ComboBoxTargetPath.Width + 2;
    EditTargetPath.Left := ComboBoxTargetPath.Left;
    EditTargetPath.Width := ComboBoxTargetPath.Width;
    //
    // --- Colonnes du HeaderControl
    if AppliData.bColon_Auto then begin
      with HeaderControl.Sections do begin
        Items[0].Width := 20;
        Items[1].Width := (HeaderControl.Width - 450) div 2;
        Items[2].Width := 90;
        Items[3].Width := 120;
        Items[4].Width := 24;
        Items[5].Width := 120;
        Items[6].Width := 90;
        Items[7].Width := Items[1].Width;
      end;
    end;
    //
    // --- Panneaux de la barre d'état (StatusBar)
    with StatusBar.Panels do begin
      Items[0].Width := StatusBar.Width div 10 * 4;
      Items[1].Width := StatusBar.Width div 10;
      Items[2].Width := Items[1].Width;
      Items[3].Width := Items[0].Width;
    end;
    CheckListBox.Refresh;
  end;
end;

{
==============================================================
|  Gestion des actions du menu fichier                       |
|------------------------------------------------------------|                                              |
|  - Sélection des répertoires source et cible               |
|  - Edition et sélection du filtre sur le nom des fichiers  |
|  - Mémorisation des choix dans les comboBox                |
|  - Choix avec ou sans les sous-répertoires                 |
==============================================================
}
procedure TUserCtrl.UserFileActions(Sender: TObject);
var
  nIndex  : integer;
  sPath   : string;
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  with FrmMain do begin
    if (CompareText (TMenuItem(Sender).Name, 'MenuItemQuit') = 0)
    or (CompareText (TSpeedButton (Sender).Name, 'SpeedButtonQuit') = 0) then
      FrmMain.close    // Abandon du programme
    else if CheckListBox.Count > 0 then begin // Si présence d'élément dans la liste
      // Récupération du contenu de la liste
      nIndex := CheckListBox.ItemIndex;
      ListUtils.ColContent (CheckListBox.Items[nIndex], sFields);
      // Gestion des commandes
      if (CompareText (TMenuItem(Sender).Name, 'MenuItemOpenSource') = 0)
      or (CompareText (TMenuItem(Sender).Name, 'PopupItemOpenSource') = 0) then begin
        sPath := ListUtils.SearchPathOfFile (nIndex, nSOURCE);
        ShellExecute(Handle, 'OPEN', pchar(sPath + sFields[nCOL_SOURCENAME]),'','', 1);
      end
      else if (CompareText (TMenuItem(Sender).Name, 'MenuItemOpenTarget') = 0)
      or (CompareText (TMenuItem(Sender).Name, 'PopupItemOpenTarget') = 0) then begin
        sPath := ListUtils.SearchPathOfFile (nIndex, nTARGET);
        ShellExecute(Handle, 'OPEN', pchar(sPath + sFields[nCOL_TARGETNAME]),'','', 1);
      end
      else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDelete') = 0)
      or (CompareText (TMenuItem(Sender).Name, 'PopupItemDelete') = 0) then begin
        // Recherche les fichiers sélectionnés (source et cible)
        // Appell du dialogue de suppression des fichiers
        if FrmDelete = nil then begin
          Application.CreateForm(TFrmDelete, FrmDelete);
          if FrmDelete.ShowModal = mrOk then
            ThreadStart;
          FrmDelete.Free;
          FrmDelete := nil;
        end;
      end
    end;
  end;
end;

{
==============================================================
|  Gestion des actions de sélection pour la synchronisation  |
|------------------------------------------------------------|                                              |
|  - Sélection des répertoires source et cible               |
|  - Edition et sélection du filtre sur le nom des fichiers  |
|  - Mémorisation des choix dans les comboBox                |
|  - Choix avec ou sans les sous-répertoires                 |
==============================================================
}
procedure TUserCtrl.UserSelectActions(Sender: TObject);
      {----------------------------------------------------------------
      |  Gestion de la boîte de dialogue pour le choix du répertoire  |
      ----------------------------------------------------------------}
      function GetFolder: string;
      begin
        if FrmSelDir = nil then
          Application.CreateForm(TFrmSelDir, FrmSelDir);
        FrmSelDir.SetInformations (LangLib.sSelDir_Title, LangLib.sSelDir_Select,
                                   LangLib.sBut_Accept, LangLib.sBut_Cancel);
        if FrmSelDir.ShowModal = mrOk then begin
          Result := FrmSelDir.sPathName;
        end;
        FrmSelDir.Free;
        FrmSelDir := nil;
      end;

      {-------------------------------------------
      |  Ajout d'un répertoire dans un comboBox  |
      -------------------------------------------}
      procedure AddInCombo (Combo: TComboBox; const sText: string);
      begin
        with Combo do begin
          if sText <> '' then begin
            if Items.IndexOf (sText) = -1 then begin    // Teste si texte déjà présent
              AddItem (sText, Items);                   // Ajoute dans le ComboBox
              Combo.ItemIndex := Items.IndexOf (sText); // Affiche le texte du réperoire ajouté
            end else
              Combo.ItemIndex := Items.IndexOf (sText); // Sélectionnne l'item déjà en liste
          end;
        end;
      end;

begin
  with FrmMain do begin
    // Choix du répertoire source -------
    if (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonSourcePath') = 0) then begin
      AddInCombo (ComboBoxSourcePath, GetFolder);
      AppliData.sSourcePath := ComboBoxSourcePath.Text;
      IniFileData.WriteComboList (ComboBoxSourcePath, AppliData.sSourcePathList);
    end
    // Sélection dans le combobox des répertoires sources
    else if (CompareText (TComboBox(Sender).Name, 'ComboBoxSourcePath') = 0) then
      AppliData.sSourcePath := ComboBoxSourcePath.Text
    // Choix du répertoire cible
    else if (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonTargetPath') = 0) then begin
      AddInCombo (ComboBoxTargetPath, GetFolder);
      AppliData.sTargetPath := ComboBoxTargetPath.Text;
      IniFileData.WriteComboList (ComboBoxTargetPath, AppliData.sTargetPathList);
    end
    // Sélection dans le combobox des répertoires cibless
    else if (CompareText (TComboBox(Sender).Name, 'ComboBoxTargetPath') = 0) then
      AppliData.sTargetPath := ComboBoxTargetPath.Text
    // Choix du filtre pour type de fichier
    else if (CompareText (TComboBox(Sender).Name, 'ComboBoxFileTypes') = 0) then begin
      AddInCombo (ComboBoxFileTypes, ComboBoxFileTypes.Text);
      AppliData.sFileFilter := ComboBoxFileTypes.Text;
      IniFileData.WriteComboList (ComboBoxFileTypes, AppliData.sFileFilterList);
    end
    // Choix pour sous-répertoires
    else if (CompareText (TCheckBox(Sender).Name, 'CheckBoxSubFolder') = 0) then
      AppliData.bSubFolder := CheckBoxSubFolder.Checked;
  end;
end;

{
==============================================================
|  Gestion des actions des outils                            |
|------------------------------------------------------------|                                              |
|  - Afficahge de la fenêtre des options                     |
|  - Affichage du popup menu de choix des skins              |
==============================================================
}
procedure TUserCtrl.UserToolActions(Sender: TObject);
begin
  // Lancement de la comparaison des répertoires
  if (CompareText (TMenuItem(Sender).Name, 'MenuItemScanStart') = 0)
  or (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonScanStart') = 0) then
    ThreadStart
  // Arrêt de la comparaison des répertoires
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemScanStop') = 0)
  or (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonScanStop') = 0) then begin
    // Gestion du Thread
    AppliData.bScanActive := FALSE; // Détermine l'arrêt de la recherche des éléments àa afficher
    Scan.Terminate;
  end
  // Lance la synchonisation
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemSynchro') = 0)
  or (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonSynchro') = 0) then begin
    // Recherche les fichiers sélectionnés (source et cible)
    // Appel du dialogue de suppression des fichiers
    if FrmSync = nil then begin
     Application.CreateForm(TFrmSync, FrmSync);
     if FrmSync.ShowModal = mrOk then
        ThreadStart;
      FrmSync.Free;
      FrmSync := nil;
    end;
  end
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDispAll') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDispAll') = 0) then
    ListUtils.RefreshFromCriteria (nCONTENT_ALL)
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDispSynchro') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDispSynchro') = 0) then
    ListUtils.RefreshFromCriteria (nCONTENT_SYNCHRO)
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDispToTarget') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDispToTarget') = 0) then
    ListUtils.RefreshFromCriteria (nCONTENT_TOTARGET)
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDispToSource') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDispToSource') = 0) then
    ListUtils.RefreshFromCriteria (nCONTENT_TOSOURCE)
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDispIdentical') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDispIdentical') = 0) then
    ListUtils.RefreshFromCriteria (nCONTENT_IDENTICAL)
  // Suppression des répertoires vides
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemDelCleanDir') = 0)
  or (CompareText (TComboBox(Sender).Name, 'SpeedButtonDelCleanDir') = 0) then begin
    if FrmDelDir = nil then
      Application.CreateForm(TFrmDelDir, FrmDelDir);
    // Affichage et attente de la fermeture
    FrmDelDir.ShowModal;
    // Fermeture de la fenêtre
    if FrmDelDir <> nil then begin
      FrmDelDir.Free;
      FrmDelDir := nil;
    end;
  end
  // Affichage de la boîte de dialogue des options
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemOptions') = 0)
  or (CompareText (TSpeedButton(Sender).Name, 'SpeedButtonOptions') = 0) then begin
    if FrmOptions = nil then
      Application.CreateForm(TFrmOptions, FrmOptions);
    // Affichage et attente de la fermeture
    FrmOptions.ShowModal;
    // Fermeture de la fenêtre
    if FrmOptions <> nil then begin
      FrmOptions.Free;
      FrmOptions := nil;
      FrmMain.CheckListBox.Refresh;
    end;
  end;
  //
  with FrmMain do
    if ComboBoxFileTypes.Enabled then
      ComboBoxFileTypes.SetFocus;
end;

{
==============================================================
|  Gestion des appels pour l'aide et de "A propos..."        |
|------------------------------------------------------------|                                              |
|  - Affichage du fichier d'aide                             |
|  - Affichage de la boîte de dialogue "A propos ..."        |
==============================================================
}
procedure TUserCtrl.UserHelpActions(Sender: TObject);
begin
  if (CompareText (TMenuItem(Sender).Name, 'MenuItemHelpTo') = 0) then
    ShellExecute (0, 'OPEN', 'FilesSync_Aide.pdf', Nil, Nil, SW_SHOW)
  // Affichage de la fenêtre A Propos ...
  else if (CompareText (TMenuItem(Sender).Name, 'MenuItemAbout') = 0) then
    CreateAboutBox (nDISPMODE_NORMAL, 0)
end;


{
==============================================================================
==================  Gestion des événements de la liste  ======================
==============================================================================
}
{
=========================================================
|  Gestion du double-click dans la liste de compraison  |
|-------------------------------------------------------|                                              |
|  Paramètre                                            |
|  - Sender : identification de l'objet appelant        |
=========================================================
}
procedure TUserCtrl.MouseActionDblClick (Sender: TObject);
var
  nIndex  : integer;  // Index de la ligne dans la liste
  sFile   : string;   // Fichier concerné par le double clic
  sPath   : string;   // Chemin correspondant au fichier
  ptMouse : TPoint;   // Coordonéées de la souris
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  with FrmMain do begin
    nIndex := CheckListBox.ItemIndex;
    ListUtils.ColContent (CheckListBox.Items[nIndex], sFields);       // Séparation du contenu des colonnes
    if sFields[nCOL_TYPE] = sTYPE_FILE then begin
      // La ligne correspond à un fichier
      ptMouse := CheckListBox.ScreenToClient(Mouse.CursorPos);
      with HeaderControl.Sections do begin
        if (ptMouse.X >= Items[nCOL_SOURCENAME].Left)
        and (ptMouse.X <= Items[nCOL_SOURCENAME].Right) then begin
          sPath := ListUtils.SearchPathOfFile (nIndex, nSOURCE);
          sFile := sFields[nCOL_SOURCENAME];
        end
        else if (ptMouse.X >= Items[nCOL_TARGETNAME].Left)
        and (ptMouse.X <= Items[nCOL_TARGETNAME].Right) then begin
          sPath := ListUtils.SearchPathOfFile (nIndex, nTARGET);
          sFile := sFields[nCOL_TARGETNAME];
        end;
      end;
      //
      if sPath <> '' then begin
        ShellExecute(Handle, 'OPEN', pchar(sPath + sFile),'','', 1);
      end;
    end;
  end;
end;

{
====================================================================
|  Affichage et gestion du contenu du menu contextuel de la lsite  |
====================================================================
}
procedure TUserCtrl.PopupMenu (const nPosX, nPosY: integer);
var
  nIndex  : integer;  // Index de la ligne dans la liste
  ptMouse : TPoint;   // Coordonéées de la souris
  sFields : array[0..8] of string;  // Contenu des colonnes
begin
  with FrmMain do begin
    // Récupère l'indice de la ligne sous le curseur
    ptMouse.X := nPosX;
    ptMouse.Y := nPosY;
    nIndex := CheckListBox.ItemAtPos(ptMouse, TRUE);
    // Si ligne présente sous le curseur
    if nIndex > -1 then begin
      ListUtils.ColContent (CheckListBox.Items[nIndex], sFields);       // Séparation du contenu des colonnes
      if sFields[nCOL_TYPE] = sTYPE_FILE then begin
        // Si clic sur une ligne contenant un fichier
        if CheckListBox.Selected[nIndex] = FALSE then begin
          CheckListBox.Enabled := FALSE;    // pour éviter un scintillement
          CheckListBox.ClearSelection;
          CheckListBox.Enabled := TRUE;
          CheckListBox.Selected[nIndex] := TRUE;
        end;
        // La ligne correspond à un fichier
        if CheckListBox.SelCount > 1 then begin
          // Plusieurs fichiers sélectionnés, donc pas d'ouverture de fichiers
          PopupMenuList.Items[0].Enabled := FALSE;
          PopupMenuList.Items[1].Enabled := FALSE;
        end
        else begin
          // Possibilité d'ouvrir le fichier sélectionné
          PopupMenuList.Items[0].Enabled := TRUE;
          PopupMenuList.Items[1].Enabled := TRUE;
          //
          if sFields[nCOL_SOURCENAME] = '' then
            PopupMenuList.Items[0].Enabled := FALSE;
          if sFields[nCOL_TARGETNAME] = '' then
            PopupMenuList.Items[1].Enabled := FALSE;
        end;
        // Ouverture du popup menu
        ptMouse := Mouse.CursorPos;
        PopupMenuList.Popup (ptMouse.X, ptMouse.Y);
      end;
    end;
  end;
end;

{
==============================================================================
===============  Gestion des appels des boîtes de dialogue  ==================
==============================================================================
}
{
==========================================================
|  Création de la boîte de dialogue "A propos"           |
|--------------------------------------------------------|
|  La boîte de dialogue "A propos..." peut aussi être    |
|  utilisée comme "splash" de l'application              |
|---------------------------------------------------------
|  Paramètres :                                          |
|  - nDispMode  : Choix mode "splash" ou  "A propos..."  |
|  - nDelay     : Temps d'affichage du mode "Splash"     |
==========================================================
}
procedure TUserCtrl.CreateAboutBox (const nDispMode, nDelay: integer);
var
  bmpImg: TBitMap;
begin
  bmpImg := TBitmap.Create;         // Pour transmettre une image
  FrmMain.ImageList32.GetBitmap(0, bmpImg);
  AboutBox (LangLib.sAbout_Title,
            Lang.sTitle_Application,
            LangLib.sAbout_DevName,
            sAUTHOR_NAME,
            LangLib.sAbout_Version + sPROG_VERS,
            sAUTHOR_EMAIL,
            LangLib.sAbout_EmailObj + '  ' + Lang.sMenu_TextApplic,
            LangLib.sBut_Close,
            bmpImg,
            nDispMode,
            nDelay);
  bmpImg.Free;
end;

end.
