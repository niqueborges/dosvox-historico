{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de arquivamento
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joarq;

interface

uses
    dvwin, dvcrt, dvForm, windows, sysUtils, dvArq, jovars, jomsg;

function criaPastaJogo: string;
function escolhePastaJogo: string;
function pegaNomeJogo (var nomeArq: string): boolean;
procedure criaJogoModelo;
function carregaEstruturaJogo (nomeArq: string): boolean;
function salvaJogo: boolean;
function salvaComOutroNome: boolean;
function pegaNumero(lido: string): integer;
function geraListaArqs (masc: string): string;
function normalizaLista (listaMidias: string): string;

implementation

uses Classes;

{--------------------------------------------------------}
{             inicialização da estrutura de dados
{--------------------------------------------------------}

procedure inicDadosGerais;
var ano, mes, dia, diaSemana: word;
    i: integer;
begin
    with jogo.dadosGerais do
        begin
            nomeJogo := 'Jogo experimental';
            autor := 'Projeto DOSVOX - NCE/UFRJ';
            getDate(ano, mes, dia, diaSemana);
            dataCriacao := intToStr (dia) + '/' +
                           intToStr (mes) + '/' +
                           intToStr (ano) + ' - ' +
                           diasDaSemana [diaSemana];
            versao := '1.0';
            dataVersao := dataCriacao;
            for i := 1 to 5 do
                comentarios[i] := '';
            ncoment := 0;
            nomeScriptControlador := '';
        end;
end;

{--------------------------------------------------------}

procedure inicEstrutJogo;
var i: integer;
begin
    with jogo do
        begin
            numLugares := 0;
            for i := 1 to maxLugares do
                lugares[i] := NIL;
            fundoDefault := '';
            fonteTexto.nomeFonte := 'Arial';
            fonteTexto.tamFonte := 24;
            fonteTexto.negrito := false;
            corFundoDefault := 'Preto';
            corLetraDefault := 'Branco';
            narrando := true;
            aleatorio := false;
        end;
end;

{--------------------------------------------------------}

procedure inicLugar (umLugar: PLugar);
var i: integer;
begin
    with umLugar^ do
        begin
            nome := 'Capa';
            categoria := '';
            respostaEsperada := '';
            memoriaResposta := '';
            lugarOk := '';
            lugarErro := '';
            pontuacao := 0;
            jogoTerminaAqui := false;
            midiaLugar := '';
            fundo := '';
            numSlides := 0;
            for i := 1 to MAXSLIDESLUGAR do
                 slides[i] := NIL;
            scriptEntrada := '';
            scriptSaida := '';
        end;

    indSlideEditando := 1;
end;

{--------------------------------------------------------}

procedure inicSlide (umSlide: PSlide);
begin
    with umSlide^ do
       begin
           titulo := 'Meu jogo';
           figura := '';
           midiaSlide := '';
           esperaMidia := true;
           efeito := '';
           avancaEm := '';
           falaTexto := '';
           texto := TStringList.Create;
       end;
end;

{--------------------------------------------------------}
{             cria jogo com valores iniciais
{--------------------------------------------------------}

procedure criaJogoModelo;
var
    umLugar: PLugar;
begin
    inicDadosGerais;
    inicEstrutJogo;

    new (umLugar);
    inicLugar (umLugar);
    jogo.lugares[1] := umLugar;
    jogo.numLugares := 1;
end;

{--------------------------------------------------------}
{              troca travessões por hífen
{--------------------------------------------------------}

procedure trocaTravessao(var s: string);
var i: integer;
begin
    for i := 1 to length(s) do
        if ord(s[i]) = 150 then
           s[i] := '-';
end;

{--------------------------------------------------------}
{              carrega a estrutura do jogo
{--------------------------------------------------------}

function carregaEstruturaJogo (nomeArq: string): boolean;
var
    arq: textFile;
    linha: integer;
    lido: string;
    prelido: boolean;

    {--------------------------------------------------------}

    procedure erroNoArquivo;
    begin
        mensagem ('JOERRARQ', 1);     // Erro ao ler o arquivo do jogo
        if linha > 0 then
            begin
                mensagem ('JOLINHA', 0);    // O problema está na linha
                sintWriteln (intToSTr(linha));
                mensagem ('JOCONTEU', 1);   // Conteúdo lido:
                sintWriteln (lido);
                limpaBufTec;
                mensagem ('JOAPTENT', 1);   // Aperte Enter
                readln;
            end;
    end;

    {--------------------------------------------------------}

    procedure separaParam (lido: string; var param, valor: string);
    var p: integer;
    begin
        param := lido;
        valor := '';
        p := pos ('=', lido);
        if p <= 0 then exit;

        param := trim (ansiUpperCase (copy (lido, 1, p-1)));
        valor := copy (lido, p+1, 999);
    end;

    {--------------------------------------------------------}

    function extraiFonte (valor: string): TFonteLetras;
    var fonte: TFonteLetras;
        p: integer;
    begin
        with fonte do
            begin
                tamFonte := 20;
                negrito := false;

                p := pos (',', valor);
                if p <= 0 then
                    p := length (valor) + 1;
                nomeFonte := copy (valor, 1, p-1);
                delete (valor, 1, p);

                p := pos (',', valor);
                if p > 0 then
                try
                    tamFonte := strToInt (trim(copy (valor, 1, p-1)));
                    delete (valor, 1, p);
                except
                end;

                if valor <> '' then
                    negrito := copy (valor, 1, 1) <> '0';

                hfonte := 0;
                larguraLetra := 0;
                alturaLetra := 0;
            end;

        result := fonte;
    end;

    {--------------------------------------------------------}

    function leDadosGerais: boolean;
    var param, valor: string;
        i: integer;
    begin
        result := true;
        inicDadosGerais;
        while not eof (arq) do
            begin
                linha := linha + 1;
                {$I-} readln (arq, lido); {$I+}
                if ioresult <> 0 then
                    begin
                        result := false;
                        lido := '';
                        exit;
                    end;

                if (trim(lido) = '') or (lido[1]  = ';') then continue;
                trocaTravessao (lido);
                separaParam (lido, param, valor);
                param := semAcentos(param);
                with jogo.dadosGerais do
                    begin
                        if param = 'NOME DO JOGO' then nomeJogo := valor
                        else
                        if param = 'AUTOR' then autor := valor
                        else
                        if param = 'DATA DE CRIACAO' then dataCriacao := valor
                        else
                        if param = 'VERSAO' then versao := valor
                        else
                        if param = 'DATA DA VERSAO' then dataVersao := valor
                        else
                        if param = 'SCRIPT' then nomeScriptControlador := valor
                        else
                        if param = 'COMENTARIOS' then comentarios[1] := valor
                        else
                        if param='COMENTARIOS2' then comentarios[2] := valor
                        else
                        if param='COMENTARIOS3' then comentarios[3] := valor
                        else
                        if param='COMENTARIOS4' then comentarios[4] := valor
                        else
                        if param='COMENTARIOS5' then comentarios[5] := valor
                        else
                            begin
                                if param[1] = '[' then prelido := true
                                                  else result := false;
                                break;
                            end;
                    end;
            end;

        nComent := 0;
        for i := 1 to 5 do
            if jogo.dadosGerais.comentarios[i] <> '' then ncoment := i;
    end;

    {--------------------------------------------------------}

    function leModelo: boolean;
    var param, valor: string;
    begin
        result := true;
        inicEstrutJogo;
        while not eof (arq) do
            begin
                linha := linha + 1;
                {$I-} readln (arq, lido); {$I+}
                if ioresult <> 0 then
                    begin
                        result := false;
                        lido := '';
                        exit;
                    end;

                if (trim(lido) = '') or (lido[1]  = ';') then continue;
                trocaTravessao (lido);
                separaParam (lido, param, valor);
                param := semAcentos(param);
                with jogo do
                    begin
                        if param = 'FUNDO' then fundoDefault := valor
                        else
                        if param = 'FONTE DO TEXTO' then fonteTexto := extraiFonte (valor)
                        else
                        if param = 'COR DO FUNDO' then corFundoDefault := valor
                        else
                        if param = 'COR DA LETRA' then corLetraDefault := valor
                        else
                        if param = 'LUGARES' then numLugares := strToInt (valor)
                        else
                        if param = 'NARRANDO' then narrando := ansiUpperCase(copy (valor, 1, 1)) <> 'N'
                        else
                        if param = 'ALEATORIO' then aleatorio := ansiUpperCase(copy (valor, 1, 1)) <> 'N'
                        else
                            begin
                                if param[1] = '[' then prelido := true
                                                  else result := false;
                                break;
                            end;
                    end;
            end;
    end;

    {--------------------------------------------------------}

    function leLugar (var numLugar: integer; var umLugar: PLugar): boolean;
    var param, valor: string;
    begin
        lido := trim (lido);
        delete (lido, 1, 6);
        delete (lido, length (lido), 1);
        lido := trim (lido);
        try
            numlugar := strToInt (lido);
        except
            result := false;
            exit;
        end;

        new (umLugar);
        inicLugar(umLugar);
        result := true;
        while not eof (arq) do
            begin
                linha := linha + 1;
                {$I-} readln (arq, lido); {$I+}
                if ioresult <> 0 then
                    begin
                        result := false;
                        lido := '';
                        exit;
                    end;

                if (trim(lido) = '') or (lido[1]  = ';') then continue;
                trocaTravessao (lido);
                with umLugar^ do
                    begin
                        separaParam (lido, param, valor);
                        param := semAcentos(param);
                        if param = 'NOME' then nome := valor
                        else
                        if param = 'DESCRICAO' then // compatibilidade com versão antiga
                        else
                        if param = 'CATEGORIA' then categoria := valor
                        else
                        if param = 'RESPOSTA ESPERADA' then respostaEsperada := valor
                        else
                        if param = 'MEMORIA DA RESPOSTA' then memoriaResposta := valor
                        else
                        if param = 'LUGAR OK' then lugarOK := valor
                        else
                        if param = 'LUGAR ERRO' then lugarErro := valor
                        else
                        if param = 'PONTUACAO' then pontuacao := pegaNumero(valor)
                        else
                        if param = 'TERMINADOR' then jogoTerminaAqui :=
                                        ansiUpperCase (copy(valor+' ', 1,1)) = 'S'
                        else
                        if param = 'MIDIA' then midiaLugar := valor
                        else
                        if param = 'COR DO FUNDO' then corFundo := valor
                        else
                        if param = 'COR DA LETRA' then corLetra := valor
                        else
                        if param = 'FUNDO' then fundo := valor
                        else
                        if param = 'IMAGEMA' then imagemA := valor
                        else
                        if param = 'IMAGEMB' then imagemB := valor
                        else
                        if param = 'NUMERO DE SLIDES' then numSlides := strToInt (valor)
                        else
                        if param = 'SCRIPT ENTRADA' then scriptEntrada := valor
                        else
                        if param = 'SCRIPT SAIDA' then scriptSaida := valor
                        else
                            begin
                                if param[1] = '[' then prelido := true
                                                  else result := false;
                                break;
                            end;
                    end;
            end;
    end;

    {--------------------------------------------------------}

    function leSlide (var numLugar, numSlide: integer; var umSlide: PSlide): boolean;
    var param, valor: string;
        p: integer;

    begin
        lido := trim (lido);
        delete (lido, length (lido), 1);
        lido := trim (lido);
        try
            p := pos (' ', lido);
            numlugar := strToInt (copy (lido, 1, p-1));
            delete (lido, 1, p);
            lido := trim (lido);
            numSlide := strToInt (lido);
        except
            result := false;
            exit;
        end;

        new (umSlide);
        inicSlide(umSlide);
        result := true;
        while not eof (arq) do
            begin
                linha := linha + 1;
                {$I-} readln (arq, lido); {$I+}
                if ioresult <> 0 then
                    begin
                        result := false;
                        lido := '';
                        exit;
                    end;

                if (trim(lido) = '') or (lido[1]  = ';') then continue;
                trocaTravessao (lido);
                with umSlide^ do
                    begin
                        separaParam (lido, param, valor);
                        param := semAcentos(param);
                        if param = 'TITULO' then titulo := valor
                        else
                        if param = 'FIGURA' then figura := valor
                        else
                        if param = 'POSICAO FIGURA' then posFigura := valor
                        else
                        if param = 'MIDIA' then midiaSlide := valor
                        else
                        if param = 'ESPERA MIDIA' then
                            esperaMidia := (copy (valor, 1, 1) = 'S') or
                                           (copy (valor, 1, 1) = '1')
                        else
                        if param = 'AUTO AVANCA' then avancaEm := valor
                        else
                        if param = 'EFEITO' then efeito := valor
                        else
                        if param = 'FALA TEXTO' then
                            falaTexto := valor
                        else
                        if param = 'POSICAO TEXTO' then posTexto := valor
                        else
                        if copy (param, 1, 1)[1] in ['0'..'9'] then
                            texto.Add(valor)
                        else
                            begin
                                if param[1] = '[' then prelido := true
                                                  else result := false;
                                break;
                            end;
                    end;
            end;
    end;

    {--------------------------------------------------------}

var ok: boolean;
    numLugar, numSlide: integer;
    umLugar: PLugar;
    umSlide: PSlide;
begin
    result := false;
    linha := 0;

    assignFile (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            erroNoArquivo;
            exit;
        end;

    prelido := false;
    ok := true;
    while (not eof (arq)) and ok do
        begin
            if not prelido then   // às vezes o parser já leu o título
                begin
                    linha := linha + 1;
                    {$I-} readln (arq, lido);  {$I+}
                    if ioresult <> 0 then
                        begin
                            erroNoArquivo;
                            exit;
                        end;
                end;

            prelido := false;
            if trim(lido) = '' then continue;
            if lido[1] = ';' then continue;

            trocaTravessao (lido);
            if ansiUpperCase (lido) = '[DADOS GERAIS]' then
                ok := leDadosGerais
            else
            if ansiUpperCase (lido) = '[MODELO]' then
                ok := leModelo
            else
            if ansiUpperCase (copy (lido, 1, 7)) = '[LUGAR ' then
                begin
                    ok := leLugar (numLugar, umLugar);
                    if ok then
                        begin
                            if jogo.numLugares < numLugar then
                                jogo.numLugares := numLugar;
                            jogo.lugares[numLugar] := umLugar;
                        end;
                end
            else
            if ansiUpperCase (copy (lido, 1, 7)) = '[SLIDE ' then
                begin
                     delete (lido, 1, 7);
                     ok := leSlide (numLugar, numSlide, umSlide);
                     if ok then
                        begin
                            if jogo.lugares[numLugar] = NIL then
                                begin
                                    mensagem ('JOLSLINV', 1);  // lugar do slide é inválido
                                    ok := false;
                                end
                            else
                                begin
                                     jogo.lugares[numLugar]^.slides[numSlide] := umSlide;
                                end;
                        end;
                end
            else
                ok := false;
        end;

    if not ok then
        erroNoArquivo;

    closeFile (arq);
    result := ok;
end;

{--------------------------------------------------------}
{                   salva o jogo
{--------------------------------------------------------}

function salvaJogo: boolean;
var
    arq: textFile;

    {--------------------------------------------------------}

    function guardaDadosGerais: boolean;
    begin
        result := true;
        with jogo.dadosGerais do
            try
                writeln (arq, '[DADOS GERAIS]');
                writeln (arq, 'NOME DO JOGO=', nomeJogo);
                writeln (arq, 'AUTOR=', autor);
                writeln (arq, 'DATA DE CRIAÇÃO=', dataCriacao);
                writeln (arq, 'VERSÃO=', versao);
                writeln (arq, 'DATA DA VERSÃO=', dataVersao);
                if nomeScriptControlador <> '' then
                    writeln (arq, 'SCRIPT=', nomeScriptControlador);
                if comentarios[1] <> '' then
                    writeln (arq, 'COMENTÁRIOS=',  comentarios[1]);
                if ncoment > 1 then
                    begin
                        writeln (arq, 'COMENTÁRIOS2=', comentarios[2]);
                        writeln (arq, 'COMENTÁRIOS3=', comentarios[3]);
                        writeln (arq, 'COMENTÁRIOS4=', comentarios[4]);
                        writeln (arq, 'COMENTÁRIOS5=', comentarios[5]);
                    end;
            except
                result := false;
            end;
    end;

    {--------------------------------------------------------}

    function guardaInfra: boolean;
    begin
        result := true;
        with jogo do
            try
                writeln (arq);
                writeln (arq, '[MODELO]');
                writeln (arq, 'LUGARES=', numLugares);
                if fundoDefault <> '' then
                    writeln (arq, 'FUNDO=', fundoDefault);
                with fonteTexto do
                    writeln (arq, 'FONTE DO TEXTO=', nomeFonte, ',',
                                   intToStr(tamFonte), ',', strBool(negrito));
                if corFundoDefault <> '' then
                    writeln (arq, 'COR DO FUNDO=', corFundoDefault);
                if corLetraDefault <> '' then
                    writeln (arq, 'COR DA LETRA=', corLetraDefault);
                if narrando then
                    writeln (arq, 'NARRANDO=', strBool(narrando));
                if aleatorio then
                    writeln (arq, 'ALEATÓRIO=', strBool(aleatorio));
            except
                result := false;
            end;
    end;

    {--------------------------------------------------------}

    function gravaLugar (nlug: integer): boolean;
    begin
        result := true;
        if jogo.lugares[nlug] <> NIL then // evita problemas
          with jogo.lugares[nlug]^ do
            try
                writeln (arq);
                writeln (arq, '[LUGAR ', nlug, ']');
                writeln (arq, 'NOME=', nome);
                writeln (arq, 'NÚMERO DE SLIDES=', numSlides);
                if categoria <> '' then
                    writeln (arq, 'CATEGORIA=', categoria);
                if respostaEsperada <> '' then
                    writeln (arq, 'RESPOSTA ESPERADA=', respostaEsperada);
                if memoriaResposta <> '' then
                    writeln (arq, 'MEMÓRIA DA RESPOSTA=', memoriaResposta);
                if lugarOK <> '' then
                    writeln (arq, 'LUGAR OK=', lugarOk);
                if lugarErro <> '' then
                    writeln (arq, 'LUGAR ERRO=', lugarErro);
                if pontuacao <> 0 then
                    writeln (arq, 'PONTUAÇÃO=', pontuacao);
                if jogoTerminaAqui then
                    writeln (arq, 'TERMINADOR=', strBool(jogoTerminaAqui));
                if midiaLugar <> '' then
                    writeln (arq, 'MÍDIA=', midiaLugar);
                if corFundo <> '' then
                    writeln (arq, 'COR DO FUNDO=', corFundo);
                if corLetra <> '' then
                    writeln (arq, 'COR DA LETRA=', corLetra);
                if fundo <> '' then
                    writeln (arq, 'FUNDO=', fundo);
                if ImagemA <> '' then
                    writeln (arq, 'IMAGEMA=', imagemA);
                if ImagemB <> '' then
                    writeln (arq, 'IMAGEMB=', imagemB);
                if scriptEntrada <> '' then
                    writeln (arq, 'SCRIPT ENTRADA=', scriptEntrada);
                if scriptSaida <> '' then
                    writeln (arq, 'SCRIPT SAÍDA=', scriptSaida);
            except
                result := false;
            end;
    end;

    {--------------------------------------------------------}

    function gravaSlides (nlug: integer): boolean;
    var sld, l: integer;
    begin
        result := true;
        with jogo.lugares[nlug]^ do
            try
                for sld := 1 to numSlides do
                    if slides[sld] <> NIL then  // evita problemas
                    begin
                        with slides[sld]^ do
                            begin
                                writeln (arq);
                                writeln (arq, '[SLIDE ', nlug, ' ', sld, ']');
                                writeln (arq, 'TÍTULO=', titulo);
                                if posFigura <> '' then
                                    writeln (arq, 'POSIÇÃO FIGURA=', posFigura);
                                if figura <> '' then
                                    writeln (arq, 'FIGURA=', figura);
                                if midiaSlide <> '' then
                                    writeln (arq, 'MÍDIA=', midiaSlide);
                                if esperaMidia then
                                    writeln (arq, 'ESPERA MÍDIA=', strBool(esperaMidia));
                                if efeito <> '' then
                                    writeln (arq, 'EFEITO=', efeito);
                                if avancaEm <> '' then
                                    writeln (arq, 'AUTO AVANÇA=', avancaEm);
                                if falaTexto <> '' then
                                    writeln (arq, 'FALA TEXTO=', falaTexto);
                                if posTexto <> '' then
                                    writeln (arq, 'POSIÇÃO TEXTO=', posTexto);
                                for l := 0 to texto.Count-1 do
                                    writeln (arq, l, '=', texto[l]);
                            end;
                    end;
            except
                result := false;
            end;
    end;

    {--------------------------------------------------------}

var nlug: integer;
label erro;

begin
    salvaJogo := false;

    assignFile (arq, nomeArqJogo);
    {$I-} rewrite (arq);  {$I+}
    if ioresult <> 0 then goto erro;

    if guardaDadosGerais and guardaInfra then
       begin
           salvaJogo := true;
           for nlug := 1 to jogo.numLugares do
               begin
                   if not gravaLugar (nlug) then goto erro;
                   if not gravaSlides (nlug) then goto erro;
               end;
       end;

    closeFile (arq);
    mensagem ('JOARQOK', 1);    // Arquivo gravado
    delay(1000);
    exit;

erro:
    closeFile (arq);
    mensagem ('JOERRCRI', 1);   // Erro ao criar o arquivo
    delay(1000);
end;

{--------------------------------------------------------}
{                 salva com outro nome
{--------------------------------------------------------}

function salvaComOutroNome: boolean;
var nomeNovo: string;
begin
    mensagem ('JONOMNOV', 1);   {'Informe o novo nome deste jogo:'}
    sintReadln (nomeNovo);
    nomeNovo := trim(nomeNovo);
    if nomeNovo = '' then
        begin
            mensagem ('JODESIST', 1);   {'Desistiu'}
            result := false;
            exit;
        end;

    nomeArqJogo := nomeNovo;
    if ansiUppercase (copy (nomeArqJogo, length(nomeArqJogo)-3, 4)) <> '.JOG' then
        nomeArqJogo := nomeArqJogo + '.jog';

    salvaComOutroNome := salvaJogo;
end;

{--------------------------------------------------------}
{                 pega o nome do jogo
{--------------------------------------------------------}

function pegaNomeJogo (var nomeArq: string): boolean;
var arq: textFile;
    c, c2: char;
    larq: TList;
    psr: PMySearchRec;

begin
    result := true;
    writeln;

    larq := criaListArq('*.jog', faArchive);
    if larq.Count = 1 then
        begin
            psr := larq[0];
            nomeArq := psr^.sr.FindData.cFileName;
        end;
    liberaListArq;

    if nomeArq = '' then
        begin
            mensagem ('JONOMJOG', 1);   // informe o nome do jogo, ou use as setas
            nomeArq := obtemNomeArqMasc (10, '*.jog');
            writeln (nomeArq);
        end;

    if nomeArq = '' then
        if (teclaObtemNomeArq = ESC) or (teclaObtemNomeArq = ENTER) then
            begin
                mensagem ('JODESIST', 1);    // Desistiu
                result := false;
                exit;
            end
        else
            begin
                mensagem ('JONAOTEM', 1);    // Este diretório não tem arquivos .JOG
                result := false;
                exit;
            end;

    if ansiUppercase (copy (nomeArq, length(nomeArq)-3, 4)) <> '.JOG' then
        nomeArq := nomeArq + '.jog';

    if not fileExists (nomeArq) then
        begin
            mensagem ('JONAOEXI', 1);      {'Arquivo não existe.'}
            mensagem ('JOQUERCR', 0);      {'Quer editar um novo jogo?'}
            sintLeTecla (c, c2);
            writeln;
            if (upcase (c) <> 'S') then
                begin
                    mensagem ('JODESIST', 1);    // Desistiu
                    result := false;
                    exit;
                end;

            assignFile (arq, nomeArq);
            {$I-} rewrite (arq);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('JOERRCRI', 1);   // Erro ao criar o arquivo
                    result := false;
                    exit;
                end;

            closeFile (arq);
            criaJogoModelo;
        end;
end;

{--------------------------------------------------------}
{                obtem as pastas de jogos
{--------------------------------------------------------}

procedure obtemPastas;
var
    sr: TSearchRec;
    FileAttrs: Integer;
begin
    listaDirJogos.clear;
    FileAttrs := faDirectory;
    if FindFirst(dirBaseJogos+'\*.*', FileAttrs, sr) = 0 then
        begin
            repeat
                if (sr.Name = '.') or (sr.Name = '..') then
                    continue;
                if (sr.Attr and FileAttrs) <> 0 then
                    listaDirJogos.add (sr.Name);
            until FindNext(sr) <> 0;
            FindClose(sr);
        end;
end;

{--------------------------------------------------------}
{                 escolhe a pasta do jogo
{--------------------------------------------------------}

function escolhePastaJogo: string;
var i, tam: integer;
    qualPasta: string;
begin
    obtemPastas;

    limpaBufTec;
    writeln;
    mensagem ('JOESCPAS', 1);  {'Escolha uma pasta de jogos com as setas'}
    garanteEspacoTela (7);

    tam := 20;
    for i := 1 to listaDirJogos.count do
        if length(listaDirJogos[i-1]) > tam then
            tam := length(listaDirJogos[i-1]);
    popupMenuCria(wherex, wherey, tam, 26-wherey, RED);
    for i := 1 to listaDirJogos.count do
        popupMenuAdiciona('', listaDirJogos[i-1]);
    limpaBufTec;
    if popupMenuSeleciona < 1 then
        begin
            qualPasta := '';
            mensagem ('JODESIST', 1);  {'Desistiu'}
        end
    else
        begin
            qualPasta := dirBaseJogos + '\' + opcoesItemSelecionado;
            writeln (qualPasta);

            {$I+}  chdir (qualPasta);  {$i-}
            if ioresult <> 0 then
                begin
                    mensagem ('JOERCRIA', 2);   {'Erro ao criar o diretório'}
                    qualPasta := '';
                end;
        end;

    escolhePastaJogo := qualPasta;
end;

{--------------------------------------------------------}
{                 cria a pasta do jogo
{--------------------------------------------------------}

function criaPastaJogo: string;
var dirACriar: string;
    c, c2: char;
begin
    criaPastaJogo := '';

    mensagem ('JODIRACR', 1);   {'Informe o nome do diretório a criar para o jogo'}
    dirACriar := '';
    c := sintEdita(dirACriar, wherex, wherey, 120, true);
    if c = ESC then exit;

    writeln (dirACriar);

    if c <> ENTER then
        dirACriar := escolhePastaJogo;

    if trim (dirACriar) = '' then
        exit;

    if directoryExists (dirACriar) then
        begin
            writeln;
            mensagem ('JODIREXI', 0);   {'Diretório já existia, posso reusar? '}
            sintLeTecla (c, c2);
            writeln; writeln;
            if upcase(c) <> 'S' then
                begin
                    mensagem ('JODESIST', 2);  {'Desistiu'}
                    exit;
                end;
        end
    else
        begin
            {$I-} mkdir (dirACriar);  {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('JOERCRIA', 0);   {'Erro ao criar o diretório'}
                    exit;
                end;
        end;

    {$I-} chdir (dirACriar);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('JOERACED', 0);   {'Erro ao acessar o diretório criado'}
            exit;
        end;

    getDir (0, dirACriar);   // pega o nome completo do diretório
    criaPastaJogo := dirACriar;
end;

{--------------------------------------------------------}
{              lê um número sem acusar erro
{--------------------------------------------------------}

function pegaNumero(lido: string): integer;
var erro, num: integer;
begin
    val (lido, num, erro);
    if erro <> 0 then num := 0;
    result := num;
end;

{--------------------------------------------------------}
{      gera lista de arquivos como string para menu
{--------------------------------------------------------}

function geraListaArqs (masc: string): string;
var listaArqs: string;
    larq: TList;
    psr: PMySearchRec;
    i: integer;
begin
    listaArqs := '';
    larq := criaListArq(masc, faArchive);
    for i := 0 to larq.count-1 do
        begin
            psr := larq[i];
            listaArqs := listaArqs + psr^.sr.FindData.cFileName + '|';
        end;
    liberaListArq;
    if listaArqs <> '' then
        delete (listaArqs, length(listaArqs), 1);
    geraListaArqs := listaArqs;
end;

{--------------------------------------------------------}
{            remove lixos da lista de arquivos
{--------------------------------------------------------}

function normalizaLista (listaMidias: string): string;
begin
    while (listaMidias <> '') and (listaMidias[1] = '|') do
        delete (listaMidias, 1, 1);
    while (listaMidias <> '') and (listaMidias[length(listaMidias)] = '|') do
        delete (listaMidias, length(listaMidias), 1);
    while pos('||', listaMidias) <> 0 do
        delete (listaMidias, pos('||', listaMidias), 1);
    result := listaMidias;
end;

end.

