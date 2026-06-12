unit mgefeitoSox;

interface
uses
    sysUtils,
    windows,
    messages,
    mmsystem,
    grAmost,
    dvCrt,
    dvwin,
    dvArq,
    dvform,
    dvwav,
//    dvExec,
    mgVars,
    mgArquivo,
    mgMsg,
    mgToca,
    shellApi;

procedure efeitoSox (efeito:string);
function GetTempDir: string;

implementation

{--------------------------------------------------------}
{            Descobre diretório de trabalho
{--------------------------------------------------------}

function GetTempDir: string;
var
  Buffer: array[0..512] of Char;
  saida: string;

begin
    GetTempPath(512,Buffer);
    saida := StrPas(Buffer);
    if saida[length(saida)] <>'\' then saida := saida+'\';
    Result := saida;
end;

{--------------------------------------------------------}
{              Troca virgula por ponto
{--------------------------------------------------------}

function trocaVirgula(s: string):string;
begin
    result:= stringreplace(s,',','.',[rfreplaceAll,rfIgnoreCase]) ;
end;

{--------------------------------------------------------}
{        Pergunta o local de saida do arquivo
{--------------------------------------------------------}

function pegaLocalSaida(s, efeito: string): string;
var
    arqFinal: string;
begin
    arqFinal := '';
    mensagem('MGNLVTXT',1);  {  'Informe o nome do arquivo a salvar: '  }
    Sintreadln(ArqFinal);

    if ArqFinal = '' then
        begin
            mensagem('MGSAIDAD',1); {  Será salvo no diretório atual  }
            arqFinal := ExtractFilePath(nomeArq)+uppercase(efeito)+'__'+ExtractFileName(nomeArq);
        end
    else

    result := arqFinal;
end;
{--------------------------------------------------------}
{            Executa o executavel sox
{--------------------------------------------------------}

procedure executaSox (comandoSox: string);
var
   sei: SHELLEXECUTEINFO;
begin
    with sei do
        begin
            cbSize := sizeof(SHELLEXECUTEINFO);
            fMask := SEE_MASK_NOCLOSEPROCESS;
            sei.Wnd := crtWindow;
            lpVerb := 'open';
            lpFile := pchar(dirSox);
            lpParameters := pchar(comandoSox);
            sei.nShow := SW_MINIMIZE;
        end;
    ShellExecuteEx(@sei);
    waitForSingleObject(sei.hProcess, INFINITE);
end;

{--------------------------------------------------------}
{               pega propriedades do eco
{--------------------------------------------------------}

function pegaEco: string;
var
    valoresEco: array of real;
    valoresStrEco: array of string;
    i: integer;
begin
    setlength(valoresEco, 3);
    setlength(valoresStrEco, 3);
    mensagem('MGECOATT', 1); { 'Atributos do eco:'   }
    formCria;
    formCampoReal('MGECATT1',pegaTextoMensagem('MGECATT1'), valoresEco[0], 0);  {  'Volume do eco(0 até 100):'  }
    formCampoReal('MGECATT2',pegaTextoMensagem('MGECATT2'), valoresEco[1], 0);  {  'Atraso do eco(0 a 1000):'  }
    formCampoReal('MGECATT3',pegaTextoMensagem('MGECATT3'), valoresEco[2], 0);  {  'Volume gradual do eco(0 até 100):'  }
    tamRotulosForm := 35;
    formEdita(True);

    if valoresEco[0]>1 then
        valoresEco[0] := 1;
    if valoresEco[2]>1 then
        valoresEco[2] := 1;

    if valoresEco[0]<0 then
        valoresEco[0] := 0;
    if valoresEco[2]<0 then
        valoresEco[2] := 0;

    for i:=0 to length(valoresEco)-1 do
        valoresStrEco[i] := floattostr(valoresEco[i]);

    for i:=0 to length(valoresStrEco)-1 do
        valoresStrEco[i] := StringReplace(valoresStrEco[i],',', '.',[rfReplaceAll, rfIgnoreCase]);
    valoresEco[0] := valoresEco[0]/100; // para ficar no padrão sox
    valoresEco[2] := valoresEco[2]/100;
    result := '0.8 '+valoresStrEco[0]+' '+valoresStrEco[1]+' '+valoresStrEco[2];
end;

{--------------------------------------------------------}
{         Equilazador de faixas de frequências
{--------------------------------------------------------}

function equalizador: string;
var
    valoresFreq: array of real;
    msg: string;
    valoresStrFreq: array of string;
    i: integer;

begin
    msg :='';
    setlength(valoresFreq, 8);
    setlength(valoresStrFreq, 8);
    mensagem('MGFREQNC', 1); { 'Variações das frequências:'   }
    formCria;
    formCampoReal('',pegaTextoMensagem('MG40HZ'),    valoresFreq[0],  1);
    formCampoReal('',pegaTextoMensagem('MG80HZ'),    valoresFreq[1],  1);
    formCampoReal('',pegaTextoMensagem('MG240HZ'),   valoresFreq[2],  1);
    formCampoReal('',pegaTextoMensagem('MG500HZ'),   valoresFreq[3],  1);
    formCampoReal('',pegaTextoMensagem('MG1000HZ'),  valoresFreq[4],  1);
    if som.velocidade >= 11000 then
        begin
            formCampoReal('',pegaTextoMensagem('MG4100HZ'),  valoresFreq[5],  1);
            msg := msg + ' equalizer 4100 .51q '  +valoresStrFreq[5];
        end;
    if som.velocidade >= 22000 then
        begin
            formCampoReal('',pegaTextoMensagem('MG8500HZ'),  valoresFreq[6],  1);
            msg := msg + ' equalizer 8500 .71q '  +valoresStrFreq[6];
        end;
    if som.velocidade >= 44000 then
        begin
            formCampoReal('',pegaTextoMensagem('MG17000HZ'), valoresFreq[7],  1);
            msg := msg + ' equalizer 17000 .71q ' +valoresStrFreq[7];
        end;
    formEdita(True);

    for i:=0 to length(valoresFreq)-1 do
        if valoresFreq[i]>=0 then
            valoresStrFreq[i] := '+'+floattostr(valoresFreq[i])
        else
            valoresStrFreq[i] := floattostr(valoresFreq[i]);

    for i:=0 to length(valoresStrFreq)-1 do
        valoresStrFreq[i] := StringReplace(valoresStrFreq[i],',', '.',[rfReplaceAll, rfIgnoreCase]);

    msg :=    ' equalizer 40 .71q '    +valoresStrFreq[0]+
              ' equalizer 80 1.10q '   +valoresStrFreq[1]+
              ' equalizer 240 1.80q '  +valoresStrFreq[2]+
              ' equalizer 500 .71q '   +valoresStrFreq[3]+
              ' equalizer 1000 2.90q ' +valoresStrFreq[4];
    if som.velocidade >= 11000 then
        msg := msg + ' equalizer 4100 .51q '  +valoresStrFreq[5];
    if som.velocidade >= 22000 then
        msg := msg + ' equalizer 8500 .71q '  +valoresStrFreq[6];
    if som.velocidade >= 44000 then
        msg := msg + ' equalizer 17000 .71q ' +valoresStrFreq[7];

    result := msg;


end;

{--------------------------------------------------------}
{                        Bota Aspas
{--------------------------------------------------------}

function botaAspas(arq: string): string;
begin
    if Arq[1] <>'"' then
        Arq := '"'+Arq;
    if Arq[Length(Arq)] <> '"' then
        Arq := Arq +'"';
    result := Arq;
end;


{--------------------------------------------------------}

procedure carregaEditado;
var
 //   tempoTotal: integer; 
    amostrasPrevia: integer;
begin

    cursor := 0;
    marca := 0;

    som.maxMemoria := maxMemoria * 1024 * 1024;
    som.leArquivo(ArqTemp2);

  //  tempoTotal:=trunc(som.numAmostras/som.velocidade);
    amostrasPrevia:= som.numAmostras;
  //  if (tempoTotal)>=10 then
  //      amostrasPrevia := trunc(som.numAmostras * 10 / tempototal);

 //   toca dez segundos:

    som.toca (0, amostrasPrevia);
    while waveIsPlaying do delay (10);
end;

{--------------------------------------------------------}
{        Executa o efeito passado como parâmetro
{--------------------------------------------------------}

procedure efeitoSox (efeito: string);
var
    Arq, ArqAspas: String;
    comandoSox, ArqTempAspas: string;
    padraoSpeed, padraoFlanger, padraoSinc, padraoStretch, padraoTempo, padraoChorus, padraoReverb, padraoTremolo: string;
    valor: string;
    c: char;

    procedure pegavalor;
    var v, erro: integer;
    label
        ponto;
    begin
        ponto:
            mensagem('MGPEGAAM',0);  {  'Informe o valor da amplificação (-20 a 20): ' }
            sintReadln(valor);
            if valor = '' then
                 valor := '0';
            val (valor, v, erro);
            if erro <> 0 then
                begin
                     mensagem ('MGASSUM0', 1);  {'Valor inválido, assumido zero'  }
                     v := 0;
                end;

            valor := intToStr(v);
            if (v > 0) then
                valor := '+' + valor;

            if v>20  then
                begin
                    mensagem('MGAVISO1', 1);{  'Atenção! Valores maiores que +20dB podem causar estouro no som.'  }
                    mensagem('MGCONTIN', 1);{  'Deseja continuar(S/N)?'  }
                    c := Readkey;
                    if upcase(c)<>'S' then
                        goto ponto;
                end;
    end;

label demonstra;
begin
    if sox_existe = false then
        begin
        mensagem ('MGPGNAOENC', 0); {'Programa não encontrado'}
        sintWriteln(dirSox);
        exit;
    end;
    Arq := trim(ArqTemp1);
    ArqTemp2 := GetTempDir+'#@#'+ExtractFileName(trim(nomeArq));
    ArqAspas := botaAspas(Arq);
    ArqTempAspas := botaAspas(Arqtemp2);

    padraoReverb := 'gain -3 pad 0 3';
    padraoSpeed := '1';
    padraoStretch := '1';
    padraoTremolo := '1';
    padraoSinc := '1';
    padraoFlanger := '0';
    padraoTempo := '1';
    padraoChorus := '1';
    comandoSox := ArqAspas+' '+ArqTempAspas;

    if efeito='echo' then
        comandoSox := comandoSox+' '+efeito+' '+pegaEco;

    if efeito='reverb' then
            comandoSox := comandoSox+' '+padraoReverb+' '+efeito;

    if efeito='pitch' then
        begin
                valor:= '0';
            mensagem('MGPEGAAF',0);  {  'Afinação, acima de zero, agudo, e abaixo de zero, grave'  }
    sintetiza (valor);
            sintReadln(valor);
    writeln;
            if uppercase(valor) ='' then
begin
                valor:= '0';
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='reverse' then
        comandoSox := comandoSox +' '+efeito;

    if efeito='chorus' then
        begin
                valor:= padraoChorus;
            mensagem('MGVALCHO',0);  {  'Efeito Chorus, de 1 a 5'  }
    sintetiza ('1');
            sintReadln(valor);
            if (uppercase(valor) ='') or (uppercase(valor) < '1') or (uppercase(valor) > '5') then
begin
                valor:= padraoChorus;
end;

                if valor= '1' then
                begin
                valor:= ('0.7'+' '+'0.9'+' '+'55'+' '+'0.4'+' '+'0.25'+' '+'2'+' '+'-t');
            comandoSox := comandoSox+' '+efeito+' '+valor;
                end;

                if valor= '2' then
                begin
                valor:= ('0.6'+' '+'0.9'+' '+'50'+' '+'0.4'+' '+'0.25'+' '+'2'+' '+'-s');
            comandoSox := comandoSox+' '+efeito+' '+valor;
                end;

                if valor= '3' then
                begin
                valor:= ('0.6'+' '+'0.9'+' '+'60'+' '+'0.32'+' '+'0.4'+' '+'1.3'+' '+'-s');
            comandoSox := comandoSox+' '+efeito+' '+valor;
                end;

                if valor= '4' then
                begin
                valor:= ('0.5'+' '+'0.9'+' '+'50'+' '+'0.4'+' '+'0.25'+' '+'2'+' '+'-t');
            comandoSox := comandoSox+' '+efeito+' '+valor;
                end;

                if valor= '5' then
                begin
                valor:= ('0.5'+' '+'0.9'+' '+'60'+' '+'0.32'+' '+'0.4'+' '+'2.3'+' '+'-t');
            comandoSox := comandoSox+' '+efeito+' '+valor;
                end;
        end;

    if efeito='speed' then
        begin
                valor:= padraoSpeed;
            mensagem('MGPEGAVL',0);  {  'Velocidade, acima de 1 acelera e abaixo de 1 até 0 diminui'  }
    sintetiza ('1');
            sintReadln(valor);
            if uppercase(valor) ='' then
begin
                valor:= padraoSpeed;
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='tremolo' then
        begin
            mensagem('MGTREMOV',0);  {  'Vibrato, até 13000'  }
            sintReadln(valor);
            if uppercase(valor) ='' then
begin
                valor:= padraoTremolo;
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='sinc' then
        begin
            mensagem('MGTELEFO',0);  {  'Digite um valor para telefone: '  }
            sintReadln(valor);
            if uppercase(valor) ='' then
begin
                valor:= padraoSinc;
                sintWriteLn ('800');
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='flanger' then
        begin
            mensagem('MGFLANGE',0);  {  'Flanger, entre 0 e 30'  }
            sintReadln(valor);
            if uppercase(valor) ='' then
begin
                valor:= padraoFlanger;
                sintWriteLn ('0');

                if valor> '30' then
                valor:= '30';
                if valor< '0' then
                valor:= '0';
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='stretch' then
        begin
                valor:= padraoStretch;
            mensagem('MGVELDIMACE',0);  {  'Velocidade, entre 0 e 1 acelera e acima de 1 diminui'  }
    sintetiza (valor);
            sintReadln(valor);
    writeln;

            if (uppercase(valor) ='') or (uppercase(valor) ='0') or
            (uppercase(valor[1]) ='-') then
begin
                valor:= padraoStretch;
end;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='tempo' then
        begin
                valor:= padraoTempo;
            mensagem('MGVELACEDIM',0);  {  'Velocidade, entre 0 e 1 diminui e entre 1 e 100 acelera'  }
    sintetiza (valor);
            sintReadln(valor);
    writeln;

//*            if (uppercase(valor) ='') or (uppercase(valor) <='0') or
//*            (uppercase(valor) >= '100') or (uppercase(valor[1]) ='-') then
//*begin
//*                valor:= padraoTempo;
//*end;

            if uppercase(valor) ='' then valor:= padraoTempo;
if uppercase(valor) <='0' then valor:= padraoTempo;
if uppercase(valor[1]) ='-' then valor:= padraoTempo;

            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='bass' then
        begin
            pegaValor;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='treble' then
        begin
            pegaValor;
            comandoSox := comandoSox+' '+efeito+' '+valor;
        end;

    if efeito='norm' then
            comandoSox := comandoSox +' gain -n';

    if efeito='equalizer' then
        comandoSox:= comandoSox + equalizador;

    ExecutaSox(comandoSox);

demonstra:
    mensagem('MGDEMONS',0);  { 'Demonstração: '  }
    while sintFalando do waitMessage;

    carregaEditado;

    writeln;
    writeln;

    mensagem('MGSALVARA',1); {  'Deseja manter o efeito?(S/N)'  }
    mensagem('MGREPETE',1); {  'R - Repete'  }
        repeat
            c := Readkey;
            case upcase(c) of
                ESC,'N':
                begin
                    mensagem('MGNAO',2); {  Não  }
                    DeleteFile(pchar(arqTemp2));
                end;

                'R', ' ':
                begin
                goto demonstra;
                end;

                'S', ENTER:
                    begin
                        mensagem('MGSIM',2); {  Sim  }
                        DeleteFile(pchar(arqTemp1));
                        copyFile(pchar(ArqTemp2), pchar(ArqTemp1), TRUE);
                        DeleteFile(pchar(arqTemp2));
                    end;
            end;
        until (upcase(c) = 'N') or (upcase(c) = 'S') or (upcase(c) = ESC) or (upcase(c) = ENTER) or (c = 'R') or (c = ' ');
    som.leArquivo(arqTemp1);
    limpaBaixo(8);
end;

end.
