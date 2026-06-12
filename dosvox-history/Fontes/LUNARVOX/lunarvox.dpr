{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

program lunarvox;

uses
  dvcrt,
  mmsystem,
  dvwin,
  sysutils,
  luvars,
  lufisica,
  luscores,
  lumsg,
  lueventos;

{-------------------------------------------------------------}
{                        inicialização                        }
{-------------------------------------------------------------}

procedure inicializa;
var
    dir: string;
    imagem: string;
begin
    randomize;

    dir := sintAmbiente ('LUNARVOX', 'DIRLUNARVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\lunarvox';
    sintInic (0, dir);

    textBackground (BLUE);
    mensagem ('LUINIC', 1);   {'Aterrisagem lunar - um desafio para pilotos!'}
    textBackground (BLACK);
    writeln;

    imagem := sintAmbiente ('LUNARVOX', 'IMAGEM');
    if imagem = '' then imagem := dir + '\foguete.bmp';
    if openBMP (imagem) then
         paintBMP (650, 10);

    sintSom ('FOGUETE');
end;

{-------------------------------------------------------------}
{         Dá boas vindas ao usuário e dá instruções           }
{-------------------------------------------------------------}

procedure boasVindas;
begin
    sintTeclaCorta(false);
    mensagem ('LUBENVIN', 2);  {'Benvindo ao jogo de Aterrisagem Lunar!'}

    if confirma ('LUDESINS') = 'S' then  {'Deseja instruções (s/n) ?'}
       mensagem('LUINSTRT', 2);   {'Instruçoes...'}
    sintTeclaCorta(true);
end;

{-------------------------------------------------------------}
{           inicializa com as opcoes do usuario               }
{-------------------------------------------------------------}
procedure inicOpcoes;
var
    i : integer;
    lido : string;
    c: char;
    nomeArq: string;
begin
    repeat
        c := confirma ('LUDIFICU');  {'Digite a sua opção de dificuldade de 1 a 3: '}
        nivel := ord (c) - (ord ('0'));
    until (nivel >= 1) and (nivel <= 3);

    writeln;
    nomeArq := sintAmbiente ('LUNARVOX', 'ARQDIF');
    if nomeArq = '' then nomeArq := sintDirAmbiente + '\lunardif.ini';

    if fileExists(nomeArq) then
       begin
          assignfile(dificuldade, nomearq);
          reset(dificuldade);

          for i := 2 to nivel do    // salta até a diculdade "nível"
              repeat
                  readln(dificuldade, lido);
              until lido = '*';

          readln(dificuldade, alturaInicial);
          readln(dificuldade, combInicial);
          readln(dificuldade, maxCombAplicar);
          readln(dificuldade, velocAterrisagem);

          closefile(dificuldade);
       end {if}
    else
       mensagem('LUERRARQ', 1);  {'Erro no arquivo de configuração!'}

end;

{-------------------------------------------------------------}
{                 mostra um número real.                      }
{-------------------------------------------------------------}

procedure mostraReal (r: real);
begin
    write (intToStr (trunc(r)) + '.' + intToStr (trunc (frac(r) * 10)));
    sintetiza (intToStr (trunc(r)) + ' ponto ' + intToStr (trunc (frac(r) * 10)));
end;

{-------------------------------------------------------------}
{              mostra velocidade e combustível                }
{-------------------------------------------------------------}

procedure mostraVelocECombustivel;
begin

    if (velocFinal > 0) AND (velocFinal < 5) then
    mensagem ('LULENTO', 1); {'ATENÇÃO, você está muito lento, deixe a nave cair.'}

    if (y < 100) AND (velocFinal > 25) then
        mensagem ('LURAPIDO', 1) {'ATENÇÃO, você está muito rápido próximo ao solo.'}
    else
       begin
          if velocFinal > 50 then
              mensagem ('LUDEMAIS', 1); {'ATENÇÃO, você está rápido demais.'}
       end; {else}

    mensagem ('LUTEMPO', 0); {'Tempo '}
    sintwriteint (trunc(t));
    writeln;
    mensagem ('LUALTURA', 0); {'Altura '}
    mostraReal (y);
    writeln;

    if velocFinal < 0 then
       begin
          mensagem ('LUVCSOBE', 1); {'Você está subindo.'}
          mensagem ('LUVELOC', 0); {'Velocidade '}
          mostraReal (-(velocFinal));
          writeln;
       end {if}
    else
       begin
          mensagem ('LUVELOC', 0); {'Velocidade '}
          mostraReal (velocFinal);
          writeln;
       end; {else}

    if comb > 0 then
       begin
          mensagem ('LUCOMBTQ', 0);  {'Combustível '}
          sintwriteint (comb);
          writeln;
       end;
end; {mostraVelocECombustivel}

{-------------------------------------------------------------}
{   Calcula a gravidade na periferia da Lua, dada a altura    }
{-------------------------------------------------------------}

function calcGravidadeLua (altura: real): real;
begin
   calcGravidadeLua := (G * massaLua) / ((altura + raioLua)*(altura + raioLua));
end;

{-------------------------------------------------------------}
{                   inicializa variáveis                      }
{-------------------------------------------------------------}

procedure inicVariaveis;
begin
    inicOpcoes;

    velocFinal := 0;       // velocidade final.
    velocInicial := 0;     // velocidade inicial.
    y := alturaInicial;    // posicao final.
    y0 := alturaInicial;   // posicao inicial.
    yTemp := y0;           // armazena uma altura temporária.
    t := 1;                // tempo decorrido no jogo.
    t0 := 0;               // tempo inicial.
    comb := combInicial;   // combustível.
    combAplicar := 0;      // combustível a usar
    marcacaoBasica := 10;  // marcação para feedback auditivo

    gravidadeLua := calcGravidadeLua (y0);  // gravidade da lua.

    if comIntuicao then intervalo := 0.1
                   else intervalo := 1;
end;

{-------------------------------------------------------------}
{                Pede o combustível a usar                    }
{-------------------------------------------------------------}

procedure pedeCombustivel;
var erro: integer;

label pedeDeNovo;
begin

pedeDeNovo:
    mensagem ('LUQLITRO', 0);  {'Quantos litros? '}
    sintreadln(lido);

    if (lido = 'R') OR (lido = 'r') then
    begin
        writeln;
        mostraVelocECombustivel;
        goto pedeDeNovo;
    end;

    if (lido = '') then
        combAplicar := 0
    else
        begin
            if lido[1] in ['0'..'9'] then
                begin
                    val (trim(lido), combAplicar, erro);
                    if combAplicar > comb then
                       combAplicar := comb;
                end
            else
                erro := 1;
            if erro <> 0 then
                begin
                    textBackground (RED);
                    mensagem ('LUNAOENT', 0);  {'Não entendi, digite de novo.'}
                    textBackground (BLACK);
                    writeln;
                    goto pedeDeNovo;
                end;
        end;

    writeln;

     if (combAplicar > maxCombAplicar) then
        begin
           textBackground (RED);
           mensagem ('LUCOMMAX', 0);  {'Combustível máximo a colocar por rodada igual a '}
           sintwriteint (maxCombAplicar);
           textBackground (BLACK);
           writeln;
           goto pedeDeNovo;
        end; {if}

     if ((comb - combAplicar) < 0) then
        begin
           textBackground (RED);
           mensagem ('LUCOMSUF', 0); {'Não há combustível suficiente!'}
           textBackground (BLACK);
           writeln;
           goto pedeDeNovo;
        end; {if}

end;

{-------------------------------------------------------------}
{                     mostra situação final                   }
{-------------------------------------------------------------}

procedure mostraSituacaoFinal;
begin
    sintTeclaCorta(false);
    if velocFinal > velocAterrisagem then
        begin
          sintsom ('EXPLODE');
          writeln;
          textBackground (RED);
          mensagem ('LUNVEXPL', 0);  {'A nave explodiu!'}
          textBackground (BLACK);
          writeln;
        end {if}
    else
        begin
        if velocFinal >= 0 then
           begin
              sintsom ('ATERRIZAGEM');
              writeln;
              textBackground (BLUE);
              mensagem ('LUNVPOUS', 0);  {'Muito bem, a nave pousou!'}
              textBackground (BLACK);
              writeln;
           end; {if}
        end; {else}
    writeln;

    if (velocFinal < 0) AND (velocFinal > -100) AND not(y >= 3000) then
        begin
          sintsom ('EXPLODE');
          textBackground (RED);
          mensagem ('LUENTERR', 0); {'Você usou muito combustível próximo
                                     ao chão, criando uma cratera e
                                     enterrando a nave no solo. Você perdeu.'}
          textBackground (BLACK);
          writeln;
        end;

    if velocFinal >= 0 then
       begin
          mensagem ('LUVELFIM', 0);  {'Velocidade final igual a '}
          mostraReal (velocFinal);
          writeln;
       end;

    mensagem ('LUCOMGAS', 0);  {'Combustivel gasto igual a '}
    sintwriteint (combInicial - comb);
    writeln;

    mensagem ('LUPTSFIM', 0);  {'Sua pontuação foi '}
    sintwriteint (scoreTemp);
    writeln;

    sintTeclaCorta(true);
end;

{-------------------------------------------------------------}
{                toca um som assíncrono                       }
{-------------------------------------------------------------}

procedure somAssincrono (s: string);
var dir: string;
    arq: array [0..255] of char;
begin
    dir := sintAmbiente ('LUNARVOX', 'DIRLUNARVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\lunarvox';
    strPCopy (arq, dir + '\' + s);

    sndPlaySound (arq, SND_ASYNC);
end;

{-------------------------------------------------------------}
{                  Informações iniciais                       }
{-------------------------------------------------------------}

procedure informacoesIniciais;
begin
    sintTeclaCorta(false);

    sintSom ('FOGUETE');

    mensagem ('LUOLA', 2); {'Olá, você está a bordo do COLUMBIAVOX 1 e terá de conduzir'}
                           {'a nave em segurança até o pouso na Lua. BOA SORTE!'}

    mensagem ('LUALTINI', 0);  {'A altura inicial é de '}
    sintwriteln (intToStr (alturaInicial) + ' metros');
    mensagem ('LUVELINI', 0);  {'A velocidade é de '}
    sintWriteln ('0 metros por segundo ');
    mensagem ('LUCOMINI', 0);  {'Você tem de combustível '}
    sintwriteln (intToStr (combInicial) + ' litros');
    writeln;

    mensagem ('LUAPENTR', 1);  {'Pressione enter para começar a alunisagem.'}
    readln;

    sintTeclaCorta(true);
end;

{-------------------------------------------------------------}
{               Mostra alturas determinadas                   }
{-------------------------------------------------------------}
procedure alturasDeterminadas;
begin

    clreol;

    if ((yTemp > 1000) AND (y < 1000)) OR ((yTemp < 1000) AND (y > 1000)) then
        sintwriteln ('Mil metros.');

    if ((yTemp > 500) AND (y < 500)) OR ((yTemp < 500) AND (y > 500)) then
        sintwriteln ('Quinhentos metros.');

    if ((yTemp > 250) AND (y < 250)) OR ((yTemp < 250) AND (y > 250)) then
        sintwriteln ('Duzentos e cinquenta metros.');

    if ((yTemp > 100) AND (y < 100)) OR ((yTemp < 100) AND (y > 100)) then
        sintwriteln ('Cem metros.');

    if ((yTemp > 50) AND (y < 50)) OR ((yTemp < 50) AND (y > 50)) then
        sintwriteln ('Cinquenta metros.');

end; {alturasDeterminadas}
{-------------------------------------------------------------}
{                  Mensagens de alerta.                       }
{-------------------------------------------------------------}
procedure mensagAlerta;
begin

    clreol;

    if (contador mod 100 = 0) AND (trunc(y) > 800) AND ((velocFinal > 0) AND (velocFinal < 5)) then
        begin
            textBackground (RED);
            mensagem ('LULENTO', 1); {'ATENÇÃO, você está muito lento, deixe a nave cair.'}
            textBackground (BLACK);
        end;
    if (combTemp <> 0) AND (comb = 0) then
        begin
            textBackground (RED);
            somAssincrono ('ALARM2');
            mensagem('LUFIMCOM', 1); {'Fim do combustível.'}
            textBackground (BLACK);
        end;

    if (contador mod 200 = 0) AND (comb = 0) then
        begin
            textBackground (RED);
            somAssincrono ('ALARM2');
            mensagem ('LUSEMCOM', 1);  {'Nave sem combustível!'}
            textBackground (BLACK);
            combAplicar := 0;
        end; {if}

    if (trunc(y) < 150) AND (contador mod 30 = 0) AND (velocFinal > 30) then
        begin
            textBackground (RED);
            mensagem ('LURAPIDO', 1); {'ATENÇÃO, você está muito rápido próximo ao solo.'}
            textBackground (BLACK);
        end;
    if (vTemp < 65) AND (velocFinal > 65) then
        begin
            textBackground (RED);
            mensagem ('LUDEMAIS', 1); {'ATENÇÃO, você está rápido demais.'}
            textBackground (BLACK);
        end;
end; {mensagAlerta}

{-------------------------------------------------------------}
{                 Sons de Combustível                         }
{-------------------------------------------------------------}
procedure somComb;
begin

    if (combAplicar > 0)  AND (combAplicar <= 10) then
        somAssincrono ('APLICCOMB')
    else
    if (combAplicar > 10) AND (combAplicar <= 20) then
        somAssincrono ('APLICCOMB2')
    else
    if (combAplicar > 20) AND (combAplicar <= maxCombAplicar) then
        somAssincrono ('APLICCOMB3');

end; {somComb}

{-------------------------------------------------------------}
{     Diz se fora de órbita ou se atingiu velocidade máxima   }
{-------------------------------------------------------------}
procedure foraOrbitaVelocMax;
begin
    if (y >= 3000) then
        begin
            sintsom ('EXPLODE');
            mensagem ('LUFORORB', 1); {'A nave saiu da órbita lunar. Você perdeu!'}
            foraOrb := true;
        end;
    if (velocFinal <= -120) OR (velocFinal >= 120) then
        begin
            sintsom ('EXPLODE');
            mensagem ('LUNSUPOR', 1); {'A nave não suportou a velocidade. Você perdeu!'}
            foraOrb := true;
        end;
end; {foraOrbitaVelocMax}

{-------------------------------------------------------------}
{           Mostra a altura por tempo determinado             }
{-------------------------------------------------------------}
procedure mostraAlturaPorTempo;
begin
    clreol;
    if trunc(y) > 40 then
       begin
          if (contador mod 120 = 0) then
             begin
                mostraReal (y);
             end; {if}
       end {if}
    else
       begin
          if contador mod 40 = 0 then
             begin
              mostraReal (y);
             end; {if}
       end; {else}
end; {mostraAlturaPorTempo}

{-------------------------------------------------------------}
{               Lê o combustível do teclado                   }
{-------------------------------------------------------------}
procedure leCombustivel;
begin
     repeat
         c := readkey;
     until not keypressed;

     if c = ' ' then
         mostraVelocECombustivel
     else
     if c = Enter then
         sintWriteln (intToStr(trunc(y)))
     else
     if (c in ['1'..'9']) then
         combAplicar := ord(c) - ord ('0');

     if combAplicar > comb then
         combAplicar := comb;
end; {leCombustivel}

{-------------------------------------------------------------}
{              corpo do jogo pela física                      }
{-------------------------------------------------------------}

(*
procedure jogoComFisica;

begin
    inicVariaveis;
    informacoesIniciais;
    intervalo := 1;

    while true do
       begin
          if (y < 0) then break;

          somAssincrono ('UUUM');
          mostraVelocECombustivel;

          gravidadeLua := calcGravidadeLua (y);

          if (comb = 0) then
              begin
                  textBackground (RED);
                  somAssincrono ('ALARM2');
                  mensagem ('LUSEMCOM', 0);  {'Nave sem combustível!'}
                  textBackground (BLACK);
                  combAplicar := 0;
                  writeln;
                  readln;
              end; {if}

          if comb > 0 then
              pedeCombustivel;

          t  := t + 1;
          velocInicial := velocFinal;
          y0 := y;

          if combAplicar > 0 then
              checaEntupimento;

          if (combAplicar > 0)  AND (combAplicar <= 10) then sintsom ('APLICCOMB');
          if (combAplicar > 10) AND (combAplicar <= 20) then sintsom ('APLICCOMB2');
          if (combAplicar > 20) AND (combAplicar <= maxCombAplicar) then
              sintsom ('APLICCOMB3');

          atualizaPosicao;
       end; {for}

    produzScores;

    mostraSituacaoFinal;

end;
*)

{-------------------------------------------------------------}
{                corpo do jogo pela intuição                  }
{-------------------------------------------------------------}

procedure jogoComIntuicao;
var
    ymarca: real;

    {-------------------------------------------------------------}

    procedure bipaNasMarcas;
    begin
        clreol;

        if y > ymarca then
             begin
                 somAssincrono ('pong.wav');
                 ymarca := ymarca + marcacaoBasica;
             end
        else
        if (ymarca - y) >= marcacaoBasica then
            begin
                 somAssincrono ('ping2.wav');
                 ymarca := ymarca - marcacaoBasica;
            end;

    clreol;
    write ('tempo= ', t:3:1,' ','altura= ', y:3:1, ' ','velocidade= ', +
           velocFinal:3:1,' ','combustível atual= ', comb, #$0d);
    end;

    {-------------------------------------------------------------}


begin
    inicVariaveis;
    informacoesIniciais;
    intervalo := 0.1;
    sintTeclaCorta (false);
    contador := 0;

    ymarca := y;
    while true do
       begin
          if (y < 0) then break;

          gravidadeLua := calcGravidadeLua (y);

          contador := contador + 1;

          alturasDeterminadas;
          mostraAlturaPorTempo;

          combAplicar := 0;

          if comb > 0 then
              if keypressed then leCombustivel;

          if (combAplicar > 0) AND (nivel <> 1) then
              checaEntupimento;

          somComb;
          mensagAlerta;

          t := t + intervalo;
          combTemp := comb;
          vTemp := velocFinal;
          yTemp := y;

          atualizaPosicao;

          foraOrbitaVelocMax;
          if foraOrb = true then break;

          y0 := y;
          velocInicial := velocFinal;

          if (comb > 0) AND (nivel <> 1) then
              checaVazamento;

          bipaNasMarcas;
          delay (trunc(1000 * intervalo));
       end; {while}

    limpaBufTec;

    produzScores;

    sintTeclaCorta (true);
    mostraSituacaoFinal;
end;

{-------------------------------------------------------------}
{                        fecha o programa                     }
{-------------------------------------------------------------}

procedure finaliza;
begin
    closeBMP;
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                        programa principal                   }
{-------------------------------------------------------------}

var c: char;
begin
    inicializa;
    sintSom ('LUCHIME');

    boasVindas;

    inicializaScores;

    sintSom ('LUCHIME');
    c := confirma ('LUCONHEC');  {'Quer conhecer os ases pilotos? '}
    if c = 'S' then
        mostraScore(nscores);

    sintSom ('LUCHIME');
    c := confirma ('LUCOMJOG'); {'Começar jogo? '}

{c := 'S';}
    while c <> 'N' do
        begin

            clrscr;
            textBackground (BLUE);
            write (pegaTextoMensagem ('LUINIC'));
                                {'Alunisagem - um desafio para pilotos!'}
            textBackground (BLACK);
            writeln;
            writeln;

            jogoComIntuicao;

            atualizaScores (scoreTemp);
            mostraScore (nscores);
            gravaScores;

            c := confirma ('LUJOGDEN');  {'Quer jogar de novo? '}
            if c = 'N' then
                begin
                     sintSom ('UUUM2');
                     mensagem ('LUGOSTEI', 1); {'Gostei de jogar com voce!'}
                end;
        end;

    mensagem ('LUTCHAU', 1); {'Tchau!'}

    finaliza;
end.
