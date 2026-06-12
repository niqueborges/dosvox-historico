{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de edição do jogo
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joedjogo;

interface

uses
    windows, dvwin, dvcrt, sysutils, dvform,
    jovars, jomsg, joEdLugs, joJoga, joConfig, joArq, joImport, joProg,
    joRoteir, joUpload;

procedure editaJogo;
procedure criaJogo;

implementation

{--------------------------------------------------------}
{                ajuda das opções principais
{--------------------------------------------------------}

procedure ajudaOpcoesPrincipais;
var x, y: integer;
begin
    x := wherex;
    y := wherey;
    window (40, 7, 80, 7 + 11{items});
    textBackground (BLUE);
    clrscr;
    mensagem ('JOOPCOES',2);   {'As opções são:'}
    mensagem ('JOAJP_R2',1);   {'R - Roteiro do jogo'}
    mensagem ('JOAJP_D', 1);   {'D - editar dados gerais'}
    mensagem ('JOAJP_C', 1);   {'C - configurar apresentação'}
    mensagem ('JOAJP_E', 1);   {'E - Editar os locais do jogo'}
    mensagem ('JOAJP_S', 1);   {'S - Salvar o projeto'}
    mensagem ('JOAJP_N', 1);   {'N - Salvar com outro nome'}
    mensagem ('JOAJP_I', 1);   {'I - Importar mídias para o jogo'}
    mensagem ('JOAJP_P', 1);   {'P - programação avançada'}
    mensagem ('JOAJP_R', 1);   {'R - Importar um roteiro'}
    mensagem ('JOAJP_X', 1);   {'X - Executar o jogo'}
    mensagem ('JOAJP_A', 1);   {'A - Abandonar sem gravar'}
    textBackground (BLACK);

    window (1, 1, 80, 25);
    gotoxy (x, y);
end;

{--------------------------------------------------------}
{                   menu de opções
{--------------------------------------------------------}

const
    nitens = 12;

function menuOpcoesPrincipais: char;
const
    letrasMenu: array [0..nitens] of char = (#$1b, 'R', 'D', 'C', 'E', 'S', 'N', 'I', 'P', 'X', 'U', 'A', #$1b);
var
    item: integer;
begin
    limpaMensagens;

    popupMenuCria(40, 7, 40, nitens, MAGENTA);
    MenuAdiciona('JOAJP_R2');  {'R - Roteiro do jogo'}
    MenuAdiciona('JOAJP_D');   {'D - editar dados gerais'}
    MenuAdiciona('JOAJP_C');   {'C - configurar apresentação'}
    MenuAdiciona('JOAJP_E');   {'E - Editar os locais do jogo'}
    MenuAdiciona('JOAJP_S');   {'S - Salvar o projeto'}
    MenuAdiciona('JOAJP_N');   {'N - Salvar com outro nome'}
    MenuAdiciona('JOAJP_I');   {'I - Importar mídias para o jogo'}
    MenuAdiciona('JOAJP_P');   {'P - programação avançada'}
    MenuAdiciona('JOAJP_X');   {'X - Executar o jogo'}
    MenuAdiciona('JOAJP_U');   {'U - Publicar o jogo'}
    MenuAdiciona('JOAJP_A');   {'A - Abandonar sem gravar'}
    MenuAdiciona('JOAJP_ES');  {'ESC - Terminar'}
    item := popupMenuSeleciona;

    if (item <= 0) or (item > nitens) then item := 0;
    menuOpcoesPrincipais := letrasMenu[item];
end;

{--------------------------------------------------------}
{             edição: escolhe as opções principais
{--------------------------------------------------------}

procedure editaJogoCriado;
var c, c1, c2: char;
label interpreta;
begin
    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    checkBreak := false;

    repeat
        clrScr;
        setWindowTitle('Jogavox ' + nomeArqJogo);
        textBackground (BLUE);
        write (pegaTextoMensagem ('JOINIC'));   {'Jogavox - editor de jogos educacionais'}
        textBackground (BLACK);
        writeln; writeln;

        mensagem ('JOOPPRIN', 2);     {'Editando o jogo'}
        mensagem ('JOOPSET', 2);      {'Escolha as setas, F1 ajuda.'}

        TextBackground(BLUE);
        mensagem ('JOOPCAO', 0);      {'Jogavox - qual sua opção? '}
        TextBackground (BLACK);
        sintLeTecla (c1, c2);
        writeln;

interpreta:
        if c1 <> #$0 then
            case upcase(c1) of
                'D': editarDadosGerais;
                'R': roteiroDoJogo;
                'C': configurarApresentacao;
                'E': editarListaDeLugares;
                'I': importarMidias;
                'P': progAvancada;
                'S': salvaJogo;
                'N': salvaComOutroNome;
                'X': jogaJogo (true);
                'U': if salvaJogo then upLoad;
                'A': begin
                         mensagem ('JOCNFABN', 0);    {'Confirma abandono sem gravar? '}
                         c := sintReadkey;
                         writeln (c);
                         if upcase(c) = 'S' then
                             mensagem ('JONAOGRV', 2)       {'Ok, as modificações não foram gravadas'}
                         else
                             begin
                                 mensagem ('JODESIST', 2);   {'Desistiu'}
                                 c1 := ' ';
                             end;
                     end;

                ESC: begin

                         mensagem ('JOCNFFIM', 0);    {'Confirma fim? '}
                         c := sintReadkey;
                         writeln (c);
                         if upcase(c) = 'S' then
                             salvaJogo
                         else
                             begin
                                 mensagem ('JODESIST', 2);   {'Desistiu'}
                                 c1 := ' ';
                             end;
                    end;
            else
                mensagem ('JOOPINV', 1);    {'Opção inválida'}
            end
        else
            case c2 of
                F1: ajudaOpcoesPrincipais;
                F2: salvaJogo;
                CIMA, BAIX, F9:
                    begin
                        c1 := menuOpcoesPrincipais;
                        goto interpreta;
                    end;
            else
                mensagem ('JOOPINV', 1);    {'Opção inválida'}
            end;

    until (c1 = ESC) or (upcase(c1) = 'A');

    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Enabled);
    checkBreak := true;
    setWindowTitle('jogavox');   //Normaliza título após edição
end;

{--------------------------------------------------------}
{                    cria um jogo novo
{--------------------------------------------------------}

procedure criaJogo;
var arq: textFile;
    c, c2: char;
begin
    dirJogo := criaPastaJogo;
    if dirJogo = '' then exit;

    mensagem ('JONOMNOV', 1);     {'Informe o nome do novo jogo'}
    sintReadln (nomeArqJogo);
    if nomeArqJogo = '' then
        begin
            nomeArqJogo := ExtractFileName(dirJogo) + '.jog';
            mensagem ('JOASSMES', 1);   {'Assumido o mesmo do diretório'}
            sintWriteln (nomeArqJogo);
            writeln;
        end;

    if ansiUppercase (copy (nomeArqJogo, length(nomeArqJogo)-3, 4)) <> '.JOG' then
        nomeArqJogo := nomeArqJogo + '.jog';

    assignFile (arq, nomeArqJogo);
    {$I-} reset (arq);  {$I+}
    if ioresult = 0 then
        begin
            close (arq);
            mensagem ('JODESTRU', 0);    {'Posso destruir o jogo existente?'}
            sintLeTecla (c, c2);
            writeln;
            if upcase(c) <> 'S' then
                begin
                    mensagem ('JODESIST', 2);   {'Desistiu'}
                    exit;
                end;
        end;

    criaJogoModelo;

    if salvaJogo then
        editaJogoCriado;
end;

{--------------------------------------------------------}
{                    edita um jogo
{--------------------------------------------------------}

procedure editaJogo;
begin
    arqTempGrafico := getTempFile('bmp');

    dirJogo := escolhePastaJogo;
    if dirJogo = '' then exit;

    if not pegaNomeJogo (nomeArqJogo) then exit;
    if not carregaEstruturaJogo (nomeArqJogo) then exit;

    editaJogoCriado;

    if FileExists(arqTempGrafico) then
         deleteFile (arqTempGrafico);
end;

end.
