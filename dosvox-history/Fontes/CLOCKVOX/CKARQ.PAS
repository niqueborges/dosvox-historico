unit ckarq;

interface

uses dvcrt, dvwin, ckjan, ckvars;

    procedure abreArquivo;
    procedure deletaEventosPassados;
    procedure carregaEventos;

implementation

procedure abreArquivo;
begin

    fileMode := 2;   // fmOpenReadWrite
    assign(arq, nomeDat);
    {$i-} reset (arq); {$i+}
    If IOresult <> 0  then
        rewrite (arq);

end; {Procedure}

procedure deletaEventosPassados;
var opcao: char; eventosPassados, aceitaDeletar: boolean;

    procedure verificaDeletar;
    begin
        numeroRegistros:= filesize(arq);
        seek (arq, numeroRegistros - numeroRegistros);

        if aceitaDeletar then
        begin
            assign (arq_tmp, nomeTemp);
            rewrite (arq_tmp);
        end;

        while not eof (arq) do
        begin
            read (arq, x);
            if (x.ano_b < ano)
            or
            (x.ano_b <= ano) and (x.mes_b < mes)
            or
            (x.ano_b <= ano) and (x.mes_b <= mes) and (x.dia_b < dia) then
            eventosPassados:= true
            else
            if aceitaDeletar then
            write (arq_tmp, x);
        end;
    end;

begin
    eventosPassados:= false;
    aceitaDeletar:= false;
    verificaDeletar;

    if not eventosPassados then
    begin
        close (arq);
        exit;
    end
    else
    begin
        jan_fim;
        write ('Desejo apagar os antigos eventos, confirma ? (S/N) : ');
        sintsom ('ckdesdel');

        opcao:= sintreadkey;
        if upcase(opcao) <> 'S' then
        begin
            writeln ('Ok, exclusão cancelada');
            sintsom ('ckexcan');
            close (arq);
            exit;
        end
        else
        begin
            aceitaDeletar:= true;
            verificaDeletar;
            close (arq);
            erase (arq);
            close (arq_tmp);
            rename (arq_tmp, nomeDat);
        end;
    end;

end; {Procedure}

procedure carregaEventos;
begin

    numeroRegistros:= filesize(arq);
    seek (arq, numeroRegistros - numeroRegistros);

    indice:= 0;

    while not eof(arq) do
    begin
        read (arq, x);
        indice:= indice + 1;

        dia_m[indice]:= x.dia_b;
        mes_m[indice]:= x.mes_b;
        ano_m[indice]:= x.ano_b;
        hora_m[indice]:= x.hora_b;
        minuto_m[indice]:= x.minuto_b;
        execDia_m[indice]:= x.execDia_b;
        diaSemana_m[indice]:= x.diaSemana_b;
        frase_m[indice]:= x.frase_b;
        programa_m[indice]:= x.programa_b;
        arquivo_m[indice]:= x.arquivo_b;
        sinal_m[indice]:= x.sinal_b;
        execAtrib[indice]:= true;

    end; {while}

    numeroRegistros:= filesize(arq);

end; {Procedure}

end.
