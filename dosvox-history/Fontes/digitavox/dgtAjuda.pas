{-------------------------------------------------------------}
{
{       Digitavox - Menus de opções do Sistema
{
{       Autor: Neno Henrique da Cunha Albernaz
{       Em 05de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtAjuda;

interface

uses
    dvcrt,
    dvform,
    dvhora,
    dvWin,
    windows,
    dgtMsg,
    dgtTela,
    dgtVars;

procedure MenuAdiciona (msg: string);
function selSetasOpcaoPrincipal (var c2: char): char;
procedure ajudaListaCursos;
function selSetasListaCursos (var c2: char): char;
procedure ajudaListaLicoes (nomeCurso: string);
function selSetasListaLicoes (nomeCurso: string; var c2: char): char;
procedure ajudaPraticaLicao (nLicao: integer; nomeCurso: string);
function selSetasPraticaLicao (nLicao: integer; nomeCurso: string; var c2: char): char;
procedure ajudaListaEstatisticasCurso(nomeCurso: string);
function selSetasListaEstatisticasCurso (nLicao: integer; nomeCurso: string; var c2: char): char;
function selSetasFiltroEstatisticas (nomeCurso: string): integer;

implementation

{-------------------------------------------------------------}
{       Utilizado para montar o menu de opções
{-------------------------------------------------------------}

procedure MenuAdiciona (msg: string);
begin
    popupMenuAdiciona (msg, pegaTextoMensagem (msg)); {}
end;

{--------------------------------------------------------}
{       seleciona as opções do menu principal com as setas
{--------------------------------------------------------}

function selSetasOpcaoPrincipal (var c2: char): char;
var n, nOpc: integer;
const
    tabLetrasOpcoes: string [6] = 'RCUT*' + ESC;

begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    nOpc := 6;
    telaPrincipal;

    writeln (pegaTextoMensagem ('DGTAJUOPC'));  {'As opções são'}
    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('DGTAJCU_R');   {'     R        - Reconhecimento de teclado'}
    MenuAdiciona ('DGTAJCU_CU');  {'     C        - Cursos de digitação'}
    MenuAdiciona ('DGTAJCU_U');   {'     U        - Usuário logado'}
    MenuAdiciona ('DGTAJCU_TE');   {'     T        - Alterar teclagem'}
    MenuAdiciona ('DGTAJCU_AST');   {'     *        - Configurar'}
    MenuAdiciona ('DGTAJCU_SDD'); {'     ESC      - Sair do Digitavox'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= nOpc) then
        result := tabLetrasOpcoes[n]
    else
        result := 'N';
end;

{-------------------------------------------------------------}
{       ajuda da lista de cursos
{-------------------------------------------------------------}

procedure ajudaListaCursos;
begin
    telaListaCursos (listaArqCursos.count);
    mensagem ('DGTAJUOPC', 1);  {'As opções são'}
    mensagem ('DGTAJCU_SE', 1);  {'Seta esquerda - Fala a apresentação'}
    mensagem ('DGTAJCU_SD', 1);  {'Seta direita - Fala a instrução '}
    mensagem ('DGTAJCU_EN', 1);  {'Enter - Entrar no curso'}
    mensagem ('DGTAJCU_L', 1);  {'L - Total de lições do curso'}
    mensagem ('DGTAJCU_C', 1);  {'C - Ultima lição concluída'}
    mensagem ('DGTAJCU_U', 1);  {'U - Usuário atual logado'}
    mensagem ('DGTAJU_F9', 1);  {'Aperte F9 para conhecer outras opções'}

    limpaBufTec;
    sintBip;
    while not keypressed do;
end;

{--------------------------------------------------------}
{       seleciona as opções da lista de cursos com as setas
{--------------------------------------------------------}

function selSetasListaCursos (var c2: char): char;
var n, nOpc: integer;
const
    tabLetrasOpcoes: string [13] = ESQ + DIR + ENTER + 'LCUNQDTEG' + ESC;

begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    nOpc := 13;
    telaListaCursos (listaArqCursos.count);
    writeln (pegaTextoMensagem ('DGTAJUOPC'));  {'As opções são'}
    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('DGTAJCU_SE'); {'Seta esquerda - Fala a apresentação'}
    MenuAdiciona ('DGTAJCU_SD'); {'Seta direita  - Fala a instrução'}
    MenuAdiciona ('DGTAJCU_EN'); {'Enter - Entrar no curso'}
    MenuAdiciona ('DGTAJCU_L'); {'L - Total de lições do curso'}
    MenuAdiciona ('DGTAJCU_C'); {'C - Ultima lição concluída'}
    MenuAdiciona ('DGTAJCU_U'); {'U - Usuário atual logado'}
    MenuAdiciona ('DGTAJCU_N'); {'N - Nome do arquivo do curso'}
    MenuAdiciona ('DGTAJCU_Q'); {'Q - Informa qual o curso do total'}
    MenuAdiciona ('DGTAJCU_D'); {'D - Dados sobre lição'}
    MenuAdiciona ('DGTAJCU_T'); {'T - Desafio do tempo'}
    MenuAdiciona ('DGTAJCU_E'); {'E - Estatísticas do curso'}
    MenuAdiciona ('DGTAJCU_G'); {'G - Gerar relatório'}
    MenuAdiciona ('DGTAJ_ESC'); {'ESC - Sair'}

    n := popupMenuSeleciona;
    if (n = 1) or (n = 2) then
        begin
            c2 := tabLetrasOpcoes[n];
            result := #0;
        end
    else
    if (n > 2) and (n <= nOpc) then
        result := tabLetrasOpcoes[n]
    else
        begin
            c2 := F12;
            result := #0;
        end
end;

{-------------------------------------------------------------}
{       ajuda da lista de lições
{-------------------------------------------------------------}

procedure ajudaListaLicoes (nomeCurso: string);
begin
    telaListaLicoes (nomeCurso);
    mensagem ('DGTAJUOPC', 1);  {'As opções são'}
    mensagem ('DGTAJCU_SE', 1);  {'Seta esquerda - Fala a apresentação'}
    mensagem ('DGTAJCU_SD', 1);  {'Seta direita  - Fala a instrução'}
    mensagem ('DGTAJLI_EN', 1);  {'Enter - Entra na lição'}
    mensagem ('DGTAJLI_N', 1);  {'N - Fala o nome do curso'}
    mensagem ('DGTAJCU_L', 1);  {'L - Total de lições do curso'}
    mensagem ('DGTAJCU_U', 1);  {'U - Usuário atual logado'}
    mensagem ('DGTAJU_F9', 1);  {'Aperte F9 para conhecer outras opções'}

    limpaBufTec;
    sintBip;
    while not keypressed do;
end;

{--------------------------------------------------------}
{       seleciona as opções da lista de lições com as setas
{--------------------------------------------------------}

function selSetasListaLicoes (nomeCurso: string; var c2: char): char;
var n, nOpc: integer;
const
    tabLetrasOpcoes: string [13] = ESQ + DIR + ENTER + 'NLUQDETAI' + ESC;

begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    nOpc := 13;
    telaListaLicoes (nomeCurso);
    writeln (pegaTextoMensagem ('DGTAJUOPC'));  {'As opções são'}
    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('DGTAJCU_SE'); {'Seta esquerda - Fala a apresentação'}
    MenuAdiciona ('DGTAJCU_SD'); {'Seta direita  - Fala a instrução'}
    MenuAdiciona ('DGTAJLI_EN'); {'Enter - Entra na lição'}
    MenuAdiciona ('DGTAJLI_N'); {'N - Fala o nome do curso'}
    MenuAdiciona ('DGTAJCU_L'); {'L - Total de lições do curso'}
    MenuAdiciona ('DGTAJCU_U'); {'U - Usuário atual logado'}
    MenuAdiciona ('DGTAJLI_Q'); {'Q - Informa qual a lição do total disponível'}
    MenuAdiciona ('DGTAJCU_D'); {'D - Dados sobre lição'}
    MenuAdiciona ('DGTAJLI_E'); {'E - Fala exercícios da lição'}
    MenuAdiciona ('DGTAJLI_T'); {'T - Fala o desafio do tempo'}
    MenuAdiciona ('DGTAJLI_A'); {'A - Fala apresentação do curso'}
    MenuAdiciona ('DGTAJLI_I'); {'I - Fala instrução do curso'}
    MenuAdiciona ('DGTAJ_ESC'); {'ESC - Sair'}

    n := popupMenuSeleciona;
    if (n = 1) or (n = 2) then
        begin
            c2 := tabLetrasOpcoes[n];
            result := #0;
        end
    else
    if (n > 2) and (n <= nOpc) then
        result := tabLetrasOpcoes[n]
    else
        begin
            c2 := F12;
            result := #0;
        end
end;

{-------------------------------------------------------------}
{       ajuda da prática de exercícios da lição
{-------------------------------------------------------------}

procedure ajudaPraticaLicao (nLicao: integer; nomeCurso: string);
begin
    telaCursoLicao (nLicao, nomeCurso);
    mensagem ('DGTAJUOPC', 1);  {'As opções são'}
    mensagem ('DGTAJPRA_SE', 1);  {'Seta esquerda - Fala repetição e total de repetições'}
    mensagem ('DGTAJPRA_SD', 1);  {'Seta direita  - Fala o restante do exercício'}
    mensagem ('DGTAJPRA_CSD', 1); {'Ctrl direita  - Soletra o restante do exercício'}
    mensagem ('DGTAJPRA_SB', 1);  {'Seta baixo    - Fala a próxima letra a digitar e com qual dedo'}
    mensagem ('DGTAJPRA_SC', 1);  {'Seta cima     - Fala o exercício atual'}
    mensagem ('DGTAJPRA_F12', 1);  {'     F12      - Fala o tempo decorrido, o total e o percentual gasto'}
    mensagem ('DGTAJPRA_ESC', 1);  {'      ESC      - Cancela a prática da lição'}
    mensagem ('DGTAJU_F9', 1);  {'Aperte F9 para conhecer outras opções'}

    limpaBufTec;
    sintBip;
    while not keypressed do;
end;

{--------------------------------------------------------}
{       seleciona as opções da prática do exercício da lição
{--------------------------------------------------------}

function selSetasPraticaLicao (nLicao: integer; nomeCurso: string; var c2: char): char;
var
    n, nOpc: integer;
const
    tabLetrasOpcoes: string [17] = ESQ + DIR + CTLDIR + BAIX + CIMA + CTLESQ + CTLUP + CTLDOWN + F2 + F3 + F4 + F5 + F6 + F7 + F8 + F12 + ESC;

begin
    C2 := ENTER; //Nada faz, evita passar sem valor.
    nOpc := 17;
    telaCursoLicao (nLicao, nomeCurso);
    writeln (pegaTextoMensagem ('DGTAJUOPC'));  {'As opções são'}
    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('DGTAJPRA_SE'); {'Seta esquerda - Fala repetição e total de repetições'}
    MenuAdiciona ('DGTAJPRA_SD'); {'Seta direita  - Fala o restante do exercício'}
    MenuAdiciona ('DGTAJPRA_CSD'); {'Ctrl direita - Soletra o restante do exercício'}
    MenuAdiciona ('DGTAJPRA_SB'); {'Seta baixo    - Fala a próxima letra a digitar e com qual dedo'}
    MenuAdiciona ('DGTAJPRA_SC'); {'Seta cima     - Fala o exercício atual'}
    MenuAdiciona ('DGTAJPRA_CSE');{'Ctrl esquerda - Fala percentual de acertos'}
    MenuAdiciona ('DGTAJPRA_CSC');{'Ctrl cima     - Fala a apresentação'}
    MenuAdiciona ('DGTAJPRA_CSB');{'Ctrl baixo    - Fala a instrução'}
    MenuAdiciona ('DGTAJPRA_F2'); {'     F2       - Fala a próxima letra a digitar e com qual dedo'}
    MenuAdiciona ('DGTAJPRA_F3'); {'     F3       - Soletra o restante do exercício'}
    MenuAdiciona ('DGTAJPRA_F4'); {'     F4       - Fala o restante do exercício'}
    MenuAdiciona ('DGTAJPRA_F5'); {'     F5       - Fala o exercício atual'}
    MenuAdiciona ('DGTAJPRA_F6'); {'     F6       - Fala a lição e repete a apresentação'}
    MenuAdiciona ('DGTAJPRA_F7'); {'     F7       - Repete a instrução da lição'}
    MenuAdiciona ('DGTAJPRA_F8'); {'     F8       - Fala a hora'}
    MenuAdiciona ('DGTAJPRA_F12'); {'     F12      - Fala o tempo decorrido, o total e o percentual gasto'}
    MenuAdiciona ('DGTAJPRA_ESC'); {'     ESC     - Cancela a prática da lição'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= (nOpc - 1)) then
        begin
            c2 := tabLetrasOpcoes[n];
            result := #0;
        end
    else
    if n = nOpc then
        result := tabLetrasOpcoes[n]
    else
        begin
            c2 := F9; //Não faz nada
            result := #0;
        end
end;

{-------------------------------------------------------------}
{       Ajuda da lista de estatísticas das lições do curso
{-------------------------------------------------------------}

procedure ajudaListaEstatisticasCurso(nomeCurso: string);
begin
    telaListaLicoesEstatisticas (nomeCurso);
    mensagem ('DGTAJUOPC', 1);  {'As opções são'}
    mensagem ('DGTAJES_SE', 1);  {'Seta esquerda - Fala se foi concluída'}
    mensagem ('DGTAJES_SD', 1);  {'Seta direita - Fala se chegou no fim'}
    mensagem ('DGTAJES_EN', 1);  {'Enter - exibe estatísticas da lição'}
    mensagem ('DGTAJLI_E', 1);  {'E - Fala exercícios da lição'}
    mensagem ('DGTAJLI_T', 1);  {'T - Fala o desafio do tempo'}
    mensagem ('DGTAJES_Q', 1);  {'Q - Informa qual item da lista do total'}
    mensagem ('DGTAJ_ESC', 1);  {'ESC - Sair'}
    mensagem ('DGTAJU_F9', 1);  {'Aperte F9 para conhecer outras opções'}

    limpaBufTec;
    sintBip;
    while not keypressed do;
end;

{--------------------------------------------------------}
{       seleciona as opções da lista de estatísticas do curso
{--------------------------------------------------------}

function selSetasListaEstatisticasCurso (nLicao: integer; nomeCurso: string; var c2: char): char;
var
    n, nOpc: integer;
const
    tabLetrasOpcoes: string [13] = ESQ + DIR + ENTER + 'ETQLCUNG' + F5 + ESC;

begin
    C2 := ENTER; //Nada faz, evita passar sem valor.
    nOpc := 13;
    telaListaLicoesEstatisticas (nomeCurso);
    writeln (pegaTextoMensagem ('DGTAJUOPC'));  {'As opções são'}

    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('DGTAJES_SE'); {'Seta esquerda - Fala se foi concluída'}
    MenuAdiciona ('DGTAJES_SD'); {'Seta direita - Fala se chegou no fim'}
    MenuAdiciona ('DGTAJES_EN'); {'Enter - exibe estatísticas da lição'}
    MenuAdiciona ('DGTAJLI_E'); {'E - Fala exercícios da lição'}
    MenuAdiciona ('DGTAJLI_T'); {'T - Fala o desafio do tempo'}
    MenuAdiciona ('DGTAJES_Q'); {'Q - Informa qual item da lista do total'}
    MenuAdiciona ('DGTAJCU_L'); {'L - Total de lições do curso'}
    MenuAdiciona ('DGTAJCU_C'); {'C - Ultima lição concluída'}
    MenuAdiciona ('DGTAJCU_U'); {'U - Usuário atual logado'}
    MenuAdiciona ('DGTAJLI_N'); {'N - Fala o nome do curso'}
    MenuAdiciona ('DGTAJCU_G'); {'G - Gerar relatório'}
    MenuAdiciona ('DGTAJES_F5'); {'F5 - Filtrar a lista'}
    MenuAdiciona ('DGTAJ_ESC'); {'ESC - Sair'}

    n := popupMenuSeleciona;
    if ((n > 0) and (n <=  2)) or (n = (nOpc - 1)) then
        begin
            c2 := tabLetrasOpcoes[n];
            result := #0;
        end
    else
    if ((n > 2) and (n <= (nOpc -2))) or (n = nOpc) then
        result := tabLetrasOpcoes[n]
    else
        begin
            c2 := F12;
            result := #0;
        end
end;

{-------------------------------------------------------------}
{       Seleciona o tipo do filtro das estatísticas com as setas
{-------------------------------------------------------------}

function selSetasFiltroEstatisticas (nomeCurso: string): integer;
begin
    telaListaLicoesEstatisticas (nomeCurso);
    mensagem ('DGTSELFIL', 2); {'Selecione o filtro com as setas e tecle Enter no desejado'}
    popupMenuCria (wherex, wherey, 79-wherex, 12, MAGENTA);
    MenuAdiciona ('DGTMESLI'); {'Mesma lição'}
    MenuAdiciona ('DGTCONCLU');{'Concluídas'}
    MenuAdiciona ('DGTNAOCOS'); {'Não concluídas'}
    MenuAdiciona ('DGTCOMAPE'); {'Concluídas com maior performance'}
    MenuAdiciona ('DGTCOMEPE'); {'Concluídas com menor performance'}
    MenuAdiciona ('DGTCHEFIM'); {'Chegou no fim'}
    MenuAdiciona ('DGTDESPRA'); {'Desistiu da prática'}
    MenuAdiciona ('DGTTMPESG'); {'Tempo esgotado'}
    MenuAdiciona ('DGTNAESTE'); {'Não esgotou tempo'}
    MenuAdiciona ('DGTMEDETE'); {'Mesmo desafio de tempo'}
    MenuAdiciona ('DGTDIDETE'); {'Escolher desafio de tempo'}
    MenuAdiciona ('DGTMESDA'); {'Mesma data'}

    result := popupMenuSeleciona;
end;

{--------------------------------------------------------}
begin
end.
