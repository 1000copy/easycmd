unit ecSession;

interface
uses classes ,Dialogs,SysUtils,uJSON;
const
  ecFile = 'easycmd.json';
type
  TecLabel = class
  public
    Dir : String;
    Active : Boolean ;
  end;
  Teclabels = class(TList )
  public
    function Get(I :Integer ):TecLabel;
    destructor Destroy ;override ;
  end;
  TecSession = class
  private
    FLeftLabels: Teclabels;
    FRightLabels: Teclabels;
    procedure SetLeftLabels(const Value: Teclabels);
    procedure SetRightLabels(const Value: Teclabels);
    procedure Save1;

  public
    constructor Create ;reintroduce;
    destructor Destroy ;override ;
    procedure Load ;
    procedure Save ;
    property LeftLabels : Teclabels  read FLeftLabels write SetLeftLabels;
    property RightLabels : Teclabels  read FRightLabels write SetRightLabels;

  end;
implementation

{ TecSession }

constructor TecSession.Create;
begin
  inherited ;
  FLeftLabels := Teclabels.Create ;
  FRightLabels := Teclabels.Create ;
end;

destructor TecSession.Destroy;
begin
  FLeftLabels.Free ;
  FRightLabels.Free ;
  inherited;
end;

procedure TecSession.Load;
var
    json : TJSONObject ;
    LastSession : TJSONObject ;
    lbl : TecLabel ;
    arr : TJSONArray;obj : TJSONObject;sl : TStringList; i :Integer;
   dir : string;active : boolean ;
begin
    if not FileExists(ecFile) then
      exit ;
    sl := TStringList.Create;
    sl.LoadFromFile(ecFile);
    json := TJSONObject.create (sl.Text );
    LastSession := json.getJSONObject('LastSession');
    arr := LastSession.getJSONArray('LeftPage');
    for i := 0 to arr.length -1 do begin
      if  arr.getJSONObject(i).optString('Dir') = 'c:\' then
        Continue ;
      lbl := TecLabel.Create ;
      lbl.Dir := arr.getJSONObject(i).optString('Dir');
      lbl.Active := arr.getJSONObject(0).optBoolean('Active');
      FLeftLabels.Add(lbl);
    end;
    arr := LastSession.getJSONArray('RightPage');
    for i := 0 to arr.length -1 do begin
      if  arr.getJSONObject(i).optString('Dir') = 'c:\' then
        Continue ;
      lbl := TecLabel.Create ;
      lbl.Dir := arr.getJSONObject(i).optString('Dir');
      lbl.Active := arr.getJSONObject(0).optBoolean('Active');
      FRightLabels.Add(lbl);
    end;  
end;

procedure TecSession.Save;
var
  root,lastsession,lbl : TJSONobject ;
  page :TJSONArray;
  i :Integer ;
  CurrLabels : Teclabels;
  sl :TStringList ;
begin
  try
    lastsession := TJSONObject.create;
    // left page
    CurrLabels := LeftLabels ;
    page := TJSONArray.Create;
    for I := 0 to CurrLabels.Count -1 do begin
      lbl := TJSONobject.Create;
      lbl.Put('Dir',CurrLabels.Get(I).Dir);
      lbl.Put('Active',CurrLabels.Get(I).Active);
      page.Put(lbl);
    end;
    lastsession.put('LeftPage',Page);
    // right page
    CurrLabels := RightLabels ;
    page := TJSONArray.Create;
    for I := 0 to CurrLabels.Count -1 do begin
      lbl := TJSONobject.Create;
      lbl.Put('Dir',CurrLabels.Get(I).Dir);
      lbl.Put('Active',CurrLabels.Get(I).Active);
      page.Put(lbl);
    end;
    lastsession.put('RightPage',Page);
    //  lastsession put into root
    root := TJSONObject.create;
    root.put('LastSession',lastsession);
    sl := TStringList.Create;
    try

      sl.Text := root.toString(2) ;
      sl.SaveToFile(ecFile);
    finally
      sl.Free ;
    end;
  finally
     root.Free ;
  end;
end;
// stupid methods ,compare of "Save"
procedure TecSession.Save1;
var i :Integer ;
    s : string ;
const Enter = #13#10 ;
const formatstr = '{"Dir":"%s","Active":%s}';
var
  sl :TStringList;
  function  BooleanToStr(b :Boolean):string;
  begin
    if b then
      result := 'True'
    else
      Result := 'False';
  end;
  function CStyleDir(Dir :string):String;
  begin
    Result := StringReplace(Dir,'\','\\',[rfReplaceAll]);
  end;
begin
  s := '';
  s := '{"LastSession":{' ;
  // leftpage
  s := s + '"LeftPage":['+Enter;
  for i := 0 to LeftLabels.Count -1  do begin
    s := s + format(formatstr,[CStyleDir(LeftLabels.Get(i).Dir),BooleanToStr(LeftLabels.get(i).Active)]);
    if i <> LeftLabels.Count -1 then
      s := s + ','+Enter;
  end;
  s := s + '],'+Enter;
  // leftpage end
  // rightpage
  s := s + '"RightPage":['+Enter;
  for i := 0 to RightLabels.Count -1  do begin
    s := s + format(formatstr,[CStyleDir(RightLabels.Get(i).Dir),BooleanToStr(RightLabels.get(i).Active)]);
    if i <> RightLabels.Count -1 then
      s := s + ','+Enter;
  end;
  s := s + ']'+Enter;
  // leftpage end
  // rightpage  end
  s := s + '}}'+Enter;
  sl := TStringList.Create;
  try
    sl.Text := s ;
    sl.SaveToFile('abc.json');
  finally
    sl.Free ;
  end;
end;
procedure TecSession.SetLeftLabels(const Value: Teclabels);
begin
  FLeftLabels := Value;
end;

procedure TecSession.SetRightLabels(const Value: Teclabels);
begin
  FRightLabels := Value;
end;

{ Teclabels }

destructor Teclabels.Destroy;
var
  i : integer;
begin
  for i := 0 to Self.Count -1 do
    TecLabel(Items[i]).Free ;
  inherited;
end;

function Teclabels.Get(I: Integer): TecLabel;
begin
  Result := TecLabel(Items[I]);
end;

end.
