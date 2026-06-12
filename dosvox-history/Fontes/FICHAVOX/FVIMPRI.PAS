unit fvImpri;
interface
uses windows, dvcrt, dvwin,
     fvProc, fvMsg, fvVars;

    procedure trataImpressao;
    procedure fazImpressao (nomearq: string; confirmacao: char);
    procedure imprimirSelecionadas;

implementation

{--------------------------------------------------------}
{                   impressao braille
{--------------------------------------------------------}

{gambiarra para conserto}
var
   opcao: char;
   passei: boolean;

procedure chamaProgImpressao (tipo: char; nomeArq: string);
var nomeDir, nome: string;
    nomeProg: string;
begin
    case upcase (tipo) of
        'B': nome := 'BRAIVOX.EXE';
        'C': nome := 'LISTAVOX.EXE';
        'F': nome := 'IMPRIVOX.EXE';
    end;

    nomeProg := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if nomeProg = '' then
         nomeProg := '\DOSVOX\' + nome
    else
        begin
            if nomeProg [length(nomeProg)] <> '\' then
                nomeProg := nomeProg + '\';
            nomeProg := nomeProg + nome;
        end;

    getdir (0, nomeDir);

    if executaProg (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;
end;

{--------------------------------------------------------}
{                    rotina de impressao
{--------------------------------------------------------}

procedure fazImpressao (nomearq: string; confirmacao: char);
var
    opc: char;

begin
    if confirmacao = 'S' then
       begin
          textBackground (MAGENTA);
          mensagem ('FVCOMFBR', 0);    { Comum, formatada ou braille ? }
          textBackground (BLACK);
          opc := upcase (readkey);
          opcao := opc;
       end
    else
       opc := opcao;

    writeln;
    if opc in ['B','C','F'] then
        chamaProgImpressao (opc, nomearq)
    else
       if not passei then
           begin
              mensagem ('FVIMPCAN', 1);
              passei := true;
           end;
end;

{--------------------------------------------------------}
{                  trata a impressao
{--------------------------------------------------------}

procedure trataImpressao;
var nomearq: string;
    arq: file;
begin
    mensagem ('FVNOMIMP', 1);   { digite o nome do arquivo a imprimir }
    sintReadln (nomearq);
    if nomearq = '' then exit;

    assign (arq, nomearq);
    {$i-}  reset (arq);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVARQNEX', 1);
            exit;
        end
    else
        close (arq);

    fazImpressao (nomearq, 'S');
end;

{----------------------------------------------------------------------}
{Imprimi fichas selecionadas ou ultima lida.}
{----------------------------------------------------------------------}

procedure imprimirSelecionadas;
var
    opc: char;
    i: integer;
    nomeArqFicha: string;
    naoSelecionada: boolean;

begin
    passei := false;
    textBackGround (red);
    mensagem ('FVIMPSEL',0);{'Imprimir: Selecionadas ou Ultima lida.'}
    textBackGround (black);
    opc := upcase (readkey);
    writeln;
    if opc = 'U' then
        begin
            nomeArqFicha := fichario[posAtual]^.nomeArq;
            fazImpressao (nomeArqFicha, 'S');
        end
    else
    if opc = 'S' then
        begin
            naoSelecionada := TRUE;
            for i := 1 to numFichas do
                begin
                    posAtual := i;
                    if fichario[i]^.selecionado then
                        begin
                            nomeArqFicha := fichario[i]^.nomeArq;
                            fazImpressao (nomeArqFicha, 'S');
                            naoSelecionada := FALSE;
                            if keypressed then
                               begin
                                  opc := readKey;
                                  if opc = ESC then
                                     begin
                                        mensagem ('FVIMPCAN',1); {a impressao foi cancelada}
                                        exit;
                                     end;
                               end;
                        end;
                end;
            if naoSelecionada then
                mensagem ('FVNAOSEL',1);
        end
    else
        mensagem ('FVDESIST',1);
end;

{----------------------------------------------------------------------}

end.
