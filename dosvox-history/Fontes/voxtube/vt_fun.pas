{
    VoxTube - utilitário de acessibilização do YouTube  ;

Funções do programa

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_fun;

interface

procedure extraiaudio(ultfolheado: integer);
procedure salvaFilme (ultfolheado: integer);
procedure tocavideo (pagina: string; teclou_ctrl_enter: boolean);
procedure InfoVideoselec (copiaAreaTransf: boolean; ultfolheado: integer);
implementation
uses
dvcrt,
dvform,
    dvexec,
dvdownload,
dvhora,
pipe,
sysutils,
windows,
classes,
vt_aux,
vt_msg,
vt_var,
dvwin;

procedure extraiaudio(ultfolheado: integer);
var
    nomevideo, nomeaudio, link: string;
    c: char;
    prog, params: string;
    audioBitRate, audioChannels, audioResample: string;
    comClek: boolean;
    x, sg, sgant: word;


begin
    nomeaudio := subsCaracInvalidos (Filme.titulo[ultfolheado]) + '.MP3';
    nomevideo := subsCaracInvalidos (Filme.titulo[ultfolheado] + '.MP4');

    mensagem ('VTSALVP', 0);  {'Salvando para: '}
    sintWriteln (nomeaudio);
    writeln;

    mensagem ('VTEDITE', 1);  {'Editore o nome, tecle enter para confirmar, esc para cancelar.'}
    c := sintEditacampo(nomeaudio, wherex, wherey, 200, 80, true);
    if (c = ESC) or (nomeaudio = '') then
        begin
            writeln;
            mensagem ('VTDESIST', 1);  {'Desistiu'}
            exit;
        end;

    writeln (nomeaudio);
    if fileExists(nomeaudio) then
        begin
            mensagem ('VTARQEXI', 0);  {'Este arquivo já existe. Sobrescreve?'}
            c := popupMenuPorLetra ('SN');
            if (c <> 'S') then
                begin
                    mensagem ('VTDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end;

            if sintFalarTudo then mensagem ('VTMOMENT', 1);  {'Um momento'}
    link := linkReal(Filme.paginaweb[ultfolheado]);
    prog := sintambiente('DOSVOX','PGMDOSVOX') + '\ffmpeg.exe';

    audioBitRate := sintAmbiente('VOXTUBE','AUDIOBITRATE');
    if audioBitRate = '' then audioBitRate := '128000';
    audioChannels := sintAmbiente('VOXTUBE','AUDIOCHANELS');
    if audioChannels = '' then audioChannels := '2';
    audioResample :=    sintAmbiente('VOXTUBE','AUDIORESAMPLE');
    if audioResample = '' then audioResample := '44100';

    params :=
        '-i "' + link + '"' +
        ' -ab ' + audioBitRate +
        ' -ac ' + audioChannels +
        ' -ar ' + audioResample +
        ' -y "' + nomeaudio + '"';

    executaProgEx (prog, '', params, sw_hide);

    mensagem ('VTINCVMP', 1);  {'Iniciando conversão para mp3.'}
    while sintFalando do
        waitMessage;
    delay (1000);  // garante que o FFMPEG comece

    comClek := false;
    getTime (x, x, sgant, x);
    while processExists('ffmpeg.exe') do
        begin
            if keypressed then
                begin
                    c := readkey;
                    if c = ENTER then
                        begin
                            mensagem ('VTGERAN', 0);    {'Gerando mp3: '}
                            sintWriteln (nomeaudio);
                            sintWrite(intToStr(myFileSize(nomeAudio) div 1024) + 'k');
                            mensagem ('VTESCRDK', 1);   {' escritos em disco'}
                        end
                    else
                    if c = ' ' then
                        comClek := not comClek
                    else
                    if c = ESC then
                        begin
                            mensagem ('VTPARACV', 0);  {'Deseja parar a conversão?'}
                            c := popupMenuPorLetra ('SN');
                            if upcase(c) = 'S' then
                                begin
                                    executaProgEx ('taskKill','','/f /im ffmpeg.exe', sw_hide);
                                    mensagem ('VTXACANC', 2); {'Extração de audio foi cancelada.'}
                                    exit;
                                end;
                        end;
                end;

            if comClek then
                begin
                    getTime (x, x, sg, x);
                    if sg <> sgant then
                        begin
                            sgant := sg;
                            sintCarac (' ');
                        end;
                end;
        end;

    mensagem ('VTXTAOK', 2);  {'Extração de audio concluída!'}
end;

{                     salva o filme                      }

procedure salvaFilme (ultfolheado: integer);
var
    arquivo: string;
    c: char;
    baixar: string;

begin
    arquivo := subsCaracInvalidos (Filme.titulo[ultfolheado]) + '.MP4';

    mensagem ('VTSALVP', 0);  {'Salvando para: '}
    sintWriteln (arquivo);
    writeln;

    mensagem ('VTEDITE', 1);  {'Editore o nome, tecle enter para confirmar, esc para cancelar.'}
    c := sintEditacampo(arquivo, wherex, wherey, 200, 80, true);
    if (c = ESC) or (arquivo = '') then
        begin
            mensagem ('VTDESIST', 1);  {'Desistiu'}
            exit;
        end;

    writeln (arquivo);
    if fileExists(arquivo) then
         begin
              mensagem ('VTARQEXI', 0);  {'Este arquivo já existe. Sobrescreve?'}
              c := popupMenuPorLetra ('SN');
              if (c <> 'S') then
                 begin
                    mensagem ('VTDESIST', 1);  {'Desistiu'}
                    exit;
                 end;
         end;

    writeln;

    mensagem ('VTBAIXVD', 1); {'Baixando o vídeo, aguarde.'}
    baixar := linkReal(Filme.paginaweb[ultfolheado]);
    if baixar = '' then
        begin
            mensagem ('VTDECERR', 1);  {'Não é possível baixar esse vídeo. Sinto muito.'}
            exit;
        end;

    if  download(baixar, arquivo,8) = DNWL_OK then
        mensagem ('VTOK', 1);  {'Ok!'}
end;


procedure tocavideo (pagina: string; teclou_ctrl_enter: boolean);
var player : string;
    parametro : string;
    urlverdadeira : string;
    c : char;
    p: integer;
begin
player := 'mpv\mpv.exe';
if sintambiente('VOXTUBE','TOCADOR') = '' then
begin
sintgravaambiente('VOXTUBE','TOCADOR','@\'+player);
player := sintambiente('DOSVOX','PGMDOSVOX')+'\'+player;
end
else
player := sintambiente('VOXTUBE','TOCADOR');

    parametro := '';

    if player[1] = '"' then
        begin
            delete (player, 1, 1);
            p := pos ('"', player);
            if p <> 0 then
                begin
                    parametro := trim(copy (player, p+1, 999));
                    delete (player, p, 999);
                end;
        end
    else
        if pos(' ', player) <> 0 then
            begin
                parametro := copy(player, pos(' ', player), length(player));
                player := copy(player, 1, pos(parametro,player));
            end;

    urlverdadeira := linkreal(pagina);

    if (player = '') or (teclou_ctrl_enter) or (urlverdadeira = '') then
        begin
            if (urlverdadeira = '') and (player <> '') and (teclou_ctrl_enter = false) then
                begin
                    mensagem ('VTNTOCA',1);  {'Execução via player não disponível.'}
                    mensagem ('VTNAVEG',0);  {'Deseja executar no navegador'?}
                    c := sintReadkey;
                    writeln (c);
                    c := upcase(c);
                    if (c = 'N') or (c = ESC) then exit;
                end;

            player := GetDefaultBrowser;
            urlverdadeira := pagina;
            if sintFalarTudo then mensagem ('VTABNAV', 1);  {'Abrindo navegador. Acione ALT F4 quando terminar.'}
            executaProg(player, '', urlverdadeira + parametro);
        end
    else
        executaProgEx(player, '', urlverdadeira + parametro , SW_SHOWNORMAL);
esperaprogvoltar;
end;

procedure InfoVideoselec (copiaAreaTransf: boolean; ultfolheado: integer);
var
arq : text;
vtinfo : string;
nomearqtemp, link : string;
s, x : string;
begin
nomearqtemp := gettempfile;
link := Filme.paginaweb[ultfolheado];
    vtinfo := sintambiente('DOSVOX','PGMDOSVOX')+'\vtinfo.exe ';

assign (arq,nomearqtemp);
    executaProgEx (vtinfo,'',link+' '+nomearqtemp,sw_hide);
while processexists('vtinfo.exe') do delay(500);

if not copiaAreaTransf then   {   Exibe no edivox   }
begin
            executaProg(sintambiente('DOSVOX','PGMDOSVOX')+'\edivox.exe', '','/L '+nomearqtemp);
esperaprogvoltar;
end
else   {   Copia para a área de transferência   }
begin
reset(arq);
while not eof(arq) do begin
readln(arq,s);
x := x + s+CRLF;
end;
close(arq);
putclipboard(pchar(x));
sintwriteln('Descrição copiada para a área de transferência');
end;
erase(arq);   {   Deleta independente do modo de leitura   }
end;

end.
