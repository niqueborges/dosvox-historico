{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de importação de mídias e roteitos
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joroteir;

interface
uses dvwin, dvcrt, dvarq, dvForm, dvdigitexto,
     jovars, joMsg, joEdLugs, joSlides,
     sysutils, strutils, classes;

procedure roteiroDoJogo;

implementation

{--------------------------------------------------------}
{            verifica se é arquivo de roteiro
{--------------------------------------------------------}

function eRoteiro (nomeArqRoteiro: string): boolean;
var
    arq: textFile;
    t1, t2: boolean;
    linha: string;
begin
    eRoteiro := false;
    try
        reset (arq, nomeArqRoteiro);
    except
        mensagem ('JOARNACE', 1);    {'Arquivo não está acessível'}
        exit;
    end;

    t1 := false;
    t2 := false;
    while not eof (arq) do
        begin
            if t1 and t2 then break;
            readln (arq, linha);
            linha := trimRight (linha);
            if copy (linha, 1, 4) = '----' then
                t1 := true
            else
            if (copy (linha, 1, 1) = '*') and (length(linha) = 1) then
                t2 := true;
        end;

    closeFile (arq);
    eRoteiro := t1 and t2;
end;

{--------------------------------------------------------}
{         extrai a primeira informação da lista
{--------------------------------------------------------}

function pegaLista (l: TStringList): string;
begin
    if l.count = 0 then
        pegaLista := '----'
    else
        begin
             pegaLista := l[0];
             l.Delete (0);
        end;
end;

{--------------------------------------------------------}
{    olha a primeira informação da lista, sem extrair
{--------------------------------------------------------}

function olhaLista (l: TStringList): string;
begin
    if l.count = 0 then
        olhaLista := '----'
    else
        olhaLista := l[0];
end;

{--------------------------------------------------------}
{                atualiza os dados gerais
{--------------------------------------------------------}

procedure atualizaDadosGerais (secaoLida: TStringList);

    function extraiParam (s: string): string;
    begin
        result := trim (copy (s, pos(']', s)+1, 999));
    end;

var
    i: integer;
    s: string;

begin
    for i := 0 to 1 do
        secaoLida.Add('');

    nComent := 0;
    with jogo do
        begin
            dadosGerais.nomeJogo    := pegaLista (secaoLida);
            dadosGerais.autor       := pegaLista (secaoLida);
            for i := 1 to 5 do
                dadosGerais.comentarios[i] := '';

            while true do
                begin
                    s := pegaLista(secaoLida);
                    if s = '----' then break;
                    if (s = '') then continue;

                    if AnsiStartsText('[DATA DE CRIAÇÃO]', s) then
                        dadosGerais.dataCriacao := extraiParam (s)
                    else
                    if AnsiStartsText('[VERSÃO]', s) then
                        dadosGerais.versao := extraiParam (s)
                    else
                    if AnsiStartsText('[DATA]', s) then
                        dadosGerais.dataVersao := extraiParam (s)
                    else
                    if AnsiStartsText('[FUNDO]', s) then
                        fundoDefault := extraiParam (s)
                    else
                    if AnsiStartsText('[ALEATÓRIO]', s) then
                        aleatorio := uppercase(copy (extraiParam (s), 1, 1)) = 'S'
                    else
                    if AnsiStartsText('[NARRANDO]', s) then
                        narrando := uppercase(copy (extraiParam (s), 1, 1)) = 'S'
                    else
                    if ncoment < 5 then
                        begin
                            ncoment := ncoment + 1;
                            dadosGerais.comentarios[ncoment] := s;
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{              converte string para boolean
{--------------------------------------------------------}

function tobool (s: string): boolean;
begin
    s := trim (s);
    toBool := (s <> '') and
              ((upcase(s[1]) = 'S') or (upcase(s[1]) = 'T')) ;   // sim ou true
end;

{--------------------------------------------------------}
{                     salva secao
{--------------------------------------------------------}

procedure salvaSecao (secaoLida: TStringList);
var pl: PLugar;
    psl: PSlide;
    s, x: string;

    function extraiParam (s: string): string;
    begin
        result := trim (copy (s, pos(']', s)+1, 999));
    end;

begin
    pl := inicializaLugar;
    with pl^ do
        begin
            repeat
                nome := pegaLista(secaoLida);
            until nome <> '';

            repeat
                 s := pegaLista(secaoLida);
                 if s = '' then continue;
                 if AnsiStartsText('[CATEGORIA]', s) then
                     categoria := extraiParam (s)
                 else
                 if AnsiStartsText('[CORFUNDO]', s) or
                    AnsiStartsText('[COR DO FUNDO]', s) or
                    AnsiStartsText('[COR FUNDO]', s) then
                     corFundo := extraiParam (s)
                 else
                 if AnsiStartsText('[CORLETRA]', s) or
                    AnsiStartsText('[COR DA LETRA]', s) or
                    AnsiStartsText('[COR LETRA]', s) then
                     corLetra := extraiParam (s)
                 else
                 if AnsiStartsText('[FUNDO]', s) then
                     fundo := extraiParam (s)
                 else
                 if AnsiStartsText('[IMAGEMA]', s) then
                     imagemA := extraiParam (s)
                 else
                 if AnsiStartsText('[IMAGEMB]', s) then
                     ImagemB := extraiParam (s)
                 else
                 if AnsiStartsText('[MÍDIA]', s) or
                    AnsiStartsText('[MIDIA]', s) then
                     midiaLugar := extraiParam (s)
                 else
                 if AnsiStartsText('[RESPOSTA]', s) or
                    AnsiStartsText('[RESPOSTAS]', s) then
                     respostaEsperada := extraiParam (s)
                 else
                 if AnsiStartsText('[ACERTO]', s) then
                     lugarOK := extraiParam (s)
                 else
                 if AnsiStartsText('[ERRO]', s) then
                     lugarErro := extraiParam (s)
                 else
                 if AnsiStartsText('[DESVIO]', s) then
                     begin
                         lugarOk := extraiParam (s);
                         lugarErro := lugarOk;
                     end
                 else
                 if AnsiStartsText('[MEMÓRIA DA RESPOSTA]', s) then
                     begin
                         memoriaResposta := extraiParam (s);
                         if ansiUppercase(memoriaResposta) = 'LUGAR' then
                             begin
                                  mensagem ('JOEROTEI', 1);  {'Erro no roteiro:'}
                                  mensagem ('JOLGNAOR', 1);  {'O nome "LUGAR" não deve ser usado como Memória da Resposta'}
                             end;
                     end
                 else
                 if AnsiStartsText('[SCRIPT]', s) or
                    AnsiStartsText('[SCRIPT DE ENTRADA]', s) then
                     begin
                         scriptEntrada := extraiParam (s)
                     end
                 else
                 if AnsiStartsText('[SCRIPT DE SAÍDA]', s) or
                    AnsiStartsText('[SCRIPT DE SAIDA]', s) then
                     begin
                         scriptSaida := extraiParam (s)
                     end
                 else
                 if AnsiStartsText('[TERMINA]', s) or
                    AnsiStartsText('[FIM]', s) then
                     begin
                         jogoTerminaAqui := true;
                     end
                 else
                 if AnsiStartsText('[PONTOS]', s) then
                     begin
                         x := extraiParam (s);
                         try
                             pontuacao := strToInt (x);
                         except end;
                     end
                 else
                 if AnsiStartsText('[', s) then
                     begin
                         mensagem ('JODADIGN', 0);  {'Dados ignorados no lugar: '}
                         sintWrite (pl^.nome);
                         writeln (':');
                         sintWriteln (s);
                     end;

            until (s = '*') or (s = '----');
        end;

    while s <> '----' do
        begin
             psl := inicializaSlide;
             psl^.titulo := pl^.nome + ' ' + intToStr(pl^.numSlides+1);
             repeat
                  s := pegaLista(secaoLida);
                  if (s <> '*') and (s <> '----') then
                       begin
                           if (s <> '') and (s[1] = '[') then
                               begin
                                   if AnsiStartsText('[MÍDIA]', s) or
                                      AnsiStartsText('[MIDIA]', s) then
                                       psl^.midiaSlide := extraiParam (s)
                                   else
                                   if AnsiStartsText('[ESPERAMIDIA]', s) or
                                      AnsiStartsText('[ESPERAMÍDIA]', s) then
                                       psl^.esperaMidia := tobool (extraiParam (s))
                                   else
                                   if AnsiStartsText('[FIGURA]', s) or
                                      AnsiStartsText('[IMAGEM]', s) then
                                       psl^.figura := extraiParam (s)
                                   else
                                   if AnsiStartsText('[POSFIGURA]', s) or
                                      AnsiStartsText('[POS FIGURA]', s) then
                                       psl^.posFigura := extraiParam (s)
                                   else
                                   if AnsiStartsText('[POSTEXTO]', s) or
                                      AnsiStartsText('[POS TEXTO]', s) then
                                       psl^.posTexto := extraiParam (s)
                                   else
                                   if AnsiStartsText('[FALATEXTO]', s) or
                                      AnsiStartsText('[FALA TEXTO]', s) then
                                       psl^.falaTexto := extraiParam (s)
                                   else
                                   if AnsiStartsText('[AVANÇA]', s) then
                                       psl^.avancaEm := extraiParam (s)
                                   else
                                   if AnsiStartsText('[EFEITO]', s) then
                                       psl^.efeito := extraiParam (s)
                                   else

                                        // resposta, acerto, erro, desvio e pontos
                                        // podem também ser colocados num slide,
                                        // para ficar mais intuitivo

                                   if AnsiStartsText('[RESPOSTA]', s) or
                                      AnsiStartsText('[RESPOSTAS]', s)  then
                                       pl^.respostaEsperada := extraiParam (s)
                                   else
                                   if AnsiStartsText('[MEMÓRIA DA RESPOSTA]', s) then
                                       begin
                                           pl^.memoriaResposta := extraiParam (s);
                                           if ansiUpperCase(pl^.memoriaResposta) = 'LUGAR' then
                                               begin
                                                   mensagem ('JOEROTEI', 1);  {'Erro no roteiro:'}
                                                   mensagem ('JOLGNAOR', 1);  {'O nome "LUGAR" não deve ser usado como Memória da Resposta'}
                                               end;
                                       end
                                   else
                                   if AnsiStartsText('[ACERTO]', s) then
                                       pl^.lugarOK := extraiParam (s)
                                   else
                                   if AnsiStartsText('[ERRO]', s) then
                                       pl^.lugarErro := extraiParam (s)
                                   else
                                   if AnsiStartsText('[DESVIO]', s) then
                                       begin
                                            pl^.lugarOk := extraiParam (s);
                                            pl^.lugarErro := pl^.lugarOk;
                                       end
                                   else
                                   if AnsiStartsText('[PONTOS]', s) then
                                       begin
                                           x := extraiParam (s);
                                           try
                                               pl^.pontuacao := strToInt (x);
                                           except end;
                                       end
                               end
                           else
                               if psl^.texto.count < 10 then
                                    psl^.texto.Add(s);
                       end;
             until (s = '*') or (s = '----');

             pl^.numSlides := pl^.numSlides + 1;
             pl^.slides[pl^.numSlides] := psl;
        end;

    with jogo do
        begin
            numLugares := numLugares + 1;
            lugares[numLugares] := pl;
        end;
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
{                   importa um roteiro
{--------------------------------------------------------}

procedure importarRoteiro (nomeRoteiro: string);
var
    nomeArqRoteiro: string;
    arq: textFile;
    secaoLida: TStringList;
    temSlides: boolean;
    c, c2: char;
    i, j: integer;

    function pegaSecao (var achouSlide: boolean): boolean;
    var
        fimSecao: boolean;
        linha: string;
    begin
        pegaSecao := false;
        achouSlide := false;
        secaoLida.clear;
        if eof(arq) then exit;

        fimSecao := false;
        repeat
             readln (arq, linha);
             linha := trimRight(linha);
             if copy (linha, 1, 1) = ';' then continue;  // ignora comentários

             trocaTravessao (linha);
             if copy (linha, 1, 4) = '----' then
                 fimSecao := true
             else
                 begin
                     secaoLida.Add(linha);
                     if copy (linha, 1, 1) = '*' then
                         achouSlide := true;
                 end;
        until fimSecao or eof(arq);

        pegaSecao := secaoLida.count > 0;
    end;

label deNovo;

begin
    if nomeRoteiro = '' then
        begin
            mensagem ('JOINFROT', 1);    {'Informe o nome do roteiro .TXT'}
            nomeArqRoteiro := obtemNomeArqMasc (10, '*.txt');
            if nomeArqRoteiro = '' then
                begin
                    mensagem ('JODESIST', 2);    {'Desistiu...'}
                    exit;
                end;
            writeln;
        end
    else
        nomeArqRoteiro := nomeRoteiro;

    if not fileExists (nomeArqRoteiro) then
        begin
            mensagem ('JONAOEXI', 2);    {'Arquivo não existe.'}
            exit;
        end;

    if not eRoteiro (nomeArqRoteiro) then
        begin
            mensagem ('JONAOROT', 1);   {'Este não parece ser um arquivo de roteiro.'}
            mensagem ('JOCONMAN', 1);   {'Consulte o manual para maiores detalhes.'}
            exit;
        end;

    secaoLida := TStringList.Create;
    reset (arq, nomeArqRoteiro);

    if (not pegaSecao(temSlides)) or temSlides then   // nos dados gerais não tem slides
        begin
            mensagem ('JONAOROT', 1);   {'Este não parece ser um arquivo de roteiro.'}
            mensagem ('JOCONMAN', 1);   {'Consulte o manual para maiores detalhes.'}
            closeFile (arq);
            secaoLida.free;
            exit;
        end;

    if (jogo.numLugares = 1) and
       (jogo.lugares[1].numSlides = 0) then
           jogo.numLugares := 0
    else
        begin
deNovo:
            mensagem ('JOIMPFIM', 0);   {'Escolha A para adicionar ou Z para zerar jogo atual'}
            sintLeTecla (c, c2);
            writeln;
            case upcase(c) of
                'A':  ;
                'Z':  begin
                          for i := 1 to jogo.numLugares do
                              with jogo.lugares[i]^ do
                                  for j := 1 to numSlides do
                                      desalocaSlide (slides[j]);
                          jogo.numLugares := 0;
                      end;
                ESC:  begin
                          mensagem ('JODESIST', 1);  {'Desistiu'}
                          closeFile (arq);
                          exit;
                      end;
            else
                gotoxy (1, wherey-1);
                clreol;
                goto deNovo;
            end;
        end;

    atualizaDadosGerais (secaoLida);

    while pegaSecao (temSlides)do
        salvaSecao (secaoLida);

    closeFile (arq);
    secaoLida.free;

    limpaBufTec;
    writeln;
    mensagem ('JOROTCRG', 2);   {'Roteiro carregado.'}
    delay (1000);
end;

{--------------------------------------------------------}
{                   gera um roteiro
{--------------------------------------------------------}

procedure gerarRoteiro;
var
    nomeArqRoteiro: string;
    arq: textFile;
    c, c2: char;
    i, l, sl: integer;
    t, ult: integer;
const
    boolToSimNao: array [boolean] of string[4] = ('NÃO', 'SIM');

begin
    mensagem ('JOINFROT', 1);    {'Informe o nome do roteiro .TXT'}
    nomeArqRoteiro := obtemNomeArqMasc (10, '*.txt');
    if nomeArqRoteiro = '' then
        begin
            nomeArqRoteiro := 'roteiro.txt';
            mensagem ('JOASSUMR', 1);  {'Assumido roteiro.txt'}
        end
    else
        writeln (nomeArqRoteiro);

    if fileExists (nomeArqRoteiro) then
        begin
            mensagem ('JOROTEXI', 0);    {'Um roteiro com este nome já existe.  Quer sobrescrever? '}
            sintLeTecla (c, c2);
            writeln;
            if (upcase(c) <> 'S') then exit;
        end;

    rewrite (arq, nomeArqRoteiro);

    with jogo do
        with dadosGerais do
            begin
                writeln (arq, nomeJogo);
                writeln (arq, autor);
                for i := 1 to ncoment do
                    writeln (comentarios[i]);

                writeln (arq, '[VERSÃO] ', versao);
                writeln (arq, '[DATA] ', dataVersao);
                writeln (arq, '[DATA DE CRIAÇÃO] ', dataCriacao);

                if fundoDefault <> '' then
                    writeln (arq, '[FUNDO] ', fundoDefault);
                if aleatorio then
                    writeln (arq, '[ALEATÓRIO] ', 'SIM');
                if not narrando then
                    writeln (arq, '[NARRANDO] ', 'NÃO');

                // talvez introduzir tags:  [FONTE] Arial 12 negrito, Aleatório, Narrando
            end;

    for l := 1 to jogo.numLugares do
        begin
            writeln (arq, '----------------------------------------');
            with jogo.lugares[l]^ do
                begin
                    writeln (arq, nome);
                    if categoria <> '' then
                        writeln (arq, '[CATEGORIA] ', categoria);
                    if respostaEsperada <> '' then
                        writeln (arq, '[RESPOSTA] ', respostaEsperada);
                    if (lugarOK = lugarErro) and (lugarOk <> '') then
                        writeln (arq, '[DESVIO] ', lugarOk)
                    else
                        begin
                            if lugarOk <> '' then
                                writeln (arq, '[ACERTO] ', lugarOk);
                            if lugarErro <> '' then
                                writeln (arq, '[ERRO] ', lugarErro);
                        end;
                    if pontuacao <> 0 then
                        writeln (arq, '[PONTOS] ', pontuacao);
                    if memoriaResposta <> '' then
                        writeln (arq, '[MEMÓRIA DA RESPOSTA] ', memoriaResposta);
                    if jogoTerminaAqui then
                        writeln (arq, '[TERMINA] ', 'SIM');
                    if midiaLugar <> '' then
                        writeln (arq, '[MÍDIA] ', midiaLugar);
                    if fundo <> '' then
                        writeln (arq, '[FUNDO] ', fundo);
                    if imagemA <> '' then
                        writeln (arq, '[IMAGEMA] ', imagemA);
                    if ImagemB <> '' then
                        writeln (arq, '[IMAGEMB] ', imagemB);
                    if corFundo <> '' then
                        writeln (arq, '[CORFUNDO] ', corFundo);
                    if (corLetra <> '') and
                        (ansiuppercase(corLetra) <> ansiuppercase(jogo.corLetraDefault)) then
                        writeln (arq, '[CORLETRA] ', corLetra);
                    if scriptEntrada <> '' then
                        writeln (arq, '[SCRIPT DE ENTRADA] ', scriptEntrada);
                    if scriptSaida <> '' then
                        writeln (arq, '[SCRIPT DE SAÍDA] ', scriptSaida);

                    for sl := 1 to numSlides do
                        with slides[sl]^ do
                            begin
                                writeln (arq, '*');
                                if midiaSlide <> '' then
                                    writeln (arq, '[MÍDIA] ', midiaSlide);
                                if not esperaMidia then
                                    writeln (arq, '[ESPERAMIDIA] ', 'NÃO');
                                if posfigura <> '' then
                                    writeln (arq, '[POSFIGURA] ', posfigura);
                                if figura <> '' then
                                    writeln (arq, '[FIGURA] ', figura);
                                if postexto <> '' then
                                    writeln (arq, '[POSTEXTO] ', posTexto);
                                if falatexto <> '' then
                                    writeln (arq, '[FALATEXTO] ', falaTexto);
                                if (avancaEm <> '') and
                                        (uppercase(avancaEm) <> 'AUTO') and
                                        (upcase(avancaEm[1]) <> 'S') then
                                    writeln (arq, '[AVANÇA] ', avancaEm);
                                if efeito <> '' then
                                    writeln (arq, '[EFEITO] ', efeito);

                                ult := -1;
                                for t := texto.count-1 downto 0 do
                                    if trim (texto[t]) <> '' then
                                        begin
                                            ult := t;
                                            break;
                                        end;
                                for t := 0 to ult do
                                    writeln (arq, texto[t]);
                            end;
                end;
        end;

    closeFile (arq);

    limpaBufTec;
    writeln;
    mensagem ('JOROTCRI', 2);   {'Roteiro equivalente criado.'}
    delay (1000);
end;

{--------------------------------------------------------}
{                   pega o nome do roteiro
{--------------------------------------------------------}

function pegaNomeArqRoteiro: string;
var nomeArqRoteiro: string;
begin
    garanteEspacoTela(12);
    mensagem ('JOINFRTS', 1);    {'Informe o nome do roteiro .TXT ou use as setas'}
    nomeArqRoteiro := obtemNomeArqMasc (10, '*.txt');
    if nomeArqRoteiro = '' then
        begin
            nomeArqRoteiro := 'roteiro.txt';
            mensagem ('JOASSUMR', 1);  {'Assumido roteiro.txt'}
        end
    else
        writeln (nomeArqRoteiro);
    result := nomeArqRoteiro;
end;

{--------------------------------------------------------}
{                   edita um roteiro
{--------------------------------------------------------}

procedure editarRoteiro (textoGerado: TStringList);
var
    texto: TStringList;
    nomeArqRoteiro: string;
    c, c2: char;
    erro: boolean;
label retenta;

begin
    nomeArqRoteiro := pegaNomeArqRoteiro;

    texto := TStringList.Create;

    if textoGerado <> NIL then
        texto.Assign(textoGerado)
    else
        if fileExists (nomeArqRoteiro) then
            texto.LoadFromFile(nomeArqRoteiro);

    clrscr;
    textBackGround (MAGENTA);
    writeln (nomeArqRoteiro);
    textBackground (BLACK);
    dvdigitexto.digiTexto(texto, false, wherex, wherey, 80, 24-wherey, black, white, yellow, green, nomeArqRoteiro, true, 0);

    gotoxy (1, 25);
    while FileExists(nomeArqRoteiro) do
        begin
            textBackground(RED);
            mensagem ('JOROTEXI', 0);  {'Sobrescrevendo roteiro.  Confirma? '}
            textBackground(BLACK);
            sintLeTecla (c, c2);
            writeln;

            c := upcase (c);
            if c = ESC then
                begin
                    mensagem ('JODESIST', 2);    {'Desistiu...'}
                    texto.Free;
                    exit;
                end;
retenta:
            if c = 'N' then  nomeArqRoteiro := pegaNomeArqRoteiro
            else
            if c = 'S' then  break;
        end;

    try
        erro := false;
        texto.SaveToFile(nomeArqRoteiro);
        mensagem ('JOOK', 2);      {'Ok.'}
        texto.Free;
    except
        erro := true;
    end;

    if erro then
        begin
            mensagem ('JOERESCR', 2);  {'Erro de escrita no arquivo.'}
            goto retenta;
        end
    else
        begin
            mensagem ('JODESIMP', 0);  {'Deseja importar o roteiro editado? '}
            sintLeTecla (c, c2);
            writeln;
            if upcase(c) = 'S' then
                importarRoteiro(nomearqRoteiro);
        end;

end;

{--------------------------------------------------------}
{           copia um roteiro pré-programado
{--------------------------------------------------------}

procedure montaRoteiro (totalItens, numAplicadas: integer;  nomeArqRtr: string;
                        textoGerado: TStringList);
var textoOriginal: TStringList;
    questao, linha, inicioParte: integer;
    p: integer;
    s: string;
    nome: string;
begin
    nomeArqRtr := dirBaseModelos + '\' + nomeArqRtr;
    if not FileExists(nomeArqRtr) then
        begin
            mensagem ('JOMODNAO', 0);   {'Modelo não foi encontrado: '}
            sintWriteln (nomeArqRtr);
            writeln;
            delay (1000);
            exit;
        end;

    textoOriginal := TStringList.Create;
    textoOriginal.LoadFromFile(nomeArqRtr);

    questao := 0;
    linha := 0;
    inicioParte := 0;
    while linha < textoOriginal.Count do
        begin
            s := textoOriginal[linha];
            if ansiUpperCase(s) = '<<<FIM>>>' then
                begin
                    questao := questao + 1;
                    if questao <= totalItens then
                        linha := inicioParte;
                end
            else
            if ansiUpperCase(s) = '<<<REPETIR>>>' then
                begin
                    inicioParte := linha;
                    questao := 1;
                end
            else
                begin
                    p := pos('<<<JOGO>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            delete(s, p, length('<<<JOGO>>>'));
                            nome := ExtractFileName(nomeArqJogo);
                            delete (nome, lastDelimiter('.', nome), 999);
                            insert(nome, s, p);
                        end;
                    p := pos('<<<AUTOR>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            delete(s, p, length('<<<AUTOR>>>'));
                            insert(jogo.dadosGerais.autor, s, p);
                        end;
                    p := pos('<<<TOTAL>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            delete(s, p, length('<<<TOTAL>>>'));
                            insert(intToStr(totalItens), s, p);
                        end;
                    p := pos('<<<APLICAR>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            delete(s, p, length('<<<APLICAR>>>'));
                            insert(intToStr(numAplicadas), s, p);
                        end;
                    p := pos('<<<QUESTÃO>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            delete(s, p, length('<<<QUESTÃO>>>'));
                            insert(intToStr(questao), s, p);
                        end;
                    p := pos('<<<PRÓXIMA_QUESTÃO>>>', ansiUpperCase(s));
                    if p <> 0 then
                        begin
                            if questao < totalItens then
                                begin
                                    delete(s, p, length('<<<PRÓXIMA_QUESTÃO>>>'));
                                    insert(intToStr(questao+1), s, p);
                                end
                            else
                                begin
                                     p := pos(']', s);
                                     delete (s, p+1, 999);
                                     s := s + ' fim';
                                end;
                        end;

                    textoGerado.Add(s);
                end;

            linha := linha + 1;
        end;
end;

{--------------------------------------------------------}
{                   cria um roteiro
{--------------------------------------------------------}

procedure criaQuizFixo;
var
    textoGerado: TStringList;
    n: integer;
begin
    writeln;
    mensagem ('JONUMQST', 0);   {'Número total de questões: '}
    n := 0;
    sintReadint (n);
    if n <= 0 then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu...'}
            exit;
        end;

    textoGerado := TStringList.create;
    montaRoteiro (n, 0, 'quiz_fixo.rtr', textoGerado);
    editarRoteiro (textoGerado);
    textoGerado.Free;
end;

{--------------------------------------------------------}

procedure criaQuizAleatorio;
var
    textoGerado: TStringList;
    n, p: integer;
begin
    writeln;
    mensagem ('JONUMQST', 0);   {'Número total de questões: '}
    n := 0;
    sintReadint (n);
    if n <= 0 then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu...'}
            exit;
        end;

    mensagem ('JONUMQSP', 0);   {'Número de questões a sortear para cada jogo: '}
    sintReadint (p);
    if p <= 0 then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu...'}
            exit;
        end;

    textoGerado := TStringList.create;
    montaRoteiro (n, p, 'quiz_aleatorio.rtr', textoGerado);
    editarRoteiro (textoGerado);
    textoGerado.free;
end;

{--------------------------------------------------------}

procedure criaListaDeLugares;
var
    textoGerado: TStringList;
begin
    mensagem ('JOEXEMPL', 2);  {'Gerarei um exemplo para você se basear'}

    textoGerado := TStringList.create;
    montaRoteiro (0, 0, 'quiz_lugares.rtr', textoGerado);
    editarRoteiro (textoGerado);
    textoGerado.free;
end;

{--------------------------------------------------------}

procedure criaJogoVazio;
var
    textoGerado: TStringList;
begin
    textoGerado := TStringList.create;
    montaRoteiro (0, 0, 'quiz_vazio.rtr', textoGerado);
    editarRoteiro (textoGerado);
    textoGerado.free;
end;

{--------------------------------------------------------}

procedure criarRoteiro;
var n: integer;
begin
    mensagem ('JOTIPROT', 2);      {'Escolha com as setas o tipo de roteiro'}
    TextBackground(BLACK);

    popupMenuCria(wherex, wherey, 45, 4, RED);

    popupMenuAdiciona('JOTIP_PR', pegaTextoMensagem ('JOTIP_PR'));  {'P - Perguntas e respostas com ordem fixa.'}
    popupMenuAdiciona('JOTIP_PS', pegaTextoMensagem ('JOTIP_PS'));  {'S - Perguntas e respostas com sorteio.'}
    popupMenuAdiciona('JOTIP_EX', pegaTextoMensagem ('JOTIP_EX'));  {'E - Exploração de lugares.'}
    popupMenuAdiciona('JOTIP_VZ', pegaTextoMensagem ('JOTIP_VZ'));  {'V - Jogo vazio.'}

    n := popupMenuSeleciona;
    if n in [1..4] then
       begin
          writeln (opcoesItemSelecionado);
          writeln;
       end;

    case n of
         1: criaQuizFixo;
         2: criaQuizAleatorio;
         3: criaListaDeLugares;
         4: criaJogoVazio;
    else
        mensagem ('JODESIST', 1);     {'Desistiu'}
    end;
end;

{--------------------------------------------------------}
{            controle das funções de roteiro
{--------------------------------------------------------}

procedure roteiroDoJogo;
var n: integer;
begin
    window (1, 1, 80, 25);
    clrScr;
    setWindowTitle('Jogavox ' + nomeArqJogo);

    TextBackground(BLUE);
    mensagem ('JOOPROT', 2);      {'Escolha com as setas a opção de roteiro, ESC cancela'}
    TextBackground(BLACK);

    popupMenuCria(wherex, wherey, 45, 4, RED);

    popupMenuAdiciona('JOAJR_C', pegaTextoMensagem ('JOAJR_C'));  {'C - Criar novo roteiro.'}
    popupMenuAdiciona('JOAJR_E', pegaTextoMensagem ('JOAJR_E'));  {'E - Editar um roteiro.'}
    popupMenuAdiciona('JOAJR_I', pegaTextoMensagem ('JOAJR_I'));  {'I - Importar um roteiro.'}
    popupMenuAdiciona('JOAJR_G', pegaTextoMensagem ('JOAJR_G'));  {'G - Gerar um roteiro a partir do jogo'}

    n := popupMenuSeleciona;
    if n in [1..4] then
       begin
          writeln (opcoesItemSelecionado);
          writeln;
       end;

    case n of
        1: criarRoteiro;
        2: editarRoteiro (NIL);
        3: importarRoteiro ('');
        4: gerarRoteiro;
    else
        mensagem ('JOOPINV', 1);    {'Opção inválida'}
    end;
end;

end.

