unit CommandMenu;

interface
uses classes ,ActnList;
type
  TMenuCommand = (
    // File
    cmChangeDir,
    cmCopyFilePathToClp,
    cmRoot,
    cmUpdir,
    cmDowndir,
    cmListDrivers,
    cmExecute,
    cmSearch,
    cmCopy,
    cmMove,
    cmDelete,
    cmTogglePanel,
    // System
    cmDosPrompt,
    cmOpenFolder,
    // Label
    cmNew,
    cmClose,
    cmSwitchLeftRight
    );
type
  TCommand =  class
   private
    FCaption: String;
    FShortcut: TShortcut;
    FCommand: TMenuCommand;
    FOnClick: TNotifyEvent;
    procedure SetCaption(const Value: String);
    procedure SetShortcut(const Value: TShortcut);
    procedure SetCommand(const Value: TMenuCommand);
    procedure SetOnClick(const Value: TNotifyEvent);
   public
     property Caption : String  read FCaption write SetCaption;
     property Command : TMenuCommand read FCommand write SetCommand;
     property Shortcut : TShortcut  read FShortcut write SetShortcut;
     property OnClick: TNotifyEvent  read FOnClick write SetOnClick;
   end;
   TCommandList=  class(TList)
   private
    FOnClick: TNotifyEvent;
    procedure SetOnClick(const Value: TNotifyEvent);
    public
      procedure AddCommand(Caption: string; Command: TMenuCommand;
        OnClick: TNotifyEvent; ShortCut: TShortCut);overload ;
     constructor Create ;reintroduce;
     procedure AddCommand(Caption:string ;OnClick :TNotifyEvent;ShortCut :TShortCut) ;overload ;

     function GetCommand(I :Integer):TCommand;

   end;
type
  TecAction = class(TAction)
  private
    FCmd: TCommand;
    procedure SetCmd(const Value: TCommand);
    public
      property Cmd :TCommand   read FCmd write SetCmd;
  end;
implementation

{ TCatalogList }


{ TCommandList }




procedure TCommandList.AddCommand(Caption: string;OnClick: TNotifyEvent;ShortCut :TShortCut);
var
  cmd :TCommand ;
begin
   cmd := TCommand.Create ;
   //cmd.Command := Command ;
   cmd.Caption := Caption;
   cmd.OnClick := OnClick ;
   cmd.Shortcut := ShortCut ;
   Add(cmd);
end;
procedure TCommandList.AddCommand(Caption: string;Command : TMenuCommand;OnClick: TNotifyEvent;ShortCut :TShortCut);
var
  cmd :TCommand ;
begin
   cmd := TCommand.Create ;
   cmd.Command := Command ;
   cmd.Caption := Caption;
   cmd.OnClick := OnClick ;
   cmd.Shortcut := ShortCut ;
   Add(cmd);
end;
constructor TCommandList.Create;
begin
  inherited;
end;


function TCommandList.GetCommand(I: Integer): TCommand;
begin
  Result := TCommand(Items[i]);
end;

procedure TCommandList.SetOnClick(const Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

{ TCommand }

procedure TCommand.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TCommand.SetCommand(const Value: TMenuCommand);
begin
  FCommand := Value;
end;

procedure TCommand.SetOnClick(const Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

procedure TCommand.SetShortcut(const Value: TShortcut);
begin
  FShortcut := Value;
end;

{ TecAction }


{ TecAction }

procedure TecAction.SetCmd(const Value: TCommand);
begin
  FCmd := Value;
end;

end.
