{-------------------------------------------------------------}
{
{    Programa Agenvox: agenda eletrônica
{
{    Autores: Bernard Condorcet, José Antonio Borges e Geraldo Junior
{
{    Em 7/05/2003
{
{-------------------------------------------------------------}

program Agenda;

uses dvCrt, dvWin, dvForm, dvHora,
    windows, sysUtils,
    agForm, agCalend, agProg, agFolhei, agGastos, agUtil, agVars, agMsg;

{--------------------------------------------------------}
{Mostra menu principal
{--------------------------------------------------------}

procedure menuPrincipal;
begin

    tocaEfeito ('agMenu');

    mensagem ('AGOPTEC', 1); {'Opções nas teclas:'}
    mensagem ('AGAJUD02', 1);  {'  E   Escolhe um outro dia'}
    mensagem ('AGAJUD03', 1);  {'  P   Procurar compromissos'}
    mensagem ('AGAJUD04', 1);  {'  F   Folhear compromissos'}
    mensagem ('AGAJUD05', 1);  {'  G   Controlar gastos'}
    mensagem ('AGAJUD06', 1);  {'  C   Calendário'}
    mensagem ('AGAJUD08', 1);  {'  D   Definir diretório de trabalho'}
    mensagem ('AGAJUD09', 1);  {'  I   Inicialização seletiva'}
    mensagem ('AGAJUD10', 1);  {'  B   efetuar backup'}
    mensagem ('AGAJUD07', 1);  {'  F9  Bloco de Notas'}

end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu principal
{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'epfgcdib';

begin
    popupMenuCria (wherex, wherey, 50, 11, MAGENTA);
    MenuAdiciona ('AGAJUD02');  {'  E   Escolhe um outro dia'}
    MenuAdiciona ('AGAJUD03');  {'  P   Procurar compromissos'}
    MenuAdiciona ('AGAJUD04');  {'  F   Folhear compromissos'}
    MenuAdiciona ('AGAJUD05');  {'  G   Controlar gastos'}
    MenuAdiciona ('AGAJUD06');  {'  C   Calendário'}
    menuAdiciona ('AGAJUD08');  {'  D   Definir diretório de trabalho'}
    menuAdiciona ('AGAJUD09');  {'  I   Inicialização seletiva'}
    menuAdiciona ('AGAJUD10');  {'  B   efetuar backup'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}
{          Tratamento do teclado no menu principal
{--------------------------------------------------------}

procedure trataTecladoMenuPrincipal;
var c1, c2: char;
    processando: boolean;
    opcao: char;
label deNovo, executa;
begin

    deNovo:

    processando := true;

    while (processando)  do
       begin

           if not trocaDir (dir_agenda) then
           begin
               writeln;
               mensagem ('AGNAOPOS', 1); {'Não posso trabalhar no diretório especificado'}
               exit;
           end;

          getdate (ano, mes, dia, sem);
          data:= int2 (dia) + '/' + int2 (mes) + '/' + int2str (ano);

          usarRelogio:= false;
          despertaOk:= false;
          jaEscolheuDia:= false;
          procurandoCompromissos:= false;

           writeln;
           TextBackGround (blue);
           mensagem ('AGMENPRI', 0);  {'Agenda, qual sua opção? '}
           TextBackGround (black);

           sintTecla (c1, c2);
           writeln;

           if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasOpcao;
                    goto executa;
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuPrincipal
           else
           if (c1 = #0) and (c2 = F9) then
               abreBlocoDeNotas
           else
           if (c1 = #0) and (c2 = F8) then
               begin
                   falaDia;
                   FalaHora;
               end
           else
executa:
               case upcase(c1) of

                   'E': escolheUmDia;
                   'P': procuraCompromissos;
                   'F':
                       begin
                           verificaCompromissos;
                           trataTecladoFolhear;
                       end;
                   'G': trataTecladoGastos;
                   'C': carregaCalendario;
                   'D':
                        begin
                            mensagem ('AGESTTRA', 0); {'Estou trabalhando em : '}
                            sintWriteln (dirTrab);
                            mensagem ('AGDESTRO', 0); {'Deseja trocar ? S ou N : '}
                            opcao:= sintReadKey;
                            writeln (opcao);
                            if upcase (opcao) = 'S' then
                            begin
                                mensagem ('AGNOVDIR', 0); {'Informe então o novo diretório de trabalho : '}
                                sintReadln (dirTrab);
                                if dirTrab = '' then
                                    dirTrab:= 'C:\winvox\';
                                if dirTrab[length(dirTrab)] <> '\' then
                                    dirTrab:= dirTrab + '\';
                                if not trocaDir (dir_agenda) then
                                begin
                                    dirTrab:= 'C:\winvox\';
                                    mensagem ('AGDIRINE', 1); {'Diretório inexistente, irei manter o padrão'}
                                end
                                else
                                    mensagem ('AGDIRRED', 1); {'OK, diretório redefinido'}
                                carregaNomeArq;
                            end;
                        end;
                   'I':
                        begin
                            mensagem ('AGINIMOD', 0); {'Estou inicializando a agenda no modo '}
                            if upcase (funInicial[1]) = 'C' then
                                mensagem ('AGCAL', 1) {'calendário'}
                            else
                            if upcase (funInicial[1]) = 'G' then
                                mensagem ('AGGAS', 1) {'gastos pessoais'}
                            else
                                mensagem ('AGFOL', 1); {'folheamento'}
                            mensagem ('AGDESTRO', 0); {'Deseja trocar ? S ou N : '}
                            opcao:= sintReadKey;
                            writeln (opcao);
                            if upcase (opcao) = 'S' then
                            begin
                                mensagem ('AGCGF', 0); {'Digite C para modo calendário, G para gastos pessoais ou F para folheamento'}
                                opcao:= sintReadkey;
                                writeln (opcao);
                                if (upcase(opcao) = 'C') or (upcase(opcao) = 'G') or (upcase(opcao) = 'F') then
                                begin
                                    mensagem ('AGRECONF', 1); {'OK, irei reconfigurar o modo de inicialização'}
                                    if upcase(opcao) = 'C' then
                                        funInicial:= 'Calendário';
                                    if upcase(opcao) = 'G' then
                                        funInicial:= 'Gastos pessoais';
                                    if upcase(opcao) = 'F' then
                                        funInicial:= 'Folheamento';
                                end
                                else
                                    mensagem ('AGINIPAD', 1); {'Opção inválida, irei inicializar mantendo o padrão'}
                            end;
                        end;
                    'B':
                        begin
                            mensagem ('AGCAMBAC', 0); {'Informe o caminho completo do diretório para o backup : '}
                            sintReadln (dirTrab_bk);
                            if dirTrab_bk = '' then
                                goto deNovo;
                            if dirTrab_bk[length(dirTrab_bk)] <> '\' then
                                dirTrab_bk:= dirTrab_bk + '\';
                            {$I-} chDir (dirTrab_bk); {$I+}
                            if ioResult <> 0 then
                                {$I-} mkDir (dirTrab_bk); {$I+}
                                if ioResult <> 0 then
                                begin
                                    mensagem ('AGNAOBAC', 1); {'Não foi possível criar o diretório para o backup'}
                                    goto deNovo;
                                end;
                            dirTrab_bk:= dirTrab_bk + 'agenda';
                            {$I-} chDir (dirTrab_bk); {$I+}
                            if ioResult <> 0 then
                                {$I-} mkDir (dirTrab_bk); {$I+}
                                if ioResult <> 0 then
                                begin
                                    mensagem ('AGPRODIS', 1); {'Problemas no disco, desculpe, não será possível efetuar o backup'}
                                    goto deNovo;
                                end;
                            if trocaDir (dir_agenda) then
                                fazBackup;
                        end;

                   ESC:  processando := false;
                   #$0d: ;
               else
                   mensagem ('AGOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

    mensagem ('AGSAIR', 0);  {'Deseja realmente sair, S ou N ? '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) <> 'S' then
        goto deNovo;

end;

{--------------------------------------------------------}
{                    Finaliza o programa
{--------------------------------------------------------}

procedure finaliza;
begin
    sintGravaAmbiente ('AGENDA', 'INICIALIZA',  funInicial);
    sintGravaAmbiente ('AGENDA', 'DIRTRABALHO',  dirTrab);

    tocaEfeito ('agViola');

    textBACKGROUND (BLUE);
    mensagem ('AGFIM', 1);
    textBACKGROUND (BLACK);

    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                 Inicializa o programa                  }
{--------------------------------------------------------}

procedure inicializa;
var erro: integer;
    jan: integer;
begin

    jan := findWindowEx(0, 0, 'dvwincrt', 'AGENDA');
    if jan <> 0 then halt;

    SintInic (0, sintAmbiente('AGENDA', 'DIRAGENDA'));

    val (sintAmbiente('TRADUTOR', 'VELOCIDADE'), velocidadeDosvox, erro);
    if erro <> 0 then
        velocidadeDosvox:= 2;

    somDespert:= sintAmbiente('AGENDA', 'SOMDESPERTADOR');
    if somDespert = '' then
        somDespert:= 'PicaPau.wav';

    funInicial:= sintAmbiente('AGENDA', 'INICIALIZA');
    if funInicial = '' then
        funInicial:= 'Folheamento';

    dirTrab:= sintAmbiente('AGENDA', 'DIRTRABALHO');
    if dirTrab = '' then
        dirTrab:= 'C:\winvox\';
    if dirTrab[length(dirTrab)] <> '\' then
        dirTrab:= dirTrab + '\';

    bipaNoSpeaker:= false;
    jaEscolheuDia:= false;
    procurandoCompromissos:= false;

    getdate (ano, mes, dia, sem);
    data:= int2 (dia) + '/' + int2 (mes) + '/' + int2str (ano);
    dvcrt.getTime (hora, min, seg, cent);

    clrscr;
    setWindowText (crtWindow, 'AGENDA');
    delay (200);
    textBACKGROUND (BLUE);
    mensagem ('AGINIC', 0); {'Agenda Eletrônica - NCE/UFRJ - v.'}
    writeln (VERSAO);
    sintSoletra (VERSAO);
    textBackground (BLACK);
    writeln;

    if hora < 5 then
        mensagem ('AGBOANOI', 0)   { boa noite }
    else if hora < 12 then
        mensagem ('AGBOMDIA', 0)   { bom dia }
    else if hora < 18 then
        mensagem ('AGBOATAR', 0)   { boa tarde }
    else
        mensagem ('AGBOANOI', 0);  { boa noite }

end;

{--------------------------------------------------------}
{Define e testa validade do diretório de trabalho
{--------------------------------------------------------}

procedure defineDirTrab;
var opcao: char;
label deNovo;
begin

    deNovo:

    if not trocaDir (dir_agenda) then
    begin
        writeln;
        mensagem ('AGNAOPOS', 1); {'Não posso trabalhar no diretório especificado'}
        mensagem ('AGDESTRO', 0); {'Deseja trocar ? S ou N : '}
        opcao:= sintReadKey;
        writeln;
        if upcase (opcao) = 'S' then
        begin
            mensagem ('AGNOVDIR', 0); {'Informe então o novo diretório de trabalho : '}
            sintReadln (dirTrab);
            if dirTrab = '' then
                dirTrab:= 'C:\winvox\';
            if dirTrab[length(dirTrab)] <> '\' then
                dirTrab:= dirTrab + '\';
        end
        else
            finaliza;
        goto deNovo;
    end
    else
    begin
        mensagem ('AGIREITR', 0); {'irei trabalhar em '}
        sintWriteln (dirTrab);
        carregaNomeArq;
    end;

end;

{--------------------------------------------------------}
{Rotina principal
{--------------------------------------------------------}

begin

    inicializa;

    defineDirTrab;

    if upcase (funInicial[1]) = 'C' then
        carregaCalendario
    else
    if upcase (funInicial[1]) = 'G' then
        trataTecladoGastos
    else
        iniciaFolheamento;

    trataTecladoMenuPrincipal;

    finaliza;

end.
