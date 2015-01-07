program easycmd;

uses
  Forms,
  fmMain in 'fmMain.pas' {FormMain},
  FolderFile in 'FolderFile.pas',
  FolderView in 'FolderView.pas',
  Utils in 'Utils.pas',
  FolderPanel in 'FolderPanel.pas',
  FolderControl in 'FolderControl.pas',
  CommandMenu in 'CommandMenu.pas',
  fmSearchFile in 'fmSearchFile.pas' {JvSearchFileMainForm},
  JvSearch in 'JvSearch.pas',
  ecSession in 'ecSession.pas',
  uJSON in 'uJSON.pas',
  UserAndPass in 'UserAndPass.pas' {fmUserAndPassword},
  NetworkUtils in 'NetworkUtils.pas',
  fuGetStr in 'fuGetStr.pas' {fmGetStr};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TfmGetStr, fmGetStr);
  Application.Run;
end.
