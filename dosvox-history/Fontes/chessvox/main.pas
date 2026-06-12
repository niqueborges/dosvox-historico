{-------------------------------------------------------------------}
{
{    CHESSVOX - Programa de Xadrez Vox
{
{    Rotinas principais
{
{    Autor: José Antonio Borges
{
{    Adaptação para o DOSVOX do TSCP
{         Tom Kerrigan's Simple Chess Program (TSCP)
{         Copyright 1997 Tom Kerrigan
{
{    Em setembro/2007
{
{-------------------------------------------------------------------}

unit main;

interface

uses windows, sysutils,
     dvcrt, dvwin, dvform, dvHora,
     defs, data, parse, board,
     search, book, eval, prboard, svload, xadmsg;

procedure main_;

implementation

(* screen preparation and game initialization*)

procedure initialize;
var amb: string;
begin
    amb := sintAmbiente ('CHESSVOX', 'DIRCHESSVOX');
    if amb = '' then
        amb := 'c:\winvox\som\chessvox';

    sintInic (0, amb);
    clrscr;
    textBackground (BLUE);
    setWindowTitle('ChessVox');
    mensagem ('XDINIC', 0);   //'Xadrez sonorizado - NCE/UFRJ - ');
    sintWrite (version);
    textBackground (BLACK);
    writeln;
    textColor (YELLOW);
    writeln('Baseado no Tom Kerrigan''s');
    writeln('Simple Chess Program (TSCP)');
    writeln('TSCP versão 1.81, 2/5/03');
    writeln('Copyright 1997 Tom Kerrigan');
    textColor (WHITE);
    writeln;
    limpaBufTec;
    mensagem ('XDAPTF9', 1);   //'Aperte F9 para acionar o menu.');

    init_hash;
    init_board;
    open_book;
    gen;

    computer_side := EMPTY;
    max_time := 1 shl 25;
    max_depth := 4;
    last_play := '';
    play_time := now;
    debugging := false;
end;

(* save image for study and terminate *)

procedure terminate;
begin
    saveForStudy;

    writeln;
    writeln;
    mensagem ('XDFIM', 1);   //'Foi um prazer.  Compartilhe e disfrute!');
    delay (2000);
    sintFim;
    doneWinCrt;
end;

(* print_result() checks to see if the game is over, and if so,
   prints the result. *)

procedure print_result;
var i: integer;

    procedure kill (msg: string);
    var i: integer;
    begin
        playing := false;
        for i := 1 to 8 do sintBip;
        mensagem (msg, 1);
        for i := 1 to 4 do sintBip;
//        debugRecord();
    end;


begin
    (* is there a legal move? *)
    for i := 0 to first_move[1] - 1 do
        if (makemove(gen_dat[i].m.b)) then
            begin
                takeback();
                break;
            end;

    if hist_dat[hply-1].capture < 6 then
       begin
           mensagem ('XDTOMA', 0);    //Toma '
           mensagem (pegaTextoMensagem (piece_name[hist_dat[hply-1].capture]), 1);
       end;

    if i = first_move[1] then
        begin
            if (in_check(side)) then
                begin
                    if side = LIGHT then
                        kill('XDCHKPRE')    //'0-1 {Pretas: checkmate}')
                    else
                        kill('XDCHKBRA');   //'1-0 {Brancas: checkmate}');
                end
            else
                kill('XDEMPATE');   //('Jogo terminado em empate');
        end
    else
        if reps = 3 then
            kill('XDEMPATR')    //'Empate provocado por repetição')
        else
        if fifty >= 100 then
            kill('XDREGR50');   //'Empate pela regra dos cinqüenta movimentos');
end;

(* interactive options *)

function show_options: char;
const
    tabLetras: string[11] = 'TUHCNGRPJD' + #$1b;
var
    n: integer;
begin
    writeln;
    mensagem ('XDUSESET', 1);   //'Use as setas para opções');
    garanteEspacoTela (11);
    popupMenuCria(0, wherey, 40, 11, MAGENTA);
    popupMenuAdiciona('XDMENUT', '  T - Informar tempo de jogo');
    popupMenuAdiciona('XDMENUU', '  U - desfazer última jogada');
    popupMenuAdiciona('XDMENUH', '  H - histórico');
    popupMenuAdiciona('XDMENUC', '  C - configurar');
    popupMenuAdiciona('XDMENUN', '  N - novo jogo');
    popupMenuAdiciona('XDMENUG', '  G - grava jogo');
    popupMenuAdiciona('XDMENUR', '  R - recupera jogo');
    popupMenuAdiciona('XDMENUP', '  P - pausa jogadas do computador');
    popupMenuAdiciona('XDMENUJ', '  J - inicia jogadas do computador');
    popupMenuAdiciona('XDMENUD', '  D - cria arquivo para debug');
    popupMenuAdiciona('XDMNESC', '  ESC - termina o jogo');
    n := popupMenuSeleciona;
    if n <= 0 then
        show_options := #$1
    else
        show_options := tabLetras[n];
end;

(* parse the move s (in coordinate notation) and return the move's
   index in gen_dat, or -1 if the move is illegal *)

function move_using_coords (s: string): boolean;
var
    m: integer;
begin
    (* maybe the user entered a move? *)
    m := parse_move(s);
    if m <> -1 then
        begin
            mensagem (pegaTextoMensagem (piece_name[piece[gen_dat[m].m.b.from]]), 0);
            write (' ');
        end;

    if (m = -1) or (not makemove(gen_dat[m].m.b)) then
        begin
            mensagem ('XDILEGAL', 1);   //'Movimento ilegal.');
            if m = -1 then
                begin
                    mensagem ('XDNOTCOO', 1);   //'Use a notação de coordenadas.');
                    mensagem ('XDEXEMPL', 1);   //'Exemplo: d2d4, ou numa promoção f7f8Q.');
                end;
        end
    else
        begin
            ply := 0;
            gen;
            print_result;
        end;
    move_using_coords := m <> -1;
end;

(* show play time *)

procedure showTime;
var n: integer;
begin
    n := get_ms (play_time, now);
    sintWrite (intToStr (round (n div 1000)));
    mensagem ('XDSEGUND', 1);   //' segundos.');
end;

(* undo last movement *)

procedure undo;
begin
    if hply = 0 then
        begin
            sintBip;
            exit;
        end;

    computer_side := EMPTY;
    takeback;
    ply := 0;
    gen;

    mensagem ('XDOK', 1);   //'Ok');
end;

(* general configuration *)

procedure configure;
var s: string;
begin
    mensagem ('XDTMPMAX', 1);   //'Tempo máximo da partida (minutos): ');
    sintReadln (s);
    s := trim (s);
    if s <> '' then
        begin
            try
                 max_time := strToInt (s);
                 max_time := max_time*60000;
            except
                 max_time := 1 shl 25;
            end;
        end;

    mensagem ('XDNIVEL', 1);   //'Nível da pesquisa (entre 5 e 32)');
    sintReadln (s);
    s := trim (s);
    if s <> '' then
        begin
            try
                max_depth := strToInt (s);
            except
                max_depth := 5;
            end;
        end;

    mensagem ('XDTMPINA', 1);   //'Versão beta: temporização inativa');
    writeln;
end;

(* begin a new game *)

procedure newGame;
begin
    computer_side := EMPTY;
    init_board;
    gen;
end;

(* terminate a game *)

function quitGame: boolean;
var c, c2: char;
begin
    mensagem ('XDCNFFIM', 0);   //'Confirma fim? ');
    sintLeTecla (c, c2);
    writeln;

    quitGame := false;
    if upcase(c) <> 'N' then
        quitGame := true;
end;

(* show history and interact *)

procedure history;
var i: integer;
    svx, svy: integer;
begin
    if hply = 0 then
        begin
            sintBip;
            exit;
        end;

    svx := wherex;
    svy := wherey;
    mensagem ('XDUSESET', 1);   //'Use as setas para ler');

    window (1, 1, 80, 25);
    popupMenuCria(50, 14, 4, 10, RED);
    for i := hply-1 downto 0 do
        popupMenuAdiciona ('', move_str(hist_dat[i].m.b));
    popupMenuSeleciona;

    window (1, 3, 40, 25);
    gotoxy (svx, svy);
    writeln;
end;

(* options dispatcher *)

procedure optionExecute (c: char);
begin
    clreol;
    case upcase(c) of
         'T':  showTime;
         'U':  undo;
         'H':  history;
         'C':  configure;
         'N':  newGame;
         'G':  saveGame;
         'R':  loadSavedGame;
         'P':  begin
                    computer_side := EMPTY;  // pause Computer Game
                    mensagem ('XDPAUSAD', 1);   //'Máquina de jogo pausada.');
               end;
         'J':  begin
                   computer_side := side;   // start Computer Game
                   mensagem ('XDLIGAD', 1);   //'Máquina de jogo ligada.');
                   exit;
               end;
         'D':  debugSet;
         ESC:  playing := not quitGame;
     else
         mensagem ('XDOPINV', 1);   //'Opção inválida, aperte F9 para menu');
     end;
end;

(* get user command *)

procedure getUserInput;
var c: char;
    s: string;
label execFuncao;
begin
    repeat
        print_board;

        if wherex <> 1 then writeln;
        gotoxy (1, wherey);
        
        textBackground (RED);
        if side = 0 then
            mensagem ('XDBRANCS', 0)    //'Brancas')
        else
            mensagem ('XDPRETAS', 0);   //'Pretas');
        mensagem ('XDJOGAM', 0);   //' jogam');
        write('> ');
        textBackground (BLACK);

        c := readkey;
        if c = ESC then
            playing := not quitGame
        else
        if c = #0 then
            begin
                case readkey of
                    dvwin.F1, dvwin.F9: begin
                                c := show_options;
                                sintWriteln (c);
                                optionExecute (c);
                                if upcase(c) = 'J' then exit;
                            end;

                    dvwin.F8:     falaHora;
                    CTLF8:  falaDia;
                    DEL:    clrscr;

                    CIMA, BAIX, ESQ, DIR:
                            if move_using_arrows (s) then
                               if move_using_coords (s) then
                                   begin
                                       debugRecord('u: ' + s);
                                       exit;
                                   end;
                else
                    mensagem ('XDOPINF9', 1);   //'Opção inválida, aperte F9 para menu');
                end;
            end
        else
            begin
                insertKeyBuf (c);
                sintReadln (s);
                if length (s) = 1 then
                    begin
                       optionExecute (s[1]);
                       if upcase(c) = 'J' then exit;
                    end
                else
                    if move_using_coords (s) then
                        begin
                            debugRecord('u: ' + s);
                            exit;
                        end;
            end;

    until not playing;  // forever until quit program
end;

(* main() is basically an infinite loop that either calls
   think() when it's the computer's turn to move or prompts
   the user for a command (and deciphers it). *)

procedure main_;

label opcao, askAgain;
begin
    initialize;

    playing := true;
    while playing do
        begin
            print_board;

            if side = computer_side then
                begin  (* computer's turn *}

                    (* think about the move and make it *)
                    think(0);

                    if pv[0,0].u = 0 then
                        begin
                            mensagem ('XDSEMJOG', 1);   //'(não existem jogadas legais)');
                            computer_side := EMPTY;
                            continue;
                        end;

                    limpaBufTec;
                    if wherex <> 1 then
                        writeln;
                    textBackground (BLUE);
                    mensagem ('XDMEUJOG', 0);   //'Meu jogo: ');
                    textBackground (BLACK);

                    last_play := move_str(pv[0,0].b);

                    debugRecord ('c: ' + last_play);
                    writeln(last_play);
                    sintSoletra (last_play);
                    mensagem (pegaTextoMensagem (piece_name[piece[pv[0,0].b.from]]), 0);
                    write (' ');

                    makemove(pv[0,0].b);
                    ply := 0;
                    gen;
                    print_result;
                    if in_check (0) or in_check (1) then
                        begin
                            mensagem ('XDCHEQUE', 1);   //'Cheque');
                            debugRecord('c: check');
                        end;
                    continue;
                end;

           getUserInput;
           if in_check (0) or in_check (1) then
               begin
                   mensagem ('XDCHEQUE', 1);   //'Cheque');
                   debugRecord('u: check');
               end;
       end;

    close_book;

    terminate;
end;

end.

