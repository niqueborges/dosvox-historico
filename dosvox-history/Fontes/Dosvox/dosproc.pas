unit dosProc;

interface
uses
    windows, sysUtils, shellApi,
    dvCrt, dvWin, dvexec, dosMsg;

function executaPrograma (nomeProg, nomeDir, nomeArq: string; visibJanela: integer): boolean;

implementation

{--------------------------------------------------------}
{             executa um programa qualquer
{--------------------------------------------------------}

function executaPrograma (nomeProg, nomeDir, nomeArq: string; visibJanela: integer): boolean;
var erro: integer;
begin
    executaPrograma := true;
    erro := executaProgEx (nomeProg, nomeDir, nomeArq, visibJanela);
    limpaBufTec;
    if erro < 32 then
        begin
            if erro = 2 then
                mensagem ('DV_PRGNAOENC', 0)        { 'Programa não encontrado.' }
            else
                begin
                    mensagem ('DV_ERROPRGCOD', 0);  { 'Erro na execução do programa: código ' }
                    sintWriteInt (erro);
                end;
            writeln;
            executaPrograma := false;
        end;
end;

end.
