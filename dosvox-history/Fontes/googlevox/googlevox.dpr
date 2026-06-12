{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Versão 1: José Antonio Borges e Fabiano Ferreira    }
{       Em maio/2013                                     }
{                                                        }
{    Versão 2: Antonio Borges e Julio Tadeu Silveira     }
{       Em maio/2016                                     }
{                                                        }
{    Versão 3: Antonio Borges e Julio Tadeu Silveira     }
{       Em maio/2019                                     }
{                                                        }
{    Versão 4: Antonio Borges e Patrick Barboza          }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

program googlevox;
uses
    windows,
    shellapi,
    dvcrt,
    dvwin,
    dvinet,
    dvForm,
    dvssl,
    dvexec,
    SysUtils,
    classes,
    gvhttp,
    gvhtml,
    gvmsg,
    gvbusca,
    gvvars,
    gvfolheia;

{--------------------------------------------------------}
{        limpa debaixo de certa posição da tela          }
{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}
{                       termina                          }
{--------------------------------------------------------}

procedure termina;
begin
    mensagem ('GVTCHAU', 1);  {'Até a próxima, pessoal!'}
    sintFim;
    fechaWinsock;
    halt;
end;

{--------------------------------------------------------}
{                     inicialização                      }
{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
    i: integer;
begin
    setwindowtitle('GoogleVox');

    ambiente := sintAmbiente ('GOOGLEVOX', 'DIRGOOGLEVOX', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Som\Googlevox');
    sintinic (0, ambiente);

    textBackground (BLUE);
    mensagem ('GVINIC', 0);  {'Acesso rápido ao Google - v.' + versao'}
    write(versao);
    sintSoletra (versao);
    if alfaBeta <> '' then sintWrite (' '+alfaBeta);
    textBackground (BLACK);
    writeln;
    writeln;

    if not abreWinsock then
        begin
            mensagem ('GVNLIG', 1);  {'Seu computador não está ligado à Internet'}
            termina;
        end;

    siteGoogle := 'www.google.com';
    urlGoogle := '/';

    for i := 1 to 10 do
        ultimasBuscas[i] := sintAmbiente ('GOOGLEVOX', intToStr(i));

    cookies := TStringList.Create;
    debug := false;
end;

{--------------------------------------------------------}
{           escolhe uma entre as últimas buscas          }
{--------------------------------------------------------}

function escolheBusca: string;
var i: integer;
begin
    garanteEspacoTela (10);
    popupMenuCria(wherex, wherey, 80, 10, MAGENTA);
    for i := 1 to 10 do
        if ultimasBuscas[i] <> '' then
            popupMenuAdiciona('', ultimasBuscas[i]);
    popupMenuSeleciona;
    result := opcoesItemSelecionado;
end;

{--------------------------------------------------------}
{                   processa um pedido                   }
{--------------------------------------------------------}

procedure processa;
var
    busca: string;
    c: char;
    repetir: boolean;
begin
    textBackground (BLUE);
    mensagem ('GVOQUE', 0);  {'Google - o que você deseja buscar? '}
    textBackground (BLACK);
    writeln;

    busca := '';
    c := sintEdita (busca, wherex, wherey, 80, true);
    if c = BAIX then
        busca := escolheBusca;
    if (c = ESC) or (busca = '') then
        exit;

    if busca = 'malabinguaba' then
        debug := not debug;

    pagAtual := 0;
    repetir := true;
    repeat
        clrEol;
        mensagem ('GVMOMENT', 1);   {'Um momento...'}

        resultado := TStringList.Create;
        buscaNoGoogle (busca, pagAtual);

        if resultado.count <> 0 then
            begin
                selecionaDaBusca (busca);
                writeln;
                textBackground(RED);
                mensagem ('GVAMPLIA', 0);   // Amplia pesquisa?
                textBackground(BLACK);
                c := popupMenuPorLetra('SN');
                if c = 'S' then
                    pagAtual := pagAtual + 1
                else
                    repetir := false;
            end
        else
            begin
                mensagem ('GVNAOACH', 1);  {'Não consegui achar o que você procurava.'}
                repetir := false;
            end;
        resultado.Free;
    until not repetir;
end;

{--------------------------------------------------------}
{                   programa principal                   }
{--------------------------------------------------------}

var c: char;
begin
    inicializa;
    if iniciaComunicGoogle then
      repeat
          processa;

          if not debug then
              limpabaixo (2);

          writeln;
          textBackground (RED);
          mensagem ('GVMAISB', 0); {'Mais buscas (s/n)? '}
          textBackground (BLACK);
          c := popupMenuPorLetra('SN');
          writeln;
      until upcase (c) <> 'S';

    termina;
end.
