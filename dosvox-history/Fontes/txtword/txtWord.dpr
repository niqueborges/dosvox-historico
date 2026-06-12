{----------------------------------------------------------------}
{   Conversor de DOX (texto com formatação do DOSVOX) para DOC
{   Autor: Neno Albernaz
{   Em fevereiro/2007
{----------------------------------------------------------------}

program TXTWord;

uses
    windows,
    dvcrt,
    dvwin,
    dvArq, dvexec,    dvForm, dvHora,
    sysutils,
    classes,
    comobj,
    activex,
    twexport,
    twmsg,
    twVars;


{-------------------------------------------------------------}
{       Carrega todas as linhas do arquivo na memória
{-------------------------------------------------------------}

function carregaLinhasArquivo (nomeArq: string): boolean;
begin
    texto := TStringList.create;
    carregaLinhasArquivo := true;
    try
        texto.loadFromFile (nomeArq);
    except
         carregaLinhasArquivo := false;
    end;
end;

{-------------------------------------------------------------}
{       Destroi todas as linhas do arquivo da memória
{-------------------------------------------------------------}

procedure destroiLinhasArquivo;
begin
    texto.free;
end;

{--------------------------------------------------------}
{       Abre o arquivo DOCX gerado
{--------------------------------------------------------}

procedure abrirArqDOCXGerado (nomeArqDoc: string);
begin
    if  fileExists (nomeArqDoc + '.docx') then nomeArqDoc := nomeArqDoc + '.docx'
    else     if   fileExists (nomeArqDoc + '.doc') then nomeArqDoc := nomeArqDoc + '.doc'
    else
        begin
            mensagem ('TWNENAR', 1); {'Não encontrei o arquivo DOCX para abrir.'}
            exit
        end;

    if pos (' ', nomeArqDoc) <> 0 then nomeArqDoc := '"' + nomeArqDoc + '"';

    while sintFalando do waitMessage;
    if executaProg (nomeArqDoc, '', '') >= 32 then;
//Comentado para não ficar janela aberta.        esperaProgVoltar;
end;

{--------------------------------------------------------}
{       Gera e salva o arquivo DOC
{--------------------------------------------------------}

procedure convertTxtParaDoc (abrirNoWord: boolean);
var
    nomeArqDoc: string;
    c: char;

label fim;
begin
    if not carregaLinhasArquivo (nomeArq) then
        begin
            mensagem ('TWERRCAR', 1); {'Erro ao carregar o arquivo...'}
            exit;
        end;

    nomeArqDoc := nomeArq;
    if (length (nomeArqDoc) > 4) and (nomeArqDoc [length (nomeArqDoc) - 3] = '.') then
        nomeArqDoc := copy(nomeArqDoc, 1,  length (nomeArqDoc) - 4);

    if  fileExists (nomeArqDoc + '.docx') or fileExists (nomeArqDoc + '.doc') then
        begin
            repeat
                mensagem ('TWREESCR', 0); {'Arquivo já existe, sobrescreve (s/n) ?'}
                c := leTeclaMaiusc;
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c in [ 'N', ESC] then
                begin
                    if c = ESC then abrirNoWord := false;
                    if not abrirNoWord then
                        mensagem ('TWDESIST', 1); {'Desistiu...'}
                    goto fim;
                end;
        end;

    mensagem ('TWEXPDOC', 1); {'Exportando arquivo para DOC, aguarde...'}
    if not exportaParaDoc (0, texto.count - 1) then
        begin
            mensagem ('TWERRWOR', 1); {'Ocorreu erro, instale o Microsoft Office para realizar esta geração.'}
            abrirNoWord := false;
        end
    else
        begin
            docWord.SaveAs (FileName := nomeArqDoc, AddToRecentFiles := false);
            docWord.Close (false);
            aplicWord.Quit (false);
            tocaOuSintetiza ('TWOK'); {'Ok'}
        end;

fim:

    destroiLinhasArquivo;

    if abrirNoWord then abrirArqDOCXGerado (nomeArqDoc);
end;

{--------------------------------------------------------}
{       Imprimi o arquivo no word, exporta para doc e imprimi
{--------------------------------------------------------}

procedure imprimiEmDoc;
begin
    if not carregaLinhasArquivo (nomeArq) then
        begin
            mensagem ('TWERRCAR', 1); {'Erro ao carregar o arquivo...'}
            exit;
        end;
    mensagem ('TWEXPDOC', 1); {'Exportando arquivo para DOC, aguarde...'}
    if not exportaParaDoc (0, texto.count - 1) then
        mensagem ('TWERRWOR', 1) {'Ocorreu erro, instale o Microsoft Office para realizar esta geração.'}
    else
        begin
            mensagem ('TWIMPARQ', 1); {'Imprimindo arquivo...'}
            docWord.PrintOut (false);
            docWord.Close (false);
            aplicWord.Quit (false);
            tocaOuSintetiza ('ETWOK'); {'Ok'}
        end;
    destroiLinhasArquivo;
end;

{--------------------------------------------------------}
{       Abre o normaalvox.dat no edivox para ser editado
{--------------------------------------------------------}

procedure editaFormatacaoInicial;
var
    nomeArq, nomeProg: string;
begin
    nomeArq := sintAmbiente ('TXTWORD', 'ARQNORMALVOX');
    if nomeArq = '' then
        nomeArq := sintDirAmbiente + '\normalvox.ini';
    nomeProg := sintAmbiente ('DOSVOX', 'EDITOR');
    if nomeProg = '' then
        nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\edivox.exe';
    if executaProg (nomeProg, '', nomeArq) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            msgBaixo ('TWOK'); {'Ok'}
        end;
end;

{--------------------------------------------------------}
{       Exibe a tela principal do programa
{--------------------------------------------------------}

procedure telaPrincipal;
begin
    clrscr;
    textBACKGROUND (BLUE);
    write ('TXTWord - Gerador e impressor - NCE/UFRJ - v. ');
    writeln (VERSAO);
    textBackground (BLACK);
    writeln;
    writeln;
end;

{--------------------------------------------------------}
{       Inicialização
{--------------------------------------------------------}

function inicializa: shortString;
var
    dir: string;
    par: string;

begin
    telaPrincipal;
    dir := sintambiente ('TXTWORD', 'DIRTXTWORD');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\txtword';
    sintInic (0, dir);

    if paramCount >= 1 then
        begin
            nomeArq := trim (paramStr(paramCount));
            par := maiuscAnsi (paramStr(1));
            if (par = '/G') or (par = '/I') or (par = '/W') then
                begin
                    result := par;
                    if paramCount = 1 then nomeArq := '';
                end
            else
                result := '';
        end
    else
        begin
            nomeArq := '';
            result := '';
        end;

    if length (nomeArq) > 136 then
        setWindowTitle (copy ('TXTWord ' + nomeArq, 1, 136) + '...')
    else
        setWindowTitle ('TXTWord ' + nomeArq);
end;

{--------------------------------------------------------}
{       Pergunta se termina o programa
{--------------------------------------------------------}

function terminaPrograma: char;
var c, c2: char;
begin
    telaPrincipal;
    writeln;
    textBackground (RED);
    repeat
        mensagem ('TWDESTER', 0); {'Deseja sair deste programa?'}
        sintletecla (c, c2);
        writeln;
    until upcase (c) in ['S', 'N', ENTER, ESC];
    textBackground (BLACK);
    if upcase (c) in ['S', ENTER] then
        begin
            c := ESC;
            mensagem ('TWFIM', 1); {'Fim do programa'}
        end
    else
        c := 'N';
    terminaPrograma := c;
end;

{--------------------------------------------------------}
{       Menu de ajuda
{--------------------------------------------------------}

procedure ajuda;
begin
    telaPrincipal;
    textBackground(BLUE);
    mensagem ('TWAJUDA', 0); {'As opções deste programa são:'}
    textBackground(BLACK);
    writeln; writeln;
    gotoxy (5, wherey);
    mensagem ('TWAJP01', 1); {'G    Gerar arquivo DOC'}
    gotoxy (5, wherey);
    mensagem ('TWAJP04', 1); {'W    Gerar e abrir no Word'}
    gotoxy (5, wherey);
    mensagem ('TWAJP02', 1); {'I    Imprimir arquivo em DOC'}
    gotoxy (5, wherey);
    mensagem ('TWAJP03', 1); {'N    Editar formatação inicial'}
    gotoxy (5, wherey);
    mensagem ('TWAJP09', 1); {'ESC  Terminar programa'}

    while keypressed do readkey;
    sintBip;
end;

function selSetasOpcoes: char;

    procedure MenuAdiciona (msg: string);
    begin
        popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var
    n: integer;
const
    tabLetrasOpcoes: string = 'GWIN'+ ESC;
begin
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcoes), MAGENTA);
    MenuAdiciona ('TWAJP01'); {'G    Gerar arquivo DOC'}
    MenuAdiciona ('TWAJP04'); {'W    Gerar e abrir no Word'}
    MenuAdiciona ('TWAJP02'); {'I    Imprimir arquivo em DOC'}
    MenuAdiciona ('TWAJP03'); {'N    Editar formatação inicial'}
    MenuAdiciona ('TWAJP09'); {'ESC  Terminar programa'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= length(tabLetrasOpcoes)) then
    selSetasOpcoes := tabLetrasOpcoes[n]
    else
    selSetasOpcoes := ENTER;
end;

{--------------------------------------------------------}
{       Corpo principal
{--------------------------------------------------------}

var
    c, c2: char;
    par: shortString;
    dirAtual: string;

label fim;
begin
    par := inicializa;
    if par <> '' then
        begin
            if par = '/W' then convertTxtParaDoc (true)
            else if par = '/G' then convertTxtParaDoc (false)
            else if par = '/I' then imprimiEmDoc
            else sintetiza ('Parâmetro ' + par + ' inválido');
            goto fim;
        end;

    tocaOuSintetiza ('TWINIC');  {'TXT Word - Gerador e impressor - NCE/UFRJ - v.'}
    sintsoletra (VERSAO);

    if nomeArq = '' then
        begin
            mensagem ('TWQuALNAR', 1); {Qual arquivo deseja? '}
            garanteEspacoTela (5);
            nomeArq := obtemNomeArqMasc (5, '*.txt');
            if (nomeArq <> '') and (pos ('\', nomeArq) = 0) then
                begin
                    getDir (0, dirAtual);
                    nomeArq := dirAtual + '\' + nomeArq;
                end;
        end;

    repeat
        mensagem ('TWQUAOPC', 0); {'Qual sua opção? '}
        sintletecla (c, c2);
        writeln;
        if c2 = BAIX then c := selSetasOpcoes;
        c := upcase (c);

        if c = #0 then
            case c2 of
                F1: ajuda;
                F8: falaHora;
                CTLF8: falaDia;
            end
        else
            case c of
                'G': convertTxtParaDoc (false);
                'I': imprimiEmDoc;
                'W': convertTxtParaDoc (true);
                'N': editaFormatacaoInicial;
//                'P': configurarPagina;//tamanho do papel, retrato
//                'R': restaurarPadrao;
                ENTER:;
                ESC: c := terminaPrograma;
            else
                mensagem ('TWOPVINV', 2);  {'Opção inválida, aperte F1 para ajuda'}
            end;
    until c in ['G', 'I', 'W', ESC];

fim:
    sintfim;
    donewincrt;
end.
