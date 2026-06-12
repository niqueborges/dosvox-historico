unit usapi;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, ACTIVEVOICEPROJECTLib_TLB;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    DirectSS1: TDirectSS;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);
    procedure DirectSS1TextDataDone(Sender: TObject; hi, lo,
      Flags: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  falando: boolean;
  nlin: integer;
  salvaVel: integer;
  primeira: boolean;
  ultNum: char;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var n, erro: integer;
begin
    if paramCount = 0 then
        begin
            showMessage ('Use minileit nomeArq [velocidade]');
            halt;
        end;

    if paramCount < 2 then
        n := 7
    else
        begin
            val (paramStr(2), n, erro);
            if erro <> 0 then n := 7;
        end;
    directSS1.Select (n);

    try
        listBox1.items.loadFromFile (paramStr(1));
    except
        showMessage ('Arquivo invalido');
        halt;
    end;

    nlin := 0;
    DirectSS1TextDataDone(self, 0, 0, 0);
    primeira := true;
end;

procedure TForm1.ListBox1KeyPress(Sender: TObject; var Key: Char);
var n, erro: integer;
begin
    case key of
        '0'..'9': begin
                      if primeira then
                          begin
                              DirectSS1.audioReset;
                              ultNum := key;
                              primeira := false;
                          end
                      else
                          begin
                              val (ultNum+key, n, erro);
                              directSS1.Select (n);
                              falando := true;
                              DirectSS1TextDataDone(self, 0, 0, 0);
                              primeira := true;
                          end;
                  end;

        '+':    begin
                    DirectSS1.audioReset;
                    falando := false;
                    nlin := nlin + 1;
                end;

        '-':    begin
                    DirectSS1.audioReset;
                    falando := false;
                    nlin := nlin - 1;
                end;

        '*':    begin
                  DirectSS1.audioReset;
                  falando := false;
                  nlin := 0;
                end;
        '/':    begin
                  DirectSS1.audioReset;
                  falando := false;
                  if DirectSS1.speed = DirectSS1.maxspeed then
                        DirectSS1.Speed := salvavel
                  else
                      begin
                          salvavel := DirectSS1.Speed;
                          DirectSS1.speed := DirectSS1.maxspeed;
                      end;
                end;

        ' ', #$0d: begin
                  DirectSS1.audioReset;
                  falando := not Falando;
                  if falando then
                      DirectSS1TextDataDone(self, 0, 0, 0);
              end;
        #$1b: close;
    end;
end;

procedure TForm1.DirectSS1TextDataDone(Sender: TObject; hi, lo,
  Flags: Integer);
begin
    while (nlin < listBox1.items.count-1) and
          (listBox1.items[nlin] = '') do
         nlin := nlin + 1;

    if (nlin < listBox1.items.count) then
       if listBox1.items[nlin] <> '' then
          DirectSS1.speak (listBox1.items[nlin]);

    nlin := nlin + 1;
end;

end.
