{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Processamento de arquivos
{
{   Em 11/06/2015
{
{--------------------------------------------------------------}

Unit ppArq;

interface

uses dvCrt, dvWin, dvExec, dvForm, dvArq,
    windows, messages, sysUtils, classes,
    ppMsg, ppVars;

function trocaDir (dirTrab: string): boolean;
procedure geraArqPadrao;
function existeArq (s: string): boolean;

function carregaArq: boolean;

procedure editaArqEDIVOX (nom: string);

procedure imprimeArqTXT;

procedure salvaArqPPx;
function salvaArqTXT: boolean;

function defineScript: boolean;

implementation

{--------------------------------------------------------}

function trocaDir (dirTrab: string): boolean;
begin

    trocaDir:= false;

    {$I-} chDir (dirTrab); {$I+}
    if ioResult <> 0 then
        begin
            {$I-} mkDir (dirTrab); {$I+}
            {$I-} chDir (dirTrab); {$I+}
            if ioResult <> 0 then
            begin
                sintBip;
                sintetiza ('- ERRO - FUNÇÃO TrocaDir');
                exit;
            end;
        end;

    trocaDir:= true;

end;

{--------------------------------------------------------}

procedure geraArqPadrao;
var arq: text;
begin

    assign (arq, 'Padrão PPTVOX.est');
    {$I-} rewrite(arq); {$I+}
    if ioResult <> 0 then
        exit;

    sintClek; sintClek; sintClek;

    writeln (arq, 'RESOLU=1024 por 768');
    writeln (arq, 'FIGFUN=' + fundoPadrao);
    writeln (arq, 'CORLET=preta');
    writeln (arq, 'FONTIT=TIMES NEW ROMAN');
    writeln (arq, 'FONLIN=ARIAL');
    writeln (arq, 'TAMTIT=36');
    writeln (arq, 'TAMLIN=24');
    writeln (arq, 'MARESQ=200');
    writeln (arq, 'MARSUP=100');
    writeln (arq, 'XTITUL=20');
    writeln (arq, 'YTITUL=30');
    writeln (arq, 'XDETAL=60');
    writeln (arq, 'YDETAL=60');

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then;

end;

{--------------------------------------------------------}

function existeArq (s: string): boolean;
var arqVer: file;
begin

    existeArq:= false;

    assign (arqVer,s);
    {$I-} reset (arqVer); {$i+}
    if ioResult <> 0 then
    begin
        sintBip;
        exit;
    end;

    close (arqVer);

    existeArq:= true;

end;

{--------------------------------------------------------}

function carregaArq: boolean;
var arq: text;
    sld: integer;
    s: string;
begin

    carregaArq:= false;

    assign (arq, nomeArq);
    {$I-} reset(arq); {$I+}
    if ioResult <> 0 then
    begin
        writeln;
        sintBip; sintBip;
        mensagem ('PPAPRINE', 1); {('Apresentação inexistente, operação cancelada');}
        nomeArq:= '';
        exit;
    end;

    for sld := 0 to nSlides -1 do
    begin
        with slides[sld] do
        begin
            arquivo:= '';
            som:= '';
            fundo:= '';
        end;
    end;

    sld:= 0;

    while not eof (arq) do
    begin
        readln (arq, s);

        if not capturouEstilo then
        begin
            if s[1] = '/' then
            begin
                delete (s, 1, 8);
                nomeEstilo := s;
                capturouEstilo:= true;
                if debugar then
                    sintetiza ('CAPTUREI O NOME DO ESTILO');
            end;
            continue;
        end;

        if s[1] = '[' then
        begin
            if s = '[CAPA]' then
                slides[sld].modelo := capa
            else
            if s = '[LISTA SIMPLES]' then
                slides[sld].modelo := listaSimples
            else
            if s = '[FIGURA]' then
                slides[sld].modelo := figura
            else
            if s = '[VIDEO]' then
                slides[sld].modelo := video
            else
            if s = '[TEXTOFIGURA]' then
                slides[sld].modelo := textofigura
            else
            begin
                mensagem ('PPERROSI', 1);   {'Erro de sintaxe no arquivo. Conteúdo:'}
                sintwriteln (s);
            end;
            continue;
        end;

        if s[1] = '*' then
        begin
            if copy (s, 1, 5) = '*TIT=' then
            begin
                delete (s, 1, 5);
                slides[sld].titulo := s;
            end
            else
            if copy (s, 1, 5) = '*ARQ=' then
            begin
                delete (s, 1, 5);
                slides[sld].arquivo := s;
            end
            else
            if copy (s, 1, 5) = '*SOM=' then
            begin
                delete (s, 1, 5);
                slides[sld].som := s;
            end
            else
            if copy (s, 1, 5) = '*FUN=' then
            begin
                delete (s, 1, 5);
                slides[sld].fundo := s;
            end
            else
            begin
                mensagem ('PPERROSI', 1);   {'Erro de sintaxe no arquivo. Conteúdo:'}
                sintwriteln (s);
            end;

            continue;
        end;

        if s[1] = '{' then
        begin
            slides[sld].linhas := TStringList.Create;
            repeat
                readln (arq, s);
                if s[1] = '.' then
                begin
                    delete (s, 1, 1);
                    if exportandoPPT then
                    begin
                        if pos ('&', s) <> 0 then
                            delete (s, pos ('&', s) - 1, length (s));
                        if pos ('#', s) <> 0 then
                            delete (s, pos ('#', s) - 1, length (s));
                        if s[1] = ';' then
                            s:= '-----'; //Provisório pois o POWERPOINT não exporta linha vazia
                    end
                    else
                        if s = '' then
                            s:= ';'; //Indica linha vazia
                    slides[sld].linhas.Add(s);
                end;
            until s[1] = '}';
        end;

        if s[1] = '}' then
            sld := sld + 1;

    end;
    
{ tirei ==>    sld := sld - 1;}

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then
        exit;

    nslides := sld;
    slideAtual := 0;
    linhaAtual := -1;

    apagaSempreOFundo := false; //Faça false se a imagem de fundo cobrir toda a tela

    carregaArq:= true;
end;

{--------------------------------------------------------}

procedure editaArqEdivox (nom: string);
begin

    nom:= '"' + nom + '"';

    delay (500);
    if executaProg ('c:\winvox\edivox.exe', '', nom) < 32 then;
        esperaProgVoltar;
    delay (500);

end;

{--------------------------------------------------------}

procedure salvaArqPPX;
var arq: text;
    i, j: integer;
begin

    assign (arq, nomeArq);
    {$I-} rewrite(arq); {$I+}
    if ioResult <> 0 then
        exit;

    if nomeEstilo = '' then
        writeln (arq, '/ESTILO=Padrão PPTVOX.est')
    else
        writeln (arq, '/ESTILO=' + nomeEstilo);

writeln (arq, ';');

    for i:= 0 to nSlides -1 do
    begin
        with slides[i] do
        begin

            if modelo = capa then
                writeln (arq, '[CAPA]');
            if modelo = listasimples then
                writeln (arq, '[LISTA SIMPLES]');
            if modelo = figura then
                writeln (arq, '[FIGURA]');
            if modelo = video then
                writeln (arq, '[VIDEO]');
            if modelo = textofigura then
                writeln (arq, '[TEXTOFIGURA]');
            if titulo <> '' then
            begin
                write (arq, '*TIT=');
                writeln (arq, titulo)
            end
            else
            begin
                write (arq, '*TIT=');
                writeln (arq, 'NÃO DEFINIDO')
            end;

            if arquivo <> '' then
            begin
                if (pos (':', arquivo) <> 0) and (pos ('\', arquivo) <> 0) and (pos ('.', arquivo) <> 0) then //Testa a ocorrencia do caminho e extensão
                begin
                    write (arq, '*ARQ=');
                    writeln (arq, arquivo)
                end;
            end;

            if som <> '' then
            begin
                write (arq, '*SOM=');
                writeln (arq, som)
            end;

            if fundo <> '' then
            begin
                write (arq, '*FUN=');
                writeln (arq, fundo)
            end;

            writeln (arq, '{');
            if linhas.count >= 1 then
                for j:= 0 to linhas.count - 1 do
                begin
//                    if linhas[j] <> '' then
                        writeln (arq, '.' + linhas[j]);
                end;
            writeln (arq, '}');

        end;
    end;

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then;

    salvarSlide:= false;

    sintSom ('PPSSADDI');
    delay (100);
    mensagem ('PPOKSAL', 1); {('OK, salvei em disco');}
    writeln;

end;

{--------------------------------------------------------}

procedure imprimeArqTXT;
var opcao: char;
    s: string;
begin

    if nomeArq = '' then
    begin
        writeln;
        mensagem ('PPINFAPR', 0); {('Informe com as setas a apresentação desejada : ');}
        garanteEspacoTela (11);
        nomeArq:= obtemNomeArqMasc (10, '*.PPX');
        writeln (nomeArq);
        if nomeArq = '' then
        begin
            mensagem ('PPDESIST', 1);
            writeln;
            exit;
        end;
    end;

    nomeArqTXT:= nomeArq;
    delete (nomeArqTXT, pos ('.', nomeArqTXT), length (nomeArqTXT));
    nomeArqTXT:= nomeArqTXT + '.TXT';

    if existeArq(nomeArqTXT) then
    begin
        sintSom ('PPATESSS');
        delay (100);
        mensagem ('PPATENCT', 1); {('Atenção ! O arquivo TXT a ser gerado irá sobrescrever um já existente !');}
        delay (100);
        mensagem ('PPCONOPP', 0); {('Confirma a operação ? (sim ou não) : ');}
        opcao:= sintReadkey;
        writeln (opcao);
        if upcase(opcao) <> 'S' then
        begin
            mensagem ('PPDESIST', 1);
            exit;
        end
        else
        begin
            s:= nomeArqTXT;
            delete (s, pos ('.', s), length (s));
            s:= s + '_TXT';
            s:= s+ '.$$$';
            renameFile (nomeArqTXT, s);
        end;
    end;

    if not salvaArqTxt then
        exit;

    textBackground (BLUE);
    writeln;
    mensagem ('PPARQIMP', 1); {('Arquivo pronto para impressão');}
    textBackground (BLACK);
    sintSom ('PPPAICON');
    delay (100);

    mensagem ('PPDESEDI', 0); {('Deseja editá-lo ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
        editaArqEdivox (nomeArqTXT);

    writeln;
    mensagem ('PPPREALG', 1); {('Pressione algo para iniciar a impressão, ESC cancela');}
    opcao:= sintReadkey;

    if opcao = ESC then
    begin
        mensagem ('PPDESIST', 1);
        writeln;
        exit;
    end;

    delay (500);
    if executaProg ('c:\winvox\listavox.exe', '', nomeArqTXT) < 32 then
        esperaProgVoltar;
    delay (500);

    clrscr;
    limpaBufTec;

end;

{--------------------------------------------------------}

function salvaArqTXT: boolean;
var arq, arqTXT: text;
    s: string;
    i: integer;
begin

    salvaArqTxt:= false;

    assign (arq, nomeArq);
    {$I-} reset(arq); {$I+}
    if ioResult <> 0 then
    begin
        sintBip; sintBip;
        nomeArq:= '';
        exit;
    end;

    nomeArqTXT:= nomeArq;
    delete (nomeArqTXT, pos ('.', nomeArqTXT), length (nomeArqTXT));
    nomeArqTXT:= nomeArqTXT + '.TXT';

    assign (arqTXT, nomeArqTXT);
    {$I-} rewrite(arqTXT); {$I+}
    if ioResult <> 0 then
        exit;

    writeln (arqTXT, 'PROJETO DOSVOX - NCE/UFRJ');
    writeln (arqTXT, 'slides gerados em formato texto');
    writeln (arqTXT, '----------');
    writeln (arqTXT);

    i:= 0;

    while not eof (arq) do
    begin
        readln (arq, s);

        if s[1] = '*' then
        begin
            if copy (s, 1, 5) = '*TIT=' then
            begin
                delete (s, 1, 5);
                writeln (arqTXT, s);
                writeln (arqTXT);
            end;
        end;

        if s[1] = '.' then
        begin
            delete (s, 1, 1);
            if pos ('&', s) <> 0 then
                delete (s, pos ('&', s) - 1, length (s));
            if pos ('#', s) <> 0 then
                delete (s, pos ('#', s) - 1, length (s));
            writeln (arqTXT, s);
        end;

        if s[1] = '}' then
        begin
            i:= i + 1;
            writeln (arqTXT);
            writeln (arqTXT, '---');
            writeln (arqTXT);
        end;

    end;

    writeln (arqTXT, 'Fim dos SLIDES');
    write (arqTXT, 'Total de SLIDES salvos : ');
    writeln (arqTXT, i);

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then;

    {$I-} close(arqTXT); {$I+}
    if ioResult <> 0 then;

    salvaArqTxt:= true;

end;

{--------------------------------------------------------}

function defineScript;
var nomeScript: string;
    opcao: char;
begin

    defineScript:= false;

    writeln;
    mensagem ('PPINFSCR', 0); {('Informe com as setas o script desejado : ');}
    garanteEspacoTela (11);
    nomeScript:= obtemNomeArqMasc (10, '*.CMD');
    writeln (nomeScript);
    if nomeScript = '' then
    begin
        writeln;
        mensagem ('PPDESIST', 1);
        writeln;
        limpaBufTec;
        exit;
    end;

    writeln;
    mensagem ('PPDIGEX', 0); {('Digite X para executar ou E para editar o script : ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if (upcase(opcao) <> 'X') and (upcase(opcao) <> 'E') then
    begin
        writeln;
        mensagem ('PPDESIST', 1);
        writeln;
        limpaBufTec;
        exit;
    end;

    if upcase(opcao) = 'X' then
        if not executaProg ('c:\winvox\scripvox.exe', '', nomeScript) < 32 then
        begin
            sintBip; sintBip;
            writeln;
            exit;
        end;

    if upcase(opcao) = 'E' then
        if not executaProg ('c:\winvox\edivox.exe', '', nomeScript) < 32 then
        begin
            sintBip; sintBip;
            writeln;
            exit;
        end;

    esperaProgVoltar;

    defineScript:= true;

    writeln;

    limpaBufTec;

end;

end.
