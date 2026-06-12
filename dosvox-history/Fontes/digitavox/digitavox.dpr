{-------------------------------------------------------------}
{
{       Digitavox - Cursos de digitação
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{    Versão 2.0 em Abril/2020
{
{-------------------------------------------------------------}

program Digitavox;

uses
    dvcrt,
    dvWin,
    sysutils,
    windows,
    dvform,
    dvhora,
    dgtMsg,
    dgtTela,
    dgtCursos,
    dgtUsuarios,
    dgtTecla,
    dgtConf,
    dgtVars,
    dgtUtil,
    dgtAjuda;

{-------------------------------------------------------------}
{       Testa se pastas Usuario e Relatorio existem, caso negativo cria.
{-------------------------------------------------------------}

procedure criarPastasUsuaRela;
begin
    if not DirectoryExists (dirUsuarios)  then
        begin
            {$I-}  mkdir (dirUsuarios);  {$I+}
            if ioresult <> 0 then;
        end;
    if not DirectoryExists (dirRelatorios)  then
        begin
            {$I-}  mkdir (dirRelatorios);  {$I+}
            if ioresult <> 0 then;
        end;
end;

{-------------------------------------------------------------}
{       rotina de inicializacao
{-------------------------------------------------------------}

procedure inicializa;
begin
    inicializarFala;
    inicializarParametros;
    criarPastasUsuaRela;
    limpaBufTec;
    setWindowTitle ('Digitavox');
    telaPrincipal;
    mensagem ('DGTDIGVER', -1);  {'Digitavox Versão'}
    sintsoletra (VERSAO);
    sintetiza (TIPOVERSAO);
    while sintFalando do waitMessage;  // controle das paradas de fala
    if not keypressed then delay(5);
end;

{-------------------------------------------------------------}
{       Verifica se existe pastas cursos e usuários.
{-------------------------------------------------------------}

function existePastasDigitavox: boolean;
begin
    result := false;
    if not DirectoryExists (dirCursos) then
        mensagem ('DGTNPCUR', 1)  {'Erro: pasta de Cursos não encontrada.'}
    else
    if not DirectoryExists (dirUsuarios)  then
        mensagem ('DGRTNPUSU', 1)  {'Erro: pasta de usuários não encontrada.'}
    else
    if not DirectoryExists (dirRelatorios)  then
        mensagem ('DGTERRPRE', 1)  {'Erro: pasta de relatórios não encontrada.'}
    else
        result := true;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

var c, c2: char;
label fim;
begin
    inicializa;
    if (not existePastasDigitavox) or (not registrarUsuario) then goto fim;
    c := 'N';

    repeat
        textBackground (BLUE);
        mensagem ('DGTQUAOPC', 0); {'Qual sua opção? F1 ajuda'}
        textBackground (BLACK);
        writeln; writeln;

        pegaTeclado (falarTecla, c, c2);
        if (c = #0) and (c2 in [CIMA, BAIX, F9]) then
            c := selSetasOpcaoPrincipal (c2);

        if c = #0 then
            begin
                case c2 of
                    F1: msgBaixo ('DGTSELSET'); {'Selecione a opção com as setas verticais e tecle Enter na desejada'}
                    F4:     desligarFalarTecla;
                    F8:     falaHora;
                    CTLF8:  falaDia;
                    DEL: begin
                            mensagem ('DGTINIC', -1);  {'Digitavox - Cursos de digitação - Versão '}
                            sintetiza (VERSAO);
                         end;
                end;
            end
        else
            begin
                c := upcase (c);

                case c of
                    'U': sintetiza (nomeUsuario);
                    ^U:  sintSoletra (nomeUsuario);
                    'R': testaTeclas;
                    '*': configDigitavox;
                    'T':     desligarFalarTecla;
                    'C': if montarListaCursos then
                            begin
                                listarCursos;
                                desmontarListaCursos;
                                end;

                    ESC:   repeat
                                limpabaixo(23);
                                TextBackground (RED);
                                mensagem ('DGTSAIDIGI', 0); {'Gostaria de realmente sair do Digitavox? Tecle S para sair ou N para cancelar.'}
                                TextBackground (BLACK);
                                c := upcase(popupMenuPorLetra ('SN'));
                                if c in ['S', ENTER] then c := ESC
                                else
                                    begin
                                        msgBaixo('DGTDESIST'); {'Desistiu'}
                                        c := 'N';
                                    end;
                            until upcase(c) in ['S', 'N', ENTER, ESC];

                    'N':; //Nada faz, reservado para o retorno da seleção das opções com as setas.

                else
                    if c <> ESC then
                        msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;
            end;

        telaPrincipal;
        tocaEfeito ('TECLADO');

    until c = #$1b;

fim:
    tocaEfeito ('SAIR'); // Toca o som de saída
    msgBaixo ('DGTFIM');  {'Fim do Digitavox'}
    while sintFalando do waitMessage;
    sintFim;
    doneWinCrt;
end.
