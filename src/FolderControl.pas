unit FolderControl;
                        
interface

uses
  Dialogs,Forms,SysUtils, Classes, Controls,Graphics, ExtCtrls,FolderView,FolderPanel,Menus,CommandMenu,utils;

type
  TFolderControl = class(TPanel)
  private
    FForm : TForm ;
    FfpCurr: TFolderTab;
    spSplit : TSplitter;
    FIsInitControl : Boolean ;
    FMainMenu: TMainMenu;
    cmdList : TCommandList;
    function GetActivePage: TFolderPage;
    function GetActiveTab: TFolderTab;
    procedure SetMainMenu(const Value: TMainMenu);
    procedure _Delete(Sender:TObject);
    procedure _Move(Sender:TObject);
    procedure ChangeDir(Sender:TObject);
    procedure Copy(Sender:TObject);

    procedure CopyFilePathToClp(Sender:TObject);
    procedure DosPrompt(Sender:TObject);
    procedure DownDir(Sender:TObject);
    procedure Execute(Sender:TObject);
    procedure ListDrives(Sender:TObject);
    procedure OpenExplorer(Sender:TObject);
    procedure Root(Sender:TObject);
    procedure Search(Sender:TObject);
    procedure UpDir(Sender:TObject);
    procedure ToggleFocus(Sender:TObject);
    procedure NewLabel (Sender:TObject);
    procedure CloseLabel (Sender:TObject);
    procedure SwitchLeftRight (Sender:TObject);
    procedure ControlPanel(Sender: TObject);
    procedure _Exit(Sender :TObject);
    procedure _About(Sender :TObject);
    procedure Rename(Sender: TObject);
    procedure _CreateDir(Sender: TObject);
    procedure _CreateTextFile(Sender: TObject);
    procedure _EditTextFile(Sender: TObject);
    procedure StartMenu(Sender: TObject);

  protected
    { Protected declarations }
  public
    { Public declarations }
    pgLeft,pgRight : TFolderPage ;
    constructor Create(Owner:TComponent);override ;
    procedure InitControl ;
    property ActiveTab : TFolderTab read GetActiveTab ;
    property ActivePage : TFolderPage read GetActivePage ;
    property MainMenu :TMainMenu  read FMainMenu write SetMainMenu;
    procedure InitMenu;
  end;

implementation
const InitDir = 'c:\';


{ TFolderControl }
procedure TFolderControl.InitMenu;
var
  i :Integer; cmd :TCommand;

  function AddCatalog(MainMenu : TMainMenu;Caption :string):TMenuItem ;
  var mi : TMenuItem ;
  begin
      mi :=  TMenuItem.Create(MainMenu) ;
      mi.Caption := Caption ;
      MainMenu.Items.Add(mi);
      Result := mi ;
  end;  
  function AddMenuCommand(MenuItem : TMenuItem;Cmd :TCommand;Event : TNotifyEvent;ShortCut:TShortCut):TMenuItem ;
  var mi : TMenuItem ;Action :TecAction; MainMenu : TMainMenu;
  begin
      MainMenu := TMainMenu(MenuItem.Owner);
      mi :=  TMenuItem.Create(MainMenu) ;
      Action := TecAction.Create(MainMenu) ;
      Action.Caption := Cmd.Caption ;
      Action.cmd := Cmd ;
      Action.ShortCut := ShortCut;
      Action.OnExecute := Event ;
      mi.Action := Action;
      MenuItem.Add(mi);
      Result := mi ;
  end;
  procedure AssocMenuAndCmd (MI:TMenuItem;CmdList : TCommandList);
  var
    i :Integer ;
    MM : TMainMenu;
  begin
    MM := TMainMenu(MI.Owner);
    for i :=0 to cmdlist.Count -1 do begin
      cmd := cmdlist.GetCommand(i);
      AddMenuCommand(MI,cmd,cmd.OnClick,cmd.Shortcut)
    end;
  end;
  var
  mi,mc: TMenuItem ;
begin
    mi :=  AddCatalog(MainMenu,'File') ;
    cmdList := TCommandList.Create;
    try
      with cmdList do begin
        //file
        AddCommand('Rename',cmChangeDir,Rename,TextToShortCut('F2'));
        AddCommand('CreateDir',cmChangeDir,_CreateDir,TextToShortCut('F7'));
        AddCommand('CreateTextFile',cmChangeDir,_CreateTextFile,TextToShortCut('F8'));
        AddCommand('EditTextFile',cmChangeDir,_EditTextFile,TextToShortCut('F4'));
        AddCommand('ChangeDir',cmChangeDir,ChangeDir,TextToShortCut('alt+d'));
        AddCommand('CopyFilePathToClp',cmCopyFilePathToClp,CopyFilePathToClp,TextToShortCut('ctrl+1'));
        AddCommand('Root',cmRoot,Root,TextToShortCut('ctrl+\'));
        AddCommand('Updir',cmUpdir,UpDir,0);
        AddCommand('Downdir',cmDowndir,DownDir,0);
        AddCommand('ListDrivers',cmListDrivers,ListDrives,TextToShortCut('alt+e'));
        AddCommand('Execute',cmExecute,Execute,0);
        AddCommand('Search',cmSearch,Search,TextToShortCut('alt+f7'));
        AddCommand('Copy',cmCopy,Copy,TextToShortCut('f5') );
        AddCommand('Move',cmMove,_Move,TextToShortCut('f6'));
        AddCommand('Delete',cmDelete,_Delete,TextToShortCut('del') );
        AddCommand('Exit',cmDelete,_Exit,0);
      end;
      AssocMenuAndCmd(mi,cmdList);
      cmdList.Clear ;
      mi :=  AddCatalog(MainMenu,'Labels') ;
      with cmdList do begin
        // Label
        AddCommand('NewLabel',cmNew,NewLabel,TextToShortCut('Ctrl+T'));
        AddCommand('CloseLabel',cmClose,CloseLabel,TextToShortCut('Ctrl+W'));
        AddCommand('SwitchLeftRight',cmSwitchLeftRight,SwitchLeftRight,TextToShortCut('Ctrl+Left'));
        AddCommand('TogglePanel',cmTogglePanel,ToggleFocus,0);
      end;
      AssocMenuAndCmd(mi,cmdList);
      cmdList.Clear ;
      mi :=  AddCatalog(MainMenu,'System') ;
      with cmdList do begin
        //system
        AddCommand('DosPrompt',cmDosPrompt,DosPrompt,TextToShortCut('ctrl+8'));
        AddCommand('OpenFolder',cmOpenFolder,OpenExplorer,TextToShortCut('ctrl+9'));
        AddCommand('ControlPanel',cmSwitchLeftRight,ControlPanel,TextToShortCut('Ctrl+7'));
        AddCommand('StartMenu',cmSwitchLeftRight,StartMenu,TextToShortCut('Ctrl+6'));
      end;
      AssocMenuAndCmd(mi,cmdList);
      cmdList.Clear ;
      mi :=  AddCatalog(MainMenu,'Help') ;
      with cmdList do begin
        //system
        AddCommand('About',cmDosPrompt,_About,0);
      end;
      AssocMenuAndCmd(mi,cmdList);
    finally
      cmdList.Free ;
    end;
end;
constructor TFolderControl.Create(Owner: TComponent);
begin
  inherited;
  FForm := TForm(Owner);
  spSplit := TSplitter.Create(Self);
  pgLeft  := TFolderPage.Create(Self);
  pgRight := TFolderPage.Create(Self);

  pgLeft.PeerPage := pgRight ;
  pgRight.PeerPage := pgLeft ;

end;

function TFolderControl.GetActiveTab: TFolderTab;
begin
  Result := ActivePage.ActiveTab ;
end;
function TFolderControl.GetActivePage : TFolderPage ;
begin
   if pgLeft.ActiveTab.Focused  then
     result := pgLeft
   else
     result := pgRight ;
end;

procedure TFolderControl.InitControl;
begin
  if not FIsInitControl then begin
    InsertControl(spSplit);
    InsertControl(pgLeft);
    InsertControl(pgRight);
    spSplit.Align := alLeft ;
    spSplit.Left := 1;
    pgLeft.Align := alLeft ;
    pgRight.Align := alClient ;
    pgLeft.InitTab ;
    pgRight.InitTab ;
    pgLeft.Width := Width div 2 ;
    pgLeft.ActiveTab.CurrDir := InitDir;
    pgRight.ActiveTab.CurrDir := InitDir;

    pgLeft.ActiveTab.Focused := true ;
    FIsInitControl := True ;
  end;
end;

procedure TFolderControl.SetMainMenu(const Value: TMainMenu);
begin
  FMainMenu := Value;
end;

procedure TFolderControl.ChangeDir(Sender:TObject);
begin
  ActiveTab.ChangeDir;
end;

procedure TFolderControl.Copy;
begin
  ActiveTab.Copy;
end;

procedure TFolderControl.CopyFilePathToClp;
begin
  ActiveTab.CopyFilePathToClp;
end;

procedure TFolderControl._Delete;
begin
  ActiveTab.Delete;
end;
procedure TFolderControl._Exit(Sender :TObject);
begin
  FForm.close ;
end;

procedure TFolderControl.DosPrompt;
begin
  ActiveTab.DosPrompt;
end;

procedure TFolderControl.DownDir;
begin
  ActiveTab.DownDir;
end;

procedure TFolderControl.Execute;
begin
  ActiveTab.Execute;
end;

procedure TFolderControl.ListDrives;
begin
  ActiveTab.ListDrives;
end;

procedure TFolderControl._Move;
begin
  ActiveTab.Move ;
end;

procedure TFolderControl.OpenExplorer;
begin
  ActiveTab.OpenExplorer;
end;

procedure TFolderControl.Root;
begin
  ActiveTab.Root;
end;

procedure TFolderControl.Search;
begin
  ActiveTab.Search ;
end;

procedure TFolderControl.UpDir;
begin
  ActiveTab.UpDir;
end;
procedure TFolderControl.ToggleFocus(Sender:TObject);
begin
    ActiveTab.Focused := not ActiveTab.Focused;
end;

procedure TFolderControl.CloseLabel(Sender: TObject);
begin
  ActivePage.CloseLabel(Sender);
end;

procedure TFolderControl.NewLabel(Sender: TObject);
begin
  ActivePage.NewLabel(Sender);
end;
procedure TFolderControl.ControlPanel(Sender: TObject);
begin
  ActiveTab.ControlPanel;
end;

procedure TFolderControl.StartMenu(Sender: TObject);
begin
  ActiveTab.StartMenu;
end;

procedure TFolderControl.SwitchLeftRight(Sender: TObject);
begin
  ActivePage.SwitchLeftRight(Sender);
end;

procedure TFolderControl.Rename(Sender: TObject);
begin
  //
  ActiveTab.Rename ;
end;
procedure TFolderControl._About(Sender: TObject);
begin
  //
  showmessage(GetappVer );
end;

procedure TFolderControl._CreateDir(Sender: TObject);
begin
  //
  ActiveTab._CreateDir;
end;
procedure TFolderControl._CreateTextFile(Sender: TObject);
begin
  //
  ActiveTab._CreateTextFile;
end;
procedure TFolderControl._EditTextFile(Sender: TObject);
begin
  //
  ActiveTab._EditTextFile;
end;
end.
