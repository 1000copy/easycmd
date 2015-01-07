unit FolderView;

interface
uses
  SysUtils, Classes, Controls, ComCtrls,Dialogs,FolderFile,windows,ShellAPI,Utils,
  netconn,UserAndPass ,Graphics ,ShlObj,forms,
  NetworkUtils;//,JvListView;
const
   DiskUnc = '\\.\disks' ;
   ControlPanelUnc = '\\.\ControlPanel';
type
  TSpecialFolder =(sfNormal,sfDiskList,sfControlPanel,sfStartMenu);
  TFolderView = class(TListView)
  private
    // two fields for Click to sorting
    LastSortedColumn: integer;
    Ascending: boolean;
    // non sorting fields
    FCurrDir : String;
    FImgList : TImageList ;
    FFolderList: TFolderList;
    FSpecialFolder: TSpecialFolder;
    procedure SetFolderList(const Value: TFolderList);
    procedure FindAll(const Path: String);
    procedure ListDrives;
    procedure FillView;
    procedure SetSpecialFolder(const Value: TSpecialFolder);
    procedure ListControlPanel;
    procedure ListXXX;
    procedure Find(Path, Matchs: String; IsRescure: Boolean;ToQueryTable:Boolean=false);
    procedure ListShareFolder(const ComputerName: String);
    procedure FillUnc1(FilePath: string);
    procedure ListStartMenu;
    { Private declarations }
  protected
    { Protected declarations }
  public
    procedure FillSpecialFolder(FilePath: String);
    procedure FillUnc(FilePath:string);
    procedure FillDir(FilePath : String);
    procedure FillOne(folder : TFolder);
    procedure Fill(sf : TSpecialFolder);
    procedure ForceAtLastOneSelected;
    procedure ColClick(Column: TListColumn);override ;
  public
    { Public declarations }
    constructor Create(Owner:TComponent);override;
    destructor Destroy ;override ;
    property SpecialFolder: TSpecialFolder  read FSpecialFolder write SetSpecialFolder;
    property FolderList : TFolderList read FFolderList ;
  published
    { Published declarations }
  end;

procedure Register;

implementation




procedure Register;
begin
  //RegisterComponents('Samples', [TFolderView]);
end;

{ TFolderView }

constructor TFolderView.Create(Owner: TComponent);
begin
  inherited;
  //Width := Width div 2 ;
  ViewStyle := vsReport;
  RowSelect := True ;
  with Columns.Add do begin
     Caption := 'FileName';
     Width := 100;
  end;
  Columns.Add.Caption := 'Ext';
  Columns.Add.Caption := 'IsDir';
  Columns.Add.Caption := 'Size';
  with Columns.Add do begin
    Caption := 'Datetime';
    Width := 150;
  end;
  FFolderList := TFolderList.Create;
  LastSortedColumn := -1;
  Ascending := True;
  MultiSelect := true ;
  FImgList := TImageList.Create(Self) ;
  SmallImages := FImgList ;
end;
procedure TFolderView.FindAll (const Path: String) ;
var
   Res: TSearchRec;
   EOFound: Boolean;
   Folder : TFolder ;
begin
   EOFound:= False;
   FFolderList.Clear ;
   if FindFirst(IncludeTrailingBackslash(Path)+'*.*', faAnyFile, Res) = 0 then
     while  not EOFound do begin
       if (Res.Name <>'.') and (res.Name <>'..') then  begin
         Folder := TFolder.Create ;
         Folder.Name := res.Name;
         Folder.Size := Res.Size ;
         Folder.IsFile := not (Res.Attr and faDirectory = faDirectory);
         Folder.Date := FileDateToDateTime(res.Time);
         FFolderList.Add(Folder);
       end;
       EOFound:= FindNext(Res) <> 0;
     end;
   FindClose(Res.FindHandle);
end;
function GetShareFolders (ComputerName : string):String;
Var  
    EnumHandle                                 :   THandle;
    FileRS                                           :   TNetResource;  
    Buf                                               :   Array[1..500]   of   TNetResource;  
    BufSize                                       :   DWord;
    Entries                                       :   DWord;
    Res                                         :   Integer;
    mydir ,s : string ;
    sl :TStringList ;
begin
    mydir := ComputerName;
    //mydir为工作组名时可以得到组内所有主机名
    //mydir为主机名时可以得到机内所有共享文件夹名 
    mydir   :=   mydir   +   #0;
    FillChar(FileRS,   SizeOf(FileRS)   ,   0);  
    With   FileRS   do   begin  
        dwScope   :=   2;
        dwType   :=   3;  
        dwDisplayType   :=   1;  
        dwUsage   :=   2;  
        lpRemoteName   :=   @mydir[1];  
    end;
    sl := TStringList.Create;
    WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@FileRS,EnumHandle);  
    Repeat  
      Entries   :=   1;  
      BufSize   :=   SizeOf(Buf);
      Res   :=   WNetEnumResource(   EnumHandle,Entries,@Buf,BufSize   );

      If   (Res   =   NO_ERROR)   and   (Entries   =   1)   then
      begin  
          s:=   StrPas(Buf[1].lpRemoteName);   //得到网上资源名，主机或文件夹
          s := StringReplace(s ,ComputerName+'\','',[]);
          sl.Add(s);
      end   ;
    Until   (Entries   <>   1)   or   (Res   <>   NO_ERROR);
    WNetCloseEnum(   EnumHandle   );
    Result := sl.text ;
    sl.free ;
end;


procedure TFolderView.ListShareFolder (const ComputerName: String) ;
var
   sl : TStringList ;
   i :Integer ;
   Folder : TFolder ;
begin
   FFolderList.clear ;
   sl := TStringList.Create ;
   try
     sl.Text := GetShareFolders(ComputerName);
     for i := 0 to  sl.Count -1 do begin
         Folder := TFolder.Create ;
         Folder.Name := sl.Strings[i];
         Folder.Size := 0 ;
         Folder.IsFile := False;
         Folder.Date := 0;
         FFolderList.Add(Folder);
     end;
   finally
     sl.free ;
   end;
end;
destructor TFolderView.Destroy;
begin
  FFolderList.Free ;
  inherited;
end;
{
var
    finfo:   _SHFILEINFO;
    ico     :   TIcon;
begin
    SHGetFileInfo(pchar('D:\lcjun\easycmd\docs\changelog.txt'),0,finfo,sizeof(finfo),SHGFI_SMALLICON   or   SHGFI_ICON   or   SHGFI_SYSICONINDEX);
    Application.Icon.Handle   :=   finfo.hIcon;
    ico   :=   ticon.Create;
    ico.Handle   :=   finfo.hIcon;
    ico.SaveToFile('d:\aaa.ico');
    ico.Free;
end;
}

procedure TFolderview.FillView;
var i : Integer;
    finfo:   _SHFILEINFO;
    Folder :TFolder;
    icon : TIcon ;
    filename : string;
begin
   Items.Clear ;
   FImgList.Clear ;
   for i := 0 to FFolderList.Count -1 do
   begin
     with Items.add do
     begin
       Data :=  FFolderList.GetItem(i) ;
       Folder := FFolderList.GetItem(i);
       Caption :=  Folder.DisplayLabel;
       SubItems.Add(Folder.FileExt);
       SubItems.Add(Folder.FileType);
       SubItems.Add(Folder.SizeStr);
       SubItems.Add(Folder.DateStr);
       // file icon

       if (FCurrDir =DiskUnc) or  (FCurrDir =ControlPanelUnc) then
        filename := Folder.Name
       else
        filename := FCurrDir+ Folder.Name;
       SHGetFileInfo(pchar(filename),0,finfo,sizeof(finfo),SHGFI_SMALLICON   or   SHGFI_ICON   or   SHGFI_SYSICONINDEX);
       icon := TIcon.Create ;
       icon.Handle := finfo.hIcon ;
       ImageIndex :=  FImgList.AddIcon(icon);
     end;
   end;
   //ForceAtLastOneSelected
end;      {

procedure TFolderview.FillView1;
var i : Integer;
begin
   Items.Clear ;
   for i := 0 to FFolderList.Count -1 do
   begin
     with Items.add do
     begin
       Data :=  FFolderList.GetItem(i) ;
       Caption :=  FFolderList.GetItem(i).DisplayLabel;
       SubItems.Add(FFolderList.GetItem(i).FileExt);
       SubItems.Add(FFolderList.GetItem(i).FileType);
       SubItems.Add(FFolderList.GetItem(i).SizeStr);
       SubItems.Add(FFolderList.GetItem(i).DateStr);
     end;
   end;
   ForceAtLastOneSelected
end;         }

procedure TFolderView.FillSpecialFolder(FilePath: String);
var
   i :Integer ;
begin
   LockWindowUpdate(Handle);
   if UpperCase(FilePath) = UpperCase('ControlPanel') then begin
     FCurrDir := EnsureBackSlash(FilePath) ;
     FindAll(FCurrDir);
     FillView;
   end;
   LockWindowUpdate(0);
end;
procedure TFolderView.FillDir(FilePath: String);
var
   i :Integer ;
begin
   LockWindowUpdate(Handle);
   FCurrDir := EnsureBackSlash(FilePath) ;
   FindAll(FCurrDir);
   FillView;
   LockWindowUpdate(0);
end;

procedure TFolderView.SetFolderList(const Value: TFolderList);
begin
  FFolderList := Value;
end;


// delphi GetLogicalDriveStrings by google 
procedure TFolderView.ListDrives;
const
  DRIVE_UNKNOWN = 0;
  DRIVE_NO_ROOT_DIR = 1;
  DRIVE_REMOVABLE = 2;
  DRIVE_FIXED = 3;
  DRIVE_REMOTE = 4;
  DRIVE_CDROM = 5;
  DRIVE_RAMDISK = 6;
var
  r: LongWord;
  Drives: array[0..128] of char;
  pDrive: PChar;
  Folder : TFolder ;
begin
  FFolderList.clear ;
  r := GetLogicalDriveStrings(SizeOf(Drives), Drives);
  if r = 0 then Exit;
  if r > SizeOf(Drives) then
    raise Exception.Create(SysErrorMessage(ERROR_OUTOFMEMORY));
  pDrive := Drives;
  while pDrive^ <> #0 do
  begin
    //if GetDriveType(pDrive) = DRIVE_FIXED then
    //  Form1.ComboBox1.Items.Add(pDrive);
    Folder := TFolder.Create;
    Folder.IsFile := false;
    Folder.Name := pDrive;
    FFolderList.Add(Folder);
    Inc(pDrive, 4);
  end;
end;
procedure TFolderView.ListXXX;
var
  Folder : TFolder ;
begin{
  FFolderList.clear ;
    Folder := TFolder.Create;
    Folder.IsFile := false;
    Folder.Name := pDrive;
    FFolderList.Add(Folder);
  end;}
end;
function QueryTable(str :string):string;
begin
  with getsl do
  try
  begin
    Add('main.cpl=mouse');
    Add('certmgr.msc=cert');
    Add('ciadv.msc=index service');
    Add('compmgmt.msc=computer');
    Add('devmgmt.msc=device');
    Add('dfrg.msc=defrag');
    Add('diskmgmt.msc=disk');
    Add('eventvwr.msc=eventlog');
    Add('fsmgmt.msc=shared directory ');
    Add('lusrmgr.msc=local user and group');
    Add('ntmsmgr.msc=mobile storge');
    Add('ntmsoprq.msc=mobile storge operator');
    Add('perfmon.msc=performent');
    Add('services.msc=services');
    Add('wmimgmt.msc=WMI');
    Add('ncpa.cpl=netconnection');
    Add('telephon.cpl=telephone');
    Add('desk.cpl=desk');
    Add('appwiz.cpl=software');
    Add('firewall.cpl=firewall');
    Add('hdwwiz.cpl=hardware');
    Add('inetcpl.cpl=internet explorer');
    Add('intl.cpl=region and language');
    Add('irprops.cpl=irprops');
    Add('joy.cpl=game controller');
    Add('netsetup.cpl=net setup wizard');
    Add('nusrmgr.cpl=user account');
    Add('odbccp32.cpl=ODBC32');
    Add('powercfg.cpl=power');
    Add('sysdm.cpl=system info');
    Add('timedate.cpl=datetime');
    Add('wscui.cpl=windows security');
    Add('bthprops.cpl=blue tooth');
    Add('wuaucpl.cpl=eventlog');
    Add('access.cpl=access');
    Add('bdeadmin.cpl=Borland Data Engine');
      result := Values[str] ;
    if result ='' then
      Result := '';
  end;
  finally
    free;
  end;

end;
procedure TFolderView.Find (Path,Matchs: String;IsRescure : Boolean;ToQueryTable:Boolean=false) ;
var
   Res: TSearchRec;
   EOFound: Boolean;
   Folder : TFolder ;
begin
   EOFound:= False;
   if FindFirst(Path+Matchs, faAnyFile, Res) = 0 then
     while  not EOFound do begin
       if (Res.Name <>'.') and (res.Name <>'..') then  begin
         Folder := TFolder.Create ;
         if ToQueryTable then
          Folder.DisplayLabel := QueryTable(Res.Name) ;
         Folder.Name := res.Name;
         Folder.Size := Res.Size ;
         Folder.IsFile := not (Res.Attr and faDirectory = faDirectory);
         Folder.Date := FileDateToDateTime(res.Time);
         FFolderList.Add(Folder);
       end;
       EOFound:= FindNext(Res) <> 0;
     end;
   FindClose(Res.FindHandle);
end;
procedure TFolderView.ListControlPanel;
  function GetSysDir : String ;
  var
    Buf : array[0..255] of char ;
  begin
    GetSystemDirectory(
    Buf,	// address of buffer for system directory
    256 	// size of directory buffer
   );
    result := EnsureBackSlash(Buf) ;
  end;
  var s : string ;
begin
  FFolderList.Clear ;
  s:= GetSysDir ;
  Find(s,'*.msc',False,true);
  Find(s,'*.cpl',False,true);
end;
procedure TFolderView.ListStartMenu;
var s : string ;
 
begin
  FFolderList.Clear ;
  FCurrDir := EnsureBackSlash(GetPROGRAMSFolder);
  FillDir(FCurrDir);  
  //s:= GetSysDir ;
  //Find(s,'*.msc',False,true);
  //Find(s,'*.cpl',False,true);
end;
procedure TFolderView.Fill(sf: TSpecialFolder);
begin
  FSpecialFolder := sf ;
  if sf = sfDiskList then
  begin
    ListDrives;
    FCurrDir := DiskUnc;
  end else if sf =sfStartMenu then begin
    ListStartMenu ;
    //FCurrDir := '\\.\StartMenu';
  end 
  else begin
    ListControlPanel;
    FCurrDir := ControlPanelUnc;
  end;
  FillView;
end;

procedure TFolderView.ForceAtLastOneSelected;
begin
  if (Selcount =0 ) and (items.Count > 0 ) then begin
    Selected := Items[0];
    ItemFocused:= Items[0];
  end;

end;

procedure TFolderView.SetSpecialFolder(const Value: TSpecialFolder);
begin
  FSpecialFolder := Value;
end;

// function ColClick write by referecing from
// 1. jvcl's JvListView-ColClick and
// 2. http://www.delphi3000.com/articles/article_2609.asp?SK=
// delphi 3000 is Good site
// Thought JvListView is excellent component on sorting ,but it 's too complex to I
// use it directly
procedure TFolderView.ColClick(Column: TListColumn);
  function SortByColumn(Item1, Item2: TListItem; Data: integer): integer; stdcall;
  begin
    if Data = 0 then
      Result := AnsiCompareText(Item1.Caption, Item2.Caption)
    else
      Result := AnsiCompareText(Item1.SubItems[Data-1],
                                Item2.SubItems[Data-1]);
  end;
  function SortByColumn1(Item1, Item2: TListItem; Data: integer): integer; stdcall;
  begin
    Result := - SortByColumn(Item1, Item2, Data);
  end;
begin
  inherited;
  if Column.Index = LastSortedColumn then begin
    if Ascending then  begin
      CustomSort(@SortByColumn1, Column.Index);
      Ascending := False ;
    end else begin
      CustomSort(@SortByColumn, Column.Index);
      Ascending := true ;
    end;
  end
  else begin
    LastSortedColumn := Column.Index;
    CustomSort(@SortByColumn, Column.Index);
    Ascending := true ;
  end;

end;

procedure TFolderView.FillUnc(FilePath: string);

var
  ComputerName,ShareFolder:String;
  netcon : TNetConnection ;
  sl ,sl1: TStringList ;
  dir ,SharePath: string ;
  u,p : string;
  IsUserCancel : Boolean ;
begin
  dir :=FilePath;
  if ExplodeUNC(dir,ComputerName,ShareFolder) then
  begin
    netcon := TNetConnection.Create(self);
    sl := TStringList.Create ;
    try
      sl.Text := GetShareFolders('\\'+ComputerName);
      if ShareFolder = '' then begin
        ListShareFolder('\\'+ComputerName) ;
        FillView ;
      end
      else if sl.IndexOf(ShareFolder) <> -1 then begin
        // Already link ?
        IsUserCancel := false ;
        if not  ExistConnection(dir) then begin
          repeat
            IsUserCancel := not GetUserAndPass(u,p,dir +' need login');
          until IsUserCancel or  UNCConnect(FilePath,u,p);
        end;
        if not IsUserCancel then begin
          FindAll(dir);
          FillView;
        end;
      end else
        raise Exception.Create('UNC is not exists');
    finally
      netcon.Free ;
      sl.Free ;
    end;
  end;
end;
procedure TFolderView.FillUnc1(FilePath: string);

var
  ComputerName,ShareFolder:String;
  netcon : TNetConnection ;
  sl ,sl1: TStringList ;
  dir ,SharePath: string ;
  u,p : string;
begin
  dir :=FilePath;
  if ExplodeUNC(dir,ComputerName,ShareFolder) then
  begin
    netcon := TNetConnection.Create(self);
    sl := TStringList.Create ;
    try
      sl.Text := GetShareFolders('\\'+ComputerName);
      if ShareFolder = '' then begin
        ListShareFolder('\\'+ComputerName) ;
        FillView ;
      end
      else if sl.IndexOf(ShareFolder) <> -1 then begin
        // Already link ?
        SharePath := Format('\\%s\%s',[ComputerName,ShareFolder]);
        if not ExistConnection (ShareFolder) then begin
          netcon.RemoteName := SharePath;
          netcon.UserName :='';
          netcon.Password := '';
          netcon.LocalName := '';
          while true do
          try
            netcon.Connect ;
            Break ;
          except
            on E : Exception do  begin
              ShowMessage(e.Message);
            if not GetUserAndPass(u,p,dir +' need login') then
              exit else
            begin
              netcon.UserName := u;
              netcon.Password := p ;
            end;
            end;
          end;
        end;
        FindAll(dir);
        FillView;
      end else
        raise Exception.Create('UNC is not exists');
    finally
      netcon.Free ;
      sl.Free ;
    end;
  end;
end;

procedure TFolderView.FillOne(folder: TFolder);
var i : Integer;
    finfo:   _SHFILEINFO;
    icon : TIcon ;
    filename : string;
begin
   //Items.Clear ;
   //FImgList.Clear ;
   with Items.add do
   begin
     Data :=  Folder;
     Caption :=  Folder.DisplayLabel;
     SubItems.Add(Folder.FileExt);
     SubItems.Add(Folder.FileType);
     SubItems.Add(Folder.SizeStr);
     SubItems.Add(Folder.DateStr);
     filename := FCurrDir+ Folder.Name;
     SHGetFileInfo(pchar(filename),0,finfo,sizeof(finfo),SHGFI_SMALLICON   or   SHGFI_ICON   or   SHGFI_SYSICONINDEX);
     icon := TIcon.Create ;
     icon.Handle := finfo.hIcon ;
     ImageIndex :=  FImgList.AddIcon(icon);
   end;
end;
end.
