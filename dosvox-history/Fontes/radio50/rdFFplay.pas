{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Execuçaõ da stream através de FFPlay                }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdFFPlay;

interface
uses
    windows, dvcrt, dvWin, SysUtils,
    rdGravar,
    rdPipeEx,
    rdAjuda,
    rdmsg;

function tocaRadioExterna (nomeRadio, url: string): integer;

implementation
uses rdBass;

var
    codif, hz, stmono, trans, bitrate: string;

label fim;

{--------------------------------------------------------}
{             extrai informações da stream
{--------------------------------------------------------}

procedure extraiInfo (retorno: string);

     function extraiAteVirg: string;
     var p: integer;
     begin
         p := pos (',', retorno);
         result := trim (copy (retorno, 1, p-1));
         delete (retorno, 1, p);
     end;

begin
     delete (retorno, 1, pos (':', retorno));
     delete (retorno, 1, pos (':', retorno));
     codif := extraiAteVirg;
     hz := extraiAteVirg;
     stmono := extraiAteVirg;
     trans := extraiAteVirg;
     bitrate := trim (copy (retorno, 1, pos ('s', retorno)+1));
end;

{--------------------------------------------------------}
{             exibe informações extraídas
{--------------------------------------------------------}

procedure exibeInfo;
begin
    mensagem ('RDCODIFC', 0);  {'Codificação: '}
    sintWriteln (codif);
    mensagem ('RDAMOSTR', 0);  {'Amostragem:  '}
    sintWriteln (hz);
    mensagem ('RDCANAIS', 0);  {'Canais:      '}
    sintWriteln (stmono);
    mensagem ('RDTRANSP', 0);  {'Transporte:  '}
    sintWriteln (trans);
    mensagem ('RDTAXAB' , 0);  {'Taxa:        '}
    sintWriteln (bitrate);
end;

{--------------------------------------------------------}
{                     interação
{--------------------------------------------------------}

procedure interage (c: char; nomeRadio: string);
begin
    limpaBufTec;
    case upcase(c) of
        'G': gravarRadio (nomeRadio);
        'F': if not finalizarGravacoesRadio then sintBip;
        'V': mudaVolumeBass;
        'I': exibeInfo;
        'E': begin
                 mensagem ('RDENDSEL', 1);  {'Endereço selecionado:'}
                 sintWriteln (nomeRadio);
             end;
    else
        ajudaTocaRadioExterna;
    end;
end;

{--------------------------------------------------------}
{             toca rádio com FFPlay
{--------------------------------------------------------}

function tocaRadioExterna (nomeRadio, url: string): integer;
var
    nomeProgExterno: string;
    s: string;
    c: char;
    p: integer;
begin
    result := 0;
    if nomeRadio <> '' then setwindowtitle(nomeRadio + ' - Radio50');
    writeln;
    textBackGround (RED);
    if sintFalarTudo then mensagem ('RDFFPLAY', 0)   {'Processando com ffplay'}
    else
        begin
            sintbip;
            write (pegaTextoMensagem('RDFFPLAY'));   {'Processando com ffplay'}
        end;
    textBackGround (BLACK);
    writeln;

    nomeProgExterno := sintAmbiente ('RADIO50', 'TOCADOR', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\ffplay.exe -nodisp');

    if not pipedProgExecute (nomeProgExterno + ' ' + url) then
        begin
            mensagem ('RDERPLYR', 2);  {'Não pude executar o tocador externo.'}
            setwindowtitle('Radio50');
            exit;
        end;

    c := ' ';
    repeat
        s := ReadPipeInput(OutputPipeRead);
        if s <> '' then writeln (s);

        keypressed;
        s := ReadPipeInput(ErrorPipeRead);
        if s <> '' then
             begin
                 p := pos ('Stream #', s);
                 if p <> 0 then
                      begin
                          delete (s, 1, p-1);
                          extraiInfo(s);
                      end;
             end;

        if keypressed then
            begin
               c := upcase(readkey);
               if c = ^R then
                   begin
                       result := -1;
                       c := ESC;
                   end;

               if c = ^C then putClipboard (pchar(nomeRadio + '=FFMPEG ' + url))
               else
               if c = 'R' then sintetiza (nomeRadio)
               else
               if c <> ESC then
                    interage (c, url);
            end;

    until c = ESC;

    finalizarGravacoesRadio;

    while keypressed do readkey;
    pipedProgStop;
    setwindowtitle('Radio50');
end;

{--------------------------------------------------------}

begin
end.
