{--------------------------------------------------------}
{                                                        }
{    Programa de execução de midias                      }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autor: Marcolino Matheus Nascimento                 }
{                                                        }
{    Em setembro/2015                                    }
{                                                        }
{   Modificado por Patrick Barboza                       }
{                                                        }
{   Em Junho/2022                                        }
{                                                        }
{--------------------------------------------------------}

program midiavox;

uses
  SysUtils,
  classes,
  DvCrt,
  DvWin,
  DvForm,
  DvArq,
  DvAmplia,
  mimsg,
  miproc,
  miPlaylist,
  miplayer,
  miparam,
  mireprod,
  mivars;

{--------------------------------------------------------}
{             mostra o logotipo do MIDIAVOX
{--------------------------------------------------------}

procedure mostraLogo;
begin
    clrscr;
    textBackground (BLUE);
    writeln ('  **   **   ******   *****    ******    *****    **   **   *****   **   **  ');
    writeln ('  *** ***     **     **  **     **     **   **   **   **  **   **   ** **   ');
    writeln ('  ** * **     **     **   **    **     **   **   **   **  **   **    ***    ');
    writeln ('  **   **     **     **   **    **     *******   **   **  **   **     *     ');
    writeln ('  **   **     **     **   **    **     **   **    ** **   **   **    ***    ');
    writeln ('  **   **     **     **  **     **     **   **     ***    **   **   ** **   ');
    writeln ('  **   **   ******   *****    ******   **   **      *      *****   **   **  ');

    textBackground (BLACK);
    writeln(pegatextomensagem('MIDIAVOX')+versao); {  'MIDIAVOX - Versão '  }
end;

{--------------------------------------------------------}
{         Identifica as extensões processáveis
{--------------------------------------------------------}

procedure identificaExtensoes;
begin
    extensoes:= TStringList.Create;
    extensoes.Add('.wav');
    extensoes.Add('.mp3');
    extensoes.Add('.aac');
    extensoes.Add('.AU');
    extensoes.Add('.mid');
    extensoes.Add('.rm');
    extensoes.Add('.ogg');
    extensoes.Add('.aiff');
    extensoes.Add('.mp4');
    extensoes.Add('.wmv');
    extensoes.Add('.mpeg');
    extensoes.Add('.rmvb');
    extensoes.Add('.avi');
    extensoes.Add('.3gp');
    extensoes.Add('.mov');
    extensoes.Add('.flv');
end;

{--------------------------------------------------------}
{                   Inicializa o sistema
{--------------------------------------------------------}

procedure Inicializa;
var amb: string;
    salva: integer;
    modo: string;
begin
    mostralogo;

    amb := sintAmbiente ('MIDIAVOX', 'DIRMIDIAVOX');
    if amb = '' then
       amb := 'C:/Winvox/Som/midiavox2';
    sintInic(0, amb);

    salva := amplfator;
    amplFim;
    amplInic(26-salva, salva);

    modo := UpperCase (sintAmbiente ('MIDIAVOX', 'MODOSILENCIOSO'));
    modosilencioso := (modo = '') or (modo[1] <> 'N');

    mireprod.inicializaReprod;

    If paramCount = 0  Then
        begin
            sintSom('MIDIAVOX'); {  'MIDIAVOX - Versão '  }
            sintSoletra(versao);
            writeln;
        end;

    playlist := TStringList.Create;

    identificaExtensoes;
end;

{--------------------------------------------------------}
{                  Finaliza o sistema
{--------------------------------------------------------}

procedure finaliza;
begin
    If not execucaoAutomatica then
    begin
        limpabaixo(9);
        writeln;
        mensagem('MIFIMMIV', 1);  {  'Fim do Midiavox.'  }
    end;
    sintFim;
    doneWincrt;
end;

{--------------------------------------------------------}
{                   ajuda do programa principal
{--------------------------------------------------------}

procedure ajudaPrincipal;

begin
    limpabaixo(10);
    textBackground (BLUE);
    mensagem('MIAJU001',1);     {'As principais opções do MIDIAVOX são:'}
    textBackground (BLACK);
    mensagem('MIMENU_A',1);     {  'A - Abrir um arquivo multimidia'  }
    mensagem('MIMENU_L',1);     {  'L - Abrir uma lista de reprodução'  }
    mensagem('MIMENU_S',1);     {  'S - Selecionar um diretório de mídias'  }
    mensagem('MIMENU_R',1);     {  'R - Acionar o reprodutor de CD ou de DVD'  }
    mensagem('MIMENU_T',1);     {  'T - Playlist da área de transferencia'  }
    mensagem('MIMENU_X',2);     {  'X - eXecutar a playlist atual'  }
    mensagem('MIMENU_C',2);     {  'C - Configurações do midiavox'  }
    mensagem('MIAJU002',1);     {'    A tecla ESC é sempre usada para cancelar'}
    mensagem('MIAJU003',1);     {'    Use as setas para selecionar ou conhecer todas as opções'}
    gotoxy(1,9);
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                   configuração do programa
{--------------------------------------------------------}

procedure configura;
var
    opcao: ShortString;
    opcoes: string;
    salva: integer;
    salvay: integer;
begin
    salvay := wherey;
    limpabaixo (salvay);

    mensagem('MICONFIG',2);    {'Configuração do midiavox:'}
    mensagem('MIEDCONF',2);    {'Editore as configurações, ao final tecle ESC'}

    if modosilencioso then
        begin
            opcao  := 'SIM';
            opcoes := 'SIM|NAO';
        end
        else
        begin
            opcao  := 'NAO';
            opcoes := 'NAO|SIM';
        end;

    salva := tamRotulosForm;
    tamRotulosForm := 20;
    formCria;
    formCampoLista('MIMODOSIL', pegaTextoMensagem('MIMODOSIL'),opcao,5,opcoes);
    formEdita (true);
    tamRotulosForm := salva;

    opcao := UpperCase(opcao);
    modosilencioso := (opcao = '') or (opcao[1] <> 'N');
    if modosilencioso then opcao := 'SIM'
                      else opcao := 'NAO';
    sintGravaAmbiente ('MIDIAVOX', 'MODOSILENCIOSO', opcao);

    writeln;
    mensagem ('MICONFSA',0);    {'Configurações salvas'}
    gotoxy(1,9);
end;

{--------------------------------------------------------}
{                   escolha da opção
{--------------------------------------------------------}

function menuPrincipal: char;
var
    n: integer;

const ops = #$1b + 'ALSRPXC';

begin
    popupMenuCria (wherex, wherey, 42, 7, MAGENTA);

    menuAdiciona('MIMENU_A');   {  'A - Abrir um arquivo multimidia'  }
    menuAdiciona('MIMENU_L');   {  'L - Abrir uma lista de reprodução'  }
    menuAdiciona('MIMENU_S');   {  'S - Selecionar um diretório de mídias'  }
    menuAdiciona('MIMENU_R');   {  'R - Acionar o reprodutor de CD ou de DVD'  }
    menuAdiciona('MIMENU_T');   {  'T - Playlist da área de transferencia'  }
    menuAdiciona('MIMENU_X');   {  'X - eXecutar a playlist atual'  }
    menuAdiciona('MIMENU_C');   {  'C - Configurações do midiavox'  }

    limpaBufTec;
    n := popupMenuSeleciona;

    result := ops[n+1];
end;

{--------------------------------------------------------}
{                     escolha da opção
{--------------------------------------------------------}

procedure processa;
var
    c1,c2: char;
    s: string;
    veioDoMenu: boolean;

    procedure exibe (msg: string);
    begin
         if veioDoMenu then
             begin
                  writeln (pegaTextoMensagem(msg));
                  writeln;
             end
         else
         begin
             gotoxy (wherex-1, wherey);
             mensagem(msg, 2)
         end;
    end;

begin
    window (1, 1, 80, 25); 
    repeat
        mostralogo;
        limpaBaixo(10);
        TextBackground(BLUE);
        mensagem('MIQOPCAO',0);  {  'Selecione a opção com as setas:'  }
        TextBackground(BLACK);
        sintLeTecla(c1,c2);
        if (c1 = #0) and (c2 = F1) then
        begin
                ajudaPrincipal;
                continue;
        end;
//        if c1 = ESC then exit;

        veioDoMenu := false;
        if c1 = #0 then
             begin
                  veioDoMenu := true;
                  c1 := menuPrincipal;
             end;

        case upcase(c1) of

                'A':
                begin
                    exibe('MIMENU_A'); {  'A - Abrir um arquivo multimidia'  }
                    procuraArquivoMultimidia;
                end;

                'L':
                begin
                    exibe('MIMENU_L'); {  'L - Abrir uma lista de reprodução'  }
                    procuraPlayList;
                end;

                'S':
                begin
                    exibe('MIMENU_S'); {  'S - Selecionar um diretório de mídias'  }
                    selecionaDiretorio;
                end;

                'R':
                begin
                    exibe('MIMENU_R'); {  'R - Acionar o reprodutor de CD ou de DVD'  }
                    CDPlayer;
                end;

                'T':
                begin
                    exibe('MIMENU_T'); {  'T - Playlist da área de transferência'  }
                    s := strPas(getClipBoard(64000));
                    playlist.text := playlist.text + s;
                    mensagem('MILOADPL',1);   {   ' Playlist carregada.'  }
                    clrscr;
                    folheiaPlaylist;
                end;

                'X':
                begin
                    clrscr;
                    folheiaPlaylist;
                end;

                'C':
                begin
                    clrscr;
                    configura;
                end;
                ESC,'F':
                begin
                    writeln;    writeln;
                    mensagem('MICONFIR', 0); { 'Confirma o fim do Midiavox? ' }
                    if upcase(sintReadKey) in [ 'N', ESC ] then
                        c1 := ' ';
                end;
        end;

    until c1 = ESC;
end;

{--------------------------------------------------------}
{                      programa principal
{--------------------------------------------------------}
begin
    inicializa;
    
    If paramCount > 0  Then
        begin
            trataParametros;
            clrscr;
            execucaoAutomatica := True;
            folheiaPlaylist;
            if not execucaoAutomatica then processa;
        end
    else
       processa;

    finaliza;
end.
