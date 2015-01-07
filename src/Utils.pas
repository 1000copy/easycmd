unit Utils;

interface

uses SysUtils,Classes ,ShellAPI,Windows,Forms,ShlObj;


function EnsureBackSlash(Dir:string):string;
function EnsureNoBackSlash(Dir:string):string;
function ParentDir(Dir:string):string;
// lastDirName('c:\windows\system32\') => system32
function LastDirName(Dir:string):string;

function IsSpecialFolder (Value:string):Boolean ;
function IsDisks (Value:string):Boolean ;
function IsStartMenu (Value:string):Boolean ;

function IsControlPanel (Value:string):Boolean ;
function IsUnc (Value:string):Boolean ;
function ExplodeUNC(unc : string;var ComputerName,ShareFolder:String):boolean;
function GetSL : TStringList ;
function GetLastPath (dir : string):string;
function IsDirectory(dir :string):Boolean ;
Function DelTree(DirName : string): Boolean;
Function CopyTree(DirName ,TodirName: string): Boolean;
Function MoveTree(DirName ,TodirName: string): Boolean;
function Confirm (Text: String):Boolean ;
function GetAppVer ():String;

function   GetPROGRAMSFolder:string;
function   GetDESKTOPFolder:string;

implementation


function   GetPROGRAMSFolder:string;
var
    pidl:pItemIDList;   
    buffer:array[0..255]   of   char;   
begin
    {
      CSIDL_DESKTOP
      CSIDL_INTERNET
      CSIDL_PROGRAMS
      CSIDL_CONTROLS
      CSIDL_PRINTERS
      CSIDL_PERSONAL
      CSIDL_FAVORITES
      CSIDL_STARTUP
      CSIDL_RECENT
      CSIDL_SENDTO
      CSIDL_BITBUCKET
      CSIDL_STARTMENU
      CSIDL_DESKTOPDIRECTORY
      CSIDL_DRIVES
      CSIDL_NETWORK
      CSIDL_NETHOOD
      CSIDL_FONTS
      CSIDL_TEMPLATES
      CSIDL_COMMON_STARTMENU
      CSIDL_COMMON_PROGRAMS
      CSIDL_COMMON_STARTUP
      CSIDL_COMMON_DESKTOPDIRECTORY
      CSIDL_APPDATA
      CSIDL_PRINTHOOD
      CSIDL_ALTSTARTUP
      CSIDL_COMMON_ALTSTARTUP
      CSIDL_COMMON_FAVORITES
      CSIDL_INTERNET_CACHE
      CSIDL_COOKIES
      CSIDL_HISTORY
    }
    SHGetSpecialFolderLocation(application.Handle,CSIDL_COMMON_PROGRAMS,pidl);
    SHGetPathFromIDList(pidl,buffer);   
    result:=strpas(buffer);   
end;

function   GetDESKTOPFolder:string;
var
    pidl:pItemIDList;
    buffer:array[0..255]   of   char;
begin
    SHGetSpecialFolderLocation(application.Handle,CSIDL_DESKTOP,pidl);
    SHGetPathFromIDList(pidl,buffer);   
    result:=strpas(buffer);   
end;
function GetAppVer ():String;
begin
  result := 'Easycmd 0.4';
end;
function Confirm (Text: String):Boolean ;
begin
  result := Application.MessageBox( PChar(Text),'Easycmd', MB_OKCANCEL + MB_ICONQUESTION) = IDOK
end;
Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    wFunc := FO_DELETE;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;

Function CopyTree(DirName ,TodirName: string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf ,toDirBuf: array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   FillChar(ToDirBuf, Sizeof(ToDirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   StrPCopy(ToDirBuf, ToDirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    pTo := @toDirBuf;
    wFunc := FO_COPY;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;

Function  MoveTree(DirName ,TodirName: string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf ,toDirBuf: array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   FillChar(ToDirBuf, Sizeof(ToDirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   StrPCopy(ToDirBuf, ToDirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    pTo := @toDirBuf;
    wFunc := FO_MOVE;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;

function IsDirectory(dir :string):Boolean ;
begin
  result := DirectoryExists(dir);
end;
function GetSL : TStringList ;
begin
  result := TStringList.Create;
end;
function GetLastPath (dir : string):string;
begin
  if Length(dir) = 3 then result :=dir
  else
  with GetSL do
  try
    Delimiter := '\' ;
    DelimitedText := ExcludeTrailingPathDelimiter(dir) ;
    result := Strings[Count -1];
  finally
    free ;
  end;
end;
function IsSpecialFolder (Value:string):Boolean ;
begin
 result := Pos('\\.',Value)=1 ;
end;

function IsStartMenu (Value:string):Boolean ;
begin
 result := Uppercase('\\.\StartMenu')=Uppercase(Value) ;
end;
function IsControlPanel (Value:string):Boolean ;
begin
 result := Uppercase('\\.\ControlPanel')=Uppercase(Value) ;
end;
function IsDisks (Value:string):Boolean ;
begin
 result := Uppercase('\\.\Disks')=Uppercase(Value) ;
end;

function IsUnc (Value:string):Boolean ;
begin
 result := (Pos('\\',Value)=1) and (Pos('\\.',Value)=0);
end;

function EnsureBackSlash(Dir:string):string;
begin
  Result := Dir ;
  if Result[Length(Result)] <>'\' then
    Result := Result + '\';
end;
function EnsureNoBackSlash(Dir:string):string;
begin
  Result := Dir ;
  if Result[Length(Result)] ='\' then
    SetLength( Result,Length(result)-1);
end;
function ParentDir(Dir:string):string;
var t : String ; i : Integer ;
var ComputerName,ShareFolder:String;
begin
  if IsUnc(Dir) then begin
    ExplodeUNC(Dir ,ComputerName,ShareFolder);
    if ShareFolder = '' then begin
      Result := dir ;
      exit ;
    end;
  end;
  if Length(EnsureBackSlash(dir))=3 then
    result := Dir
  else begin
    t := EnsureNoBackSlash(Dir) ;
    i := Length(t);
    while(i>0) and (t[i] <> '\') do begin
      SetLength(t,i-1);
      Dec(i);
    end;
    result := t ;
  end;
end;

function LastDirName(Dir:string):string;
var t ,r: String ; i : Integer ;
begin
    t := EnsureNoBackSlash(Dir) ;
    i := Length(t);
    r := '';
    while(i>0) and (t[i] <> '\') do begin
      r := t[i]+r;
      Dec(i);
    end;
    result := r ;
end;

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
end.
 