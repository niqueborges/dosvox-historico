{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de desenho do tabuleiro                      }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crdesen;

interface
uses dvcrt, dvwin, sysUtils, crvars, crmsg;

procedure areaLegendas;
procedure todaTela;
procedure limpaTela;
procedure geraMoldura (nx, ny: integer);
procedure desenhaCruzadas (nx, ny: integer; modelo: TModelo);
procedure testaModelo;

implementation

procedure areaLegendas;
begin
    window (36, 3, 80, 25);
end;

procedure todaTela;
begin
    window (1, 1, 80, 25);
end;

procedure limpaTela;
begin
    window (1, 1, 80, 25);
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('CRINIC') + versao);
    textBackground (BLACK);
    writeln;
end;

procedure geraMoldura (nx, ny: integer);
var i: integer;
begin
    for i := 3 to 25 do
        begin
            gotoxy (1, i);
           // clreol;
        end;

    textColor (yellow);
    textBackground (red);

    gotoxy (1, 3);
    write ('   ');
    for i := 1 to nx do
        write (chr(i-1+ord('A')), ' ');
    write (' ');

    gotoxy (1, 4+ny);
    write ('   ');
    for i := 1 to nx do
        write (chr(i-1+ord('A')), ' ');
    write (' ');

    for i := 1 to ny do
        begin
            gotoxy (1, 3+i);
            write (i:2);
            gotoxy (nx*2+3, 3+i);
            write (i:2);
        end;

    textBackground (black);
    textColor (white);
end;

procedure desenhaCruzadas (nx, ny: integer; modelo: TModelo);
var i, j: integer;
begin
    geraMoldura (nx, ny);
    textBackground (lightCyan);
    textColor (Black);

    for i := 1 to ny do
        begin
            gotoxy (3, 3+i);
            for j := 1 to nx do
                begin
                if modelo [i,j] <> '*' then
                    write (' ', ansiUpperCase(modelo [i,j]))
                else
                    begin
                        textBackground (blue);
                        write ('  ');
                        textBackground (lightCyan);
                    end;
                end;
        end;

    textBackground (black);
    textColor (white);
end;

procedure testaModelo;
const
   mdl: TModelo = (
       'eroiusflxkj*oie',
       'sflkjx*odiewruo',
       'fklasjdflfkj*dl',
       'sflkjx*oidewruo',
       'eroiusflkfj*oie',
       'er....a.lkj*oie',
       'sflkjfx*oiewruo',
       'fklass*jdflk...',
       'iwrewfr*sflkjx*',
       'erofdffasdfiusf',
       'erdiusdflkj*oie',
       'sflkjxf*oiewru.',
       'fklasjdfglkj*dl',
       'fkla*sjdflkj*dl',
       'eroiussflkj*oie');
begin
    desenhaCruzadas (15, 15, mdl);
end;

end.
