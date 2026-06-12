unit dosimpr;
interface
uses windows, sysUtils,
    dvcrt, dvwin, dvArq, dvExec, dvForm,
    dosgeral, dosmsg, doscopia, dosproc,
    dosVars;

procedure trataImpressao;
procedure fazImpressao (nomearq: string);

implementation

{--------------------------------------------------------}
{                   impressao braille
{--------------------------------------------------------}

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
         nomeProg := 'c:\winvox\' + nome
    else
        begin
            if nomeProg [length(nomeProg)] <> '\' then
                nomeProg := nomeProg + '\';
            nomeProg := nomeProg + nome;
        end;

    getdir (0, nomeDir);

    if pos (' ', nomeArq) <> 0 then
        nomeArq := '"' + nomeArq + '"';

    if executaPrograma (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;
end;

{--------------------------------------------------------}
{                    rotina de impressao
{--------------------------------------------------------}

procedure fazImpressao (nomearq: string);
var
    c: char;

begin
    writeln (nomeArq);
    textBackground (MAGENTA);
    mensagem ('DV_COMFBR', 0);      { 'Impressão comum, formatada ou braille ? ' }
    textBackground (BLACK);

    c := popupMenuPorLetra('CFB');
    if c in ['B','C','F'] then
        chamaProgImpressao (c, nomearq)
    else
        begin
            writeln;
            mensagem ('DV_IMPRCANC', 1);    { 'A impressão foi cancelada.' }
        end;
end;

{--------------------------------------------------------}
{                  trata a impressao
{--------------------------------------------------------}

procedure trataImpressao;
var nomearq: string;
    arq: file;
    c: char;
label fim;
begin
    limpaBufTec;
    mensagem ('DV_NOMEAIMP', 4);    { 'Digite o nome do arquivo a imprimir: ' }
    c := sintEdita (nomeArq, 1, wherey-3, 255, true);

    if c = ESC then goto fim;

    if (c <> ENTER) or (pos ('*', nomeArq) <> 0) then
        nomeArq := selecArq (41, wherey-1, 79, 25, nomeArq, faArchive, 0);
 
    if nomeArq = '' then
       begin
           mensagem ('DV_NAOSELEC', 2);     { 'Não posso fazer: não existe nenhum arquivo selecionado.' }
           goto fim;
       end;

    assignFile (arq, nomearq);
    {$i-}  reset (arq);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_ARQNAOEX', 1);    { 'Arquivo não existe, sinto muito.' }
            exit;
        end
    else
        closeFile (arq);

    fazImpressao (nomearq);
fim:
    writeln;
    exit;
end;

end.
