{-------------------------------------------------------------}
{
{    Webvox - Manipulação dos bookmarks
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webBmark;

interface
uses dvcrt, dvexec, sysUtils, dvWin, winsock,
    dvForm,
    webVars, webMsg, weburl, webTraz, webLeit;

procedure carregaBookMarks;
procedure adicionaBookMark;
procedure folheiaBookMarks;
procedure paginasSeletas;

implementation

{-------------------------------------------------------------}

procedure gravaBookMarks;
var
    nomeArqBmark: string;
    arqBookMark: text;
    i: integer;

label erroDisco;
begin

    {Bernard}
    (* nomeArqBmark := sintAmbiente ('WEBVOX', 'ARQWEBSELEC');
    if nomeArqBmark = '' then
        nomeArqBmark := sintDirAmbiente + '\webselec.ini'; *)

    {Bernard}
    nomeArqBmark := titCatal;

    assign (arqBookMark, nomeArqBMark);
    {$I-} rewrite (arqBookMark);  {$I-}
    if ioresult <> 0 then
        begin
erroDisco:
            mensagem ('WBERRGRD', 1);   {'Problemas para gravar arquivo no disco'}
            {$I-} close (arqBookMark);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    for i := 1 to nBookMarks do
        begin
             writeln (arqBookMark, bookMark[i]^, '=', comentBMark[i]^);
             if ioresult <> 0 then goto erroDisco;
        end;
    close (arqBookMark);
end;

{-------------------------------------------------------------}

procedure carregaBookMarks;
var nomeArqBmark, s: string;
    arqBookMark: text;
    n: integer;
begin

    {Bernard}
    (* nomeArqBmark := sintAmbiente ('WEBVOX', 'ARQWEBSELEC');
    if nomeArqBmark = '' then
        nomeArqBmark := sintDirAmbiente + '\webselec.ini'; *)

    {Bernard}
    nomeArqBmark := titCatal;

    nBookMarks := 0;
    assign (arqBookMark, nomeArqBMark);
    {$I-}  reset (arqBookMark);  {$I+}
    if ioresult <> 0 then exit;

    while not eof (arqBookMark) do
        begin
             readln (arqBookMark, s);
             if (s <> '') and (s[1] <> ';') then
                 begin
                     n := length (s);
                     while (n > 0) and (s[n] <> '=') do n := n - 1;
                     if n <> 0 then
                         begin
                             nBookMarks := nBookMarks + 1;
                             new (bookMark[nBookMarks]);
                             new (comentBMark[nBookMarks]);

                             bookMark [nBookMarks]^ := copy (s, 1, n-1);
                             comentBMark [nBookMarks]^ := copy (s, n+1, length (s) - n);
                         end;
                 end;
        end;

    close (arqBookMark);
end;

{-------------------------------------------------------------}

procedure adicionaBookMark;
var coment: string;
    s: string;
begin
    if nomePagAtual = '' then
        begin
            mensagem ('WBNAOCAR', 1); {'Não existe página carregada'}
            mensagem ('WBDIGPAG', 1); {'Qual o nome da página desejada ?'}
            sintReadln (s);
            if s = '' then
                 begin
                     mensagem ('WBDESIST', 1);  {'Desistiu...'}
                     exit;
                 end;
        end
    else
        s := nomePagAtual;

    mensagem ('WBCOMBMK', 1);   {'Digite um comentário para esta seleção'}
    sintReadln (coment);
    if coment = '' then
        begin
              mensagem ('WBDESIST', 1);
              exit;
        end;

    if nbookMarks < MAXBOOKMARK then
        begin
            nBookMarks := nBookMarks + 1;
            new (bookMark[nBookMarks]);
            new (comentBMark[nBookMarks]);
            bookMark [nBookMarks]^ := s;
            comentBMark [nBookMarks]^ := coment;
        end;

    gravaBookMarks;
end;

{-------------------------------------------------------------}

procedure buscaTextoBmark (pergunta: boolean; var n: integer);
var b, i: integer;
begin
    b := n;
    if pergunta then
        begin
            writeln;
            mensagem ('WBQUALTX', 1);   {'Qual o texto a buscar ? '}
            sintReadln (textoBuscado);
            if textoBuscado = '' then
                begin
                    textoBuscado :=  sintambiente ('WEBVOX','TEXTOBUSCADO');
                    exit;
                end;
        end
    else
        b := n + 1;

    if b <= 0 then b := 1;

    textoBuscado := maiuscAnsi (textoBuscado);
    for i := b to nBookMarks do
        begin
            if pos (textoBuscado, maiuscAnsi (comentBMark [i]^)) <> 0 then
                begin
                    sintWriteln (comentBMark [i]^);
                    n := i;
                    exit;
                end;
        end;

    mensagem ('WBNAOACH', 1);    {'Texto não encontrado após esta posição do texto'}
end;

{-------------------------------------------------------------}

procedure folheiaBookMarks;
var
    i, nsel: integer;
    c: char;
    voltando: boolean;
    pag: string;
label trazer, semBmark, remover;
begin
    if nBookMarks = 0 then
         begin
semBmark:
             mensagem ('WBSEMBMK', 1);   {'Não existem mais páginas seletas'}
             exit;
         end;

    voltando := false;
    nsel := 0;
    mensagem ('WBUSESET', 1);   {'Use setas, depois comande trazer, informação ou remover'}
    repeat
        c := readkey;
        case upcase(c) of
            #$0:  begin
                      c := readkey;
                      case c of
                         CIMA:    begin
                                       nsel := nsel - 1;
                                       if nsel < 1 then
                                           begin
                                                nsel := 0;
                                                sintBip;
                                           end
                                       else
                                           sintWriteln (comentBMark [nsel]^);
                                  end;
                         BAIX:    begin
                                       nsel := nsel + 1;
                                       if nsel > nBookMarks then
                                           begin
                                                nsel := nBookMarks+1;
                                                sintBip;
                                           end
                                       else
                                           sintWriteln (comentBMark [nsel]^);
                                  end;
                         PGUP:    begin
                                      nsel := 1;
                                      sintWriteln (comentBMark [nsel]^);
                                  end;
                         PGDN:    begin
                                      nsel := nBookMarks;
                                      sintWriteln (comentBMark [nsel]^);
                                  end;

                         ESQ:     if (nsel >= 1) and (nsel <= nBookMarks) then sintetiza (comentBMark [nsel]^)
                                  else sintclek;
                         CTLESQ:     if (nsel >= 1) and (nsel <= nBookMarks) then sintSoletra (comentBMark [nsel]^)
                                  else sintclek;
                         DIR:     if (nsel >= 1) and (nsel <= nBookMarks) then sintetiza (bookMark [nsel]^)
                                  else sintclek;
                         CTLDIR:     if (nsel >= 1) and (nsel <= nBookMarks) then sintSoletra (bookMark [nsel]^)
                                  else sintclek;

                         F5:      buscaTextoBMark (true, nsel);
                         F7:      goto remover;
                         CTLF5:   buscaTextoBMark (false, nsel);
                      end;
                  end;

            ENTER, 'T':  begin
                              if (nsel >= 1) and (nsel <= nBookMarks) then
                                  begin
                                      pag := bookMark [nsel]^;
                                      completaEsquema (pag);
                                      if trazerPagina (pag, 'G') then
                                          lerPagina (voltando);
                                      exit;
                                  end;
                          end;

            CTLENTER: // Executar página fora do Dosvox
                      if (nsel >= 1) and (nsel <= nBookMarks) then
                          begin
                              pag := bookMark [nsel]^;
                              completaEsquema (pag);
                              if executaProg (pag, '', '') >= 32 then
                                  esperaProgVoltar;
                              exit;
                          end;

            'I':          begin
                              if (nsel >= 1) and (nsel <= nBookMarks) then
                                    sintWriteln ('   ' + bookMark [nsel]^)
                                else
                                    sintBip;
                          end;

            'R', 'A':     begin
remover:
                              if (nsel >= 1) and (nsel <= nBookMarks) then
                                  begin
                                    mensagem ('WBCNFEXC', 0);  {'Confirma a exclusão de '}
                                    sintWrite (comentBMark [nsel]^);
                                    write ('? ');
                                    c := popupMenuPorLetra ('SN');
                                    writeln;
                                    if c <> 'S' then
                                       mensagem ('WBOK', 1)
                                    else
                                      begin
                                        dispose (bookMark [nsel]);
                                        for i := nsel to nBookMarks -1 do
                                            begin
                                                bookMark [i] := bookMark [i+1];
                                                comentBMark [i] := comentBMark [i+1];
                                            end;
                                        nBookMarks := nBookMarks - 1;
                                        gravaBookmarks;
                                        if nBookMarks = 0 then
                                            goto semBMark
                                        else
                                            mensagem ('WBBMKREM', 1);  {'Removido'}
                                      end;
                                    end;
                                end;
        end;

    until c = ESC;
end;

{-------------------------------------------------------------}

procedure paginasSeletas;
var c: char;
begin
    mensagem ('WBFOLADI', 0);    {'Folhear ou adicionar ? '}
    c := popupMenuPorLetra ('FA' + ESC);
    writeln;

    case c of
        'A': adicionaBookMark;
        'F': folheiaBookMarks;
    end;
end;

end.
