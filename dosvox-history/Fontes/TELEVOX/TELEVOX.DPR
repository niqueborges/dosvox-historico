{--------------------------------------------------------}
{
{   Caderno de Telefones - Vox
{
{   Autor:  José Antonio Borges
{
{   Baseado num programa de
{       Marcelo Pimentel e David Cipriano
{
{   Em Junho de 1994
{
{   Versao 1.4 em Abril de 1996
{
{--------------------------------------------------------}

Program TeleVox;

uses
  windows,
  sysUtils,
  DVcrt,
  DVWin,
  DVLeNum,
  dvForm,
  dvArq,
  dvhora,
  telMsg,
  TelTela,
  TelVars,
  TelItem,
  TelImpEtq,
  TelListag,
  telFolhe,
  telUtil,
  telConf,
  telAmbie,
  telArq;

{--------------------------------------------------------}
{                    ajuda principal
{--------------------------------------------------------}

Procedure ajuda;
begin
    textBackground(BLUE);
    mensagem ('TVAJUDA', 0); { As principais opcoes do Televox sao... }
    textBackground(BLACK);
    writeln;writeln;writeln;

    gotoxy (10, 6);
    mensagem ('TVAJ01', 0); //'N - Novo registro'
    gotoxy (10, 7);
    mensagem ('TVAJ02', 0); //'P - Procurar'
    gotoxy (10, 8);
    mensagem ('TVAJ03', 0); //'S - Selecionar'
    gotoxy (10, 9);
    mensagem ('TVAJ04', 0); //'F - Folhear'
    gotoxy (10, 10);
    mensagem ('TVAJ05', 0); //'R - Remover'
    gotoxy (10, 11);
    mensagem ('TVAJ06', 0); //'O - Ordenar'
    gotoxy (10, 12);
    mensagem ('TVAJ07', 0); //'I - Imprimir'
    gotoxy (10, 13);
    mensagem ('TVAJ08', 0); //'A - Operações com arquivos'
    gotoxy (10, 14);
    mensagem ('TVAJ09', 0); //'C - Configurar os campos'}

    gotoxy (5, 17);
    mensagem ('TVUTSEOP', 1); {'Utilize as setas para selecionar ou conhecer todas as opções'}
    clreol;
    writeln;
    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao (var c: char): char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [19] = 'NPSFROIACD'+ F2+ F3+ F5+ F7+ CTLF7+ F9+ '*'+ '/'+ ESC;

begin
    limpaBufTec;
    popupMenuCria (wherex, wherey, 50, 19, MAGENTA);
    MenuAdiciona ('TVAJ01'); {'N - Novo registro'}
    MenuAdiciona ('TVAJ02'); {'P - Procurar'}
    MenuAdiciona ('TVAJ03'); {'S - Selecionar'}
    MenuAdiciona ('TVAJ04'); {'F - Folhear'}
    MenuAdiciona ('TVAJ05'); {'R - Remover'}
    MenuAdiciona ('TVAJ06'); {'O - Ordenar'}
    MenuAdiciona ('TVAJ07'); {'I - Imprimir'}
    MenuAdiciona ('TVAJ08'); {'A - Arquivo externo'}
    MenuAdiciona ('TVAJ09'); {'C - Configurar'}
    MenuAdiciona ('TVAJ10'); {'D - Remover registros duplicados'}
    MenuAdiciona ('TVAJ11'); {'F2  - grava cadastro'}
    MenuAdiciona ('TVAJ12'); {'F3  - troca de arquivo'}
    MenuAdiciona ('TVAJ13'); {'F5  - procura'}
    MenuAdiciona ('TVAJ14'); {'F7  - informa numero de registros'}
    MenuAdiciona ('TVAJ14A');{'ctrl-F7  - informa numero de registros selecionados do total'}
    MenuAdiciona ('TVAJ15'); {'F9  - seleciona ou tira a seleção do ultimo lido'}
    MenuAdiciona ('TVAJ16'); {'* - seleciona todos os registros'}
    MenuAdiciona ('TVAJ17'); {'/ - tira a seleção de todos os registros'}
    MenuAdiciona ('TVAJ18'); {'ESC - termina'}

    n := popupMenuSeleciona;
    if (n > 0) and (n<= 10) then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
    if (n >= 10) and (n <= 15) then
        begin
            c := tabLetrasOpcoes[n];
            selSetasOpcao := #0;
        end
    else
    if (n >= 16) and (n <= 18) then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;
 
{--------------------------------------------------------}
{                       inicializacao
{--------------------------------------------------------}

Procedure Inicializa;
var
    dir: string;
Begin
    dir := sintAmbiente('TELEVOX', 'DIRTELEVOX', '@\som\televox');
    SintInic (0, dir);

    setWindowText (crtWindow, 'Televox');
    logotipo;

    if existeArqSom ('TVINIC') then
        sintSom ('TVINIC') { Televox, Caderno de telefones }
    else
        sintetiza (pegaTextoMensagem('TVINIC'));

    if existeArqSom ('TVVERSAO') then
        sintsom ('TVVERSAO'); {'Versão'}
    sintSoletra (VERSAO);

    fim := False;
    cadastrados := 0;
    inserindo := true;
    posatual := 0;
    fundo := FuNDOPADRAO;
    posFolheia := TOPO;
    campoConfigura := false;

    dirAgendas := sintAmbiente ('TELEVOX', 'AGENDAS');
    if dirAgendas = '' then
        getDir (0, dirAgendas);
    if dirAgendas[length(dirAgendas)] = '\' then
        delete (dirAgendas, length (dirAgendas), 1);

    imprimeNomeCampo := upcase(sintAmbiente ('TELEVOX', 'NOMECAMPO', 'NAO')[1]) = 'S';
    limpaBaixo (3);
end;

{--------------------------------------------------------}
{                    finalização
{--------------------------------------------------------}

Procedure Finaliza;
begin
    if gravaCadastro (true) then
        begin
            if (dirAgendas = '') and (pos ('\', nomeCadastro) <> 0) then
                begin
                    while pos ('\', nomeCadastro) <> 0 do
                        begin
                            dirAgendas := dirAgendas +
                            copy (nomeCadastro, 1, pos ('\', nomeCadastro));
                            delete (nomeCadastro, 1, pos ('\', nomeCadastro));
                        end;

                    if dirAgendas[length(dirAgendas)] = '\' then
                        delete (dirAgendas, length(dirAgendas), 1);
                    sintGravaAmbiente ('TELEVOX', 'AGENDAS', dirAgendas)
                end
            else
            if (dirAgendas = '') and (pos ('/', nomeCadastro) <> 0) then
                begin
                    while pos ('/', nomeCadastro) <> 0 do
                        begin
                            dirAgendas := dirAgendas +
                            copy (nomeCadastro, 1, pos ('/', nomeCadastro));
                            delete (nomeCadastro, 1, pos ('/', nomeCadastro));
                        end;

                    if dirAgendas[length(dirAgendas)] = '/' then
                        delete (dirAgendas, length(dirAgendas), 1);
                    sintGravaAmbiente ('TELEVOX', 'AGENDAS', dirAgendas)
                end;

            if cadastrados <= 0 then
                begin
                    {$I-}  erase (arqfone);  {$I+}
                    if ioresult <> 0 then;
                end;

            limpaTela;
            msgBaixo ('TVOBRIG', ''); {'Obrigado, até a próxima.'}
            sintFim;

            fim := True;
        end;
end;

{--------------------------------------------------------}
{                 escolhe tipo de impressao
{--------------------------------------------------------}

function escolheTipoDeImpressao: char;
var c, c2: char;
begin
    writeln; writeln;
    mensagem ('TVTIPIMP', 2); {'Escolha o tipo de impressão'}
    mensagem ('TVTIPOSF', 0); {'E - etiquetas ou envelopes, L - listagem: '}
    sintLeTecla (c, c2);
    writeln;
    c := upcase (c);
    result := c;
    if (c = ESC) then exit;

    if not (c in ['E','L']) then
        begin
            msgBaixo ('TVOPINV', ''); {'Operação inválida'}
            result := ESC;
        end;
end;

{--------------------------------------------------------}
{                 programa principal
{--------------------------------------------------------}

var c, c2: char;
label sai;

Begin
    Inicializa;
    leCadastro (true, true);
    if numCampos < (fundo - topo + 1) then
        fundo := numCampos + topo - 1;

    Repeat
        limpaBufTec;

        gotoxy (1, 3);
        clreol;
        textBackground (blue);
        mensagem ('TVQUALOP', 0); {'Qual a sua opção: '}
        textBackground (black);
        clreol;

        sintLeTecla (c, c2);
        writeln;

        limpatela;

        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
            c := selSetasOpcao (c2);

        if c = #0 then
                case c2 of
               F1: ajuda;
               F2: if gravaCadastro (false) then;
               F3: trocaArquivo;
               F5: procura;
               F7: falaNumRegs (true);
               CTLF7: falaQuantosSelecionados;
               F8: falaHora;
               CTLF8: falaDia;
               F9: marcaOuDesmarcaUltimoLido;
           end
        else
            case upcase(c) of
                '*': marcaTodos;
                '/': desmarcaTodos;
                'N': inclui;
                'P': procura;
                'S': seleciona;
                'F': folheiaCadastro;
                'R': remove;
                'O': ordena;
                'I': case escolheTipoDeImpressao of
                         'E': imprimeEtiquetas;
                         'L': imprimeListagem;
                     end;
                'A': arquiva;
                'C': configura;
                'D': removeRegsDuplicados;
                ENTER:;

                ^F: fim := true;
                #27: finaliza;
            else
                msgBaixo ('TVERROP', ''); {'Opção errada: aperte F1 para ajuda'}
        end;

sai:
    Until fim ;
    gotoxy (1, 25);
  doneWinCRT;
end.
