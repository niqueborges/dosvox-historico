unit ppmssg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,pptgeral, MPlayer;

type
  Tppmsg = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ppmsg: Tppmsg;

implementation

{$R *.dfm}

procedure Tppmsg.FormPaint(Sender: TObject);
begin
   TocaWav ('ppconfim');
end;

end.
