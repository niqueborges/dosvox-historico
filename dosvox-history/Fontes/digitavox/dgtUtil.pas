{-------------------------------------------------------------}
{
{       Digitavox - Rotinas utilitárias
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtUtil;

interface

uses
    classes,
    dvWin,
    dvCrt,
    windows,
    sysutils,
    dvHora,
    dvForm,
    dgtVars,
    dgtMsg;

procedure limpaParteTela(inicio, fim: integer);
procedure salvaXY;
procedure restauraXY;
procedure falaQualItemDoTotal (nItem, totalItens: integer; selecionado: boolean);
procedure falaApresentacaoOuInstrucao (apresentacao: boolean; secao, nomeArqCurso: string);
procedure falaUltimaConcluida (nomeArqCurso: string);
procedure falaDivisorTempo (divisorTempo: integer);
procedure falaExerLicao (nLicao: integer; nomeArqCurso: string);
function estaNaLista (s: string; lista: TStringList): boolean;
function quantidadeLetrasDistintasLicao (nLicao: integer; nomeArqCurso: string): integer;
function quantidadeLetrasLicao (qtdExer, repeticoesExer, nLicao: integer; nomeArqCurso: string): integer;
function quantidadePalavrasLicao (qtdExer, repeticoesExer, nLicao: integer; nomeArqCurso: string): integer;
procedure pegaTeclado (falarTecla: boolean; var c1, c2: char);
function formataTempo (tempo: longInt): string;
function quantidadeExerLicao (nLicao: integer; nomeArqCurso: string): integer;
function retiraNomeDir (nomeArq: string): string;
function diaMesAno (invertido: boolean) : string;
function horaMinutoSegundo: string;
procedure desligarFalarTecla;

implementation

var
    xSalva,
    ySalva: integer;

{----------------------------------------------------------------------}
{       Linpa a parte da tela desejada.
{----------------------------------------------------------------------}

procedure limpaParteTela(inicio, fim: integer);
var i: integer;
begin
    for i := inicio to fim do
    begin
        gotoxy (1,i); clreol;
    end;
    gotoxy (1, inicio);
end;

{-------------------------------------------------------------}
{       Grava e restaura x y
{-------------------------------------------------------------}

procedure salvaXY;
begin
    xSalva := whereX;
    ySalva := whereY;
end;

procedure restauraXY;
begin
    gotoXY (xSalva, ySalva);
end;

{-------------------------------------------------------------}
{       Fala em qual item está do total
{-------------------------------------------------------------}

procedure falaQualItemDoTotal (nItem, totalItens: integer; selecionado: boolean);
var i: integer;
begin
    if selecionado then nItem := folheiaNumSelec (i);
    sintetiza (intToStr (nItem));
    if selecionado and (nItem > 1) then mensagem ('DGTSELECS', -1) {'selecionados'}
    else if selecionado then mensagem ('DGTSELEC', -1); {'selecionado'}
    mensagem ('DGTDE', -1); {'de'}
    sintetiza (intToStr(totalItens));
end;

{-------------------------------------------------------------}
{       Retorna uma string com os itens de  uma seção com mesmo prefixo + número concatenados
{-------------------------------------------------------------}

function juntarItensMesmoPrefixoSecao (parte, secao, nomeArqIni: string): string;
Var
    s, s2: string;
    i: integer;
begin
    s2 := '';
    i := 1;
    repeat
        s := sintAmbienteArq (secao, parte + intToStr(i), '', nomeArqIni);
        writeln (s);
        if s <> '' then
            begin
                ultimaLinhaInstrucao := s;
                s2 := s2 + ' ' + s;
            end;
        inc (i);
    until s = '';

    result := s2;
end;

{-------------------------------------------------------------}
{       Fala a apresentação ou a instrução
{-------------------------------------------------------------}

procedure falaApresentacaoOuInstrucao (apresentacao: boolean; secao, nomeArqCurso: string);
var
    nomeArqSom, parte, texto: string;
    falaPontuacao: boolean;
begin
    if apresentacao then
        begin
            parte := 'APT';
            nomeArqSom := sintAmbienteArq (secao, 'SOMAPRESENTACAO', '', nomeArqCurso);
        end
    else
        begin
            parte := 'IST';
            nomeArqSom := sintAmbienteArq (secao, 'SOMINSTRUCAO', '', nomeArqCurso);
        end;

    texto := juntarItensMesmoPrefixoSecao (parte, secao, nomeArqCurso);

    if (trim(nomeArqSom) <> '') and (FileExists(nomeArqSom)) then
        sintSom (nomeArqSom)
    else
        begin
            falaPontuacao := sintFalaPont;
            sintFalaPont := false;
            sintetiza (texto);
            sintFalaPont := falaPontuacao;
        end;
    if comEfeitos then sintclek;

    while sintFalando do waitMessage;
    limpaBufTec;
end;

{-------------------------------------------------------------}
{       Fala qual a ultima lição que foi concluída do curso
{-------------------------------------------------------------}

procedure falaUltimaConcluida (nomeArqCurso: string);
var s: string;
begin
    s := sintAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', '', nomeArqUsuario);
    if trim(s) = '' then
        msgBaixo ('DGTNELICU') {'Nenhuma lição deste curso foi concluída'}
    else
        sintetiza (s);
    if comEfeitos then sintclek;
end;

{-------------------------------------------------------------}
{       Fala o fator de divisão do tempo
{-------------------------------------------------------------}

procedure falaDivisorTempo (divisorTempo: integer);
begin
    sintetiza (intToStr(divisorTempo));
    mensagem ('DGTDIVTEM', -1); {'Divisor do tempo '}
end;

{-------------------------------------------------------------}
{       Fala os exercícios da lição
{-------------------------------------------------------------}

procedure falaExerLicao (nLicao: integer; nomeArqCurso: string);
var
    i: integer;
    s, licao: String;
    soletra: boolean;
begin
    licao := 'LICAO' + intToStr(nLicao);
    soletra := upcase((sintAmbienteArq (licao, 'SOLETRAEXER', '', nomeArqCurso) + 'N')[1]) = 'S';
    i := 1;
    repeat
        s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
        if s <> '' then
            begin
                mensagem ('DGTEXERC', -1 ); {'Exercício'}
                sintetiza (intToStr(i));
                if comEfeitos then sintclek;
                if soletra then sintSoletra (s)
                else sintetiza (s);
                if comEfeitos then sintclek;
            end;
        inc (i);
    until s = '';
end;

{-------------------------------------------------------------}
{       Varre uma TStringList, se encontrar um item igual retorna true
{-------------------------------------------------------------}

function estaNaLista (s: string; lista: TStringList): boolean;
var j: integer;
begin
    result := false;
    for j := 0 to (lista.count -1) do
        if lista[j] = s then
            begin
                result := true;
                break;
            end;
end;

{-------------------------------------------------------------}
{       Retorna a quantidade de caracteres distintos dos exercícios da lição
{-------------------------------------------------------------}

function quantidadeLetrasDistintasLicao (nLicao: integer; nomeArqCurso: string): integer;
var
    i, k: integer;
    s, licao: String;
    listaLetrasDistintas: TStringList;
    tudoEmMaiusculo: boolean;
begin
    licao := 'LICAO' + intToStr(nLicao);
    tudoEmMaiusculo := upcase((sintAmbienteArq (licao, 'TUDO_EM_MAIUSCULO', '', nomeArqCurso) + 'N')[1]) = 'S';
    listaLetrasDistintas := TStringList.create;
    listaLetrasDistintas.add (' ');
    i := 1;
    repeat
        s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
        if s <> '' then
            begin
                if tudoEmMaiusculo then s := maiuscAnsi (s);
                for k := 1 to length(s) do
                    if not estaNaLista (s[k], listaLetrasDistintas) then
                        listaLetrasDistintas.add (s[k]);
            end;
        inc (i);
    until s = '';
    result := listaLetrasDistintas.count;
    listaLetrasDistintas.free;
end;

{-------------------------------------------------------------}
{       Retorna o total de letras da lição
{-------------------------------------------------------------}

function quantidadeLetrasLicao (qtdExer, repeticoesExer, nLicao: integer; nomeArqCurso: string): integer;
var
    licao: string;
    i, tam: integer;
begin
    licao := 'LICAO' + intToStr(nLicao);
    tam := 0;
    for i := 1 to qtdExer do
        tam := tam + 1 + length (sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso)); //Soma 1 pelo espaço a mais que entra no fim do exercício
    result := tam * repeticoesExer;
end;

{-------------------------------------------------------------}
{       Retorna o total de palavras da lição
{-------------------------------------------------------------}

function quantidadePalavrasLicao (qtdExer, repeticoesExer, nLicao: integer; nomeArqCurso: string): integer;
var
    licao, s: string;
    i, p: integer;
    totalPalavras: integer;
begin
    licao := 'LICAO' + intToStr(nLicao);
    totalPalavras := 0;
    for i := 1 to qtdExer do
        begin
            s := trim(sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso));
            while s <> '' do
                begin
                    inc (totalPalavras);
                    p := pos (' ', s);
                    if p > 0 then
                        delete (s, 1, p)
                    else
                        s := '';
                    s := trim(s);
                end;
        end;

    result := totalPalavras * repeticoesExer;
end;

{-------------------------------------------------------------}
{       Retorna o tempo total máximo em centésimo de segundos para realizar uma lição
{-------------------------------------------------------------}

function calculaTempoTotalLicao (qtdExer, tempoPorCaracter, repeticoesExer, nLicao: integer; nomeArqCurso: string): longInt;
begin
    result := tempoPorCaracter * quantidadeLetrasLicao (qtdExer, repeticoesExer, nLicao, nomeArqCurso) * 100;
end;

{--------------------------------------------------------}
{              pega um dado do teclado
{--------------------------------------------------------}

procedure pegaTeclado (falarTecla: boolean; var c1, c2: char);
label inicio;
begin

inicio:
    if not keypressed then
        if sintFalando then waitMessage;

    c1 := readkey;
    if falarTecla then sintsoletra (c1);
    if c1 = NOFOCUS then
        goto inicio;

    c2 := ' ';
    if c1 = #0 then
        c2 := readkey;
end;

{-------------------------------------------------------------}
{       Recebe o tempo em centésimo de segundos e retorna a string formatada 00:00:00
{-------------------------------------------------------------}

function formataTempo (tempo: longInt): string;
var
    s, r: string;
var hora, min, seg, cent: integer;
begin
    cent := tempo mod 100;
    tempo := tempo div 100;
    seg :=  tempo mod 60;
    if cent >= 50 then inc (seg);
    tempo := tempo div 60;
    min :=  tempo mod 60;
    hora := tempo div 60;

    s := intToStr(hora);
    if length(s) < 2 then s := '0' + s;
    r := s;
    s := intToStr(min);
    if length(s) < 2 then s := '0' + s;
    r := r + ':' + s;
    s := intToStr(seg);
    if length(s) < 2 then s := '0' + s;
    r := r + ':' + s;

    result := r;
end;

{-------------------------------------------------------------}
{       Retorna a quantidade de exercícios que a lição contem
{-------------------------------------------------------------}

function quantidadeExerLicao (nLicao: integer; nomeArqCurso: string): integer;
var
    s, licao: string;
    i, qtdExer: integer;
begin
    licao := 'LICAO' + intToStr(nLicao);
    qtdExer := 0;
    i := 1;
    s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
    while s <> '' do
        begin
            inc (qtdExer);
            inc (i);
            s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
        end;

    result := qtdExer;
end;

{-------------------------------------------------------------}
{       Retira o diretório do nome do arquivo
{-------------------------------------------------------------}

function retiraNomeDir (nomeArq: string): string;
var
    p: integer;
    s: string;
begin
    s := nomeArq;
    repeat
        p := pos ('\', s);
        if p > 1 then delete (s, 1, p);
    until p <= 0;
    if trim(s) <> '' then result := s
    else result := nomeArq;
end;

{--------------------------------------------------------}
{       Retorna o dia/mês/ano
{--------------------------------------------------------}

function diaMesAno  (invertido: boolean): string;
var
    diaSemana, dia, mes, ano: word;
    s, r: string;
begin
    getDate (ano, mes, dia, diaSemana);
    str (dia, s);
    if length(s) < 2 then s := '0' + s;
    r := s;
    str (mes, s);
    if length(s) < 2 then s := '0' + s;
    if invertido then
        r := s + '_' + r
    else
        r := r + '/' + s;
    str (ano, s);
    if invertido then
        r := s + '_' + r
    else
        r := r + '/' + s;

    result := r;
end;

{--------------------------------------------------------}
{       Retorna hora:Minuto:segundo
{--------------------------------------------------------}

function horaMinutoSegundo: string;
var
    h_, m_, s_, c_: word;
    s, s2: string;
begin
    getTime(h_, m_, s_, c_);
    str (h_, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s + ':';
    str (m_, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s + ':';
    str (s_, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;

    result := s2;
end;

{-------------------------------------------------------------}
{       Ativa e desativa falar tecla
{-------------------------------------------------------------}

procedure desligarFalarTecla;
begin
    falarTecla := not falarTecla;
    if falarTecla then mensagem ('DGTTECACI', -1) {'Teclagem acionada'}
    else mensagem ('DGTTECDES', -1); {'Teclagem desligada'}
end;

{-------------------------------------------------------------}

begin
end.
