unit FolderFile;

interface
uses Classes ,SysUtils;
type
  TFolder = class
  private
    FIsFile: Boolean;
    FSize: Integer;
    FDisplayName : String ;
    FDateStr: String;
    FName: String;
    FDate: TDateTime;
    procedure SetIsFile(const Value: Boolean);
    procedure SetDate(const Value: TDateTime);
    procedure SetDateStr(const Value: String);
    procedure SetName(const Value: String);
    procedure SetSize(const Value: Integer);
    function GetDateStr: String;
    function GetFileType: String;
    function GetSizeStr: String;
    function GetFileExt: String;
    function GetFileName: string;
    function GetDisplayName: String;
    procedure SetDisplayLabel(const Value: String);
  public
    property IsFile : Boolean  read FIsFile write SetIsFile;
    property SizeStr : String read GetSizeStr;
    property FileType : String read GetFileType;
    property Name :String  read FName write SetName;
    property DisplayLabel :String read GetDisplayName write SetDisplayLabel ;
    property FileName : string read GetFileName ;
    property FileExt :String read GetFileExt ;
    property Size : Integer read FSize write SetSize;
    property Date : TDateTime  read FDate write SetDate;
    property DateStr : String read GetDateStr;
  end;
  TFolderList = class(TList)
  public
    function GetItem(I:Integer ) : TFolder ;
    destructor Destroy ;override ;
    procedure clear ;override ;
  end;
implementation

{ TFolder }

function TFolder.GetDateStr: String;
begin
  result := DateTimeToStr(FDate);
end;

function TFolder.GetDisplayName: String;
begin
  if FDisplayName = '' then
    result := FName
  else
    result := FDisplayName;
end;

function TFolder.GetFileExt: String;
begin
  Result := ExtractFileExt(FName);
end;

function TFolder.GetFileName: string;
begin
  if (Length(FName) = 3 ) then
    Result := FName
  else
    Result := ChangeFileExt(ExtractFileName(FName),'');
end;

function TFolder.GetFileType: String;
begin
  result := '<dir>';
  if FIsFile then
    Result := '';
end;

function TFolder.GetSizeStr: String;
begin
  Result := '';
  if IsFile then
    result := Inttostr(FSize);

end;

procedure TFolder.SetDate(const Value: TDateTime);
begin
  FDate := Value;
end;

procedure TFolder.SetDateStr(const Value: String);
begin
  FDateStr := Value;
end;

procedure TFolder.SetDisplayLabel(const Value: String);
begin
  FDisplayName := Value ;
end;

procedure TFolder.SetIsFile(const Value: Boolean);
begin
  FIsFile := Value;
end;

procedure TFolder.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TFolder.SetSize(const Value: Integer);
begin
  FSize := Value;
end;

{ TFolderList }

procedure TFolderList.clear; var i : Integer;
begin
  //for  i := 0 to self.Count -1 do
  //  TFolder(Items[i]).Free;
  inherited;

end;

destructor TFolderList.Destroy;     var i : Integer;
begin
  for  i := 0 to self.Count -1 do
    TFolder(Items[i]).Free;
  inherited;
end;

function TFolderList.GetItem(I: Integer): TFolder;
begin
  Result := TFolder(Items[i]);
end;

end.
