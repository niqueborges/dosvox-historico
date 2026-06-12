{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Módulo de tratamento dos eventos aleatórios         }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

unit lueventos;

interface
uses
   dvcrt,
   dvwin,
   sysutils,
   lumsg,
   luvars;

procedure checaVazamento;
procedure checaEntupimento;

implementation

function veSeAcontece (x: integer): boolean;
begin
    veSeAcontece := random (x) = 0;
end;

{-------------------------------------------------------------}
{                     Vazamento                               }
{-------------------------------------------------------------}

procedure checaVazamento;
var
    vazou: boolean;
    combVazou: integer;

begin
    combVazou := random (5) + 5;
    vazou := veSeAcontece (5000);

    if vazou then
       begin
          if (comb - combVazou) < 0 then
             begin
                combVazou := comb;
                comb  := 0;
             end {if}
          else
             comb := comb - combVazou;

          clreol;
          sintsom ('VAZAMENT');
          textBackGround (RED);
          mensagem ('LUCOMVAZ', 0);  {'COMBUSTÍVEL VAZADO '}
          sintwriteint (combVazou);
          textBackGround (BLACK);
          writeln;
       end; {if}

end; {checaVazamento}

{-------------------------------------------------------------}
{                 Entupimento na mangueira                    }
{-------------------------------------------------------------}

procedure checaEntupimento;
var
    entupiu: boolean;
    fatorEntupimento: integer;

begin
    entupiu := veSeAcontece (2000);
    if entupiu then
        begin
            fatorEntupimento := random (5);
            combAplicar := (combAplicar * fatorEntupimento) div 5;

            clreol;
            textBackGround (RED);
            sintsom ('ENTUPIME');
            mensagem ('LUENTOPE', 0);  {'Entupimento na mangueira, combustível utilizado: '}
            sintwriteint(combAplicar);
            writeln ('.');
            mensagem ('LUINJETE', 0);  {'Injete mais combustível.'}
            textBackGround (BLACK);
            writeln;
        end; {if}

end; {entupimento}

end.
