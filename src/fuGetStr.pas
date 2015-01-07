unit fuGetStr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmGetStr = class(TForm)
    edt1: TEdit;
    btn1: TButton;
    btn2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmGetStr: TfmGetStr;
function GetStrForm(str:string;title:string):String;
implementation

{$R *.dfm}
function GetStrForm(str : string;title:string):String;
begin
   result := '';
   fmGetStr:= TfmGetStr.Create(nil);

   with fmGetStr do try
     edt1.Text := str ;
     caption := title ;
     if ShowModal =mrok then
      result := edt1.Text ;
   finally
     free ;
   end;
end;
end.
