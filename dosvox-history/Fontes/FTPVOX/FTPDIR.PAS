{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotina para ler diretorio remoto
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpDir;
interface

uses
    dvCrt, dvWin, dvForm, sysUtils, winsock, winprocs, windows,
    dvItemSeq, dvHora,
    ftpVars, ftpMsg, ftpDlg, ftpPort, ftpRede, ftpArq;

function trocaDir (nome: string; mudo: boolean): boolean;
procedure processaDiretorio;
procedure trocaSubdiretorio;
//procedure buscaItem (paraTraz: boolean);

implementation

{-------------------------------------------------------------}
{                          ajuda
{-------------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('FTPAJA01', 1);  {'As opções são'}
    mensagem ('FTPAJA02', 1);  {'R - recebe o arquivo que foi falado'}
    mensagem ('FTPAJA03', 1);  {'A - apaga o arquivo'}
    mensagem ('FTPAJA04', 1);  {'D - dados sobre o arquivo'}
    mensagem ('FTPAJA05', 1);  {'V - vai para o diretório pai'}
    mensagem ('FTPAJA06', 1);  {'T - troca para o diretório falado'}
    mensagem ('FTPAJA10', 1);  {'ESQ, DIR - soletra nome com as setas'}
    mensagem ('FTPAJA11', 1);  {'CTRL INS - joga o nome na área de transferência'}
    mensagem ('FTPAJA12', 1);  {'ESC - volta ao menu principal do ftp'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [5] = 'radvt';

begin
    popupMenuCria (40, wherey, 50, 5, MAGENTA);
    MenuAdiciona ('FTPAJA02');  {'R - recebe o arquivo que foi falado'}
    MenuAdiciona ('FTPAJA03');  {'A - apaga o arquivo'}
    MenuAdiciona ('FTPAJA04');  {'D - dados sobre o arquivo'}
    MenuAdiciona ('FTPAJA05');  {'V - vai para o diretório pai'}
    MenuAdiciona ('FTPAJA06');  {'T - troca para o diretório falado'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{-------------------------------------------------------------}
{                   Apaga um arquivo
{-------------------------------------------------------------}

function apagaItem (nome: string; diretorio: boolean): boolean;
var c: char;
    codigo: integer;
    comando: string;
begin
    result := false;
    if nome = '' then
        begin
            sintBip;
            exit;
        end;

    writeln;
    mensagem ('FTCNFAPA', 1);  {'Confirme apagamento de'}
    sintWrite (nome);
    write ('?  ');
    mensagem ('FTSIMNAO', 0); {Sim ou nao?}
    c := popupMenuPorLetra('SN');
    writeln;
    if upcase (c) <> 'S' then
        begin
             mensagem ('FTDESIS', 2);   {'Desistiu'}
             exit;
        end;

    if diretorio then comando := 'XRMD '
    else comando := 'DELE ';

    if enviaComando (comando + ansiToUtf8(nome)) then
        begin
            mostraRespostas (codigo);
            if (codigo = 125) or (codigo = 150) or (codigo = 250) then
                begin
                    mensagem ('FTOKAPAG', 1);   {'Ok, apagado'}
                    result := true;
                end
            else
                mensagem ('FTNAOAPA', 1);  {'Não consegui apagar este arquivo'}
        end;
end;

{-------------------------------------------------------------}
{               troca diretório atual
{-------------------------------------------------------------}

function trocaDir (nome: string; mudo: boolean): boolean;
var codigo: integer;
begin
    result := false;
    if nome = '' then
        begin
            if not mudo then
                sintBip;
            exit;
        end;

    if enviaComando ('CWD '+ nome) then
        begin
            mostraRespostas (codigo);
            if (codigo = 250) or (codigo = 200) then
                begin
                    if not mudo then
                        mensagem ('FTOK', 1);  {'OK'}
                    result := true;
                end
            else
                if not mudo then
                    mensagem ('FTNAOTRO', 1);  {'Não consegui trocar'}
        end;
end;

{-------------------------------------------------------------}
{                   Informa o total de itens do folheamento.
{-------------------------------------------------------------}

procedure falaQualItemDeQuantos (nItem, totalItens: integer);
begin
    sintetiza (intToStr (nItem));
    mensagem ('FTDE', -1); {'de'}
    sintetiza (intToStr(totalItens));
end;

{-------------------------------------------------------------}
{                    le o diretorio trazido
{-------------------------------------------------------------}

procedure leDiretorio;
type
     stringDir = string[150];
     diretorio = array [1..15000] of ^stringDir;
var
    n, nent, i: integer;
    pdir: ^diretorio;
    arqDir: text;
    nome, s, buscado: string;
    c, c2: char;
    codigo: integer;
    podeFalar, apertouShift: boolean;

            procedure extraiNome (s: string; var nome: string);
const
    tabMesAbrev: array[1..12] of string=(
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec');

            var i, j: integer;
            begin
                i := pos(':', s);
                if i > 0 then
                begin
                    nome := trim(copy(s, i+3, length(s)));
                    nome := utf8ToAnsi(nome);
                end
                else
                begin
                    for j := 1 to length(tabMesAbrev) do
                    begin
                        i := pos(tabMesAbrev[j], s);
                        if i > 0 then
                        begin
                            nome := trim(copy(s, i+12, length(s)));
                            nome := utf8ToAnsi(nome);
                        end;
                    end;
                end;
            end;

            procedure buscaParaFrente;
            var i, nAux: integer;
                umaVez: boolean;
            label buscaCiclica;
            begin
                umaVez := true;
                nAux := n + 1;
            buscaCiclica:
                for i := nAux to nent do
                    if pos(buscado, semAcentos(pdir^[i]^)) <> 0 then
                        begin
                            N := i;
                            exit;
                        end;

                if umaVez then
                    begin
                        umaVez := false; // Para não ficar em loop quando não encontrar no texto.
                        sintClek;
                        nAux := 1;
                        goto buscaCiclica;
                    end;
                sintClek;
            end;

            procedure buscaParaTraz;
            var i, nAux: integer;
            begin
                nAux := n - 1;
                for i := nAux downto 1 do
                    if pos(buscado, semAcentos(pdir^[i]^)) <> 0 then
                        begin
                            N := i;
                            exit;
                        end;
                sintClek;
            end;

            procedure buscaDeNovo (paraTraz: boolean);
            begin
                if buscado = '' then
                    buscado := semAcentos(sintAmbiente ('FTPVOX', 'BUSCAR1'));
                if paraTraz then buscaParaTraz
                else buscaParaFrente;
            end;

            procedure buscaItem (paraTraz: boolean);
            var
                c: char;
            begin
                buscado := sintAmbiente ('FTPVOX', 'BUSCAR1', 'Dosvox');

                if existeArqSom ('_BUSCAR') then sintSom ('_BUSCAR')   {'O que buscar? '}
                else sintetiza ('O que buscar? ');
                writeLn ('O que buscar? ');
                repeat
                    c := sintEditaCampo (buscado , 1, wherey, 2048, 80, true);
                    if (c = BAIX) or (c = CIMA) then
                        begin
                            c := pegaItemSequencialGravado ('FTPVOX', 'BUSCAR', 10, buscado);
                            if c <> ESC then
                                if existeArqSom ('_REEDIT') then sintSom ('_REEDIT')   {'Reedite e tecle Enter'}
                                else sintetiza ('Reedite e tecle enter');
                        end;
                until c in [ESC, ENTER];

                if (c = ESC) or (buscado = '') then
                    begin
                        mensagem ('FTDESIS', -1); {'Desistiu'}
                        exit;
                    end;

    gravarNoPrimeiroItemSequencial ('FTPVOX', 'BUSCAR', buscado, 10);
            buscado := semAcentos(buscado);
                buscaDeNovo (paraTraz);
            end;

            procedure mostraNomeDir (n: integer; podeFalar: boolean);
            var nome: string;
            begin
                writeln;
                extraiNome (pdir^[n]^, nome);
                if podeFalar then sintetiza (nome);
                write (nome);
                if pdir^[n]^[1] = 'd' then
                    begin
                        gotoxy (30, wherey);
                        if podeFalar then sintetiza ('  diretório');
                        write ('  diretório');
                    end;
            end;

            function converteData (data: string; extenso: boolean): string;
            var
                dia, mes, ano: string;
                i, erro: integer;
            const
                tabMes: array [1..12] of string =
                    ('Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
                    'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');

            begin
        result := data;
                mes := copy (data, 1, 3);
                delete (data, 1, 4);
                dia := copy (data, 1, 2);
                delete (data, 1, 3);
                ano := data;

                if mes = 'Jan' then mes := '01'  else
                if mes = 'Feb' then mes := '02'  else
                if mes = 'Mar' then mes := '03'  else
                if mes = 'Apr' then mes := '04'  else
                if mes = 'May' then mes := '05'  else
                if mes = 'Jun' then mes := '06'  else
                if mes = 'Jul' then mes := '07'  else
                if mes = 'Aug' then mes := '08'  else
                if mes = 'Sep' then mes := '09'  else
                if mes = 'Oct' then mes := '10' else
                if mes = 'Nov' then mes := '11' else
                if mes = 'Dec' then mes := '12';

                if extenso then
                    begin
                        val (mes, i, erro);
                        if erro = 0 then
                            result := dia+ ' de ' + tabMes [i] +                 ' de ' + ano;
                    end
                else
                    result := dia+ '/' + mes + '/' + ano;
            end;

            function extraiData (s: string; formatoOriginal: boolean): string;
            var
                i: integer;
                nome, hora: string;
            begin
                extraiNome (s, nome);
                s := copy (s, 1, length(s)- length(nome));
                for i := 1 to 5 do s := trim (copy(s, pos(' ', s), length(s)));
                while pos('  ', s) > 0 do delete(s, pos('  ', s), 1);

                if not formatoOriginal then
                    begin
                        i := pos (':', s);
                        if i > 4 then
                            begin
                                hora := ' ' + copy(s, i-3, i+2);
                                s := trim (copy(s, 1, i-3));
                            end
                        else
                            hora := '';
                        if length(s) < 10 then s := s + ' ' + formatdatetime('YYYY', now);
                        s := converteData (s, upcase(sintAmbiente('FTPVOX', 'DATAPOREXTENSO', 'SIM')[1]) = 'S') + hora;
                    end;

                result := s;
            end;

    function diretorioEstaVazio (nent: integer; falar: boolean): boolean;
    begin
        if nent <= 0 then
            begin
                if falar then mensagem ('FTDIRVAZ', 1) {'Diretório vazio'}
                else writeln (pegaTextoMensagem('FTDIRVAZ')); {'Diretório vazio'}
                result := true;
            end
        else
            result := false;
    end;



label fim, executa;
begin
    buscado := '';
    assign (arqDir, nomeArqDir);
    {$I-}  reset (arqDir);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('FTERTEMP', 1);  {'Problemas com o arquivo temporário, não posso ler o diretório'}
            exit;
        end;

    new (pdir);
    nent := 0;
    while not eof (arqDir) do
        begin
            readln (arqDir, s);
            nent := nent + 1;
            new (pdir^[nent]);
            pdir^[nent]^ := s;
        end;

    if diretorioEstaVazio (nent, true) then goto fim;

    if sintFalarTudo then
        mensagem ('FTUSSETA', 1);
                    {Use as setas para selecionar arquivos ou subdiretórios,
                    F9 - menu, ESC termina}
    while sintFalando do;

    n := 1;
    podeFalar := true;
    repeat
        if (n >= 1) and (n <= nent) then
            mostraNomeDir (n, podeFalar);

        c := readKey;
        apertouShift := GetKeyState(VK_SHIFT) < 0;

executa:
        if n < 1 then N := 1
        else if n > nent then n := nent;
        if nent > 0 then
            extraiNome (pdir^[n]^, nome)
        else
            begin
                n := 0;
                nome := '';
            end;

        case upcase(c) of
        'R':
            if nome <> '' then
                begin
                    writeln;
                    iniciaRecepcao (nome);
                end
            else
                sintBip;

        'A':
            begin
                if apagaItem (nome, pdir^[n]^[1] = 'd') then
                    begin
                        for i := N to (nent-1) do
                            pdir^[i]^ := pdir^[i+1]^;
                        dispose (pdir^[nent]);
                        dec(n);
                        dec(nent);
                        if diretorioEstaVazio (nent, true) then goto fim;
                    end;
            end;

        'D':
            if enviaComando ('SIZE ' + ansiToUtf8(nome)) then
                begin
                    write (' .... ');
                    falaRespostas (codigo, false, not apertouShift);
                end;

        ^D: if nome <> '' then
                sintetiza(extraiData (pdir^[n]^, apertouShift));

        'Q': falaQualItemDeQuantos (n, nent);

        'V':
            if trocaDir ('..', false) then goto fim;

        'T':
            if trocaDir (ansiToUtf8(nome), false) then goto fim;

        'S': sintSoletra (nome);

        ^C: begin
                     s := nome + #$0;
                     putClipboard (@s[1]);
                     sintclek; sintclek;
                 end;

        #$0:
            begin
                c2 := readkey;
                case c2 of
                    F9: begin
                            c := selSetasOpcao;
                            goto executa;
                        end;

                    CIMA:    n := n - 1;
                    BAIX:    n := n + 1;
                    PGUP:    n := n - 5;
                    PGDN:    n := n + 5;
                    CTLPGUP, HOME: n := 0;
                    CTLPGDN, TEND: n := nent + 1;

                    ESQ, DIR:
                        begin
                                if (n >= 1) or (n <= nent) then
                                    begin
                                        s := pdir^[n]^;
                                        c2 := sintEdita (s, 1, wherey, length (s)+1, false);
                                    end;
                            end;

                    CTLESQ:
                        if enviaComando ('SIZE ' + ansiToUtf8(nome)) then
                            begin
                                write (' .... ');
                                falaRespostas (codigo, false, not apertouShift);
                            end;

                    CTLDIR: if nome <> '' then
                            sintetiza(extraiData (pdir^[n]^, apertouShift));

                    CTLINS: begin
                                 s := nome + #$0;
                                 mensagem ('FTOK', 1);   {ok}
                                 putClipboard (@s[1]);
                             end;

                    F5: buscaItem (apertouShift);
                    CTLF5: buscaDeNovo (apertouShift);
                    F8: falaHora;
                    CTLF8: falaDia;
                end;
            end;
        end;

        while pins <> pret do
            begin
                if wherex <> 0 then writeln;
                mostraRespostas (codigo);
            end;

        if n < 1 then
            begin
                n := 1;
                writeln;
                writeln (pegaTextoMensagem('FTULTARQ'));  {'Ultimo arquivo...'}
                if sintFalarTudo then mensagem ('FTULTARQ', -1)  {'Ultimo arquivo...'}
                else sintClek;
            end
        else
        if n > nent then
            begin
                n := nent;
                writeln;
                writeln (pegaTextoMensagem('FTULTARQ'));  {'Ultimo arquivo...'}
                if sintFalarTudo then mensagem ('FTULTARQ', -1)  {'Ultimo arquivo...'}
                else sintClek;
            end;

        if (upcase(c) in ['D', ^D, 'S']) or ((c = #0) and (c2 in [CTLESQ, CTLDIR, F8, CTLF8])) then
            podeFalar := false
        else
            podeFalar := true;

    until c = #$1b;

fim:
    for n := 1 to nent do
       dispose (pdir^[n]);
    dispose (pdir);

    close (arqDir);

    writeln;
    while keypressed do readkey;
end;

{-------------------------------------------------------------}
{                      processa diretório
{-------------------------------------------------------------}

procedure processaDiretorio;
var i, codigo, ev: integer;
begin
    while pins <> pret do
        mostraRespostas (codigo);

    if enviaComando ('TYPE A') then
        mostraRespostas (codigo)
    else
        exit;

    if not modoPassivo then
        begin
            if not trocaPortaLocal then exit;
        end
    else
        begin
            if not trocaPortaPassiva then exit;
        end;

    assign (arqLocal, nomeArqDir);
    {$I-}  rewrite (arqLocal, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('FTERRCRI', 1);  {'Não consegui criar o arquivo para receber o diretorio'}
            exit;
        end;

    mensagem ('FTDIRPED', 1);  {'Diretorio pedido, aguarde'}
    if abreConexaoArq then
        begin
            totalTransmitido := 0;
            if enviaComando ('LIST') then
                begin
                    mostraRespostas (codigo);
                    if (codigo <> 125) and (codigo <> 150) then
                        mensagem ('FTPEDREC', 1);  {'Pedido de informações de diretório foi recusado'}
                end;
        end
    else
        begin
            {$I-}  close (arqLocal);  {$I+}
            ioresult;   // ignora e sai
            exit;
        end;

    while processaTransf(ev) and (codigo <> 425) do
        begin
            if pins <> pret then
                mostraRespostas (codigo);

            if keypressed then
                case upcase (readkey) of
                   #$1b:  if enviaComando ('ABOR') then
                               begin
                                   mostraRespostas (codigo);
                                   fechaConexaoArq;
                                   exit;
                               end;
                else
                    begin
                         mostraTransmitidos;
                         while keypressed do readkey;
                    end;
                end;
        end;

    i := 0;
    repeat
         delay (500);
         processaTransf(ev);
         i := i + 1;
         if pins <> pret then
             mostraRespostas (codigo);
    until (pins <> pret) or (i > 10) or (codigo = 226) or (codigo = 250) or (codigo = 425);

    if (codigo <> 226) and (codigo <> 250) then
        mensagem ('FTERRDIR', 1)  {'Erro na transferencia do diretorio'}
    else
        leDiretorio;
end;

{-------------------------------------------------------------}
{                 muda diretorio remoto atual
{-------------------------------------------------------------}

procedure trocaSubdiretorio;
var s, nome, salva: string;
    i, codigo: integer;
    continua: boolean;
begin
    mensagem ('FTVERDIR', 1);  {'Verificando diretório atual'}
    if enviaComando ('PWD') then
        begin
            pegaResposta (s, codigo, continua);
            s := utf8ToAnsi(s);
            if codigo <> 257 then
                mensagem ('FTNAODIR', 1)  {'Não consegui obter o diretório atual'}
            else
                begin
                    salva := s;
                    while (s <> '') and (s[1] <> '"') do delete (s, 1, 1);
                    delete (s, 1, 1);
                    i := pos ('"', s);
                    if i > 0 then
                        delete (s, i, length (s)-i+1);

                    sintWrite ('');
                    if sintFalarTudo then delay (1000);
                    if s <> '' then
                        sintetiza (s)
                    else
                        sintetiza (salva);
                end;
        end
    else
        exit;

    mensagem ('FTQUEDIR', 1);    {'Qual o nome do diretorio remoto desejado ? '}
    sintReadln (nome);

    if nome = ''   then
        begin
            mensagem ('FTDESIS', 1);  {'Desistiu'}
            exit;
        end;

    if      nome = '..' then   s := 'CDUP'
    else                       s := 'CWD '+ ansiToUtf8(nome);
    if enviaComando (s) then
        begin
            mostraRespostas (codigo);
            if  (codigo = 250) or (codigo = 200) then
                mensagem ('FTOK', 1)  {'OK'}
            else
                mensagem ('FTNAOTRO', 1);  {'Não consegui trocar'}
        end;
end;

begin
end.
