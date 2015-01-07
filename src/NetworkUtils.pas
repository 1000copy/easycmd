unit NetworkUtils;

interface
uses netconn,windows,Classes,SysUtils;
function GetShareFolders (ComputerName : string):String;
function ListUNC(unc :string ):string;
function GetConnectedShare : String;
function ExistConnection(Unc :string) : boolean;
function UNCConnect(unc ,UserName,password: string ):Boolean;

implementation

function ExplodeUNC(unc : string;var ComputerName,ShareFolder:String):boolean;
var
  sl : TStringList  ;
begin
  ComputerName := '';
  ShareFolder := '';
  sl := TStringList.Create ;
  try
    sl.Delimiter := '\';
    sl.DelimitedText := unc ;
    if sl.Count < 3 then
      Result := false
    else
      ComputerName := sl.Strings[2];
    if sl.Count >= 4 then
      ShareFolder := sl.Strings[3];
    Result := True ;
  finally
    sl.free ;
  end;
end;
function GetUncConnectableResource (unc : string ):string;
var ComputerName,ShareFolder:String;
begin
   result := '';
   if ExplodeUNC(unc,ComputerName,ShareFolder) then
   begin
     Result := Format('\\%s\%s',[ComputerName,ShareFolder]) ;
   end;
end;
function ExistConnection(Unc :string) : boolean;
var sl :TStringList ;
var ComputerName,ShareFolder:String;
begin
  sl := TStringList.Create ;
  try
    sl.Text := GetConnectedShare ;
    Result := sl.IndexOf(GetUncConnectableResource(Unc)) <> -1 ;
  finally
    sl.Free ;
  end;   
end;
function GetConnectedShare : String;
var
  hEnum     : THandle;
  Count   : DWORD;
  BufSize : DWORD;
  pNR, pBuf : PNetResourceA;
  Ret     : DWORD;
  sl : TStringList ;
begin
  Ret := WNetOpenEnum(RESOURCE_CONNECTED,RESOURCETYPE_ANY, 0,nil, hEnum);
  if Ret <> NO_ERROR then 
    Exit; 
  BufSize := 1000;
  GetMem(pBuf, BufSize);
  sl := TStringList.Create ;
  try
    while True do
    begin 
      Count := $FFFFFFFF; // alle Items anfordern
      Ret := WNetEnumResource(hEnum, Count, pBuf, BufSize); 
      if Ret = ERROR_MORE_DATA then
       begin 
         Count := $FFFFFFFF;
         FreeMem(pBuf); 
         GetMem(pBuf, BufSize); 
         Ret := WNetEnumResource(hEnum, Count, pBuf, BufSize);
       end; 
      if Ret = ERROR_NO_MORE_ITEMS then 
        Break; // Fertig ! 
      if Ret <> NO_ERROR then
        exit;
      pNR := pBuf; 
      while Count > 0 do 
      begin
        sl.Add( pNR.lpRemoteName);
        Inc(pNR);
        Dec(Count);
      end;
    end;
    Result := sl.text;
  finally
    WNetCloseEnum(hEnum);
    FreeMem(pBuf);
    sl.free ;
  end; 
end;
procedure Find (Path,Matchs: String;var sl : TStringList) ;
var
   Res: TSearchRec;
   EOFound: Boolean;
   a : dword;
begin
   EOFound:= False;
   if FindFirst(Path+Matchs, faAnyFile, Res) = 0 then
     while  not EOFound do begin
       if (Res.Name <>'.') and (res.Name <>'..') then  begin
         sl.Add(Res.Name);
       end;
       EOFound:= FindNext(Res) <> 0;
     end;

   FindClose(Res);
end;
procedure CheckUncAccessable (Unc : string );
begin
  if not ExistConnection(unc) then
    raise Exception.CreateFmt('Unc "%s"connection is not exists',[unc]);
  if not DirectoryExists(unc) then
    raise Exception.CreateFmt('UNC %s is not exists',[unc]);
end;
function ListUNC(unc: string ):string;

var
  ComputerName,ShareFolder:String;
  netcon : TNetConnection ;
  sl ,sl1: TStringList ;
begin
  if ExplodeUNC(unc,ComputerName,ShareFolder) then
  begin
    sl1 := TStringList.Create ;
    try
      CheckUncAccessable(unc);
      Find(unc+'\','*.*',sl1);
      result :=  sl1.Text ;
    finally
      sl1.Free ;
    end;
  end;
end;
function UNCConnect(unc ,UserName,password: string ):Boolean;

var
  ComputerName,ShareFolder:String;
  netcon : TNetConnection ;
  sl ,sl1: TStringList ;
  dir : string ;
begin
  Result := false ;
  dir :=unc;
  if ExplodeUNC(dir,ComputerName,ShareFolder) then
  begin
    netcon := TNetConnection.Create(nil);
    sl := TStringList.Create ;
    sl1 := TStringList.Create ;
    try
      sl.Text := GetShareFolders('\\'+ComputerName);
      if sl.IndexOf(ShareFolder) <> -1 then begin
        // Already link ?
        if not ExistConnection(dir) then begin
          netcon.RemoteName := ExcludeTrailingPathDelimiter(dir);
          netcon.UserName :=UserName;
          netcon.Password := password;
          netcon.LocalName := '';
          netcon.Connect;
        end;
        if not DirectoryExists(ExcludeTrailingPathDelimiter(dir)) then
          raise Exception.CreateFmt('%s is not exists',[dir])
        else
          Result := True ;
      end else
        raise Exception.CreateFmt('UNC %s ''s Share folder is not exists',[dir]);
    finally
      netcon.Free ;
      sl.Free ;
      sl1.Free ;
    end;
  end;
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
end.
