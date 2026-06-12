{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Módulo de leitura interativa                        }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit neleit;

interface
uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes,
    dvdigitexto,
    nevars,
    neutil,
    nerede,
    nemsg;

//procedure leituraInterativa (sl: TStringList; buscar: string);
procedure leituraRapidaHTML (site: string);

implementation

{--------------------------------------------------------}
{                  leitura interativa                    }
{--------------------------------------------------------}

(*
procedure leituraInterativa (sl: TStringList; buscar: string);
var i: integer;
    pausado: boolean;
    processando: boolean;
    emUTF: boolean;
    c, c2: char;
begin
    pausado := false;
    processando := true;
    emUTF := false;

    i := 0;
    if buscar <> '' then
        for i := 0 to sl.count-1 do
            if pos (buscar, sl[i]) <> 0 then break;

    if i > sl.Count-1 then i := 0;

    while processando do
        begin
            if (i >= 0) and (i < sl.count) then
                if emUTF then
                    sintWriteln (utf8ToAnsi (sl[i]))
                else
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
                    if upcase(c) = 'U' then emUTF := not emUTF
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
                    i := -1;
                end
            else
            if i >= sl.count then
                begin
                    sintBip;
                    i := sl.count;
                end;
        end;
end;
*)

{--------------------------------------------------------}
{               leitura rápida do site                   }
{--------------------------------------------------------}

procedure leituraRapidaHTML (site: string);
var lido: string;
    status: integer;
    sl: TStringList;
    ano, mes, dia, sem: word;
begin
    clrscr;
    textbackground (RED);
    writeln (site);
    textbackground (BLACK);
    writeln;

    lido := HttpDownload (site, status);
    lido := removeTagsHTML(Utf8ToAnsi(lido));
    sl := TStringList.Create;
    sl.text := lido;

    dvcrt.getDate (ano, mes, dia, sem);
//  leituraInterativa (sl, '/' + intToStr(ano));

    popupDigiTexto (sl, false, true, 1, wherey, 80, 25-wherey, true);

    sl.free;
end;

end.
