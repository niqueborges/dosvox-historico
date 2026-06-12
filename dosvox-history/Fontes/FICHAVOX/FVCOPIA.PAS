unit fvCopia;
interface
uses windows, dvcrt, dvwin, sysUtils,
     fvVars, fvProc, fvMsg;

procedure fazCopias (nomearq: string);

implementation
var
    arqin, arqout: file;

{--------------------------------------------------------}

    procedure ajudaCopia;
    var i: integer;
        s: string;
    begin
        writeln;
        for i := 1 to 5 do
            begin
                str (i, s);
                mensagem ('FVAJUD'+s, 1);
                if keypressed then
                    begin
                        sintBip;
                        exit;
                    end;
            end;
    end;

{--------------------------------------------------------}
{                  copias de arquivos
{--------------------------------------------------------}

    { esta rotina recebe os nomes dos arquivos ja' assinalados }
    {  aos arquivos arqin e arqout }

    function copiaUm: boolean;
    const
        BUFSIZE = 8192;
    type
        BUFFER = array [0..BUFSIZE-1] of byte;

    var tam: longint;
        nbytes: word;
        buf: ^BUFFER;
        erro: word;
    label fim;

    begin
        copiaUm:= false;

        {$I-} reset (arqin, 1); {$I+}
        if ioresult <> 0 then exit;
        {$I-} rewrite (arqout, 1); {$I+}
        if ioresult <> 0 then exit;

        new (buf);

        tam := filesize (arqin);
        while tam > 0 do
            begin
                nbytes := BUFSIZE;
                if tam < BUFSIZE then nbytes := tam;

                {$I-} blockread  (arqin,  buf^, nbytes); {$I+}
                if ioresult <> 0 then
                    begin
                        limpaBufTec;
                        mensagem ('FVERRLEI', 1);
                        goto fim;
                    end;

                {$I-} blockwrite (arqout, buf^, nbytes); {$I+}
                erro := ioresult;
                if erro = 101 then
                    begin
                        limpaBufTec;
                        mensagem ('FVFALESP', 1);
                        goto fim;
                    end;

                tam := tam - BUFSIZE;
            end;

        copiaUm := true;

fim:
        dispose (buf);

        {$I-} close (arqin);  {$I+}
        if ioresult <> 0 then;
        {$I-} close (arqout); {$I+}
        if ioresult <> 0 then
            copiaUm := false;
    end;

{--------------------------------------------------------}

    function selecDirDest (var diret: string): boolean;
    var
        diratual: string;
    begin
        selecDirDest := false;

        mensagem ('FVINFDST', 1);
        sintReadln (diret);
        if diret = '' then
            begin
                mensagem ('FVDESIST', 1);
                exit;
            end;

        getdir (0, diratual);

        {$I-} chdir (diret);  {$I+}
        if ioresult <> 0 then
            begin
                limpaBufTec;
                mensagem ('FVERRDIR', 1);
                {$I-} chdir (diratual);  {$I+}
                if ioresult <> 0 then;
                exit;
            end;

        getdir (0, diret);
        {$I-}  chdir (diratual);  {$i+}
        if ioresult <> 0 then;

        if diret = diratual then
            begin
                mensagem ('FVNAOPOD', 1);
                exit;
            end;

        if diret [length(diret)] <> '\' then
           diret := diret + '\';

        selecDirDest := true;
    end;

{--------------------------------------------------------}

    procedure copiaEste (nomearq: string);
    var
         diret: string;
    begin
        if nomearq = '' then
            begin
                 mensagem ('FVNAOSEL', 1);
                 exit;
            end;

        if not selecDirDest (diret) then
            exit;

        assign (arqin, nomearq);
        assign (arqout, diret+nomearq);

        if not copiaUm then
             mensagem ('FVERRCOP', 1)
        else
             begin
                  write (nomearq);
                  sintetiza (nomearq);
                  mensagem ('FVFOICOP', 1);
             end;
    end;

{--------------------------------------------------------}

    procedure copiaTodos (apagando: boolean);
    var
        diret: string;
        i: integer;
        nomearq: string;
    begin
        if not selecDirDest (diret) then exit;

        for i := 1 to numFichas do
            begin
                nomearq := fichario[i]^.nomeArq;
                assign (arqin, nomearq);
                assign (arqout, diret+nomearq);

                if not copiaUm then
                    begin
                         mensagem ('FVERRCOP', 1);
                         exit;
                    end
                else
                    begin
                       write (nomearq);
                       sintetiza (nomearq);
                       mensagem ('FVFOICOP', 1);
                       if apagando then erase (arqin);
                    end;
            end;

        if apagando then
            begin
                assign (arqin, 'fichas.ind');
                {$i-} erase (arqin); {$i+}
                if ioresult <> 0 then;
                assign (arqin, 'modelo.txt');
                {$i-} erase (arqin); {$i+}
                if ioresult <> 0 then;
                numFichas := 0;
            end;

    end;

{--------------------------------------------------------}

    procedure replicaArquivo (nomearq: string);
    var
        novoNome: string;
    begin
        if nomearq = '' then
            begin
                 mensagem ('FVNAOSEL', 1);
                 exit;
            end;

        mensagem ('FVNOMCOP', 0);
        sintReadln (novoNome);
        if novoNome = '' then
            begin
                mensagem ('FVDESIST', 1);
                exit;
            end;

        if novoNome = compacta (nomearq) then
            begin
                limpaBufTec;
                mensagem ('FVNOMERR', 1);
                exit;
            end;

        assign (arqin, nomearq);
        assign (arqout, novoNome);

        if not copiaUm then
            begin
                mensagem ('FVERRCOP', 1);
                {$I-} erase (arqout); {$i+}
                if ioresult <> 0 then;
            end
        else
            begin
                sintsoletra (novoNome);
                write (novoNome);
                mensagem ('FVFOIREP', 1);
            end;
    end;

{--------------------------------------------------------}

procedure fazCopias (nomearq: string);
var 
    c, c2: char;
label inicio;

begin
inicio:
    textBackground (MAGENTA);
    mensagem ('FVTIPCOP', 0);
    textBackground (BLACK);
    pegaTeclado (c, c2);

    if (c = #$1b) or ((c = #0) and (c2 <> F1)) then
        begin
            writeln;
            mensagem ('OK', 1);
            exit;
        end;

    if (c = #0) and (c2 = F1) then
        begin
            ajudaCopia;
            goto inicio;
        end;

    sintWriteln (c);

    case upcase(c) of
        'D': copiaEste (nomearq);
        'T': copiaTodos (false);
        'R': replicaArquivo (nomearq);
        'M': copiaTodos (true);
    else
        mensagem ('FVERROPC', 1);
    end;
end;

end.
