{--------------------------------------------------------}
{    Programa FichaVox}
{   Operações com arquivos}
{--------------------------------------------------------}

unit fvArqui;

interface
    uses windows, dvcrt, dvWin, fvMsg, fvVars, fvEdita;

    procedure carregar_fichas;
    procedure guardar_fichas;
    procedure descarregar_fichas;
    procedure fala_numfichas;
    procedure nova_ficha;
    procedure configurarArquivoModelo;
    procedure imporArqParaFicha;
    function teste_newNomeArq (nNArq: string): boolean;
    function teste_newChave (nChave: string): boolean;
    function newNomeArq_padrao: string;
    procedure Sort(l, r: integer);
    procedure ordenaNomes;
    function semAcentos (s: string): string;

implementation

{--------------------------------------------------------}
{     transforma cadeia em maiusculos nao acentuados
{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}
{              ordena pelo metodo quick sort
{--------------------------------------------------------}

procedure Sort(l, r: Integer);
var
    i, j, xi: integer;
    x: string;
    ppes: Pficha;

begin
    i := l;
    j := r;

    ppes := fichario[(l+r) div 2];
    xi := 0;
    case tipoOrdenacao of
        'N': x := ppes^.chave;
        'O': xi := ppes^.original;
        'A': x := ppes^.nomeArq;
    end;
    if tipoOrdenacao <> 'O' then x := maiuscAnsi (semAcentos (x));

    repeat
        case tipoOrdenacao of
        'N':
            begin
                while maiuscAnsi (semAcentos (fichario[i]^.chave)) < x do
                    i := i + 1;
                while x < maiuscAnsi (semAcentos (fichario[j]^.chave)) do
                    j := j - 1;
            end;

        'O':
            begin
                while (fichario[i]^.original) < xi do
                    i := i + 1;
                while xi < (fichario[j]^.original) do
                    j := j - 1;
            end;

        'A':
            begin
                while maiuscAnsi (semAcentos (fichario[i]^.nomeArq)) < x do
                    i := i + 1;
                while x < maiuscAnsi (semAcentos (fichario[j]^.nomeArq)) do
                    j := j - 1;
            end;
        end;

        if i <= j then
            begin
                ppes := fichario[i];
                fichario[i] := fichario[j];
                fichario[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then Sort(l, j);
    if i < r then Sort(i, r);
end;

procedure ordenaNomes;
var tp2: char;
begin
    if numFichas <= 0 then exit;
    textBackGround (red);
    mensagem ('FVORDEN', 0);     {'Ordenação: N-nome da ficha O-Original  A-Nome do arquivo'}
    textBackGround (black);
    tp2 := upcase (readkey);
    writeln;
    if (tp2 in ['N', 'O', 'A']) then
        tipoOrdenacao := tp2;

    sort (1, numfichas);
    posAtual := 1;
end;

{--------------------------------------------------------}
{                Atualiza o campo original após a remoção de uma ficha
{--------------------------------------------------------}
procedure atualizaOriginal;
    var     k: integer;
    tp2: char;
begin
    if numFichas = 0 then exit;
    tp2 := tipoOrdenacao;
    tipoOrdenacao := 'O';
    Sort(1, numFichas);
    for k := 1 to numFichas do
        fichario[k]^.original := k;
    tipoOrdenacao := tp2;
    Sort(1, numFichas);
end;

{----------------------------------------------------------------------}
{Le o arquivo  FICHAS.IND, gravando-o na memória.}
{----------------------------------------------------------------------}

procedure carregar_fichas;
var
    k: byte;
    i, j, erro: integer;
    s: string;

    procedure carregarAntiga;
    begin
        while not eof (arqIndice) do
        begin
            i := i+1;
            new (fichario[i]);
            if i > 1 then readln (arqIndice, linha);
            k := pos (' ', linha);
            s := copy (linha, 1, k-1);
            val (s, j, erro);
            fichario[i]^.original:= j;
            delete (linha, 1, k);
            k := pos (' ', linha);
            fichario[i]^.nomeArq := copy (linha, 1, k-1);
            delete (linha, 1, k);
            fichario[i]^.chave := linha;
            fichario[i]^.selecionado := FALSE;
        end;
    end;

    procedure carregarNova;
    begin
        while not eof (arqIndice) do
        begin
            i := i+1;
            new (fichario[i]);
            readln (arqIndice, linha);
            val (linha, j, erro);
            fichario[i]^.original:= j;
            readln (arqIndice, fichario[i]^.nomeArq);
            readln (arqIndice, fichario[i]^.chave);
            readln (arqIndice, linha);
            fichario[i]^.selecionado := FALSE;
        end;
    end;


begin
    i := 0;
    numFichas := 0;

    nomearqIndice := 'fichas.ind';
    assign (arqIndice, nomearqIndice);
    {$i-} reset (arqIndice); {$i+}
    if ioresult <> 0 then
        mensagem ('FVARINVA',1) {Fichario vazio...}
    else
    begin
        readln (arqIndice, linha);
        if linha = '@' then
            carregarNova
        else
            carregarAntiga;

        if i > 0 then
        begin
            numFichas := i;
            Sort(1, numFichas);
        end;

        close (arqIndice);
    end;
end;

{----------------------------------------------------------------------}
{Grava no arquivo FICHAS.IND a lista que está na memória.}
{----------------------------------------------------------------------}

procedure guardar_fichas;
var
    i, j: integer;
    tp2: char;

begin
    if numFichas = 0 then exit;
    atualizaOriginal;
    tp2 := tipoOrdenacao;
    tipoOrdenacao := 'O';
    Sort(1, numFichas);
    i := 0;
    nomearqIndice := 'FICHAS.IND';
    assign (arqIndice, nomearqIndice);
    {$i-} reWrite (arqIndice); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        exit;
    end;

    writeln (arqIndice, '@');

    repeat
        i := i+1;
        j := fichario[i]^.original;
        {$i-} str (j, linha); {$i+}
        if ioresult <> 0 then;
        writeln (arqIndice, linha);
        linha := fichario[i]^.nomeArq;
        writeln (arqIndice, linha);
        linha := fichario[i]^.chave;
        writeln (arqIndice, linha);
        writeln (arqIndice, '@');
    until     i >= numFichas;

    close (arqIndice);

    tipoOrdenacao := tp2;
    Sort(1, numFichas);
end;

{----------------------------------------------------------------------}
{Desaloca da memória o pontero fichario.}
{----------------------------------------------------------------------}

procedure descarregar_fichas;
var
    i: integer;

begin
    if numFichas <= 0 then exit;
    for i := 1 to numFichas do
        dispose (fichario[i]);
end;

{----------------------------------------------------------------------}
{Fala o número de fichas no fichario atual.}
{----------------------------------------------------------------------}

procedure fala_numfichas;
begin
    mensagem ('FVNUMTFI',0); {Numero de fichas nesse fichario : }
    sintWriteInt (numFichas);
    writeln;
    delay (250);
end;

{----------------------------------------------------------------------}
{ Função que testa se já existe arqivo de ficha com este nome.}
{----------------------------------------------------------------------}

function teste_newNomeArq (nNArq: string): boolean;
var
    i: integer;

begin
    if numFichas =0 then
        begin
            teste_newNomeArq := true;
            exit;
        end;
    if nNArq = 'FICHAS.IND' then
        begin
            teste_newNomeArq := FALSE;
            exit;
        end;
    if nNArq = 'MODELO.TXT' then
        begin
            teste_newNomeArq := FALSE;
            exit;
        end;
    i := 0;
    repeat
        i := i + 1;
    until (maiuscAnsi(nNArq) = maiuscAnsi(Fichario[i]^.nomeArq))
          or (i = numFichas);

    if maiuscAnsi(nNArq) = maiuscAnsi(Fichario[i]^.nomeArq) then
        teste_newNomeArq := false
    else
        teste_newNomeArq := true;

end;

{----------------------------------------------------------------------}
{Função que testa se já existe ficha com esta chave}
{----------------------------------------------------------------------}

function teste_newChave (nChave: string): boolean;
var
    i: integer;

begin
    if numFichas =0 then
        begin
            teste_newChave := true;
            exit;
        end;

    i := 0;

    repeat
        i := i + 1;
    until (nChave = Fichario[i]^.chave) or (i = numFichas);

    if nChave = Fichario[i]^.chave then
        teste_newChave := false
    else
        teste_newChave := true;

end;

{----------------------------------------------------------------------}
{Atribuição de nome padrão para o arquivo (<número>.txt).}
{----------------------------------------------------------------------}

function newNomeArq_padrao: string;
var
    nNArq: string;
    i: integer;
    s: string;

begin
    i := 0;
    repeat
        i := i + 1;
        str (i, s);
        nNArq := s + '.txt';
    until teste_newNomeArq (nNArq);
    newNomeArq_padrao := nNArq;
end;

{----------------------------------------------------------------------}
{Copia o modelo para ficha. supondo que já exista o arquivo modelo.}
{----------------------------------------------------------------------}

procedure copiar_arquivo_modelo (nNArq: string);
var
    nArq, arqModelo: text;
begin
    assign (arqmodelo, 'modelo.txt');
    {$i-} reset (arqModelo); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVMODBRA', 1);
            {$i-} reWrite (arqModelo); {$i+}
            if ioresult <> 0 then
            begin
                mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
                exit;
            end;
        end;

    assign (nArq, nNArq);
    {$i-} reWrite (nArq); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        exit;
    end;

    while not eof (arqModelo) do
        begin
            Readln (arqModelo, linha);
            Writeln (nArq, linha);
        end;
    close (nArq);
    close (arqModelo);
end;

{----------------------------------------------------------------------}
{Copia um arquivo para o modelo ou para nova ficha.}
{----------------------------------------------------------------------}

function copParamodOuNewFich (nomeArqModelo: string):boolean;
var
    arqModelo, arqAux: text;
    nomeArqAux: string;
    opc: char;
begin
    repeat
        mensagem('FVNOMMOD', 1);
        {Digite o nome do arquivo que servirá como modelo }
        sintReadln (nomeArqAux);
        if nomeArqAux = '' then
           begin
              mensagem ('FVDESIST',1);
              copParamodOuNewFich := false;
              exit;
           end;

        assign (arqAux, NomeArqAux);
        {$i-} reset (arqAux); {$i+}
        if ioresult <> 0 then
            begin
                mensagem ('FVNAOEXS',1); {Arquivo não existe}
                mensagem ('FVTENNOV', 0); {Deseja tentar novamente? }
                opc := upcase (readkey);
                writeln;
                if opc <> 'S' then
                    begin
                        mensagem ('FVDESIST',1);
                        copParamodOuNewFich := false;
                        exit;
                    end;
            end
        else
            opc := 'N';
    until opc = 'N';
    assign (arqmodelo, 'modelo.txt');
    {$i-} reWrite (arqModelo); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        copParamodOuNewFich := false;
        exit;
    end;

    while not eof (arqAux) do
        begin
            Readln (arqAux, linha);
            Writeln (arqModelo, linha);
        end;
    close (arqAux);
    close (arqModelo);
    copParamodOuNewFich := true;
end;

{----------------------------------------------------------------------}
{Cria a ficha modelo se não existir nenhuma no diretório atual.}
{----------------------------------------------------------------------}

procedure criar_ficha_modelo (atual: boolean);
var
    arqModelo: text;
    opc, lixo: char;

begin
    assign (arqModelo, 'modelo.txt');
    {$i-} reset (arqModelo); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVMODBRA',1); {Modelo em branco.}
            mensagem ('FVCOPIQM', 0);{Deseja copiar algum modelo }
            sintLeTecla (opc, lixo);
            writeln;
            if upcase(opc) = 'S' then
                begin
                    if copParamodOuNewFich ('modelo.txt') then
                        copiar_arquivo_modelo (newNomeArq);
                end
            else
                mensagem ('FVMODFIB',1); {Modelo ficou em branco}
            exit;
        end;

    if atual then
        begin
            copiar_arquivo_modelo (newNomeArq);
            mensagem ('FVMODATU',1); {Modelo  atual}
        end
    else
        begin
            mensagem ('FVOUTMOD', 0); {Deseja usar outro modelo? }
            sintLeTecla (opc, lixo);
            writeln;
            if upcase(opc) = 'S' then
                copParamodOuNewFich (newNomeArq)
            else
                mensagem ('FVFICBRA',1); {Ficha em branco.}
        end;
end;

{----------------------------------------------------------------------}
{Procedimento principal da utilização da ficha modelo.}
{----------------------------------------------------------------------}

procedure ficha_modelo;
var
    opc, lixo: char;

begin
    mensagem ('FVDESMOD', 0);
    { 'Deseja utilizar modelo atual?'}
    sintLeTecla (opc, lixo);
    writeln;
    if upcase(opc) = 'S' then
            criar_ficha_modelo (TRUE)
    else
            criar_ficha_modelo (FALSE);
end;

{----------------------------------------------------------------------}
{Configura o arquivo modelo, editando ou importando de outro arquivo.}
{----------------------------------------------------------------------}

procedure configurarArquivoModelo;
var      opc: char;
    arqModelo: text;
begin
    textBackGround (red);
    mensagem ('FVQUAOPC', 0);{Qual sua opção?}
    mensagem ('FVEDIMOD', 0);{E-Editar,   I-Importar, ESC-Cancelar.}
    textBackGround (black);
    opc := upcase (readkey);
    writeln;
    case opc of
        'E': begin
                assign (arqmodelo, 'modelo.txt');
                {$i-} reset (arqModelo); {$i+}
                if ioresult <> 0 then
                    begin
                        mensagem ('FVMODBRA', 1);
                        {$i-} reWrite (arqModelo); {$i+}
                        if ioresult <> 0 then
                        begin
                            mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
                            exit;
                        end;
                    end;
                close (arqModelo);
                editarArquivo ('modelo.txt');
             end;

        'I': begin
                assign (arqmodelo, 'modelo.txt');
                {$i-} reset (arqModelo); {$i+}
                if ioresult <> 0 then
                    begin
                        mensagem ('FVMODBRA', 1);
                        {$i-} reWrite (arqModelo); {$i+}
                            if ioresult <> 0 then
                        begin
                            mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
                            exit;
                        end;
                    end;
                close (arqModelo);
                if copParamodOuNewFich ('modelo.txt') then
                   mensagem ('OK',1);
             end;

        ESC: mensagem ('FVDESIST',1)
    else
        mensagem ('FVDESIST',1);
    end;
end;

{----------------------------------------------------------------------}
{Pega um nome para ficha e para um arquivo}
{----------------------------------------------------------------------}

function nomeFicha: boolean;
var
    k: integer;

begin
    k := 0;
    repeat
        if k = 0 then
            mensagem ('FVNOMFIC', 1) {Digite o nome da ficha: }
        else
            mensagem ('FVOUTRON', 1);{Já existe ficha com este nome, digite outro: }

        sintReadln (newChave);
        if newChave = '' then
           begin
              nomeFicha := false;
              exit;
           end;
        k := k+1;
    until teste_newChave(newChave);
    nomeFicha := true;
end;

{----------------------------------------------------------------------}
procedure nomeArquivo;
var
    k: integer;

begin
    k := 0;
    repeat
        if k = 0 then
            mensagem ('FVNEWARQ', 1) {Digite um nome para o arquivo, ou tecle ENTER para assumir padrão: }
        else
            mensagem ('FVARQEXI', 1);{Já existe arquivo com este nome, digite outro: }

        sintReadln (newNomeArq);
        if newNomeArq = '' then
            newNomeArq := newNomeArq_padrao;
        k := k+1;
    until teste_newNomeArq(newNomeArq);
end;

{----------------------------------------------------------------------}
{Cria uma nova ficha.}
{------------------------------------------------------------------}

procedure nova_ficha;
var
    i: integer;
    opc: char;

begin
    textBackGround (red);
    mensagem ('FVNEWFIC', 0); {Nova Ficha}
    textBackGround (black);
    writeln;

    if numFichas >= NUMMAXFICHAS Then
        begin
            mensagem ('FVDIRCHE',1);   {O fichario já esta cheio.}
            exit;
        end;
    if not nomeFicha then
       begin
          mensagem ('FVDESIST',1);
          exit;
       end;

    nomeArquivo;
    assign (newArq, newNomeArq);
    {$i-} reWrite (newArq); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        exit;
    end;
    close (newArq);
    i:= numFichas+1;
    new (Fichario[i]);
    Fichario[i]^.nomeArq := newNomeArq;
    Fichario[i]^.chave := newChave;
    Fichario[i]^.original := i;
    fichario[i]^.selecionado := FALSE;
    numFichas := i;
    mensagem ('FVFCRISU',1); {Ficha criada}
    guardar_fichas;
    ficha_modelo;
    writeln;
    mensagem ('FVPEDFI', 0);{Deseja editar a ficha agora '}
    opc := upcase (readkey);
    writeln;
    if opc = 'S' then
        begin
            editarArquivo (newNomeArq);
        end;
end;

{----------------------------------------------------------------------}
{Importa um arquivo, copiando-o para uma nova ficha}
{----------------------------------------------------------------------}

procedure imporArqParaFicha;
var
    arqAux: text;
    nomeArqAux: string;
    i: integer;
    opc: char;

begin
    if numFichas >= NUMMAXFICHAS Then
        begin
            mensagem ('FVDIRCHE',1);{O fichario já esta cheio.}
            exit;
        end;

    repeat
        mensagem ('FVNOMORG', 1);        {'Informe o arquivo txt a importar: '}
        sintReadln (nomeArqAux);
        writeln;
        if nomeArqAux = '' then
            begin
                mensagem ('FVDESIST',1);
                exit;
            end;
        assign (arqAux, NomeArqAux);
        {$i-} reset (arqAux); {$i+}
        if ioresult <> 0 then
            begin
                mensagem ('FVNAOEXS',1); {Arquivo não existe}
                mensagem ('FVTENNOV', 0); {Deseja tentar novamente? }
                opc := upcase (readkey);
                writeln;
                if opc <> 'S' then
                    begin
                        mensagem ('FVDESIST',1);
                        exit;
                    end;
            end
        else
            begin
                opc := 'N';
                close (arqAux);
            end;
    until opc = 'N';
    nomeFicha;
    if newChave = '' then
        begin
            mensagem ('FVDESIST',1);
            exit;
        end;
    nomeArquivo;
    assign (arqAux, NomeArqAux);
    {$i-} reset (arqAux); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        exit;
    end;
    i:= numFichas+1;
    new (Fichario[i]);
    Fichario[i]^.nomeArq := newNomeArq;
    Fichario[i]^.chave := newChave;
    Fichario[i]^.original := i;
    fichario[i]^.selecionado := FALSE;
    numFichas := i;
    assign (newArq, newNomeArq);
    {$i-} reWrite (newArq); {$i+}
    if ioresult <> 0 then
    begin
        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
        exit;
    end;
    while not eof (arqAux) do
        begin
            Readln (arqAux, linha);
            Writeln (newArq, linha);
        end;
    close (arqAux);
    close (newArq);
    mensagem ('FVFCRISU',1); {Ficha criada}
    guardar_fichas;
    writeln;
    mensagem ('FVPEDFI', 0);{Deseja editar a ficha agora '}
    opc := upcase (readkey);
    writeln;
    if opc = 'S' then
        begin
            editarArquivo (newNomeArq);
        end;
end;

{----------------------------------------------------------------------}

end.
