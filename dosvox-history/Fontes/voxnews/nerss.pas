{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Compilação do RSS                                   }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit nerss;

interface

uses
    dvwin,
    dvcrt,
    sysUtils,
    libXmlParser,
    neUtil,
    nemsg;

type
    TSite = shortString;
    TEmail = string[80];
    TGmtDate = string[80];
    TItem = record
        title : string;
        link : TSite;
        description : string;
        author : TEmail;
        creator: string;
        category : string;
        comments : TSite;
        enclosure : string;
        guid : string;
        pubDate : TGmtDate;
        modifiedDate : TGmtDate;
        source : string;
        section : string;
        post_id: string;
    end;

    TRssImage = record
        title: shortString;
        link: TSite;
        description: string;
        width, height: integer;
        url: TSite;
    end;

    TRss = record
        title : shortString;
        link : TSite;
        description : string;
        atom_link : shortString;
        language : shortString;
        copyright : shortString;
        managingEditor : TEmail;
        webMaster : TEmail;
        pubDate : TGmtDate;
        lastBuildDate : TGmtDate;
        category : shortString;
        generator : shortString;
        docs : TSite;
        cloud : shortString;
        ttl : integer;
        image : TRssImage;
        rating : shortString;
        textInput : shortString;
        skipHours : shortString;
        skipDays : shortString;
        site: shortString;
        items : array of TItem;
    end;

procedure inicXmlParser (nomearq: string);
procedure inicXmlParserFromString (buffer: string);
function ehArquivoRss (var ehAtom: boolean): boolean;
function carregaRss (var canal: TRss): boolean;
procedure liberaRss (var canal: TRss);
procedure erro (s: string);

var
    parser : TXmlParser;
    houveErro: boolean;

implementation

procedure inicXmlParser (nomearq: string);
Begin
    parser := TXmlParser.Create;
    parser.Normalize := TRUE;
    parser.LoadFromFile (nomearq);
    parser.StartScan;
end;

procedure inicXmlParserFromString (buffer: string);
Begin
    parser := TXmlParser.Create;
    parser.Normalize := TRUE;
    parser.LoadFromBuffer (pchar(buffer));
    parser.StartScan;
end;

procedure erro (s: string);
begin
    sintWriteln (s);
    houveErro := true;
end;

function ehArquivoRss (var ehAtom: boolean): boolean;
begin
    result := false;
    ehAtom := false;

    parser.scan;
    while (parser.CurPartType = ptXMLProlog) or (parser.CurPartType = ptPI) or
          (parser.CurPartType = ptComment) do
        parser.scan;

    if (parser.CurPartType = ptStartTag) then
        if (parser.CurName = 'feed') then
            ehAtom := true
        else
            begin
                if (parser.CurName <> 'rss') then exit;
                parser.scan;
                if (parser.CurPartType <> ptStartTag) or
                   (parser.CurName <> 'channel') then exit;
            end
    else
        exit;

    result := true;
end;

procedure ignoraTag_extensao (tag: string);
begin
    repeat
        parser.Scan;
    until (parser.CurPartType = ptEndTag) and (parser.CurName = tag);
end;

function getCData (itemName: string): string;
var s: string;
begin
    s := '';
    while (parser.CurPartType <> ptEndTag) or
          (uppercase (parser.CurName) <> upperCase(itemName)) do
        begin
            if (parser.CurPartType = ptContent) or (parser.CurPartType = ptCData) then
                begin
                    if s <> '' then s := s + ' ';
                    s := s + parser.CurContent;
                end;
            parser.scan;
        end;

    s := removeTagsHTML(s);
    result := s;
end;

function processaDescription: string;
var s: string;
begin
    s := '';
    while (parser.CurPartType <> ptEndTag) or (uppercase (parser.CurName) <> 'DESCRIPTION') do
        begin
            if (parser.CurPartType = ptContent) or (parser.CurPartType = ptCData) then
                begin
                    if s <> '' then s := s + ' ';
                    s := s + parser.CurContent;
                end;
            parser.scan;
        end;

    s := removeTagsHTML(s);
    result := s;
end;

function limpaTexto (s: string): string;
var p: integer;
begin
     repeat
         p := pos (#$0a, s);
         if p <> 0 then delete (s, p, 1);
     until p = 0;
     result := trim (s);
end;

procedure processaItem (var canal: TRss);
var
    processando : boolean;
    i: integer;
    tag: string;
    lido: string;
    jaLido: boolean;
    item: TItem;
begin
    with item do
        begin
            title := '';
            link  := '';
            description  := '';
            author  := '';
            creator := '';
            category  := '';
            comments  := '';
            enclosure  := '';
            guid  := '';
            pubDate := '';
            modifiedDate := '';
            source := '';
            section := '';
            post_id := '';
       end;

    processando := true;
    jaLido := true;

    repeat
        if not jaLido then parser.Scan;
        jaLido := false;

        while parser.CurPartType = ptEmptyTag do
            begin
                if parser.CurName = 'enclosure' then
                    begin
                        for i := 0 to parser.CurAttr.Count-1 do
                            if parser.CurAttr.Name(i) = 'url' then
                                item.enclosure := parser.CurAttr.Value(i);
                    end;
                parser.Scan;
            end;

        if (parser.CurPartType = ptEndTag) and
            (parser.curName = 'item') then
                break;

        if parser.CurPartType <> ptStartTag then
             erro (pegaTextoMensagem('NEFSTART') + parser.curName);  {'Faltou o startTag. Veio '}

        tag := parser.curName;
        parser.Scan;
        if parser.CurPartType = ptEndTag then continue;

        lido := parser.CurContent;
        lido := limpaTexto (lido);

        if      tag = 'title'         then item.title := lido
        else if tag = 'link'          then item.link := lido
        else if tag = 'description'   then
            begin
                 item.description := processaDescription;
                 jaLido := true;
            end
        else if tag = 'author'        then item.author := lido
        else if tag = 'dc:creator'    then
            begin
                 item.creator := getCData('dc:creator');
                 jaLido := true;
            end
        else if tag = 'category'      then item.category := lido
        else if tag = 'comments'      then item.comments := lido
        else if tag = 'guid'          then item.guid := lido
        else if tag = 'pubDate'       then item.pubDate := lido
        else if tag = 'modifiedDate'  then item.modifiedDate := lido
        else if tag = 'source'        then item.source := lido
        else if tag = 'section'       then item.section := lido
        else if tag = 'post-id'       then item.post_id := lido
        else if tag = 'content' then {}

        else if (tag = 'texto_materia') or
                (tag = 'editoria') or
                (tag = 'autor_materia') or
                (tag = 'img_materia') or   // tags especiais do feedburner da ed. Abril
                (tag = 'titleApp') or
                (tag = 'topTitleApp') or   // tags globo 

                (pos (':', parser.curName) <> 0) then    // extensões
                begin
                    ignoraTag_extensao (tag);
                    jaLido := true;
                end
            else
                erro (pegaTextoMensagem('NETAGINV') + tag);  {'Tag inválida: '}

        if not jaLido then parser.Scan;
        jaLido := false;

        if parser.CurPartType <> ptEndTag then
             erro (pegaTextoMensagem('NEFEND') + parser.curName);  {'Faltou o endTag. Veio '}

    until not processando;

    setLength(canal.items, length(canal.items)+1);
    canal.items[length(canal.items)-1] := item;
end;

procedure processaImage (var canal: TRss);
var
    processando : boolean;
    tag: string;
    lido: string;
    jaLido: boolean;
begin
    processando := true;
    jaLido := true;
    repeat
        if not jaLido then parser.Scan;
        jaLido := false;

        while parser.CurPartType = ptEmptyTag do
            parser.Scan;

        if (parser.CurPartType = ptEndTag) and
            (parser.curName = 'image') then
                break;

        if parser.CurPartType <> ptStartTag then
             erro (pegaTextoMensagem('NEFSTART') + parser.curName);  {'Faltou o startTag. Veio '}

        tag := parser.curName;
        parser.Scan;
        if parser.CurPartType = ptEndTag then continue;

        lido := parser.CurContent;

        if      tag = 'url'         then canal.image.url := lido
        else if tag = 'title'       then canal.image.title := lido
        else if tag = 'link'        then canal.image.link := lido
        else if tag = 'width'       then canal.image.width := strToInt(lido)
        else if tag = 'height'      then canal.image.height := strToInt(lido)
        else if tag = 'description' then
            begin
                 canal.image.description := processaDescription;
                 jaLido := true;
            end
        else if tag = 'content' then
        else
            if pos (':', parser.curName) <> 0 then
                begin
                    ignoraTag_extensao (tag);
                    jaLido := true;
                end
            else
                erro (pegaTextoMensagem('NETAGINV') + tag);  {'Tag inválida: '}

        if not jaLido then parser.Scan;
        jaLido := false;

        if parser.CurPartType <> ptEndTag then
             erro (pegaTextoMensagem('NEFEND') + parser.curName);  {'Faltou o endTag. Veio '}

    until not processando;
end;

function carregaRss (var canal: TRss): boolean;
var
    processando : boolean;
    tag: string;
    lido: string;
    jaLido: boolean;
begin
    with canal do
        begin
            title := '';
            link := '';
            description:= '';
            atom_link:= '';
            language:= '';
            copyright := '';
            managingEditor:= '';
            webMaster:= '';
            pubDate:= '';
            lastBuildDate:= '';
            category:= '';
            generator:= '';
            docs:= '';
            cloud:= '';
            ttl:= 0;
            rating:= '';
            textInput:= '';
            skipHours:= '';
            skipDays:= '';
            site := '';
        end;

    processando := true;
    houveErro := false;
    jaLido := false;
    repeat
        parser.Scan;

        while parser.CurPartType = ptComment do
            if not parser.Scan then break;

        while parser.CurPartType = ptEmptyTag do
            if not parser.Scan then break;

        if (parser.CurPartType = ptEndTag) and
            (parser.curName = 'channel') then
                break;

        if parser.CurPartType <> ptStartTag then
            begin
                erro (pegaTextoMensagem('NEFSTART') + parser.curName);  {'Faltou o startTag. Veio '}
                while parser.CurPartType <> ptStartTag do
                    if not parser.Scan then break;
            end;

        tag := parser.curName;
        parser.Scan;
        if parser.CurPartType = ptEndTag then continue;

        lido := parser.CurContent;

        if      tag = 'title' then canal.title := lido
        else if tag = 'link' then canal.link := lido
        else if tag = 'description' then
            begin
                 canal.description := processaDescription;
                 jaLido := true;
            end
        else if tag = 'language' then canal.language:= lido
        else if tag = 'copyright' then canal.copyright := lido
        else if tag = 'managingEditor' then canal.managingEditor:= lido
        else if tag = 'webMaster' then canal.webMaster:= lido
        else if tag = 'pubDate' then canal.pubDate:= lido
        else if tag = 'lastBuildDate' then canal.lastBuildDate:= lido
        else if tag = 'category' then canal.category:= lido
        else if tag = 'generator' then canal.generator:= lido
        else if tag = 'docs' then canal.docs:= lido
        else if tag = 'cloud' then canal.cloud:= lido
        else if tag = 'ttl' then canal.ttl:= strToInt (lido)
        else if tag = 'image' then
            begin
                processaImage (canal);
                jaLido := true;
            end
        else if tag = 'rating' then canal.rating:= lido
        else if tag = 'textInput' then canal.textInput:= lido
        else if tag = 'skipHours' then canal.skipHours:= lido
        else if tag = 'skipDays' then canal.skipDays:= lido
        else if tag = 'site' then canal.site:= lido
        else if tag = 'item' then
            begin
                processaItem(canal);
                jalido := true;
            end
        else
            if pos (':', parser.curName) <> 0 then
                begin
                    ignoraTag_extensao (tag);
                    jaLido := true;
                end
            else
                erro (pegaTextoMensagem('NETAGINV') + tag);  {'Tag inválida: '}

        if not jaLido then parser.Scan;
        jaLido := false;

        if parser.CurPartType <> ptEndTag then
             erro (pegaTextoMensagem('NEFEND') + parser.curName);  {'Faltou o endTag. Veio '}

    until not processando;

    result := not houveErro;
end;

procedure liberaRss (var canal: TRss);
var i: integer;
begin
    // preventivo: limpa heap de strings
    for i := 0 to length(canal.items)-1 do
        with canal.items[i] do
        begin
            title := '';
            description := '';
            creator:= '';
            category := '';
            enclosure := '';
            guid := '';
            source := '';
            section := '';
            post_id:= '';
        end;

    setLength(canal.items, 0);
end;

end.

