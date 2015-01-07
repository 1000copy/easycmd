unit UserAndPass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmUserAndPassword = class(TForm)
    edt1: TEdit;
    edt2: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    btn1: TButton;
    btn2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmUserAndPassword: TfmUserAndPassword;
function GetUserAndPass(var U,P : string;title:string):Boolean ;
implementation

{$R *.dfm}
  function GetUserAndPass(var U,P : string;title:string):Boolean ;
  begin
    Result := false ;
    fmUserAndPassword:= TfmUserAndPassword.Create(nil);
    fmUserAndPassword.edt2.PasswordChar := '*';
    fmUserAndPassword.edt2.Text := '';
    fmUserAndPassword.Caption := title ;
    fmUserAndPassword.edt1.Text := '';
    try
      if mrOk = fmUserAndPassword.ShowModal then begin
        u := fmUserAndPassword.edt1.Text ;
        p := fmUserAndPassword.edt2.Text ;
        Result := True ;
      end
    finally
      fmUserAndPassword.Free ;
    end;
  end;
end.
