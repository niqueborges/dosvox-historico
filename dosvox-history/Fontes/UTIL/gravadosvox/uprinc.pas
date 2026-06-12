unit uprinc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, dvgrav, mmSystem;

type
    TIPO_CORTE = (CORTA_INICIO, CORTA_FIM, ADICIONA_INICIO, ADICIONA_FIM);

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    b_proximo: TButton;
    b_anterior: TButton;
    ListBox1: TListBox;
    b_gravar: TButton;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Carregarbase1: TMenuItem;
    Sair1: TMenuItem;
    l_nomeArq: TLabel;
    l_difo: TLabel;
    b_tocar: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    l_conta: TLabel;
    l_nomeDB: TLabel;
    Timer1: TTimer;
    b_diretorio: TButton;
    Amostra1: TMenuItem;
    Prxima1: TMenuItem;
    Anterior1: TMenuItem;
    ocar1: TMenuItem;
    Gravar1: TMenuItem;
    Image1: TImage;
    b_cortaInicio: TButton;
    b_adicfim: TButton;
    b_adicInicio: TButton;
    b_cortaFim: TButton;
    maisVol50: TButton;
    menosVol25: TButton;
    maisVol100: TButton;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    procedure Carregarbase1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure b_anteriorClick(Sender: TObject);
    procedure b_proximoClick(Sender: TObject);
    procedure b_tocarClick(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure b_gravarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DiretorioClick(Sender: TObject);
    procedure Anterior1Click(Sender: TObject);
    procedure Prxima1Click(Sender: TObject);
    procedure tocar1Click(Sender: TObject);
    procedure Gravar1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure b_cortaInicioClick(Sender: TObject);
    procedure b_adicInicioClick(Sender: TObject);
    procedure b_adicfimClick(Sender: TObject);
    procedure b_cortaFimClick(Sender: TObject);
    procedure b_cortaInicioKeyPress(Sender: TObject; var Key: Char);
    procedure b_cortaFimKeyPress(Sender: TObject; var Key: Char);
    procedure menosVol25Click(Sender: TObject);
    procedure maisVol50Click(Sender: TObject);
    procedure maisVol100Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    procedure EixoGrafico;
    procedure MostraGrafico;
    procedure cortaAdiciona (opcao: TIPO_CORTE);
    procedure volumeSom (percentual: real);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

type
    TDifone = record
        d1: string;
        d2: string;
        nomeWav: string;
        nome: string;
        v1: string;
        v2: string;
        v3: string;
    end;

var nomeBase: string;
    freq: string;
    tabDifones: array [1..5000] of TDifone;
    nDifones: integer;
    indice: integer;
    dir: string;
    gravando: boolean;


procedure TForm1.Carregarbase1Click(Sender: TObject);

var s: string;
var arq: textFile;

    procedure extrai (var x: string);
    begin
         x := '';
         while (s <> '') and ((s[1] = ' ') or (s[1] = #$09)) do
             delete (s, 1, 1);

         while (s <> '') and ((s[1] <> ' ') and (s[1] <> #$09)) do
             begin
                 x := x + s[1];
                 delete (s, 1, 1);
             end;
    end;

begin
    if OpenDialog1.Execute then
        begin
            nomeBase := OpenDialog1.FileName;
            reset (arq, nomeBase);
            if length (nomebase) < 20 then
                l_nomeDb.Caption := nomeBase
            else
                l_nomeDb.Caption := '...' + copy (nomeBase, length(nomeBase)-19, 20);

            dir := ExtractFileDir(nomeBase);
            if dir [length(dir)] <> '\' then dir := dir + '\';

            readln (arq, freq);
            ndifones := 0;
            while not eof (arq) do
                begin
                    readln (arq, s);
                    if s = '' then continue;
                    ndifones := ndifones + 1;
                    with tabDifones[nDifones] do
                        begin
                            extrai (nomeWav);
                            if pos ('.WAV', ansiUpperCase (nomeWav)) = 0 then
                                nomeWav := nomeWav + '.WAV';
                            nome := trim(s);
                            listBox1.Items.Add(nome);
                        end;
                end;

            l_conta.caption := intToStr(nDifones) + ' difones';
            closeFile (arq);
        end;

end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
    if gravando then b_gravarClick(Sender);
    if listBox1.count = 0 then exit;
    indice := ListBox1.ItemIndex + 1;
    if indice < 1 then exit;
    Panel1.Caption := tabDifones[indice].nome;
    l_nomeArq.Caption := tabDifones[indice].nomeWav;
    l_difo.Caption := tabDifones[indice].d1 + ' ' + tabDifones[indice].d2;
    mostraGrafico;
end;

procedure TForm1.b_anteriorClick(Sender: TObject);
begin
   if gravando then b_gravarClick(Sender);
   if listBox1.count = 0 then exit;
   if ListBox1.ItemIndex >= 0 then
       begin
           ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
           ListBox1Click(Sender);
           b_tocarClick(sender);
       end;
end;

procedure TForm1.b_proximoClick(Sender: TObject);
begin
   if gravando then b_gravarClick(Sender);
   if listBox1.count = 0 then exit;
   if ListBox1.ItemIndex < listBox1.count then
       begin
           ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
           ListBox1Click(Sender);
           b_tocarClick(sender);
       end;
end;

procedure TForm1.b_tocarClick(Sender: TObject);
var p: array [0..255] of char;
begin
    if gravando then b_gravarClick(Sender);
    if listBox1.itemIndex < 0 then exit;
    strPcopy (p, dir+tabDifones[listBox1.itemIndex+1].nomeWav);
    sndPlaySound(p, snd_Async)
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
    b_tocarClick(Sender);
end;

procedure TForm1.b_gravarClick(Sender: TObject);
begin
    if listBox1.itemIndex < 0 then exit;
    if gravando then
        begin
            gravando := false;
            timer1.Enabled := false;
            monitoraGravacao;
            terminaGravacao;
            b_gravar.Caption := '&Gravar';
            MostraGrafico;
        end
    else
    if preparaGravacao(dir+tabDifones[listBox1.itemIndex+1].nomeWav,
         22050, 16, 1, 4, 4096) = 0 then
        begin
            b_gravar.Caption := 'gravando';
            timer1.Enabled := true;
            b_gravar.Caption := 'Fim &Grav';
            gravando := true;
            iniciaGravacao;
        end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    monitoraGravacao;
end;

procedure TForm1.DiretorioClick(Sender: TObject);
var cmd: string;
begin
    cmd := 'explorer ' + dir;
    winExec (pchar (@cmd[1]), SW_SHOWNORMAL);
end;

procedure TForm1.Anterior1Click(Sender: TObject);
begin
    b_anteriorClick(Sender);
end;

procedure TForm1.Prxima1Click(Sender: TObject);
begin
    b_proximoClick(Sender);
end;

procedure TForm1.tocar1Click(Sender: TObject);
begin
    b_tocarClick(Sender);
end;

procedure TForm1.Gravar1Click(Sender: TObject);
begin
   b_gravarClick(Sender);
end;

procedure TForm1.EixoGrafico;
var rect: TRect;
begin
   with image1 do
       begin
           canvas.pen.color := clRed;
           rect.Left := 0;
           rect.Top := 0;
           rect.Right := width-1;
           rect.Bottom := height-1;
           canvas.FillRect (rect);
           Canvas.MoveTo(0, height div 2);
           canvas.LineTo(width, height div 2);
           canvas.pen.color := clBlack;
       end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
    EixoGrafico;
end;

procedure TForm1.MostraGrafico;
var nomeSom: string;
    arqSom: file;
    buf: array [0..255] of smallInt;
    lidos: integer;
    max, min: smallInt;
    ampl: real;
    i, x: integer;
begin
    EixoGrafico;
    if listBox1.itemIndex < 0 then exit;
    nomeSom := dir+tabDifones[listBox1.itemIndex+1].nomeWav;

    ampl := image1.height / 65000.0;
    assignFile (arqSom, nomeSom);
    {$I-} reset (arqSom, 1);  {$I+}
    if ioresult = 0 then
        begin
            seek (arqSom, 44);
            x := 0;
            while not eof (arqSom) do
                begin
                    blockread (arqSom, buf, 512, lidos);
                    max := 0;
                    for i := 0 to (lidos div 2) - 1 do
                        if buf[i] > max then max := buf[i];
                    min := 0;
                    for i := 0 to (lidos div 2) - 1 do
                        if buf[i] < min then min := buf[i];
                    image1.canvas.moveto (x, image1.height-1-trunc ((min+32768) * ampl));
                    image1.canvas.lineto (x, image1.height-1-trunc ((max+32768) * ampl));
                    if trunc ((min+32768) * ampl) = trunc ((max+32768) * ampl) then
                        image1.canvas.lineto (x, image1.height-trunc ((max+32768) * ampl));

                    x := x + 1;
                end;
            closeFile (arqSom);
        end;
end;


procedure TForm1.cortaAdiciona (opcao: TIPO_CORTE);
var nomeSom: string;
    arqSom, arqSom2: file;
    buf: array [0..127] of smallInt;
    lidos: integer;
    wavHdr: array [0..43] of byte;
    p: ^longint;
    tamSom, aLer: integer;

begin
    if listBox1.itemIndex < 0 then exit;
    nomeSom := dir+tabDifones[listBox1.itemIndex+1].nomeWav;

    assignFile (arqSom, nomeSom);
    assignFile (arqSom2, '_____.wav');
    {$I-} reset (arqSom, 1);  {$I+}
    if ioresult = 0 then
        begin
            rewrite (arqSom2, 1);

            blockRead (arqSom, wavHdr, 44);    { acerta o cabecalho }
            if (opcao = CORTA_INICIO) or (opcao = CORTA_FIM) then
                begin
                    p := @wavHdr[4];    p^ := p^ - 256;
                    p := @wavHdr[40];   p^ := p^ - 256;
                end
            else
                begin
                    p := @wavHdr[4];    p^ := p^ + 256;
                    p := @wavHdr[40];   p^ := p^ + 256;
                end;

            blockWrite (arqSom2, wavHdr, 44);

            if opcao = CORTA_INICIO then
                blockRead (arqSom, buf, 256)   { ignora um pedaço }
            else
            if opcao = ADICIONA_INICIO then
                begin
                    fillchar (buf, 256, 0);
                    blockWrite (arqSom2, buf, 256);
                end;

            tamSom := fileSize (arqSom) - filePos (arqSom);
            if opcao = CORTA_FIM then
                tamSom := tamSom - 256;

            while (tamSom > 0) and (not eof (arqSom)) do
                begin
                    if tamSom <= 256 then aler := tamSom
                                     else aLer := 256;
                    blockread (arqSom, buf, aler, lidos);
                    blockwrite (arqSom2, buf, lidos);
                    tamSom := tamSom - 256;
                end;

            if opcao = ADICIONA_FIM then
                begin
                    fillchar (buf, 256, 0);
                    blockWrite (arqSom2, buf, 256);
                end;

            closeFile (arqSom);
            closeFile (arqSom2);
            erase (arqSom);
            rename (arqSom2, nomeSom);
        end;

    mostraGrafico;
end;

procedure TForm1.b_cortaInicioClick(Sender: TObject);
begin
    cortaAdiciona (CORTA_INICIO);
end;

procedure TForm1.b_adicInicioClick(Sender: TObject);
begin
    cortaAdiciona (ADICIONA_INICIO);
end;

procedure TForm1.b_adicfimClick(Sender: TObject);
begin
    cortaAdiciona (ADICIONA_FIM);
end;

procedure TForm1.b_cortaFimClick(Sender: TObject);
begin
    cortaAdiciona (CORTA_FIM);
end;

procedure TForm1.b_cortaInicioKeyPress(Sender: TObject; var Key: Char);
begin
    if key = #$08 then
        b_cortaInicioClick (Sender);
end;

procedure TForm1.b_cortaFimKeyPress(Sender: TObject; var Key: Char);
begin
    if key = #$08 then
        b_cortaFimClick (Sender);
end;

procedure TForm1.volumeSom (percentual: real);
var nomeSom: string;
    arqSom, arqSom2: file;
    buf: array [0..127] of smallInt;
    lidos: integer;
    wavHdr: array [0..43] of byte;
    i, tamSom, aLer: integer;
    conseguiu: boolean;

begin
    if listBox1.itemIndex < 0 then exit;
    nomeSom := dir+tabDifones[listBox1.itemIndex+1].nomeWav;

    assignFile (arqSom, nomeSom);
    assignFile (arqSom2, '_____.wav');
    {$I-} reset (arqSom, 1);  {$I+}
    if ioresult = 0 then
        begin
            rewrite (arqSom2, 1);
            blockRead (arqSom, wavHdr, 44);    { acerta o cabecalho }
            blockWrite (arqSom2, wavHdr, 44);

            tamSom := fileSize (arqSom) - filePos (arqSom);
            conseguiu := true;
            while (tamSom > 0) and (not eof (arqSom)) do
                begin
                    if tamSom <= 256 then aler := tamSom
                                     else aLer := 256;
                    blockread (arqSom, buf, aler, lidos);
                    try
                        for i := 0 to (lidos div 2)-1 do
                            buf[i] := trunc(buf[i] * percentual);
                    except
                        if conseguiu then
                            showMessage ('Não dá');
                        conseguiu := false;
                        percentual := 1.0;
                    end;
                    blockwrite (arqSom2, buf, lidos);
                    tamSom := tamSom - 256;
                end;

            closeFile (arqSom);
            closeFile (arqSom2);
            if conseguiu then
                begin
                    erase (arqSom);
                    rename (arqSom2, nomeSom);
                end
            else
                erase (arqSom2);
        end;

    mostraGrafico;
end;

procedure TForm1.menosVol25Click(Sender: TObject);
begin
    volumeSom (0.7);
end;

procedure TForm1.maisVol50Click(Sender: TObject);
begin
    volumeSom (1.5);
end;

procedure TForm1.maisVol100Click(Sender: TObject);
begin
    volumeSom (2.0);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
    cortaAdiciona (CORTA_INICIO);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
    cortaAdiciona (CORTA_FIM);
end;

procedure TForm1.Sair1Click(Sender: TObject);
begin
    close;
end;

procedure TForm1.Button3Click(Sender: TObject);
var i: integer;
begin
    for i := 1 to 50 do
        cortaAdiciona (CORTA_INICIO);
end;

end.
