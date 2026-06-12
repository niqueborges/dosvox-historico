{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de programação avançada
{
{    Autores: José Antonio Borges
{             Oswaldo Vernet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joprog;

interface
uses
    dvwin, dvcrt, dvform, dvarq, dvexec, windows, classes, sysutils,
    jovars, jomsg, dvdigitexto;

procedure progAvancada;

implementation

{--------------------------------------------------------}
{               chama um editor de textos
{--------------------------------------------------------}

function chamaEditor (qualArquivo: string): boolean;
var
    texto: TStringList;
begin
    mensagem ('JOCHAEDI', 2);  {'Chamando editor'}

    texto := TStringList.Create;
    if fileExists (qualArquivo) then
        texto.loadFromFile (qualArquivo);

    clrscr;
    textBackGround (MAGENTA);
    writeln (qualArquivo);
    textBackground (BLACK);

    digiTexto(texto, false, wherex, wherey, 80, 24-wherey, black, white, yellow, green, '', true, 0);
    texto.saveToFile (qualArquivo);

    chamaEditor := true;
end;

function geraNomePadrao: string;
var
    nomeNovo: string;
begin
    nomeNovo := nomeArqJogo;
    if ansiUpperCase(copy (nomeNovo, length(nomeNovo)-3, 4)) = '.JOG' then
        delete (nomeNovo, length(nomeNovo)-3, 4);
    result := nomeNovo + '.pro';
end;

function criarPrograma (edita: boolean): boolean;
var
    nomeNovo: string;
    c, c2: char;
    arq: textFile;
begin
    result := false;
    nomeNovo := geraNomePadrao;
    mensagem ('JONOMPRG', 1);   {'Editore o nome do programa'}

    c := sintEdita (nomeNovo, wherex, wherey, 80, true);
    writeln (nomeNovo);

    nomeNovo := trim(nomeNovo);
    if nomeNovo = '' then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu...'}
            exit;
        end;

    if ansiUpperCase(copy (nomeNovo, length(nomeNovo)-3, 4)) <> '.PRO' then
        nomeNovo := nomeNovo + '.pro';

    if FileExists(nomeNovo) then
        begin
            mensagem ('JOARQJAX', 1);    {'Arquivo já existe, quer destruir? '}
            sintLeTecla (c, c2);
            writeln;
            if upcase(c) <> 'S' then
                begin
                    mensagem ('JODESIST', 1);  {'Desistiu...'}
                    exit;
                end;
        end;

    assignFile (arq, nomeNovo);
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('JOPRGNAO', 1);    {'Programa não pôde ser criado'}
            exit;
        end;
    closefile (arq);

    with jogo.dadosGerais do
        begin
            nomeScriptControlador := nomeNovo;
            if edita then
                chamaEditor (nomeScriptControlador);
        end;

    result := true;
end;

procedure inibirPrograma;
begin
    jogo.dadosGerais.nomeScriptControlador := '';
    mensagem ('JOPRGINB', 2);    {'Programa inibido.'}
end;

procedure associarPrograma;
var
    nome: string;
begin
    mensagem ('JOSETPRG', 1);     {'Use as setas para escolher o programa'}
    nome := obtemNomeArqMasc(10, '*.pro');
    if nome = '' then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu...'}
            exit;
        end
    else
        begin
            writeln (nome);
            jogo.dadosGerais.nomeScriptControlador := nome;
        end;
end;

procedure editarPrograma;
begin
    with jogo.dadosGerais do
        begin
            if nomeScriptControlador = '' then
                begin
                    mensagem ('JOPRGNSL', 1);  {'Programa não está selecionado.'}
                    associarPrograma;
                end;

            if nomeScriptControlador <> '' then
                chamaEditor (nomeScriptControlador);
        end;
end;

procedure geraProgramaAutom;
var arq: textFile;
    i: integer;
    c, c2: char;
    r, l: string;
    pr, pl: integer;
    aproveitaProg: boolean;

    function sem_espaco (s: string): string;
    var i: integer;
    begin
         for i := 1 to length(s) do
             if s[i] = ' ' then s[i] := '_';
         result := s;
    end;

begin
    if not criarPrograma(false) then exit;
    mensagem ('JOAPROVT', 0);    {'Transcreve também a programação simples pré-existente? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu...'}
            exit;
        end;

    aproveitaProg := upcase(c) <> 'N';

    assignFile (arq, jogo.dadosGerais.nomeScriptControlador);
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('JOPRGNAO', 1);    {'Programa não pôde ser criado'}
            exit;
        end;

    writeln (arq, '* Programação do jogo ', jogo.dadosGerais.nomeJogo);

    for i := 1 to jogo.numLugares do
        if jogo.lugares[i] <> NIL then // evita problemas
          with jogo.lugares[i]^ do
            try
                writeln (arq);
                writeln (arq, '@' + sem_espaco(nome));
                writeln (arq, '    chama remoto "' + nome + '"');
                if memoriaResposta <> '' then
                    writeln (arq, '    seja $' + memoriaResposta + ' = $RESPOSTA"');

                if aproveitaProg then
                    begin
                        if jogo.lugares[1]^.jogoTerminaAqui then
                            writeln (arq, '    termina mudo')
                        else
                        if lugarOK = '' then
                            begin
                                if lugarErro <> '' then
                                    begin
                                        writeln (arq, '    se $RESPOSTA <> "', respostaEsperada, '"');
                                        writeln (arq, '        desvia @', sem_espaco(lugarErro));
                                        writeln (arq, '    fim se');
                                    end;
                            end
                        else
                            if lugarOK = lugarErro then
                                writeln (arq, '    desvia @', sem_espaco(lugarOK))
                            else
                                begin
                                    r := respostaEsperada;
                                    l := lugarOk;
                                    while r <> '' do
                                        begin
                                            pr := pos ('|', r);
                                            if pr = 0 then pr := length (r) +1;
                                            pl := pos ('|', l);
                                            if pl = 0 then pl := length (l) +1;

                                            writeln (arq, '    se $RESPOSTA = "', trim(copy(r, 1, pr-1)), '"');
                                            writeln (arq, '        desvia @', sem_espaco(trim(copy(l, 1, pl-1))));
                                            delete (r, 1, pr);
                                            delete (l, 1, pl);
                                            if r <> '' then
                                                writeln (arq, '    senão');
                                        end;

                                    if lugarErro <> '' then
                                        begin
                                            writeln (arq, '    senão');
                                            writeln (arq, '        desvia @', sem_espaco(lugarErro));
                                        end;
                                    writeln (arq, '    fim se');
                                end;

                    end;
            except
                mensagem ('JOERRESC', 1);  {'Erro de escrita do programa...'}
                exit;
            end;

    closeFile (arq);
    chamaEditor (jogo.dadosGerais.nomeScriptControlador);
end;

procedure progAvancada;
var n: integer;
begin
    window (1, 1, 80, 25);
    clrScr;
    setWindowTitle('Jogavox ' + nomeArqJogo);

    TextBackground(BLUE);
    mensagem ('JOPROAVN', 2);      {'Programação avançada'}
    TextBackground(BLACK);

    mensagem ('JOOPPROG', 2);      {'Escolha com as setas a opção de programação, ESC cancela'}
    popupMenuCria(wherex, wherey, 45, 5, RED);

    popupMenuAdiciona('JOAUTPRG', pegaTextoMensagem ('JOAUTPRG'));  {'Gerar a programação automaticamente'}
    popupMenuAdiciona('JOCRIPRG', pegaTextoMensagem ('JOCRIPRG'));  {'Criar e editar programa novo'}
    popupMenuAdiciona('JOEDIPRG', pegaTextoMensagem ('JOEDIPRG'));  {'Editar programa atual'}
    popupMenuAdiciona('JOASSPRG', pegaTextoMensagem ('JOASSPRG'));  {'Ativar o programa'}
    popupMenuAdiciona('JOINBPRG', pegaTextoMensagem ('JOINBPRG'));  {'Desativar o programa'}

    n := popupMenuSeleciona;

    case n of
        1: geraProgramaAutom;
        2: criarPrograma (true);
        3: editarPrograma;
        4: associarPrograma;
        5: inibirPrograma;
    else
        mensagem ('JODESIST', 1);     {'Desistiu'}
    end;
end;

end.

