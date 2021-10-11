{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : IniFile.pas
|
|  Description : Gestion du fichier FilsSync.ini qui contient les
|                param�tres de l'application.                                                                                                           |
|
==============================================================================
}
unit IniFile;

interface

uses
  Forms, SysUtils, StdCtrls, Classes, IniFiles, Declare, StringUtils;

const

  //  Constantes pour la gestion du fichier *.ini
  sOPTIONS_FILE       = 'FilesSync.ini';
  // El�ments du programme
  sSECTION_PROGRAM    = '=== PROGRAM ===';
  sRUB_COMMANDBAR     = 'COMMANDBAR';     // Barre des boutons de ommandes
  sRUB_SELECTBAR      = 'SELECTBAR';      // Barre des �l�menst de s�lection
  sRUB_STATUSBAR      = 'STATUSBAR';      // Barre d'�tat de la fen�tre
  sRUB_DEFSOURCE      = 'DEF_SOURCE';     // Chemin du r�pertoire source
  sRUB_DEFTARGET      = 'DEF_TARGET';     // Chemin du r�pertoire cible
  sRUB_DEFTYPESFILE   = 'DEF_TYPESFILE';  // Type du filtre des fichiers
  sRUB_SUBFOLDER      = 'DEF_SUBFOLDER';  // Recherche dans sous-r�pertoires
  // El�ments de l'interface
  sSECTION_INTERFACE  = '=== INTERFACE ===';
  sRUB_LEFT           = 'LEFT';       // Position gauche de la fen�tre
  sRUB_TOP            = 'TOP';        // Position haute de la fen�tre
  sRUB_WIDTH          = 'WIDTH';      // Largur de la fen�tre
  sRUB_HEIGHT         = 'HEIGHT';     // Hauteur de la fen�tre
  sRUB_LANGUAGE       = 'LANGUAGE';   // Langage utilis�
  sRUB_SKIN           = 'SKIN';       // Choix du skin
  // El�ments des options
  sSECTION_OPTIONS    = '=== OPTIONS ===';
  sRUB_COLORPAIR      = 'COLOR_PAIR';     // Couleur de fond des lignes paires
  sRUB_COLORIMPAIR    = 'COLOR_IMPAIR';   // Couleur de fonde des lignes impaires
  sRUB_IGNORE2S       = 'IGNORE2S';       // Choix pour "oubli" d'une diff�rence de 2 secondes
  // El�ments des options de suppression des fichiers
  sSECTION_DELETE     = '=== DELETE ===';
  sRUB_DELCONFIRM     = 'DEL_CONFIRM';      // Confirmation de suppression � chaque fichier
  sRUB_MOVERECYCLE    = 'DEL_MOVERECYCLE';  // Supprime de fa�on d�finitive
  sRUB_DELCONFIRM2    = 'DEL_CONFIRM2';     // Confirmation de suppression � chaque fichier
  sRUB_MOVERECYCLE2   = 'DEL_MOVERECYCLE2'; // Supprime de fa�on d�finitive
  // El�ments des options de syncrnisation des fichiers
  sSECTION_SYNCHRO    = '=== SYNCHRO ===';
  sRUB_FROMSOURCE     = 'SYNC_FROMSOURCE';  // Synchronisation de la source vers la cible
  sRUB_FROMTARGET     = 'SYNC_FROMTARGET';  // Synchronisation de la cible vers la source
  // Position des colonnnes de la liste de s�lection
  sSECTION_COLONS     = '=== COLONS_WIDTH ===';
  sRUB_COLONAUTO      = 'COL_AUTOWIDTH';   // Synchronisation de la source vers la cible
  sRUB_COLON          = 'COL_';            // Synchronisation de la source vers la cible



type

  // Classe pour la gestion du fichier *.ini
  TIniFileData = class
    sFileName   : string;
    sSection    : string;
    sRubrique   : array of string;
    sComment    : array of string;
    function  CreateIniFile: TIniFile;
    procedure WriteStr (const sRubrique, sValue: string);
    function  ReadStr (const sRubrique: string): string;
    procedure WriteComboList (Combo: TComboBox; PathList: TStringList);
    procedure ReadComboList (Combo: TComboBox; PathList: TStringList);
    procedure WriteIniFile;
    procedure ReadIniFile;
  end;

var
  IniFileData : TIniFileData;

implementation

uses
  FormMain;

{
========================================================================
|  Cr�ation du composant TIniFile                                      |
|----------------------------------------------------------------------|                                              |
|  Cr�ation du chemin complet � partir du r�pertoire de l'application  |
|  et du nom de fichier puis cr�ation du composant TIniFile            |
========================================================================
}
function TIniFileData.CreateIniFile: TIniFile;
var
  sPathName : string;
begin
  sPathName := AppliData.sCurrDir + '\' + sOPTIONS_FILE;
  Result := TIniFile.Create(sPathName);
end;

{
==========================================================
|  Ecriture d'une option 'string' dans le fichier *.ini  |
|--------------------------------------------------------|                                              |
|  Param�tres :                                          |
|  - sRubrique  : Nom de la rubrique du fichier .ini     |
|  - sValue     : Valeur 'string' � �crire               |
==========================================================
}
procedure TIniFileData.WriteStr (const sRubrique, sValue: string);
var
  IniFile   : TIniFile;
begin
  IniFile := CreateIniFile;
  IniFile.WriteString (sSECTION_PROGRAM, sRubrique, sValue);
  IniFile.Free;
end;

{
=========================================================
|  Lecture d'une option 'string' dans le fichier *.ini  |
|-------------------------------------------------------|
|  Param�tres :                                         |
|  - sRubrique  : Nom de la rubrique du fichier .ini    |
|  Valeur de retours :                                  |
|  - string : Valeur 'string' de la rubrique            |
=========================================================
}
function TIniFileData.ReadStr (const sRubrique: string): string;
var
  IniFile   : TIniFile;
begin
  IniFile := CreateIniFile;
  Result := IniFile.ReadString (sSECTION_PROGRAM, sRubrique, '');
  IniFile.Free;
end;

{
=============================================================
|  Ecriture du contenu d'un ComboBox dans le fichier *.ini  |
|-----------------------------------------------------------|                                              |
|  Param�tre :                                              |
|  - IniFile  : Classe de sauvegarde des infos sur fichier  |
|  - Combo    : Nom du comboBox qui doit �tre sauvegard�    |
|-----------------------------------------------------------|                                              |
|  Le nom de la section du fichier .ini est le nom du       |
|  ComboBox et la rubrique est le num�ro d'index            |
=============================================================
}
procedure TIniFileData.WriteComboList (Combo: TComboBox; PathList: TStringList);
var
  i       : integer;
  IniFile : TIniFile;
begin
  IniFile := CreateIniFile;
  IniFile.EraseSection(Combo.Name);   // Supprime la section du ComboBox
  // Sauvegarde le contenu du ComboBox
  PathList.Clear;
  for i := 0 to Combo.Items.Count - 1 do begin
    IniFile.WriteString (Combo.Name, IntToStr(i), Combo.Items[i]);
    PathList.Add(Combo.Items[i]);
  end;
  // Lib�ration
  IniFile.Free;
end;

{
=============================================================
|  Lecture du contenu d'un ComboBox dans le fichier *.ini   |
|-----------------------------------------------------------|                                              |
|  Param�tre :                                              |
|  - IniFile  : Classe de sauvegarde des infos sur fichier  |
|  - Combo    : Nom du comboBox qui doit �tre initialis�    |
|-----------------------------------------------------------|                                              |
|  Le nom de la section du fichier .ini est le nom du       |
|  ComboBox et la rubrique est le num�ro d'index            |
=============================================================
}
procedure TIniFileData.ReadComboList (Combo: TComboBox; PathList: TStringList);
var
  i       : integer;
  sStr    : string;
  IniFile : TIniFile;
begin
  i := 0;
  IniFile := CreateIniFile;
  Combo.Clear;
  PathList.Clear;
  repeat
    sStr := IniFile.ReadString (Combo.Name, IntToStr(i), '');
    if sStr <> '' then begin
      Combo.Items.Add(sStr);
      PathList.Add(sStr);
    end;
    inc (i);
  until sStr = '';
  Combo.ItemIndex := 0;
  // Lib�ration
  IniFile.Free;
end;

{
==========================================================
|  Ecriture de toutes les options dans le fichier *.ini  |
|--------------------------------------------------------|                                              |
|  Toutes les options m�moris�es dans le fichier .ini    |
|  sont rassembl�es dans cette proc�dure                 |
==========================================================
}
procedure TIniFileData.WriteIniFile;
var
  i       : integer;
  sRubCol : string;
  IniFile : TIniFile;
begin
  IniFile := CreateIniFile;
  // Section PROGRAM
  // =========== G�rer l'index s�lectionn� du combo plut�t que du texte =======
  IniFile.EraseSection(sSECTION_PROGRAM);   // Supprime la section programme
  IniFile.WriteString (sSECTION_PROGRAM, sRUB_DEFSOURCE,    AppliData.sSourcePath);
  IniFile.WriteString (sSECTION_PROGRAM, sRUB_DEFTARGET,    AppliData.sTargetPath);
  IniFile.WriteString (sSECTION_PROGRAM, sRUB_DEFTYPESFILE, AppliData.sFileFilter);
  IniFile.WriteBool   (sSECTION_PROGRAM, sRUB_SUBFOLDER,    AppliData.bSubFolder);
  //
  with FrmMain do begin
    // Section pour l'interface
    IniFile.EraseSection(sSECTION_INTERFACE);   // Supprime la section interface
    IniFile.WriteString (sSECTION_INTERFACE, sRUB_LEFT,     IntToStr(FrmMain.Left));
    IniFile.WriteString (sSECTION_INTERFACE, sRUB_TOP,      IntToStr(FrmMain.Top));
    IniFile.WriteString (sSECTION_INTERFACE, sRUB_WIDTH,    IntToStr(FrmMain.Width));
    IniFile.WriteString (sSECTION_INTERFACE, sRUB_HEIGHT,   IntToStr(FrmMain.Height));
    IniFile.WriteString (sSECTION_INTERFACE, sRUB_LANGUAGE, sLanguage);
    // --- Options d'affichage ---
    // Section pour le menu d'affichage
    IniFile.WriteBool (sSECTION_PROGRAM, sRUB_COMMANDBAR, MenuItemCommandBar.Checked);
    IniFile.WriteBool (sSECTION_PROGRAM, sRUB_SELECTBAR,  MenuItemSelectBar.Checked);
    IniFile.WriteBool (sSECTION_PROGRAM, sRUB_STATUSBAR,  MenuItemStatusBar.Checked);
    // --- Bo�te de dialogue des options ---
    with AppliData do begin
      // Section contenu de l'onglet d'affichage
      IniFile.WriteString (sSECTION_OPTIONS, sRUB_COLORPAIR, Str.ColorToHex(AppliData.ColorPair));
      IniFile.WriteString (sSECTION_OPTIONS, sRUB_COLORIMPAIR, Str.ColorToHex(AppliData.ColorImpair));
      // Section contenu de l'onglet de comparaison
      IniFile.WriteBool (sSECTION_OPTIONS, sRUB_IGNORE2S, bIgnore2s);
    end;
    // Section contenu des combobox de l'historique
    WriteComboList (ComboBoxSourcePath, AppliData.sSourcePathList);
    WriteComboList (ComboBoxTargetPath, AppliData.sTargetPathList);
    WriteComboList (ComboBoxFileTypes, AppliData.sFileFilterList);
    // Section des options de suppression des fichiers
    IniFile.WriteBool (sSECTION_DELETE, sRUB_DELCONFIRM, AppliData.bDelConfirm);
    IniFile.WriteBool (sSECTION_DELETE, sRUB_MOVERECYCLE, AppliData.bDelMoveRecycle);
    IniFile.WriteBool (sSECTION_DELETE, sRUB_DELCONFIRM2, AppliData.bDelConfirm2);
    IniFile.WriteBool (sSECTION_DELETE, sRUB_MOVERECYCLE2, AppliData.bDelMoveRecycle2);
    // Section des options de synchronisation des fichiers
    IniFile.WriteBool (sSECTION_SYNCHRO, sRUB_FROMSOURCE, AppliData.bSyncSource);
    IniFile.WriteBool (sSECTION_SYNCHRO, sRUB_FROMTARGET, AppliData.bSyncTarget);
    // Position des colonnes de la liste des fichiers
    with HeaderControl.Sections do begin
      IniFile.WriteBool (sSECTION_COLONS, sRUB_COLONAUTO, AppliData.bColon_Auto);
      for i := 1 to Count do begin
        sRubCol := sRUB_COLON + IntToStr (i);
        IniFile.WriteInteger(sSECTION_COLONS, sRubCol, Items[i-1].Width);
      end;
    end;
  end;
  // Lib�ration
  IniFile.Free;
end;

{
=========================================================
|  Lecture de toutes les options dans le fichier *.ini  |
|-------------------------------------------------------|                                              |
|  Toutes les options lues dans le fichier .ini         |
|  sont rassembl�es dans cette proc�dure                |
=========================================================
}
procedure TIniFileData.ReadIniFile;
var
  i       : integer;
  sRubCol : string;
  IniFile : TIniFile;
begin
  IniFile := CreateIniFile;
  // Section PROGRAM
  // =========== G�rer l'index s�lectionn� du combo plut�t que du texte =======
  AppliData.sSourcePath := IniFile.ReadString (sSECTION_PROGRAM, sRUB_DEFSOURCE,    '');
  AppliData.sTargetPath := IniFile.ReadString (sSECTION_PROGRAM, sRUB_DEFTARGET,    '');
  AppliData.sFileFilter := IniFile.ReadString (sSECTION_PROGRAM, sRUB_DEFTYPESFILE, '');
  AppliData.bSubFolder  := IniFile.ReadBool   (sSECTION_PROGRAM, sRUB_SUBFOLDER,    TRUE);
  with FrmMain do begin
    // Section pour l'interface
    FrmMain.Left    := StrToInt (IniFile.ReadString (sSECTION_INTERFACE, sRUB_LEFT, '0'));
    FrmMain.Top     := StrToInt (IniFile.ReadString (sSECTION_INTERFACE, sRUB_TOP, '0'));
    FrmMain.Width   := StrToInt (IniFile.ReadString (sSECTION_INTERFACE, sRUB_WIDTH, '720'));
    FrmMain.Height  := StrToInt (IniFile.ReadString (sSECTION_INTERFACE, sRUB_HEIGHT, '520'));
    sLanguage       := IniFile.ReadString (sSECTION_INTERFACE, sRUB_LANGUAGE, '');
    // --- Options d'affichage ---
    // Section pour le menu d'affichage
    MenuItemCommandBar.Checked := IniFile.ReadBool (sSECTION_PROGRAM, sRUB_COMMANDBAR, TRUE);
    MenuItemSelectBar.Checked  := IniFile.ReadBool (sSECTION_PROGRAM, sRUB_SELECTBAR,  TRUE);
    MenuItemStatusBar.Checked  := IniFile.ReadBool (sSECTION_PROGRAM, sRUB_STATUSBAR,  TRUE);
    // --- Bo�te de dialogue des options ---
    with AppliData do begin
      // Section contenu de l'onglet d'affichage
      AppliData.ColorPair := Str.HexToColor (IniFile.ReadString (sSECTION_OPTIONS, sRUB_COLORPAIR, 'FFFFFF'));
      AppliData.ColorImpair := Str.HexToColor (IniFile.ReadString (sSECTION_OPTIONS, sRUB_COLORIMPAIR, 'C0DCC0'));
      // Section contenu de l'onglet de comparaison
      bIgnore2s := IniFile.ReadBool (sSECTION_OPTIONS, sRUB_IGNORE2S, FALSE);
    end;
    // Section contenu des combobox de l'historique
    ReadComboList (ComboBoxSourcePath, AppliData.sSourcePathList);
    ReadComboList (ComboBoxTargetPath, AppliData.sTargetPathList);
    ReadComboList (ComboBoxFileTypes, AppliData.sFileFilterList);
    // Section des options de suppression des fichiers
    AppliData.bDelConfirm     := IniFile.ReadBool (sSECTION_DELETE, sRUB_DELCONFIRM,   FALSE);
    AppliData.bDelMoveRecycle := IniFile.ReadBool (sSECTION_DELETE, sRUB_MOVERECYCLE,  FALSE);
    AppliData.bDelConfirm2    := IniFile.ReadBool (sSECTION_DELETE, sRUB_DELCONFIRM2,  FALSE);
    AppliData.bDelMoveRecycle2:= IniFile.ReadBool (sSECTION_DELETE, sRUB_MOVERECYCLE2, FALSE);
    // Section des options de synchronisation des fichiers
    AppliData.bSyncSource  := IniFile.ReadBool (sSECTION_SYNCHRO, sRUB_FROMSOURCE, FALSE);
    AppliData.bSyncTarget  := IniFile.ReadBool (sSECTION_SYNCHRO, sRUB_FROMTARGET, FALSE);
    // Position des colonnes de la liste des fichiers
    with HeaderControl.Sections do begin
      AppliData.bColon_Auto  := IniFile.ReadBool (sSECTION_COLONS, sRUB_COLONAUTO, TRUE);
      for i := 1 to Count do begin
        sRubCol := sRUB_COLON + IntToStr (i);
        Items[i-1].Width := IniFile.ReadInteger(sSECTION_COLONS, sRubCol, 20);
      end;
    end;
  end;
  // Lib�ration
  IniFile.Free;
end;

end.
