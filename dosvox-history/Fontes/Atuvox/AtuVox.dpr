{--------------------------------------------------------}
{
{       AtuVox - Programa que atualiza DOSVOX.INI a partir de um arquivo
{
{       Por: Neno Albernaz - neno@intervox.nce.ufrj.br
{       Em: 25/07/2021
{
{       Reaproveitamento de parte do código das rotinas de atualização do DOSVOX (dosupdat.pas)
{
{--------------------------------------------------------}

program atuVox;

uses
    dvcrt, dvwin, dvForm, dvarq,
    sysUtils,
    atuMsg;

{--------------------------------------------------------}
{       atualiza DOSVOX.INI a partir de um arquivo
{--------------------------------------------------------}

function mudaArrobas (s, dirOriginal: string): string;
var p: integer;
begin
    p := pos ('@@', s);
    if p <> 0 then
        begin
            delete (s, p, 2);
            insert (sintDirAmbiente, s, p);
        end;

    p := pos ('=@', s);
    if p <> 0 then
        begin
            delete (s, p+1, 1);
            insert (dirOriginal, s, p+1);
        end;

    p := pos ('@\', s);
    if p <> 0 then
        begin
            delete (s, p, 1);
            insert (dirOriginal, s, p);
        end;

    result := s;
end;

{-------------------------------------------------------------}
{       Retorna uma string centralizada
{-------------------------------------------------------------}

function centralizaFrase (frase: string): string;
var t, i: integer;
begin
    frase := trim (frase);
    t := length (frase);
    if t < 80 then
        begin
            t := (80 - t) div 2;
            for i := 1 to t do frase := ' ' + frase;
            while length (frase) < 80 do frase := frase + ' ';
        end;

    result := frase;
end;

{--------------------------------------------------------}
{       Corpo principal
{--------------------------------------------------------}

var
    nomeArq: string;
    c: char;
    realtera: boolean;
    secao, item, valor, s: string;
    arq: text;
    p: integer;
    dirOriginal: string;

    function existeChave (secao, item: string): boolean;
    begin
        existeChave := sintAmbiente (secao, item) <> '';
    end;

label fim;
begin
    inicFala;
    clrscr;
    setWindowTitle('Atuvox');
    textBackground (BLUE);
    write (centralizaFrase(pegaTextoMensagem('ATUINIC'))); {'Atualizar configuração por arquivo .ATU'}
    textBackground (BLACK);
    writeln;
    mensagem ('ATUINIC', -1); {'Atualizar configuração por arquivo .ATU'}

    if paramCount >= 1 then
        begin
            nomeArq := trim (paramStr(paramCount));
            if not  fileExists (nomeArq) then nomeArq := '';
        end
    else
        nomeArq := '';

    if nomeArq = '' then
        begin
            mensagem ('ATUARQMUDANCA', 1);     {'Informe o nome do arquivo que contém as mudanças'}
            nomeArq := obtemNomeArqMasc (10, '*.ATU');
    end;

    if nomeArq = '' then
        begin
            writeln;
            mensagem ('ATUATUNEC', 1);   {'Nenhum arquivo .ATU foi selecionado.'}
            goto fim;
        end;

    assign (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('ATUARQNAOEX', 1);   { 'Arquivo não existe, sinto muito.' }
            goto fim;
        end;

    repeat
        mensagem ('ATUREALTERASN', 0);     { 'Deseja realterar itens anteriormente criados?' }
        c := upcase(popupMenuPorLetra('SN'));
        writeln;
    until c in ['S', 'N', ESC];

    if c= ESC then
        begin
            {$I-} close (arq);  {$I+}
            if ioresult <> 0 then;
            mensagem ('ATUDESIST', 1);   {'Desistiu ...'}
            goto fim;
        end;

    realtera := upcase (c) = 'S';

     dirOriginal := sintAmbiente ('DOSVOX', 'PGMDOSVOX');

     secao := '';
     while not eof (arq) do
         begin
             readln (arq, s);
             if (s <> '') and (s[1] <> ';') and (s[1] <> '*') then
                 begin
                     if s[1] = '[' then
                          begin
                              delete (s, 1, 1);
                              delete (s, length(s), 1);
                              secao := s;
                          end
                     else
                          begin
                              p := pos ('=', s);
                              if p > 1 then
                                  begin
                                      s := mudaArrobas(s, dirOriginal);
                                      item := copy (s, 1, p-1);
                                      valor := copy (s, p+1, length(s));
                                      if realtera or (not existeChave (secao, item)) then
                                          begin
                                              sintGravaAmbiente (secao, item, valor);
                                              if dvWin.sintAceitaLegado then
                                                  sintGravaAmbienteArq (secao, item, valor, 'dosvox.ini');
                                          end;
                                  end
                              else
                                  begin
                                      mensagem ('ATUCHAVEINVAL', 1);    { 'Chave inválida' }
                                      sintWriteln (s);
                                  end;
                          end;
                 end;
         end;

     close (arq);
     mensagem ('ATUOK', 1);         { 'Ok ! '}

fim:
    sintfim;
    doneWinCrt;
end.
