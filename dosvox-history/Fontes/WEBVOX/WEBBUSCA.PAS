{-------------------------------------------------------------}
{
{    Webvox - Módulo para armazenar páginas selecionadas
{
{    Autor: Bernard Condorcet
{
{    Em 19/01/2001
{
{-------------------------------------------------------------}

unit webBusca;

interface

uses dvcrt, dvWin, dvForm,
     windows,
     webVars, webMsg, webTraz, webGrArq;

function armazenaOrig (nomeArq: string): boolean;
procedure armazenaVariasPaginas;

implementation

{-------------------------------------------------------------}

function armazenaOrig (nomeArq: string): boolean;
var
arq, arqSai: file;
buf: array [0..4095] of byte;
lidos: integer;

label erroDisco;

begin

    armazenaOrig := false;

    assign (arq, nomeTemp);
    {$I-}  reset (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBTRAAPA', 1);  {'Arquivo de trabalho foi apagado'}
            exit;
        end;

    assign (arqSai, nomeArq);
    {$I-}  rewrite (arqSai, 1);  {$I+}
    if ioresult <> 0 then
        begin
erroDisco:
            mensagem ('WBERRGRD', 1);  {'Problemas para gravar arquivo no disco'}
            {$I-}  close (arq);  {$I+}
            if ioresult <> 0 then;
            {$I-}  close (arqSai);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    while not eof (arq) do
        begin
            {$I-} blockread (arq, buf, 4096, lidos);  {$I+}
            if lidos = 0 then goto erroDisco;
            if ioresult <> 0 then goto erroDisco;
            {$I-} blockwrite (arqSai, buf, lidos);  {$I+}
            if ioresult <> 0 then goto erroDisco;
        end;

    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then;
    {$I-}  close (arqSai);  {$I+}
    if ioresult <> 0 then goto erroDisco;

    armazenaOrig := true;

end;

{-------------------------------------------------------------}
{Busca URL e grava no disco de acordo com o formato escolhido
{-------------------------------------------------------------}

procedure armazenaVariasPaginas;
var
    nomeArqBuscador: string;
    arqEnd: textFile;
    nomeArq: string;
    numPag: integer;
    s: string;
    ano, mes, dia, sem: word;
    linha, diaSem, nomePag: string;
    opTxtHtm, opRefer: char;

    {-------------------------------------------------------------}

        function comparaDiaSemana: boolean;
        var i: integer;
        begin
            comparaDiaSemana := false;

            for i:= 1 to length(diaSem) do
                begin
                    if (diaSem[i] = 'Á') or (diaSem[i] = 'Ã') or (diaSem[i] = 'À') or
                    (diaSem[i] = 'á') or (diaSem[i] = 'ã') or (diaSem[i] = 'à') then
                        diaSem[i]:= 'A';

                    if (diaSem[i] = 'É') or (diaSem[i] = 'Ê') or
                    (diaSem[i] = 'é') or (diaSem[i] = 'ê') then
                        diaSem[i]:= 'E';

                    if (diaSem[i] = 'Í') or
                    (diaSem[i] = 'í') then
                        diaSem[i]:= 'i';

                    if (diaSem[i] = 'Ó') or (diaSem[i] = 'Õ') or
                    (diaSem[i] = 'ó') or (diaSem[i] = 'õ') then
                        diaSem[i]:= 'O';

                    if (diaSem[i] = 'Ú') or
                    (diaSem[i] = 'ú') then
                        diaSem[i]:= 'U';

                    if (diaSem[i] = 'Ç') or
                    (diaSem[i] = 'ç') then
                        diaSem[i]:= 'C';

                    diaSem[i]:= upcase(diaSem[i]);
                end;

            if  (diaSem = '') or
                (diaSem = '[DOMINGO]') and (sem = 0) or
                (diaSem = '[SEGUNDA]') and (sem = 1) or
                (diaSem = '[TERCA]') and (sem = 2) or
                (diaSem = '[QUARTA]') and (sem = 3) or
                (diaSem = '[QUINTA]') and (sem = 4) or
                (diaSem = '[SEXTA]') and (sem = 5) or
                (diaSem = '[SABADO]') and (sem = 6) then

                    comparaDiaSemana := true;
        end;

    {-------------------------------------------------------------}

        procedure trazEstaPagina;
        var nomeDir: string;
        begin
            if numPag = 0 then
                mensagem ('WBBUSGRV', 0); {'Vou tentar buscar e gravar '}
            sintWriteln (nomePag);

            if trazerPagina (nomeTemp, 'G') then
                begin
                    delay (250);
                    numPag := numPag + 1;
                    str (numPag, s);

                    nomeDir := sintAmbiente ('WEBVOX', 'DIRBUSCADOR');
                    if nomeDir = '' then
                        nomeDir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\treino';
                    if nomeDir [length(nomeDir)] <> '\' then
                        nomeDir := nomeDir + '\';

                    if opTxtHtm = 'T' then
                        begin
                            nomeArq := (nomeDir + nomePag + '.txt');
                            if upcase(opRefer) = 'S' then
                                geraArqTexto (nomeTemp, nomeArq, true)
                            else
                                geraArqTexto (nomeTemp, nomeArq, false);
                        end
                    else  // opção O
                        begin
                            if pos('.', nomePag) = 0 then
                                nomeArq := (nomeDir + nomePag + '.htm');
                            if not armazenaOrig (nomeArq) then;
                        end;

                    if numPag = 1 then
                        begin
                            mensagem ('WBOKGRAV', 0); {'Ok, já gravei '}
                            sintWriteln (nomePag)
                        end;
                end;
        end;

    {-------------------------------------------------------------}

begin
    nomeArqBuscador := sintAmbiente ('WINVOX', 'ARQBUSCADOR');
    if nomeArqBuscador = '' then
        nomeArqBuscador := sintDirAmbiente + '\buscador.ini';
    assign (arqEnd, nomeArqBuscador);
    {$I-}  reset (arqEnd);  {$I+}
    if ioresult <> 0 then
        begin
            writeln;
            mensagem ('WBVCNCRI', 1); {'Você não criou o arquivo de endereços'}
            exit;
        end;

    mensagem ('WBORITXT', 0); {'Digite O para formato original ou T para texto'}
    opTxtHtm:= popupMenuPorLetra ('OT');
    writeln;
    if (opTxtHtm <> 'O') and (opTxtHtm <> 'T') then
        exit;

    if opTxtHtm = 'T' then
    begin
        mensagem ('WBQUEREF', 0); {'Deseja referências listadas no texto ? '}
        opRefer:= popupMenuPorLetra ('SN');
        writeln;
    end;

    getdate (ano, mes, dia, sem);
    numPag := 0;

    while not eof(arqEnd) do
        begin
            readln (arqEnd, linha);
            if linha <> '' then
                begin
                    diaSem := copy(linha, 1, pos(']', linha));
                    delete (linha, 1, pos(']', linha));
                    if (linha <> '') and (linha[1] = '"') then
                        begin
                            delete (linha, 1, 1);
                            nomeTemp := copy(linha, 1, pos('"', linha));
                            delete (linha, 1, length (nomeTemp));
                            delete (nomeTemp, length (nomeTemp), 1);
                        end
                    else
                        begin
                            nomeTemp := copy(linha, 1, pos('=', linha));
                            delete (nomeTemp, pos('=', nomeTemp), 1);
                            delete (linha, 1, pos('=', linha));
                        end;
                    nomePag := linha;
                    if comparaDiaSemana then
                        trazEstaPagina;
                end;
            delay (250);
        end;

    close (arqEnd);

    if numPag > 0 then
        begin
            writeln;
            mensagem ('WBJACONS', 1);  {'Ok, as páginas já constam no diretório especificado'}
        end
        else
        begin
            writeln;
            mensagem ('WBNAOGRA', 1);  {'Não gravei página alguma'}
            nomeTemp := '';
        end;
end;

end.
