{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Módulo de interação com os resultados               }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvfolheia;

interface

uses windows, sysutils, shellApi, classes,
     dvcrt, dvWin, dvInet, dvArq, dvForm, dvExec, dvSsl, winsock,
     gvVars, gvhttp, gvMsg, dvdigitexto;

procedure selecionaDaBusca (busca: string);

implementation

var slist: TStringList;

{--------------------------------------------------------}
{           mostra o site no navegador web padrão        }
{--------------------------------------------------------}

procedure mostraNavWindows (pagina: string);
begin
    mensagem ('GVABRNAV', 1);  {'Abrindo navegador. Acione ALT F4 quando terminar.'}
    while sintFalando do waitMessage;
    delay (100);

    executaProg(GetDefaultBrowser, '', pagina);
    delay (5000);
    while getForegroundWindow <> crtWindow do delay (500);
end;

{--------------------------------------------------------}
{         chama o webvox ou outro selecionado            }
{--------------------------------------------------------}

procedure chamaWebvox (site: string);
var nomeProg: string;
begin
    nomeProg := sintAmbiente ('GOOGLEVOX', 'NAVEGADOR', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\webvox.exe');

    if executaProg (nomeProg, '', site) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
        end
    else
        mensagem ('GVERRNAV', 1);  {'Erro ao chamar o navegador'}
end;

{--------------------------------------------------------}
{         Gera stringlist para leitura interativa        }
{--------------------------------------------------------}

procedure geraSlist (s: string);
var p: integer;
    s2: string;
begin
    while s <> '' do
        begin
            p := pos (^m^j, s);
            s2 := copy (s, 1, p-1);
            delete (s, 1, p+1);
            while length(s2) > 80 do
                begin
                    for p := 80 downto 50 do
                        if s2[p] = ' ' then
                            break;
                    slist.add (trim(copy (s2, 1, p)));
                    delete (s2, 1, p);
                end;
            slist.add (trim(s2));
        end;
end;

{--------------------------------------------------------}
{            Leitura Interativa da Descrição             }
{--------------------------------------------------------}

procedure leituraInterativa;
begin
    limpaBaixo (15);
    dvdigitexto.popupDigiTexto(slist, false, true, 1, 15, 80, 12, true);
end;

{--------------------------------------------------------}
{            Interação sobre os sites achados            }
{--------------------------------------------------------}

procedure selecionaDaBusca (busca: string);
var i, l: integer;
    nselec: integer;
    link: string;
    s: string;
    c: char;

begin
    nselec := 1;

    repeat
        clrscr;
        textBackground (BLUE);
        write (PegaTextoMensagem ('GVINIC'));   {'Acesso rápido ao Google - v.' + versao}
        write (versao);
        if alfaBeta <> '' then write (' '+alfaBeta);
        textBackground (BLACK);
        writeln;

        write (busca + ' - ');
        sintWriteln('Página '+intToStr(pagAtual+1));

        textBackground (RED);
        mensagem ('GVSELSIT', 1);  {'Selecione o site desejado e tecle enter'}
        textBackground (BLACK);

        opcoesCria(wherex, wherey, 80);
        i := 0;
        while i < resultado.count do
            begin
                opcoesAdiciona('', resultado[i]);
                inc (i, 3);
            end;
        limpaBufTec;
        nselec := opcoesSelecInic(nselec);
        if nselec = 0 then break;

        link := resultado[nselec*3-1];
        writeln (resultado[nselec*3-3]);
        writeln (link);
        limpaBaixo (3);

        writeln;
        textBackground (RED);
        mensagem ('GVTXTINI', 1);  {'Texto inicial da página:'}
        textBackground (BLACK);

        s := resultado[nselec*3-2] + ^m^j;

        geraSList (s);
        for l := 0 to slist.Count-1 do
            writeln (slist[l]);

        sintetiza (resultado[nselec*3-2]);

        sintBip;

        if copy (link, 1, 1) = '/' then
            link := siteGoogle + link;

        if debug then
            begin
                textColor (yellow);
                sintWriteln (link);
                textColor (white);
                sintWriteln ('Aperte enter');
                readln;
            end;

        garanteEspacoTela (8);
        writeln ('-------------------------------------------------------------------------------');
        mensagem ('GVWAPENT', 1);  {'Aperte W ou Enter para chamar o Webvox,           '}
        mensagem ('GVNCTENT', 1);  {'       N para navegador,'}
        mensagem ('GVLLER', 1);    {'       L para ler interativamente a descrição'}
        mensagem ('GVESCIGN', 1);  {'       ESC para ignorar. '}
        mensagem ('GVOPCAO', 0);   {'Opcao: '}
        textBackground (BLACK);

        c := popupMenuPorLetra ('WNL');
        case c of
           'W', ENTER:      chamaWebvox(link);
           'N', CTLENTER:   mostraNavWindows (link);
           'L':  leituraInterativa;
        else
           mensagem ('GVDESIST', 1);    {'Desistiu...'}
        end;

        slist.Clear;
    until false;   // até sair por abandono do menu
end;

begin
    slist := TStringList.Create;
end.
