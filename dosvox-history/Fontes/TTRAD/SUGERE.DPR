program sugere;
uses classes, sysUtils, dvcrt, dvwin, dvdic, dvForm;

var
    s: string;
    listaAlternativa, palOrig, palTroca: TStringList;

function carregaSugestoesDic (nomeSug: string): boolean;
var
    arqTrocas: textFile;
    p: integer;
begin
    carregaSugestoesDic := false;

    palOrig := TStringList.Create;
    palTroca := TStringList.Create;

    assign (arqTrocas, nomeSug);
    {$I-} reset (arqTrocas);  {$I+}
    if ioresult <> 0 then
         exit;

    while not eof (arqTrocas) do
        begin
            readln (arqTrocas, s);
            if s = '' then continue;
            p := pos ('=', s);
            if p < 2 then
                begin
                    sintWriteln ('Linha errada no arquivo ' + nomeSug + ': ' +  s);
                    exit;
                end;

            palOrig.add  (trim (copy (s, 1, p-1)));
            palTroca.add (trim (copy (s, p+1, 99)));
        end;

    closeFile (arqTrocas);
    carregaSugestoesDic := true;
end;

procedure geraAlternativasDic (s: string; ind: integer; lista: TStringList);
var prefixo, pesquisa, chute: string;
    i, t, nc: integer;

begin
    if not procuraDic (s) then
        begin
            chute := maiuscAnsi (s);
            if procuraDic(chute) then
                lista.Add(chute);
        end
    else
        lista.Add(s);

    if s[1] in dicVogal then
        begin
            prefixo := maiuscAnsi (s);
            chute := prefixo[1] + copy (s, 2, 99);
            if procuraDic(chute) then
                lista.Add(chute);

            chute := 'h' + s;
            if procuraDic(chute) then
                lista.Add(chute);
        end;

    for i := ind to length (s) do
        begin
            prefixo := copy (s, 1, i-1);
            pesquisa := copy (s, i, 99);
            for t := 0 to palOrig.count-1 do
                    begin
                        nc := length (palOrig[t]);
                        if copy (pesquisa, 1, nc) = palOrig[t] then
                            begin
                                chute := pesquisa;
                                delete (chute, 1, nc);
                                insert (palTroca[t], chute, 1);
                                insert (prefixo, chute, 1);
                                if procuraDic(chute) then
                                    lista.Add(chute);
                            end;
                end;
        end;
end;

procedure mostraAlternativas;
var i, nsel: integer;
begin
    sintWriteln (intToStr (listaAlternativa.count) + ' alternativas, use as setas');

    garanteEspacoTela(listaAlternativa.count);
    popupMenuCria(1, wherey, 50, listaAlternativa.count, RED);
    for i := 0 to listaAlternativa.Count-1 do
        popupMenuAdiciona('', listaAlternativa[i]);
    nsel := popupMenuSeleciona;

    if nsel > 0 then
        begin
            writeln (listaAlternativa[nsel-1]);
            sintSoletra (listaAlternativa[nsel-1]);
        end;
end;

begin
    sintInic (0, '');
    if carregaDic ('c:\winvox\diciona.dic',
                   'c:\winvox\diciona.suf',
                   'c:\winvox\diciona.exc',
                   'c:\winvox\diciona.nom') <> 0 then
        sintWriteln ('Dicionário não carregado');

    if not carregaSugestoesDic ('diciona.sug') then
        sintWriteln ('Arquivo de sugestões não carregado');

    listaAlternativa := TStringList.Create;
    listaAlternativa.sorted := true;
    listaAlternativa.Duplicates := dupIgnore;

    repeat
            sintWriteln ('Digite a palavra errada');
            sintReadln (s);
            if s = '' then break;

            listaAlternativa.clear;
            geraAlternativasDic (s, 1, listaAlternativa);
            if listaAlternativa.count = 0 then
                sintWriteln ('sem sugestão')
            else
                mostraAlternativas;
    until s = '';


    listaAlternativa.free;
    fechaDic;
    sintFim;
    donewincrt;
end.

