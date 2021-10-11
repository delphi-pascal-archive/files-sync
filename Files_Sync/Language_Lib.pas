{
==============================================================================
|
|  Unit         : Language_Lib.pas
|
|  Description  : Lecture et mémorisation des textes de l'application
|                 à partir d'un fichier de type *.ini.
|
==============================================================================
}
unit Language_Lib;

interface

uses
  SysUtils, IniFiles;


type
  {
  ======================================================
  |  Textes standards pour les unités de la librairie  |
  ======================================================
  }
  TLanguageLib = class
    // Textes standards pour les menus
    sMenu_Password    : string;
    sMenu_File        : string;
    sMenu_New 	      : string;
    sMenu_Open	      : string;
    sMenu_Import      : string;
    sMenu_Save	      : string;
    sMenu_SaveTo      : string;
    sMenu_Delete      : string;
    sMenu_View	      : string;
    sMenu_Print	      : string;
    sMenu_Config      : string;
    sMenu_Options     : string;
    sMenu_Quit	      : string;
    sMenu_Help        : string;
    sMenu_HelpTo      : string;
    sMenu_About	      : string;
    // Texts standards pourmles bouttons
    sBut_Password     : string;
    sBut_New  	      : string;
    sBut_Open 	      : string;
    sBut_Import       : string;
    sBut_Save         : string;
    sBut_SaveTo       : string;
    sBut_Delete       : string;
    sBut_View         : string;
    sBut_Print        : string;
    sBut_Config       : string;
    sBut_Accept       : string;
    sBut_Close        : string;
    sBut_Quit         : string;
    sBut_Cancel       : string;
    // Textes standards pour les hints
    sHint_Open     : string;
    sHint_Import   : string;
    sHint_Save     : string;
    sHint_SaveTo   : string;
    sHint_Print    : string;
    sHint_Options  : string;
    sHint_Quit     : string;
    // Textes pour les messages
    sMsg_Wait     		    : string;
    // Textes pour l'acquisition d'un mot de passe
    sPass_Title       : string;
    sPass_Text        : string;
    sPass_Rights1     : string;
    sPAss_Rights2     : string;
    // Textes pour la fenêtre FormAbout
    sAbout_Title      : string;
    sAbout_Version    : string;
    sAbout_DevName    : string;
    sAbout_EmailObj   : string;
    // Textes la fenêtre FormAlertMsg
    sAlert_Title      : string;
    // Textes pour la fenêtre FormSelectDir
    sSelDir_Title     : string;
    sSelDir_Select	  : string;
    // Textes pour la fenêtre FormPreview
    sPrv_Title       	    : string;
    sPrv_Lbl_Zoom   	    : string;
    sPrv_Lbl_Format       : string;
    sPrv_Lbl_Unit   	    : string;
    sPrv_Cmb_Boundary	    : string;
    sPrv_Cmb_HarCopy	    : string;
    sPrv_Cmb_Fast		      : string;
    sPrv_but_Save	        : string;
    sPrv_But_Open	        : string;
    sPrv_But_Print		    : string;
    sPrv_But_Exit 		    : string;
    sPrv_txt_Saving    	  : string;
    sPrv_Txt_Loading   	  : string;
    sPrv_Txt_CreatePage   : string;
    sPrv_Txt_PrintPrepare : string;
    sPrv_Txt_PrintPage  	: string;
    sPrv_Txt_Of	  	      : string;
    sPrv_Txt_Done	  	    : string;
    sPrv_Txt_Page	  	    : string;
    // Textes pour la Fenêtre FormPreviewCfg
    sPrvCfg_Title         : string;
    sPrvCfg_GrpPanels     : string;
    sPrvCfg_Thumb		      : string;
    sPrvCfg_Navigator	    : string;
    sPrvCfg_Toolbar		    : string;
    sPrvCfg_Printbar	    : string;
    sPrvCfg_GrpToolBar    : string;
    sPrvCfg_Zoom		      : string;
    sPrvCfg_Paper		      : string;
    sPrvCfg_Orient		    : string;
    sPrvCfg_Boundary	    : string;
    sPrvCfg_Unit		      : string;
    sPrvCfg_GrpPrintBar   : String;
    sPrvCfg_Open		      : string;
    sPrvCfg_Save		      : string;
    sPrvCfg_Print		      : string;
    sPrvCfg_Quit		      : string;
    sPrvCfg_Hardcopy	    : string;
    sPrvCfg_FastPrint	    : string;
    // Textes pour les mois
    sMonths_ShortName     : array[1..12] of string; // Nom court
    sMonths_FullName      : array[1..12] of string; // Nom complet
    // Textes pour le zoom
    sZoom_Name        : array[0..6] of string;
    // Textes pour les skins
    sSkins_Skin       : string;
    sSkins_Choice     : string;
    sSkins_Normal     : string;
    //
    procedure ReadLanguage (const sLanguage: string);
  end;

var

  LangLib : TLanguageLib;

implementation


{
=======================================================
|  Lecture des textes en fonction de la langue        |
|-----------------------------------------------------|                                              |
|  Paramètre :                                        |
|  - sLanguage  : Identification du langage concerné  |
=======================================================
}
procedure TLanguageLib.ReadLanguage (const sLanguage: string);
var
  i         : integer;
  sSection  : string;
  IniFile   : TIniFile;
begin
  IniFile := TIniFile.Create(GetCurrentDir + '\' + sLanguage + '_Lib.lng');
  //
  //========================================================================
  // Texts standards and for libraries
  //========================================================================
  // Textes standards pour les menus
  sSection := '--- Texts standards for menus ---';
  sMenu_Password    := IniFile.ReadString (sSection, 'sMenu_Password', '');
  sMenu_File        := IniFile.ReadString (sSection, 'sMenu_File', '');
  sMenu_New         := IniFile.ReadString (sSection, 'sMenu_New', '');
  sMenu_Open        := IniFile.ReadString (sSection, 'sMenu_Open', '');
  sMenu_Import      := IniFile.ReadString (sSection, 'sMenu_Import', '');
  sMenu_Save        := IniFile.ReadString (sSection, 'sMenu_Save', '');
  sMenu_SaveTo      := IniFile.ReadString (sSection, 'sMenu_SaveTo', '');
  sMenu_Delete      := IniFile.ReadString (sSection, 'sMenu_Delete', '');
  sMenu_View        := IniFile.ReadString (sSection, 'sMenu_View', '');
  sMenu_Print       := IniFile.ReadString (sSection, 'sMenu_Print', '');
  sMenu_Config      := IniFile.ReadString (sSection, 'sMenu_Config', '');
  sMenu_Options     := IniFile.ReadString (sSection, 'sMenu_Options', '');
  sMenu_Quit        := IniFile.ReadString (sSection, 'sMenu_Quit', '');
  sMenu_Help        := IniFile.ReadString (sSection, 'sMenu_Help', '');
  sMenu_HelpTo      := IniFile.ReadString (sSection, 'sMenu_HelpTo', '');
  sMenu_About       := IniFile.ReadString (sSection, 'sMenu_About', '');
  // Textes standards pour les bouttons
  sSection := '--- Texts standards for buttons ---';
  sBut_Password     := IniFile.ReadString (sSection, 'sBut_Password', '');
  sBut_New          := IniFile.ReadString (sSection, 'sBut_New', '');
  sBut_Open         := IniFile.ReadString (sSection, 'sBut_Open', '');
  sBut_Import       := IniFile.ReadString (sSection, 'sBut_Import', '');
  sBut_Save         := IniFile.ReadString (sSection, 'sBut_Save', '');
  sBut_SaveTo       := IniFile.ReadString (sSection, 'sBut_SaveTo', '');
  sBut_Delete       := IniFile.ReadString (sSection, 'sBut_Delete', '');
  sBut_View         := IniFile.ReadString (sSection, 'sBut_View', '');
  sBut_Print        := IniFile.ReadString (sSection, 'sBut_Print', '');
  sBut_Config       := IniFile.ReadString (sSection, 'sBut_Config', '');
  sBut_Accept       := IniFile.ReadString (sSection, 'sBut_Accept', '');
  sBut_Close        := IniFile.ReadString (sSection, 'sBut_Close', '');
  sBut_Quit         := IniFile.ReadString (sSection, 'sBut_Quit', '');
  sBut_Cancel       := IniFile.ReadString (sSection, 'sBut_Cancel', '');
  // Textes standards pour les hints
  sSection := '--- Texts standards for hints ---';
  sHint_Open        := IniFile.ReadString (sSection, 'sHint_Open', '');
  sHint_Import      := IniFile.ReadString (sSection, 'sHint_Import', '');
  sHint_Save        := IniFile.ReadString (sSection, 'sHint_Save', '');
  sHint_SaveTo      := IniFile.ReadString (sSection, 'sHint_SaveTo', '');
  sHint_Print       := IniFile.ReadString (sSection, 'sHint_Print', '');
  sHint_Options     := IniFile.ReadString (sSection, 'sHint_Options', '');
  sHint_Quit        := IniFile.ReadString (sSection, 'sHint_Quit', '');
  // Textes pour les messages
  sSection := '--- Texts for messages ---';
  sMsg_Wait           := IniFile.ReadString (sSection, 'sMsg_Wait', '');
  // Textes pour l'acquisition d'un mot de passe
  sSection := '--- Texts for FormPassword ---';
  sPass_Title       := IniFile.ReadString (sSection, 'sPass_Title', '');
  sPass_Text        := IniFile.ReadString (sSection, 'sPass_Text', '');
  sPass_Rights1     := IniFile.ReadString (sSection, 'sPass_Rights1', '');
  sPass_Rights2     := IniFile.ReadString (sSection, 'sPass_Rights2', '');
  // Textes pour la fenêtre FormAbout
  sSection := '--- Texts for FormAbout ---';
  sAbout_Title      := IniFile.ReadString (sSection, 'sAbout_Title', '');
  sAbout_Version    := IniFile.ReadString (sSection, 'sAbout_Version', '');
  sAbout_DevName    := IniFile.ReadString (sSection, 'sAbout_DevName', '');
  sAbout_EmailObj   := IniFile.ReadString (sSection, 'sAbout_EmailObj', '');
  // Textes la fenêtre FormAlertMsg
  sSection := '--- Texts for FormAlertMsg ---';
  sAlert_Title      := IniFile.ReadString (sSection, 'sAlert_Title', '');
  // Textes pour la fenêtre FormSelectDir
  sSection := '--- Texts for FormSelectDir ---';
  sSelDir_Title     := IniFile.ReadString (sSection, 'sSelDir_Title', '');
  sSelDir_Select    := IniFile.ReadString (sSection, 'sSelDir_Select', '');
  // Textes pour la fenêtre FormPreview
  sSection := '--- Texts for preview ---';
  sPrv_Title            := IniFile.ReadString (sSection, 'sPrv_Title', '');
  sPrv_Lbl_Zoom         := IniFile.ReadString (sSection, 'sPrv_Lbl_Zoom', '');
  sPrv_Lbl_Format       := IniFile.ReadString (sSection, 'sPrv_Lbl_Format', '');
  sPrv_Lbl_Unit         := IniFile.ReadString (sSection, 'sPrv_Lbl_Unit', '');
  sPrv_Cmb_Boundary     := IniFile.ReadString (sSection, 'sPrv_Cmb_Boundary', '');
  sPrv_Cmb_HarCopy      := IniFile.ReadString (sSection, 'sPrv_Cmb_HarCopy', '');
  sPrv_Cmb_Fast         := IniFile.ReadString (sSection, 'sPrv_Cmb_Fast', '');
  sPrv_But_Save         := IniFile.ReadString (sSection, 'sPrv_But_Save', '');
  sPrv_But_Open         := IniFile.ReadString (sSection, 'sPrv_But_Open', '');
  sPrv_But_Print        := IniFile.ReadString (sSection, 'sPrv_But_Print', '');
  sPrv_But_Exit         := IniFile.ReadString (sSection, 'sPrv_But_Exit', '');
  sPrv_Txt_Saving    	  := IniFile.ReadString (sSection, 'sPrv_Txt_Saving', '');
  sPrv_Txt_Loading   	  := IniFile.ReadString (sSection, 'sPrv_Txt_Loading', '');
  sPrv_Txt_CreatePage   := IniFile.ReadString (sSection, 'sPrv_Txt_CreatePage', '');
  sPrv_Txt_PrintPrepare := IniFile.ReadString (sSection, 'sPrv_Txt_PrintPrepare', '');
  sPrv_Txt_PrintPage  	:= IniFile.ReadString (sSection, 'sPrv_Txt_PrintPage', '');
  sPrv_Txt_Of	  	      := IniFile.ReadString (sSection, 'sPrv_Txt_Of', '');
  sPrv_Txt_Done	  	    := IniFile.ReadString (sSection, 'sPrv_Txt_Done', '');
  sPrv_Txt_Page	  	    := IniFile.ReadString (sSection, 'sPrv_Txt_Page', '');
  // Textes pour la Fenêtre FormPreviewCfg
  sSection := '--- Texts for preview cfg ---';
  sPrvCfg_Title         := IniFile.ReadString (sSection, 'sPrvCfg_Title', '');
  sPrvCfg_GrpPanels     := IniFile.ReadString (sSection, 'sPrvCfg_GrpPanels', '');
  sPrvCfg_Thumb         := IniFile.ReadString (sSection, 'sPrvCfg_Thumb', '');
  sPrvCfg_Navigator     := IniFile.ReadString (sSection, 'sPrvCfg_Navigator', '');
  sPrvCfg_Toolbar       := IniFile.ReadString (sSection, 'sPrvCfg_Toolbar', '');
  sPrvCfg_Printbar      := IniFile.ReadString (sSection, 'sPrvCfg_Printbar', '');
  sPrvCfg_GrpToolBar    := IniFile.ReadString (sSection, 'sPrvCfg_GrpToolBar', '');
  sPrvCfg_Zoom          := IniFile.ReadString (sSection, 'sPrvCfg_Zoom', '');
  sPrvCfg_Paper         := IniFile.ReadString (sSection, 'sPrvCfg_Paper', '');
  sPrvCfg_Orient        := IniFile.ReadString (sSection, 'sPrvCfg_Orient', '');
  sPrvCfg_Boundary      := IniFile.ReadString (sSection, 'sPrvCfg_Boundary', '');
  sPrvCfg_Unit          := IniFile.ReadString (sSection, 'sPrvCfg_Unit', '');
  sPrvCfg_GrpPrintBar   := IniFile.ReadString (sSection, 'sPrvCfg_GrpPrintBar', '');
  sPrvCfg_Open          := IniFile.ReadString (sSection, 'sPrvCfg_Open', '');
  sPrvCfg_Save          := IniFile.ReadString (sSection, 'sPrvCfg_Save', '');
  sPrvCfg_Print         := IniFile.ReadString (sSection, 'sPrvCfg_Print', '');
  sPrvCfg_Quit          := IniFile.ReadString (sSection, 'sPrvCfg_Quit', '');
  sPrvCfg_Hardcopy      := IniFile.ReadString (sSection, 'sPrvCfg_Hardcopy', '');
  sPrvCfg_FastPrint     := IniFile.ReadString (sSection, 'sPrvCfg_FastPrint', '');
  // Textes pour les noms courts des mois
  sSection := '--- Texts for months short ---';
  for i := 1 to 12 do
    LangLib.sMonths_ShortName[i] := IniFile.ReadString (sSection, IntToStr (i), '');
  // Textes des noms complets des mois
  sSection := '--- Texts for months long ---';
  for i := 1 to 12 do
    LangLib.sMonths_FullName[i] := IniFile.ReadString (sSection, IntToStr (i), '');
  // Textes pour le zoom
  sSection := '--- Texts for zoom ---';
  for i := 0 to 6 do
    LangLib.sZoom_Name[i] := IniFile.ReadString (sSection, IntToStr (i), '');
  // Textes pour le choix des skins
  sSection := '--- Texts for Skins ---';
  sSkins_Skin         := IniFile.ReadString (sSection, 'sSkins_Skin', '');
  sSkins_Choice       := IniFile.ReadString (sSection, 'sSkins_Choice', '');
  sSkins_Normal       := IniFile.ReadString (sSection, 'sSkins_Normal', '');
  //
  IniFile.Free;
end;


end.
