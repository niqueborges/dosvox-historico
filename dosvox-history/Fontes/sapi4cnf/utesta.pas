unit utesta;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  Tform_fala = class(TForm)
    e_testar: TEdit;
    b_fala: TButton;
    b_cancela: TButton;
    procedure b_falaClick(Sender: TObject);
    procedure b_cancelaClick(Sender: TObject);
    procedure e_testarKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  form_fala: Tform_fala;

implementation

uses usapi, ACTIVEVOICEPROJECTLib_TLB;
{$R *.dfm}

procedure Tform_fala.b_falaClick(Sender: TObject);
begin
    with MainForm.DirectSS1 do
        begin
            Speak(e_testar.text);
        end;
end;

procedure Tform_fala.b_cancelaClick(Sender: TObject);
begin
    close;
end;

procedure Tform_fala.e_testarKeyPress(Sender: TObject; var Key: Char);
begin
   if key = #$1b then close;
   if key = #$0d then b_falaClick(sender);
end;

end.
