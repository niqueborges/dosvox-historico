unit usapi;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, ACTIVEVOICEPROJECTLib_TLB, StdCtrls, ExtCtrls;

type
  TMainForm = class(TForm)
    DirectSS1: TDirectSS;
    b_OK: TButton;
    b_acerca: TButton;
    b_config: TButton;
    b_lexicon: TButton;
    b_transl: TButton;
    Panel1: TPanel;
    b_velocidade: TButton;
    b_tonalidade: TButton;
    ComboBox1: TComboBox;
    b_info: TButton;
    b_testa: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure b_acercaClick(Sender: TObject);
    procedure b_configClick(Sender: TObject);
    procedure b_lexiconClick(Sender: TObject);
    procedure b_translClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure b_infoClick(Sender: TObject);
    procedure b_velocidadeClick(Sender: TObject);
    procedure b_tonalidadeClick(Sender: TObject);
    procedure b_OKClick(Sender: TObject);
    procedure b_testaClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  vozSelec, velocVoz, tomVoz: integer;

implementation

uses uformInfo, utesta;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
var i: integer;
    s: string;
begin
   with directSS1 do
       begin
           initialized := 1;
           for i := 1 to countEngines do
               begin
                   s := speaker(i);
                   if (s = 'Homem') or (s = 'Mulher') or
                      (pos ('Female', s) <> 0) or (pos ('Male', s) <> 0) then
                       s := modeName(i);
                   ComboBox1.Items.Add(intToStr(i) + ' - ' + s);
               end;
       end;
    ComboBox1.ItemIndex := 0;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
    ComboBox1Select(Sender);
end;

procedure TMainForm.b_acercaClick(Sender: TObject);
begin
    directSS1.AboutDlg (handle, 'Sobre este sintetizador');
end;

procedure TMainForm.b_configClick(Sender: TObject);
begin
    directSS1.GeneralDlg (handle, 'Configuração deste sintetizador');
end;

procedure TMainForm.b_lexiconClick(Sender: TObject);
begin
    directSS1.LexiconDlg (handle, 'Analisador léxico');
end;

procedure TMainForm.b_translClick(Sender: TObject);
begin
    directSS1.TranslateDlg (handle, 'Tradutor');
end;

function isBlank (p: pchar): boolean;
begin
    isBlank := true;
    if p = NIL then exit;
    while (p^ = ' ') do p := p + 1;
    if p^ <> #$0 then
        isBlank := false;
end;

procedure TMainForm.ComboBox1Select(Sender: TObject);
begin
    ComboBox1.text := comboBox1.Items[ComboBox1.ItemIndex];
    with directSS1  do
        try
            currentMode := ComboBox1.ItemIndex+1;
            vozSelec := currentMode;
            velocVoz := speed;
            tomVoz := pitch;
        except end;
end;

procedure TMainForm.b_infoClick(Sender: TObject);
var
    n: integer;
begin
    n := vozSelec;
    with directSS1, formInfo.memo1 do
        begin
            formInfo.memo1.ReadOnly := false;
            formInfo.memo1.clear;
            lines.Add(Speaker (n));
            lines.Add('Modo: ' + ModeName (n));
            lines.Add('Velocidade entre ' + intToStr (minSpeed) + ' e ' + intToStr (maxSpeed));
            lines.Add('Tonalidade entre ' + intToStr (minPitch) + ' e ' + intToStr (maxPitch));
            lines.Add('Fabricante: ' + MfgName (n));
            lines.Add('Produto: ' + ProductName (n));
            lines.Add('Estilo: ' + Style (n));
            lines.Add('Dialeto: ' + Dialect (n));
            // lines.Add(ModeID (n));
            // lines.Add(EngineID (n));
            formInfo.memo1.ReadOnly := true;
            formInfo.Memo1.SelStart := 0;
            formInfo.Memo1.selLength := 0;
        end;
    formInfo.ShowModal;
end;

procedure TMainForm.b_velocidadeClick(Sender: TObject);
var
  titulo, novoValor: string;
begin
  novoValor := intToStr (velocVoz);
  titulo := 'Velocidade, entre ' + intToStr(directSS1.minSpeed) + ' e ' +
                                   intToStr(directSS1.maxSpeed);
  if InputQuery(titulo, 'Novo valor', novoValor) then
      begin
          velocVoz := strToInt (novoValor);
          directSS1.Speed := velocVoz;
          velocVoz := directSS1.Speed;
      end;
end;

procedure TMainForm.b_tonalidadeClick(Sender: TObject);
var
  titulo, novoValor: string;
begin
  novoValor := intToStr (velocVoz);
  titulo := 'Tonalidade, entre ' + intToStr(directSS1.MinPitch) + ' e ' +
                                   intToStr(directSS1.maxPitch);
  if InputQuery(titulo, 'Novo valor', novoValor) then
      begin
          tomVoz := strToInt (novoValor);
          directSS1.Pitch := tomVoz;
          tomVoz := directSS1.Pitch;
      end;
end;

procedure TMainForm.b_OKClick(Sender: TObject);
begin
    if MessageDlg('Guarda configuração no DOSVOX.INI?',
         mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
            writePrivateProfileString('TRADUTOR', 'SAPI', 'SIM', 'DOSVOX.INI');
            writePrivateProfileString('SERVFALA', 'TIPOSAPI', '4', 'DOSVOX.INI');
            writePrivateProfileString('SERVFALA', 'VOZ', pchar(vozSelec), 'DOSVOX.INI');
            writePrivateProfileString('SERVFALA', 'VELOCIDADE', pchar(velocVoz), 'DOSVOX.INI');
            writePrivateProfileString('SERVFALA', 'TOM', pchar(tomVoz), 'DOSVOX.INI');
        end;
    close;
end;


procedure TMainForm.b_testaClick(Sender: TObject);
begin
    with directSS1 do
        begin
            CurrentMode := vozSelec;
            Speed := velocVoz;
            Pitch := tomVoz;
        end;

    form_fala.showModal;
end;

end.
