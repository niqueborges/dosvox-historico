unit mtEfeit;
interface

uses dvWin, dvCrt,
    mtMsg, mtVars,
    sysutils, mmSystem;

function carregaOcorrencias: boolean;
function carregaEfeitos: boolean;
function carregaModelos: boolean;
function escolheEfeito: string;
function escolheModelo: string;
procedure trocarSom;

implementation

var
    numDeOcorrencias, numDeModelos, numDeEfeitos: integer;
    ocorrencia: array [1..200] of string;
    somDoModelo: array [1..200] of string;
    somDoEfeito: array [1..200] of string;

{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{-------------------------------------------------------------}

function maiusc (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := s;
    for i := 1 to length (s) do
        s2 [i] := upcase (s[i]);
    maiusc := s2;
end;

{--------------------------------------------------------}
{Busca trecho à esquerda do sinal de igual
{--------------------------------------------------------}

function esqDoIgual (som: string): string;
begin
    result := copy (som, 1, pos ('=', som) - 1);
end;

{--------------------------------------------------------}
{Busca trecho à direita do sinal de igual
{--------------------------------------------------------}

function dirDoIgual (som: string): string;
begin
    result := maiusc (copy (som, pos ('=', som) + 1, length (som))) + '.WAV';
end;

{--------------------------------------------------------}
{Carrega num vetor as ocorrencias para troca dos modelos ou efeitos
{--------------------------------------------------------}

function carregaOcorrencias: boolean;
var arqEfeitos: text;
    nomeArqEfeitos: string;
    s: string;
begin

    carregaOcorrencias:= false;
    numDeOcorrencias:= 0;

    nomeArqEfeitos := sintAmbiente ('METROVOX', 'ARQEFEITOS');
    if nomeArqEfeitos = '' then
        nomeArqEfeitos := sintDirAmbiente + '\sommetro.ini';

    assign (arqEfeitos, nomeArqEfeitos);
    {$i-} reset (arqEfeitos); {$i+}
    if ioResult <> 0 then
        exit;

    while (not eof(arqEfeitos)) or (numDeOcorrencias = 199) do
        begin
            readln (arqEfeitos, s);
            if (s[1] <> ';') and (s[1] <> '[') then
                begin
                    numDeOcorrencias:= numDeOcorrencias + 1;
                    ocorrencia[numDeocorrencias]:= s;
                end;
        end;

    close (arqEfeitos);

    if numDeOcorrencias > 0 then
    carregaOcorrencias:= true;

end;

{--------------------------------------------------------}
{Carrega num vetor os efeitos
{--------------------------------------------------------}

function carregaEfeitos: boolean;
var i, j: integer;
    s: string;
begin

    carregaEfeitos:= false;
    numDeEfeitos:= 0;

    for i:= 1 to numDeOcorrencias do
        if ocorrencia[i][1] <> '*' then
        begin
            numDeEfeitos:= numDeEfeitos + 1;
            somDoEfeito[numDeEfeitos]:= ocorrencia[i];
        end;

    if numDeEfeitos > 0 then
        carregaEfeitos:= true;

    if numDeEfeitos > 2 then
        begin
                for i:= 1 to numDeEfeitos - 1 do
                for j:= i + 1 to numDeEfeitos do
                    if semAcentos(somDoEfeito[i]) > semAcentos(somDoEfeito[j]) then
                        begin
                            s:= somDoEfeito[i];
                            somDoEfeito[i]:= somDoEfeito[j];
                            somDoEfeito[j]:= s;
                        end;
        end;

end;

{--------------------------------------------------------}
{Carrega num vetor os modelos
{--------------------------------------------------------}

function carregaModelos: boolean;
var i, j: integer;
    s: string;
begin

    carregaModelos:= false;
    numDeModelos:= 0;

    for i:= 1 to numDeOcorrencias do
        if ocorrencia[i][1] = '*' then
        begin
            numDeModelos:= numDeModelos + 1;
            somDoModelo[numDeModelos]:= ocorrencia[i];
            delete (somDoModelo[numDeModelos], 1, 1);
        end;

    if numDeModelos > 0 then
        carregaModelos:= true;

    if numDeModelos > 2 then
        begin
                for i:= 1 to numDeModelos - 1 do
                for j:= i + 1 to numDeModelos do
                    if semAcentos(somDoModelo[i]) > semAcentos(somDoModelo[j]) then
                        begin
                            s:= somDoModelo[i];
                            somDoModelo[i]:= somDoModelo[j];
                            somDoModelo[j]:= s;
                        end;
        end;
end;

{--------------------------------------------------------}
{      Escolhe com as setas o modelo a ser tocado
{--------------------------------------------------------}

function escolheModelo: string;
var c1, c2: char;
    contModelos: integer;
    processando: boolean;
label executa, de_novo;
begin

    contModelos:= 0;
    processando := true;

    de_novo:

    mensagem ('MTESCSET', 1);  {'Escolha com as setas, F1 ajuda'}
    writeln;

    while (processando)  do
       begin

           sintLeTecla (c1, c2);
           write (#$0);

           if (c1 = #0) and (c2 = F1) then
               goto de_novo;

           if (c1 = #0) and (c2 = CIMA) then
                begin
                    contModelos:= contModelos - 1;
                    if contModelos < 1 then
                        begin
                            contModelos:= 0;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDoModelo[contModelos]));
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    contModelos:= contModelos + 1;
                    if contModelos > numDeModelos then
                        begin
                            contModelos:= numDeModelos + 1;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDoModelo[contModelos]));
                end
           else
executa:
               case upcase(c1) of
                   ENTER: begin
                       if (contModelos = 0) or (contModelos = numDeModelos + 1) then
                           begin
                               sintClek;
                               exit;
                           end;
                       escolheModelo:= dirDoIgual (somDoModelo[contModelos]);
                       processando:= false;
                   end;
                   ESC: begin
                       sintClek;
                       exit;
                   end;
               else
                   mensagem ('MTAPTF1', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

{--------------------------------------------------------}
{      Escolhe com as setas o efeito a ser tocado
{--------------------------------------------------------}

function escolheEfeito: string;
var c1, c2: char;
    contEfeitos: integer;
    p: char;
    constaLetra: boolean;
    tocaTeste, ef: string;
    processando: boolean;
label executa, de_novo;
begin

    contEfeitos:= 0;
    constaLetra:= false;
    p:= '-';
    processando := true;

    mensagem ('MTESCSET', 1);  {'Escolha com as setas, F1 ajuda'}
    writeln;

    while (processando)  do
       begin

           sintLeTecla (c1, c2);
           write (#$0);

           de_novo:

           if upcase(c1) in ['A'..'Z'] then
           begin
                   contEfeitos:= contEfeitos + 1;
                   for contEfeitos:= contEfeitos to numDeEfeitos do
                   begin
                       if semAcentos(upcase(c1)) = semAcentos(
                                             maiusc(copy (somDoEfeito[contEfeitos], 1, 1))) then
                       begin
                           constaLetra:= true;
                           p:= c1; //Atender CTLF5, anteriormente implementada
                           sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
                           break;
                       end
                       else
                           constaLetra:= false;
                   end; //Final do FOR
           if p = '-' then
           begin
               writeln;
               mensagem ('MTNAOINI', 1); {'Não consta arquivo com essa inicial'}
               exit;
           end;
           if (not constaLetra) or (numDeEfeitos < contEfeitos) then
           begin
               contEfeitos:= 0;
               p:= '-';
               goto de_novo;
           end;
           end
           else
           if (c1 = #0) and (c2 = CIMA) then
                begin
                    contEfeitos:= contEfeitos - 1;
                    if contEfeitos < 1 then
                        begin
                            contEfeitos:= 0;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    contEfeitos:= contEfeitos + 1;
                    if contEfeitos > numDeEfeitos then
                        begin
                            contEfeitos:= numDeEfeitos + 1;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = HOME) then
                begin
                    contEfeitos:= 1;
                    sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = TEND) then
                begin
                contEfeitos:= numDeEfeitos;
                        sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = PGUP) then
               begin
                   contEfeitos:= contEfeitos - 5;
                   if contEfeitos < 1 then
                       contEfeitos:= 1;
                   sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
               end
           else
           if (c1 = #0) and (c2 = PGDN) then
               begin
                   contEfeitos:= contEfeitos + 5;
                   if contEfeitos > numDeEfeitos then
                       contEfeitos:= numDeEfeitos;
                   sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
               end
           else
           if (c1 = #0) and (c2 = F1) then
               begin
                   mensagem ('MTENV1', 1);  {'F5, busca efeito'}
                   mensagem ('MTENV2', 1);  {'CTRL+F5, busca de novo'}
                   mensagem ('MTENV3', 1);  {'PGUP, anda 5 na fila'}
                   mensagem ('MTENV4', 1);  {'PGDN, volta 5 na fila'}
                   mensagem ('MTENV5', 1);  {'HOME, vai para o início da fila'}
                   mensagem ('MTENV6', 1);  {'END, vai para o final da fila'}
                   mensagem ('MTENV7', 1);  {'CTRL+ENTER, Testa o som a ser tocado'}
               end
           else
           if (c1 = #0) and (c2 = F5) then
               begin
                   writeln;
                   mensagem ('MTBUSEFE', 0);   {'Digite uma letra: '}
                   p := upcase(sintReadkey);
                   if not (p in ['A'..'Z']) then exit;

                   for contEfeitos:= 1 to numDeEfeitos do
                       begin
                           ef := somDoEfeito[contEfeitos];
                           if semAcentos(p) = semAcentos(maiusc(copy (ef, 1, 1))) then
                               break;
                       end;
                   sintWriteln (copy (ef, 1, pos ('=', ef) - 1 ));
               end
           else
           if (c1 = #0) and (c2 = CTLF5) then
               begin
                   if p = '-' then
                       exit;
                   contEfeitos:= contEfeitos + 1;
                   for contEfeitos:= contEfeitos to numDeEfeitos do
                       if semAcentos(upcase(p)) = semAcentos(maiusc(copy (somDoEfeito[contEfeitos], 1, 1))) then
                           break;
                   sintWriteln (esqDoIgual (somDoEfeito[contEfeitos]));
               end
           else
executa:
               case upcase(c1) of
                   #10: begin
                       tocaTeste:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' + dirDoIgual (somDoEfeito[contEfeitos]);
                       sndPlaySound (@tocaTeste[1], snd_sync);
                   end;
                   ENTER: begin
                       if (contEfeitos = 0) or (contEfeitos = numDeEfeitos + 1) then
                           begin
                               sintClek;
                               exit;
                           end;
                       escolheEfeito:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' + dirDoIgual (somDoEfeito[contEfeitos]);
                       processando:= false;
                   end;
                   ESC: begin
                       sintClek;
                       exit;
                   end;
               else
                   mensagem ('MTAPTF1', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

{--------------------------------------------------------}
{Troca efeitos: tempo/compasso
{--------------------------------------------------------}

procedure trocarSom;
var modelo: string;
    somTempoBk, somCompassoBk: string;
begin

    somTempoBk:= somTempo;
    somCompassoBk:= somCompasso;

    if usarModelos then
    begin
        mensagem ('MTTRMO', 1); {'Informe o novo modelo : '}
        modelo:= escolheModelo;

        if modelo = '' then
        begin
            somTempo:= somTempoBk;
            somCompasso:= somCompassoBk;
            exit;
        end;

        somTempo:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' +
          maiusc (copy (modelo, 1, pos ('/', modelo) - 1) + '.WAV');
        somCompasso:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' +
          maiusc (copy (modelo, pos ('/', modelo) + 1, length (modelo)));

        exit;
    end;

    mensagem ('MTTRTM', 1); {'Informe o novo efeito para a marcação do tempo : '}
    somTempo:= escolheEfeito;
    if somTempo = '' then
        somTempo:= somTempoBk;

    mensagem ('MTTRCO', 1); {'Informe o novo efeito para a marcação do compasso : '}
    somCompasso:= escolheEfeito;
    if somCompasso = '' then
        somCompasso:= somCompassoBk;

end;

end.
