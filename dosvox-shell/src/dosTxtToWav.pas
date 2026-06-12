{----------------------------------------------------------------}
{
{    Transcritor de texto para wav
{
{    Autor: Neno Henrique da Cunha Albernaz
{    Em 30/9/2018
{
{----------------------------------------------------------------}

unit dosTxtToWav;

interface

uses
    dvcrt,
    dvWin,
    windows,
    sysutils,
    classes,
    dvSapi,
    dosmsg;

function converterTxtToWav (nomeArq: string): boolean;

implementation

var
    arq: file;
    bufArq: array [0..1023] of char;
    pbufArq, lidosBuf: integer;
    fimDoArq: boolean;
    pendente: string;

{----------------------------------------------------------------}
{       acumula frases durante a fala
{----------------------------------------------------------------}

procedure acumulaTexto (s: string);
begin
    s := trim (s);
    if s = '' then
        begin
            if pendente <> '' then
                begin
                     sintetiza (pendente);
                     while sintFalando do waitMessage;
                end;
            pendente := '';
            exit;
        end;

    s := ' ' + s + ' ';
    while s <> '' do
        begin
            pendente := pendente + s[1];
            if (copy (s, 1, 2) = '. ')
                or (copy (s, 1, 2) = '? ')
                or (copy (s, 1, 2) = '! ')
                or ((length (pendente) > 200) and (s[1] = ' ')) then
                    begin
                        sintetiza (pendente);
                        while sintFalando do waitMessage;
                        pendente := '';
                    end;

            delete (s, 1, 1);
        end;

    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}

procedure devolveCaracArq (c: char);
begin
   pbufArq := pbufArq - 1;
end;

{--------------------------------------------------------}

function pegaCaracArq: char;
begin
    if pbufArq >= lidosBuf then
         begin
             {$I-} blockread (arq, bufArq, 1024, lidosBuf);  {$i+}
             pbufArq := 0;

             if ioresult <> 0 then
                 begin
                     sintetiza ('Erro de leitura do arquivo.');
                     pegaCaracArq := #$0d;
                     fimDoArq := true;
                     exit;
                 end;
         end;

    pegaCaracArq := bufArq [pBufArq];
    pbufArq := pbufArq + 1;
    fimDoArq := (pBufArq >= lidosBuf) and eof (arq);
end;

{--------------------------------------------------------}

procedure inicBuffer;
begin
    pbufArq := 9999;
    lidosBuf := 0;
    devolveCaracArq (pegaCaracArq);
    fimDoArq := eof (arq) and (pBufArq >= lidosBuf);
end;

{--------------------------------------------------------}

function carregaUmaLinha (comTabs, comQuebraPag: boolean; var arq: file) : string;
var s: string;
    c: char;
    fimDaLinha: boolean;
begin
    fimDaLinha := false;
    s := '';

    repeat
        c := pegaCaracArq;

        if (c = #$0d) or (c = #$0a) then
            fimDaLinha := true
        else
            if (c = #9) and (not comTabs) then   // caractere tab horizontal é substituído por oito espaços se o padrão for usado
                s := s + '        '
            else
                if (c in [#0..#8, #10, #13..#31]) or ((c = #11) and (not comTabs)) or ((c = #12) and (not comQuebraPag)) then
                    s := s + '#'
                else
                    s := s + c;

    until fimDaLinha or fimDoArq;

    if (not fimDoArq) and (c = #$0d) then
        begin
            c := pegaCaracArq;
            if c <> #$0a then
                devolveCaracArq (c);
        end;

    carregaUmaLinha := s;
end;

{--------------------------------------------------------}

function  fazCargaDoArquivo: boolean;
var
    c: char;
    s: string;
    comTabs, comQuebraPag: boolean;
Begin
    fazCargaDoArquivo := true;
    comTabs := (sintAmbiente ('EDIVOX', 'CARACTERESTAB') + 'N') = 'S'; // por padrão "CARACTERESTAB" é igual a "NÃO"
    comQuebraPag := (sintAmbiente ('EDIVOX', 'CARACTEREQUEBRAPAG') + 'N') = 'S'; // por padrão "CARACTEREQUEBRAPAG" é igual a "NÃO"
    While not fimDoArq do
        begin
            if keyPressed then
                begin
                    c := readkey;
                    if c = ESC then
                        begin
                            fazCargaDoArquivo := false;
                            break
                        end
                    else sintclek;
                end;

            s := carregaUmaLinha (comTabs, comQuebraPag, arq);
            acumulaTexto (s);
        end;

    acumulaTexto (''); //Grava último bloco Quando o texto não termina por pontuação e nem linha em branco.
    {$i-} close (arq); {$i+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}

function processa (nomeArq: string): boolean;
begin
    processa := false;
    assign (arq, nomeArq);
    {$i-} reset (arq, 1); {$i+}
    if ioresult <> 0 then
        begin
Sintetiza ('Erro ao abrir o arquivo: ' + nomeArq);
            exit;
        end;

    inicBuffer;
    if fazCargaDoArquivo then
        processa := true;
end;

{----------------------------------------------------------------}
{                           Ativa a gravação do sintetizador em arquivo
{----------------------------------------------------------------}

procedure ativarGravacaoArq (nomeArq: string);
begin
    sintPara;
    sintFim;
    sintNomeArq := nomeArq;
    inicFala;
    sintTeclaCorta (false);
end;

{----------------------------------------------------------------}
{                           desativa a gravação do sintetizador em arquivo
{----------------------------------------------------------------}

procedure desativarGravacaoArq;
begin
    while sapiAtivo(0) do delay (1); ////500);
    sintPara;
    sapiFim;
    sintFim;
    sintNomeArq := '';
    inicFala;
    sintTeclaCorta (true);
end;

{-------------------------------------------------------------}
{       Corpo principal
{-------------------------------------------------------------}

function converterTxtToWav (nomeArq: string): boolean;
var
    tipoSapi: integer;
    nomeWav: string;
begin
    converterTxtToWav := false;
    tipoSapi := strToInt (sintAmbiente ('SERVFALA', 'TIPOSAPI'));
    if (not sapiPresente) or (tipoSapi <> 5) then //Só funciona com SAPI 5
        begin
            mensagem ('DV_SAPATI', 1);   {'Fala SAPI 5 não está ativada no DOSVOX'}
            exit;
        end;

    sintFalaPont := false;
    pendente := '';
    nomeWav := ChangeFileExt(nomeArq, '.wav');
    ativarGravacaoArq (nomeWav);
    if processa (nomeArq) then
        converterTxtToWav := true;
    while sintFalando do waitMessage;
    desativarGravacaoArq;
end;

{-------------------------------------------------------------}

begin
end.
