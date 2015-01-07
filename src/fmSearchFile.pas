{from jvcl 'demo }

unit fmSearchFile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask,
  ComCtrls, Menus,JvSearch;

type
  TJvSearchFileMainForm = class(TForm)
    GroupBox1: TGroupBox;
    btnSearch: TButton;
    Label1: TLabel;
    chkRecursive: TCheckBox;
    Label2: TLabel;
    edFileMask: TEdit;
    GroupBox2: TGroupBox;
    btnCancel: TButton;
    StatusBar1: TStatusBar;
    chkClearList: TCheckBox;
    chkNoDupes: TCheckBox;
    cbContainText: TComboBox;
    rbInclude: TRadioButton;
    rbExclude: TRadioButton;
    reFoundFiles: TListBox;
    edtJvDirectoryBox1: TEdit;
    btnExit: TButton;
    btnLocateFile: TButton;
    procedure btnSearchClick(Sender: TObject);
    procedure JvSearchFile1FindFile(Sender: TObject; const AName: string);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvSearchFile1BeginScanDir(Sender: TObject;
      const AName: String);
    procedure OptionsChange(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure JvSearchFile1Progress(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnLocateFileClick(Sender: TObject);
  private
    { Private declarations }
    JvSearchFile1 : TJvSearchFiles ;
    procedure AddSearchTextToComboBox;
  end;

var
  JvSearchFileMainForm: TJvSearchFileMainForm;
function ShowSearchFiles (currdir : String):String;
implementation

{$R *.DFM}
function ShowSearchFiles (currdir : String):string;
  function GetSelectStr(List : TListBox):String ;
  var
    i: Integer;
  begin
    for i := 0 to (List.Items.Count - 1) do begin
       if list.Selected[i] then begin
         Result := list.Items[i];
         exit;
       end;
    end;
    Result := '';
  end;
begin
  JvSearchFileMainForm:= TJvSearchFileMainForm.Create(nil);
  with JvSearchFileMainForm do
  try
    edtJvDirectoryBox1.Text := currdir ;
    if mrYes = ShowModal then
      result := GetSelectStr(reFoundFiles)
  finally
    Free;
  end;  
end;
procedure TJvSearchFileMainForm.btnSearchClick(Sender: TObject);
begin
  btnSearch.Enabled := false;
  btnCancel.Enabled := true;
  Screen.Cursor := crHourGlass;
  try
    if chkClearList.Checked then
      reFoundFiles.Items.Clear;
    AddSearchTextToComboBox;
    JvSearchFile1.Files.Clear;
    JvSearchFile1.Directories.Clear;
    JvSearchFile1.FileParams.FileMasks.Text := edFileMask.Text;
    if chkRecursive.Checked then
      JvSearchFile1.DirOption := doIncludeSubDirs
    else
      JvSearchFile1.DirOption := doExcludeSubDirs;
    // don't store file and folder names - we do that in the memo
    JvSearchFile1.Options := JvSearchFile1.Options + [soOwnerData];
    JvSearchFile1.RootDirectory := edtJvDirectoryBox1.Text;
    JvSearchFile1.Search;
  finally
    StatusBar1.Panels[0].Text := Format('(%d matching items found)',[reFoundFiles.Items.Count]);
    btnSearch.Enabled := true;
    btnCancel.Enabled := false;
    Screen.Cursor := crDefault;
  end;
end;

function ContainsText(const Filename,AText:string):boolean;
var S:TMemoryStream;tmp:string;
begin
  Result := false;
  S := TMemoryStream.Create;
  try
    S.LoadFromFile(Filename);
    if S.Memory <> nil then
    begin
      tmp := PChar(S.Memory);
      tmp := AnsiLowerCase(tmp);
      Result := Pos(AnsiLowerCase(AText),tmp) > 0;
    end;
  finally
    S.Free;
  end;
end;

procedure TJvSearchFileMainForm.JvSearchFile1FindFile(Sender: TObject;
  const AName: string);
begin
  StatusBar1.Panels[0].Text := Format('Searching in %s...',[AName]);
  StatusBar1.Update;
  if (cbContainText.Text <> '') then
    if rbInclude.Checked <> ContainsText(AName,cbContainText.Text) then
      Exit;
  if not chkNoDupes.Checked or (reFoundFiles.Items.IndexOf(AName) < 0) then
    reFoundFiles.Items.Add(AName);
end;

procedure TJvSearchFileMainForm.btnCancelClick(Sender: TObject);
begin
  JvSearchFile1.Abort;
  btnCancel.Enabled := false;
end;

procedure TJvSearchFileMainForm.FormCreate(Sender: TObject);
begin
  JvSearchFile1 := TJvSearchFiles.Create(Self) ;
  JvSearchFile1.OnBeginScanDir :=  JvSearchFile1BeginScanDir ;
  JvSearchFile1.OnFindFile := JvSearchFile1FindFile ;
  JvSearchFile1.OnProgress := JvSearchFile1Progress;
  JvSearchFile1.FileParams.SearchTypes := [stFileMask]
end;

procedure TJvSearchFileMainForm.JvSearchFile1BeginScanDir(Sender: TObject;
  const AName: String);
begin
  StatusBar1.Panels[0].Text := Format('Searching in %s...',[ExcludeTrailingPathDelimiter(AName)]);
  StatusBar1.Update;
end;

procedure TJvSearchFileMainForm.OptionsChange(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := 'Ready';
  StatusBar1.Update;
end;

procedure TJvSearchFileMainForm.Sort1Click(Sender: TObject);
var S:TStringlist;
begin
  S := TStringlist.Create;
  try
   S.Assign(reFoundFiles.Items);
   S.Sort;
   while (S.Count > 0) and (S[0] = '') do S.Delete(0);
   reFoundFiles.Items := S;
  finally
    S.Free;
  end;
end;

procedure TJvSearchFileMainForm.Clear1Click(Sender: TObject);
begin
  reFoundFiles.Clear;
end;

procedure TJvSearchFileMainForm.AddSearchTextToComboBox;
begin
  with cbContainText do
    if (Text <> '') and (Items.IndexOf(Text) < 0) then
        Items.Add(Text);
end;

procedure TJvSearchFileMainForm.JvSearchFile1Progress(Sender: TObject);
begin
  Application.ProcessMessages;
end;

procedure TJvSearchFileMainForm.btnExitClick(Sender: TObject);
begin
  JvSearchFile1.Abort;
  ModalResult := mrCancel ;
end;

procedure TJvSearchFileMainForm.btnLocateFileClick(Sender: TObject);
begin
  ModalResult := mrYes ;
  
end;

end.

