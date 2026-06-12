unit neatom;

interface
uses
    dvwin,
    dvcrt,
    sysUtils,
    libXmlParser,
    neRss,
    neUtil,
    nemsg;

function carregaAtomRss (var canal: TRss): boolean;

implementation

procedure processaEntry (var canal: TRss);
var
    processando : boolean;
    tag: string;
    lido: string;
    jaLido: boolean;
    item: TItem;
    n, nome, email: string;

    function processaAuthor: string;
    begin
        repeat         // simplificação
            parser.scan;
            if (parser.CurPartType = ptStartTag) then
                begin
                     n := parser.CurName;
                     parser.scan;
                     if parser.CurPartType = ptContent then
                         begin
                             if n = 'name' then nome := parser.CurContent
                             else
                             if n = 'email' then email := parser.CurContent;
                             parser.scan;
                         end;
                     parser.Scan;
                end;
        until (parser.CurPartType = ptEndTag) and (parser.curName = 'author');
        result := nome + '<' + email + '>';
        jaLido := true;
    end;

begin
    with item do
        begin
            title := '';
            link  := '';
            description  := '';
            author  := '';
            category  := '';
            comments  := '';
            enclosure  := '';
            guid  := '';
            pubDate := '';
            modifiedDate := '';
            source := '';
            section := '';
       end;

    processando := true;
    jaLido := true;

    repeat
        if not jaLido then parser.Scan;
        jaLido := false;

        while parser.CurPartType = ptEmptyTag do
            begin
                tag := parser.curName;
                if tag = 'category' then
                    begin
                         if item.category <> '' then
                             item.category := item.category + '; ';
                         item.category := item.category + Parser.CurAttr.Value ('term');
                    end
                else
                if tag = 'link' then item.link := Parser.CurAttr.Value ('href');
                parser.Scan;
             end;

        if (parser.CurPartType = ptEndTag) and
            (parser.curName = 'entry') then
                break;

        if parser.CurPartType <> ptStartTag then
             erro (pegaTextoMensagem('NEFSTART') + parser.curName);  {'Faltou o startTag. Veio '}

        tag := parser.curName;
        parser.Scan;
        if parser.CurPartType = ptEndTag then continue;

        lido := parser.CurContent;

        if      tag = 'title'         then item.title := lido
        else if tag = 'summary'       then item.description := lido
        else if tag = 'author'        then item.author := processaAuthor
        else if tag = 'id'            then item.guid := lido
        else if tag = 'published'     then item.pubDate := lido
        else if tag = 'updated'       then item.modifiedDate := lido
        else if tag = 'content'       then item.comments := lido
        else
            if pos (':', parser.curName) = 0 then
                erro (pegaTextoMensagem('NETAGINV') + tag);  {'Tag inválida: '}

        if not jaLido then parser.Scan;
        jaLido := false;

        if parser.CurPartType <> ptEndTag then
             erro (pegaTextoMensagem('NEFEND') + parser.curName);  {'Faltou o endTag. Veio '}

    until not processando;

    setLength(canal.items, length(canal.items)+1);
    canal.items[length(canal.items)-1] := item;
end;


function carregaAtomRss (var canal: TRss): boolean;
var
    processando : boolean;
    tag: string;
    lido: string;
    alt, site: string;
    jaLido: boolean;
begin
    with canal do    // simula como se fosse Rss 2.0
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
        end;

    processando := true;
    houveErro := false;
    jaLido := false;
    repeat
        parser.Scan;

        while parser.CurPartType = ptEmptyTag do
            begin
                tag := parser.curName;
                if tag = 'link' then
                    begin
                        alt  := Parser.CurAttr.Value ('alt');
                        site := Parser.CurAttr.Value ('href');
                        if alt <> 'self' then  canal.link := site
                                         else  canal.atom_link := site;
                    end;
                parser.Scan;
             end;

        if (parser.CurPartType = ptEndTag) and
            (parser.curName = 'feed') then
                break;

        if parser.CurPartType <> ptStartTag then
             erro (pegaTextoMensagem('NEFSTART') + parser.curName);  {'Faltou o startTag. Veio '}

        tag := parser.curName;
        parser.Scan;
        if parser.CurPartType = ptEndTag then continue;

        lido := parser.CurContent;

        if      tag = 'title' then canal.title := lido
        else if tag = 'subtitle' then canal.description := lido
        else if tag = 'rights' then canal.copyright := lido
        else if tag = 'updated' then canal.lastBuildDate:= lido
        else if tag = 'category' then canal.category:= lido
        else if tag = 'generator' then canal.generator:= lido
        else if tag = 'id' then canal.cloud:= lido
        else if tag = 'icon' then canal.image.link := lido
        else if tag = 'logo' then canal.image.url := lido
        else if tag = 'entry' then
            begin
                processaEntry(canal);
                jalido := true;
            end
        else
            if pos (':', parser.curName) = 0 then
                erro (pegaTextoMensagem('NETAGINV') + tag);  {'Tag inválida: '}

        if not jaLido then parser.Scan;
        jaLido := false;

        if parser.CurPartType <> ptEndTag then
             erro (pegaTextoMensagem('NEFEND') + parser.curName);  {'Faltou o endTag. Veio '}

    until not processando;

    result := not houveErro;
end;

end.

