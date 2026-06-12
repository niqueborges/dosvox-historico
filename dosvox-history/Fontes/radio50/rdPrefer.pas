{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Processamento de rádios preferidas                  }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdPrefer;

interface
uses
    windows,
    dvcrt,
    dvwin,
    dvForm,
    dvHora,
    sysUtils,
    rdbass,
    rdFFplay,
    rdAjuda,
    rdmsg,
    rdUtil,
    rdvars;

procedure folheiaPreferidas (continuarFolheando: boolean);
procedure radiosPreferidas;

implementation

{--------------------------------------------------------}
{                   escolhe pelo número
{--------------------------------------------------------}

procedure escolhePeloNumero;
var
    c: char;
    r, sn, nomeRadio, url: string;
    p, n, erro: integer;
begin
    mensagem ('RDINFNUMENT', 0);   {'Informe o número da rádio entre '}
    sintWrite (' 1 e ' + intToStr(MAXPREFERIDAS)); write (': ');
    mensagem ('RDUTSETA', 1);  {'Ou use as setas'}
    c := sintEdita(sn, wherex, wherey, 10, true);
    if c = ESC then exit;
    if c = Enter then
        begin
            val (sn, n, erro);
            if (erro <> 0) or (n < 1) or (n > MAXPREFERIDAS) then
                begin
                    mensagem ('RDNUMINV', 2);  {'Número inválido'}
                    mensagem ('RDUSSEDNU',  1);  {'Use as setas para descobrir os números.}
                    exit;
                end;
        end
    else
    if not escolherNumeroPreferidas (n) then
        exit
    else
        sn := intToStr(n);

    r := sintAmbienteArq ('PREFERIDAS', sn, '', arqIndice);
    p := pos ('=', r);
    if p <= 1 then
        begin
            mensagem ('RDERRRAD',  2);  {'A informação sobre está rádio não está disponível.}
            exit;
        end;

    nomeRadio := copy (r, 1, p-1);
    url := copy (r, p+1, length(r));

    clrScr;
    textBackground (BLUE);
    sintWriteln (nomeRadio);
    textBackground (BLACK);
    writeln (url);
    writeln;
    limpabuftec;

    ultimaTocada := url;

    if not comTocadorExterno(url) then
        tocaRadioBass (nomeRadio, url)
    else
        tocaRadioExterna (nomeRadio, tirarTocadorExterno (url));
end;

{--------------------------------------------------------}
{                 Chama o tocador para a rádio.
{--------------------------------------------------------}

procedure tocarRadio (nomeRadio, site: string);
begin
    clrScr;
    TextBackground (BLUE);
    writeln (nomeRadio);
    TextBackground (BLACK);
    writeln;

    ultimaTocada := site;
    if not comTocadorExterno (site) then
        tocaRadioBass (nomeRadio, site)
    else
        tocaRadioExterna (nomeRadio, tirarTocadorExterno(site));
end;

{--------------------------------------------------------}
{                 folheia as preferidas
{--------------------------------------------------------}

procedure folheiaPreferidas (continuarFolheando: boolean);
var
    sites: array [1..MAXPREFERIDAS] of string;

    {--------------------------------------------------------}

    procedure removeItemPreferido (n: integer);
    var c: char;
        sn: string;
    begin
        clrscr;
        textBackground (BLUE);
        writeln ('PREFERIDAS');
        textBackground (BLACK);
        writeln;
        mensagem ('RDCNFRMI', 0);   {'Confirma remoção do item '}
        sintWriteInt (n);
        write (' ');
        c := popupMenuPorLetra('SN');
        if c = 'S' then
            begin
                limpabaixo (3);
                sintClek; sintClek;
                sites[n] := '';
                sn := intToStr(n);
                sintRemoveAmbienteArq('PREFERIDAS', sn, arqIndice);
                folheiaAltera(n, sn + ' - ');
            end;
    end;

    {--------------------------------------------------------}

    procedure clonaItemPreferido (n: integer);
    var
        r, sn: string;
        n2: integer;
        c: char;
        erro: integer;
    begin
        clrscr;
        textBackground (BLUE);
        writeln ('PREFERIDAS');
        textBackground (BLACK);
        writeln;

        r := sintAmbienteArq ('PREFERIDAS', intToStr(n), '', arqIndice);

        mensagem ('RDINNUCL', 0);   {'Informe o número em que será clonado '}
        write('('); sintWrite ('1 a ' + intToStr(MAXPREFERIDAS)); write ('): ');
        mensagem ('RDUTSETA', 1);  {'Ou use as setas'}
        c := sintEdita(sn, wherex, wherey, 10, true);
        if c = ESC then exit;
        if c = Enter then
            begin
                val (sn, n2, erro);
                if (erro <> 0) or (n2 < 1) or (n2 > MAXPREFERIDAS) then
                    begin
                        mensagem ('RDNUMINV', 2);    {'Número inválido'}
                        mensagem ('RDUSSEDNU',  1);  {'Use as setas para descobrir os números.}
                        exit;
                    end;

                if trim(sintAmbienteArq ('PREFERIDAS', sn, '', arqIndice)) <> '' then
                    begin
                        mensagem ('RDEXRAPO', 0); {'Já existe rádio nessa posição, sobrescreve? '}
                        c := popupMenuPorLetra ('SN');
                        writeln;
                        if c <> 'S' then exit;
                    end;
            end
        else
        if not escolherNumeroPreferidas (n2) then
            exit
        else
            sn := intToStr(n2);

        sintGravaAmbienteArq ('PREFERIDAS', sn, r, arqIndice);

        delete (r, pos ('=', r), length(r));
        folheiaAltera(n2, sn + ' - ' + r);
        sites[n2] := sites[n];

        mensagem ('RDOK', 2);   {'OK'}
    end;

    {--------------------------------------------------------}

var
    n: integer;
    r: string;
    c, c2: char;
    nomesRadios: array [1..MAXPREFERIDAS] of string;
    falarItem, apertouShift: boolean;

    procedure renovaNomes;
    var i, p: integer;
    begin
        for i := 1 to MAXPREFERIDAS do
            begin
                sites [i] := '';
                r := sintAmbienteArq ('PREFERIDAS', intToStr(i), '', arqIndice);
                p := pos ('=', r);
                if p <= 1 then
                    nomesRadios[i] := ''
                else
                    begin
                        nomesRadios[i] := copy (r, 1, p-1);
                        sites[i] := copy (r, p+1, 999);
                    end;
            end;
    end;

begin
    clrscr;
    textBackground (BLUE);
    mensagem ('RDFOLPRF', 0);  {'Folheando as rádios preferidas.  F1 ajuda'}
    textBackground (BLACK);
    writeln;
    while sintFalando do waitMessage;

    renovaNomes;

    folheiaCria (wherex, wherey, 80, wherey+20);
    for n := 1 to MAXPREFERIDAS do
        folheiaAdiciona(intToStr(n) + ' - ' + nomesRadios[n]);

    n := 1;
    falarItem := true;
    limpaBufTec;
    repeat
        clrscr;
        textBackground (BLUE);
        write (pegaTextoMensagem('RDFOLPRF'));  {'Folheando as rádios preferidas.  F1 ajuda'}
        textBackground (BLACK);
        writeln;
        folheiaExecuta(n, n, c, c2, falarItem);
        apertouShift := GetKeyState(VK_SHIFT) < 0;
        if n < 1 then n := 1
        else if n > folheiaNumItens then n := folheiaNumItens;

        if c in ['0' .. '9'] then n := folheiaPosicionaInicial (c, n)
        else
        if c = #0 then
            case c2 of
                DIR, CTLDIR:
                    begin
                        if comTocadorExterno (sites[n]) then sintbip;
                        if c2 = DIR then sintetiza (tirarTocadorExterno(sites[n]))
                        else sintsoletra (tirarTocadorExterno(sites[n]));
                    end;
                ESQ: sintetiza ('PREFERIDAS');
                CTLESQ: sintsoletra ('PREFERIDAS');
                F5: n := folheiaBuscaItem (n);
                CTLF5: n := folheiaBuscaItemNovamente (n);
                F8: falaHora;
                CTLF8: falaDia;
            else
                gotoxy (1, 25);
                mensagem ('RDREDENT', 0); {'As opções são: R-remove, E-edita, C-Clona, Enter- Toca.'}
                while sintFalando do waitMessage;
            end
        else
        case upcase(c) of
            'Q', ^Q: falaQualItemDeQuantos (n, apertouShift);
            ^C:
                begin
                    if apertouShift then putClipBoard(pchar(nomesRadios[n]))
                    else putClipBoard(pchar('[PREFERIDAS]' + nomesRadios[n] + '=' + sites[n]));
                    sintClek; sintclek;
                end;

            ENTER: tocarRadio (nomesRadios[n], sites[n]);

            'R', ^R, F7: removeItemPreferido (n);
            'E', ^E: editarRadioFolheamento (n, 'PREFERIDAS', nomesRadios[n], sites[n]) ;
            'C': clonaItemPreferido (n);
            'T', ^T: n := procurarSeUsaTocadorExterno (n,  'PREFERIDAS', nil);
            ESC: ;
        else
            gotoxy (1, 25);
            mensagem ('RDREDENT', 0); {'As opções são: R-remove, E-edita, C-Clona, Enter- Toca.'}
            while sintFalando do waitMessage;
        end;

        renovaNomes;

        if (upcase(c) in ['Q', ^Q, ^C]) or ((c = #0) and (c2 in [DIR, CTLDIR, ESQ, CTLESQ, F8, CTLF8])) then falarItem := false
        else falarItem := true;

    until (c = ESC) or ((c = ENTER) and (not continuarFolheando));

    folheiaDestroi;
end;

{--------------------------------------------------------}
{              repete a última escutada
{--------------------------------------------------------}

procedure ultimaEscutada;
begin
    clrscr;
    TextBackground (BLUE);
    writeln (ultimaTocada);
    TextBackground (BLACK);
    writeln;

    if not comTocadorExterno (ultimaTocada) then
        tocaRadioBass (ultimaTocada, ultimaTocada)
    else
        tocaRadioExterna (tirarTocadorExterno(ultimaTocada), tirarTocadorExterno(ultimaTocada));
end;

{--------------------------------------------------------}
{             seleciona uma das rádios preferidas
{--------------------------------------------------------}

procedure radiosPreferidas;
var c, c2: char;
    opcao: string;
label fim;

begin
    while true do
        begin
            clrscr;
            textBackground (BLUE);
            writeln ('Radio 50 - Preferidas');
            writeln;

            textBackground (RED);
            mensagem ('RDPROQUE', 0);      {'Preferidas - que deseja? '}
            textBackground (BLACK);
            sintLeTecla (c, c2);
            opcao := '';

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                begin
                    c := selSetasOpcaoPreferidas;
                    if c <> #$1b then
                        opcao := copy (opcoesItemSelecionado, pos ('-', opcoesItemSelecionado)-1, 999);
                end;

            if c = #$1b then
                begin
                    writeln;
                    goto fim;
                end;

            if (c = #0) and (c2 = F1) then
                 ajudaOpcaoPreferidas
            else
                begin
                    clrscr;
                    textBackground (BLUE);
                    writeln ('Preferidas' + opcao);
                    textBackground (BLACK);
                    writeln;

                    case upcase(c) of
                        'F': folheiaPreferidas (false);
                        ^F: folheiaPreferidas (true);
                        'P': escolhePeloNumero;
                        'U': ultimaEscutada;
                    else
                        mensagem ('RDOPINV', 1); {'Opção inválida'}
                    end;
                end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}

begin
end.
