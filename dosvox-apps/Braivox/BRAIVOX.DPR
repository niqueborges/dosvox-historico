{--------------------------------------------------------}
{
{    Programa de impressao braille
{
{    Autor: Jose' Antonio Borges
{
{    Em 1994/95
{
{--------------------------------------------------------}

program BraiVox;
uses
  dvCrt,
  dvWin,
  dvAmplia,
  windows,
  sysutils,
  dvarq,
  brVars,
  brMsg,
  brConfig,
  brImprim,
  brutil,
  brdevice;

{--------------------------------------------------------}

function pegaNomeArq: string;
var nomeArq: string;
begin
    if paramCount >= 1 then
        begin
            nomeArq := paramStr(1);
            while (nomeArq <> '') and (nomeArq[1] = ' ') do  delete (nomeArq, 1, 1);
        end
    else
        begin
            while keypressed do readkey;
            if wherey <= amplFator then
                gotoxy (1, amplFator+1);
            mensagem ('BRNOMARQ', 0);  {'Digite o nome do arquivo a imprimir: '}
            nomeArq := obtemNomeArq (15);
            if nomeArq = '' then
                begin
                    writeln;
                    mensagem ('BRFIMTRA', 1);  {'Fim de trabalho'}
                    sintFim;
                    doneWinCrt;
                end;
        end;

    pegaNomeArq := nomeArq;
    setWindowText (crtWindow, pchar('BRAIVOX ' + nomeArq));
end;

{--------------------------------------------------------}
{          inicializacao e abertura de arquivos
{--------------------------------------------------------}

procedure inicializa;
var resp, c, c2: char;
label fim;
begin
    sintInic (0, sintambiente ('BRAIVOX', 'DIRBRAIVOX'));

    clrscr;
    setWindowText (crtWindow, 'BRAIVOX');
    delay (200);

    mensagem ('BRINTRO', 0);    {'Programa de impressão Braille - v ...'}
    write (versao);
    sintSoletra (versao);
    if beta then sintWrite (' beta');
    writeln;
    writeln;

    nomeArq := pegaNomeArq;
    writeln (nomeArq);

    assign (arq, nomearq);
    {$i-}  reset (arq);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('BRARQNAO', 1);    {'Arquivo não foi achado'}
            goto fim;
        end;
    close (arq);

    assumeParamDefaults;

    mensagem ('BRPADRAO', 0);   {'Assumo valores padrão (s/n) ? '}
    sintLeTecla (resp, c2);
    writeln;
    if (resp <> '') and (upcase (resp) = 'N') then
        pedeParametros;

    if nomeSai = '' then nomeSai := 'LPT1';

    writeln;
    mensagem ('BRESCCAN', 1);   {'ENTER continua, ESC cancela'}
    repeat
        c := readkey;
    until c in [ENTER, ESC];
    if c = ESC then goto fim;
    writeln;

    sobraAnterior := '';
    exit;

fim:
    mensagem ('BRIMPCAN', 1);  {'Impressão cancelada.'}
    delay (2000);
    sintBip;
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

var i: integer;
begin
    inicializa;

    if not abreDispositivo (nomeSai) then
        begin
            mensagem ('BRERRCRI', 1);
                    {'Erro ao criar arquivo de impressão.  Programa cancelado.'}
            exit;
        end;

    for i := 1 to ncopias do
        begin
            reset (arq, 1);
            impressao;
            close (arq);

            mensagem ('BRFIMCOP', 1);    {'Fim de impressão da copia '}
            if ncopias <> 1 then
                sintWriteInt (i);
            writeln;

            if i < ncopias then reset (arq);
        end;

    fechaDispositivo;
    mensagem ('BRFIMTRA', 1);    {'Fim de trabalho'}

    delay (2000);
    while sintFalando do;
    sintFim;
    doneWinCrt;
end.
