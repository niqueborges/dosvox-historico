{-------------------------------------------------------------}
{
{    Editor de textos sonoro simplificado
{
{    Autor: José Antonio Borges
{
{    Cooperação técnica: Marcelo Pimentel
{
{    Em 04/09/98
{
{-------------------------------------------------------------}

program minied;

uses windows, sysUtils, dvcrt, dvwin, dvArq, meMsg, dvamplia;

const
    VERSAO = '4.0';
    MAXLIN = 5000;
    TAMLINHA = 250;
type
    tlinha = string[TAMLINHA];
    plinha = ^tlinha;
var
    linhas: array [1..MAXLIN] of plinha;
    arq: text;
    nlin, linAtual: integer;
    editando: boolean;
    buscado: string;
    nomeArq: string;
    dirSom: string;
    acessoRapido: boolean;

var fator: integer;

{--------------------------------------------------------}

procedure tituloJanela (s: string);
var nomeJan: array [0..144] of char;
begin
    strPcopy (nomeJan, 'Mini Editor ' + s);
    setWindowText (crtWindow, nomeJan);
end;

{--------------------------------------------------------}

function pegaNomeArq: string;
var nomeArq: string;
    i: integer;
begin
    nomeArq := '';
    for i := 1 to paramCount do
        begin
            nomeArq := trim (paramStr(i));
            if maiuscAnsi (nomeArq) <> '/D' then break;
        end;

    if nomeArq = '' then
        begin
            while keypressed do readkey;
            mensagem ('MENOMARQ', 1);  {'Informe o nome do arquivo'}
            nomeArq := obtemNomeArq (15);
            if nomeArq = '' then
                begin
                    mensagem ('MECANC', 1);  {'Cancelado'}
                    sintFim;
                    doneWinCrt;
                end;
        end;

    pegaNomeArq := nomeArq;
end;

{--------------------------------------------------------}

procedure inicializa;
var
    traduzOem: boolean;
    s: string;
    salva, i: integer;
label erro;

    function traduzParaAnsi (s: string): string;
    begin
        s := s + #$0;
        OemToAnsi (@s[1], @s[1]);
        traduzParaAnsi := copy (s, 1, length (s)-1);
    end;

begin
    clrscr;
    tituloJanela ('Mini Editor');

    dirSom := sintAmbiente ('MINIED', 'DIRMINIED');
    if dirSom = '' then
        dirSom := 'c:\winvox\som\minied';
    sintInic (0, dirSom);

    textBackground (BLUE);
    write ('Projeto DOSVOX - 1998 - ');

    acessoRapido := false;
    for i := 1 to paramCount do
       if (maiuscAnsi(paramStr(i)) = '/D') then acessoRapido := true;

    if acessoRapido then
        write ('Mini Editor')
    else
        mensagem ('METITULO', 0);  {'Mini Editor'}
    writeln ('   v' + VERSAO);
    textBackground (BLACK);
    writeln;
    delay (500);

    salva := amplFator;
    amplFim;
    amplInic (25-salva, salva);

    nomeArq := pegaNomeArq;

    amplFim;
    amplInic (1, salva);

    tituloJanela (nomeArq);

    nlin := 1;
    new (linhas [1]);
    linhas [1]^ := '';
    linAtual := 1;
    buscado := '*(&%^#$&*^@%*^&@#%*$';   {lixo}

    assignFile (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MEARQNOV', 1);  {'Arquivo novo'}
            mensagem ('MEAPTF9', -1);  {'Aperte F9 para ajuda'}
            exit;
        end;

    traduzOem := acessoRapido;

    if not eof (arq) then    { arquivo existe e não está vazio }
        begin
            dispose (linhas [1]);
            nlin := 0;
        end;

    while not eof (arq) do
        begin
            if nlin >= MAXLIN then
                begin
erro:
                    mensagem ('MESEMMEM', 1);  {'Memória esgotada'}
                    mensagem ('METENTER', 1);  {'Tecle enter'}
                    close (arq);
                    exit;
                end;

            readln (arq, s);
            nlin := nlin + 1;                             
            new (linhas [nlin]);
            linhas[nlin]^ := '';
            while length (s) > 0 do
                begin
                    if traduzOem then
                        linhas [nlin]^ := traduzParaAnsi (copy (s, 1, TAMLINHA))
                    else
                        linhas [nlin]^ := copy (s, 1, TAMLINHA);
                    delete (s, 1, TAMLINHA);
                    if length (s) > 0 then
                        begin
                            if nlin >= MAXLIN then goto erro;
                            nlin := nlin + 1;
                            new (linhas [nlin]);
                        end;
                end;
        end;
    close (arq);
end;

{--------------------------------------------------------}

function gravaArquivo: boolean;
var i: integer;
label erro;
begin
     gravaArquivo := true;

     {$I-} rewrite (arq);  {$I+}
     if ioresult <> 0 then
         begin
erro:
             clrScr;
             mensagem ('MEERRGRV', 1);  {'Erro de gravacao.'}
             mensagem ('MEUSEF2',  1);  {'Use ctrl F2 para trocar o nome'}
             gravaArquivo := false;
             {$I-} close (arq);  {$I+}
             if ioresult <> 0 then;
             while sintFalando do;
             exit;
         end;

     for i := 1 to nlin do
         begin
             {$I-}writeln (arq, linhas [i]^);  {$I+}
             if ioresult <> 0 then
                 goto erro;
         end;

     if not editando then
         for i := 1 to nlin do
             dispose (linhas [i]);

     close (arq);
     clrscr;
     mensagem ('MEARQGRV', 1);  {'Arquivo gravado'}
end;

{--------------------------------------------------------}

procedure mostraTela;
var i: integer;
begin
    for i := 4 to 24 do
        begin
            gotoxy (1, i);
            if ((linAtual + i - 13) > 0) and
               ((linAtual + i - 13) <= nlin) then
                write (linhas[linAtual+i-13]^);
            clreol;
        end;
    gotoxy (1, 25);
    clreol;
    textBackGround (BLUE);

    gotoxy (10, 25);
    write (linAtual);
    gotoxy (20, 25);
    write (nomeArq);
    gotoxy (50, 25);
    write ('Aperte F9 para ajuda');
    textBackGround (BLACK);
end;

{--------------------------------------------------------}

procedure ordena;
var i, j: integer;
    temp: plinha;
    c: char;
begin
     gotoxy (1, 1); clreol;
     textBackground (RED);
     mensagem ('MECNFORD', 0);  {'Aperte S para confirmar ordenação'}
     textBackground (BLACK);
     c := sintReadkey;
     mensagem ('MEESPERE', -1);  {'Espere'}

     while (nlin > 1) and (linhas [nlin]^ = '') do
         begin
             dispose (linhas [nlin]);
             nlin := nlin - 1;
         end;

     if upcase (c) = 'S' then
         begin
             for i := 1 to nlin-1 do
                 for j := i+1 to nlin do
                       begin
                           if linhas [i]^ > linhas [j]^ then
                               begin
                                   temp := linhas [i];
                                   linhas [i] := linhas [j];
                                   linhas [j] := temp;
                               end;
                       end;

             linAtual := 1;
         end;

     mensagem ('MEOK', -1);  {'OK'}
 end;

{--------------------------------------------------------}

procedure edita;
var s: string;
    i: integer;
    c, retorno: char;
    salvaLin: integer;

label mvcima, mvbaixo, insereLinha, achou, buscaDeNovo;
begin
    editando := true;

    while editando do
        begin
            mostraTela;
            s := linhas [linAtual]^;
            amplCampo(s, 0);

            if not keypressed then
                if s = '' then
                    sintClek
                else
                    sintetiza (s);

            retorno := sintEditaCampo (s, 1, 13, TAMLINHA, 80, true);
            linhas [linAtual]^ := s;

            case retorno of
                CIMA:
                     begin
    mvcima:
                         linAtual := linAtual - 1;
                         if linAtual <= 0 then
                             begin
                                 sintBip;
                                 delay (200);
                                 linAtual := 1;
                             end;
                     end;
                BAIX:
                     begin
    mvbaixo:
                         linAtual := linAtual + 1;
                         if linAtual > nlin then
                             begin
                                 sintBip;
                                 delay (200);
                                 linAtual := nlin;
                             end;
                     end;
                PGUP:
                     begin
                         linAtual := linAtual - 19;
                         goto mvcima;
                     end;

                PGDN:
                     begin
                         linAtual := linAtual + 19;
                         goto mvbaixo;
                     end;

                CTLPGUP:  linAtual := 1;
                CTLPGDN:  linAtual := nlin;

                CTLENTER:
                    if nlin <= MAXLIN then
                        begin
               insereLinha:
                            for i := nlin downto linAtual  do
                                linhas [i+1] := linhas [i];
                            nlin := nlin+1;
                            new (linhas [linAtual]);
                            linhas [linAtual]^ := '';
                            mensagem ('MENOVLIN', -1);  {'Nova linha'}
                        end
                    else
                        mensagem ('MESEMMEM', -1);  {'Memória esgotada'}

                ENTER:
                    if nlin > MAXLIN then
                        mensagem ('MESEMMEM', -1)  {'Memória esgotada'}
                    else
                        begin
                            linAtual := linAtual+1;
                            goto insereLinha;
                        end;

                CTLF2:   begin
                               gotoxy (1, 1);  clreol;
                               textBackground (RED);
                               mensagem ('MENOMARQ', 0);  {'Nome do arquivo ? '}
                               textBackground (BLACK);
                               sintReadln (s);
                               if nomeArq <> '' then
                                    begin
                                        nomeArq := s;
                                        tituloJanela (nomeArq);
                                        assign (arq, nomeArq);
                                    end;
                         end;

                F2:  if gravaArquivo then;

                F3:  begin
                  	 str (linAtual, s);
                         mensagem ('MELINHA', -1);  {'Linha '}
                         sintetiza (s);
                         delay (500);
                     end;

              { F4: tratado pela rotina de edicao }

                F5:  begin
                         gotoxy (1, 1); clreol;
                         textBackground (RED);
                         mensagem ('METXTBUS', 0);  {'Informe o texto buscado '}
                         textBackground (BLACK);
                         sintReadln (buscado);
                         salvaLin := linAtual;
              buscaDeNovo:
                         if buscado = '' then
                             for i := linAtual to nlin do
                                 begin
                                     if linhas [i]^ = '' then
                                     begin
                                          linAtual := i;
                                          mensagem ('MEOK', -1);
                                          goto achou;
                                     end;
                                 end
                         else
                             for i := linAtual to nlin do
                                 if pos (buscado, linhas[i]^) <> 0 then
                                     begin
                                          linAtual := i;
                                          mensagem ('MEOK', -1);
                                          goto achou;
                                     end;

                         linAtual := salvaLin;
                         mensagem ('MENAOACH', -1);  {'Não achou'}
              achou:
                     end;

                CTLF5: begin
                           salvaLin := linAtual;
                           linAtual := linAtual + 1;
                           goto buscaDeNovo;
                       end;

                F6:  ordena;

                F7:
                     begin
                         if nlin <> 1 then
                             begin
                                 dispose (linhas [linAtual]);
                                 nlin := nlin-1;
                                 for i := linAtual to nlin do
                                     linhas [i] := linhas [i+1];
                             end
                         else
                             linhas [1]^ := '';
                         if linAtual > nlin then linAtual := nlin;
                         mensagem ('MELINREM', -1);  {'linha removida'}
                     end;

              { F4: tratado pela rotina de edicao }

                F9:
                    begin
                       clrscr;
                       textBackground (BLUE);
                       mensagem ('MEAJU01', 1);  {'As principais opções deste programa são'}
                       textBackground (BLACK);
                       mensagem ('MEAJU02', 1);  {'ENTER insere linha'}
                       mensagem ('MEAJU03', 1);  {'F1    fala palavra'}
                       mensagem ('MEAJU04', 1);  {'F2    grava'}
                       mensagem ('MEAJU05', 1);  {'F3    informa linha atual'}
                       mensagem ('MEAJU06', 1);  {'F4    controle da soletragem'}
                       mensagem ('MEAJU07', 1);  {'F5    busca trecho'}
                       mensagem ('MEAJU08', 1);  {'F6    ordena arquivo'}
                       mensagem ('MEAJU09', 1);  {'F7    remove linha atual'}
                       mensagem ('MEAJU10', 1);  {'F8    Informa hora'}
                       mensagem ('MEAJU11', 1);  {'F9    ajuda'}
                       mensagem ('MEAJU12', 1);  {'ESC termina'}
                       writeln;
                       textBackground (BLUE);
                       mensagem ('METENTER', 1);  {'Pressione Enter'}
                       textBackground (BLACK);
                       readln;
                   end;

                ESC:
                     if acessoRapido then
                         editando := false
                     else
                         begin
                             clrscr;
                             textBackground (BLUE);
                             mensagem ('MECNFFIM', 0);  {'Confirma fim ? '}
                             textBackground (BLACK);
                             c := sintReadKey;
                             writeln (c);
                             if upcase (c) = 'S' then
                                 editando := false
                             else
                                 clrscr;
                         end;
            end;
        end;
end;

{--------------------------------------------------------}

procedure finaliza;
begin
   sintSom ('MEOK');
   while sintFalando do;
   sintFim;
   delay (500);
   doneWinCrt;
end;

{--------------------------------------------------------}

var c: char;
label vaiEditar;
begin
   inicializa;
   clrscr;

   vaiEditar:
   sintApagaAuto := false;
   edita;

   if not acessoRapido then
       begin
           mensagem ('MEQUERGV', 0);  {'Quer gravar o arquivo ? '}
           c := sintReadKey;
           writeln (c);
           if upcase (c) <> 'N' then
               if not gravaArquivo then
                   goto vaiEditar;
       end;

   finaliza;
end.

