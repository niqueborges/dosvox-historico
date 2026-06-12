{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de jogar                                      }
{                                                         }
{    Autor: João Marcelo de Andrade & João Pedro Souza    }
{                                                         }
{    Em Outubro/2018                                      }
{                                                         }
{    Revisão: Júlio Silveira e Antonio Borges             }
{                                                         }
{    Em Dezembro/2018                                     }
{                                                         }
{---------------------------------------------------------}

program palavrox;

uses
  sysutils,
  windows,
  classes,
  dvcrt,
  dvwin,
  dvWav,
  dvform,
  dvdic,
  pvscores,
  pvvars,
  pvmsg,
  pvjoga;

{--------------------------------------------------------}
{                 Carrega dicionário                     }
{--------------------------------------------------------}

function carregaDicionario: boolean;
var
    cod : integer;
begin
    cod := carregaDic(
                 sintAmbiente('DICIONARIO', 'ARQDIC'),
                 sintAmbiente('DICIONARIO', 'ARQSUFIXOS'),
                 sintAmbiente('DICIONARIO', 'ARQINEXIST'),
                 sintAmbiente('DICIONARIO', 'ARQNOMES'),
                 sintAmbiente('DICIONARIO', 'ARQSUGERE') );

    if cod <> 0 then
        begin
            textbackground(magenta);
            mensagem ('PVDICNAO', 0);       {'Dicionário não achado.'}
            write (' ');
            mensagem ('PVAPTENT', 0);       {'Aperte Enter...'}
            readln;
            result := false;
        end
    else
        result := true;
end;

{--------------------------------------------------------}
{                    Inicializa                          }
{--------------------------------------------------------}

function inicializa: boolean;

begin
    clrscr;
    setWindowTitle('Palavrox');     { Nome do programa }

    GetClientRect(crtWindow, winRect);

    ambiente := sintAmbiente('PALAVROX', 'DIRPALAVROX');
    if ambiente = '' then
        ambiente := 'c:\winvox\som\palavrox';
    sintinic (0, ambiente);

    desenhaBMPInic;

    textBackground (BLUE);
    mensagem ('PVVERSAO', 0);       {'Palavrox - versão '}
    sintWriteln (versao);
    writeln;
    textBackground (BLACK);

    randomize;                      { Inicialização do gerador num. aleatórios }

    with duracaoMaxJogada do
        tempoLimDaJogada :=  EncodeTime (hor, min, seg, ms);

    mensagem ('PVPREPAL', 0);       {'Preparando palavras...'}

    result := carregaDicionario;
    limpaBaixo (whereY);
end;

{--------------------------------------------------------}
{             Mostra instruções do jogo.                 }
{--------------------------------------------------------}

procedure mostraInstrucoes;
var c: char;
begin
    closeBMP;
    ClrScr;
    cabecalho;
    TextColor (YELLOW);
    mensagem ('PVINSTRJ', 2);       {'Palavrox é um jogo cujo objetivo... '}
    TextColor (WHITE);

    mensagem ('PVAPTENT', 0);       {'Aperte Enter...'}
    repeat
        c := readkey;
    until (c = ENTER) or (c = ESC);
end;

{--------------------------------------------------------}
{                       menu principal                   }
{--------------------------------------------------------}

function menuPrincipal: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem(msg));
    end;

const
    tabLetrasOpcao: string = '123IR' + ESC;

var
    n: integer;

begin
    garanteEspacoTela (6);
    popupMenuCria (WhereX, whereY, 25, length(tabLetrasOpcao), MAGENTA);
    menuAdiciona ('PVM_1');   {'1  - Jogar no nível 1'}
    menuAdiciona ('PVM_2');   {'2  - Jogar no nível 2'}
    menuAdiciona ('PVM_3');   {'3  - Jogar no nível 3'}
    menuAdiciona ('PVM_I');   {'I  - Instruções de jogo'}
    menuAdiciona ('PVM_R');   {'R  - Consultar recordes'}
    menuAdiciona ('PVM_ESC'); {'ESC - Sair do jogo'}

    n := popupMenuSeleciona;
    if n > 0 then
        menuPrincipal := tabLetrasOpcao[n]
    else
        menuPrincipal := ESC;
end;

{--------------------------------------------------------}
{                     processamento                      }
{--------------------------------------------------------}

procedure processa;
var
    o:      char;
    salvaY: integer;

begin
    cabecalho;
    inicializaScores;
    salvaY := WhereY;

    nivel := 0;
    repeat
        cabecalho;
        limpaBaixo (salvaY);
        desenhaBMPInic;
        textBackground (BLUE);
        mensagem ('PVQUALOP', 0);           {'Qual sua opção? '}
        textBackground (BLACK);
        o := readkey;
        if o in [' '..#126] then
            sintWriteln (o)
        else
            begin
               writeln;
               limpabuftec;
               insertKeyBuf(#$0);
               insertKeyBuf(ESQ);
               o := menuPrincipal;
            end;

        case UpCase(o) of

            '1': begin
                    nivel := 1;
                    jogarPartida (ambiente + '\nivel1.pal');
                 end;
            '2': begin
                    nivel := 2;
                    jogarPartida (ambiente + '\nivel2.pal');
                 end;
            '3': begin
                    nivel := 3;
                    jogarPartida (ambiente + '\nivel3.pal');
                 end;

            'I': mostraInstrucoes;

            'R': begin
                    closeBMP;
                    ClrScr;
                    cabecalho;
                    mostraScore(nscores);
                 end;
            ESC:
                begin
                    mensagem ('PVQUSAIR', 0);                   {'Deseja sair do jogo (S/N)? '}
                    if popupMenuPorLetra('SN') = 'S' then
                        break;
                end;

        else
            mensagem ('PVOPCINV', 1);   {'Opção inválida'}
            delay (1000);
        end;

    until False;
end;

{--------------------------------------------------------}
{                       termina                          }
{--------------------------------------------------------}

procedure termina;
begin
    cabecalho;
    gravaScores;
    limpaBufTec;
    mensagem ('PVFIM', 1);            {'Fim do Palavrox'}
    sintfim;
end;

{--------------------------------------------------------}
{                  Programa principal                    }
{--------------------------------------------------------}

begin
    if inicializa then
        begin
            processa;
            termina;
        end;
end.

