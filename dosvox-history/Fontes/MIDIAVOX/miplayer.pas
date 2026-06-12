unit miplayer;
interface

Uses

  SysUtils,
  windows,
  classes,
  DvCrt,
  DvForm,
  DvWin,
  DvArq,
  mimsg,
  mivars,
  miplaylist,
  mireprod,
  mmsystem;

procedure CDPlayer;

implementation

{--------------------------------------------------------}
{             menu 2 do reprodutor de cd
{--------------------------------------------------------}

procedure controles (var c1, c2: char);
var
    n: integer;

begin
    gotoxy(1,5);
    write('                            ');

    window (1, 6, 32, 11);
    textBackground (red);
    clrscr;

    window (1, 1, 80, 25);
    popupMenuCria(1, 6, 32, 11, red);
    menuAdiciona('MI_CD_VOLTA');  {  '  CIMA - Volta trilha'}
    menuAdiciona('MI_CD_AVANC');  {  '  BAIXO - Avança trilha'}
    menuAdiciona('MI_CD_REPET');  {  '  R - Repetir trilha' }
    menuAdiciona('MI_CD_ESCOL');  {  '  F5 - escolher trilha'  }
    menuAdiciona('MI_CD_SOBRE');  {  '  I - Informações sobre a trilha'}
    menuAdiciona('MI_CD_DESLI');  {  '  D - Desliga o CD-Player' }

    c1 := #0;
    c2 := #0;
    n := popupMenuSeleciona;
    case n of
        1: c2 := CIMA;
        2: c2 := BAIX;
        3: c1 := 'R';
        4: c2 := F5;
        5: c1 := 'I';
        6: c1 := ESC;

        else
           c1 := ESC;
    end;

    textBackground (BLACK);
    clrscr;
    window (1, 1, 80, 25);

end;

{--------------------------------------------------------}
{          ajuda do menu do reprodutor de cd
{--------------------------------------------------------}

procedure ajudaMenuPrincipal(falando: boolean);

    procedure msg (som: string; pula: integer);
    begin
        if falando then
            mensagem (som, pula)
        else
            msgMuda (som, pula);
    end;

begin
    window (1, 5, 32, 11);
    TextBackground(black);
    clrscr;

    msg('MIOPCSMM',1);  {'As opções são:'}
    msg('MI_CD_VOLTA',1);  {' CIMA - Volta trilha' }
    msg('MI_CD_AVANC',1);  {' BAIXO - Avança mídia' }
    msg('MI_CD_REPET',1);  {' R - Repetir trilha' }
    msg('MI_CD_ESCOL',1);  {' F5 - escolher trilha' }
    msg('MI_CD_SOBRE',1);  {' I - Informações sobre a trilha' }
    msg('MI_CD_DESLI',0);  {' D - Desliga o CD-Player' }

    while keypressed do readkey;
    TextBackground(black);
    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}
{             menu do reprodutor de cd
{--------------------------------------------------------}

function menuPrincipal: char;
const
    opcoes: string = 'EFL';
var
    n: integer;

begin
    popupMenuCria(wherex, 11, 24, length(opcoes), red);
    menuAdiciona('MI_CD_ABRIR');  {' E - abre gaveta do CD'       }
    menuAdiciona('MI_CD_FECHA');  {' F - fecha gaveta do CD' }
    menuAdiciona('MI_CD_LIGAR');  {' L - Liga o CD-Player'   }

    n := popupMenuSeleciona;

    if n > 0 then
        result := opcoes[n]
    else
        result := ESC;
end;

{-------------------------------------------------------------}
{               Comandos MCI
{-------------------------------------------------------------}

function comandoMCI(s: string): string;
var
    retorno: array [0..512] of char;
begin
    mciSendString(pchar(s), retorno, 512, 0);
    result := strPas(retorno);
end;

{--------------------------------------------------------}
{           executa trilhas do cd/dvd
{--------------------------------------------------------}

procedure executaTrilhas(iMusica: integer);
var
    qtdtrilhas, trilhaAtual, duracao: string;
    posicao, tempo, nomeMidia, retorno: string;
    tocando, pausado: boolean;
    cmdTecla, cmdMenu: char;

label interpretaComando;
    
    procedure pausa;
    begin
        if tocando then
            begin
                tocando := false;
                pausado := true;
                posicao := comandoMCI('status unidcd position');
                tempo := copy(posicao,4,5);
                comandoMCI('pause unidcd');
                retorno := comandoMCI('status unidcd mode');
                mostraStatus(nomeMidia, 'Pausado' , tempo, true);
            end
        else
            begin
                comandoMCI('play unidcd from '+posicao);
                ajudaMenuPrincipal(False);
                setWindowTitle ('Midiavox - ' + nomeMidia);
                retorno := comandoMCI('status unidcd mode');
                mostraStatus(nomeMidia, pegatextomensagem('MITOCAND') , tempo, false);
                tocando := true;
                pausado := false;
           end;
    end;

begin

    comandoMCI('play unidcd from ' + inttostr(iMusica));
    trilhaAtual := comandoMCI('status unidcd current track');

    qtdtrilhas:= comandoMCI('status unidcd number of tracks');
    tocando := True;

    repeat

        folheiaPreview(strtoint(trilhaAtual));
        nomeMidia := pegatextomensagem('MI_TRACK') + playlist[strtoint(trilhaAtual)];  {  'Trilha '  }
        setWindowTitle ('Midiavox - ' + nomeMidia);

        delay (100);
        retorno := comandoMCI('status unidcd mode');
        posicao := comandoMCI('status unidcd position');
        tempo := copy(posicao,4,5);

        if tocando then
            mostraStatus(nomeMidia, pegatextomensagem('MITOCAND') , tempo, false) { 'Tocando' }
        else
            mostraStatus(nomeMidia, pegatextomensagem('MIPAUSAD') , tempo, true);  {  'Pausado'  }

        if not keypressed then continue;

        cmdTecla := upcase(readKey);
        if cmdTecla = #0 then cmdMenu := readkey;

interpretaComando:

        case upcase(cmdTecla) of
            ' ':
                pausa;

            'R' :
            begin   { repetir faixa }
                trilhaAtual := comandoMCI('status unidcd current track');
                ComandoMCI ('play unidcd from '+ trilhaAtual);
            end;

            'I':
            begin
                gotoxy(1,13);
                retorno := comandoMCI('status unidcd ready');
                if retorno <> 'true' then
                    begin
                        mensagem('MINAOACH',1); { 'O CD-Player não está preparado.' }
                        cmdTecla := ESC;
                    end;
                mensagem('MINUMTLH', 0); {  'Número de trilhas: '  }
                sintWriteln (qtdTrilhas);

                mensagem('MITATUAL', 0); {  'Trilha corrente: '  }
                trilhaAtual := comandoMCI('status unidcd current track');
                sintWriteln(trilhaAtual);

                duracao := comandoMCI('status unidcd length track ' + trilhaAtual);
                mensagem('MIDURACA', 0); {  'Duração: '  }
                sintWriteln(duracao);
                if keypressed then
                begin
                    window(1,13,48,25);
                    clrscr;
                    break;
                    window(1,1,85,25);
                end;
            end;

            #0:                                       
            case upcase(cmdMenu) of

                BAIX:
                begin    { avançar faixa }
                    trilhaAtual := comandoMCI('status unidcd current track');
                    if strtoint(trilhaAtual) >= playlist.count-1 then
                    begin
                        sintbip;
                        trilhaAtual := inttostr(playlist.count-2);
                     end;
                    trilhaAtual := playlist[strtoint(trilhaAtual)+1];
                    ComandoMCI ('play unidcd from '+ trilhaAtual);
                end;

                CIMA:
                begin    { voltar faixa }
                    trilhaAtual := comandoMCI('status unidcd current track');
                    if strtoint(trilhaAtual) <= 1 then
                    begin
                        sintbip;
                        trilhaAtual := '2';
                     end;
                    trilhaAtual := playlist[strtoint(trilhaAtual)-1];
                    ComandoMCI ('play unidcd from '+ trilhaAtual);
                end;

                F1:
                begin
                    if tocando then
                        pausa;
                    ajudaMenuPrincipal(True);
                    if not tocando then
                        pausa;
                end;
                
                F5:
                begin
                    gotoxy(1,13);
                    mensagem('MINTRACK',0); {  'Informe o número da trilha : '  }
                    sintReadln (trilhaAtual);
                    ComandoMCI('play unidcd from '+ trilhaAtual);

                    window(1,13,48,25);
                    clrscr;
                    window(1,1,85,25);
                end;

                F9:
                begin
                    if tocando then
                        pausa;
                    tocando := false;
                    posicao := comandoMCI('status unidcd position');
                    tempo := copy(posicao,4,5);
                    mostraStatus(nomeMidia, pegatextomensagem('MIPAUSAD') , tempo, true);  {  'Pausado'  }

                    controles (cmdTecla, cmdMenu);  // executa o menu
                    if not tocando then
                        pausa;
                    goto interpretaComando;
                end;


            end;
        end;

    until (cmdTecla = ESC) or
          ((retorno = 'stopped') and (not pausado));

    comandoMCI('stop unidcd');
    item := strtoint(trilhaAtual);
    mostraStatus(nomeMidia, pegatextomensagem('MIPARADO') , tempo, true);  {  'Parado'  }
end;

{--------------------------------------------------------}
{           folheia trilhas do cd/dvd
{--------------------------------------------------------}

procedure folheiaTrilhas;
var
    i: integer;
    c1, c2: char;
    numItensSelec: integer;
    primeiroSelec: integer;
    s: string;
    sel: boolean;

label inicio;
begin
inicio:
    limpabaixo(1);
    numItensSelec := 0;
    folheiaCria(50,3,80,25);

    textBackground (BLUE);
    msgMuda('MIDIAVOX', 0); { 'MIDIAVOX - Versão ' }
    write(versao);
    textBackground (BLACK);

    mostraStatus('',pegatextomensagem('MILOADCD') , '', true);  {  'Carregado'  }
    setWindowTitle ('Midiavox - Reprodutor de CD/DVD');

    i := 1;
    while i < playlist.Count do
        begin
            folheiaAdiciona(pegatextomensagem('MI_TRACK')+playlist[i]);  {   'Trilha'  }
            i := i+1;
        end;

    item := 1;
    repeat
        if folheiaNumItens = 0 then
            begin
                gotoxy(50,11);
                mensagem('MIERLOAD',1);// 'Sem arquivos para reprodução.'
                c1 := 'A';
            end
        else
            begin
                ajudaMenuPrincipal(False);
                gotoxy(50,11);
                if item > folheiaNumItens then
                    item := folheiaNumItens;
                TextBackground(BLACK);

                if not folheiaExecuta(item, item, c1, c2, true) then exit;

                numItensSelec := folheiaNumSelec (primeiroSelec);
            end;

        if (c1 = #0) and (c2 = DIR) then
            begin
                repete := false;
                executaTrilhas(item);
            end;

        case upcase(c1) of
             Enter, 'P': // Executar midia
                executaTrilhas(strtoint(playlist[item]));

             'R': // remover
                begin
                    if numItensSelec = 0 then
                        begin
                            folheiaRemoveItem (item);
                            playlist.Delete(item);
                        end
                    else
                        for i := folheiaNumItens downto 1 do
                            begin
                                folheiaObtemItem(i, s, sel);
                                if sel then
                                    folheiaRemoveItem (i);
                                    playlist.Delete(i-1);
                            end;
                end;
            end;

    until upcase(c1) = ESC;

    TextBackground(black);
    folheiaDestroi;
    playlist.Clear;
end;

{--------------------------------------------------------}
{             reprodutor de cd/dvd
{--------------------------------------------------------}

procedure CDPlayer;
var
   qtdTrilhas, unidCD:string;
   c,c2: char;
   retorno: array [0..80] of char;
   portaFechada: boolean;

    procedure carregaTrilhas;
    var i: integer;
        begin
            playlist.Clear;
            playlist.add(midiaAtual);            
            for i := 1 to strtoint(qtdTrilhas) do
                playlist.add(inttostr(i));
        end;

label inicio;

begin
        portaFechada := true;
inicio:
        limpaBaixo(11);
        TextBackground(red);
        mensagem('MIQOPCAO',0);     {   'Selecione a opção com as setas: '   }
        sintLeTecla(c, c2);
        TextBackground(black);

        if (upcase(c) = #0) and ((upcase(c2) = CIMA) or (upcase(c2) = BAIX) or (upcase(c2) = F9)) then
            begin
                c := upcase(menuPrincipal);
            end;

        if c = ESC then
            begin
                mensagem ('MIDESIST', 1);   {  'Desistiu...' }
                exit;
            end;

    case upcase(c) of
        'L', 'T':
        begin
            if portaFechada then
            begin
                unidCD := sintAmbiente ('MIDIAVOX', 'CD');
                if unidCD <> '' then
                    comandoMCI('open ' + unidcd + ':\ type cdaudio alias unidcd')
                else
                    comandoMCI('open cdaudio alias unidcd');
            end
            else
                mensagem('MIPORTAA',1); {  'A porta está aberta'  }

            mciSendString(pchar('status unidcd ready'), retorno, 512, 0);

            if retorno = 'false' then
                begin
                    mensagem('MINAOACH',1); { 'O CD-Player não está preparado.' }
                    goto inicio;
                end;


            comandoMCI('set unidcd time format tmsf');

            qtdtrilhas:= comandoMCI('status unidcd number of tracks');
            carregaTrilhas;

            folheiaTrilhas;
        end;

        'E' :   { abre porta }
        begin
            comandoMCI('stop unidcd');
            comandoMCI('set cdaudio door open');
            portaFechada := False;
            goto inicio;
        end;

        'F' :   { fecha porta }
        begin
            comandoMCI('set cdaudio door closed');
            portaFechada := True;
            goto inicio;            
        end;
    end;
end;
end.
