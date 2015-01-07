unit FolderPanel;

interface

uses
   CommandMenu,Menus ,SysUtils, Classes, Controls, ExtCtrls,
   FolderView,Graphics,StdCtrls,Utils,ShellAPI,windows,FolderFile,
   Clipbrd,dialogs,ComCtrls,fuGetStr,Registry,
   fmSearchFile;

type
  TFolderTab = class  ;
  TFolderPage = class(TPageControl)
  private
    FIsInitTab : Boolean ;
    FFolderTab : TFolderTab;
    FPeerPage: TFolderPage;
    function GetActiveTab: TFolderTab;
    procedure SetPeerPage(const Value: TFolderPage);
    procedure DoTabChanging(Sender: TObject; var AllowChange: Boolean);overload ;
    function GetFocused: Boolean;
    procedure SetFocused(const Value: Boolean);

  public
    constructor Create(owner : TComponent);override ;
    procedure DoTabChanging; overload ;
    procedure DoTabChange(Sender:TObject);
    procedure InitTab ;
    // command
    procedure NewLabel (Sender:TObject);overload ;
    procedure NewLabel (Dir : String;DoActive:Boolean=true );overload ;
    procedure CloseLabel (Sender:TObject);
    procedure SwitchLeftRight (Sender:TObject);

    procedure ToggleFocus (Sender:TObject);
 
  published
    property ActiveTab : TFolderTab read GetActiveTab ;
    property PeerPage : TFolderPage  read FPeerPage write SetPeerPage;
    property Focused :Boolean read GetFocused write SetFocused ;
  end;
  TFolderTab = class(TTabSheet)
  private
    { Private declarations }
    //FTabSheet : TTabsheet ;
    FIsInitControl : Boolean ;
    FTop : TPanel ;
    FEdit :TEdit ;
    FFolderView : TFolderView;
    FFocused: boolean;
    FCurrDir: String;
    FSpecialFolder: TSpecialFolder;
    FPeerFolderTab: TFolderTab;
    FPeerFolderPage: TFolderPage;
    function GetCurrDir: String;
    procedure SetCurrDir(const Value: String);
    procedure DoDblClick(Sender: TObject);
    procedure DoEditExit(Sender: TObject);
    procedure DoKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
    function GetSelectedFilePath: String;
    function GetSelectedPath: String;
    function GetFolder: TFolder;
    procedure SetSpecialFolder(const Value: TSpecialFolder);
    procedure SetPeerFolderTab(const Value: TFolderTab);
    procedure DoEnter(Sender: TObject);
    function GetPeerFolderPage: TFolderPage;
    procedure SetPeerFolderPage(const Value: TFolderPage);
    function GetAllSelectedFile: String;
    function DeleteAllSelected: boolean;
    procedure SelectFile(Filename: string);
    procedure RefreshPeer ;

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(Owner:TComponent);override ;
    //property FolderView : TFolderView read FFolderView;
    procedure SetFocus(b : Boolean) ;
    procedure ControlPanel ;
    procedure StartMenu;
    property Focused :boolean read FFocused write SetFocus;
    // command
    procedure DosPrompt ;
    procedure Execute ;
    procedure Root ;
    procedure UpDir ;
    procedure DownDir ;
    procedure CopyFilePathToClp;
    procedure OpenExplorer ;
    procedure ListDrives;
    procedure Copy;
    procedure Move;
    procedure Delete ;
    procedure ChangeDir ;
    procedure Rename ;
    procedure LocateFile(f :String);
    procedure Search ;
    procedure _CreateDir;
    procedure _CreateTextFile;
    procedure _EditTextFile;
    property CurrDir : String read GetCurrDir write SetCurrDir;
    property SpecialFolder : TSpecialFolder  read FSpecialFolder write SetSpecialFolder;
    property PeerFolderTab : TFolderTab  read FPeerFolderTab write SetPeerFolderTab;
    //
    procedure InitControl;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  //RegisterComponents('Samples', [TFolderTab]);
end;

{ TFolderTab }

constructor TFolderTab.Create(Owner: TComponent);
begin
  inherited;
  FIsInitControl := False ;
end;
procedure TFolderTab.InitControl;
begin
  if not FIsInitControl then begin
    FTop := TPanel.Create(Self);
    FTop.Height := 20 ;
    FTop.Align := alTop ;
    FTop.TabStop := false ;
    Self.InsertControl(FTop);
    FFolderView := TFolderView.Create(Self);
    FFolderView.Align := alClient ;
    Self.InsertControl(FFolderView);
    // insert edit
    FEdit :=TEdit.Create(Self) ;
    FEdit.Align := alClient ;
    FEdit.TabStop := False ;
    FTop.InsertControl(FEdit);
    FFolderView.OnDblClick := DoDblClick;
    Fedit.OnExit := DoEditExit;
    FFolderView.OnKeyUp := DoKeyUp ;
    FFolderView.OnEnter := DoEnter;
    FSpecialFolder := sfNormal ;
    FIsInitControl := True ;
  end;
end;
function TFolderTab.GetFolder :TFolder ;
begin
  Result := nil;
  if FFolderView.Selected <> nil then
  begin
    Result := TFolder(FFolderView.Selected.Data);
  end;

end;
function TFolderTab.GetAllSelectedFile:String;
var
   r :string ;
   i : integer ;
   Item : TListItem;
   f : string ;
begin
   Item := FFolderView.selected ;
   with GetSL do
   try
     while not (Item =nil) do
     begin
       f :=TFolder(Item.Data).FileName + TFolder(Item.Data).FileExt;
       Add(FCurrDir+f);
       Item := FFolderView.GetNextItem(Item,sdAll,[isSelected]);
     end;
     Result := Text ;
   finally
      Free ;
   end;
end;

function TFolderTab.DeleteAllSelected:boolean;
var
   r :string ;
   i : integer ;
   Item : TListItem;
   f : string ;
begin
   Item := FFolderView.selected ;
   while not (Item =nil) do
   begin
     //Item := FFolderView.GetNextItem(Item,sdAll,[isSelected]);
     item.Delete ;
     Item := FFolderView.Selected ;
   end;
end;
procedure TFolderTab.DoDblClick(Sender: TObject);
begin
  Execute;
end;



procedure TFolderTab.SetCurrDir(const Value: String);
var
  dir : string;
begin
  if IsControlPanel(Value) then begin
    FFolderView.Fill (sfControlPanel);
    FFolderView.ForceAtLastOneSelected;
  end else if IsDisks(Value) then begin
      FSpecialFolder := sfDiskList ;
      FFolderView.Fill(sfDiskList);
      FFolderView.ForceAtLastOneSelected;
  end
  else
  if IsUnc(Value) then begin
    FFolderView.FillUnc(Value);
    FFolderView.ForceAtLastOneSelected;
  end else begin
    if IsStartMenu(Value) then begin
      dir := GetPROGRAMSFolder;
      Caption := dir;
      FFolderView.FillDir( dir) ;
    end else begin
      Caption := ExtractFileDir(Value) ;
      FFolderView.FillDir( Value) ;
    end;
    //FFolderView.ForceAtLastOneSelected;
  end;
  if IsStartMenu(value) then
    FCurrDir := dir
  else
    FCurrDir := Value ;
  FEdit.Text := FCurrDir ;
  Caption := GetLastPath(FCurrDir) ;
end;

procedure TFolderTab.SetFocus(b :Boolean );
begin
  if FFocused <> b then begin
    FFocused := b ;
    PeerFolderTab.Focused := not b ;
    if b then begin
      FEdit.Color := clGreen;
    end
    else   begin
      FEdit.Color := clBtnFace;
    end;
  end;

end;

procedure TFolderTab.SelectFile(Filename :string);
var name: string ;
  li : TListItem ;
begin
  li := FFolderview.FindCaption(0,Filename,False,true,False);
  if li <> nil then
    li.Selected := True;
    li.MakeVisible(false);
    li.Focused :=true ;
end;

procedure TFolderTab.UpDir;
var pdir,lastcurrdir : string ;
begin
  if IsControlPanel(FCurrDir) then
    Exit ;
  pdir := ParentDir(Fcurrdir);
  lastcurrdir :=LastDirName(Fcurrdir) ;
  if (pdir<> FCurrDir) then begin
    //FFolderView.FillDir(pdir);
    CurrDir := Pdir ;
    SelectFile(lastcurrdir)
  end;
end;


procedure TFolderTab.DosPrompt;
begin
  ShellExecute(0,'open','cmd.exe','' , PChar(FCurrDir),SW_SHOWNORMAL);
end;
function TFolderTab.GetSelectedFilePath:String;
var
  dir : String;
  f  : TFolder ;
begin
  if FFolderView.Selected <> nil then
  begin
    f := TFolder(FFolderView.Selected.Data);
    dir := f.Name;
    if f.IsFile then
      result := EnsureBackSlash(FCurrDir)+dir
    else
      result := EnsureBackSlash(FCurrDir)+EnsureBackSlash(dir);
  end;
end;
function TFolderTab.GetSelectedPath:String;
var
  dir : String;
  f  : TFolder ;
begin
  if FFolderView.Selected <> nil then
  begin
    f := TFolder(FFolderView.Selected.Data);
    dir := f.Name;
    if f.IsFile then
      result := ''
    else
      result := EnsureBackSlash(FCurrDir)+EnsureBackSlash(dir);
  end;
end;

procedure TFolderTab.Execute;
var
  dir : String;
begin
  if FFolderView.Selected <> nil then
  begin
    dir := GetFolder.Name;
    if  GetFolder.IsFile then
    begin
      if ExtractFileExt(dir) = '.cpl' then
        Winexec(PansiChar('control '+ dir) ,0)
      else if not IsControlPanel(Currdir) then
        ShellExecute(0,'open',PChar(EnsureBackSlash(FCurrDir)+dir),'' , PChar(FCurrDir),SW_SHOWNORMAL)
      else
        ShellExecute(0,'open',PChar(dir),'' , PChar(FCurrDir),SW_SHOWNORMAL);
    end else     begin
      if (FSpecialFolder = sfNormal) then
        CurrDir :=EnsureBackSlash(FCurrDir)+EnsureBackSlash(dir)
      else if (FSpecialFolder = sfDiskList) then begin
        CurrDir := dir ;
        FSpecialFolder := sfNormal
      end;
      FFolderView.ForceAtLastOneSelected;
    end
  end;
end;


procedure TFolderTab.Root;
begin
  //FFolderView.FillDir(EnsureBackSlash(ExtractFileDrive(CurrDir)));
  CurrDir :=EnsureBackSlash(ExtractFileDrive(CurrDir))
end;
function TFolderTab.GetCurrDir: String;
begin
  Result :=FCurrDir;
end;

procedure TFolderTab.DoEditExit(Sender: TObject);
begin
  CurrDir :=FEdit.Text ;
end;

procedure TFolderTab.CopyFilePathToClp;
var
  clp : TClipboard;
begin
   Clipboard.SetTextBuf(PChar(GetSelectedFilePath));
end;

procedure TFolderTab.DownDir;
var pdir : string ;
begin
  pdir := GetSelectedPath ;
  if  pdir<>'' then  begin
    CurrDir := Pdir ;
  end;
  FFolderView.ForceAtLastOneSelected;
end;




procedure TFolderTab.OpenExplorer;
begin
  ShellExecute(0,'open',PChar(EnsureBackSlash(FCurrDir)),'' , PChar(FCurrDir),SW_SHOWNORMAL);
end;


procedure TFolderTab.ListDrives;
begin
  //FSpecialFolder := sfDiskList ;
  //FFolderView.Fill(sfDiskList);
  CurrDir := '\\.\disks'
end;

procedure TFolderTab.SetSpecialFolder(const Value: TSpecialFolder);
begin
  FSpecialFolder := Value;
end;

procedure TFolderTab.SetPeerFolderTab(const Value: TFolderTab);
begin
  FPeerFolderTab := Value;
end;

procedure TFolderTab.Copy;
var
  i :integer ;
  froms ,tos :string ;
begin
  if (GetFolder <> nil ) and Confirm ('Are you sure') then begin
    // 得到全部文件和文件夹
    with Getsl do
    try
      text := GetAllSelectedFile;
      for i := 0 to count -1 do
        if IsDirectory(Strings[I]) then
          CopyTree(Strings[I],PChar(PeerFolderTab.Currdir))
        else begin
          // todo 提示文件已经存在？
          froms := Strings[I];
          tos := PeerFolderTab.Currdir+Extractfilename(Strings[I]);
          CopyFile(PChar(froms),PChar(tos),true);
        end;
    finally
      free ;
    end;
    // refresh
    //Currdir := Fcurrdir ;
    RefreshPeer ;
  end;
end;

procedure TFolderTab.Delete;
var
  i :integer ;
  foundedIndex,deleteIndex : integer;
  li : TListItem ;
  founded : boolean ;
begin
  if (GetFolder <> nil ) and Confirm ('Are you sure') then begin
    // 得到全部文件和文件夹
    // delete all file and folder ,需要实现一个deletefolder的函数
    with Getsl do
    try
      text := GetAllSelectedFile;
      // File system delete
      for i := 0 to count -1 do begin
        if IsDirectory(Strings[I]) then
          DelTree(Strings[I])
        else
          DeleteFile(PChar(Strings[I]));
      end;
      if count > 0 then begin
        //fileview delete
        deleteindex := FFolderView.Selected.Index ;
        DeleteAllSelected;
        // delete后，selected 需要focus到上一个，如果没有上一个，就是下一个，否则就不选了。
        for i := deleteIndex-1 to FFolderView.Items.Count -1 do
        begin
          if i  >= 0 then
          begin
            FFolderView.Items[i].Selected :=true;
            Break ;
          end ;
        end;
        //refresh peer
        if PeerFolderTab.CurrDir = CurrDir then
        begin
           RefreshPeer ;
        end;
      end;
    finally
      free ;
    end;
  end;
end;

procedure TFolderTab.Move;
var
  i :integer ;
  froms ,tos :string ;
begin
  if (GetFolder <> nil ) and Confirm ('Are you sure') then begin
    // 得到全部文件和文件夹
    with Getsl do
    try
      text := GetAllSelectedFile;
      for i := 0 to count -1 do
        if IsDirectory(Strings[I]) then
          MoveTree(Strings[I],PChar(PeerFolderTab.Currdir))
        else begin
          // todo 提示文件已经存在？
          froms := Strings[I];
          tos := PeerFolderTab.Currdir+Extractfilename(Strings[I]);
          MoveFile(PChar(froms),PChar(tos));
        end;
    finally
      free ;
    end;
    // refresh
    Currdir := Fcurrdir ;
    refreshPeer ;
  end;
end;

procedure TFolderTab.DoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // 8  backspace
  // 13 enter
  if (Key = 8 ) then
    UpDir
  else if (Key =13 ) then
    Execute ;
end;

procedure TFolderTab.DoEnter(Sender: TObject);
begin
  SetFocus(true);
  FFolderView.ForceAtLastOneSelected ;
end;



function TFolderTab.GetPeerFolderPage: TFolderPage;
begin

end;

procedure TFolderTab.SetPeerFolderPage(const Value: TFolderPage);
begin
  FPeerFolderPage := Value;
end;



procedure TFolderTab.ChangeDir;
begin
  FEdit.SetFocus ;
end;

procedure TFolderTab.Search;
var s : String;
begin
  //ShowMessage('Unimplemented');
  s := ShowSearchFiles (CurrDir);
  if s <> '' then
    LocateFile(s);
end;

procedure TFolderTab.LocateFile(f: String);
var filename : string ; i :Integer ;
begin
  // instead of iteration ,or I can locate it by 'FindCaption' 
  CurrDir := ExtractFilePath(f);
  filename := ChangeFileExt(ExtractFileName(f),'');
  for i := 0 to FFolderView.Items.Count -1 do
    if FFolderView.Items[i].Caption = filename then  begin
       FFolderView.Items[i].Selected :=True ;
       // move the item to middle positon of listview
       FFolderView.Scroll(0,FFolderView.Items[i].Top-FFolderView.Height div 2);
       Break ;
    end;
end;

procedure TFolderTab.ControlPanel;
begin
  CurrDir := '\\.\ControlPanel';
  //Caption := CurrDir;
end;
procedure TFolderTab.StartMenu;
begin
  CurrDir := '\\.\StartMenu';
  //Caption := CurrDir;
end;

procedure TFolderTab.Rename;
var
  dir ,newdir ,filename,newfilename,tipname: String;
begin
  filename := GetSelectedFilePath ;
  if IsDirectory(filename) then
    tipname := GetLastPath(filename)
  else
    tipname := ExtractFileName(filename);
  newfilename := GetStrForm (tipname,'rename file');
  if newfilename = '' then
    exit;
  newfilename := FCurrDir + newfilename ;
  if DirectoryExists(filename) or FileExists(filename) then
    if not RenameFile(filename,newfilename) then
      raise exception.CreateFmt('can not rename the file:%s',[filename]);
  Currdir := Fcurrdir ;
end;

procedure TFolderTab._CreateDir;
var
  newfilename: String;
  folder : TFolder ;
begin
  newfilename := GetStrForm ('','create dir ');
  if newfilename = '' then
    exit;
  if not CreateDir(FCurrDir + newfilename) then
    raise exception.CreateFmt('can not create dir:%s',[FCurrDir + newfilename]);
  //refresh
  //Currdir := Fcurrdir ;
  folder := TFolder.Create;
  folder.IsFile := false ;
  folder.DisplayLabel := newfilename;
  folder.Name := newfilename;
  folder.Size := 0 ;
  folder.Date := now ;
  FFolderView.FolderList.Add(folder);
  FFolderview.FillOne(folder);
  ffolderview.Selected := nil;
  SelectFile(newfilename);
  // refresh peertab
  if PeerFolderTab.CurrDir = CurrDir then
  begin
     PeerFolderTab.FFolderView.FillOne(folder);
     PeerFolderTab.SelectFile(newfilename);
  end;
end;
procedure TFolderTab._CreateTextFile;
var
  newfilename: String;
  folder : TFolder ;
  function GetNewTextFile(dir : string) : string;
  var
    i : integer;
    filename :string;
  begin
    i := 1 ;
    repeat
      filename := format('text%d.txt',[i]);
      inc(i);
    until(not fileexists(dir + filename));
    result := filename;
  end;
begin
  //newfilename := GetStrForm ('.txt','create text file');
  newfilename := GetNewTextFile(FCurrDir);
  with GetSL do try
    SaveToFile(FCurrDir + newfilename);
  finally
    free ;
  end;
  //Currdir := Fcurrdir ;
  folder := TFolder.Create;
  folder.IsFile := True ;
  folder.DisplayLabel := newfilename;
  folder.Name := newfilename;
  folder.Size := 0 ;
  folder.Date := now ;
  FFolderView.FolderList.Add(folder);
  FFolderview.FillOne(folder);
  ffolderview.Selected := nil;
  SelectFile(newfilename);
  //refresh peer
  if PeerFolderTab.CurrDir = CurrDir then
  begin
     PeerFolderTab.FFolderView.FillOne(folder);
     PeerFolderTab.SelectFile(newfilename);
  end;
end;

procedure TFolderTab._EditTextFile;
var
  filename: String;
  editor : string;
  function GetDefaultTextEditor(key:string):string;
  var
    r : TRegistry;s,str : string;
  begin
     r := TRegistry.Create(KEY_READ);
     //[HKEY_CLASSES_ROOT\.txt]
     r.RootKey := HKEY_CLASSES_ROOT;
     r.OpenKeyReadOnly('.txt');
     s := r.ReadString('');  // read default value
     r.CloseKey ;
     //HKEY_CLASSES_ROOT\emeditor.txt\shell\open\command
     str :=Format('%s\shell\open\command',[s]);
     r.OpenKeyReadOnly(str);
     s := r.ReadString('');
     r.CloseKey ;
     s := StringReplace(s,'"%1"','',[]);
     s := StringReplace(s,'"','',[rfReplaceAll]);
     Result := s;
  end;
begin
  filename := GetSelectedFilePath;
  editor := '';
  editor := GetDefaultTextEditor('');
  //ShowMessage(editor);
  ShellExecute(0,'open',PChar(editor),PChar(filename) , PChar(FCurrDir),SW_SHOWNORMAL);

end;
procedure TFolderTab.RefreshPeer;
begin
  PeerFolderTab.CurrDir := PeerFolderTab.CurrDir ;
end;

{ TFolderPage }

constructor TFolderPage.Create(owner: TComponent);
begin
  inherited;
  OnChanging := DoTabChanging;
  OnChange := DoTabChange;
  TabStop := false ;
  FFolderTab := TFolderTab.Create(Self);
end;

procedure TFolderPage.DoTabChanging(Sender: TObject; var AllowChange: Boolean);
begin
  DoTabChanging;
end;

procedure TFolderPage.DoTabChange(Sender: TObject);
begin
  ActiveTab.PeerFolderTab := PeerPage.ActiveTab ;
  PeerPage.ActiveTab.PeerFolderTab := ActiveTab ;
  ActiveTab.Focused := True;
  ActiveTab.FFolderView.SetFocus ;
  PeerPage.ActiveTab.Focused := false ;
end;

procedure TFolderPage.DoTabChanging;
begin
  //ActiveTab.Focused := False ;
end;

function TFolderPage.GetActiveTab: TFolderTab;
begin
  if (ActivePage <> nil)then
    Result := TFolderTab(ActivePage)
  else
    Result := FFolderTab ;
end;

procedure TFolderPage.SetPeerPage(const Value: TFolderPage);
begin
  FPeerPage := Value;
end;

procedure TFolderPage.NewLabel(Sender:TObject);
begin
  NewLabel(ActiveTab.CurrDir );
end;

procedure TFolderPage.CloseLabel;
var
  NextIndex : Integer ;
begin
   if PageCount > 1 then begin
     NextIndex := ActiveTab.TabIndex ;
     ActiveTab.Free ;
     if NextIndex = 0 then
       ActivePageIndex := 0
     else
       ActivePageIndex := NextIndex -1 ;
     // 不是用户做的事件，OnChange不会激发，需要自己调用事件。
     DoTabChange(nil) ;
   end;
end;

procedure TFolderPage.SwitchLeftRight;
var
   dir1: string ;
begin
  dir1 := ActiveTab.CurrDir ;
  ActiveTab.CurrDir := PeerPage.ActiveTab.CurrDir;
  PeerPage.ActiveTab.CurrDir :=dir1;
end;

function TFolderPage.GetFocused: Boolean;
begin
  result := ActiveTab.Focused ;
end;

procedure TFolderPage.SetFocused(const Value: Boolean);
begin
  ActiveTab.Focused := True ;
end;

procedure TFolderPage.InitTab;
begin
  if not FIsInitTab then begin
    FFolderTab.PeerFolderTab := PeerPage.ActiveTab ;
    FFolderTab.Align := alClient ;
    FFolderTab.PageControl := Self;
    FFolderTab.InitControl;
    FIsInitTab := True ;
  end;
end;

procedure TFolderPage.ToggleFocus;
begin
    ActiveTab.Focused := not ActiveTab.Focused;
end;





procedure TFolderPage.NewLabel(Dir: String;DoActive:Boolean=true);
var
  FolderTab : TFolderTab ;
  pgActive ,pgPeer: TFolderPage ;
begin
  if DirectoryExists(Dir) then begin
    pgActive := Self ;
    pgPeer := pgActive.PeerPage;
    // new page
    FolderTab := TFolderTab.Create(pgActive);
    FolderTab.PageControl := pgActive ;
    FolderTab.InitControl ;
    FolderTab.CurrDir := Dir;
    // 第一次不会触发OnChanging，因此Onchanging 内代码必须自己在这里写 ，并且需要
    // 在Activepage切换前执行(修改Peer)，否则SetFocused内会报错。
    FolderTab.PeerFolderTab := pgPeer.ActiveTab ;
    pgPeer.ActiveTab.PeerFolderTab := FolderTab ;
    if DoActive then begin
      pgActive.ActivePage := FolderTab ;
      FolderTab.Focused := true ;
    end;
  end;
end;

end.
