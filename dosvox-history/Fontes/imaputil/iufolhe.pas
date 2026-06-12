{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de folheamento de mensagens                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iufolhe;

interface

uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes,
    dvinet,
    dvssl,
    dvform,
    dvarq,
    dvHora,
    iurede,
    iuUtil,
    iuenvel,
    iuBusca,
    iuvars,
    iumsg;

procedure folheiaCartas;

implementation
uses iupastas, iuleit;

var
    indEnvel, tamEnvel: array of integer;
    listaDeCartas: TList;

    selecs: packed array [1..60000] of boolean;   // esta é uma cópia do array de selecionados
                                           // necessária pela não reentrância da rotina de folheamento

{--------------------------------------------------------}
{ descobre quantos itens do menu estão selecionados
{--------------------------------------------------------}

function descobreQuantosSelecionados: integer;
var i: integer;
    item: string;
    selec: boolean;
    numSelec: integer;
begin
    numSelec := 0;
    for i := 1 to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, selec);
            selecs[i] := selec;
            if selec then
                numSelec := numSelec + 1;
        end;
    result := numSelec;
end;

{--------------------------------------------------------}
{ obtem os envelopes do intervalo pedido                 }
{--------------------------------------------------------}

function obtemEnvelopes (quantos: integer): boolean;
var i, n: integer;
    s: string;
begin
    result := false;
    setLength (indEnvel, quantos+2); // o último contem a posição do OK final.
    setLength (tamEnvel, quantos+2);

    n := 0;
    tamEnvel[n] := 0;
    if execComando ('fetch ' + intToStr(1)+ ':' + intToStr(quantos) + ' ENVELOPE') then
        begin
            for i := 0 to respServ.Count-2 do
                if copy (respServ[i], 1, 2) = '* ' then
                    begin
                        s := copy (respServ[i], 3, 9999);
                        s := copy (s, 1, pos(' ', s)-1);
                        n := strToInt(s);
                        indEnvel[n] := i;
                        tamEnvel[n] := 1;
                    end
                else
                        inc (tamEnvel[n]);

            result := true;
        end;
    indEnvel[quantos+1] := respServ.Count-1;
end;

{--------------------------------------------------------}
{  extrai um dos envelopes num intervalo recebido        }
{--------------------------------------------------------}

function extraiEnvelope (n: integer): string;
var i, f: integer;
    n1, n2: integer;
    nc, ncprox: integer;
    s: string;

begin
    result := '';
    nc := 0;
    n1 := indEnvel[n];
    n2 := indEnvel[n] + tamEnvel[n] - 1;

    for i := n1 to n2 do
        begin
            s := respserv[i];
            f := length(s);
            ncprox := 0;
            if (f > 1) and (s[f] = '}') then
                 begin
                     while (f > 1) and (s[f] <> '{') do
                         f := f - 1;
                     if f <> 0 then
                         begin
                             ncprox := strToInt (copy (s, f+1, length(s)-f-1));
                             delete (s, f, 999);
                         end;
                 end;

            if nc <> 0 then
                begin
                    insert ('"', s, nc+1);
                    insert ('"', s, 1);
                end;

            result := result + s;
            nc := ncProx;
        end;
end;

{--------------------------------------------------------}
{ prepara a lista de cartas                              }
{--------------------------------------------------------}

function preparaListaDeCartas: boolean;
var i: integer;
    env: string;
    pEnvel: ^TEnvelope;

begin
    respserv.Clear;
    if cartasNaPasta = 0 then
        begin
            if sintFalarTudo then mensagem ('IUPVAZIA', 1)  {'A pasta está vazia'}
            else writeln (pegaTextoMensagem('IUPVAZIA'));  {'A pasta está vazia'}
            result := false;
            exit;
        end;

    if sintFalarTudo then mensagem ('IUMOMENT', 1)  {'Um momento'}
    else writeln (pegaTextoMensagem('IUMOMENT'));  {'Um momento'}
    if not obtemEnvelopes (cartasNaPasta) then
        begin
            mensagem ('IUERRENV', 1);  {'Erro ao trazer os envelopes'}
            result := false;
            exit;
        end;

    listaDeCartas := TList.Create;
    for i := 1 to cartasNaPasta do
        begin
            env := extraiEnvelope (i);
            new (pEnvel);
            with pEnvel^ do
                envelope (env, data, assunto, enviador);
            listaDeCartas.Add(penvel);

            if listaDeCartas.Count >= MAXCARTAS then break;
        end;
    result := true;
end;

{--------------------------------------------------------}
{ libera a lista de cartas                               }
{--------------------------------------------------------}

procedure destroiListaDeCartas;
var i: integer;
    p: ^TEnvelope;
begin
    if listaDeCartas = NIL then
        exit;
    for i := 0 to listaDeCartas.Count-1 do
        begin
            p := listaDeCartas[i];
            dispose(p);
        end;
    listaDeCartas.Free;
    listaDeCartas := NIL;
end;

{--------------------------------------------------------}
{ Escolhe a pasta destino                                }
{--------------------------------------------------------}

function escolhePastaDestino: string;
var
    i, nitem: integer;
begin
    result := '';

    mensagem ('IUESETAP', 1);  {'Escolha com as setas a pasta desejada'}
    popupMenuCria (wherex, wherey, 60, 20, RED);
    for i := 0 to pastasImap.count-1 do
        popupMenuAdiciona('', pastasImap[i]);
    popupMenuOrdena;
    nitem := popupMenuSeleciona;

    if (nitem > 0) and (nitem <= pastasImap.Count) then
        result := pastasImap[nitem-1]
    else
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;
end;

{--------------------------------------------------------}
{ Move um trecho da pasta para outra pasta               }
{--------------------------------------------------------}

function moveTrecho (primeiro, ultimo: integer;
                     pastaDestino: string; apagandoOrigem: boolean): boolean;
var comando: string;
label tentaDeNovo;
begin
    if apagandoOrigem then comando := 'MOVE'    // pode não existir
                      else comando := 'COPY';

tentaDeNovo:
    if primeiro = ultimo then
        result := execComando (comando +
              ' ' + intToStr(primeiro) + ' ' +
              '"' + codifInternat(pastaDestino) +  '"')
    else
        result := execComando (comando +
              ' ' + intToStr(primeiro) + ':' + intToStr(ultimo) + ' ' +
              '"' + codifInternat(pastaDestino) +  '"');

    if comando = 'MOVE' then
        if result then
            exit   // já apagou, não precisa fazer mais nada
        else
            begin
                comando := 'COPY';
                goto tentaDeNovo;
            end;

    if result and apagandoOrigem then
         result := execComando('STORE ' +
                       intToStr(primeiro) + ':' + intToStr(ultimo) +
                                        ' +flags \deleted');
    if result then
        if apagandoOrigem then
            execComando ('EXPUNGE');

    if not result then
        mensagem ('IUERRCOP', 1);   {'Erro durante a cópia'}
end;

{--------------------------------------------------------}
{ Move cartas para outra pasta                           }
{--------------------------------------------------------}

function moverCartas (ncar: integer; apagando: boolean): integer;
var
    i, k: integer;
    pastaDestino: string;
    c, c2: char;
    quantAMover: integer;
    numSelec: integer;
    ultimo: integer;
    salvaNumItens: integer;

begin
    result := ncar;
    numSelec := descobreQuantosSelecionados;
    salvaNumItens := folheiaNumItens;

    if numSelec > 0 then
        begin
            mensagem ('IUCOPSEL', 0);  {'Opção: S - copia as selecionadas, Enter - copia esta  '}
            sintLeTecla (c, c2);
            writeln;
            if c = ESC then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end
    else
        c := ENTER;

    pastaDestino := escolhePastaDestino;
    if pastaDestino = '' then
        exit;

    if pastaAtual = pastaDestino then
        begin
            mensagem ('IUPASIGU', 1);   {'As pastas de origem e destino tem que ser diferentes!'}
            exit;
        end;

    mensagem ('IUCPPARA', 0);   {'Copiando para '}
    sintWriteln (pastaDestino);
    if c = ENTER then
        begin
            if moveTrecho (ncar, ncar, pastaDestino, apagando) then
                begin
                    mensagem ('IUOK', 1);   {'OK'}
                    result := ncar - 1;
                end
            else
                mensagem ('IUPROBLE', 1); {'Operação concluída com problemas'}
        end
    else
        begin
            mensagem ('IUMOMENT', 1);   {'Um momento...'}

            ultimo := -1;
            quantAMover := 0;
            for i := salvaNumItens downto 1 do
                begin
                    if selecs[i] then
                        if quantAMover <> 0 then
                            inc (quantAMover)
                        else
                            begin
                                quantAMover := 1;
                                ultimo := i;
                            end
                    else
                        if quantAMover <> 0 then
                            begin
                                if not moveTrecho (ultimo-quantAmover+1, ultimo, pastaDestino, apagando) then
                                    begin
                                        quantAMover := 0;
                                        break;
                                    end;

                                if apagando then
                                    for k := (ultimo-quantAmover+1) to ultimo do
                                        if k < ncar then dec(ncar)
                                        else break;
                                quantAMover := 0;
                            end;
                    end;

            if quantAMover <> 0 then
                moveTrecho (ultimo-quantAmover+1, ultimo, pastaDestino, apagando);
            if apagando then
                for k := (ultimo-quantAmover+1) to ultimo do
                    if k < ncar then dec(ncar)
                    else break;
            result := ncar - 1;
        end;

    limpaBufTec;
end;

{--------------------------------------------------------}
{ informa as opções disponíveis                          }
{--------------------------------------------------------}

procedure ajuda;
begin
    limpaBaixo (17);
    writeln ('--------------------------------------------------------------------------------');
    gotoxy (1, 18);
    mensagem ('IUOPCAO',  1);   {'As opções são:'}
    mensagem ('IUABRCAR', 1);   {'ENTER - abrir a carta'}
    mensagem ('IUINFO',   1);   {'i - informações sobre a carta'}
    mensagem ('IUOPAPAG', 1);   {'a - apagar carta remota'}
    mensagem ('IUOPCOPI', 1);   {'c - copiar carta para outra pasta'}
    mensagem ('IUOPMOVE', 1);   {'m - mover carta para outra pasta'}
    mensagem ('IUOPGUAR', 1);   {'g - guardar na pasta de recebidas do cartavox'}
    mensagem ('IUOPZERA', 1);   {'z - zerar a pasta'}
    mensagem ('IUOP_ESC', 1);   {'ESC - Cancelar'}
    readkey;
    limpaBufTec;
end;

{--------------------------------------------------------}
{ seleciona interativamente a opção
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = ENTER + 'iacmgz'+ ESC;
begin
    popupMenuCria(40, wherey, 50, 8, RED);
    MenuAdiciona ('IUABRCAR');   {'ENTER - abrir a carta'}
    MenuAdiciona ('IUINFO');     {'i - informações sobre a carta'}
    MenuAdiciona ('IUOPAPAG');   {'a - apagar carta remota'}
    MenuAdiciona ('IUOPCOPI');   {'c - copiar carta para outra pasta'}
    MenuAdiciona ('IUOPMOVE');   {'m - mover carta para outra pasta'}
    MenuAdiciona ('IUOPGUAR');   {'g - guardar na pasta de recebidas do cartavox'}
    MenuAdiciona ('IUOPZERA');   {'z - zerar a pasta'}
    MenuAdiciona ('IUOP_ESC');   {'ESC - Cancelar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := ' '
    else
        result := opmenu[n];
end;

{--------------------------------------------------------}
{ zerar a pasta                                          }
{--------------------------------------------------------}

procedure zerarPasta;
var
    c: char;
begin
    mensagem ('IUSEMVLT', 1);  {'Tem certeza? Isso não tem volta!'}
    c := sintReadkey;
    if upcase(c) <> 'S' then
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;

    mensagem ('IUMOMENT', 1);  {'Um momento'}
    if execComando('STORE 1:' + intToStr(folheiaNumItens) +
                           ' +flags \deleted') and
       execComando ('EXPUNGE') then
        mensagem ('IUOK', 1)   {'OK'}
    else
        mensagem ('IUNAOZER', 1);   {'Pasta não pode ser zerada'}
end;

{--------------------------------------------------------}
{ apagar as cartas selecionadas                         }
{--------------------------------------------------------}

function apagarCartas (ncar: integer): integer;
var c, c2, r, r2: char;
    i: integer;
    item: string;
    selec: boolean;
    numSelec: integer;
begin
    result := nCar;
    numSelec := descobreQuantosSelecionados;
    if numSelec > 0 then
        begin
            mensagem ('IUREMSEL', 0);  {'Opção: S - remove as selecionadas, Enter - Remove esta  '}
            sintLeTecla (c, c2);
            writeln;
            if c = ESC then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end
    else
        c := ENTER;

    mensagem ('IUSEMVLT', 0);   {'Atenção, esta função destrói sem volta.  Tem certeza? '}
    sintLetecla (r, r2);
    if upcase(r) <> 'S' then
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;

    if c = ENTER then
        begin
            if execComando('STORE ' + intToStr(ncar) + ' +flags \deleted') and
                 execComando ('EXPUNGE') then
                begin
                    mensagem ('IUOK', 1);   {'OK'}
                    result := ncar;
                end
            else
                mensagem ('IUNAOAPA', 1);   {'Carta não foi apagada'}
        end
    else
        begin
            for i := 1 to listaDeCartas.Count do
                begin
                    folheiaObtemItem (i, item, selec);
                    if selec then
                        begin
                            execComando('STORE ' + intToStr(i) + ' +flags \deleted');
                            if i <= nCar then dec(ncar);
                        end;
                end;
            if execComando ('EXPUNGE') then
                mensagem ('IUOK', 1)   {'OK'}
            else
                mensagem ('IUPROBLE', 1); {'Operação concluída com problemas'}

            result := nCar;
        end;
end;

{--------------------------------------------------------}
{       Retorna o ano, mes e dia para o nome do arquivo da carta
{--------------------------------------------------------}

function pegaAnoMesDia: string;
var
    diaSemana, dia, mes, ano: word;
    s, s2: string;
begin
    getDate (ano, mes, dia, diaSemana);
    str (ano, s2);
    str (mes, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;
    str (dia, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;

    result := s2;
end;

{--------------------------------------------------------}
{ Retorna hora e minuto para o nome do arquivo da carta  }
{--------------------------------------------------------}

function pegaHoraMinuto: string;
var
    hora, minuto, segundo, cent: word;
    s, s2: string;
begin
    dvcrt.gettime (hora, minuto, segundo, cent);
    str (hora, s);
    if length(s) < 2 then s := '0' + s;
    s2 := 'H' + s;
    str (minuto, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;
    str (segundo, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s + 'E';

    result := s2;
end;

{-------------------------------------------------------------}
{ Cria um novo nome para carta                                }
{-------------------------------------------------------------}

function novoNomeCarta (var nbase: integer; diret, extensao: string): string;
var
    resulta, resulta2: integer;
    s, dirAtual, amdhm: string;
    arq: file;
begin
    resulta2 := 0;
    getDir (0, dirAtual);

    {$I-}  chdir (diret);  {$I+}
    if ioresult <> 0 then
        begin
            result := '';
            exit;
        end;
    chDir (dirAtual);

    if diret [length(diret)] = '\' then
        delete (diret, length(diret), 1);

    amdhm:= prefixoImap;
    if amdhm <> '' then amdhm := amdhm + '_';
    amdhm:= amdhm + pegaAnoMesDia + pegaHoraMinuto;

    if (maiuscansi(extensao) = '.ENV') or (maiuscansi(extensao) = '.CPR') then
        extensao := 'M' + extensao;

    repeat
        str (nbase, s);
        nbase := nbase + 1;
        assign (arq, diret + '\' + amdhm + s + extensao);
        {$I-} reset (arq);  {$I+}
        resulta := ioresult;
        if resulta = 0 then   // carta já existia
            begin
                {$I-} close (arq);  {$I+}
                if ioresult <> 0 then;
                continue;
            end;

        if pos ('M.', extensao) <> 0 then
            assign (arq, diret + '\' + amdhm + s +  copy (extensao, 2, length (extensao)))
        else
            assign (arq, diret + '\' + amdhm + s + 'M' + extensao);

        {$I-} reset (arq);  {$I+}
        resulta2 := ioresult;
        if resulta2 = 0 then
            begin
                {$I-} close (arq);  {$I+}
                if ioresult <> 0 then ;
            end;

    until (resulta <> 0) and (resulta2 <> 0);

    result := diret + '\' +amdhm + s + extensao;
end;

{--------------------------------------------------------}
{ Guarda uma carta
{--------------------------------------------------------}

procedure guardaUmaCarta (ncar: integer);
var
    i: integer;
    arq: textfile;
    nomeArq: string;

begin
    nomeArq := novoNomeCarta (serialDownload, dirRecebeCartavox, '.CAR');
                 // nota: o numero de Download é auto-incrementado

    if not execComando('fetch ' + intToStr(ncar) + ' rfc822') then
        mensagem ('IUNRECUP', 1)   {'Problemas ao recuperar a carta.'}
    else
        begin
            assignfile (arq, nomeArq);
            rewrite(arq);
            for i := 1 to respserv.count-3 do
                writeln(arq,respserv[i]);
            closefile(arq);
        end;
end;

{--------------------------------------------------------}
{ guardar as cartas selecionadas no cartavox             }
{--------------------------------------------------------}

procedure guardarCartaNoCartavox (ncar: integer);
var c, c2: char;
    i: integer;
    item: string;
    selec: boolean;
    numSelec: integer;
begin
    numSelec := descobreQuantosSelecionados;
    if numSelec > 0 then
        begin
            mensagem ('IUGUASEL', 0);  {'Opção: S - guarda as selecionadas, Enter - Guarda esta  '}
            sintLeTecla (c, c2);
            writeln;
            if not (upcase(c) in ['S', ENTER]) then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end
    else
        c := ENTER;

    if c = ENTER then
        guardaumacarta(ncar)
    else
        begin
            mensagem ('IUMOMENT', 0);  {'Um momento...'}
            for i := 1 to listaDeCartas.Count do
                begin
                    folheiaObtemItem (i, item, selec);
                    if selec then
                        guardaUmaCarta (i);
                end;
        end;

    mensagem ('IUOK', 1);  {'OK'}
end;

{--------------------------------------------------------}
{ executa o folheamento                                  }
{--------------------------------------------------------}

procedure folheiaCartas;
var
    s: string;
    nome: string;
    i: integer;
    c, c2: char;
    n, nCar: integer;
    p: PEnvelope;
    apertouEsc, falarItem, apertouShift: boolean;

label processa, reexecuta;

const
    brancos = '                              ';
begin
    nCar := 1;
    obtemPastas;

    falarItem := true;
    apertouEsc := false;
    repeat
        select(pastaAtual, true);  // para saber quantas cartas existem agora
        if not preparaListaDeCartas then
            exit;

        clrScr;
        write (pegaTextoMensagem('IUFOLHEN') + pastaAtual);   {'ImapUtil - Folheando cartas de '}
        limpaBaixo (21);
        writeln ('--------------------------------------------------------------------------------');
        gotoxy (1, 22);

        folheiaCria(1, 3, 80, 20);
        folheiaCorDoMeio (1, 30, CYAN);
        for i := 0 to listaDeCartas.Count-1 do
             begin
                 p := listaDeCartas[i];
                 nome := p^.enviador;
                 if (nome <> '') and (nome[1] = '"') then
                     begin
                         delete (nome, pos('<', nome), 999);
                         nome := trim (nome);
                         delete (nome, 1, 1);
                         delete (nome, length(nome), 1);
                     end;
                 s := copy (nome + brancos, 1, 30) + p^.assunto;
                 folheiaAdiciona(s);
             end;
reexecuta:
        folheiaExecuta(nCar, nCar, c, c2, falarItem);
        apertouShift := GetKeyState(VK_SHIFT) < 0;

processa:
        gotoxy (1, 22);
        if ncar < 1 then ncar := 1
        else if ncar > listaDeCartas.count then ncar := listaDeCartas.count;

        if c = ESC then
            apertouEsc := true
        else
            begin
                n := ncar - 1;
                c := upcase (c);
                case c of
                    'Z': zerarPasta;
                    'I': infoCarta (n, listaDeCartas);
                    'A': nCar := apagarCartas (ncar);
                    'C': ncar := moverCartas (ncar, false);
                    'M': ncar := moverCartas (ncar, true);
                    'G': guardarCartaNoCartavox (ncar);
                    'Q',
                    ^Q: falaQualItemDeQuantos (nCar, folheiaNumItens, c = ^Q);
                    ^S: for i := 1 to folheiaNumItens do folheiaSeleciona ( i,  true);
                    ENTER: processarCarta (ncar);
                    'D',
                    ^D: infoDataCarta (n, listaDeCartas);

                    BS: ;
                    ESC: apertouEsc := true;

                    #0: case c2 of
                            ESQ: falaAssunto (n, false, listaDeCartas);
                            DIR: falaAssunto (n, true, listaDeCartas);
                            CTLESQ: sintetiza(pegarRemetenteCarta (n, listaDeCartas));
                            CTLDIR: sintSoletra(pegarRemetenteCarta (n, listaDeCartas));
                            F1: ajuda;
                            DEL: begin
                                     nCar := apagarCartas (ncar);
                                     c := 'A';
                                 end;

                            F5: ncar :=  buscaPalavra (ncar, apertouShift, listaDeCartas);
                            CTLF5: ncar := buscaDeNovo (ncar, apertouShift, false, listaDeCartas);
                            F8: falaHora;
                            CTLF8: falaDia;

                            F9:  begin
                                     c := selSetasOpcao;
                                     goto processa;   // como se tivesse teclado a letra
                                 end;
                            else
                                sintbip;
                        end;
                else
                    begin
                         mensagem ('IUNAOSEI', 0); {'Não sei fazer isso não'}
                         while not keypressed do waitMessage;
                    end;
                end;
            end;

        if (c in ['I', 'Q', ^Q, 'D',^D, ENTER]) or ((c = #0) and (c2 in [ESQ, DIR, CTLESQ, CTLDIR, F8, CTLF8])) then falarItem := false
        else falarItem := true;

        if not(c in ['Z', 'A', 'M', ESC]) then
            goto reexecuta;

        folheiaDestroi;
        destroiListaDeCartas;
    until apertouEsc;
end;

begin
end.
