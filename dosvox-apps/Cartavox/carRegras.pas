{-------------------------------------------------------------}
{
{           cartaVox - Regras
{
{           Autora: Tamires Maciel
{           Em Junho de 2010.
{
{           Atualizado por: Neno Henrique da Cunha Albernaz
{          Em Novembro de 2015
{          Em Setembro de 2017
{
{-------------------------------------------------------------}

unit carRegras;

interface

uses
    dvcrt,
    dvform,
    dvWin,
    dvhora,
    sysUtils,
    uuenc,
    windows,
    carCopia,
    carEst,
    carList,
    carMsg,
    carUtil,
    carVars,
    carFolhe,
    carTela,
    carResp;

    procedure aplicarRegrasCartas (naoLidas, assuntoPrimeiro: boolean);
    procedure inicializaRegras;
function obtemNomePastaRegra (var pasta: string): boolean;

implementation

const
    NUMMAXREGRA= 30000;

type
    TRegra= record
                regra: string;
                nome: string;
                pasta: string;
                selecionado: boolean;
            end;

    Pregra= ^TRegra;
    treg = array [1..NUMMAXREGRA] of Pregra;

    TAux = record
        nome: string;
        numero: integer;
    end;

var
     reg: treg;
     numRegras, nFolhe: integer;

{--------------------------------------------------------}
{       ordena pelo metodo quick sort
{--------------------------------------------------------}

procedure Sort(l, r: Integer; ordemInversa: boolean);
var
    i, j: integer;
    x: string;
    ppes: Pregra;
begin
    i := l;
    j := r;
    ppes := reg [(l+r) div 2];
    x := ppes^.pasta;
    x := semAcentos (x);

    repeat
        if ordemInversa then
            begin
                while semAcentos (reg[i]^.pasta) > x do
                    i := i + 1;
                while x > semAcentos (reg[j]^.pasta) do
                    j := j - 1;
            end
        else
            begin
                while semAcentos (reg[i]^.pasta) < x do
                    i := i + 1;
                while x < semAcentos (reg[j]^.pasta) do
                    j := j - 1;
            end;
        if i <= j then
            begin
                ppes := reg[i];
                reg[i] := reg[j];
                reg[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then Sort(l, j, ordemInversa);
    if i < r then Sort(i, r, ordemInversa);
end;

{-------------------------------------------------------------}
{       Cria uma pasta
{-------------------------------------------------------------}

procedure criaPasta(nomePasta: string);
var attributes: integer;
begin
    if not DirectoryExists(nomePasta) then
    begin
        attributes := FileGetAttr(dirRecebe);
        if FileSetAttr (dirRecebe, Attributes xor faReadOnly) = 0 then
            ForceDirectories(nomePasta);
    end;
end;

{-------------------------------------------------------------}
{       Carrega as regras na estrutura pRegra
{-------------------------------------------------------------}

function carregarRegras (carregarNomesPastas, mudo: boolean): boolean;
var
    k: byte;
    i: integer;
    linha, regra, nome, pasta: string;
    pastaGuardada: boolean;
begin
    carregarRegras := false;
    if not carregaLinhasArquivo (dirRecebe + '\Regras.ini') then exit;
    numRegras := 0;
    if carregarNomesPastas and (not mudo) then
        mensagem ('CTMOMENT', -1); {'Um momento...  '}

    for i := 0 to (linhasArquivo.count -1) do
        begin
            linha := trim (linhasArquivo[i]);
            if linha = '' then continue;
            if linha[1] = ';' then continue;
            if (linha[1] = '[') and (linha[length(linha)] = ']') then
                begin
                    regra := copy(linha, 2, pos(']', linha) - 2);
                    continue;
                end;
            if (carregarNomesPastas) and (regra = 'EXCLUIR') then continue;

            k := pos ('=', linha);
            if k <= 1 then continue;
            nome := copy (linha, 1, k-1);
            if copy(nome, 1, 2) = '-[' then delete(nome, 1, 1);
            pasta := copy (linha, k + 1,  length(linha) - k);
            deletaAspas (pasta);

            if carregarNomesPastas then
                begin
                    if not DirectoryExists(dirRecebe + '\' + pasta) then continue;
                    if numeroDeCartas (dirRecebe + '\' + pasta, 'F') = 0 then continue;
                    pastaGuardada := false;
                    for k := 1 to numRegras do
                        if uppercase(reg[k]^.pasta) = uppercase(pasta) then
                            begin
                                pastaGuardada := true;
                                break;
                            end;
                    if pastaGuardada then continue;
                end;

            numRegras :=  numRegras + 1;
            new (reg[numRegras]);
            reg[numRegras]^.regra := regra;
            reg[numRegras]^.nome := nome;
            reg[numRegras]^.pasta := pasta;
            reg[numRegras]^.selecionado := false;
        end;

    carregarRegras := true;
    destroiLinhasArquivo;
end;

{-------------------------------------------------------------}

{       Descarrega as regras da memória
{-------------------------------------------------------------}

procedure descarregarRegras;
begin
    while numRegras >0 do
    begin
        dispose (reg[numRegras]);
        numRegras := numRegras - 1;
    end;
end;

{-------------------------------------------------------------}
{       Busca a regra
{-------------------------------------------------------------}

function buscaRegra (nomeBusc: string): integer;
var
    i : integer;
begin
    buscaRegra := 0;
    for i :=  1 to numRegras do
        if (reg[i]^.regra = 'MOVER ASSUNTO') or
          ((reg[i]^.regra = 'EXCLUIR') and (reg[i]^.pasta = 'ASSUNTO')) then
            begin
                if pos (uppercase(reg[i]^.nome), uppercase(nomeBusc)) <> 0 then
                    begin
                        buscaRegra := i;
                        break;
                    end;
            end
        else
        if uppercase(reg[i]^.nome) = uppercase(nomeBusc) then
            begin
                buscaRegra := i;
                break;
            end;
end;

{-------------------------------------------------------------}
{ Cria uma nova regra.
{-------------------------------------------------------------}

procedure criarRegras;
var
    r1, r2: char;
    keyname, newStr, amb: array [0..144] of char;
    nomeRegra, pastaCarta: string;
    res: integer;

    function nomeArqPastaValido: boolean;
    var i: integer;
    begin
        nomeArqPastaValido := false;
        i := pos('\', pastaCarta);
        i := i + pos('/', pastaCarta);
        i := i + pos(':', pastaCarta);
        i := i + pos('<', pastaCarta);
        i := i + pos('>', pastaCarta);
        i := i + pos('?', pastaCarta);
        i := i + pos('*', pastaCarta);
        i := i + pos('|', pastaCarta);
        i := i + pos('"', pastaCarta);
        if i <> 0 then
            mensagem('CTCARCNP',0) {'Caracteres / \ < > " ? : * | não permitidos'}
        else
            nomeArqPastaValido:= true;
        writeln;
    end;

label desistiu;
begin
    repeat
        mensagem('CTREGESC', 1); {'Digite A para aplicar regra sobre o assunto e R para remetente'}
        r1 := upcase(readkey());
    until r1 in ['A', 'R', ESC];
    if r1 = ESC then goto desistiu;

    repeat
        if r1 = 'A' then
            mensagem('CTREGAAS', 1) {'Digite o assunto sobre o qual deseja aplicar a regra'}
        else
            mensagem('CTREGARE', 1); {'Digite o email do remetente sobre o qual deseja aplicar a regra'}
        sintReadln (nomeRegra);
        nomeRegra := trim(nomeRegra);
        if length(nomeRegra) < 2 then goto desistiu;
        if (r1 = 'R') and (pos('@', nomeRegra) = 0) then
            begin
                mensagem ('CTFOEMIN', 1); {'Formato de e-mail inválido.'}
                continue;
            end;
        if nomeRegra[1] = ';' then delete (nomeRegra, 1, 1);
        if pos('[', nomeRegra) = 1 then nomeRegra := '-' + nomeRegra;
        if carregarRegras (false, false) then
            begin
                res := buscaRegra(nomeRegra);
                descarregarRegras;
            end
        else
            res := 0;
        if res > 0 then
            if r1 = 'A' then
                mensagem('CTREGEXA',1) {'Já existe regra para este assunto'}
            else
                mensagem('CTREGEXR', 1); {'Já existe regra para este remetente'}
    until res = 0;

    repeat
        mensagem('CTREGFAZ', 1); {'O que você deseja fazer com essas cartas? Digite P para mover para pasta ou E para excluir'}
        r2 := upcase(readkey());
    until r2 in ['P', 'E', ESC];
    if r2 = ESC then goto desistiu;

    if r2 = 'P' then
        repeat
            mensagem('CTREGPAS', 1); {'Para qual pasta você deseja mover essa carta?'}
            sintReadln(pastaCarta);
            if trim(pastaCarta) = '' then goto desistiu;
        until nomeArqPastaValido;

    strPCopy (amb, dirRecebe + '\regras.ini');
    strPCopy (keyName, nomeRegra);
    strPCopy(newStr, pastaCarta);
    if r1 = 'A' then
        begin
            if r2 = 'P' then
                WritePrivateProfileString('MOVER ASSUNTO', keyName, newStr, amb)
            else
                WritePrivateProfileString('EXCLUIR', keyName, 'ASSUNTO', amb);
        end
    else //R1 = 'R'
    if r2 = 'P' then
        WritePrivateProfileString('MOVER REMETENTE', keyName, newStr, amb)
    else
        WritePrivateProfileString('EXCLUIR', keyName, 'REMETENTE', amb);

    repeat
        textBackGround (RED);
        mensagem('CTREGAPE', 1); {'Deseja aplicar a regra sobre as cartas existentes?'}
        r1 := upcase(popupMenuPorLetra ('SN'));
        textBackGround (BLACK);
        writeln;
    until r1 in ['S', 'N', ENTER, ESC];
    if r1 = 'S' then
        aplicarRegrasCartas(false, false);

    exit;
desistiu:
    mensagem ('CTDESIST', 2);    {'Desistiu...'}
end;

{-------------------------------------------------------------}
{       Aplica as regras na carta
{-------------------------------------------------------------}

procedure aplicarRegrasCartas (naoLidas, assuntoPrimeiro: boolean);
var
    i, j, cont, indice, numPastas: integer;
    regra, nomeBusca1, nomeBusca2, pasta, dirAtual: string;
    listaPasta : array [1..500] of Taux;
    encontrou : boolean;

    procedure contadorBipa (limite: integer);
    begin
        cont := cont + 1;
        if (cont mod limite) = 0 then
            begin
                sintclek;
                cont := 0;
            end;
    end;

label fim;
begin
    if not carregarRegras (false, false) then
        begin
            msgBaixo ('CTARQREG'); {'Arquivo com as regras não existe.'}
            exit;
        end;
    if numRegras = 0 then
        begin
            mensagem ('CTREGVAZ', 1); {'O arquivo de regras está vazio'}
            exit;
        end;

    getdir (0, dirAtual);
    {$I-} chdir (dirRecebe);  {$I+}
    if ioresult <> 0 then;

    if assuntoPrimeiro then sintBip;
    msgBaixo('CTMOMENT'); {'Um momento ...'}
    if naoLidas then
        montaListaDeCartas ('CAR', 'N')
    else
        montaListaDeCartas ('CAR', 'F');
    if numRegs = 0 then
        begin
            mensagem('CTREGCAR', 1); {'Não existem cartas para aplicar as regras'}
            goto fim;
        end;

    cont := 0;
    numPastas:= 1;
    listaPasta[numPastas].nome := 'Lixeira';
    listaPasta[numPastas].numero := 0;
    for j := 1 to numRegs do
        begin
            contadorBipa (1000);
            if keypressed then
                if quantasCartasDoTotal (j, numRegs) = ESC then
                    begin
                        mensagem ('CTDESIST', 1); {'Desistiu ...'}
                        goto fim;
                    end;
            carregaArqPreencheCabPrin (j);

            if assuntoPrimeiro then
                begin
                    nomeBusca1 := regLido[j]^.carta^.subject;
                    nomeBusca2 := retornaEMail (regLido [j]^.carta^.from);
                end
            else
                begin
                    nomeBusca1 := retornaEMail (regLido [j]^.carta^.from);
                    nomeBusca2 := regLido[j]^.carta^.subject;
                end;
            indice := buscaRegra (nomeBusca1);
            if indice = 0 then
                indice := buscaRegra (nomeBusca2);
            if indice = 0 then continue;
            regra := reg[indice]^.regra;
        if uppercase (regra) = 'EXCLUIR' then
                begin
                    if not apagaCarta (j,  true) then goto fim;
                    pasta := 'Lixeira';
                end
            else
                begin
                    pasta := reg[indice]^.pasta;
                    criaPasta(dirRecebe + '\' +pasta);
                    if copiaUm(regLido[j]^.carta^.nomArqCarta, dirRecebe + '\' + pasta+ '\' + regLido[j]^.carta^.nomArqCarta) then
                        if not apagaCarta (j,  false) then
                            goto fim;
                end;

            encontrou := false;
            for i := 1 to numPastas do
                begin
                    if uppercase(listaPasta[i].nome) = uppercase(pasta) then
                        begin
                            listaPasta[i].numero := listaPasta[i].numero + 1;
                            encontrou := true;
                            break;
                        end;
                end;
            if not encontrou then
                begin
                    numPastas := numPastas + 1;
                    listaPasta [numPastas].nome := pasta;
                    listaPasta [numPastas].numero := 1;
                end;
        end;

    mensagem('CTREGAPL', 1); {'Regras aplicadas'}
    for i := 1 to numPastas do
        if listaPasta[i].numero > 0 then
            begin
                sintWriteInt(listaPasta[i].numero);
                if i = 1 then
                    mensagem('CTCARLIX',1) {'Cartas movidas para a lixeira'}
                else
                    begin
                        mensagem('CTCARPAS', 1); {'Carta movida para a pasta '}
                        sintwriteln(listaPasta[i].nome);
                    end;
            end;

fim:
    descarregarRegras;
    {$I-} chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Retorna se a pasta da regra passada por parâmetro existem em outra regra.
{-------------------------------------------------------------}

function pastaEmOutraRegra (item: integer): boolean;
var i: integer;
begin
    pastaEmOutraRegra := false;
    if uppercase(reg[item]^.regra) <> 'EXCLUIR' then
        for i := 1 to numRegras do
            if (i <> item) and (uppercase(reg[i]^.pasta) = uppercase(reg[item]^.pasta)) then
                begin
                    pastaEmOutraRegra := true;
                    break;
                end;
end;

{-------------------------------------------------------------}
{       Apagar regras
{-------------------------------------------------------------}

procedure apagarRegra (item: integer);

    function apagaUmaRegra ( item: integer): boolean;
    var
        keyName, keyReg, amb, pasta: array [0..144] of char;
        i, j, totalCartas: integer;
        c1 : char;
        dirAtual: string;

    label erro;
    begin
        apagaUmaRegra := false;
        totalCartas := 0;
        if uppercase(reg[item]^.regra) <> 'EXCLUIR' then
            begin
                if DirectoryExists (dirRecebe + '\' + reg[item]^.pasta) then
                    begin
                        getDir (0, dirAtual);
                        chdir(dirRecebe + '\' + reg[item]^.pasta);
                        montaListaDeCartas ('CAR', 'F');
                        if numRegs > 0 then
                            repeat
                                mensagem('CTMOVCAR', 1); {'Deseja mover as cartas desta pasta para o diretório principal?'}
                                mensagem('CTMOVCR2', 0); {'Se não mover, serão perdidas. '}
                                c1 := upcase(readkey());
                                writeln (c1);
                                if c1 = ESC then goto erro;
                            until c1 in ['S', 'N', ENTER, ESC]
                        else
                            c1 := 'N';

                        mensagem('CTMOMENT', 0); {'Um momento ...'}
                        if c1 in ['S', ENTER] then
                            begin
                                for j := 1 to numRegs do
                                    begin
                                        if keypressed then
                                            if quantasCartasDoTotal (j, numRegs) = ESC then
                                                begin
                                                    mensagem ('CTDESIST', 1); {'Desistiu ...'}
                                                    goto erro;
                                                end;
                                        if copiaUm(regLido[j]^.carta^.nomArqCarta, dirRecebe + '\'+ regLido[j]^.carta^.nomArqCarta) then
                                            if not apagaCarta (j, false) then
                                                goto erro;
                                        totalCartas := j;
                                    end;
                            end
                        else
                        for j := 1 to numRegs do
                            begin
                                if keypressed then
                                    if quantasCartasDoTotal (j, numRegs) = ESC then
                                        begin
                                            mensagem ('CTDESIST', 1); {'Desistiu ...'}
                                            goto erro;
                                        end;
                                if not apagaCarta (j, true) then
                                    goto erro;
                                totalCartas := j;
                            end;

                        sintWriteInt (totalCartas); write (' ');
                        if c1 in ['S', ENTER] then
                            begin
                                mensagem('CTCARPAS', 0); {'Cartas movidas para a pasta '}
                                sintWriteln (dirRecebe);
                            end
                        else
                            mensagem('CTCARLIX', 0); {'Cartas movidas para a lixeira'}

                        desmontaListaDeCartas;
                        chdir(dirAtual);
                        if not pastaEmOutraRegra (item) then
                            begin
                                strPCopy(pasta, dirRecebe + '\' + reg[item]^.pasta);
                                RemoveDirectory(pasta);
                            end;
                    end;
            end;

        if (length(reg[item]^.nome) > 0) and (reg[item]^.nome[1] = '[') then
            strPCopy (keyName, '-' + reg[item]^.nome)
        else
            strPCopy (keyName, reg[item]^.nome);
        strPCopy (amb, dirRecebe + '\Regras.ini');
        strPCopy (keyReg, reg[item]^.regra);
        WritePrivateProfileString(keyReg, KeyName, NIL, amb);
        dispose (reg[item]);
        numRegras := numRegras - 1;
        for i := item to numRegras do
            reg[i] :=  reg[i + 1];
        folheiaRemoveItem (item);
        if item <= nFolhe then nFolhe :=  nFolhe - 1;
        apagaUmaRegra := true;
        exit;

    erro:
        desmontaListaDeCartas;
        chdir(dirAtual);
    end;

    function perguntaSeApaga(item: integer): char;
    var
        c: char;
        nomeAux : string;
    begin
        nomeAux := reg[item]^.nome;
        repeat
            mensagem ('CTAPAREG', 0); {'Deseja apagar a regra '}
            if(reg[item]^.regra <> 'EXCLUIR') then
                sintWrite (reg[item]^.regra + ' ' + nomeAux + ' para a pasta ' + reg[item]^.pasta + '  ')
            else
                sintWrite (reg[item]^.regra + ' ' + reg[item]^.pasta + ' ' + nomeAux + '  ');
            mensagem ('CTSIMNAO', 1); {'(S/N) '}
            c := upcase(popupMenuPorLetra ('SNT'));
            writeln;
        until c in ['S', 'N', 'T', ESC];
        perguntaSeApaga := c;
    end;

var
    c: char;
    i, numRegrasAux: integer;
    apagaSelecionados, apagaTodosSelecionados: boolean;

label desistiu;
begin
    telaFolheiaRegras (0);
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
            numRegrasAux := numRegras;
            apagaTodosSelecionados := false;
            for i := numRegrasAux downto 1 do
                if reg[i]^.selecionado then
                    if apagaTodosSelecionados then
                        begin
                            if not apagaUmaRegra (i) then
                                goto desistiu;
                        end
                    else
                        begin
                            c := perguntaSeApaga(i);
                            if c = ESC then goto desistiu;
                            if c = 'T' then apagaTodosSelecionados := true;
                            if c in ['S', 'T'] then
                                if not apagaUmaRegra (i) then
                                    goto desistiu;
                            if c = 'S' then
                                mensagem('CTOKRGAP', 1);  {'Ok, regra apagada'}
                        end;
        end
    else
        begin
            c := perguntaSeApaga(item);
            if c in ['N',ESC] then goto desistiu;
            if not apagaUmaRegra (item) then
                goto desistiu;
            mensagem('CTOKRGAP', 1);  {'Ok, regra apagada'}
        end;

    exit;
desistiu:
    msgBaixo ('CTDESIST');   {'Desistiu'}
end;

{--------------------------------------------------------}
{       procura próximo item no folheamento
{--------------------------------------------------------}

var nomeBusc: string; //Usado na procura do folheamento

function procuraProximoItem(numFolhe: integer): integer;
var
    i: integer;
    buscado, item: string;
begin
    buscado := semAcentos (nomeBusc);
     for i := numFolhe +1 to folheiaNumItens do
        begin
            item := reg [i]^.nome + reg [i]^.pasta;
            if pos (buscado, semAcentos (item)) <> 0 then
                begin
                    procuraProximoItem := i;
                    exit;
                end;
        end;
    sintbip;
    procuraProximoItem := numFolhe;
end;

{-------------------------------------------------------------}
{       Procura um item no folheamento, usa a fuction procuraProximoItem
{-------------------------------------------------------------}

function procuraItem (numFolhe: integer): integer;
begin
    procuraItem := numFolhe;
    gotoxy (1, 24); clreol;
    textbackground (red);
    mensagem ('CTPALPRO', 0);{'Digite a palavra a procurar: '}
    textbackground (black);
    sintReadln (nomeBusc);
    if nomeBusc = '' then
        mensagem ('CTDESIST', 1) {'Desistiu ...'}
    else
        procuraItem := procuraProximoItem (numFolhe);
end;

{-------------------------------------------------------------}
{       Cria o folheamento das regras
{-------------------------------------------------------------}

procedure inicializaFolheamentoRegras;
var
    i: integer;
    regra, nome, pasta: string;
begin
    folheiaCria (1, 6, 80, 21);
    for i :=  1 to numRegras do
        begin
            regra := copy (reg[i]^.regra+BRANCOS, 1, 20);
            nome := copy (reg[i]^.nome + BRANCOS, 1, 25);
            pasta := copy (reg[i]^.pasta + BRANCOS, 1, 45);
            if (trim(regra) = 'EXCLUIR') then
                folheiaAdicionaEspecial (regra + pasta + nome,
                                     reg[i]^.selecionado, regra + pasta +
nome)
            else
                folheiaAdicionaEspecial (regra + nome + ' para a pasta ' + pasta,
                                     reg[i]^.selecionado, regra + nome + ' para a pasta ' + pasta);
        end;
end;

{-------------------------------------------------------------}
{       Verifica se a pasta já está na lista de pastas, se estiver retorna true
{-------------------------------------------------------------}

function jaTemNaLista(k: integer): boolean;
var j: integer;
begin
    jaTemNaLista := true;
    for j := 1 to (k-1) do
        if reg[k]^.pasta = reg[j]^.pasta then
            exit;
    jaTemNaLista := false;
end;

{-------------------------------------------------------------}
{       Cria um popupMenu de pastas de regras, retorna o nome da pasta escolhida e se teve sucesso
{-------------------------------------------------------------}

function obtemNomePastaRegra (var pasta: string): boolean;
var
    i: integer;
begin
    obtemNomePastaRegra := false;
    pasta := '';
    if not carregarRegras (true, true) then
        begin
            msgBaixo ('CTARQREG'); {'Arquivo com as regras não existe.'}
            exit;
        end;
    if numRegras = 0 then
        begin
            mensagem ('CTREGVAZ', 1); {'O arquivo de regras está vazio'}
            exit;
        end;

    mensagem ('CTESCPAS', 2); {'Escolha com as setas a pasta'}
    if not keypressed then delay (300);
    popupMenuCria (wherex, wherey, 79-wherex, numRegras, MAGENTA);
    for i :=  1 to numRegras do
        begin
            if jaTemNaLista(i) then continue;
            pasta := reg[i]^.pasta;
            if not DirectoryExists(dirRecebe + '\' + pasta) then
                criaPasta (dirRecebe + '\' + reg[i]^.pasta);
            popupMenuAdiciona ('', pasta);
        end;
    descarregarRegras;

    popupMenuOrdena;
    popupMenuSeleciona;
    pasta := trim(opcoesItemSelecionado);

    if pasta = '' then
        begin
            mensagem ('CTDESIST', 1);  {'Desistiu...'}
            exit;
        end;
    pasta := dirRecebe + '\' + pasta;
    if not DirectoryExists(pasta) then
        begin
            mensagem ('CTPASNEN', 1); {'Pasta não encontrada'}
            exit;
        end;
    if pasta [length(pasta)] <> '\' then
        pasta := pasta + '\';

    obtemNomePastaRegra := true;
end;

{-------------------------------------------------------------}
{       Cria o folheamento das pastas de regras
{-------------------------------------------------------------}

procedure inicializaFolheamentoPastas;
var
    i: integer;
    pasta: string;
begin
    folheiaCria (1, 6, 80, 21);
    for i :=  1 to numRegras do
        begin
            if jaTemNaLista(i) then continue;
            pasta := copy (reg[i]^.pasta+BRANCOS, 1, 20);
            if DirectoryExists(dirRecebe + '\' + reg[i]^.pasta) then
            begin
                numRegs := 0;
                chdir(dirRecebe + '\' + reg[i]^.pasta);
                montaListaDeCartas ('CAR', 'N');
                if numRegs > 0 then
                begin
                        folheiaAdicionaEspecial ('Pasta: ' +pasta +' possui '+ IntToStr(numRegs)
                                                + ' Cartas não lidas', false,
                                                 reg[i]^.pasta + ' ' + IntToStr(numRegs) +' '+ pegaTextoMensagem('CTNAOLID')); {'Não lidas'}
                end
                else
                        folheiaAdicionaEspecial ('Pasta ' + pasta, false, reg[i]^.pasta);
                chdir(dirRecebe);
            end
            else
            begin
                criaPasta (dirRecebe + '\' + reg[i]^.pasta);
                folheiaAdicionaEspecial ('Pasta ' + pasta, false, reg[i]^.pasta);
            end;
        end;
end;

{-------------------------------------------------------------}
{       Ajuda no folheamento das regras
{-------------------------------------------------------------}

procedure ajudaFolheamentoRegras (listarRegras: boolean);
begin
    writeln;
    if listarRegras then
        mensagem ('CTAJFR01', 2) {'Folheie as regras com as setas, depois tecle:'}
    else
        mensagem ('CTAJPA01', 2); {'Folheie as pastas com as setas, depois tecle:'}
    if (listarRegras) and (not keypressed) then
        mensagem ('CTAJFR02', 2); {'A - Apagar regra'}
    if (not listarRegras) and (not keypressed) then
        begin
            mensagem ('CTAJPA02', 2); {'F - Folhear todas as cartas desta pasta'}
            mensagem ('CTAJUD5A', 2); {'  N   Folhear as cartas não lidas'}
            mensagem ('CTAJUD5B', 2); {'  L   Folhear as cartas lidas'}
            mensagem ('CTAJUD21', 2); {'  G folhear cartas não lidas agrupadas por assunto'}
        end;
    if not keypressed then
        mensagem ('CTAJFR03', 2); {'C - Informa o número de cartas na pasta'}
    if not keypressed then
        mensagem ('CTAJFR04', 2); {'T - Informa tamanho das cartas na pasta'}
    if (listarRegras) and (not keypressed) then
        begin
        mensagem ('CTAJFR05', 2); {'P - Soletra o nome da pasta'}
        mensagem ('CTAJFR06', 2); {'R - Soletra a regra'}
        end;
    if not keypressed then
        delay(300);
end;

{-------------------------------------------------------------}
{       Folheamento das regras, se listarRegras = false lista as pastas
{-------------------------------------------------------------}

procedure folhearRegras (listarRegras: boolean);
var
    c, c2, opc: char;
    k: integer;
    totalAux: int64;
    podeFalar: boolean;
    item, dirAtual, pasta: string;
begin
    if not carregarRegras (not listarRegras, false) then
        begin
            msgBaixo ('CTARQREG'); {'Arquivo com as regras não existe.'}
            exit;
        end;
    if numRegras = 0 then
        begin
            mensagem ('CTREGVAZ', 1); {'O arquivo de regras está vazio'}
            exit;
        end;

    if listarRegras then
        begin
            telaFolheiaRegras (numRegras);
            inicializaFolheamentoRegras;
            mensagem ('CTFOLREG', -1); {'Folheamento das regras'}
        end
    else
        begin
            telaFolheiaPastas (numRegras);
            getDir (0, dirAtual);
            chdir(dirRecebe);
            Sort(1, numRegras, false);
            inicializaFolheamentoPastas;
            chdir(dirAtual);
            mensagem ('CTFOLPAS', -1); {'Folheamento das pastas de regras'}
        end;

    mensagem ('CTUSESET', 0); {'Folheando: use as setas, depois tecle sua opção'}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    textBackground (BLACK);
    writeln;

    nFolhe:= 1;
    podeFalar := true;
    repeat
        if listarRegras then
            telaFolheiaRegras (numRegras)
        else
            telaFolheiaPastas (numRegras);
        folheiaExecuta (nFolhe, nFolhe, c, c2, podeFalar);
        if nFolhe < 1 then NFolhe := 1;
        if nfolhe > folheiaNumItens then nFolhe := folheiaNumItens;
        sintPara;
        for k := 1 to folheiaNumItens do
            folheiaObtemItem (k, item, reg[k]^.selecionado);

        if c = #$0 then
            case c2 of
                F1: ajudaFolheamentoRegras (listarRegras);
                DIR: if listarRegras then sintetiza (reg[nFolhe]^.pasta)
                     else sintSoletra(reg[nFolhe]^.pasta);
                ESQ: if listarRegras then sintetiza(reg[nFolhe]^.nome)
                     else sintetiza(reg[nFolhe]^.pasta);

                F5: if listarRegras then
                        nFolhe := procuraItem (nFolhe)
                    else
                        begin
                            opc := upcase(readkey());
                            if opc in ['A'..'Z', '0' .. '9'] then
                                begin
                                    k := nFolhe + 1;
                                    if k > folheiaNumItens then k := 1;
                                    while (k <> nFolhe) and (maiuscAnsi (reg[k]^.pasta[1]) <> opc) do
                                        if k >= folheiaNumItens then
                                            k := 1
                                        else
                                            k := k + 1;
                                    if maiuscAnsi(reg[k]^.pasta[1]) = opc then
                                        nFolhe := k
                                    else
                                        sintbip;
                                end;
                        end;
                CTLF5: if listarRegras then
                        nFolhe := procuraProximoitem (nFolhe)
                    else
                        msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                F8:     falaHora;
                CTLF8:   falaDia;
            end
        else
            begin
                c := upcase(c);
                case c of
                    'A': if listarRegras then  apagarRegra (nFolhe)
                         else msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                    'I': sintetiza (nomeConfiguracao);
                    ^I: sintSoletra (nomeConfiguracao);

                    'B': if listarRegras then
                            nFolhe := procuraItem (nFolhe)
                        else
                            begin
                                opc := upcase(readkey());
                                if opc in ['A'..'Z', '0' .. '9'] then
                                    begin
                                        k := nFolhe + 1;
                                        if k > folheiaNumItens then k := 1;
                                        while (k <> nFolhe) and (maiuscAnsi (reg[k]^.pasta[1]) <> opc) do
                                            if k >= folheiaNumItens then
                                                k := 1
                                            else
                                                k := k + 1;
                                        if maiuscAnsi(reg[k]^.pasta[1]) = opc then
                                            nFolhe := k
                                        else
                                            sintbip;
                                    end;
                            end;

                ^B:     if listarRegras then
                            nFolhe := procuraProximoitem (nFolhe)
                        else
                            msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    ENTER, 'F', 'L', 'N' : if not listarRegras then
                            begin
                                pasta := reg[nFolhe]^.pasta;
                                if (trim(pasta) = '') or (not DirectoryExists(dirRecebe + '\' + pasta)) then
                                    msgBaixo ('CTPASNEN') {'Pasta não encontrada'}
                                else
                                    begin
                                        if c = ENTER then c := 'F';
                                        folheiaDestroi;
                                        descarregarRegras;
                                        folhearCartas(c, dirRecebe + '\' + pasta);
                                        exit;
                                    end;
                            end
                        else
                            msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                'G', ^G: if not listarRegras then
                            begin
                                pasta := reg[nFolhe]^.pasta;
                                if (trim(pasta) = '') or (not DirectoryExists(dirRecebe + '\' + pasta)) then
                                    msgBaixo ('CTPASNEN') {'Pasta não encontrada'}
                                else
                                    begin
                                        folheiaDestroi;
                                        descarregarRegras;
                                        agruparPorAssunto := true;
                                        if c = ^G then
                                            folhearCartas(^N, dirRecebe + '\' + pasta)
                                        else
                                            folhearCartas('N', dirRecebe + '\' + pasta);
                                        exit;
                                    end;
                            end
                        else
                            msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    'Q', ^Q: falaQualItemDeQuantos (nFolhe, folheiaNumItens, c = ^Q);

                    'C', 'D':    if uppercase(reg[nFolhe]^.regra) = 'EXCLUIR' then
                                falaNumeroCartasDir (dirLixeira, 'F')
                            else
                                falaNumeroCartasDir (dirRecebe + '\' + reg[nFolhe]^.pasta, 'F');
                    ^D: if temItemSelecionado then
                            begin
                                totalAux := 0;
                                for k := 1 to folheiaNumItens do
                                    if reg[k]^.selecionado then
                                        if uppercase(reg[nFolhe]^.regra) = 'EXCLUIR' then
                                            totalAux := totalAux + numeroDeCartas (dirLixeira, 'F')
                                        else
                                            totalAux := totalAux + numeroDeCartas (dirRecebe + '\' + reg[k]^.pasta, 'F');
                                sintetiza (intToStr(totalAux));
                                if totalAux > 1 then
                                    mensagem ('CTCARTAS', -1) {'cartas'}
                                else
                                    mensagem ('CTCARTA', -1); {'carta'}
                            end
                        else
                            mensagem ('CTNAOEXT', -1); {'Não existem selecionadas'}

                    'T':    if uppercase(reg[nFolhe]^.regra) = 'EXCLUIR' then
                                falaTamanhoTodasCartasDir (dirLixeira, 'F')
                            else
                                falaTamanhoTodasCartasDir (dirRecebe + '\' + reg[nFolhe]^.pasta, 'F');
                    ^T: if temItemSelecionado then
                            begin
                                totalAux := 0;
                                for k := 1 to folheiaNumItens do
                                    if reg[k]^.selecionado then
                                        if uppercase(reg[nFolhe]^.regra) = 'EXCLUIR' then
                                            totalAux := totalAux + TamanhoTodasCartasDir (dirLixeira, 'F')
                                        else
                                            totalAux := totalAux + TamanhoTodasCartasDir (dirRecebe + '\' + reg[k]^.pasta, 'F');
                                mensagem ('CTTAMAN', -1); {'Tamanho '}
                                sintetiza (formataTamanhoArq ( totalAux));
                            end
                        else
                            mensagem ('CTNAOEXT', -1); {'Não existem selecionadas'}

                    'P' : sintsoletra (reg[nFolhe]^.pasta);
                    'R': if listarRegras then sintSoletra(reg[nFolhe]^.nome)
                          else sintetiza (reg[nFolhe]^.pasta);

                    ESC: ; //Sair
                else
                    msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;
            end;

        if (c in['Q', ^Q, 'I', ^I, 'T', ^T, 'C', 'D', ^D, 'R', 'P']) or (c2 in [ESQ, DIR, f8, CTLF8]) then
            podeFalar := false
        else
        if (not (c in ['B', ^B, ESC])) and (not (c2 in [F5, CTLF5]))  then
            begin
                msgBaixo ('CTCNTFOL');  {'Continue folheando ou tecle ESC'}
                podeFalar := true;
            end;
        if nFolhe < 1 then NFolhe := 1;

    until (c = ESC) or (numRegras <= 0);

    folheiaDestroi;
    descarregarRegras;
    if c = ESC then
        msgBaixo ('CTFOLFIM');  {'Folheamento terminado'}
    textColor (WHITE);
    telaPrincipal;
end;

{-------------------------------------------------------------}
{       Ajuda do menu principal das regras
{-------------------------------------------------------------}

procedure ajudaRegras;
begin
    writeln;
    if not keypressed then
        mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTREGO00', 1); {'    i - incluir regra'}
    if not keypressed then
        mensagem ('CTREGO01', 1); {'    a - aplicar regra cartas'}
    if not keypressed then
        mensagem ('CTREG002', 1); {'    p - pastas de regras'}
    if not keypressed then
        mensagem ('CTREG003', 1); {'    r - Remover regras'}
end;

{-------------------------------------------------------------}
{       Folheamento das opções do menu principal das regras
{-------------------------------------------------------------}

function selSetasRegras: char;
var n: integer;
const
    tabLetrasConfig: string [4] = 'IAPR';

begin
    popupMenuCria (35, wherey, 44, 4, RED);
    MenuAdiciona ('CTREGO00'); {'   i - incluir regra'}
    MenuAdiciona ('CTREGO01'); {'   a - aplicar regras cartas'}
    MenuAdiciona ('CTREG002'); {'   p - pastas de regras'}
    MenuAdiciona ('CTREG003'); {'   r - Remover regras'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 4) then
        selSetasRegras := tabLetrasConfig[n]
    else
        selSetasRegras := ESC;
end;

{-------------------------------------------------------------}
{       Procedure inicial com as opções principais  das regras
{-------------------------------------------------------------}

procedure inicializaRegras;
var c, c2: char;
label inicio;
begin
inicio:
    telaPrincipal;
    textBackground (RED);
    mensagem ('CTREGINI', 1);{'Regras'}
    mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    sintLeTecla (c, c2);
    textBackground (BLACK);
    writeln;

    if (c = #0) and ((c2 = BAIX) or (c2 = CIMA)) then
        c := selSetasRegras
    else
    if c = #0 then
        begin
            ajudaRegras;
            goto inicio;
        end;

    case upcase (c) of
        'I':  criarRegras;
        'A':  aplicarRegrasCartas(false, false);
        ^A:  aplicarRegrasCartas(false, true);
        'P':  folhearRegras (false);
        'R':  folhearRegras (true);
    else
        if c <> ESC then
            msgBaixo ('CTOPCINV')   {'Opção inválida'}
        else
            msgBaixo ('CTDESIST'); {'Desistiu'}
    end;
end;

begin
end.

