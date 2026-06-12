unit miplaylist;
interface

uses
  dialogs,
  SysUtils,
  windows,
  DvCrt,
  DvForm,
  DvWin,
  dvArq,
  dvHora,
  DvAmplia,
  mimsg,
  mireprod,
  mivars,
  mmsystem,
  classes,
  math;

procedure folheiaPlaylist;
function abrePlayList(endereco:string): boolean;
function executaPlayList(iMusica: integer): TStatusTerm;

implementation

{--------------------------------------------------------}
{          Testa se o numero esta na lista
{--------------------------------------------------------}

function testaRepetido(n: integer): boolean;
var
    i: integer;

begin
    result := false;
    if repetidos.count = 0 then
        repetidos.add(inttostr(n))
    else
        begin
            for i:=0 to repetidos.count-1 do
                if repetidos[i] = inttostr(n) then
                begin
                    result := true;
                    exit;
                end;
            repetidos.add(inttostr(n));
        end;
end;

{--------------------------------------------------------}
{                  Abre arquivo de M3U
{--------------------------------------------------------}

function abrePlayList(endereco:string): boolean;
var
    linha: string;
    arquivo: text;

begin
    result:=true;
    AssignFile(arquivo,endereco);
    {$I-}
    Reset(arquivo);
    {$I+}
    if ioresult <> 0 then
        begin
            mensagem('MIEABRIR',1); {  'Erro ao abrir a lista de reprodução.'  }
            result:=false;
            halt;

        end;

    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           linha := trim(linha);
           playlist.add(linha);
         end;

    closefile(arquivo);
    nomePlaylist := ExtractFileName(endereco);
end;

{--------------------------------------------------------}
{                    executa a playlist
{--------------------------------------------------------}

function executaPlayList(iMusica: integer): TStatusTerm;

label fim;

begin
    avanca := false;
    volta := false;
    fimPlaylist := false;
    result := TERMINOU;  {  Por default vai terminar normalmente }

    if playlist.Count > 0 then
        begin
            while iMusica <= playlist.Count do
                begin
                    TextBackground(BLACK);
                    folheiaPreview(iMusica);

                    midiaAtual := playlist[iMusica-1];
                    AcionaTocador;

                    if fimPlaylist then  {  Usuário teclou F }
                        begin
                            fimPLaylist := false;
                            if execucaoAutomatica then
                                result := TERMINOU
                            else
                                result := CANCELOU;
                            break;
                        end

                    else
                    if not aleatorio then
                        repetidos.clear;
                        
                    if aleatorio then
                    begin
                        repeat
                            if playlist.Count <= repetidos.count then
                                begin
                                    goto fim;
                                end;
                            iMusica := RandomRange(1,playlist.Count+1);
                        until not testaRepetido(iMusica);
                    end

                    else
                    if repete then
                        continue

                    else
                    if volta then
                        begin
                            repete := false;
                            iMusica := iMusica-1;
                            if iMusica <= 0 then
                                begin
                                    sintbip;
                                    iMusica := 1;
                                end;
                            volta:= false;
                        end

                    else
                    if avanca then
                        begin
                            repete := false;
                            iMusica := iMusica+1;
                            if iMusica > playlist.Count then
                                begin
                                    sintbip;
                                    iMusica := playlist.Count;
                                end;
                            avanca:= false;
                        end

                    else
                    if reinicia then
                    begin
                        reinicia := false;
                        continue;
                    end

                    else
                        if iMusica = playlist.Count then
                            goto fim
                        else
                            iMusica := iMusica+1;
                end;
        end
    else
        begin
            mensagem('MIERLOAD',1); {  'Sem arquivos para reprodução.'  }
            result := VAZIO;
        end;
fim:
    item := iMusica;
    repetidos.clear;    
end;

{--------------------------------------------------------}
{                Modifica a playlist atual
{--------------------------------------------------------}

procedure salvaPlaylist(playlist: TStringList);
var
    c: char;
    nomeLista: string;
begin
    mensagem ('MI_NOMEM3U', 1);   {'Entre com o nome do arquivo .m3u a gravar: '}
    nomeLista := '';
    c := sintEdita (nomeLista, wherex, wherey, 85-wherex, true);
    clrEol;
    if (c = ESC) or (nomeLista = '') then
    begin
        mensagem ('MI_DESIST', 1);   {'Desistiu.'}
        exit;
    end;
    if  ExtractFileExt(nomeLista) = '' then
       nomeLista := nomeLista + '.m3u';
    if FileExists(nomeLista) then
    begin
        mensagem ('MI_SOBRESC', 1);   {'Sobrescreve arquivo já existente? (S/N) '}
        if popupMenuPorLetra('SN') <> 'S' then
            exit;
    end;

    try
        playlist.SaveToFile(nomeLista);
        mensagem ('MI_OK', 1);   {'OK'}
    except
        mensagem ('MI_NAOGRAV', 1);   {'Não consegui gravar'}
    end;
end;

{--------------------------------------------------------}
{               Ajuda do menu da playlist
{--------------------------------------------------------}

procedure ajudaEscolheOpcaoPL(falando: boolean);

    procedure msg (som: string; pula: integer);
    begin
        if falando then
            mensagem (som, pula)
        else
            msgMuda (som, pula);
    end;

const
    TAM_MENU = 8;
begin
    window (1, 5, 48, 5+TAM_MENU-1);
    textBackGround (MAGENTA);
    clrscr;

    window (1, 1, 80, 25);
    gotoxy (1, 5);
    msg('MIOPCSMM'       , 1);  {'As opções são:'}
    msg('MI_PL_EXECUTAR',  1);  {'ENTER - Executar a lista' }
    msg('MI_PL_ALEATORIO',  1); {'Control Enter - Execução Aleatória' }
    msg('MI_PL_ADICIONAR', 1);  {'    A - Adicionar música à lista' }
    msg('MI_PL_REMOVER'  , 1);  {'    R - Remover música'   }
    msg('MI_PL_GRAVAR'   , 1);  {'    G - Gravar lista'    }
    msg('MI_PL_TROCADIR' , 1);  {'    T - Trocar diretório'    }
    msg('MI_PL_PARAR'    , 1);  {'    ESC - Finalizar lista'   }
    TextBackground(BLACK);
end;

{--------------------------------------------------------}
{                   menu de opções
{--------------------------------------------------------}
function escolheOpcaoPL: char;
const
    opcoes: string = ^m + ^j + 'ARGTF';
var
    n: integer;
begin
    window (1, 5, 48, 25);
    clrscr;
    window (1, 1, 80, 25);

    gotoXY (1,5);
    msgMuda('MIOPCSMM'       , 1);  {'As opções são:'}
    textBackground (MAGENTA);
    popupMenuCria(4, 6, 45, length(opcoes), MAGENTA);
    menuAdiciona('MI_PL_EXECUTAR');   {'ENTER - Executar a lista' }
    menuAdiciona('MI_PL_ALEATORIO');  {'Control Enter - Execução Aleatória' }
    menuAdiciona('MI_PL_ADICIONAR');  {'  A - Adicionar música à lista' }
    menuAdiciona('MI_PL_REMOVER');    {'  R - Remover música'   }
    menuAdiciona('MI_PL_GRAVAR');     {'  G - gravar lista'    }
    menuAdiciona('MI_PL_TROCADIR');   {'  T - Trocar diretório'    }
    menuAdiciona('MI_PL_PARAR');      {'ESC - Finalizar lista'   }
    n := popupMenuSeleciona;

    if n > 0 then
        result := opcoes[n]
    else
        result := ESC;
    textBackground (BLACK);
end;


{--------------------------------------------------------}

{                 muda o diretório
{--------------------------------------------------------}

procedure trocaDir;

var

    nomeDir: string;

begin

    begin

        mensagem('MINOMDIR',1);     {'Informe o diretório:'}
        sintReadln (nomeDir);
        {$I-}
        chdir (nomeDir);
        {$I+}
        if ioresult <> 0 then
              mensagem ('MIINVAL', 1)    {'Inválido'}
        else
              mensagem ('MI_OK', 1);      {'OK'}
    end;
end;


{--------------------------------------------------------}

{       folheia a lista de reprodução
{--------------------------------------------------------}

procedure folheiaPlaylist;
var
    i: integer;
    c1, c2: char;
    numItensSelec: integer;
    primeiroSelec: integer;
    s: string;
    sel: boolean;
    nomeMidia, pedacoMidia: String;
    p:integer;
    status: TStatusTerm;

    listMidias: TList;
    psr: ^TMySearchRec;
    marcados: integer;
    nome: string;

label
    inicio, fim;

    procedure procuraMidia(s:string);
    begin
        s := ansiuppercase(s);
        while item <= playlist.count do
            begin
                if pos(s, ansiuppercase(ExtractFileName(playlist[item-1]))) <> 0 then
                    break;
                item := item +1;
            end;
            if item > playlist.count then
            begin
                sintbip;
                item := item+1;
            end;
    end;
begin

inicio:
    window (1, 1, 80, 25);
    textBackground (BLUE);
    msgMuda('MIDIAVOX', 0); { 'MIDIAVOX - Versão ' }
    write(versao);
    textBackground (BLACK);
    mostraStatus(midiaAtual, 'Carregado', '', false);

    repetidos := TStringList.Create;

    folheiaCria(50,3,80,25-amplfator);
    i := 0;
    while i < playlist.Count do
        begin
//Neno: não fala tudo            folheiaAdiciona(copy(ExtractFileName(playlist[i]), 1, 30));
            folheiaAdicionaEspecial (copy(ExtractFileName(playlist[i]), 1, 30), false, ExtractFileName(playlist[i])); //Neno: Fala o nome completo
            i := i+1;
        end;

    If not execucaoAutomatica then
        begin
            gotoxy(50,1);
            clreol;
            mensagem('MITOTMID',0);   {   'Total de mídias: '    }
            sintwriteint(playlist.count);
        end;
    item := 1;

    repeat
        if folheiaNumItens = 0 then
            begin
                gotoxy(50,11);
                mensagem('MIERLOAD',1);  { 'Sem arquivos para reprodução.'  }
                break;
            end;

        ajudaEscolheOpcaoPL(false);
        gotoxy(50,11);
        if item > folheiaNumItens then
            item := folheiaNumItens+1;
        TextBackground(BLACK);

        if execucaoAutomatica then
           begin
               item := 1;
               folheiaPreview(item);
               status := executaPlayList(item);

               case status of
                   VAZIO:
                   begin
                       mensagem('MIERLOAD',1);  {  'Sem arquivos para reprodução.'  }
                       execucaoAutomatica := false;
                       continue;
                   end;

                   CANCELOU:
                   begin
                       mostraStatus(nomeMidia, pegatextomensagem('MIPARADO'), tempo, false);  {  'Parado'  }
                       sintetiza(pegatextoMensagem('MIFIMRPL'));  {  'Execução interrompida'  }
                       execucaoAutomatica := false;
                   end;

                   TERMINOU:
                       goto fim;
                end;
           end
        else
            begin
                folheiaExecuta(item, item, c1, c2, true);
            end;

        numItensSelec := folheiaNumSelec (primeiroSelec);

        limpaBaixo (14);
        if (c1 = #0) and (c2 = DIR) then
            begin
                repete := false;
                executaPlayList(item);
            end;

        if (c1 = #0) and (c2 = F1) then
            ajudaEscolheOpcaoPL(True);

        if (c1 = #0) and (c2 = F2) then
            salvaPlaylist(playlist);

        if (c1 = #0) and (c2 = F5) then
            begin
                window(1,19, 47, 25);
                mensagem('MIDIGPED',1); {  'Digite o pedaço do nome: ');  }
                sintreadln(pedacoMidia);
                procuraMidia(pedacoMidia);
                clrscr;
                window(1,1,80,25);
            end;

        if (c1 = #0) and (c2 = CTLF5) then
            begin
                item := item+1;
                procuraMidia(pedacoMidia);
            end;

        if (c1 = #0) and (c2 = F8) then
            falaHora;

        if (c1 = #0) and (c2 = CTlf8) then
            falaDia;

        if (c1 = #0) and (c2 = F9) then
            begin
                c1 := escolheOpcaoPL;
                if c1 = ESC then c1 := ' ';
            end;

        case upcase(c1) of
            Enter: // Executar midia
            begin
                aleatorio := false;
                executaPlayList(item);
            end;

            CTLENTER:
                begin
                    aleatorio := True;
                    repetidos.add(inttostr(item));                    
                    executaPlayList(item);
                end;

            'G':
            begin
                window(1,19, 47, 25);
                salvaPlaylist(playlist);
                clrscr;
                window(1,1,80,25);
            end;

            'R':
                 begin
                     sintClek;
                     if item >0 then
                         begin
                             if numItensSelec = 0 then
                                 begin
                                     folheiaRemoveItem (item);
                                     playlist.Delete(item-1);
                                 end;
                             if numItensSelec <>0 then
                                 for i := folheiaNumItens downto 1 do
                                     begin
                                         folheiaObtemItem(i, s, sel);
                                         if sel then
                                             folheiaRemoveItem (i);
                                             playlist.Delete(i-1);
                                     end;
                         end;
                     goto inicio;
                 end;

            'T':
                 trocaDir;

            'A':
                begin
                    mensagem('MINARQMM',1);     {'Informe o nome do arquivo multimídia:'}
                    nomeMidia := obtemNomeArqMasc (25-wherey, '*.wav|*.mp4|*.mp3|*.aac|*.AU|*.mid|*.rm|*.ogg|*.aiff|*.wmv|*.mpeg|*.rmvb|*.avi|*.3gp|*.MOV|*.FLV');
                    p := LastDelimiter('.',nomemidia);
                    extMidiaAtual := UpperCase( copy(nomeMidia, p, length(nomeMidia)) );

                    if nomeMidia = '' then
                        begin
                            limpabaixo(14);
                            mensagem ('MIMMNENC', 1);   { 'Nenhum arquivo multimídia foi selecionado.' }
                            dvCrt.Delay(600);
                            limpabaixo(14);
                        end
                    else
                        begin
                            listMidias := obtemListArq;
                            if listMidias = NIL then listMidias := TList.Create;
                            marcados := 0;
                            for i := 0 to listMidias.count-1 do
                                begin
                                    psr := listMidias[i];
                                    if psr^.marcado then
                                        begin
                                             marcados := marcados +1;
                                             nome := psr^.sr.Name;
                                             playlist.add(psr^.sr.Name);
                                        end;
                                end;
                            liberaListArq;
                            if (marcados = 0) then
                                playlist.Add (nomeMidia);

                            limpabaixo(1);
                            textBackground (BLUE);
                            mostraStatus(nomeMidia, pegatextomensagem('MIPARADO'), tempo, true);  {  'Parado'  }
                            textBackground (BLACK);
                            goto inicio;
                        end;
                end;

            'Q', ^Q: //Neno: Fala atual ou selecionados do total
                begin
                    if upcase(c1) = 'Q' then
                        sintetiza (intToStr(item))
                    else
                        sintetiza (intToStr(numItensSelec));
                    if c1 = ^Q then
                        if numItensSelec > 1 then
                            mensagem ('MISELECS', -1) {'selecionados'}
                        else
                            mensagem ('MISELECI', -1); {'selecionado'}
                    mensagem ('MIDE', -1); {'de'}
                    sintetiza (intToStr(folheiaNumItens));
                    if not keypressed then delay(250);
                end;

        end;
    until (upcase(c1) = ESC) or (upcase(c1) = 'F');
fim:
    TextBackground(black);
    folheiaDestroi;
    repetidos.clear;
end;

end.
