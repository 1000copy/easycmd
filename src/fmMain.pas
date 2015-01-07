unit fmMain;

interface

uses
  ShellAPI,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Menus,FolderView,FolderPanel, StdCtrls,FolderControl,ActnList,CommandMenu,utils;

type
  TFormMain = class(TForm)
    pnl1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fc : TFolderControl ;
  end;

var
  FormMain: TFormMain;


implementation
uses ecSession ;
{$R *.dfm}
procedure TFormMain.FormCreate(Sender: TObject);
var
  Session: TecSession ;
  procedure LoadLabels (Labels :TecLabels ;FolderPage :TFolderPage);
  var  i :Integer ;
  begin
      for i:= 0 to Labels.Count -1 do
      begin
        FolderPage.NewLabel(Labels.Get(i).Dir ,Labels.Get(i).Active );
      end;
  end;
begin
  Caption := GetappVer ;
  // Init FolderControl
  fc := TFolderControl.Create(self);
  fc.Align := alClient ;
  InsertControl(fc);
  fc.InitControl ;
  fc.MainMenu := TMainMenu.Create(Self) ;
  fc.InitMenu ;
  Session:= TecSession.Create ;
  try
    Session.Load ;
    LoadLabels(Session.LeftLabels,fc.pgLeft);
    LoadLabels(Session.RightLabels,fc.pgRight);
  finally
    Session.Free ;
  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
  Session: TecSession ;
  procedure SaveLabels (Labels :TecLabels ;FolderPage :TFolderPage);
  var  i :Integer ;
       lbl :TecLabel  ;
  begin
      for i:= 0 to FolderPage.PageCount -1 do
      begin
        lbl := TecLabel.Create;
        lbl.Dir := TFolderTab(FolderPage.Pages[i]).CurrDir ;
        lbl.Active := TFolderTab(FolderPage.Pages[i]).Focused ;
        Labels.Add(lbl);
      end;
  end;
begin
  Session:= TecSession.Create ;
  try
    SaveLabels(Session.LeftLabels,fc.pgLeft);
    SaveLabels(Session.RightLabels,fc.pgRight);
    Session.Save ;
  finally
    Session.Free ;
  end;
end;

end.
