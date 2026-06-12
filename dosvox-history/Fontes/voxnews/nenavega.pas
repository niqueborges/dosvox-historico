{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Folheamento de RSS                                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit nenavega;

interface

uses
    windows,
    sysutils,
    classes,
    dvcrt,
    dvwin,
    dvform,
    dvexec,
    nerede,
    nevars,
    nerss,
    neutil,
    neleit,
    nemsg,
    neatom,
    shellapi;

procedure navegaNosSitesRss (nomeCategoria: string);
procedure testaRSS;

implementation

{--------------------------------------------------------}
{                     chama o navegador                  }
{--------------------------------------------------------}

procedure chamaNavegador (site: string);
var nomeProg: string;
begin

    nomeProg := sintAmbiente ('VOXNEWS', 'NAVEGADOR');
    if nomeProg = '' then
        nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\webvox.exe';

    if executaProg (nomeProg, '', site) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
        end
    else
        mensagem ('NEERRCHM', 1);  {'Erro ao chamar o leitor'}
end;

{--------------------------------------------------------}
{                   compila o RSS                        }
{--------------------------------------------------------}

function compilaRss (nomeSite: string; var canal: TRss): integer;
var status: integer;
    rssLido: string;
    ok, ehAtom: boolean;

begin
    rsslido := HttpDownload (nomeSite, status);

    result := status;
    if status <> 200 then
        begin
            mensagem ('NENAOCRG', 1);   {'Não consegui carregar o RSS.'}
            mensagem ('NESTATUS', 0);   {'Status: '}
            sintWriteln (intToStr(status));

            if status = -1 then
                mensagem ('NEINTCAI', 1)    {'Internet parece ter caído.'}
            else
            if status >= 400  then
                mensagem ('NESITEFO', 1);   {'Site parece estar fora do ar.'}

            exit;
        end;

    inicXmlParserFromString (rsslido);
    if not ehArquivoRss (ehAtom) then
        begin
            mensagem ('NERSSINV', 1);  {'Desculpe, mas isso não é um arquivo Rss válido.'}
            result := 210;
            exit;
        end;

    if ehAtom then
        ok := carregaAtomRss (canal)
    else
        ok := carregaRss (canal);

    if not ok then
        begin
            limpaBufTec;
            writeln;
            mensagem ('NEXMLERR', 0);  {'Este RSS não é totalmente compatível com este programa.  Aceito? '}
            if popupMenuPorLetra('SN') = 'N' then
                result := 400;
        end;
end;

{--------------------------------------------------------}
{             mostra detalhes deste RSS                  }
{--------------------------------------------------------}

procedure mostraDetalhesRss (canal: TRss);
begin
    clrScr;
    textBackGround (RED);
    writeln (canal.title);
    textBackGround (BLACK);
    writeln;
    sintWriteln (canal.description);

    limpaBufTec;
    mensagem ('NEUSESET', 0);   {'Use as setas, ao final tecle ESC'}
    formCria;
    with canal do
        begin
            formCampo('', 'Título', title, 255);
            formCampo('', 'Endereço', link, 255);
            if language <> '' then
                formCampo('', 'Língua', language, 255);
            if copyright <> '' then
                formCampo('', 'Copyright', copyright, 255);
            if managingEditor <> '' then
                formCampo('', 'Editor gerente', managingEditor, 255);
            if webMaster <> '' then
                formCampo('', 'Webmaster', webMaster, 255);
            if pubDate <> '' then
                formCampo('', 'Data de publicação', pubDate, 255);
            if lastBuildDate <> '' then
                formCampo('', 'Data de montagem',  lastBuildDate, 255);
            if category <> '' then
                formCampo('', 'Categoria', category, 255);
            if generator <> '' then
                formCampo('', 'Gerador', generator, 255);
            if docs <> '' then
                formCampo('', 'Documentos', docs, 255);
            if cloud <> '' then
                formCampo('', 'Nuvem', cloud, 255);
            if ttl <> 0 then
                formCampoInt ('', 'Validade', ttl);
            if image.title <> '' then
                formCampo('', 'Imagem', image.title, 255);
            if image.url <> '' then
                formCampo('', 'URF Imagem', image.url, 255);
            if rating <> '' then
                formCampo('', 'Idade recomendada', rating, 255);
            if textInput <> '' then
                formCampo('', 'Texto', textInput, 255);
            if skipHours <> '' then
                formCampo('', 'Horas passadas', skipHours, 255);
            if skipDays <> '' then
                formCampo('', 'Dias passados', skipDays, 255);
            formEdita(false);
        end;

    limpaBufTec;
end;

{--------------------------------------------------------}
{             mostra detalhes de um item                 }
{--------------------------------------------------------}

procedure mostraDetalhesItemRss (item: TItem);
var
    xtitle, xlink, xauthor, xcreator, xcategory, xcomments, xenclosure, xguid,
    xpubDate, xmodifiedDate, xsource, xsection: shortString;
begin
    clrScr;
    textBackGround (RED);
    writeln (item.title);
    textBackGround (BLACK);
    writeln;
    sintWriteln (removeTagsHTML(item.description));

    limpaBufTec;
    mensagem ('NEUSESET', 0);   {'Use as setas, ao final tecle ESC'}
    formCria;
    with item do
        begin
            xtitle     := title;
            xlink      := link;
            xauthor    := author;
            xcreator   := creator;
            xcategory  := category;
            xcomments  := comments;
            xenclosure := enclosure;
            xguid      := guid;
            xpubDate   := pubDate;
            xmodifiedDate := modifiedDate;
            xsource    := source;
            xsection   := section;

            formCampo('', 'Título', xtitle, 255);
            formCampo('', 'Endereço', xlink, 255);
            if author    <> '' then    formCampo('', 'Autor', xauthor, 255);
            if creator   <> '' then    formCampo('', 'Criador', xcreator, 255);
            if category  <> '' then    formCampo('', 'Categoria', xcategory, 255);
            if comments  <> '' then    formCampo('', 'Comentário', xcomments, 255);
            if enclosure <> '' then    formCampo('', 'Pertinência', xenclosure, 255);
            if guid      <> '' then    formCampo('', 'Identificação', xguid, 255);
            if pubDate   <> '' then    formCampo('', 'Data de publicação', xpubDate, 255);
            if modifiedDate <> '' then formCampo('', 'Data de modificação', xmodifiedDate, 255);
            if source    <> '' then    formCampo('', 'Fonte', xsource, 255);
            if section   <> '' then    formCampo('', 'Seção', xsection, 255);
            formEdita(false);
        end;

    limpaBufTec;
end;

{--------------------------------------------------------}
{             abre o site com Webvox                     }
{--------------------------------------------------------}

procedure abreSite (site: string);
var
    nomeProg: string;
begin
    writeln (site);
    writeln;
    mensagem ('NECHANAV', 1);  {'Chamando navegador'}

    nomeProg := sintAmbiente ('VOXNEWS', 'NAVEGADOR');
    if nomeProg = '' then
        nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\webvox.exe';

    if executaProg (nomeProg, '', site) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
        end
    else
        mensagem ('NEERRNAV', 1);  {'Erro ao chamar o navegador'}
end;

{--------------------------------------------------------}
{            Descobre qual é o navegador padrão
{--------------------------------------------------------}

function GetDefaultBrowser: string;
var
    tmp : PChar;
    res : PChar;
begin
    tmp := StrAlloc(255);
    res := StrAlloc(255);
    try
        GetTempPath(255,tmp);
        FileCreate(tmp+'htmpl.htm');
        FindExecutable('htmpl.htm',tmp,Res);
        Result := ExtractFilePath(res) + ExtractFileName(res);
        SysUtils.DeleteFile(tmp+'htmpl.htm');
    finally
        StrDispose(tmp);
        StrDispose(res);
    end;
end;

{--------------------------------------------------------}
{       mostra o youtube no navegador web padrão
{--------------------------------------------------------}

procedure mostraWeb (pagina: string);
begin
    mensagem ('NEABNAV', 1);  {'Abrindo navegador. Acione ALT F4 quando terminar.'}
    while sintFalando do waitMessage;
    delay (100);

    executaProg(GetDefaultBrowser, '', pagina);
    delay (5000);
    while getForegroundWindow <> crtWindow do delay (500);
end;

{--------------------------------------------------------}
{  põe informações sobre link na área de transferência   }
{--------------------------------------------------------}

procedure poeAreaTransf (s: string);
begin
    putClipboard (pchar(s));
end;

{--------------------------------------------------------}
{        interação para escolha de sites a exibir        }
{--------------------------------------------------------}

procedure chamaRadio50 (site: string);
var nomeProg: string;
begin
    nomeProg := sintAmbiente ('DOSVOX', 'PGMDOSVOX') + '\radio50.exe';
    executaProg(nomeProg, '', site);
    esperaProgAtivar;
    esperaProgVoltar;
    mensagem ('NEVOLTA', -1);
end;

{--------------------------------------------------------}
{              nomeia um arquivo temporário
{--------------------------------------------------------}

function GetTempFile: String;
var
    tempFileName, tempPath: array[0..255] of Char;

begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, 'vn', 0, tempFileName);
    result := strPas (tempFileName);
end;

{--------------------------------------------------------}
{          escarafuncha o site procurando um mp3         }
{--------------------------------------------------------}

procedure procuraMP3noSite (site: string);
var lido: string;
    status: integer;
    l, i, p: integer;
    sl: TStringList;
    nomeTemp: string;
begin
    clrscr;
    textbackground (RED);
    writeln (site);
    textbackground (BLACK);
    writeln;
    lido := HttpDownload (site, status);

    l := length(lido);
    for i := 1 to l-1 do
        if (lido[i] = ^m) or (lido[i] = ^j) then
            lido[i] := ' ';

    sl := TStringList.Create;
    repeat
        p := pos ('.mp3"', lido);
        i := p;
        if p <> 0 then
            repeat
                i := i - 1;
            until (i = 0) or (lido[i] = '"');

        if i <> 0 then
            sl.add (trim(copy (lido, i+1, p-i+3)));

        delete (lido, 1, p+3);
    until p <= 0;

    if sl.count = 0 then
        begin
            mensagem ('NEACHAD', 0);      {'Número de áudios achados: '}
            sintWriteln (intToStr (sl.Count));
            exit;
        end;

    if sl.count = 1 then
        chamaRadio50(sl[0])
    else
        begin
            mensagem ('NEACHAD', 0);      {'Número de áudios achados: '}
            sintWriteln (intToStr (sl.Count));

            nomeTemp := GetTempFile;
            delete (nomeTemp, length(nomeTemp)-2, 3);
            nomeTemp := nomeTemp + 'm3u';
            writeln (nomeTemp);

            sl.saveToFile (nomeTemp);
            chamaRadio50(nomeTemp);
            deleteFile (nomeTemp);
        end;

    sl.Free;
end;

{--------------------------------------------------------}
{               busca e toca o áudio do site             }
{--------------------------------------------------------}

procedure tocaAudioSite (site: string);
var lido: string;
    status: integer;
    l, col, col2, i, p: integer;
    s: string;
    achou: boolean;
    sl: TStringList;
    nomeTemp: string;
begin
    clrscr;
    textbackground (RED);
    writeln (site);
    textbackground (BLACK);
    writeln;
    lido := HttpDownload (site, status);

    l := length(lido);
    for i := 1 to l-1 do
        if (lido[i] = ^m) or (lido[i] = ^j) then
            lido[i] := ' ';

    achou := false;
    sl := TStringList.Create;
    repeat
        col := pos ('<audio', lido);
        if col > 0 then
             begin
                 delete (lido, 1, col-1);
                 col2 := pos ('</audio>', lido);
                 if col2 > 0 then
                     begin
                         s := copy (lido, 1, col2+7);
                         delete (lido, 1, col2);
                         p := pos('src=', s);
                         if p <= 0 then continue;
                         delete (s, 1, p+3);
                         p := pos('"', s);
                         delete (s, 1, p);
                         p := pos('"', s);
                         delete (s, p, 999);

                         if trim(s) <> '' then
                             begin
                                 sl.Add(s);
                                 achou := true;
                             end;
                     end;
             end;
    until col <= 0;

    if not achou then
        procuraMP3noSite (site)
    else
    if sl.count = 1 then
        chamaRadio50(sl[0])
    else
        begin
            mensagem ('NEACHAD', 0);      {'Número de áudios achados: '}
            sintWriteln (intToStr (sl.Count));

            nomeTemp := GetTempFile;
            delete (nomeTemp, length(nomeTemp)-2, 3);
            nomeTemp := nomeTemp + 'm3u';
            writeln (nomeTemp);

            sl.saveToFile (nomeTemp);
            chamaRadio50(nomeTemp);
            deleteFile (nomeTemp);
        end;

    sl.Free;
end;

{--------------------------------------------------------}
{                         ajuda                          }
{--------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('NEOPCAO', 1);   {'As opções são:'}
    mensagem ('NEOPN01', 1);   {'ENTER - abre a página'}
    mensagem ('NEOPN02', 1);   {'Control ENTER: executa a página com o navegador do Windows'}
    mensagem ('NEOPN08', 1);   {'A  - escutar o áudio desta página'}
    mensagem ('NEOPN03', 1);   {'L  - leitura rápida desta página'}
    mensagem ('NEOPN04', 1);   {'I  - mostra informações sobre esta página'}
    mensagem ('NEOPN05', 1);   {'D  - mostra detalhes deste canal'}
    mensagem ('NEOPN06', 1);   {'C  - põe o endereço desta página na área de transferência'}
    mensagem ('NEOPN07', 1);   {'T  - põe o título desta página na área de transferência'}
    mensagem ('NEOPN20', 1);   {'F9 - seleciona as opções com as setas'}
    mensagem ('NEAJCN99',1);   {'ESC - terminar'}
    writeln;
    mensagem ('NEAPTTEC', 1);  {'Aperte uma tecla para continuar...'}

    readkey;
    limpaBufTec;
end;

{--------------------------------------------------------}
{             seleção interativa de opções               }
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcao: string = ENTER + CTLENTER + 'ALIDCT' + ESC;

begin
    garanteEspacoTela (8);
    popupMenuCria (wherex, wherey, 60, length(tabLetrasOpcao), MAGENTA);
    MenuAdiciona ('NEOPN01');   {'ENTER - abre a página'}
    MenuAdiciona ('NEOPN02');   {'Control ENTER: executa a página com o navegador do Windows'}
    MenuAdiciona ('NEOPN08');   {'A  - exibe o áudio desta página'}
    MenuAdiciona ('NEOPN03');   {'L  - leitura rápida desta página'}
    MenuAdiciona ('NEOPN04');   {'I  - mostra informações sobre esta página'}
    MenuAdiciona ('NEOPN05');   {'D  - mostra detalhes deste canal'}
    MenuAdiciona ('NEOPN06');   {'C  - põe o endereço desta página na área de transferência'}
    MenuAdiciona ('NEOPN07');   {'T  - põe o título desta página na área de transferência'}
    MenuAdiciona ('NEAJCN99');  {'ESC - terminar'}
    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        selSetasOpcao := ' ';
end;

{--------------------------------------------------------}
{              executa uma opção no site                 }
{--------------------------------------------------------}

procedure executaOpcaoSite (c, c2: char; site, titulo, enclosure: string);
label deNovo;
begin
deNovo:
    case upcase(c) of
      ENTER,
        'W': if pos ('soundcloud.com', site) <> 0  then
                 mostraWeb (site)
             else
             if (pos ('.MP3', upperCase(site)) = length(site)-3) or
                (pos ('.MP3?', upperCase(site)) <> 0) then
                 chamaRadio50 (site)
             else
                 abreSite (site);
      CTLENTER,
        'N': mostraWeb (site);
        'L': leituraRapidaHTML (site);
        'A': if (pos ('.MP3', upperCase(enclosure)) = length(enclosure)-3) or
                (pos ('.MP3?', upperCase(enclosure)) <> 0) then
                 chamaRadio50 (enclosure)
             else
             if (pos ('.MP3', upperCase(site)) = length(site)-3) or
                (pos ('.MP3?', upperCase(site)) <> 0) then
                 chamaRadio50 (site)
             else
                 tocaAudioSite (site);

        'T': poeAreaTransf (titulo);
        'C': poeAreaTransf (site);
        ESC: ;
   'D', 'I': sintBip;   // só válido em canal

         #0:  begin
                 case c2 of
                  F1: begin
                          ajuda;
                          c := readkey;
                          goto deNovo;
                      end;
                  F9: begin
                          c := selSetasOpcao;
                          if c <> ' ' then
                              goto deNovo;
                      end;
                 end;
             end;
    else
        mensagem ('NEOPINV', 1);   {'Opção inválida'}
    end;
end;

{--------------------------------------------------------}
{        interação para escolha de sites a exibir        }
{--------------------------------------------------------}

procedure exibeSitesDoRSS (canal: TRSS; nomeCategoria, nomeCanal: string);
var
    i, itemInic: integer;
    c, c2: char;
    primeiraVez: boolean;
label deNovo;
begin
    itemInic := 1;
    primeiraVez := true;
    repeat
        clrscr;
        TextBackground (BLUE);
        writeln ('VoxNews - ' + nomeCategoria + ' - ' + nomeCanal);
        writeln;
        TextBackground (RED);
        if primeiraVez then
            mensagem ('NEFOLSIT', 1)  {'Folheie os sites com as setas, F1 ajuda'}
        else
            writeln (pegaTextoMensagem ('NEFOLSIT'));
        primeiraVez := false;
        TextBackground (BLACK);
deNovo:
        folheiaCria (wherex, wherey, 80, 25);
        for i := 0 to length(canal.items)-1 do
            folheiaAdiciona(canal.items[i].title);
        folheiaExecuta(itemInic, itemInic, c, c2, true);
        folheiaLimpa;
        folheiaDestroi;

        if c = ESC then
            begin
                mensagem ('NEFOLTRM', 1);   {'Folheamento terminado'}
                break;
            end;

        if upcase(c) = 'D' then
            mostraDetalhesRss (canal)
        else
        if upcase(c) = 'I' then
            mostraDetalhesItemRss (canal.items[itemInic-1])
        else
            begin
                if c = #$0 then
                    begin
                        if c2 = F1 then
                            begin
                                ajuda;
                                goto deNovo;
                            end;
                        c := selSetasOpcao;
                      end;
                with canal.items[itemInic-1] do
                    executaOpcaoSite (c, c2, canal.link, title, enclosure);
            end;

        clreol;
        mensagem ('NECNTFOL', 0); {'Continue folheando'}

    until false;
    folheiaDestroi;
end;

{--------------------------------------------------------}
{          escolhe um dos canais para navegar            }
{--------------------------------------------------------}

function escolheCanal (nomeCategoria: string;
                       var nomeCanal, siteCanal: string): boolean;
var
    i, n, p: integer;
    sl: TStringList;
    itens: TStringList;
    s: string;
begin
    clrscr;
    TextBackground (BLUE);
    writeln ('VoxNews - ' + nomeCategoria);
    writeln;
    mensagem ('NEESCCAN', 1);  {'Escolha o canal desejado e aperte enter'}
    TextBackground(BLACK);

    sl := TStringList.Create;
    itens := TStringList.Create;

    sl.LoadFromFile(arqIndice);

    popupMenuCria(1, wherey, 79, 26-wherey, RED);
    for i := 0 to sl.Count-1 do
        begin
            if trim(sl[i]) = '[' + nomeCategoria + ']' then
                begin
                    for n := i+1 to sl.Count-1 do
                        begin
                            s := trim(sl[n]);
                            if s = '' then continue;
                            if s[1] = '[' then break;

                            p := pos ('=', s);
                            if p > 1 then
                                begin
                                    itens.add (trim(copy(s, p+1, 999)));
                                    popupMenuAdiciona ('', trim(copy(s, 1, p-1)))
                                end
                            else
                                begin
                                    itens.add('<invalido>');
                                    popupMenuAdiciona ('', '<inválido>');
                                end;
                        end;
                    break;
               end;
        end;

    n := popupMenuSeleciona;
    if (n <= 0) or (n > itens.Count) then
        begin
            nomeCanal := '';
            siteCanal := '';
            result := false;
        end
    else
        begin
            limpaBaixo (2);
            gotoxy (1, 2);
            textColor (YELLOW);
            writeln (itens[n-1]);
            textColor (WHITE);

            nomeCanal := opcoesItemSelecionado;
            siteCanal := itens[n-1];
            result := true;
        end;

    sl.Free;
    itens.Free;
end;

{--------------------------------------------------------}
{            interação para escolher as páginas          }
{--------------------------------------------------------}

procedure navegaNosSitesRss (nomeCategoria: string);
var nomeCanal, site: string;
    canal: TRss;
    c, c2: char;
label deNovo;
begin
    c2 := ' ';
    while escolheCanal (nomeCategoria, nomeCanal, site) do
        begin
            if compilaRSS (site, canal) = 200 then
                begin
                    exibeSitesDoRSS (canal, nomeCategoria, nomeCanal);
                    liberaRss(canal);
                end
            else
                begin
deNovo:
                    limpabuftec;
                    mensagem ('NEQUEFAZ', 0);   {'Informe o que fazer ou use as setas'}
                    c := readkey;
                    if c = #$0 then
                        begin
                            c2 := readkey;
                            writeln;
                            if c2 = F1 then
                                begin
                                    ajuda;
                                    goto deNovo;
                                end;

                            c := selSetasOpcao;
                          end
                     else
                        writeln (c);

                     executaOpcaoSite (c, c2, site, 'site isolado', '');
                 end;
        end;

    mensagem ('NECATTRM', 1);  {'Categoria terminada'}
end;

{--------------------------------------------------------}
{            testa um RSS pelo endereço na WEB
{--------------------------------------------------------}

procedure testaRSS;
var site: string;
    canal: TRss;
    status: integer;
    c, c2: char;
label deNovo;
begin
    clrscr;
    TextBackground (BLUE);
    writeln ('VoxNews - ' + 'Teste de acesso a Feeds e Podcasts');
    writeln;
    mensagem ('NEINFEED', 1);  {'Informe o endereço do Feed:'}
    TextBackground(BLACK);

    sintReadln (site);
    if trim (site) = '' then
         begin
             mensagem ('NEDESIST', 1);     {'Desistiu'}
             exit;
         end;

    status := compilaRSS (site, canal);
    if status = 200 then
        begin
            exibeSitesDoRSS (canal, 'canal', canal.title);
            liberaRss(canal);
        end
    else
    if status = 210 then
        begin
deNovo:
            limpabuftec;
            mensagem ('NEQUEFAZ', 0);   {'Informe o que fazer ou use as setas'}
            c := readkey;
            c2 := ' ';
            if c = #$0 then
                begin
                     c2 := readkey;
                     writeln;
                     if c2 = F1 then
                         begin
                             ajuda;
                             goto deNovo;
                         end;
                     c2 := selSetasOpcao;
                end
            else
                writeln (c);

            executaOpcaoSite (c, c2, site, '', '');
        end;

end;

end.

