unit uescolhedic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormEscolher = class(TForm)
    Label1: TLabel;
    e_nomedic: TEdit;
    Label2: TLabel;
    e_primPal: TEdit;
    Button2: TButton;
    Label3: TLabel;
    e_nomesuf: TEdit;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEscolher: TFormEscolher;

implementation

{$R *.dfm}

procedure TFormEscolher.Button2Click(Sender: TObject);
begin
    close;
end;

end.

