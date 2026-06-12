unit dosutil;
interface
uses windows, sysUtils,
     dvcrt, dvwin, dvform, dvExec,
     dosproc, dosgeral, dosmsg,
    dosVars;

procedure chamaUtilitarios (tipo: char);
function expandeArroba (nomeProg: string): string;

implementation

{--------------------------------------------------------}
{            extrai um parâmetro de uma cadeia
{--------------------------------------------------------}

function extraiParam (s: string; qual: integer): string;
var i, p: integer;
begin
    if qual > 1 then                              { remove os primeiros parâmetros }
        for i := 2 to qual do
            begin
                p := pos (',', s);
                delete (s, 1, p);
            end;

    p := pos (',', s);                            { pega até virgula }
    if qual = 4 then p := 0;                      { no ultimo parametro vale até o fim }
    if p = 0 then p := length (s) + 1;
    s := copy (s, 1, p-1);

    while (s <> '') and (s[1] = ' ') do           { remove brancos no início e fim }
        delete (s, 1, 1);
    while (s <> '') and (s[length (s)] = ' ') do
        delete (s, length (s), 1);

    extraiParam := s;
end;

{--------------------------------------------------------}
{                 expande nome começado por @
{--------------------------------------------------------}

function expandeArroba (nomeProg: string): string;
var dirDosvox: string;
begin
    if (nomeProg <> '') and (nomeProg[1] = '@') then
        begin
            dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
            delete (nomeProg, 1, 1);
            expandeArroba := dirDosvox + nomeProg;
        end
    else
        expandeArroba := nomeProg;
end;

{--------------------------------------------------------}
{                 ajuda dos utilitarios
{--------------------------------------------------------}

procedure ajudaUtil (secao: pchar; prefixo: string);

var
    s: string;
    i: integer;
    abrev: string [1];
    nomeSom: string [8];
    texto: string[80];
    nomeProg: string;

begin
    writeln;
    for i := 1 to 6 do
        begin
            s := sintAmbiente (secao, prefixo + intToStr(i));
            if s <> '' then
                begin
                    nomeprog := expandeArroba (extraiParam (s, 2));

                    if not fileExists (nomeProg) then
                        continue;

                    abrev   := extraiParam (s, 1);
                    nomeSom := extraiParam (s, 3);
                    texto   := extraiParam (s, 4);

                    writeln ('    ', abrev, ' - ', texto);
                    if nomeSom[1] = '-' then
                        begin
                            sintCarac (abrev[1]);
                            sintetiza (texto);
                        end
                    else
                        sintSom (nomeSom);
                    while sintFalando do;
                    delay (200);
                end;
        end;

    mensagem ('DV_AJUTIL', 1);  {'    Use as setas para selecionar ou conhecer todas as opções'}
    repeat until not sintFalando;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasUtil (secao, prefixo: string): integer;

    procedure MenuAdiciona (abrev: char; som, texto: string);
    begin
        if (som <> '') and (som[1] = '-') then
            delete (som, 1, 1);
        if abrev = ' ' then
            texto := '    ' + texto
        else
            texto := abrev + ' - ' + texto;

//    popupMenuAdiciona ('_'+intToStr(ord(abrev)) + '|' + 'util\'+trim(som), '  ' + texto);
      popupMenuAdiciona ('util\'+trim(som), '  ' + texto);
    end;

var
    s: string;
    i: integer;
    abrev, som, texto: string;
    nutil: integer;
    tabCodUtil: array [0..100] of integer;
    nomeProg: string;
    op: integer;

begin
    nutil := 0;
    for i := 1 to 100 do  // esse loop só serve para contagem
        begin
            s := sintAmbiente (secao, prefixo + intToStr(i));
            if s <> '' then
                begin
                    nomeprog := expandeArroba (extraiParam (s, 2));
                    if (copy (trim (nomeProg), 1, 1) = '[') or fileExists (nomeProg) then
                        nutil := nutil + 1;
                end;
        end;

    popupMenuCria (1, wherey+1, 50, nutil, MAGENTA);
    nutil := 0;
    tabCodUtil[0] := 0;
    textBackground (MAGENTA);
    for i := 1 to 100 do
        begin
            s := sintAmbiente (secao, prefixo + intToStr(i));
            if s <> '' then
                begin
                    nomeprog := expandeArroba (extraiParam (s, 2));
                    if not ((copy (trim (nomeProg), 1, 1) = '[') or fileExists (nomeProg)) then
                        continue;

                    nutil := nutil + 1;
                    tabCodUtil [nutil] := i;

                    abrev   := ansiLowerCase(extraiParam (s, 1));
                    if abrev = '' then abrev := ' ';
                    som     := extraiParam (s, 3);
                    texto   := extraiParam (s, 4);
                    MenuAdiciona (abrev[1], som, texto);
                end;
        end;

    sintFalaPont := false;
    op := popupMenuSeleciona;
    textBackground (BLACK);

    selSetasUtil := tabCodUtil [op];
    sintFalaPont := true;
end;

{--------------------------------------------------------}
{                  opcao de chamada do DOS
{--------------------------------------------------------}

procedure chamaUtilitarios (tipo: char);
var
    nomeDir, param, s, comando: string;
    c, c2: char;
    secao: string;
    prefixo: string;
    i: integer;

label inicio, achou, erro, subSecao;

begin

inicio:
    textBackground (RED);

    case tipo of
        'U':  begin
                        secao := 'PROGUTIL';
                        prefixo:= 'Util';
                        mensagem ('DV_TECPGM', 0);  { 'Qual a letra do programa ? ' }
              end;
        'J':  begin
                        secao := 'PROGJOGOS';
                        prefixo:= 'Jogo';
                        mensagem ('DV_TECJOG', 0);  { 'Qual a letra do jogo ? ' }
              end;
        'R':  begin
                        secao := 'PROGREDE';
                        prefixo:= 'Rede';
                        mensagem ('DV_TECRED', 0);  { 'Qual a letra do programa de rede ? ' }
              end;
        'M':  begin
                        secao := 'PROGMULTI';
                        prefixo:= 'Multi';
                        mensagem ('DV_TECMUL', 0);  { 'Qual a letra do programa de multimídia ? ' }
              end;
    end;
    textBackground (BLACK); clreol;

subSecao:
    sintLetecla (c, c2);
    writeln;

    if (c = #0) and (c2 = F1) then
        begin
            ajudaUtil (@secao[1], prefixo);
            goto inicio;
        end
    else
    if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
        begin
           i := selSetasUtil (secao, prefixo);
           if i <= 0 then
               begin
                   clrscr;
                   exit;
               end;

           writeln (opcoesItemSelecionado);
           s := sintAmbiente (secao, prefixo + intToStr(i));
           goto achou;
        end;

    if c = #$1b then
        begin
            clrscr;
            exit;
        end;

    c := upcase (c);
    for i := 1 to 50 do
        begin
            s := sintAmbiente (secao, prefixo + intToStr(i));
            if s <> '' then
                begin
                    if upcase(s[1]) = c then
                        goto achou;
                end;
        end;

erro:
    writeln;
    mensagem ('DV_PRGNAOEX', 1);    { 'Não existe programa registrado com esta letra.' }
    mensagem ('DV_F1ESC', 1);       { 'Tecle F1 para ajuda ou ESC para cancelar.' }
    goto inicio;

achou:
    writeln;
    comando := expandeArroba (extraiParam (s, 2));
    if copy (trim(comando), 1, 1) = '[' then
        begin
            secao := trim(comando);
            delete (secao, 1, 1);
            delete (secao, length(secao), 1);
            secao := trim (secao);
            mensagem ('DV_TECPGM', 0);      { 'Qual a letra do programa ? ' }
            goto subsecao;
        end;

    i := pos (' ', comando);
    if i = 0 then
        param := ''
    else
        begin
            param := copy (comando, i+1, 999);
            delete (comando, i, 999);
        end;

    while sintFalando do;
    if executaPrograma (comando, nomeDir, param, SW_SHOWNORMAL) then
        esperaProgVoltar;

    if tipo = 'M' then
        begin
            sintFim;
            inicFala;
        end;
end;

end.
