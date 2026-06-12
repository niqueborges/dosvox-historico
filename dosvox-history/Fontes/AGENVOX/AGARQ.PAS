{--------------------------------------------------------}
{             tratamento dos arquivos
{--------------------------------------------------------}

unit agArq;
interface
uses dvcrt, dvwin, dvArq,
     agDados,
     agMensag,
     agEstDad;

procedure leAgenda;
procedure gravaAgenda;
procedure finaliza;

implementation

{--------------------------------------------------------}
{                        finaliza
{--------------------------------------------------------}

procedure finaliza;
begin
    writeln;
    mensagem ('AGTCHAU', 1);
    while sintFalando do;
    delay (2000);
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                      le agenda
{--------------------------------------------------------}

procedure leAgenda;
var
    reg, nome: string;
    erro: integer;
    dia, mes, ano, hora, min: word;
    texto: string;
    p: PLISTA;

label inicio, abreAgenda;

Begin
    if paramCount >= 1 then
        nome := paramStr(1);
inicio:
    gotoxy (1, 11);
    clreol;
    mensagem ('AGNOMARQ', 1);
    nome := obtemNomeArq (10);
    if nome = '' then
        finaliza;

abreAgenda:
    limpaBaixo;
    assign (arqAgenda, nome);
    {$I-}  reset (arqAgenda); {$I+}
    If Ioresult = 0  Then
        begin
            gotoxy (1, 14);
            textBackground (blue);
            mensagem ('AGCARGA', 1);
            textBackground (black);
            clreol;

            while not eof (arqAgenda)  Do
                begin
                    {$I-} readln (arqAgenda, reg); {$I+}
                    if ioresult <> 0 then
                        begin
                            gotoxy (1, 14); clreol;
                            mensagem ('AGERRLEI', 1);
                            close (arqAgenda);
                            exit;
                        end;

                    val (copy (reg,  1, 4), ano, erro);
                    val (copy (reg,  5, 2), mes, erro);
                    val (copy (reg,  7, 2), dia, erro);
                    val (copy (reg,  9, 2), hora, erro);
                    val (copy (reg, 11, 2), min, erro);

                    texto := copy (reg, 14, length(reg)-13);

                    if not insereEstrDados (dia, mes, ano, hora, min, texto, p) then
                         begin
                             gotoxy (1, 14); clreol;
                             mensagem ('AGERRLEI', 1);
                         end;

                    if p <> NIL then
                       p^.marcaComprom := reg[13];
                end;

            close (arqAgenda);
        end
    else
        begin
            {$I-}  rewrite (arqAgenda);  {$I+}
            if ioresult = 0 then
                begin
                    gotoxy (1, 14);
                    mensagem ('AGARQNOV', 1);
                    close (arqAgenda);
                end
            else
                begin
                    gotoxy (1, 14);
                    mensagem ('AGNOMINV', 1);
                    delay (1000);
                    goto Inicio;
                end;
        end;

    gotoxy (1, 16);
    mensagem ('AGOK', 1);
    gotoxy (41, 10);
    writeln ('Agenda: ', nome);
end;

{--------------------------------------------------------}
{                      grava agenda
{--------------------------------------------------------}

procedure gravaAgenda;
var
    nome, s: string;
    resulta: integer;
    p: PLISTA;

label
    achou, errodisco;

begin
    repeat
        {$I-} rewrite (arqAgenda); {$I+}
        resulta := ioresult;
        if resulta <> 0 then
            begin
erroDisco:
                {$I-} close (arqAgenda);  {$I+}
                resulta := ioresult;  { limpa eventual erro }

                limpaBaixo;

                mensagem ('AGERRGRV', 1);
                writeln;
                mensagem ('AGNOMARQ', 1); clreol;

                repeat
                    nome := '';
                    sintReadln (nome);
                until nome <> '';
                assign (arqAgenda, nome);
            end;

    until resulta = 0;

    p := primeiro;

    while p^.prox <> NIL do
        begin
            with p^ do
                s := codifica (diaComprom,mesComprom,anoComprom,
                               horaComprom,minComprom);
            {$I-} write (arqAgenda, s); {$i+}
            if ioresult <> 0 then goto erroDisco;

            s := p^.marcaComprom + p^.textoComprom;
            {$I-} writeln (arqAgenda, s); {$i+}
            if ioresult <> 0 then goto erroDisco;

            p := p^.prox;
        end;

    {$i-} close (arqAgenda); {$I+}
    if ioresult <> 0 then goto erroDisco;
    mensagem ('AGARQGRV', 1);
end;

end.
