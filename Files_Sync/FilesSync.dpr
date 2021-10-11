program FilesSync;



uses
  Forms,
  FormMain in 'FormMain.pas' {FrmMain},
  Language in 'Language.pas',
  Declare in 'Declare.pas',
  IniFile in 'IniFile.pas',
  UserControl in 'UserControl.pas',
  ScanFiles in 'ScanFiles.pas',
  FormDeleteFiles in 'FormDeleteFiles.pas' {FrmDelete},
  Utils in 'Utils.pas',
  FormSyncFiles in 'FormSyncFiles.pas' {FrmSync},
  FormDelCleanDir in 'FormDelCleanDir.pas' {FrmDelDir},
  Language_Lib in 'Language_Lib.pas',
  FilesUtils in 'FilesUtils.pas',
  StringUtils in 'StringUtils.pas',
  FormSelectDir in 'FormSelectDir.pas' {FrmSelDir};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
