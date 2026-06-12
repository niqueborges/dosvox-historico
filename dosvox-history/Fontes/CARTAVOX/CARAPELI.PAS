{-------------------------------------------------------------}
{
{           cartaVox - gerente de apelidos
{
{-------------------------------------------------------------}

unit carApeli;
interface

uses
    dvArq, dvForm, dvhora,
    dvcrt,
    dvlenum,
    dvwin,
    sysUtils,
    windows,
    carMsg,
    carUtil,
    carVars,
    carTela,
    carEst,
    dvExec;

function buscaApelido (nomeBusc: string): string;
function procuraEmail (nomeBusc: string): boolean;
procedure trocaApelido (nomeDest, valorNovo: string);
procedure editarApelidos;
function procuraProximoItem(numFolhe: integer): integer;
function procuraItem (numFolhe: integer): integer;
function folhearApelidos (textoBuscar: string): string;
function pegaEMailApelidos (i: integer): string;
procedure selecionaApelido (nCar: integer; folheiaRecebidas: boolean);

implementation

uses carCC;

{--------------------------------------------------------}
{       busca um apelido em APELIDOS.INI
{--------------------------------------------------------}

function buscaApelido (nomeBusc: string): string;
var
    keyName, resulta, amb: array [0..144] of char;
begin
    strPCopy (keyName, nomeBusc);
    strPCopy (amb, nomeArqApelidos);

    GetPrivateProfileString('APELIDOS', KeyName, '', resulta, 80, amb);
    buscaApelido := strPas (resulta);
end;

{--------------------------------------------------------}
{       Procura um e-mail em APELIDOS.ini, retorna TRUE se existir.
{--------------------------------------------------------}

function procuraEmail (nomeBusc: string): boolean;
var
    i, totalLinhas: integer;
begin
    procuraEmail := FALSE;
    if not carregaLinhasArquivo (nomeArqApelidos) then
        begin
            msgBaixo ('CTARQAPL'); {'Arquivo com a lista de pessoas não existe.'}
            msgBaixo('CTLISAPL'); {'Lista de pessoas vazia.'}
            exit;
        end;
    totalLinhas := linhasArquivo.count;
    for i := 0 to (totalLinhas - 1) do
        if pos (nomebusc, linhasArquivo[i]) <> 0 then
            begin
                procuraEmail := TRUE;
                break;
            end;

    destroiLinhasArquivo;
end;

{--------------------------------------------------------}
{       cria um apelido
{--------------------------------------------------------}

procedure trocaApelido (nomeDest, valorNovo: string);
var
    keyName, newStr, amb: array [0..144] of char;
begin
    strPCopy (keyName, nomeDest);
    strPCopy (newStr, valorNovo);
    strPCopy (amb, nomeArqApelidos);
    WritePrivateProfileString('APELIDOS', KeyName, newStr, amb);
end;

{-------------------------------------------------------------}
{       Troca o arquivo de apelidos
{-------------------------------------------------------------}

procedure trocaArqApelido;
var c: char;
    dirAtual, dirApelidos, nomeArq, s: string;
    arqApelido: text;

label outroArqApelido;
begin
    getdir (0, dirAtual);
    dirApelidos := '';
////    s := sintAmbiente ('CARTAVOX', 'APELIDOS');
    s := nomeArqApelidos;
    while pos ('\', s) <> 0 do
        begin
            dirApelidos := dirApelidos + copy (s, 1, pos ('\', s));
            delete (s, 1, pos ('\', s));
        end;

outroArqApelido:
    {$I-} chdir (dirApelidos);  {$I+}
    if ioresult <> 0 then
        begin
            {$I-} chdir (dirAtual);  {$I+}
            if ioresult <> 0 then;
        end;
    textBackGround (RED);
    mensagem ( 'CTNOARQL', 0); {'Nome do arquivo com a lista de pessoas'}
    textBackGround (BLACK);
    writeln;
    garanteEspacoTela (5);
    nomeArq := obtemNomeArqMasc (5, '*.ini');
    {$I-} chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;

    if (nomeArq = '') or (nomeArq[length(nomeArq)] in ['\', '/']) then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu...'}
            exit;
        end;

    if not testaExtensao (nomeArq) then
        nomeArq := nomeArq + '.ini';

    if (pos ('\', nomearq) = 0) and (pos ('/', nomearq) = 0) then
        nomeArq := dirApelidos + nomeArq;

    assign (arqApelido, nomeArq);
    {$i-} reset (arqApelido); {$i+}
    if ioresult <> 0 then
        begin
            repeat
                textBackGround (RED);
                mensagem ('CTARQNDC', 0); {'Arquivo não existe, deseja cria-lo? '}
                mensagem ('CTSIMNAO', 0); {'(S/N) ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackGround (BLACK);
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c = ESC then
                begin
                    mensagem ('CTDESIST', 2);    {'Desistiu...'}
                    exit;
                end
            else
            if c = 'S' then
                begin
                    {$I-} rewrite (arqApelido); {$I+}
                    if ioresult <> 0 then exit
                    else
                        begin
                            {$i-} writeln (arqApelido, ';Apelidos para o correio eletronico'); {$i+}
                            if ioresult = 0 then;
                            {$i-} writeln (arqApelido, '; Formato:   apelido="nome" <endereço>'); {$i+}
                            if ioresult <> 0 then;
                            {$i-} write (arqApelido, '[APELIDOS]'); {$i+}
                            if ioresult <> 0 then;
                            {$i-} close (arqApelido); {$i+}
                            if ioresult <> 0 then;
                            nomeArqApelidos := nomeArq;
                            mensagem ('CTOK', 2); {'Ok'}
                        end;
                end
            else goto outroArqApelido;
        end
    else
        begin
            {$i-} close (arqApelido); {$i+}
            if ioresult <> 0 then;
            nomeArqApelidos := nomeArq;
        end;
end;

{-------------------------------------------------------------}
{       Insere apelidos
{-------------------------------------------------------------}

procedure insereNovoApelido;
var
    c: char;
    apelido, nome, endEletr: string;

label outroApelido;
        begin
outroApelido:
    textBackGround (RED);
    mensagem ('CTINFAPE', 0);  {'Informe o apelido: '}
    textBackGround (BLACK);
    sintReadln (apelido);
    if apelido = '' then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu...'}
            exit;
        end;

    if apelido[1] in [';', '[', '.', '=', '<', '''', '"'] then
        begin
            mensagem ('CTAPEINV', 2); {'Apelido inválido'}
            exit;
        end;

    if buscaApelido (apelido) <> '' then
        begin
            repeat
                mensagem ('CTAPJAEX', 1); {'Apelido já existe, se mantiver este, apagará o anterior'}
                mensagem ('CTDEESOU', 0); {'Deseja escolher outro?'}
                mensagem ('CTSIMNAO', 0); {'(S/N) ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c = ESC then
                begin
                    mensagem ('CTAPEINV', 2); {'Apelido inválido'}
                    exit;
                end
            else
            if c <> 'N' then
                goto outroApelido;
        end;

    mensagem ('CTINFNOM', 0);  {'Informe o nome: '}
    sintReadln (nome);

    mensagem ('CTINFEND', 0);  {'Informe o endereço eletrônico: '}
    sintReadln (endEletr);
    if endEletr = '' then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu...'}
            exit;
        end;

    if nome <> '' then
        nome := '"' + nome + '"'
    else
        nome := '"' + endEletr + '"';

    if not procuraEmail (endEletr) then
        begin
            trocaApelido (apelido, nome + ' <'+ endEletr + '>');
            mensagem ('CTOK', 2);  {'ok'}
        end
    else
        begin
            garanteEspacoTela (2);
            textBackground (RED);
            mensagem ('CTEMJAEX', 2);   {'e-mail já existe.'}
            textBackground (BLACK);
        end;
end;

{--------------------------------------------------------}
{       seleciona a função com as setas, edita apelidos
{--------------------------------------------------------}

function selSetasEditaApelidos: char;
var n: integer;
const
    tabLetrasEditaApelidos: string [4] = 'IETA';

begin
    popupMenuCria (35, wherey, 44, 4, RED);
    MenuAdiciona ('CTAJAP01'); {'    i - insere um novo apelido'}
    MenuAdiciona ('CTAJAP02'); {'    e - edita arquivo atual'}
    MenuAdiciona ('CTAJAP03'); {'    t - troca de arquivo'}
    MenuAdiciona ('CTAJAP04'); {'    a - arquivo atual'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasEditaApelidos := tabLetrasEditaApelidos[n]
    else
        selSetasEditaApelidos := ESC;
end;

{--------------------------------------------------------}
{       ajuda das opções de edição de apelidos
{--------------------------------------------------------}

procedure ajudaEditaApelidos;
begin
    mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTAJAP01', 1); {'    i - insere um novo apelido'}
    if not keypressed then
        mensagem ('CTAJAP02', 1); {'    e - edita arquivo atual'}
    if not keypressed then
        mensagem ('CTAJAP03', 1); {'    t - troca de arquivo'}
    if not keypressed then
        mensagem ('CTAJAP04', 0); {'    a - arquivo atual'}
    writeln;
end;

{-------------------------------------------------------------}
{       editar apelidos
{-------------------------------------------------------------}

procedure editarApelidos;
var c1, c2: char;
    nomeProg: string;
label inicioApeli;
begin
    textBackground (RED);
    mensagem ('CTEDIAPE', 0);   {'Editando arquivo de apelidos'}
    textBackground (BLACK);  clreol;
    writeln;

inicioApeli:
    mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    sintLeTecla (c1, c2);
    writeln;

    if (c1 = #0) and (c2 in [BAIX, CIMA]) then
        c1 := selSetasEditaApelidos
    else
    if c1 = #0 then
        begin
            ajudaEditaApelidos;
            goto inicioApeli;
        end;

    case upcase (c1) of
        'I': insereNovoApelido;
        'T': trocaArqApelido;
        'A', 'B':
            begin
                sintWriteln (nomeArqApelidos);
                writeln;
            end;
        'E':
            begin
                nomeProg := sintAmbiente ('CARTAVOX', 'EDITOR');
                nomeArqApelidos := trim (nomeArqApelidos);
                if pos (' ', nomeArqApelidos) <> 0 then
                    if nomeArqApelidos [1] <> '"' then
                        nomeArqApelidos := '"' + nomeArqApelidos + '"';
                if executaProg (nomeProg, dirRecebe, nomeArqApelidos) >= 32 then
                    esperaProgVoltar;
            end;
    else
        if c1 <> ESC then
            mensagem ('CTOPCINV', 2)   {'Opção inválida'}
        else
            mensagem ('CTDESIST', 2); {'Desistiu'}
    end;

end;

{----------------------------------------------------------------------}
{       Folheamento de Apelidos
{----------------------------------------------------------------------}

{               Declaração das variáveis e constantes }

const
    NUMMAXAPELIDO= 30000;

type
    TApelido= record
                apelido: string;
                nome: string;
                email: string;
                selecionado: boolean;
            end;

    Papelido= ^TApelido;
    tapeli = array [1..NUMMAXAPELIDO] of Papelido;

var
    numApelidos, nFolhe: integer;
    apeli : tapeli;
    nomeBusc: string;

{----------------------------------------------------------------------}
{       Le o arquivo  APELIDOS.INI, gravando-o na memória.}
{----------------------------------------------------------------------}

procedure carregarApelidos;
var
    k: byte;
    i: integer;
    linha, apelido, nome, email: string;

begin
    numApelidos := 0;

    for i := 0 to (linhasArquivo.count -1) do
        begin
            linha := trim (linhasArquivo[i]);
            if linha = '' then continue;
            if linha[1] in [';', '['] then continue;
            if pos ('@', linha) = 0 then continue;

            k := pos ('=', linha);
            if k <> 0 then
            begin
                if k > 1 then
                    apelido := copy (linha, 1, k-1)
                else
                    apelido := '';
                if linha[k+1] = '"' then
                    delete (linha, 1, k+1)
                else
                    delete (linha, 1, k);
            end
            else
                apelido := '';

            k := pos ('<', linha);
            if k <> 0 then
            begin
                if k > 3 then
                    nome := copy (linha, 1, k-3)
                else
                    nome := '';
                delete (linha, 1, k);
            end
            else
                nome := '';

            k := pos ('>', linha);
            if k > 1 then
                email := copy (linha, 1, length (linha)-1)
            else
            if (linha <> '') and (linha <> '>') then
                email := linha
            else
                email := 'Nulo';

            if nome = '' then nome := email;
            if apelido = '' then apelido := nome;
            numApelidos :=  numApelidos + 1;
            new (apeli[numApelidos]);
            apeli[numApelidos]^.apelido := apelido;
            apeli[numApelidos]^.nome := nome;
            apeli[numApelidos]^.email := email;
            apeli[numApelidos]^.selecionado := false;
        end;
end;

{----------------------------------------------------------------------}
{       Desaloca da memória o pontero apeli.}
{----------------------------------------------------------------------}

procedure descarregarApelidos;
begin
    while numApelidos >0 do
    begin
        dispose (apeli[numApelidos]);
        numApelidos := numApelidos - 1;
    end;
end;

{--------------------------------------------------------}
{       Funcao que retorna o e-mail do indice passado
{--------------------------------------------------------}

function pegaEMailApelidos (i: integer): string;
begin
    if not carregaLinhasArquivo (nomeArqApelidos) then
        begin
            msgBaixo ('CTARQAPL'); {'Arquivo com a lista de pessoas não existe.'}
            exit;
        end;
    carregarApelidos;
    if (i > 0) and (i <= numApelidos) then
        pegaEMailApelidos := '"'+apeli[i]^.nome+'" <'+apeli[i]^.email+'>'
    else
        pegaEMailApelidos := '';
    descarregarApelidos;
    destroiLinhasArquivo;
end;

{--------------------------------------------------------}
{       Ordena pelo metodo quick sort
{--------------------------------------------------------}

procedure Sort(l, r: Integer);
var
    i, j: integer;
    x: string;
    ppes: PApelido;

begin
    i := l;
    j := r;

    ppes := apeli[(l+r) div 2];
    x := ppes^.apelido;
    x := semAcentos (x);

    repeat
        while semAcentos (apeli[i]^.apelido) < x do
            i := i + 1;
        while x < semAcentos (apeli[j]^.apelido) do
            j := j - 1;

        if i <= j then
            begin
                ppes := apeli[i];
                apeli[i] := apeli[j];
                apeli[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then Sort(l, j);
    if i < r then Sort(i, r);
end;

{--------------------------------------------------------}
{       procura próximo item do folheamento
{--------------------------------------------------------}

function procuraProximoItem(numFolhe: integer): integer;
var
    i: integer;
    buscado, item: string;
begin
    buscado := semAcentos (nomeBusc);
     for i := numFolhe +1 to folheiaNumItens do
        begin
            item := apeli[i]^.apelido +' '+ apeli[i]^.nome +' '+ apeli[i]^.email;
            if pos (buscado, semAcentos (item)) <> 0 then
                begin
                    procuraProximoItem := i;
                    exit;
                end;
        end;

    sintbip;
    procuraProximoItem := numFolhe;
end;

{--------------------------------------------------------}

function procuraItem (numFolhe: integer): integer;
begin
    procuraItem := numFolhe;
    if nomeBusc = '' then
        begin
            gotoxy (1, 24); clreol;
            textbackground (red);
            mensagem ('CTPALPRO', 0);{'Digite a palavra a procurar: '}
            textbackground (black);
            sintReadln (nomeBusc);
            if nomeBusc = '' then exit;
        end;

    procuraItem := procuraProximoItem (numFolhe);
end;

{-------------------------------------------------------------}
{       Função que apaga apelidos
{-------------------------------------------------------------}

procedure apagaApelido (item: integer);

    procedure apagaUmApelido ( item: integer);
    var
        keyName, amb: array [0..144] of char;
        i: integer;
    begin
        strPCopy (keyName, apeli[item]^.apelido);
        strPCopy (amb, nomeArqApelidos);
        WritePrivateProfileString('APELIDOS', KeyName, NIL, amb);

        dispose (apeli[item]);
        numApelidos := numApelidos - 1;
        for i := item to numApelidos do
            apeli[i] :=  apeli[i + 1];

        folheiaRemoveItem (item);
        if item <= nFolhe then
        nFolhe :=  nFolhe - 1
    end;

    function perguntaSeApaga(item: integer): char;
    var
        c: char;
    begin
        repeat
            mensagem ('CTAPAAPE', 0); {'Deseja apagar o apelido '}
            sintWrite (apeli[item]^.apelido); write ('  ');
            mensagem ('CTSIMNAO', 1); {'(S/N) '}
            c := upcase(popupMenuPorLetra ('SNT'));
            writeln;
        until c in ['S', 'N', 'T', ESC];
        perguntaSeApaga := c;
    end;

var
    c: char;
    i, numApelidosAux: integer;
    apagaSelecionados, apagaTodosSelecionados: boolean;
label desistiu;

begin
    telaFolheiaApelidos (0);
    if temItemSelecionado then
        begin
            repeat
                msgBaixo ('CTDEREIS'); {'Deseja remover todos os itens selecionados?'}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ESC];
            if c = ESC then goto desistiu;
            apagaSelecionados := c = 'S';
        end
    else
        apagaSelecionados := false;

    if apagaSelecionados then
        begin
            numApelidosAux := numApelidos;
            apagaTodosSelecionados := false;
            for i := numApelidosAux downto 1 do
                if apeli[i]^.selecionado then
                    if apagaTodosSelecionados then
                        apagaUmApelido (i)
                    else
                        begin
                            c := perguntaSeApaga(i);
                            if c in ['S', 'T'] then
                                apagaUmApelido (i);
                            if c = ESC then goto desistiu;
                            if c = 'T' then apagaTodosSelecionados := true;
                            if c = 'S' then
                                mensagem('CTOKAPAP', 1);  {'Ok, apagado'}
                        end;
            if apagaTodosSelecionados then
                mensagem ('CTOKAPES', 1); {'Ok, apelidos apagados'}
        end
    else
        begin
            c := perguntaSeApaga(item);
            if c = 'S' then
                begin
                    apagaUmApelido (item);
                    mensagem('CTOKAPAP', 1);  {'Ok, apelido apagado'}
                end
            else
            if c in ['N',ESC] then goto desistiu;
        end;

    exit;
desistiu:
    msgBaixo ('CTDESIST');   {'Desistiu'}
end;

{-------------------------------------------------------------}
{       Ajuda das opções do folheamento de apelidos
{-------------------------------------------------------------}

procedure ajudaFolheApelido;
begin
    telaFolheiaApelidos (folheiaNumItens);
    textBackground (BLUE);
    mensagem ('CTAJUD01', 0); {'As opções são:'}
    textBackground (BLACK);
    writeln;
    mensagem ('CTAJFA01', 1); {'ENTER - Escolhe atual ou selecionados e sai'}
    mensagem ('CTAJFC01', 1); {'CTRL+A - Apagar'}
    mensagem ('CTAJFC02', 1); {'CTRL+Q - Informa quantas do total'}
    mensagem ('CTAJFC03', 1); {'CTRL+S - Informa quantas selecionadas do total'}
    mensagem ('CTAJFL10', 1); {'F5 - Procurar'}
    mensagem ('CTAJFP11', 1); {'BARRA DE ESPAÇO - Seleciona ou tira seleção'}
    mensagem ('CTAJFP12', 1); {'* - Seleciona tudo'}
    mensagem ('CTAJFP13', 1); {'/ - Tira seleção de tudo'}
    mensagem ('CTAJFL07', 1); {'ESC - Terminar folheamento'}

    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
end;

{--------------------------------------------------------}
{       Faz o folheamento dos apelidos e retorna o e-mail desejado.    }
{----------------------------------------------------------------------}

procedure inicializaFolheamentoApelidos;
var
    i: integer;
    apelido, nome, email: string;
begin
    folheiaCria (1, 6, 80, 21);
    for i :=  1 to numApelidos do
        begin
            apelido := copy (apeli[i]^.apelido+BRANCOS, 1, 15);
            nome := copy (apeli[i]^.nome+BRANCOS, 1, 20);
            email := copy (apeli[i]^.email + BRANCOS, 1, 38);

            folheiaAdicionaEspecial (apelido + ' = ' + nome + ' < ' + email + '>',
                                     apeli[i]^.selecionado, apeli[i]^.apelido);
        end;
end;

{-------------------------------------------------------------}

function folhearApelidos (textoBuscar: string): string;
var
    c, c2: char;
    i, k: integer;
    podeFalar, apertouShift: boolean;
    aux, item: string;
begin
    telaFolheiaApelidos (0);
    if not carregaLinhasArquivo (nomeArqApelidos) then
        begin
            msgBaixo ('CTARQAPL'); {'Arquivo com a lista de pessoas não existe.'}
            exit;
        end;
    carregarApelidos;
    destroiLinhasArquivo;
    if numApelidos < 1 then
        begin
            msgBaixo('CTLISAPL'); {'Lista de pessoas vazia.'}
            exit;
        end;
    sort (1, numApelidos);
    inicializaFolheamentoApelidos;

    nFolhe:= 1;
    podeFalar := true;
    nomeBusc := trim (textoBuscar);
    if nomeBusc <> '' then
        nFolhe := procuraItem (nFolhe);

    repeat
        telaFolheiaApelidos (folheiaNumItens);
        folheiaExecuta (nFolhe, nFolhe, c, c2, podeFalar);
        apertouShift := GetKeyState(VK_SHIFT) < 0; 
        if nFolhe < 1 then NFolhe := 1;
        if nfolhe > folheiaNumItens then nFolhe := folheiaNumItens;
        sintPara;
        for k := 1 to folheiaNumItens do
            folheiaObtemItem (k, item, apeli[k]^.selecionado);

        if c = #$0 then
            case c2 of
                ESQ: sintetiza (apeli[nFolhe]^.nome);
                CTLESQ: sintsoletra (apeli[nFolhe]^.apelido);
                DIR: sintetiza (apeli[nFolhe]^.email);
                CTLDIR: sintsoletra (apeli[nFolhe]^.email);
                F1: ajudaFolheApelido;
                f5:
                    begin
                        nomeBusc := '';
                        nFolhe := procuraItem (nFolhe);
                    end;
                CTLF5: nFolhe := procuraProximoitem (nFolhe);
                F7: apagaApelido (nFolhe);
                f8: falaHora;
                CTLF8: falaDia;
            end
        else
            with apeli[nFolhe]^ do
            begin
                case upcase(c) of
                    ESC: folhearApelidos := '';
                    ^A: apagaApelido (nFolhe);
                    ^C: begin
                            putClipBoard(@apeli[nFolhe]^.email[1]);
                            sintClek; sintclek;
                        end;
                    ENTER: begin
                                aux := '';
(*NenoNeno2*)                                if not temItemSelecionado then
                                    aux := '"'+nome+'" <'+email+'>'
                                else
                                    for i := 1 to numApelidos do
                                    if apeli[i]^.selecionado then
                                        aux := aux +',"'+ apeli[i]^.nome+'" <'+ apeli[i]^.email+'>';
                                if aux[1] = ',' then delete (aux, 1, 1);
                                folhearApelidos := aux;
                                c := ESC;
                           end;

                    ^Q: falaQualItemDeQuantos (nFolhe, folheiaNumItens, apertouShift);
                    ^S: falaQualItemDeQuantos (nFolhe, folheiaNumItens, true);
                end;
            end;

        if (upCase(c) in[^Q, ^S]) or (c2 in [ESQ, DIR, f8, CTLF8]) then
            podeFalar := false
        else
            podeFalar := true;

        if (upcase (c) in ['A' .. 'Z']) or (upcase (c) in ['0' .. '9']) then
            begin
                i := nFolhe + 1;
                if i > folheiaNumItens then i := 1;
                while (i <> nFolhe) and  (maiuscAnsi (apeli[i]^.apelido[1]) <> upcase(c)) do
                    if i >= numApelidos then
                        i := 1
                    else
                        i := i + 1;
                if maiuscAnsi (apeli[i]^.apelido[1]) = upcase(c) then
                    nFolhe := i;

            end;

    until (c = ESC) or (numApelidos <= 0);

    folheiaDestroi;
    descarregarApelidos;
    textColor (WHITE);
    telaPrincipal;
end;

{--------------------------------------------------------}
{       associa nome a um apelido
{--------------------------------------------------------}

function adicionaUm (nCar: integer; nome: string; var mudo, adicionarSemPerguntar, mudoSemApelido: boolean): boolean;
var
    c: char;
    apelido, s: string;
    k, i: integer;
    jaExisteApelido: boolean;

label outroApelido;
begin
    adicionaUm := false;
    if nome = '' then
        if folheiaRecebidas then
            nome := regLido [nCar]^.carta^.from
        else
            nome := regLido [nCar]^.carta^.to_;

    if pos ('<', nome) <= 1 then
        begin
            deletaMenorMaior (nome);
            nome := '"' + nome + '" <' + nome + '>';
        end
    else
    if pos ('"', nome) = 0 then
        begin
            k := pos ('<', nome);
            s := copy (nome, 1, k-1);
            delete (nome, 1, k);
            nome := '"' + s + '" <' + nome;
        end;

outroApelido:
    if not adicionarSemPerguntar then
        begin
            repeat
                limpaParteTela (20, 25);
                textBackground (RED);
                mensagem ('CTQAPELI', 0);    {'Informe o apelido desejado para '}
                textBackground (BLACK);
                writeln;
                sintWriteln (nome);

                apelido := nome;
                delete (apelido, 1, 1);
                apelido := copy (apelido, 1, pos ('"', apelido)-1);
                c := sintEditaCampo (apelido, 1, wherey, 255, 80, true);
                writeln;
            until c in [ENTER, ESC];
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST');   {'Desistiu'}
                    exit;
                end;
        end
    else
        begin
            apelido := nome;
            delete (apelido, 1, 1);
            apelido := copy (apelido, 1, pos ('"', apelido)-1);
        end;

    if apelido <> '' then
        begin
            if apelido[1] in [';', '[', '.', '=', '<', '''', '"'] then
                begin
                    msgBaixo ('CTAPEINV'); {'Apelido inválido'}
                    exit;
                end;

            jaExisteApelido := buscaApelido (apelido) <> '';
            if adicionarSemPerguntar and jaExisteApelido then
                begin
                    i := 1;
                    while (buscaApelido (apelido + intToStr(i)) <> '') and (i < 100)   do
                        i := i + 1;
                    apelido := apelido + intToStr(i);
                end
            else
            if jaExisteApelido then
                begin
                    repeat
                        limpaParteTela (20, 25);
                        textBackground (RED);
                        mensagem ('CTAPJAEX', 1); {'Apelido já existe, se manter este, apagará o anterior'}
                        mensagem ('CTDEESOU', 0); {'Deseja escolher outro?'}
                        mensagem ('CTSIMNAO', 0); {'(S/N) ? '}
                        c := popupMenuPorLetra ('SNT');
                        writeln;
                    until c in ['S', 'N', 'T', ENTER, ESC];
                    if c = 'T' then
                        begin
                            adicionarSemPerguntar := true;
                            mudo := true;
                        end;
                    if c = ESC then
                        begin
                            msgBaixo ('CTDESIST');   {'Desistiu'}
                            exit;
                        end
                    else
                    if not (c in ['N', 'T', ENTER]) then
                        goto outroApelido;
                end;

            s := copy (nome, (pos('<', nome)+1), (pos ('>', nome) -1) - (pos('<', nome)+1));
            if not procuraEmail (s) then
                begin
                    trocaApelido (apelido, nome);
                    adicionaUm := true;
                end
            else
                begin
                if not mudo then
                    begin
                        msgBaixo ('CTEMJAEX');   {'e-mail já existe.'}
                        sintetiza(nome);
                    end;
                end;
        end
    else
    if not adicionarSemPerguntar then
        msgBaixo ('CTDESIST')   {'Desistiu'}
    else
        begin
            if not mudoSemApelido then
                begin
                    mensagem ('CTAPEINV', -1); {'Apelido inválido'}
                    if ncar > 0 then
                        begin
                            mensagem ('CTCARTA', -1); {'carta'}
                            sintetiza( intToStr(ncar));
                        end
                    else
                        sintetiza (nome);
                    while sintFalando do waitMessage;
                end;
            if keypressed then
                begin
                    c := readkey;
                    if c = 'T' then
                        begin
                            adicionarSemPerguntar := true;
                            mudo := true;
                        end
                    else
                    if (c = ' ') or (c = #$08) then
                        mudoSemApelido := not mudoSemApelido;
                    limpabuftec;
                end;
        end;
end;

{--------------------------------------------------------}

function adicionaCC (nCar: integer): boolean;
var
    c: char;
    adicionou, mudo, adicionarSemPerguntar, mudoSemApelido: boolean;
    i, adicionados, naoAdicionados: integer;
    nome: string;
    p: pListaCC;
begin
    adicionaCC := false;
    extraiCc (nCar);
    if pCC = NIL then exit;

    repeat
        limpaParteTela (20, 25);
        textBackground (RED);
        mensagem ('CTADICC', 0); {'Deseja adicionar os contatos carbono da carta?')}
        c := upcase(popupMenuPorLetra ('SNT'));
        textBackground (BLACK);
        writeln;
    until c in ['S', 'N', 'T', ESC];
    if c in ['N', ESC] then sintbip;
    if not (c in ['S', 'T']) then exit;

    adicionou := false;
    adicionados := 0;
    naoAdicionados := 0;
    adicionarSemPerguntar := c = 'T';
    mudoSemApelido := not adicionarSemPerguntar;
    mudo := adicionarSemPerguntar;
    i := 1;
    p := pCC;
    while p <> NIL do
        begin
            nome := p^.nome;
            p := p^.prox;
            if not adicionarSemPerguntar then sintclek;
            if adicionaUm(i, nome, mudo, adicionarSemPerguntar, mudoSemApelido) then
                begin
                    adicionou := true;
                    adicionados := adicionados + 1;
                end
            else
                naoAdicionados := naoAdicionados + 1;
            if keypressed then
                begin
                    c := readkey;
                    if (c = ' ') or (c = #$08) then
                        begin
                            mudo := not mudo;
                            if mudoSemApelido then
                                mudoSemApelido := false;
                        end
                    else
                    if c = ESC then
                        begin
                            msgBaixo('CTDESIST');
                            break;
                        end
                    else
                        sintetiza (intToStr(i));
                    i := i + 1;
                end;
        end;

    limpaListaCarbono (pCC);
    limpaBuftec;
    sintWriteint (adicionados);
    if adicionados > 1 then
        mensagem ('CTAPEADS', 0) {' apelidos adicionados'}
    else
        mensagem ('CTAPEADI', 0); {' apelido adicionado'}
        write ('    ');
    delay (100);
    sintWriteint (naoAdicionados);
    if NaoAdicionados > 1 then
        mensagem ('CTAPNADS', 1) {' apelidos não adicionados'}
    else
        mensagem ('CTAPNADI', 1); {' apelido não adicionado'}

    if adicionou then
        msgBaixo ('CTOK');   {'Ok'}
    adicionaCC := true;
end;

{--------------------------------------------------------}

procedure selecionaApelido (nCar: integer; folheiaRecebidas: boolean);
var
    adicionaSelecionados, selecionado, adicionou, mudo, mudoSemApelido: boolean;
    c: char;
    i, adicionados, naoAdicionados, totalSelecionados: integer;
    item: string;
begin
    adicionou := false;
    mudo := false;
    if temItemSelecionado then
        repeat
            limpaParteTela (20, 25);
            textBackground (RED);
            mensagem ('CTADISEL', 0); {'Deseja adicionar todas as selecionadas? '}
            c := upcase(popupMenuPorLetra ('SNT'));
            textBackground (BLACK);
            writeln;
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu ...'}
                    exit;
                end;
            AdicionaSelecionados := c in ['S','T'];
        until c in ['S', 'N', 'T', ENTER]
    else
        adicionaSelecionados := false;

    if adicionaSelecionados then
        begin
            adicionados := 0;
            naoAdicionados := 0;
            mudo := c = 'T';
            adicionaSelecionados := mudo;
            mudoSemApelido := not adicionaSelecionados;
            totalSelecionados := totalDeItensSelecionados;

            for i := 1 to folheiaNumItens do
                begin
                    if not regLido [i]^.carta^.preenchido then
                        begin
                            selecionado := regLido [i]^.selecionado;
                            carregaArqPreencheCabPrin ( i);
                            regLido [i]^.selecionado := selecionado;
//                            if mudo and ((i mod 102) = 0) then sintclek;
                        end;
                    folheiaObtemItem (i, item, selecionado);
                    if selecionado then
                        begin
                            if not mudo then sintclek;
                            if adicionaUm(i, '', mudo, adicionaSelecionados, mudoSemApelido) then
                                begin
                                    adicionou := true;
                                    adicionados := adicionados + 1;
                                end
                            else
                                naoAdicionados := naoAdicionados + 1;
                        end;
                    if keypressed then
                        begin
                            c := readkey;
                            if (c = ' ') or (c = #$08) then
                                begin
                                    mudo := not mudo;
                                    if mudoSemApelido then
                                        mudoSemApelido := false;
                                end
                            else
                            if c = ESC then
                                begin
                                    msgBaixo('CTDESIST');
                                    break;
                                end
                            else
                            if (adicionados + naoAdicionados) < 1 then
                                sintetiza ('1' + ' de ' + intToStr(totalSelecionados))
                            else
                                sintetiza (intToStr(adicionados + naoAdicionados) + ' de ' + intToStr(totalSelecionados));
                        end;
                    limpaBuftec;
                end;
            sintWriteint (adicionados);
            if adicionados > 1 then
                mensagem ('CTAPEADS', 0) {' apelidos adicionados'}
            else
                mensagem ('CTAPEADI', 0); {' apelido adicionado'}
                write ('    ');
            delay (100);
            sintWriteint (naoAdicionados);
            if NaoAdicionados > 1 then
                mensagem ('CTAPNADS', 1) {' apelidos não adicionados'}
            else
                mensagem ('CTAPNADI', 1); {' apelido não adicionado'}
        end
    else
    if not adicionaCC (nCar) then
        if adicionaUm(nCar, '', mudo, adicionaSelecionados, mudoSemApelido) then
            adicionou := true
        else
        if mudo then
            mensagem ('CTAPNADI', 1); {' apelido não adicionado'}

    if adicionou then
        msgBaixo ('CTOK');   {'Ok'}
end;

{-------------------------------------------------------------}
begin
end.
