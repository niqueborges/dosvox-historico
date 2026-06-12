{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de controle da operacao
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plopera;
interface
uses
    dvcrt, dvwin, dvForm, dvHora, dvAmplia,
    sysUtils,
    plvars, plmsg, plarq, pltela, plcursor, plcelula, plbloco, plcalc, plcomp,
    plFormul, videovox;

procedure opera;

implementation

var processando: boolean;

{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}
{      seleciona a opção com as setas no menu célula
{--------------------------------------------------------}

function selSetasOpCel: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'acml$jirv';
begin
    popupMenuCria (wherex, wherey, 22, 9, MAGENTA);
    MenuAdiciona ('PLGAJU09');  {'  A - Apaga'}
    MenuAdiciona ('PLGAJU10');  {'  C - Copia'}
    MenuAdiciona ('PLGAJU11');  {'  M - Move'}
    MenuAdiciona ('PLGAJU13');  {'  L - Largura'}
    MenuAdiciona ('PLGAJ11E');  {'  $ - Formata'}
    MenuAdiciona ('PLGAJU14');  {'  J - Justifica'}
    MenuAdiciona ('PLGAJ14A');  {'  I - Insere na coluna'}
    MenuAdiciona ('PLGAJ14B');  {'  R - Remove da coluna'}
    MenuAdiciona ('PLGAJ14C');  {'  V - Vai para célula'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpCel := tabLetrasOpcoes[n]
    else
        selSetasOpCel := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu célula
{--------------------------------------------------------}

procedure selMenuCelula;
var c1, c2: char;
begin
    pergunta ('PLQUALCL');  {'Qual sua opção de célula ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpCel;

    case upcase(c1) of
        'A': apagaCelula;
        'C': carimbaCelula;
        '$': formatoCelula;
        'L': larguraCelula;
        'J': justificaCelula;
        'I': insereEmbaixo;
        'R': removeEmbaixo;
        'V': vaiParaCelula;
        ESC: begin informa ('PLDESIS'); limpaBufTec; end;
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu bloco
{--------------------------------------------------------}

function selSetasOpBlo: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'ifacmdotn$jx';
begin
    popupMenuCria (wherex, wherey, 18, 12, MAGENTA);
    MenuAdiciona ('PLGAJU15');  {'  I - Início'}
    MenuAdiciona ('PLGAJU16');  {'  F - Fim'}
    MenuAdiciona ('PLGAJU09');  {'  A - Apaga'}
    MenuAdiciona ('PLGAJU10');  {'  C - Copia'}
    MenuAdiciona ('PLGAJU11');  {'  M - Move'}
    MenuAdiciona ('PLGAJ11A');  {'  D - Desmarca'}
    MenuAdiciona ('PLGAJ11B');  {'  O - Ordena'}
    MenuAdiciona ('PLGAJ11C');  {'  T - Textualiza'}
    MenuAdiciona ('PLGAJ11D');  {'  N - Numera'}
    MenuAdiciona ('PLGAJ11E');  {'  $ - Formata'}
    MenuAdiciona ('PLGAJU14');  {'  J - Justifica'}
    MenuAdiciona ('PLGAJU34');  {'  X - Musicaliza'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpBlo := tabLetrasOpcoes[n]
    else
        selSetasOpBlo := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu bloco
{--------------------------------------------------------}

procedure selMenuBloco;
var c1, c2: char;
begin
    pergunta ('PLQUALBL');  {'Qual sua opção de bloco ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpBlo;

    case upcase(c1) of
        'I': inicioBloco;
        'F': fimBloco;
        'A': apagaBloco;
        'C': copiaBloco;
        'M': moveBloco;
        'D': desmarcaBloco;
        'O': ordenaBloco;
        'T': textualizaBloco;
        'N': numeraAutoBloco;
        '$': FormatoBloco;
        'J': JustificaBloco;
        'X': MusicalizaBloco;
        ESC: begin informa ('PLDESIS'); limpaBufTec; end;
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu planilha
{--------------------------------------------------------}

function selSetasOpPla: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'nicrkp';
begin
    popupMenuCria (wherex, wherey, 30, 14, MAGENTA);
    MenuAdiciona ('PLGAJU17');  {'  N - Nova planilha'}
    MenuAdiciona ('PLGAJU18');  {'  I - Insere linha'}
    MenuAdiciona ('PLGAJU19');  {'  C - Insere coluna'}
    MenuAdiciona ('PLGAJU20');  {'  R - Remove linha'}
    MenuAdiciona ('PLGAJU21');  {'  K - Remove coluna'}
    MenuAdiciona ('PLGAJU23');  {'  P - Procura'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpPla := tabLetrasOpcoes[n]
    else
        selSetasOpPla := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu planilha
{--------------------------------------------------------}

procedure selMenuPlanilha;
var c1, c2: char;
begin
    pergunta ('PLQUALPL');  {'Qual sua opção de planilha ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpPla;

    case upcase(c1) of
        'N': novaPlanilha (false);
        'I': insereLinha;
        'C': insereColuna;
        'R': removeLinha;
        'K': removeColuna;
        'P': procuraCelula(false);
        ESC: begin informa ('PLDESIS'); limpaBufTec; end;
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu arquivo
{--------------------------------------------------------}

function selSetasOpArq: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'lgtrie';
begin
    popupMenuCria (wherex, wherey, 18, 10, MAGENTA);
    MenuAdiciona ('PLGAJU24');  {'  L - Lê'}
    MenuAdiciona ('PLGAJU25');  {'  G - Grava'}
    MenuAdiciona ('PLGAJ25A');  {'  T - Grava TXT'}
    MenuAdiciona ('PLGAJU26');  {'  R - Renomeia'}
    MenuAdiciona ('PLGAJU27');  {'  I - Importa CSV'}
    MenuAdiciona ('PLGAJU28');  {'  E - Exporta CSV'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpArq := tabLetrasOpcoes[n]
    else
        selSetasOpArq := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu arquivo
{--------------------------------------------------------}

procedure selMenuArquivo;
var c1, c2: char;
begin
    pergunta ('PLQUALAR');  {'Qual sua opção de arquivo ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpArq;

    case upcase(c1) of
        'L': LeArquivo (false);
        'G': GravaArquivo;
        'T': GravaTexto;
        'R': NovoNome('PLA', nomeArq);
        'I': LeArquivo (true);
        'E': ExportaArquivo (nomeArq);
        ESC: begin informa ('PLDESIS'); limpaBufTec; end;
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;
end;

{--------------------------------------------------------}
{      seleciona a opção com as setas no menu imprime
{--------------------------------------------------------}

function selSetasOpImp: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'tb';
begin
    popupMenuCria (wherex, wherey, 50, 4, MAGENTA);
    MenuAdiciona ('PLGAJU29');  {'  T - Tudo'}
    MenuAdiciona ('PLGAJU30');  {'  B - Bloco'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpImp := tabLetrasOpcoes[n]
    else
        selSetasOpImp := ENTER;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu fim
{--------------------------------------------------------}

function selSetasOpFim: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'asd';
begin
    popupMenuCria (wherex, wherey, 50, 6, MAGENTA);
    MenuAdiciona ('PLGAJU31');  {'  A - Abandona'}
    MenuAdiciona ('PLGAJU32');  {'  S - Salva'}
    MenuAdiciona ('PLGAJU33');  {'  D - Desiste'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpFim := tabLetrasOpcoes[n]
    else
        selSetasOpFim := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu fim
{--------------------------------------------------------}

procedure selMenuFim;
var c1, c2: char;
begin
    pergunta ('PLQUALFI');  {'Qual sua opção para finalizar ? '}
    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;
    pergunta ('');

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpFim;

    case upcase(c1) of
        'A': begin
            informa ('PLFIM'); {'Fim da planilha'}
            sintFim;
            doneWinCrt;
        end;

        'S': begin
            if guardaPlanilha (nomeArq) then
            begin
                informa ('PLARMDIS'); {'OK, armazenei em disco'}
                delay (250);
                informa ('PLFIM'); {'Fim da planilha'}
                sintFim;
                doneWinCrt;
            end
            else
            begin
                informa ('PLNAOSAI'); {'Finalização cancelada pois não consegui gravar no disco'}
            end;
        end;

        'D', ESC: begin
            informa ('PLDESIS'); {'Desistiu'}
            limpaBufTec;
        end;

    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu principal
{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'cbpaf';
begin
    popupMenuCria (wherex, wherey, 15, 16, MAGENTA);
    MenuAdiciona ('PLGAJU01');  {'  C - Celula'}
    MenuAdiciona ('PLGAJU02');  {'  B - Bloco'}
    MenuAdiciona ('PLGAJU03');  {'  P - Planilha'}
    MenuAdiciona ('PLGAJU04');  {'  A - Arquivo'}
    MenuAdiciona ('PLGAJU08');  {'  F - Fim'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu
{--------------------------------------------------------}

procedure selMenu;
var c1, c2: char;
begin
    pergunta ('PLQUALOP');  {'Qual sua opção ? ESC retorna'}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpcao;

    informa ('');
    case upcase(c1) of
        'C':  selMenuCelula;
        'B':  selMenuBloco;
        'P':  selMenuPlanilha;
        'A':  selMenuArquivo;
        'F':  selMenuFim;
        ESC:  begin
                  informa ('PLDESIS');
                  mensagemSonora ('PLEDITAN');
              end;
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
    end;

    mostraLinha (yatual);

    pergunta ('');
    if c1 <> ESC then
        mensagemSonora ('PLEDITAN');
end;

{--------------------------------------------------------}
{                  controle da operacao
{--------------------------------------------------------}

procedure opera;
var
    c: char;

    procedure exibeCelulaAtual;
    var s: string;
        salvax, salvay: integer;
    begin
        salvax := wherex;
        salvay := wherey;
        if existeCelula (xatual, yatual) then
            s := plan[yatual]^.cel[xatual]^.conteudo
        else
            s := '';
        gotoxy (1, 3);
        clreol;
        write (copy (s, 1, 80));
        gotoxy (salvax, salvay);

        if trim (s) <> '' then
            amplCampo (s, 1)
        else
            amplEsconde;
    end;

    procedure controles;
    var c: char;
    begin
        c := readkey;

        case c of
            F1    : falaCelula (xatual, yatual);
            F2    : gravaArquivo;
            F3    : leArquivo(false);
            F4    : begin
                        falaPosCel := not falaPosCel;
                        if falaPosCel then begin sintBip; sintBip; sintBip; end
                                      else sintBip;
                    end;
            F5    : procuraCelula (false);
            F6    : insereLinha;
            F7    : removeLinha;
            F8    : falaHora;
            F9    : selMenu;
            F10   : ;
            F11   :  selMenuFormat;
            F12   :  begin
                         with plan[yAtual]^.cel[xAtual]^ do
                             executaArquivo (trim(conteudo));
                     end;

            CTLF1 : falaRestoLinha (xatual, yatual);
            CTLF2 :;
            CTLF3 : vaiParaCelula;
            CTLF4 :;
            CTLF5 : procuraCelula(true);
            CTLF6:  insereColuna;
            CTLF7:  removeColuna;
            CTLF8 : falaDia;
            CTLF9 : leitorDeTela;
            CTLF10:;

            ALTF1 : falaRestoPlan (xatual, yatual);

            INS   : insereLinha;
            DEL   : begin
                        removeCelula (xatual, yatual);
                        reCalcular;
                        informa ('PLLIMPA');   {'Célula limpa'}
                    end;

            HOME  : primColLinha;
            TEND  : ultColLinha;

            PGUP  : sobePagina;
            PGDN  : descePagina;

            CTLPGUP: topoPlan;
            CTLPGDN: basePlan;

            CIMA  : sobeCursor;
            BAIX  : desceCursor;
            ESQ   : recuaCursor;
            DIR   : avancaCursor;

        end;

        exibeCelulaAtual;
    end;

{--------------------------------------------------------}
{                    Rotina principal
{--------------------------------------------------------}

label jaLeu;
var s: string;
begin

    informa ('PLINIFUN'); {'Editando - F9 opções gerais'}

    processando := true;
    while processando do
        begin
            if (not keypressed) and alterouTodaTela then
                mostraTela;

            c := readkey;
jaLeu:
            case c of
                '/' :   selMenu;

                ENTER:  begin
                            c := editaCelula (xatual, yatual);
                            if ord(c) >= 32 then
                                 begin
                                      limpaBufTec;
                                      insertKeyBuf(#0);
                                      insertKeyBuf(c);
                                 end
                            else
                            if (c <> ENTER) and (c <> ESC) then
                                goto jaLeu;
                        end;

                CTLENTER: insereLinha;

                ^B: begin
                        selMenuBloco;
                        mensagemSonora ('PLEDITAN');
                    end;

                ^L, ^K: falaPos;

                ^C: begin
                    with plan[yAtual]^.cel[xAtual]^ do
                        begin
                            xtransp := xatual;
                            ytransp := yatual;
                            sintBip;
                        end;
                end;

                ^V: begin
                        if not existeCelula (xtransp, ytransp) then
                            s := ''
                        else
                            s := plan[ytransp]^.cel[xtransp]^.conteudo;

                        if (s <> '') and (s[1] = '=') then
                            s := relocaFormula (s, xAtual-xtransp, yatual-ytransp, 0, 0, MAXCELLINHA, MAXLINPLAN);
                        formataCelula (xAtual, yAtual, s);
                        if (s <> '') and (s[1] = '=') then
                            compilaFormula (xAtual, yAtual, s);
                        reCalcular;
                        mostraTela;
                        falaCelula (xAtual, yAtual);
                    end;

                ^R: begin
                        recalcular;
                        sintBip;
                    end;

                ^Q: numeraAutoBloco;

                ^X: somaPos;
                ^Z: begin
                        if posicArmazenada <> '' then
                            begin
                                formataCelula (xAtual, YAtual, posicArmazenada);
                                falaCelula (xAtual, yAtual);
                                posicArmazenada:= '';
                            end;
                    end;

                TAB: avancaCursor;
                BS:  recuaCursor;
                ' ': falaCelula (xatual, yatual);

                ESC: begin
                         selMenuFim;
                         mensagemSonora ('PLEDITAN');
                     end;

                #0:  controles;
            else
                if ord(c) >= 32 then
                    begin
                        if existeCelula(xatual, yatual) then
                            sintBip
                        else
                            begin
                                if criaSemEnter then
                                    begin
                                        insertKeyBuf(c);
                                        c := ENTER;
                                        goto jaLeu;
                                    end;
                            end;
                    end
                else
                    sintBip;
            end;
        end;
end;

end.
