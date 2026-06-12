{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de leitura interativa                        }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iuleitin;

interface
uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes;

procedure leituraInterativa (sl: TStringList);

implementation

procedure leituraInterativa (sl: TStringList);
var i: integer;
    pausado: boolean;
    processando: boolean;
    c, c2: char;
begin
    i := 0;
    pausado := false;
    processando := true;

    while processando do
        begin
            if (i >= 0) and (i < sl.count) then
                sintWriteln (sl[i]);

            if pausado then
                while not keypressed do waitMessage
            else
                while sintFalando do waitMessage;

            if keypressed then
                begin
                    c := readkey;
                    if c = ESC then processando := false
                    else
                    if c = ' ' then pausado := false
                    else
                    if c = #$0 then
                        begin
                            pausado := true;

                            c2 := readkey;
                            if c2 = BAIX then i := i+1
                            else
                            if c2 = CIMA then
                                begin
                                    i := i-1;   clrscr;
                                end
                            else
                            if c2 = PGDN then
                                begin
                                    i := i+20;  clrscr;
                                end
                            else
                            if c2 = PGUP then
                                begin
                                    i := i-20;  clrscr;
                                end;
                        end;
                end
            else
                inc (i);

            if i < 0 then
                begin
                    sintBip;
                    pausado := true;
                    i := -1;
                end
            else
            if i >= sl.count then
                begin
                    sintBip;
                    pausado := true;
                    i := sl.count;
                end;
        end;
end;


end.
