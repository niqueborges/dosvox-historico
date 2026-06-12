{--------------------------------------------------------}
{           procedimentos de leitura bufferizada
{--------------------------------------------------------}

unit brlebuf;
interface

uses dvwin, dvcrt, brvars, brmsg;

procedure devolveCaracArq (c: char);
function pegaCaracArq: char;
procedure inicBufArq;
function carregaUmaLinha: string;

implementation

{--------------------------------------------------------}

procedure devolveCaracArq (c: char);
begin
     pbufArq := pbufArq - 1;
end;

{--------------------------------------------------------}

function pegaCaracArq: char;
begin
    if pbufArq >= lidosBuf then
         begin
             {$I-} blockread (arq, bufArq, 1024, lidosBuf);  {$i+}
             pbufArq := 0;

             if ioresult <> 0 then
                 begin
                     mensagem ('BRERRLEI', 1);    {'Erro de leitura no arquivo'}
                     pegaCaracArq := #$0d;
                     fimDoArq := true;
                     exit;
                 end;
         end;

    pegaCaracArq := bufArq [pBufArq];
    pbufArq := pbufArq + 1;
    fimDoArq := (pBufArq >= lidosBuf) and eof (arq);
end;

{--------------------------------------------------------}

procedure inicBufArq;
begin
    pbufArq := 9999;
    lidosBuf := 0;
    devolveCaracArq (pegaCaracArq);
    fimDoArq := eof (arq) and (pBufArq >= lidosBuf);
    linhasDivididas := false;
end;

{--------------------------------------------------------}

function carregaUmaLinha: string;
var s: string;
    c: char;
    fimDaLinha: boolean;

begin
    fimDaLinha := false;
    s := '';

    repeat
        c := pegaCaracArq;

        if (c = #$0d) or (c = #$0a) then
            fimDaLinha := true
        else
            if c = #9 then
                s := s + '        '
            else
                if c in [#0..#31] then
                    s := s + '#'
                else
                    s := s + c;

        if length (s) > 160 then
            begin
                if not linhasDivididas then
                    begin
                        mensagem ('BRLINDIV', 1);  {'Linhas grandes foram divididas'}
                        linhasDivididas := true;
                    end;

                if length (s) >= 180 then
                    fimDaLinha := true;

                if c = ' ' then
                    begin
                        fimDaLinha := true;
                        while (c = ' ') and (not fimDoArq) do
                           c := pegaCaracArq;
                        if (c <> #$0d) and (c <> #$0a) then
                            devolveCaracArq (c);
                    end;
            end;

    until fimDaLinha or fimDoArq;

    if (not fimDoArq) and (c = #$0d) then
        begin
            c := pegaCaracArq;
            if c <> #$0a then
                devolveCaracArq (c);
        end;

    carregaUmaLinha := s;
end;

end.
