{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

program cruzavox;

uses
  dvcrt, dvwin, dvArq, dvForm, sysutils, classes,
  crvars, crmsg, crdesen, crjoga, crcria, crarq,
  crlegend, crinstru, crimport;

procedure inicializa;
var ambiente: string;
begin
    ambiente := sintAmbiente ('CRUZAVOX', 'DIRCRUZAVOX');
    if ambiente = '' then
        ambiente := 'c:\winvox\som\cruzavox';
    sintInic (0, ambiente);

    textBackground (BLUE);
    setWindowTitle ('Cruzavox  v.' + versao);
    mensagem ('CRINIC',0);  {'PALAVRAS CRUZADAS - versão '}
    sintWriteln (versao);
    writeln;
    textBackground (BLACK);

    listaDirJogos := TStringList.Create;
    obtemPastas;
end;

function selInterativa: char;
var n: integer;
    c: char;
begin
    popupMenuCria (wherex, wherey, 12, 4, RED);
    MenuAdiciona ('CRJOGAR');    // 'J - jogar'
    MenuAdiciona ('CRCRIAR');    // 'C - criar'
    MenuAdiciona ('CRIMPORT');   // 'I - importar'
    MenuAdiciona ('CREDITAR');   // 'E - criar'
    limpaBufTec;
    n := popupMenuSeleciona;

    case n of
        1: c := 'J';
        2: c := 'C';
        3: c := 'E';
    else
        c := #$1b;
    end;

    if c <> #$1b then writeln (c);
    writeln;
    selInterativa := c;
end;

procedure processa;
var c: char;
begin
    repeat
        gotoxy (1, 3);
        limpaTela;
        limpabuftec;
        c := pergunta ('CRJOGCRI', 1, BLUE);  {'Opção: Jogar, Criar, Importar ou Editar? '}
        if c = ESC then exit;
        if c = #0 then c := selInterativa;

        if c = 'C' then                       // resposta já vem em maiúscula
            criaJogo
        else
        if c = 'E' then
            alteraJogo
        else
        if c = 'I' then
            importaJogo
        else
        if c = 'T' then    // não documentado propositalmente
            importaTudo
        else
        if c = 'J' then
            if iniciaJogo then
                joga;

    until c = ESC;
    writeln;
end;

procedure criaFundo;
//var
//  crFundo : string;
begin
//   crFundo:= 'C:\Nova pasta\crossword2.bmp';
//   openBMP (crFundo);
//   paintBMP(0, 0);
end;


procedure finaliza;
begin
    gotoxy (1, 25);
    mensagem ('CRFIM', 0);  {'Fim das palavras cruzadas'}
    delay (2000);
    while sintFalando do;
    doneWinCrt;
end;

begin
    criaFundo;
    inicializa;
    processa;
    finaliza;
end.
