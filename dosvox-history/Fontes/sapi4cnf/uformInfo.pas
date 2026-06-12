unit uformInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormInfo = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormInfo: TFormInfo;

implementation

{$R *.dfm}

procedure TFormInfo.Button1Click(Sender: TObject);
begin
   close;
end;

end.
