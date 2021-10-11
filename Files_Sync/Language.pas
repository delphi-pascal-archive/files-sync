{
==============================================================================
|
|  Application  : FilesSync.exe
|  Unit         : Language.pas
|
|  Description  : Lecture et mémorisation des textes de l'application
|                 à partir d'un fichier de type *.ini.
|
==============================================================================
}
unit Language;

interface

uses
  SysUtils, IniFiles;

const

  sFRENCH = 'Français';
  sGERMAN = 'Deutsch';

type

  TLanguage = class
    //============================================
    // Textes spécifiques à l'application
    //============================================
    // Texts for titles
    sTitle_Application    : string;
    sTitle_MainApplic     : string;
    sTitle_FormOptions    : string;
    // Texts for menus
    // Menu file
    sMenu_OpenSource      : string;
    sMenu_OpenTarget      : string;
    sMenu_DeleteFiles     : string;
    // Menu tools
    sMenu_Tools           : string;
    sMenu_ScanStart       : string;
    sMenu_ScanStop        : string;
    sMenu_Synchro         : string;
    sMenu_DispAll		      : string;
    sMenu_DispSynchro	    : string;
    sMenu_DispToTarget	  : string;
    sMenu_DispToSource	  : string;
    sMenu_DispIdentical	  : string;
    sMenu_DelCleanDir     : string;
      // Menu view
    sMenu_View            : string;
    sMenu_CommandBar      : string;
    sMenu_SelectBar       : string;
    sMenu_StatusBar       : string;
    sMenu_TextApplic      : string;
    // Texts fo popup menu
    // Texts for labels
    sLabel_SourcePath	    : string;
    sLabel_TargetPath	    : string;
    sLabel_FileTypes	    : string;
    // Texts for checkbox
    sCheck_SubFolder	    : string;
    // Texts fot checklistbox
    sCLB_ColName          : string;
    sCLB_ColSize          : string;
    sCLB_ColModified      : string;
    // Test for hints
    sHint_ScanStart       : string;
    sHint_ScanStop        : string;
    sHint_Synchro         : string;
    sHint_DispAll         : string;
    sHint_DispSynchro     : string;
    sHint_DispToTarget    : string;
    sHint_DispToSource    : string;
    sHint_DispIdentical   : string;
    sHint_DelCleanDir     : string;
    sHint_Directory       : string;
    // Textes pour les messages
    sMsg_ErrDirAccess     : string;
    sMsg_FilesOf		      : string;
    sMsg_File             : string;
    sMsg_Files            : string;
    sMsg_FreeSpace		    : string;
    sMsg_Folders          : string;
    //
    // ==== Boîte de dialogue des options générales du programme ====
    // Texts for l'affichage
    sDisp_Tab   		      : string;
    sDisp_GrpColors	      : string;
    sDisp_ColorPair       : string;
    sDisp_ColorImpair	    : string;
    sDisp_ClicMe		      : string;
    sDisp_ColorDef		    : string;
    sDisp_ColWidth		    : string;
    // Texts for history lists
    sHistory_Tab		      : string;
    sHistory_Choice       : string;
    sHistory_Delete		    : string;
    sHistory_DeleteAll	  : string;
    // Textes pour les options de compraison
    sCmp_Tab              : string;
    sCmp_NTFS_FAT_Grp     : string;
    sCmp_Ignore_2s        : string;
    sCmp_Timezone		      : string;
    sCmp_ShiftTimeZone	  : string;
    sCmp_Hours		        : string;
    //
    // ==== Boîte de dialogue pour suppression des fichiers ====
    sDel_Title            : string;
    sDel_FromSource       : string;
    sDel_FromTarget       : string;
    sDel_Confirmation     : string;
    sDel_MoveRecycle      : string;
    sDel_Progress         : string;
    sDel_ButtonDelete     : string;
    sDel_ButtonStop       : string;
    sDel_MsgRecycleFiles  : string;
    sDel_MsgRecycleOne    : string;
    sDel_MsgDeleteOne     : string;
    sDel_MsgRecycleAll    : string;
    sDel_MsgDeleteAll     : string;
    // Pour suppression des répertoires vides
    sDel_DirTitle         : string;
    sDel_DirCleanSource   : string;
    sDel_DirCleanTarget   : string;
    sDel_MsgRecycleDir    : string;
    sDel_MsgRecyOneDir    : string;
    sDel_MsgDelOneDir     : string;
    //
    // ==== Boîte de dialogue pour la synchronisation des fichiers ====
    sSyn_Title            : string;
    sSyn_FromSource       : string;
    sSyn_FromTarget       : string;
    sSyn_DirSource		    : string;
    sSyn_DirTarget		    : string;
    sSyn_FileName		      : string;
    sSyn_BarProgressFile  : string;
    sSyn_BarProgress		  : string;
    sSyn_ButtonSync 		  : string;
    sSyn_ButtonStop 		  : string;
    sSyn_NotSpaceTitle    : string;
    sSyn_NotSpaceSource   : string;
    sSyn_NotSpaceTarget   : string;
    sSyn_NotSpaceSource80 : string;
    sSyn_NotSpaceTarget80 : string;
    sSyn_ConfirmSynchro   : string;
    //
    procedure ReadLanguage (sLanguage: string);
  end;

var

  Lang : TLanguage;

implementation


{
=======================================================
|  Lecture des textes en fonction de la langue        |
|-----------------------------------------------------|                                              |
|  Paramètre :                                        |
|  - sLanguage  : Identification du langage concerné  |
=======================================================
}
procedure TLanguage.ReadLanguage (sLanguage: string);
var
  sSection  : string;
  IniFile   : TIniFile;
begin
  IniFile := TIniFile.Create(GetCurrentDir + '\' + sLanguage + '.lng');
  //==================================================================================
  //  Textes spécifiques à l'application
  //==================================================================================
  // Textes pour les titres
  sSection := '--- Texts for titles ---';
  sTitle_Application    := IniFile.ReadString (sSection, 'sTitle_Application', '');
  sTitle_MainApplic     := IniFile.ReadString (sSection, 'sTitle_MainApplic', '');
  sTitle_FormOptions    := IniFile.ReadString (sSection, 'sTitle_FormOptions', '');
  // Textes pour les menus
  sSection := '--- Texts for menus ---';
  sMenu_OpenSource      := IniFile.ReadString (sSection, 'sMenu_OpenSource', '');
  sMenu_OpenTarget      := IniFile.ReadString (sSection, 'sMenu_OpenTarget', '');
  sMenu_DeleteFiles     := IniFile.ReadString (sSection, 'sMenu_DeleteFiles', '');
  // Menu tools
  sMenu_Tools           := IniFile.ReadString (sSection, 'sMenu_Tools', '');
  sMenu_ScanStart       := IniFile.ReadString (sSection, 'sMenu_ScanStart', '');
  sMenu_ScanStop        := IniFile.ReadString (sSection, 'sMenu_ScanStop', '');
  sMenu_Synchro         := IniFile.ReadString (sSection, 'sMenu_Synchro', '');
  sMenu_DispAll         := IniFile.ReadString (sSection, 'sMenu_DispAll', '');
  sMenu_DispSynchro     := IniFile.ReadString (sSection, 'sMenu_DispSynchro', '');
  sMenu_DispToTarget    := IniFile.ReadString (sSection, 'sMenu_DispToTarget', '');
  sMenu_DispToSource    := IniFile.ReadString (sSection, 'sMenu_DispToSource', '');
  sMenu_DispIdentical   := IniFile.ReadString (sSection, 'sMenu_DispIdentical', '');
  sMenu_DelCleanDir     := IniFile.ReadString (sSection, 'sMenu_DelCleanDir', '');
  // Menu view
  sMenu_View            := IniFile.ReadString (sSection, 'sMenu_View', '');
  sMenu_CommandBar      := IniFile.ReadString (sSection, 'sMenu_CommandBar', '');
  sMenu_SelectBar       := IniFile.ReadString (sSection, 'sMenu_SelectBar', '');
  sMenu_StatusBar       := IniFile.ReadString (sSection, 'sMenu_StatusBar', '');
  sMenu_TextApplic      := IniFile.ReadString (sSection, 'sMenu_TextApplic', '');
  // Textes pour les labels
  sSection := '--- Texts for labels ---';
  sLabel_SourcePath     := IniFile.ReadString (sSection, 'sLabel_SourcePath', '');
  sLabel_TargetPath     := IniFile.ReadString (sSection, 'sLabel_TargetPath', '');
  sLabel_FileTypes      := IniFile.ReadString (sSection, 'sLabel_FileTypes', '');
  // Textes pour les checkbox
  sSection := '--- Texts for checkbox ---';
  sCheck_SubFolder      := IniFile.ReadString (sSection, 'sCheck_SubFolder', '');
  // Textes pour les checklistbox
  sSection := '--- Texts for checklistbox ---';
  sCLB_ColName          := IniFile.ReadString (sSection, 'sCLB_ColName', '');
  sCLB_ColSize          := IniFile.ReadString (sSection, 'sCLB_ColSize', '');
  sCLB_ColModified      := IniFile.ReadString (sSection, 'sCLB_ColModified', '');
  // Textes pour les hints
  sSection := '--- Texts for hints ---';
  sHint_ScanStart       := IniFile.ReadString (sSection, 'sHint_ScanStart', '');
  sHint_ScanStop        := IniFile.ReadString (sSection, 'sHint_ScanStop', '');
  sHint_Synchro         := IniFile.ReadString (sSection, 'sHint_Synchro', '');
  sHint_DispAll         := IniFile.ReadString (sSection, 'sHint_DispAll', '');
  sHint_DispSynchro     := IniFile.ReadString (sSection, 'sHint_DispSynchro', '');
  sHint_DispToTarget    := IniFile.ReadString (sSection, 'sHint_DispToTarget', '');
  sHint_DispToSource    := IniFile.ReadString (sSection, 'sHint_DispToSource', '');
  sHint_DispIdentical   := IniFile.ReadString (sSection, 'sHint_DispIdentical', '');
  sHint_DelCleanDir     := IniFile.ReadString (sSection, 'sHint_DelCleanDir', '');
  sHint_Directory       := IniFile.ReadString (sSection, 'sHint_Directory', '');
  // Textes pour les messages
  sSection := '--- Texts for messages ---';
  sMsg_ErrDirAccess   := IniFile.ReadString (sSection, 'sMsg_ErrDirAccess', '');
  sMsg_FilesOf        := IniFile.ReadString (sSection, 'sMsg_FilesOf', '');
  sMsg_File           := IniFile.ReadString (sSection, 'sMsg_File', '');
  sMsg_Files          := IniFile.ReadString (sSection, 'sMsg_Files', '');
  sMsg_FreeSpace      := IniFile.ReadString (sSection, 'sMsg_FreeSpace', '');
  sMsg_Folders        := IniFile.ReadString (sSection, 'sMsg_Folders', '');
  //
  // ==== Boîte de dialogue des options générales du programme ====
  // Textes pour les options d'ffichage
  sSection := '--- Texts for display ---';
  sDisp_Tab   		    := IniFile.ReadString (sSection, 'sDisp_Tab', '');
  sDisp_GrpColors	    := IniFile.ReadString (sSection, 'sDisp_GrpColors', '');
  sDisp_ColorPair		  := IniFile.ReadString (sSection, 'sDisp_ColorPair', '');
  sDisp_ColorImpair	  := IniFile.ReadString (sSection, 'sDisp_ColorImpair', '');
  sDisp_ClicMe        := IniFile.ReadString (sSection, 'sDisp_ClicMe', '');
  sDisp_ColorDef      := IniFile.ReadString (sSection, 'sDisp_ColorDef', '');
  sDisp_ColWidth      := IniFile.ReadString (sSection, 'sDisp_ColWidth', '');
  // Textes pour les historiques
  sSection := '--- Texts for history lists ---';
  sHistory_Tab		    := IniFile.ReadString (sSection, 'sHistory_Tab', '');
  sHistory_Choice	    := IniFile.ReadString (sSection, 'sHistory_Choice', '');
  sHistory_Delete	    := IniFile.ReadString (sSection, 'sHistory_Delete', '');
  sHistory_DeleteAll	:= IniFile.ReadString (sSection, 'sHistory_DeleteAll', '');
  // Textes pour les options de compraison
  sSection := '--- Texts for compare options ---';
  sCmp_Tab		        := IniFile.ReadString (sSection, 'sCmp_Tab', '');
  sCmp_NTFS_FAT_Grp   := IniFile.ReadString (sSection, 'sCmp_NTFS_FAT_Grp', '');
  sCmp_Ignore_2s      := IniFile.ReadString (sSection, 'sCmp_Ignore_2s', '');
  sCmp_Timezone       := IniFile.ReadString (sSection, 'sCmp_Timezone', '');
  sCmp_ShiftTimeZone  := IniFile.ReadString (sSection, 'sCmp_ShiftTimeZone', '');
  sCmp_Hours          := IniFile.ReadString (sSection, 'sCmp_Hours', '');
  //
  // ==== Boîte de dialogue pour la suppression des fichiers ====
  sSection := '--- Texts for delete dialogue ---';
  sDel_Title          := IniFile.ReadString (sSection, 'sDel_Title', '');
  sDel_FromSource     := IniFile.ReadString (sSection, 'sDel_FromSource', '');
  sDel_FromTarget     := IniFile.ReadString (sSection, 'sDel_FromTarget', '');
  sDel_Confirmation   := IniFile.ReadString (sSection, 'sDel_Confirmation', '');
  sDel_MoveRecycle    := IniFile.ReadString (sSection, 'sDel_MoveRecycle', '');
  sDel_Progress       := IniFile.ReadString (sSection, 'sDel_Progress', '');
  sDel_ButtonDelete   := IniFile.ReadString (sSection, 'sDel_ButtonDelete', '');
  sDel_ButtonStop     := IniFile.ReadString (sSection, 'sDel_ButtonStop', '');
  sDel_MsgRecycleFiles:= IniFile.ReadString (sSection, 'sDel_MsgRecycleFiles', '');
  sDel_MsgRecycleOne  := IniFile.ReadString (sSection, 'sDel_MsgRecycleOne', '');
  sDel_MsgDeleteOne   := IniFile.ReadString (sSection, 'sDel_MsgDeleteOne', '');
  sDel_MsgRecycleAll  := IniFile.ReadString (sSection, 'sDel_MsgRecycleAll', '');
  sDel_MsgDeleteAll   := IniFile.ReadString (sSection, 'sDel_MsgDeleteAll', '');
  // Pour suppression des répertoires vides
  sDel_DirTitle       := IniFile.ReadString (sSection, 'sDel_DirTitle', '');
  sDel_DirCleanSource := IniFile.ReadString (sSection, 'sDel_DirCleanSource', '');
  sDel_DirCleantarget := IniFile.ReadString (sSection, 'sDel_DirCleanTarget', '');
  sDel_MsgRecycleDir  := IniFile.ReadString (sSection, 'sDel_MsgRecycleDir', '');
  sDel_MsgRecyOneDir  := IniFile.ReadString (sSection, 'sDel_MsgRecyOneDir', '');
  sDel_MsgDelOneDir   := IniFile.ReadString (sSection, 'sDel_MsgDelOneDir', '');
  //
  // ==== Boîte de dialogue pour la synchronisation des fichiers ====
  sSection := '--- Texts for synchro dialogue ---';
  sSyn_Title            := IniFile.ReadString (sSection, 'sSyn_Title', '');
  sSyn_FromSource       := IniFile.ReadString (sSection, 'sSyn_FromSource', '');
  sSyn_FromTarget       := IniFile.ReadString (sSection, 'sSyn_FromTarget', '');
  sSyn_DirSource        := IniFile.ReadString (sSection, 'sSyn_DirSource', '');
  sSyn_DirTarget        := IniFile.ReadString (sSection, 'sSyn_DirTarget', '');
  sSyn_FileName         := IniFile.ReadString (sSection, 'sSyn_FileName', '');
  sSyn_BarProgressFile  := IniFile.ReadString (sSection, 'sSyn_BarProgressFile', '');
  sSyn_BarProgress      := IniFile.ReadString (sSection, 'sSyn_BarProgress', '');
  sSyn_ButtonSync       := IniFile.ReadString (sSection, 'sSyn_ButtonSync', '');
  sSyn_ButtonStop       := IniFile.ReadString (sSection, 'sSyn_ButtonStop', '');
  sSyn_NotSpaceTitle    := IniFile.ReadString (sSection, 'sSyn_NotSpaceTitle', '');
  sSyn_NotSpaceSource   := IniFile.ReadString (sSection, 'sSyn_NotSpaceSource', '');
  sSyn_NotSpaceTarget   := IniFile.ReadString (sSection, 'sSyn_NotSpaceTarget', '');
  sSyn_NotSpaceSource80 := IniFile.ReadString (sSection, 'sSyn_NotSpaceSource80', '');
  sSyn_NotSpaceTarget80 := IniFile.ReadString (sSection, 'sSyn_NotSpaceTarget80', '');
  sSyn_ConfirmSynchro   := IniFile.ReadString (sSection, 'sSyn_ConfirmSynchro', '');
  //
  IniFile.Free;
end;


end.
