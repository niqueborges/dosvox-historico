unit mgEfeito;

interface

uses windows, messages, sysutils, mmsystem,
     dvcrt, dvwin, dvform, dvarq, dvwav,mgefeitoSox,
     mgMsg, mgArquivo, mgVars, grAmost, mgRemove, mgToca, mgMistura, ShellApi;

procedure menuEfeito;
procedure fadeIn;
procedure fadeInTrecho;
procedure fadeOut;
procedure fadeOutTrecho;
procedure desceVolume;
procedure desceVolumeTrecho;
procedure diminuiVolume;
procedure diminuiVolumeTrecho;
procedure aumentaVolume;
procedure aumentaVolumeTrecho;
procedure sobeVolume;
procedure sobeVolumeTrecho;
procedure sobeVolumeAlto1;
procedure sobeVolumeAlto1Trecho;
procedure sobeVolumeAlto2;
procedure sobeVolumeAlto2Trecho;
procedure sobeVolumeAlto3;
procedure sobeVolumeAlto3Trecho;
procedure sobeVolumeAlto4;
procedure sobeVolumeAlto4Trecho;
procedure sobeVolumeAlto5;
procedure sobeVolumeAlto5Trecho;
procedure sobeVolumeAlto6;
procedure sobeVolumeAlto6Trecho;
procedure sobeVolumeAlto7;
procedure sobeVolumeAlto7Trecho;
procedure sobeVolumeAlto8;
procedure sobeVolumeAlto8Trecho;
procedure sobeVolumeAlto9;
procedure sobeVolumeAlto9Trecho;
procedure aplicaSenha;
procedure fazCopia (nomeArq: string);
procedure extraiTrechoMarcado (nomeArq: string);
procedure ajudaEfeito;
procedure MenuAdiciona (msg: string);
function selSetasEfeitos: char;

implementation

{--------------------------------------------------------}
{        Executa o efeito passado como parâmetro
{--------------------------------------------------------}

procedure SalvaTemporario;
var
    c: char;
begin
    mensagem('MGSALVARA',1); {  'Deseja manter o efeito?(S/N)'  }
    mensagem('MGREPETE',1); {  'R - Repete'  }
        repeat
            c := Readkey;
            case upcase(c) of
                ESC,'N':
                begin
                    mensagem('MGNAO',2); {  Não  }
                    som.leArquivo(arqTemp1);
                end;

                'R', ' ':
                begin
    while sintFalando do waitMessage;
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    som.tocaTudo;
    mensagem('MGSALVARA',1); {  'Deseja manter o efeito?(S/N)'  }
    mensagem('MGREPETE',1); {  'R - Repete'  }
    end;

                'S', ENTER:
                        mensagem('MGSIM',2); {  Sim  }
            end;
        until (upcase(c) = 'N') or (upcase(c) = 'S') or (upcase(c) = ESC) or (upcase(c) = ENTER) or (c = 'R') or (c = ' ');
    limpaBaixo(8);
end;

{--------------------------------------------------------}

procedure fadeIn;
var inicio, fim: integer;
begin
    inicio := 0;
    fim := cursor;

    som.rampa (inicio, fim, 0.0, 1.0);

    mensagem ('MGFADEINA', 1);  {'FadeIn adicionado'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure fadeInTrecho;
var inicio, fim: integer;
begin
    inicio := marca;
    fim := cursor;

    som.rampa (inicio, fim, 0.0, 1.0);

    mensagem ('MGFADEINA', 1);  {'FadeIn adicionado'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure fadeOut;
var inicio, fim: integer;
begin
    inicio := cursor;
    fim := som.numAmostras-1;

    som.rampa (inicio, fim, 1.0, 0.0);
    mensagem ('MGFADEOUT', 1);  {'FadeOut adicionado'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure fadeOutTrecho;
var inicio, fim: integer;
begin
    inicio := marca;
    fim := cursor-1;

    som.rampa (inicio, fim, 1.0, 0.0);
    mensagem ('MGFADEOUT', 1);  {'FadeOut adicionado'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure adicionaEco;
var
    a, b: TStereo16;
    i, n, dist: integer;
    fator1_eco, fator2_eco: real;

begin
    fator1_eco := fator_eco / 100.0;
    fator2_eco := 1.0 - fator1_eco;

    with som do
        begin
            dist := (velocidade div 11025) * dist_eco;
            n := numAmostras+dist;
            amostra [n-1] := SILENCIO;   // precria area de silencio no fim
            for i := n-1 downto 0 do
                begin
                     a := amostra[i];
                     b := amostra [i-dist];
                     // nota: o objeto som retorna silêncio para acessos a índices < 0
                     a.left  := trunc(a.left  * fator1_eco) + trunc(b.left  * fator2_eco);
                     a.right := trunc(a.right * fator1_eco) + trunc(b.right * fator2_eco);
                     amostra[i] := a;
                end;
        end;

    mensagem ('MGECO', 1);  {'Eco adicionado'  }
    mensagem ('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure adicionaEcoTrecho;
var
    a, b: TStereo16;
    i, n, dist: integer;
    fator1_eco, fator2_eco: real;

begin
    fator1_eco := fator_eco / 100.0;
    fator2_eco := 1.0 - fator1_eco;

    with som do
        begin
            dist := (velocidade div 11025) * dist_eco;
            n := numAmostras+dist;
            amostra [n-1] := SILENCIO;   // precria area de silencio no fim
            for i := cursor-1 downto marca do
                begin
                     a := amostra[i];
                     b := amostra [i-dist];
                     // nota: o objeto som retorna silêncio para acessos a índices < 0
                     a.left  := trunc(a.left  * fator1_eco) + trunc(b.left  * fator2_eco);
                     a.right := trunc(a.right * fator1_eco) + trunc(b.right * fator2_eco);
                     amostra[i] := a;
                end;
        end;

    mensagem ('MGECO', 1);  {'Eco adicionado'  }
    mensagem ('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure adicionaReverber;
var
    a, b: TStereo16;
    i, n, dist: integer;
    fator1_reverb, fator2_reverb: real;

begin
    fator1_reverb := fator_reverb / 100.0;
    fator2_reverb := 1.0 - fator1_reverb;
    with som do
        begin
            dist := (velocidade div 11025) * dist_reverb;
            n := numAmostras+dist;
            amostra [n-1] := SILENCIO;   // precria area de silencio no fim
            for i := 0 to n-1 do
                begin
                     a := amostra[i];
                     b := amostra [i-dist];
                     a.left  := trunc(a.left  * fator1_reverb) + trunc(b.left  * fator2_reverb);
                     a.right := trunc(a.right * fator1_reverb) + trunc(b.right * fator2_reverb);
                     amostra[i] := a;
                end;
        end;

    mensagem ('MGREV', 1);  {'Reverberação adicionada'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure adicionaReverberTrecho;
var
    a, b: TStereo16;
    i, n, dist: integer;
    fator1_reverb, fator2_reverb: real;

begin
    fator1_reverb := fator_reverb / 100.0;
    fator2_reverb := 1.0 - fator1_reverb;
    with som do
        begin
            dist := (velocidade div 11025) * dist_reverb;
            n := numAmostras+dist;
            amostra [n-1] := SILENCIO;   // precria area de silencio no fim
            for i := marca to cursor-1 do
                begin
                     a := amostra[i];
                     b := amostra [i-dist];
                     a.left  := trunc(a.left  * fator1_reverb) + trunc(b.left  * fator2_reverb);
                     a.right := trunc(a.right * fator1_reverb) + trunc(b.right * fator2_reverb);
                     amostra[i] := a;
                end;
        end;

    mensagem ('MGREV', 1);  {'Reverberação adicionada'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure desceVolume;
begin
    som.rampa(0, som.numAmostras-1, 0.75, 0.75);
    mensagem ('MGVOLDIM', 1);  {'Diminuí o volume em 25 por cento'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure desceVolumeTrecho;
begin
    som.rampa(marca, cursor-1, 0.75, 0.75);
    mensagem ('MGVOLDIM', 1);  {'Diminuí o volume em 25 por cento'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure diminuiVolume;
var c: char;
label denovo;
begin
    mensagem('MGDIMINU',1);  {'Diminuindo o volume'  }

begin
repeat
denovo:
    mensagem('MGQVOLDI',1);  {'Qual o volume a diminuir de 1 a9?'  }
    c := sintreadkey;
//    sintCarac (c);
        writeln (c);

    if not (upCase(c) in['1'..'9', ESC]) then
    goto denovo;
    until (upCase(c) in['1'..'9', ESC]);

    if upCase(c) = '' then exit;

    if upCase(c) = ESC then exit;

    if (upCase(c) in['1'..'9']) then
        begin

if c = '1' then
    som.rampa(0, som.numAmostras-1, 0.10, 0.10);
if c = '2' then
    som.rampa(0, som.numAmostras-1, 0.20, 0.20);
if c = '3' then
    som.rampa(0, som.numAmostras-1, 0.30, 0.30);
if c = '4' then
    som.rampa(0, som.numAmostras-1, 0.40, 0.40);
if c = '5' then
    som.rampa(0, som.numAmostras-1, 0.50, 0.50);
if c = '6' then
    som.rampa(0, som.numAmostras-1, 0.60, 0.60);
if c = '7' then
    som.rampa(0, som.numAmostras-1, 0.70, 0.70);
if c = '8' then
    som.rampa(0, som.numAmostras-1, 0.80, 0.80);
if c = '9' then
    som.rampa(0, som.numAmostras-1, 0.90, 0.90);

    mensagem ('MGVOLDI_', 1);  {'Diminuí o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
          exit;
        end;

    if not (upCase(c) in['1'..'9']) then
//          exit;

goto denovo;
end;
end;

{--------------------------------------------------------}

procedure diminuiVolumeTrecho;
var c: char;
label denovo;
begin
    mensagem('MGDIMINU',1);  {'Diminuindo o volume'  }

begin
repeat
denovo:
    mensagem('MGQVOLDI',1);  {'Qual o volume a diminuir de 1 a9'  }
    c := sintreadkey;
//    sintCarac (c);
        writeln (c);

    if not (upCase(c) in['1'..'9', ESC]) then
    goto denovo;
    until (upCase(c) in['1'..'9', ESC]);

    if upCase(c) = '' then exit;

    if upCase(c) = ESC then exit;

    if (upCase(c) in['1'..'9']) then
        begin

if c = '1' then
    som.rampa(marca, cursor-1, 0.10, 0.10);
if c = '2' then
    som.rampa(marca, cursor-1, 0.20, 0.20);
if c = '3' then
    som.rampa(marca, cursor-1, 0.30, 0.30);
if c = '4' then
    som.rampa(marca, cursor-1, 0.40, 0.40);
if c = '5' then
    som.rampa(marca, cursor-1, 0.50, 0.50);
if c = '6' then
    som.rampa(marca, cursor-1, 0.60, 0.60);
if c = '7' then
    som.rampa(marca, cursor-1, 0.70, 0.70);
if c = '8' then
    som.rampa(marca, cursor-1, 0.80, 0.80);
if c = '9' then
    som.rampa(marca, cursor-1, 0.90, 0.90);

    mensagem ('MGVOLDI_', 1);  {'Diminuí o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
          exit;
        end;

    if not (upCase(c) in['1'..'9']) then
//          exit;

goto denovo;
end;
end;

{--------------------------------------------------------}

procedure aumentaVolume;
var c: char;
label denovo;
begin
    mensagem('MGAUMENT',1);  {'Aumentando o volume'  }

begin
repeat
denovo:
    mensagem('MGQVOLAU',1);  {'Qual o volume a aumentar de 1 a9'  }
    c := sintreadkey;
//    sintCarac (c);
        writeln (c);

    if not (upCase(c) in['1'..'9', ESC]) then
    goto denovo;
    until (upCase(c) in['1'..'9', ESC]);

    if upCase(c) = '' then exit;

    if upCase(c) = ESC then exit;

    if (upCase(c) in['1'..'9']) then
        begin

if c = '1' then
    som.rampa(0, som.numAmostras-1, 1.75, 1.75);
if c = '2' then
    som.rampa(0, som.numAmostras-1, 2.75, 2.75);
if c = '3' then
    som.rampa(0, som.numAmostras-1, 3.75, 3.75);
if c = '4' then
    som.rampa(0, som.numAmostras-1, 4.75, 4.75);
if c = '5' then
    som.rampa(0, som.numAmostras-1, 5.75, 5.75);
if c = '6' then
    som.rampa(0, som.numAmostras-1, 6.75, 6.75);
if c = '7' then
    som.rampa(0, som.numAmostras-1, 7.75, 7.75);
if c = '8' then
    som.rampa(0, som.numAmostras-1, 8.75, 8.75);
if c = '9' then
    som.rampa(0, som.numAmostras-1, 9.75, 9.75);

    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
          exit;
        end;

    if not (upCase(c) in['1'..'9']) then
//          exit;

goto denovo;
end;
end;

{--------------------------------------------------------}

procedure aumentaVolumeTrecho;
var c: char;
label denovo;
begin
    mensagem('MGAUMENT',1);  {'Aumentando o volume'  }

begin
repeat
denovo:
    mensagem('MGQVOLAU',1);  {'Qual o volume a aumentar de 1 a9'  }
    c := sintreadkey;
//    sintCarac (c);
        writeln (c);

    if not (upCase(c) in['1'..'9', ESC]) then
    goto denovo;
    until (upCase(c) in['1'..'9', ESC]);

    if upCase(c) = '' then exit;

    if upCase(c) = ESC then exit;

    if (upCase(c) in['1'..'9']) then
        begin

if c = '1' then
    som.rampa(marca, cursor-1, 1.75, 1.75);
if c = '2' then
    som.rampa(marca, cursor-1, 2.75, 2.75);
if c = '3' then
    som.rampa(marca, cursor-1, 3.75, 3.75);
if c = '4' then
    som.rampa(marca, cursor-1, 4.75, 4.75);
if c = '5' then
    som.rampa(marca, cursor-1, 5.75, 5.75);
if c = '6' then
    som.rampa(marca, cursor-1, 6.75, 6.75);
if c = '7' then
    som.rampa(marca, cursor-1, 7.75, 7.75);
if c = '8' then
    som.rampa(marca, cursor-1, 8.75, 8.75);
if c = '9' then
    som.rampa(marca, cursor-1, 9.75, 9.75);

    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
          exit;
        end;

    if not (upCase(c) in['1'..'9']) then
//          exit;

goto denovo;
end;
end;

{--------------------------------------------------------}

procedure sobeVolume;
begin
    som.rampa(0, som.numAmostras-1, 1.25, 1.25);
    mensagem ('MGVOLAUM', 1);  {'Aumentei o volume em 25 por cento'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeTrecho;
begin
    som.rampa(marca, cursor-1, 1.25, 1.25);
    mensagem ('MGVOLAUM', 1);  {'Aumentei o volume em 25 por cento'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto1;
begin
    som.rampa(0, som.numAmostras-1, 1.75, 1.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto1Trecho;
begin
    som.rampa(marca, cursor-1, 1.75, 1.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto2;
begin
    som.rampa(0, som.numAmostras-1, 2.75, 2.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto2Trecho;
begin
    som.rampa(marca, cursor-1, 2.75, 2.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto3;
begin
    som.rampa(0, som.numAmostras-1, 3.75, 3.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto3Trecho;
begin
    som.rampa(marca, cursor-1, 3.75, 3.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto4;
begin
    som.rampa(0, som.numAmostras-1, 4.75, 4.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto4Trecho;
begin
    som.rampa(marca, cursor-1, 4.75, 4.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto5;
begin
    som.rampa(0, som.numAmostras-1, 5.75, 5.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto5Trecho;
begin
    som.rampa(marca, cursor-1, 5.75, 5.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto6;
begin
    som.rampa(0, som.numAmostras-1, 6.75, 6.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto6Trecho;
begin
    som.rampa(marca, cursor-1, 6.75, 6.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto7;
begin
    som.rampa(0, som.numAmostras-1, 7.75, 7.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto7Trecho;
begin
    som.rampa(marca, cursor-1, 7.75, 7.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto8;
begin
    som.rampa(0, som.numAmostras-1, 8.75, 8.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto8Trecho;
begin
    som.rampa(marca, cursor-1, 8.75, 8.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto9;
begin
    som.rampa(0, som.numAmostras-1, 9.75, 9.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure sobeVolumeAlto9Trecho;
begin
    som.rampa(marca, cursor-1, 9.75, 9.75);
    mensagem ('MGVOLAU_', 1);  {'Aumentei o volume'  }
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;
    som.tocaTudo;
    SalvaTemporario;
end;

{--------------------------------------------------------}

procedure aplicaSenha;
var i: integer;
    a: TStereo16;
    senha: array [0..255] of byte;
    salva: word;
    x: smallInt;
    s: string;
    erro: integer;
begin
    mensagem ('MGDIGSEN', 0);   {'Digite a senha com 6 digitos: '  }
    salva := textAttr;
    textAttr := 0;
    readln (s);
    textAttr := salva;

    if s = '' then
        begin
            mensagem ('MGDESIST', 1);  {'Desistiu'  }
            exit;
        end;

    val (s, x, erro);

    senha[0] := 17 xor (x and 255) xor ((x shr 5) and 255);
    for i := 1 to 255 do
        senha [i] := (senha[i-1] * 13 + 89) mod 255;

    with som do
        begin
            for i := 0 to numAmostras-1 do
                begin
                     a := amostra[i];
                     x := smallInt (word (senha[i and $ff]) shl 8);
                     a.left   := a.left  xor x;
                     a.right  := a.right xor x;
                     amostra[i] := a;
                end;
        end;

    mensagem ('MGSENHAP', 1);  {'Senha aplicada'  }
end;

{--------------------------------------------------------}

procedure undo1;
begin
    som.leArquivo(nomeArq);
end;

{--------------------------------------------------------}

procedure fazCopia (nomeArq: string);
var t, c, c2: char;
    nomeNovo: string;
    som2: TAmostras;
    pnome: array [0..255] of char;
var aRemover, cursor1: integer;

label desistiu, salvamentoMP3;
begin
cursor := som.numAmostras;
cursor1 := cursor;
marca := 0;
    aRemover := abs (som.numAmostras - cursor);
    if cursor < som.numAmostras then
    else
        cursor := som.numAmostras;
    som.removeTrecho(cursor, aRemover);

cursor := 0;

    aRemover := abs (marca - cursor);
    if cursor < marca then
        marca := cursor
    else
        cursor := marca;
    som.removeTrecho(cursor, aRemover);

cursor := cursor1;

    som2 := NIL;
    nomeNovo := nomeArq;

    mensagem ('MGNOMCOP', 1);            {'Informe o novo da cópia: '  }
    garanteEspacoTela(2);
    c := sintEdita (nomeNovo, wherex, wherey, 255, true);
    writeln;
    if (c = ESC) or (nomeNovo = '') then goto desistiu;

    if (maiuscAnsi (copy (nomeNovo, length (nomeNovo)-3, 4)) = '.MP3') or
                                   (pos ('.', nomeNovo) = 0) then
         nomeNovo:= nomeNovo + '.wav';

    mensagem ('MGRADTLF', 0);  {'Qualidade CD, rádio ou telefone ? '  }
    sintLeTecla (t, c2);
    writeln;
    if t = ESC then exit;

    mensagem ('MGSTMONO', 0);  {'Estéreo ou Mono? '  }
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then goto desistiu;

    som2:= TAmostras.Create;
    case upcase(t) of
        'C':  begin
                  som2.reAmostra (som, rAmostra);
                  som2.bitsPorAmostra := 16;
              end;
        'T':  begin
                  som2.reAmostra (som, 11025);
                  som2.bitsPorAmostra := 8;
              end;
        else
              begin
                  som2.reAmostra (som, 22050);
                  som2.bitsPorAmostra := 16;
              end;
    end;

    if upcase (c) in ['E', 'S'] then
        som2.canais := 2
    else
        som2.canais := 1;

    som.Free;
    som := som2;
    som2 := NIL;

    if not som.gravaArquivo(nomeNovo) then
        begin
            mensagem ('MGERRGRV', 1);      {'Erro de gravação'  }
            exit;
        end
    else
        nomeArq := nomeNovo;

    mensagem ('MGARQSLV', 2);       {'OK, arquivo salvo'  }
undo1;
    strPCopy (pnome, 'MINIGRAV ' + nomeArq);
    setWindowText (crtWindow, pnome);

salvamentoMP3:
    veSeSalvaMP3 (nomeNovo);
    exit;

desistiu:
    if som2 <> NIL then som2.free;
    mensagem ('MGDESIST', 1);        {'Desistiu'  }
end;

{--------------------------------------------------------}

procedure extraiTrechoMarcado (nomeArq: string);
var t, c, c2: char;
    nomeNovo: string;
    som2: TAmostras;
    pnome: array [0..255] of char;
var aRemover, cursor1: integer;

label desistiu, salvamentoMP3;
begin
cursor1 := cursor;
    aRemover := abs (som.numAmostras - cursor);
    if cursor < som.numAmostras then
    else
        cursor := som.numAmostras;
    som.removeTrecho(cursor, aRemover);

cursor := 0;

    aRemover := abs (marca - cursor);
    if cursor < marca then
        marca := cursor
    else
        cursor := marca;
    som.removeTrecho(cursor, aRemover);

cursor := cursor1;

    som2 := NIL;
    nomeNovo := nomeArq;

    mensagem ('MGNOMTRE', 1);            {'Informe o nome do trecho a extrair: '  }
    garanteEspacoTela(2);
    c := sintEdita (nomeNovo, wherex, wherey, 255, true);
    writeln;
    if (c = ESC) or (nomeNovo = '') then goto desistiu;

    if (maiuscAnsi (copy (nomeNovo, length (nomeNovo)-3, 4)) = '.MP3') or
                                   (pos ('.', nomeNovo) = 0) then
         nomeNovo:= nomeNovo + '.wav';

    mensagem ('MGRADTLF', 0);  {'Qualidade CD, rádio ou telefone ? '  }
    sintLeTecla (t, c2);
    writeln;
    if t = ESC then exit;

    mensagem ('MGSTMONO', 0);  {'Estéreo ou Mono? '  }
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then goto desistiu;

    som2:= TAmostras.Create;
    case upcase(t) of
        'C':  begin
                  som2.reAmostra (som, rAmostra);
                  som2.bitsPorAmostra := 16;
              end;
        'T':  begin
                  som2.reAmostra (som, 11025);
                  som2.bitsPorAmostra := 8;
              end;
        else
              begin
                  som2.reAmostra (som, 22050);
                  som2.bitsPorAmostra := 16;
              end;
    end;

    if upcase (c) in ['E', 'S'] then
        som2.canais := 2
    else
        som2.canais := 1;

    som.Free;
    som := som2;
    som2 := NIL;

    if not som.gravaArquivo(nomeNovo) then
        begin
            mensagem ('MGERRGRV', 1);      {'Erro de gravação'  }
            exit;
        end
    else
        nomeArq := nomeNovo;

    mensagem ('MGARQSLV', 2);       {'OK, arquivo salvo'  }
undo1;
    strPCopy (pnome, 'MINIGRAV ' + nomeArq);
    setWindowText (crtWindow, pnome);

salvamentoMP3:
    veSeSalvaMP3 (nomeNovo);
    exit;

desistiu:
    if som2 <> NIL then som2.free;
    mensagem ('MGDESIST', 1);        {'Desistiu'  }
end;

{--------------------------------------------------------}

procedure undo;
var c, c2: char;
begin
    mensagem ('MGCNFUND', 0);   {'Vou recuperar a última versão salva, confirma? '  }
    sintLeTecla (c, c2);
    writeln;
    if upcase (c) <> 'S' then exit;

    som.leArquivo(nomeArq);
    mensagem ('MGUNDO', 1);  {'Voltei ao último arquivo gravado'  }
end;

{--------------------------------------------------------}

procedure ajudaEfeito;
begin
    textBackground (RED);
    mensagem ('MGASOPC',2); {'As opções são:'  }
    textBackground (BLACK);
    writeln;

    mensagem ('MGVOLSOB', 1);  {'+ - Aumenta Volume'  }
    mensagem ('MGVOLDES', 1);  {'- - Diminui volume'  }
    mensagem ('MGFADEIN', 1);  {'I - Fade In'  }
    mensagem ('MGFADEOU', 1);  {'O - Fade Out'  }
    mensagem ('MGCODSEN', 1);  {'P - Codifica com senha}
    mensagem ('MGOPECO',  1);  {'E - Ecoa'  }
    mensagem ('MGOPCXE',  1);  {'X - Super Eco'  }
    mensagem ('MGOPREV',  1);  {'R - Reverbera'  }
    mensagem ('MGOPSREV', 1);  {'S - Super Reverber'  }
    mensagem ('MGVOLTSO', 1);  {'T - Inverte o som'  }
    mensagem ('MGTREBL',  1);  {'A - Agudos'  }
    mensagem ('MG_BASS',  1);  {'G - Graves'  }
    mensagem ('MGSPEED',  1);  {'V - Altera a velocidade e afinação'  }
    mensagem ('MGSTRETCH',  1);  {'W - Altera a velocidade sem mexer na afinação, Stretch'  }
    mensagem ('MGTEMPO',  1);  {'J - Altera a velocidade sem mexer na afinação, Tempo'  }
    mensagem ('MGTREMOL',  1);  {'Y - Adiciona vibrato, até 13000'  }
    mensagem ('MGPITCH',  1);  {'F - Altera a afinação sem mexer na velocidade'  }
    mensagem ('MGOPCEQ',  1);  {'Q - Equalização por faixas'  }
    mensagem ('MG_NORM',  1);  {'N - Normaliza Volume'  }
    mensagem ('MGCAUMEN',1);  {'C - Aumenta o volume'  }
    mensagem ('MGBDIMIN',1);  {'B - Diminui o volume'  }
    mensagem ('MGFAZCOP', 1);  {'H - Faz cópia'  }
    mensagem ('MGKATELE', 1);  {'K - Telefone'  }
    mensagem ('MGFLANGE', 1);  {'L - Flanger'  }
    mensagem ('MGDESFAZ', 1);  {'D - Desfaz'  }
    mensagem ('MGCHORUS', 1);  {'U - Chorus'  }
    mensagem ('MGVOLSTM', 1);  {'= - Aumenta Volume do trecho marcado'  }
    mensagem ('MGVOLDTM', 1);  {'_ - Diminui volume do trecho marcado'  }
    mensagem ('MGFADETM', 1);  {'SHIFT+I - Fade In do trecho marcado'  }
    mensagem ('MGFADOTM', 1);  {'SHIFT+O - Fade Out do trecho marcado'  }
    mensagem ('MGOPECTM',  1);  {'SHIFT+E - Ecoa o trecho marcado'  }
    mensagem ('MGOPRETM',  1);  {'SHIFT+R - Reverbera o trecho marcado'  }
    mensagem ('MGCAUMTM',1);  {'SHIFT+V - Aumenta o volume do trecho marcado'  }
    mensagem ('MGBDIMTM',1);  {'SHIFT+B - Diminui o volume do trecho marcado'  }
    mensagem ('MGEXTMAR', 1);  {'SHIFT+H - Extrai trecho marcado'  }
    mensagem ('MGTOCAEF', 1);   {'SHIFT+T - Toca'  }
    mensagem ('MGREMOEF', 1); {'SHIFT-A - Remove'  }
    mensagem ('MGMIEF', 1);   {'SHIFT+M - Mistura'  }
    mensagem ('MGVOLCTM', 1);  {'CTRL+V - Aumenta Volume'  }
    mensagem ('MGVOLBTM', 1);  {'CTRL+B - Diminui volume'  }

end;

{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
        popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasEfeitos: char;
var
    n, totalOpcoes: integer;
    tabLetrasOpcao: string;

const
    nopc = 40;
    nopc2 = 25;  //Sem efeitos dependentes do sox
    tabLetrasOpcoes: string [nopc] = '+-iopexrstagvwjyfqncbhkldu=_IOERVBHTAMzZ';
    tabLetrasOpcoes2 : string [nopc2] = '+-iopercbhd=_IOERVBHTAMzZ';  //Efeitos não dependentes do sox

begin
    if sox_existe = false then
        begin
        totalOpcoes := nopc2;
        tabLetrasOpcao := tabLetrasOpcoes2;
    end
    else
        begin
        totalOpcoes := nopc;
        tabLetrasOpcao := tabLetrasOpcoes;
    end;
    garanteEspacoTela(totalOpcoes);

    popupMenuCria (wherex, wherey, 27, totalOpcoes, MAGENTA);

    menuAdiciona ('MGVOLSOB');    {'+ - Aumenta Volume'  }
    menuAdiciona ('MGVOLDES');    {'- - Diminui volume'  }
    menuAdiciona ('MGFADEIN');    {'I - Fade In'  }
    menuAdiciona ('MGFADEOU');    {'O - Fade Out'  }
    menuAdiciona ('MGCODSEN');    {'P - Codifica com senha}
    menuAdiciona ('MGOPECO');     {'E - Ecoa'  }
    if sox_existe then menuAdiciona ('MGOPCXE');     {'X - Super Eco'  }
    menuAdiciona ('MGOPREV');     {'R - Reverber'  }
    if sox_existe then menuAdiciona ('MGOPSREV');    {'S - Super Reverber'  }
    if sox_existe then menuAdiciona ('MGVOLTSO');    {'T - Inverte o som'  }
    if sox_existe then menuAdiciona ('MGTREBL');     {'A - Agudos'  }
    if sox_existe then menuAdiciona ('MG_BASS');     {'G - Graves'  }
    if sox_existe then menuAdiciona ('MGSPEED');     {'V - Altera a velocidade e afinação'  }
    if sox_existe then menuAdiciona ('MGSTRETCH');     {'W - Altera a velocidade sem mexer na afinação, Stretch'  }
    if sox_existe then menuAdiciona ('MGTEMPO');     {'J - Altera a velocidade sem mexer na afinação, Tempo'  }
    if sox_existe then menuAdiciona ('MGTREMOL');     {'Y - Adiciona vibrato, até 13000'  }
    if sox_existe then menuAdiciona ('MGPITCH');     {'F - Altera a afinação sem mexer na velocidade'  }
    if sox_existe then menuAdiciona ('MGOPCEQ');     {'Q - Equalização por faixas'    }
    if sox_existe then menuAdiciona ('MG_NORM');     {'N - Normaliza Volume'  }
    menuAdiciona ('MGCAUMEN');     {'C - Aumenta o volume'  }
    menuAdiciona ('MGBDIMIN');     {'B - Diminui o volume'  }
    menuAdiciona ('MGFAZCOP');     {'H - Faz cópia'  }
    if sox_existe then menuAdiciona ('MGKATELE');    {'K - Telefone'  }
    if sox_existe then menuAdiciona ('MGFLANGL');    {'L - Flanger'  }
    menuAdiciona ('MGDESFAZ');     {'D - Desfaz'  }
    if sox_existe then menuAdiciona ('MGCHORUS');     {'U - Chorus'  }
    menuAdiciona ('MGVOLSTM');    {'= - Aumenta Volume do trecho marcado'  }
    menuAdiciona ('MGVOLDTM');    {'_ - Diminui volume do trecho marcado'  }
    menuAdiciona ('MGFADETM');    {'SHIFT+I - Fade In do trecho marcado'  }
    menuAdiciona ('MGFADOTM');    {'SHIFT+O - Fade Out do trecho marcado'  }
    menuAdiciona ('MGOPECTM');     {'SHIFT+E - Ecoa o trecho marcado'  }
    menuAdiciona ('MGOPRETM');     {'SHIFT+R - Reverbera o trecho marcado'  }
    menuAdiciona ('MGCAUMTM');     {'SHIFT+V - Aumenta o volume do trecho marcado'  }
    menuAdiciona ('MGBDIMTM');     {'SHIFT+B - Diminui o volume do trecho marcado'  }
    menuAdiciona ('MGEXTMAR');     {'SHIFT+H - Extrai trecho marcado'  }
    menuAdiciona ('MGTOCAEF');    {'SHIFT+T - Toca'  }
    menuAdiciona ('MGREMOEF');  {'SHIFT+A - Remove'  }
    menuAdiciona ('MGMIEF');    {'SHIFT+M - Mistura'  }
    menuAdiciona ('MGVOLCTM');     {'CTRL+V - Aumenta Volume'  }
    menuAdiciona ('MGVOLBTM');     {'CTRL+B - Diminui volume'  }

    n := popupMenuSeleciona;

    if (n > 0) and (n <= totalOpcoes) then
        selSetasEfeitos := tabLetrasOpcao[n]
    else
        selSetasEfeitos := ESC;
end;

{--------------------------------------------------------}
{               ciclo de processamento geral
{--------------------------------------------------------}

procedure menuEfeito;
var
    processando: boolean;
    c, c2: char;
label executa;
begin
    processando := true;
    while processando do
        begin
            Som.gravaArquivo(Arqtemp1);
            while keypressed do readkey;
            limpabaixo(wherey);
            textBackground (BLUE);
            mensagem ('MGOPEF', 0);   {'Qual efeito? '  }
            textBackground (BLACK);

            sintLeTecla (c, c2);
            writeln;

           if (c = #0) and (c2 = F4) then
begin
        mensagem ('MGVELOC', 1);  {'Qual a velocidade, de 1 a 5'  }
    sintLeTecla (c, c2);
    writeln;
    if c in ['1'..'5'] then
        begin
            sintFim;
            sintInic (ord(c) - ord('0'), sintambiente ('MINIGRAV', 'DIRMINIGRAV'));
end;
end
           else
           if (c = #0) and (c2 = CTLF4) then
begin
c := '5';
        begin
            sintFim;
            sintInic (ord(c) - ord('0'), sintambiente ('MINIGRAV', 'DIRMINIGRAV'));
end;
end
           else
           if (c = #0) and (c2 = CTLF3) then
begin
c := '4';
        begin
            sintFim;
            sintInic (ord(c) - ord('0'), sintambiente ('MINIGRAV', 'DIRMINIGRAV'));
end;
end
else
           if (c = #0) and (c2 = CTLF2) then
begin
c := '3';
        begin
            sintFim;
            sintInic (ord(c) - ord('0'), sintambiente ('MINIGRAV', 'DIRMINIGRAV'));
end;
end
           else
           if (c = #0) and (c2 = CTLF1) then
begin
c := '2';
        begin
            sintFim;
            sintInic (ord(c) - ord('0'), sintambiente ('MINIGRAV', 'DIRMINIGRAV'));
end;
end
else

            if c = #$0 then
                begin
                    if c2 = F1 then
                        ajudaEfeito
                    else
                    if (c2 = CIMA) or (c2 = BAIX) then
                        begin
                            c := selSetasEfeitos;
                            goto executa;
                        end
                end
            else
               begin
        executa:
               case c of

                        '+':  sobeVolume;
                        '-':  desceVolume;
                        'b':  diminuiVolume;
                        'c':  aumentaVolume;
                        'i':  fadeIn;
                        'o':  fadeOut;
                        'e':  adicionaEco;
                        'r':  adicionaReverber;
                        'p':  aplicaSenha;
                        'h': fazCopia (nomeArq);
                        'd': undo;

                        '=':  sobeVolumeTrecho;
                        '_':  desceVolumeTrecho;
                        'I':  fadeInTrecho;
                        'O':  fadeOutTrecho;
                        'E':  adicionaEcoTrecho;
                        'R':  adicionaReverberTrecho;
                        'V':  aumentaVolumeTrecho;
                        'B':  diminuiVolumeTrecho;
                        'H': extraiTrechoMarcado (nomeArq);
                        'A': trataRemocao;
                        'T': tocaSom;
                        'M': misturaOutroSom;
                        ^v, 'z':  sobeVolume;
                        ^b, 'Z':  desceVolume;

                        '1':  sobeVolumeAlto1;
                        '!':  sobeVolumeAlto1Trecho;
                        '2':  sobeVolumeAlto2;
                        '@':  sobeVolumeAlto2Trecho;
                        '3':  sobeVolumeAlto3;
                        '#':  sobeVolumeAlto3Trecho;
                        '4':  sobeVolumeAlto4;
                        '$':  sobeVolumeAlto4Trecho;
                        '5':  sobeVolumeAlto5;
                        '%':  sobeVolumeAlto5Trecho;
                        '6':  sobeVolumeAlto6;
                        '¨':  sobeVolumeAlto6Trecho;
                        '7':  sobeVolumeAlto7;
                        '&':  sobeVolumeAlto7Trecho;
                        '8':  sobeVolumeAlto8;
                        '*':  sobeVolumeAlto8Trecho;
                        '9':  sobeVolumeAlto9;
                        '(':  sobeVolumeAlto9Trecho;

                        't':  efeitoSox('reverse');    //retrógado
                        's':  efeitoSox('reverb');    //Reverberação
                        'f':  efeitoSox('pitch');     //Afinação, de 0 a 1000 agudo, abaixo de 0 até menos 1000 grave
                        'v':  efeitoSox('speed');     //velocidade e afinação, acima de 1 acelera e abaixo de 1 até 0 diminui
                        'w':  efeitoSox('stretch');     //velocidade sem mexer na afinação, entre 0 e 1 acelera e acima de 1 diminui
                        'j':  efeitoSox('tempo');     //velocidade sem mexer na afinação, entre 0 e 1 diminui e acima de 1 acelera
                        'y':  efeitoSox('tremolo');     //vibrato, valores até 13000
                        'g':  efeitoSox('bass');      //grave
                        'a':  efeitoSox('treble');    //agudo
                        'n':  efeitoSox('norm');      //normaliza volume
                        'q':  efeitoSox('equalizer'); //equalizador de faixas de frequência
                        'x':  efeitoSox('echo');      //eco
                        'k':  efeitoSox('sinc');      //Telefone
                        'l':  efeitoSox('flanger');
                        'u':  efeitoSox('chorus');

                        ^X: begin
    delay (3);
        SintFim;
        doneWinCrt;
                        end;

                        ESC: processando := false;
                    else
                        mensagem ('MGOPINV', 2); {'Opção inválida, F1 ajuda'  }
                    end;
                end;
        end;
end;

end.
