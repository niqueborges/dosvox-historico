{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de edição da palavra                         }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit credipal;

interface
uses windows, dvwin, dvcrt, dvHora, sysutils, crmsg;

function editaPalavra (var campo, campoModelo: string): char;

implementation

{--------------------------------------------------------}
{                    edita um item
{--------------------------------------------------------}

function editaPalavra (var campo, campoModelo: string): char;
var c, c2: char;
    curx, i: integer;

label fechaCampo;

{--------------------------------------------------------}

var
    salvaCampo: string;
    x, y: integer;

const
    espurios: set of char = ['<', '"', '(', '{', '[', '-', '=', '.', '_', '>', '*'];

label moveu, processaC2;

    procedure troca (var x1, x2: integer);
    var temp: integer;
    begin
         temp := x1;  x1 := x2;  x2 := temp;
    end;

    {--------------------------------------------------------}

    procedure caracComum (c: char);
    begin
        if curx > length(campo) then
            begin
                sintBip;
                exit;
            end;

        if (campo[curx] <> '.') and (campo[curx] <> ' ') and
           (ansiUpperCase(c) <> AnsiUpperCase(campo[curx])) then
               begin
                   sintBip; sintBip;
               end;

        campo[curx] := c;
        gotoxy (x+curx-1, y);
        write (c);
        sintCarac (c);
        curx := curx + 1;
    end;

begin
    x := wherex;
    y := wherey;
    gotoxy (wherex, wherey+2);
    write (pegaTextoMensagem ('CRF6PEGA'));  {'F6 mostra a letra, mas evite fazer isso.'}

    curx := 1;
    salvaCampo := campo;

    repeat
        gotoxy (x, y);
        write (campo);
        gotoxy (curx-1+x, y);

        if sintFalaAcumulada <> '' then
            sintetiza ('');

        c := readkey;
        sintPara;

        c2 := #0;
        if c = #0 then
            begin
                c2 := readkey;
                if c2 in [#16..#18] then
                    c := readkey; {ALT-GR q,w,e}
            end;

        if c = #0 then
            begin
processaC2:
                case c2 of
                    ESQ: if curx <= 1 then
                              sintBip
                          else
                              begin
                                  curx := curx - 1;
                                  sintCarac (campo [curx]);
                              end;

                    DIR: begin
                              if curx > length (campo) then
                                  sintBip
                              else
                                  begin
                                      sintCarac(campo [curx]);
                                      curx := curx + 1;
                                  end;
                         end;

                    HOME:  curx := 1;

                    TEND:  begin
                              curx := length (campo)+1;
                              repeat
                                  curx := curx - 1;
                              until (curx = 0) or (campo[curx] <> ' ');
                              curx := curx + 1;
                          end;

                    DEL: if curx <= length(campo) then
                              begin
                                  sintSom ('_DEL');
                                  sintCarac (campo[curx]);
                                  campo[curx] := '.';
                              end;

                    F1:  sintetiza (campo);

                    F6:  begin
                             if curx <= length(campo) then
                                 begin
                                     mensagem ('CRDICAPO', -1);  {'Dica para esta posição: '}
                                     campo[curx] := campoModelo[curx];
                                     sintCarac (campoModelo[curx]);
                                 end;
                         end;

                    F8:     falaHora;
                    CTLF8:  falaDia;
                    CTLF1:  sintetiza (campo);
                    #120..#129: ;

                else
                    goto FechaCampo;
                end;
            end
        else
            begin
                c2 := c;
                case c of
                    NOFOCUS: ;
                    GOTFOCUS:  begin
                                   while sintFalando do waitMessage;
                                   sintetiza (campo);
                                   end;

                    ENTER, CTLENTER, ESC: begin
                                    c2 := c;
                                    goto FechaCampo;
                                end;

                    TAB:   goto fechaCampo;

                    BS:    begin
                               if curx = 1 then
                                   sintBip
                               else
                                   begin
                                       curx := curx - 1;
                                       if curx > 0 then
                                          begin
                                              sintSom ('_DEL');
                                              sintCarac (campo[curx]);
                                              campo[curx] := '.';
                                          end;
                                   end;
                           end;

                    ^U:    begin
                                campo := salvaCampo;
                                curx := 1;
                                sintBip; sintBip; sintBip;
                           end;

                    ^Y:    begin
                               for i := 1 to length (campo) do
                                   campo [i] := ' ';
                               sintSom ('_CPOAPA');
                               curx := 1;
                           end;

                else
                    if c >= #$20 then
                        caracComum (c);
                end;
            end;

    until false;

fechaCampo:
    editaPalavra := c2;
end;

end.
