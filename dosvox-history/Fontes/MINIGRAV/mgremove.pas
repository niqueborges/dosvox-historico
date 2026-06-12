unit mgremove;

interface
uses
    dvcrt,
    dvwin,
    dvForm,
    mgVars,
    mgArquivo,
    mgMsg,
    sysUtils;

procedure trataRemocao;

implementation

{--------------------------------------------------------}

procedure removeAntes;
begin
    som.removeTrecho(0, cursor);
    marca := marca - cursor;
    if marca < 0 then marca := 0;
    cursor := 0;
    mensagem ('MGREMANT', 1);  {'Trecho anterior removido'}
end;

{--------------------------------------------------------}

procedure removeDepois;
begin
    som.removeTrecho(cursor, som.numAmostras - cursor);
    if marca > cursor then marca := cursor;
    mensagem ('MGREMPOS', 1);  {'Trecho posterior removido'}
end;

{--------------------------------------------------------}

procedure removeMeio;
var aRemover: integer;
begin
    aRemover := abs (cursor - marca);
    if marca < cursor then
        cursor := marca
    else
        marca := cursor;
    som.removeTrecho(cursor, aRemover);
    mensagem ('MGTRCREM', 1);  {'Trecho removido'}
end;

{--------------------------------------------------------}

procedure removeTudo;
begin
    som.removeTrecho(0, som.numAmostras);
    marca := 0;
    mensagem ('MGDESTRU', 1);  {'Ok, toda gravação foi removida.'}
end;

{--------------------------------------------------------}

procedure trataRemocao;
var opcao: char;
begin
    mensagem ('MGTRAREM', 0); {'A - remove antes do cursor, D - depois, T - tudo'}
                              {'M - remove entre cursor e ponto memorizado: '}
    opcao:= popupMenuPorLetra('ADTM');
    writeln;

    case upcase(opcao) of
        'A': removeAntes;
        'D': removeDepois;
        'T': removeTudo;
        'M': removeMeio;
    else
        mensagem ('MGOPINV', 1); {'Opção inválida'}
    end;
end;

end.
