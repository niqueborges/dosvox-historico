unit ppImport;

interface

uses dvCrt, dvWin, dvArq, dvForm,
    ppImpPpt, ppArq, ppMsg, ppVars;

procedure defineTipoImport;

implementation

var importando_PP:boolean;

{--------------------------------------------------------}

procedure importaTexto;
var arqTransf, arqGerad: text;
    nomeArqGerad: string;
    s: string;
    i: integer;
    opcao: char;
label pula;
begin

    if importando_PP then
        goto pula;

    writeln;
    mensagem ('PPARQIMT', 1); {('Informe com as setas o arquivo TXT a ser importado : ');}
    garanteEspacoTela (11);
    nomeArqTransf:= obtemNomeArqMasc (10, '*.TXT');
    writeln (nomeArqTransf);

    if nomeArqTransf = '' then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    pula :

    if not existeArq(nomeArqTransf) then
    begin
        sintBip; sintBip;
        mensagem ('PPARQINE', 1); {('Arquivo inexistente');}
        exit;
    end;

    assign (arqTransf, nomeArqTransf);
    {$I-} reset(arqTransf); {$I+}
    if ioResult <> 0 then;

    nomeArqGerad:= nomeArqTransf;
    if pos ('.', nomeArqGerad) <> 0 then
        delete (nomeArqGerad, pos ('.', nomeArqGerad), length (nomeArqGerad));
    nomeArqGerad:= nomeArqGerad+ '.PPX';

    if existeArq(nomeArqGerad) then
    begin
        sintSom ('PPATESSS');
        delay (100);
        mensagem ('PPATENCA', 1); {('Atenção ! O arquivo PPX a ser gerado irá sobrescrever um já existente !');}
        delay (100);
        mensagem ('PPCONOPP', 0); {('Confirma a operação ? (sim ou não) : ');}
        opcao:= sintReadkey;
        writeln (opcao);
        if upcase(opcao) <> 'S' then
        begin
            mensagem ('PPDESIST', 1);
            exit;
        end;
    end;

    assign (arqGerad, nomeArqGerad);
    {$I-} rewrite(arqGerad); {$I+}
    if ioResult <> 0 then
        exit;

    writeln (arqGerad, '/ESTILO=Padrão PPTVOX.est');
    writeln (arqGerad, ';');
    writeln (arqGerad, '[CAPA]');
    writeln (arqGerad, '*TIT=Projeto DOSVOX - NCE/UFRJ');
    writeln (arqGerad, '*SOM=FUNDOMUSICAL c:\winvox\treino\Strauss.mp3');
    writeln (arqGerad, '{');
    writeln (arqGerad, '.Contatos CAEC :');
    writeln (arqGerad, '.E-mail : bernard@nce.ufrj.br &c:\winvox\cartavox.exe bernard@nce.ufrj.br');
    writeln (arqGerad, '.Ativar o Cronômetro &c:\winvox\scripvox.exe ' + dirEstilos + '\Alarme_PPTVOX.cmd');
    writeln (arqGerad, '.DOSVOX Homepage &c:\winvox\webvox.exe intervox.nce.ufrj.br/dosvox');
    writeln (arqGerad, '.DOSVOX Rádio &c:\winvox\webvox.exe intervox.nce.ufrj.br/dosvox/radio.ram');
    writeln (arqGerad, '}');

    while not eof (arqTransf) do
    begin

        readln (arqTransf, s);
        i:= 0;

        writeln (arqGerad, '[LISTA SIMPLES]');

        if s <> '' then
            writeln (arqGerad, '*TIT=' + s)
        else
            writeln (arqGerad, '*TIT=Não Definido');

        writeln (arqGerad, '{');

        repeat
            i:= i + 1;
            readln (arqTransf, s);
            if s <> '' then
                writeln (arqGerad, '.' + s);
        until (i = 11) or (s = '');

        writeln (arqGerad, '}');

    end;

    {$I-} close(arqGerad); {$I+}
    if ioResult <> 0 then;

    {$I-} close(arqTransf); {$I+}
    if ioResult <> 0 then;

    sintSom ('PPSSADDI');
    delay (100);

    writeln;
    mensagem ('PPOKSAL', 1); {('OK, salvei em disco');}
    writeln;

    nomeArq:= nomeArqGerad;
    nomeArqTXT:= nomeArqTransf;

end;

{--------------------------------------------------------}

procedure importaPowerPoint;
var opcao: char;
begin

    importando_PP:= true;

    writeln;
    mensagem ('PPINFPPS', 1); {('Informe com as setas o arquivo PPT ou PPS a ser importado : ');}
    garanteEspacoTela (11);
    nomeArqTransf:= obtemNomeArqMasc (10, '*.PP*');
    writeln (nomeArqTransf);

    if nomeArqTransf = '' then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    if (maiuscAnsi(copy(nomeArqTransf, pos('.', nomeArqTransf), length(nomeArqTransf))) <> '.PPS') and
    (maiuscAnsi(copy(nomeArqTransf, pos('.', nomeArqTransf), length(nomeArqTransf))) <> '.PPT') then
    begin
        writeln;
        mensagem ('ppdessoi', 1); {('Desculpe, nesse caso só importo PPT ou ppS');}
        writeln;
        exit;
    end;

    pptToTxt;

    writeln;
    mensagem ('PPSAFOTX', 1); {('Salvei em formato texto, irei transformá-lo em .PPX');}
    delay (100);
    mensagem ('PPDEEDLO', 0); {('Deseja editá-lo ? (SIM ou NÃO) : ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if (upcase(opcao) = 'S') or (opcao = ENTER) then
        editaArqEdivox (nomeArqTransf);

    importaTexto;

end;

{--------------------------------------------------------}

procedure defineTipoImport;
var opcao: char;
begin

    textBackground (BLUE);
    writeln;
    mensagem ('PPIMPOTT', 1); {('Importando');}
    textBackground (BLACK);
    sintSom ('PPPAICON');
    delay (100);

    writeln;
    mensagem ('PPTTTPPP', 0); {('Digite T para arquivo tipo texto ou P para arquivo tipo POWERPOINT : ');}
    opcao:= sintReadkey;
    writeln (opcao);

    importando_PP:= false;

    if upcase (opcao) = 'T' then
        importaTexto
    else
    if upcase (opcao) = 'P' then
        importaPowerPoint
    else
        mensagem ('PPDESIST', 1);

    writeln;
    limpaBufTec;

end;

end.
