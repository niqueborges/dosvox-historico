{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de folheamento de conversas                  }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recfolhe;

interface
uses dvcrt, dvwin, dvForm, dvWav, dvexec, dvdigitexto,
     recvars, recmsg, recMime64, recSMTP, recenvia,
     windows, classes, sysutils, dateUtils;

function contabiliza (ext: string): integer;
procedure mostraQuantosRecados;
procedure folhearRecados;

implementation

var recado: TStringList;

{--------------------------------------------------------}

function contabiliza (ext: string): integer;
var contador: integer;
    sr: TSearchRec;
    FileAttrs: Integer;
begin
    contador := 0;
    FileAttrs := faArchive;
    if FindFirst('*.' + ext, FileAttrs, sr) = 0 then
        repeat
             inc(contador);
        until FindNext(sr) <> 0;
        FindClose(sr);
    result := contador;
end;

{--------------------------------------------------------}

procedure mostraQuantosRecados;
var
    enviados, lidos, naoLidos, pendentes, total: integer;

begin
    {$i-}  chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
            exit;
        end;

    naoLidos  := contabiliza ('REC');
    pendentes := contabiliza ('CPR');
    lidos     := contabiliza ('LID');
    enviados  := contabiliza ('ENV');
    total     := contabiliza ('*');

    writeln;
    mensagem ('RCEXISTM', 0);   {'Existem:'}
    writeln;
    sintWriteInt (naoLidos);    {...}
    mensagem ('RCNAOLID', 0);   {' recados não lidos, '}
    writeln;
    sintWriteInt (pendentes);   {...}
    mensagem ('RCPENDEN', 0);   {' pendentes, '}
    writeln;
    sintWriteInt (enviados);    {...}
    mensagem ('RCENVIDO', 0);   {' enviados, '}
    writeln;
    sintWriteInt (lidos);       {...}
    mensagem ('RCLIDOS',  0);   {' lidos, '}
    writeln;
    sintWriteInt (total);       {...}
    mensagem ('RCMSGTOT', 2);   {' no total.}

    mensagem ('RCAPTENT', 0);   {'Aperte enter'}
    readln;
end;

{--------------------------------------------------------}

procedure ajudaFolheamento;
begin
    mensagem ('RCFLEREC', 1);   {'L - le Recado'}
    mensagem ('RCFTEXTO', 1);   {'T - editora o Texto do recado'}
    mensagem ('RCFAPAGA', 1);   {'A - Apaga o recado'}
    mensagem ('RCRESPON', 1);   {'R - Responde ao recado'}
    mensagem ('RCSALVAS', 1);   {'S - Salva o som do recado'}
end;

{--------------------------------------------------------}

function selSetasOpcaoFolhear: char;
const opmenu: string = 'LTARS' + #$1b;
var n: integer;
begin
    popupMenuCria(50, 8, 30, length(opmenu), RED);
    MenuAdiciona ('RCFLEREC');   {'L - le Recado'}
    MenuAdiciona ('RCFTEXTO');   {'T - editora o Texto do recado'}
    MenuAdiciona ('RCFAPAGA');   {'A - Apaga o recado'}
    MenuAdiciona ('RCRESPON');   {'R - Responde ao recado'}
    MenuAdiciona ('RCSALVAS');   {'S - salva o som do recado'}
    MenuAdiciona ('RCOP_ESC');   {'ESC - terminar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := ' '
    else
        result := opmenu[n];
end;


{--------------------------------------------------------}

function unQuotedPrintable (s: string): string;
var i, n1, n2: integer;
begin
    result := '';
    for i := length(s)-2 downto 1 do
        if s[i] = '=' then
            begin
                n1 := ord(s[i+1]) - ord('0');
                if n1 > 9 then n1 := n1 - 7;
                n2 := ord(s[i+2]) - ord('0');
                if n2 > 9 then n2 := n2 - 7;
                delete (s, i, 2);
                s[i] := chr(ord(n1 * 16) or n2);
            end;
    result := s;
end;

{--------------------------------------------------------}

function buscaInfoCabec (recado: TStringList;
                         buscado: string): string;
var lin: integer;
begin
    result := '';
    buscado := upperCase(buscado);

    for lin := 0 to recado.count-1 do
        if pos (buscado, upperCase(recado[lin])) = 1 then
            begin
                result := trim (copy (recado[lin], length(buscado)+1, 999));
                break;
            end;
end;

{--------------------------------------------------------}

procedure localizaTextoAudio (recado: TStringList;
                              var posAudio, posTexto: integer;
                              var chaveMime: string);
var lin: integer;

    procedure pula;
    begin
        while (lin < recado.count) and (recado[lin] <> chaveMime) do
            lin := lin + 1;
    end;

    procedure buscaBranco;
    begin
        while (lin < recado.count) and (recado[lin] <> '') do
            lin := lin + 1;
        lin := lin + 1;
    end;

begin
    posAudio := -1;
    posTexto := -1;
    chaveMime := 'dksfhalierhyoaiusdyfhjbkviue2yh';

    lin := 0;
    while lin < recado.count do
        begin
            if pos ('Content-Type: text/plain;', recado[lin]) = 1 then
                begin
                    chaveMime := recado[lin-1];
                    buscaBranco;
                    posTexto := lin;
                    pula;
                end
            else
            if pos ('Content-Type: audio/', recado[lin]) = 1 then
                begin
                    chaveMime := recado[lin-1];
                    buscaBranco;
                    posAudio := lin;
                    pula;
                end;

            lin := lin + 1;
        end;
end;

{--------------------------------------------------------}

procedure leRecado (nomeArq: string);
var
    i, j: integer;
    posAudio, posTexto: integer;
    chaveMime: string;
    nomeArqTemp, nomeArqMP3: string;
begin
    recado.LoadFromFile(nomeArq);

    localizaTextoAudio (recado, posAudio, posTexto, chaveMime);

    if posAudio > 0 then
        begin
            i := posAudio;

            for j := 0 to i-1 do
                recado.Delete(0);
            i := 0;
            while (i < recado.count) and (copy (recado[i], 1, 2) <> '--') do
                i := i + 1;

            while i < recado.count do
                recado.Delete(i);

            nomeArqTemp := pegaNomeArqTemp('m64');
            recado.saveToFile (nomeArqTemp);

            nomeArqMP3 := pegaNomeArqTemp('mp3');
            DecodMime64(nomeArqTemp, nomeArqMP3);
            deleteFile (nomeArqTemp);

            executaProg('c:\winvox\midiavox.exe', '.', nomeArqMP3);
            esperaProgVoltar;

            deleteFile (nomeArqMP3);
        end;

    if posTexto > 0 then
        begin
            if posAudio <> 0 then
                recado.LoadFromFile(nomeArq);

            window (1, 21, 80, 25);
            for i := posTexto to recado.Count-1 do
                begin
                    if (recado[i] <> chaveMime) and (recado[i] <> chaveMime + '--') then
                        sintWriteln (unQuotedPrintable (recado[i]))
                    else
                        break;
                end;
            sintbip; sintbip;
            while not keypressed do waitMessage;
            window (1, 1, 80, 25);
        end;

    if copy (nomeArq, length(nomeArq)-2, 3) = 'REC' then
        renameFile (nomeArq, copy (nomeArq, 1, length(nomeArq)-3) + 'LID');
end;

{--------------------------------------------------------}

procedure editaRecadoTextual (nomeArq: string);
var
    i: integer;
    posAudio, posTexto: integer;
    chaveMime: string;
    sl: TStringList;
begin
    recado.LoadFromFile(nomeArq);
    sl := TStringList.Create;

    localizaTextoAudio (recado, posAudio, posTexto, chaveMime);

    if posTexto <> 0 then
        begin
            for i := posTexto to recado.Count-1 do
                begin
                    if (recado[i] <> chaveMime) and (recado[i] <> chaveMime + '--') then
                        sl.add (unQuotedPrintable (recado[i]))
                    else
                        break;
                end;

            mensagem ('RCFEDESC', 1);   {'Ao final da edição, tecle ESC'}
            while sintFalando do;

            dvdigitexto.popupDigiTexto(sl, false, true, 1, 7, 80, 14, false);
            sl.Free;
        end;

    if copy (nomeArq, length(nomeArq)-2, 3) = 'REC' then
        renameFile (nomeArq, copy (nomeArq, 1, length(nomeArq)-3) + 'LID');
end;

{--------------------------------------------------------}

procedure apagaRecado (nomeArq: string);
var
    c: char;
begin
    if nomeArq = '' then exit;

    writeln (nomeArq);
    mensagem ('RCCNFREM', 0);    {'Confirma remoção? '}
    c := upcase(popupMenuPorLetra('S|N'));
    writeln;
    if c <> 'S' then exit;

    if deleteFile (nomeArq) then
        mensagem ('RCREMOVI', 0)     {'Arquivo removido: '}
    else
        mensagem ('RCNREMOV', 0);     {'Arquivo não removido: '}
    sintWriteln (nomeArq);
end;

{--------------------------------------------------------}

procedure salvaSomDoRecado (nomeArq: string);
var
    i, j: integer;
    posAudio, posTexto: integer;
    chaveMime: string;
    nomeTemp, nomeDest: string;
begin
    recado.LoadFromFile(nomeArq);

    localizaTextoAudio (recado, posAudio, posTexto, chaveMime);

    if posAudio = 0 then
        begin
            mensagem ('RCSEMAUD', 1);   {'O recado original não continha áudio'}
            exit;
        end;

    mensagem ('RCQNOMEC', 1);   {'Informe o nome do arquivo MP3 destino:'}
    sintReadln (nomeDest);
    nomeDest := trim (nomeDest);
    if nomeDest = '' then
        begin
            mensagem ('RCDESIST', 1);   {'Desistiu'}
            exit;
        end;

    if upperCase(copy (nomeDest, length(nomeDest)-3, 4)) <> '.MP3' then
        nomeDest := NomeDest + '.MP3';

    i := posAudio;

    for j := 0 to i-1 do
        recado.Delete(0);
    i := 0;
    while (i < recado.count) and (copy (recado[i], 1, 2) <> '--') do
        i := i + 1;

    while i < recado.count do
        recado.Delete(i);

    try
        nomeTemp := pegaNomeArqTemp('tmp');
        recado.saveToFile (nomeTemp);
        DecodMime64(nomeTemp, nomeDest);
        deleteFile (nomeTemp);

        mensagem ('RCOK', 1);
    except
        mensagem ('RCERRGRV', 1);   {'Erro de gravação de arquivo.'}
    end;
end;

{--------------------------------------------------------}

procedure respondeRecado (nomeArq: string);
var c: char;
    destinatario: string;
begin
    recado.LoadFromFile(nomeArq);

    destinatario := buscaInfoCabec(recado, 'Reply-to:');
    if destinatario = '' then
        destinatario := buscaInfoCabec(recado, 'From:');

    mensagem ('RCRESPA', 1);   {'Respondendo ao recado de'}
    sintWriteln (Destinatario);
    writeln;

    mensagem ('RCFALGRV', 0);   {'Vai responder como fala gravada? '}
    c := upcase(popupMenuPorLetra('S|N'));
    writeln;
    if c = 'S' then
        enviarRecadoFalado(destinatario)
    else
        enviarRecadoTextual(destinatario);
end;

{--------------------------------------------------------}

function arquivoContem (nomeArq, nome: string): boolean;
var sl: TStringList;
    s: string;
    i: integer;
    contem: boolean;
begin
    nome := trim(ansiUpperCase (nome));
    contem := false;
    sl := TStringList.Create;
    try
        sl.LoadFromFile(nomeArq);
        i := 0;
        while (i < sl.Count) and (sl[i] <> '') do
            begin
                s := ansiUpperCase(sl[i]);

                if pos ('FROM:', s) = 1 then
                    begin
                        if pos(nome, s) > 5 then
                             begin
                                 contem := true;
                                 break;
                             end;
                    end;

                if pos ('TO:', s) = 1 then
                    begin
                        if pos(nome, s) > 3 then
                             begin
                                 contem := true;
                                 break;
                             end;
                    end;

                i := i + 1;
            end;

    except end;

    sl.Free;
    result := contem;
end;

procedure folhear (ext: string; nome: string);
var
    sr: TSearchRec;
    FileAttrs: Integer;
    item: integer;
    folheando: boolean;
    c1, c2: char;
    x, y: integer;
    arquivoEscolhido: string;
    selec: boolean;
    jaFolheando: boolean;

label deNovo;

begin
    {$i-}  chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
            exit;
        end;

    x := wherex;
    y := wherey;
    jaFolheando := false;

    item := 0;
    repeat
        titulo (false);

        textBackground (MAGENTA);
        if jaFolheando then
            mensagem ('RCCFOLHE', 1)  {'Continue folheando...'}
        else
            begin
                mensagem ('RCFOLHEN', 1);  {'Folheando...'}
                jaFolheando := true;
            end;
        textBackground (BLACK);

        gotoxy(1, 20);
        write ('--------------------------------------------------------------------------------');
        gotoxy (x, y);

        folheiaCria(x, y, 80, 19);    // a escolha por recriar durante a execução
                                      // decorre da possibilidade de haver processamentos
                                      // recursivos de folheamento no processamento das opções
        FileAttrs := faArchive;
        if FindFirst('*.' + ext, FileAttrs, sr) = 0 then
            repeat
                  if nome = '' then
                      folheiaAdiciona(sr.Name)
                  else
                      if arquivoContem (sr.Name, nome) then
                          folheiaAdiciona(sr.Name)
            until FindNext(sr) <> 0;
        FindClose(sr);

        folheando := folheiaExecuta(item, item, c1, c2, false);
        if folheando then
            folheiaObtemItem(item, arquivoEscolhido, selec);

        folheiaDestroi;

        gotoxy (1, 21);
        limpaBaixo;

        if sintFalando then sintPara;

deNovo:
        if folheando then
            if c1 = #$0 then
                begin
                    case c2 of
                        F1: ajudaFolheamento;
                        F9: begin
                                c1 := selSetasOpcaoFolhear;
                                goto deNovo;
                            end;
                        F7: begin
                                apagaRecado (arquivoEscolhido);
                                if item > 0 then item := item - 1;
                            end;
                    end;
                end
            else
            case upcase(c1) of
                ENTER,
                'L': leRecado (arquivoEscolhido);
                'T': editaRecadoTextual (arquivoEscolhido);
                'A': begin
                        apagaRecado (arquivoEscolhido);
                        if item > 0 then item := item - 1;
                     end;
                'R': respondeRecado (arquivoEscolhido);
                'S': salvaSomDoRecado (arquivoEscolhido);
                ESC: folheando := false;
            else
                mensagem ('RCOPINV', 0);   {'Opção inválida, F1 ajuda.'}
            end;
        if folheando then
            sintSom ('RCCNTFOL');    {'Continue folheando...'}

    until not folheando;
end;

{--------------------------------------------------------}

procedure folhearIndividual;
var nome: string;
begin
    {$i-}  chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
            exit;
        end;

    mensagem ('RCINFNOM', 1);  {'Informe algumas letras do nome ou e-mail'}
    sintReadln (nome);
    if trim(nome) = '' then
        begin
            mensagem ('RCDESIST', 1);
            exit;
        end;

    folhear ('*.*', nome);
end;

{--------------------------------------------------------}

procedure ajudaFolheia;
begin
    limpaBaixo;
    writeln;
    mensagem ('RCOPSAO',  1);   {'As opções são:'}
    mensagem ('RCFOLTOD', 1);   {'T - folhear Todos'}
    mensagem ('RCFOLNAO', 1);   {'N - folhear Não lidas'}
    mensagem ('RCFOLIND', 1);   {'I - folhear Individualmente'}
    mensagem ('RCFOLENV', 1);   {'E - folhear recados Enviados'}
    mensagem ('RCFOLPEN', 1);   {'P - folhear recados Pendentes'}
    mensagem ('RCOP_ESC', 2);   {'ESC - terminar'}
end;

{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = 'TNIEP' + #$1b;
begin
    popupMenuCria(wherex, wherey, 50, length(opmenu), RED);
    MenuAdiciona ('RCFOLTOD');   {'T - folhear Todos'}
    MenuAdiciona ('RCFOLNAO');   {'N - folhear Não lidas'}
    MenuAdiciona ('RCFOLIND');   {'I - folhear Individualmente'}
    MenuAdiciona ('RCFOLENV');   {'E - folhear recados Enviados'}
    MenuAdiciona ('RCFOLPEN');   {'P - folhear recados Pendentes'}
    MenuAdiciona ('RCOP_ESC');   {'ESC - terminar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := ' '
    else
        result := opmenu[n];
end;

{--------------------------------------------------------}

procedure folhearRecados;
var
    folheando: boolean;
    c, c2: char;
begin
    recado := TStringList.Create;

    folheando := true;
    repeat
        titulo (false);

        textBackground (BLUE);
        mensagem ('RCOPFOL', 0);   {'O que deseja folhear? '}
        textBackground (BLACK);
        clreol;
        sintLeTecla (c, c2);
        c := upcase(c);
        writeln;
        limpaBaixo;

        if c = #$0 then
            case c2 of
            F1, F9:  begin
                        ajudaFolheia;
                        continue;
                     end;
                CIMA, BAIX: c := selSetasOpcao;
            end;

        case c of
            'T': folhear ('*', '');
            'N': folhear ('REC', '');
            'I': folhearIndividual;
            'E': folhear ('ENV', '');
            'P': folhear ('CPR', '');
            ESC: folheando := false;
        else
            mensagem ('RCOPINV', 1);   {'Opção inválida, F1 ajuda.'}
        end;
    until not folheando;

    recado.Free;
end;

end.

