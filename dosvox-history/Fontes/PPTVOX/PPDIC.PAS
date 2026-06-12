unit ppDic;

interface

uses dvcrt, dvwin, dvwav, dvdic, videovox, dvtradut, dvinter, dvlenum, dvhora, dvsapi4,
    Windows, SysUtils, messages, shellApi, mmsystem, activex,
    ppMsg, ppVars;

procedure ativaDicionario;
function sintEditaDic (var campo: string; x, y, tamanho, tamVisual: integer;
                     altera: boolean): char;

var
    nomeDirSom: string;

implementation

{--------------------------------------------------------}

procedure ativaDicionario;
begin

    if comDic then
    begin
        writeln;
        mensagem ('PPVERATI', 1); {('O verificador já está ativado');}
        writeln;
        exit;
    end;

    writeln;
    mensagem ('PPAGUATI', 1); {('Aguarde, irei ativar o verificador ortográfico');}

    nomeArqDic := sintAmbiente ('DICIONARIO', 'ARQDIC');
    if nomeArqDic = '' then
        nomeArqDic := 'c:\winvox\diciona.dic';

    nomeArqSufixos := sintAmbiente ('DICIONARIO', 'ARQSUFIXOS');
    if nomeArqSufixos = '' then
        nomeArqSufixos := 'c:\winvox\diciona.suf';

    nomeArqInexist := sintAmbiente ('DICIONARIO', 'ARQINEXIST');
    if nomeArqInexist = '' then
        nomeArqInexist := 'c:\winvox\diciona.exc';

    nomeArqNomes := sintAmbiente ('DICIONARIO', 'ARQNOMES');
    if nomeArqNomes = '' then
        nomeArqNomes := 'c:\winvox\diciona.nom';

    nomeArqSugTroca := sintAmbiente ('DICIONARIO', 'ARQSUGERE');
    if nomeArqSugTroca = '' then
        nomeArqSugTroca := 'c:\winvox\diciona.sug';

    if carregaDic (nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0 then
    begin
        mensagem ('PPOKVATI', 1); {('Verificador ativado');}
        mensagem ('PPUSEXZ', 1); {('Edite a linha e use control+X ou control+Z');}
        comDic:= true;
    end
    else
    begin
        mensagem ('PPNAOATV', 1); {('Não consegui ativar o verificador');}
        comDic:= false;
    end;

    writeln;

end;

{--------------------------------------------------------}
{                    edita um item + CTRL+X verifica no dicionário
{--------------------------------------------------------}

function sintEditaDic (var campo: string; x, y, tamanho, tamVisual: integer;
                     altera: boolean): char;
var c, c2: char;
    curx, i: integer;
    primeiraVez: boolean;
    colInic: integer;
    palDic: string;

label fechaCampo;

{--------------------------------------------------------}

    procedure caracComum (c: char);
    begin
        if not altera then
            exit;

        if curx > tamanho then
            begin
                sintBip;
                exit;
            end;

        insert (c, campo, curx);
        delete (campo, tamanho+1, 1);

        gotoxy (x+curx-1, y);
        write (c);

        if soletrando then
            sintCarac (c);
        curx := curx + 1;
    end;

{--------------------------------------------------------}

    procedure delCarac (comDel: boolean);
    var campoPc: string;
        c: char;
    begin
        if not altera then
            exit;

        c := campo [curx];
        delete (campo, curx, 1);
        campo := campo + ' ';

        gotoxy (x, y);
        campoPC := copy (campo, colinic, tamVisual);
        write (campoPC);

        if comDel then sintSom ('_DEL');
        sintCarac(c);
    end;

{--------------------------------------------------------}

    function temVogal (s: string): boolean;
    const
        CONSOANTES: set of char =
        ['B','C','D','F','G','H','J','K','L','M',
         'N','P','Q','R','S','T','V','X','Z'];

    var i: integer;

    begin
        temVogal := true;
        for i := 1 to length (s) do
             if not (upcase (s[i]) in CONSOANTES) then exit;
        temVogal := false;
    end;

{--------------------------------------------------------}

    procedure falaPalavra;
    var palavra: string;
        c: char;
        salvacur: integer;
    begin
        campo := campo + #0;
        salvacur := curx;
        while campo [curx] = ' ' do
            curx := curx + 1;

        c := upcase (campo [curx]);
        case c of
            #0: sintBip;

            'A'..'Z', #128..#255:
                begin
                    palavra := '';
                    repeat
                        palavra := palavra + campo[curx];
                        curx := curx + 1;
                    until not (upcase (campo[curx]) in
                            ['A'..'Z', #128..#255]);
                    if temVogal (palavra) then
                        sintetiza (palavra)
                    else
                        sintSoletra (palavra);
                end;

            '0'..'9', '-':
                begin
                    palavra := '';
                    repeat
                        palavra := palavra + campo[curx];
                        curx := curx + 1;
                    until not (campo[curx] in ['0'..'9']);
                    sintetiza (palavra);
                end;

        else
            begin
                palavra := campo [curx];
                curx := curx + 1;
                sintSoletra (palavra);
            end;
        end { case };

        campo := copy (campo, 1, length(campo)-1);
        if c = #0 then
            curx := salvacur;
    end;

{--------------------------------------------------------}

    procedure avancaPalavra;
    var tam: integer;
        c: char;
    begin
        tam := length (campo);
        campo := campo + ' @';

        c := campo [curx];
        if c <> ' ' then
            if c in ['0'..'9'] then
                repeat
                    curx := curx + 1;
                    c := campo [curx];
                until not (c in ['0'..'9'])
            else
                repeat
                    curx := curx + 1;
                    c := campo [curx];
                until not (c in ['a'..'z', 'A'..'Z', #128..#255]);

        if c = ' ' then
            repeat
                curx := curx + 1;
                c := campo [curx];
            until c <> ' ';

        campo := copy (campo, 1, tam);

        if curx > tam+1 then
            begin
                curx := length(campo)+1;
                repeat
                    curx := curx - 1;
                until (curx = 0) or (campo[curx] <> ' ');
                curx := curx + 1;
                sintBip;
            end
        else
            sintClek;
    end;

{--------------------------------------------------------}

    procedure recuaPalavra;
    var tam: integer;
        c: char;
    begin
        tam := length (campo);
        campo := ' @' + campo;
        curx := curx + 2;

        repeat
            curx := curx - 1;
            c := campo [curx];
        until c <> ' ';

        if c in ['0'..'9'] then
            repeat
                curx := curx - 1;
                c := campo [curx];
            until not (c in ['0'..'9'])
        else
            repeat
                curx := curx - 1;
                c := campo [curx];
            until not (c in ['a'..'z', 'A'..'Z', #128..#255]);

        campo := copy (campo, 3, tam);
        curx := curx - 1;

        if curx <= 0 then
            begin
                curx := 1;
                sintBip;
            end
        else
            sintClek;
    end;

{--------------------------------------------------------}

var campoPc: string;
    buf: array [1..257] of char;
    xx: integer;
    temLetras: boolean;
    sn: string[6];
    v: integer;
    salvaCampo: string;
    nl: integer;
    x1, x2: integer;
    comando: string;

const
    espurios: set of char = ['<', '"', '(', '{', '[', '-', '=', '.', '_', '>', '*'];

label moveu, processaC2;
begin
    if sintFalaAcumulada <> '' then
        sintetiza ('');

    if tamVisual > tamanho then
        tamVisual := tamanho;
    with currentWindow do
        if (y = bottom-top+1) and (x+tamVisual > right-left+1) then
            tamVisual := tamVisual - 1;

    campo := copy (campo, 1, tamanho);
    while length (campo) < tamanho do
        campo := campo + ' ';

    primeiraVez := true;
    curx := 1;
    colInic := 1;
    salvaCampo := campo;

    repeat
        if curx < colInic then colInic := curx;
        if curx > colinic+tamVisual then colInic := curx-tamVisual;

        gotoxy (x, y);
        campoPC := copy (campo, colinic, tamVisual);
        write (campoPC); clreol;
        gotoxy (curx-colinic+x, y);

        c := readkey;
        sintPara;

        if c = #0 then
            begin
                c2 := readkey;
//              sintPara;
processaC2:
                case c2 of
                    ESQ: if curx <= 1 then
                              sintBip
                          else
                              begin
                                  curx := curx - 1;
                                  sintCarac (campo [curx]);
                              end;

                    DIR: begin
                              if curx >= length (campo) then
                                  sintBip
                              else
                                  begin
                                      sintCarac (campo [curx]);
                                      curx := curx + 1;
                                  end;
                         end;

                    HOME: curx := 1;

                    TEND:  begin
                              curx := length (campo)+1;
                              repeat
                                  curx := curx - 1;
                              until (curx = 0) or (campo[curx] <> ' ');
                              curx := curx + 1;
                          end;

                    DEL: delCarac (true);

                    F1:  begin
                             if (getKeyState (VK_MENU) shr 15) <> 0 then
                                 begin
                                     c2 := ALTF1;
                                     goto fechaCampo;
                                 end;
                             falaPalavra;
                         end;

                    F11: ativaDicionario;

                    F12:
                         begin
                             x1 := curx;
                             while (x1 > 1) and (campo[x1-1] <> ' ') do
                                 x1 := x1 - 1;
                             x2 := curx;
                             while (x2 < length(campo)) and (campo[x2] <> ' ') do
                                  x2 := x2 + 1;
                             if campo[x2] = ' ' then x2 := x2 - 1;
                             comando := copy (campo, x1, x2-x1+1);

                            while (comando <> '') and (comando[1] in espurios) do
                                delete (comando, 1, 1);
                            while (comando <> '') and (comando[length(comando)] in espurios) do
                                delete (comando, length(comando), 1);

                             if comando = '' then
                                 sintBip
                             else
                                 executaArquivo (comando);
                         end;

                    F4:  begin
                             soletrando:= not soletrando;
                             if soletrando then
                                 sintSom ('_FALACI')   {Fala acionada}
                             else
                                 sintSom ('_FALDLG');  {Fala desligada}
                         end;

                    CTLF4:  begin
                                sintSom ('_VELOC');    {Qual a velocidade de 1 a 4 ? }
                                repeat
                                    c := sintReadkey;
                                until not keypressed;
                                if (c <> ESC) and (c <> ENTER) then
                                    begin
                                        sintFim;
                                        v := ord (c) - ord('0');
                                        sintInic (v, nomeDirSom);
                                    end;
                            end;

                    F8:     falaHora;

                    CTLF8:  falaDia;

                    CTLF9:  if getKeyState (vk_Menu) < 0 then
                                leitorDeTela
                            else
                                goto fechaCampo;

                    CTLDIR: avancaPalavra;

                    CTLESQ: recuaPalavra;

                    CTLF1:  sintetiza (campo);

                    CTLINS:   begin
                                  xx := length (campo);
                                  repeat
                                      xx := xx - 1;
                                  until (xx = 0) or (campo[xx] <> ' ');
                                  for i := 1 to xx do
                                      buf[i] := campo[i];
                                  buf [xx+1] := #$0;
                                  putClipboard (@buf);
                              end;

                    SHIFTINS:  begin
                                   getClipboard (@buf, length(campo)+1);
                                   fillchar (campo[1], length (campo), ' ');
                                   buf [length(campo)+1] := #$0;
                                   for i := 1 to strLen (@buf)+1 do
                                       begin
                                           if (buf[i] = #$0d) or (buf[i] = #$0a) or
                                              (buf[i] = #$0) then
                                                           goto moveu;
                                           campo[i] := buf [i];
                                       end;
                                   i := strLen (@buf) + 2;
                 moveu:
                                   curx := i;
                               end;

                else
                    goto FechaCampo;
                end
            end
        else
            begin
                c2 := c;
                case c of
                    NOFOCUS: ;
                    GOTFOCUS:  begin
                                   while sintFalando do waitMessage;
                                   sintetiza (campo);
                                   end;

                    ENTER, CTLENTER, ESC: begin
                                    c2 := c;
                                    goto FechaCampo;
                                end;

                    CTLBS:  begin
                                if (curx > 1) and (campo [curx-1] <> ' ') then
                                    recuaPalavra;
                                x1 := curx;
                                avancaPalavra;
                                x2 := curx;
                                recuaPalavra;
                                for i := x1 to x2-1 do
                                    delCarac (i=x1);
                            end;

                    TAB:   goto fechaCampo;

                    BS:    begin
                               if curx = 1 then
                                   sintBip
                               else
                                   begin
                                       curx := curx - 1;
                                       delCarac (true);
                                   end;
                           end;

                    ^K:    begin
                               str (curx, sn);
                               sintetiza (sn);
                           end;

                    ^D:    if altera then
                           begin
                               for i := curx to length (campo) do
                                   campo [i] := ' ';
                               sintSom ('_APFCPO');
                           end;

                    ^S:    if altera then
                           begin
                               nl := length(campo)-curx+1;
                               for i := 1 to nl do
                                   campo [i]:= campo [curx+i-1];
                               for i := nl+1 to length(campo) do
                                   campo [i] := ' ';
                               curx := 1;
                               sintSom ('_APICPO');
                           end;

                    ^U:    if altera then
                                begin
                                    campo := salvaCampo;
                                    curx := 1;
                                    sintBip;
                                    sintBip;
                                    sintBip;
                                end;

                    ^Y:    if altera then
                           begin
                               for i := 1 to length (campo) do
                                   campo [i] := ' ';
                               sintSom ('_CPOAPA');
                               curx := 1;
                           end;

                    ^C:    begin
                               c2 := CTLINS;
                               goto processaC2;
                           end;

                    ^V:    begin
                               c2 := SHIFTINS;
                               goto processaC2;
                           end;

                    ^\:    for i := 1 to length (campo) do
                               sintTelefona (campo [i]);

                    #26: begin
                        if not comDic then
                        begin
                            sintSom ('PPVERDES'); {('Verificador desativado, pressione F11');}
                            exit;
                        end;

                        repeat
                            i:= curx;
                            palDic:= campo;

                            if curx > 1 then
                                delete (palDic, 1, curx - 1);
                            if pos (' ', palDic) <> 0 then
                                delete (palDic, pos (' ', palDic), length (palDic));

                            if length(palDic) > 1 then
                            if not procuraDic (palDic) then
                            begin
                                sintSom ('PPNAOCON'); {('NÃO CONSTA');}
                                sintBip;
                                delay (100);
                                sintetiza (palDic);
                            end
                            else
                                sintSom ('PPOK');

                            avancaPalavra;
                            until curx = i;
                            curx:= 1;
                    end;

                    #24: begin
                        if not comDic then
                        begin
                            sintSom ('PPVERDES'); {('Verificador desativado, pressione F11');}
                            exit;
                        end;

                        palDic:= campo;

                        recuaPalavra;

                        if curx > 1 then
                            delete (palDic, 1, curx - 1);
                        if pos (' ', palDic) <> 0 then
                            delete (palDic, pos (' ', palDic), length (palDic));

                        avancaPalavra;

                        if not procuraDic (palDic) then
                        begin
                            sintBip; sintBip;
                            sintSom ('PPNAOCON'); {('NÃO CONSTA');}
                            curx:= curx - 1;
                        end
                        else
                            sintSom ('PPOK');

                        end

                else
                    if primeiraVez and sintApagaAuto then
                        begin
                             temLetras := false;
                             for i := curx to length (campo) do
                                 if campo [i] <> ' ' then
                                     temLetras := true;
                             if temLetras then
                                 begin
                                     sintClek;
                                     sintClek;
                                     if (c >= #$20) and altera then
                                         for i := 1 to length (campo) do
                                             campo [i] := ' ';
                                 end;
                        end;

                    if c >= #$20 then
                        caracComum (c);
                end;
            end;

        primeiraVez := false;
    until false;

fechaCampo:
    sintEditaDic := c2;
    sintCursorX := curx;

    gotoxy (x, y);
    campoPC := copy (campo, 1, tamVisual);
    write (campoPC);
    gotoxy (x, y);

    curx := tamanho+1;
    repeat
        curx := curx - 1;
    until (curx = 0) or (campo[curx] <> ' ');

    if curx = 0 then
        campo := ''
    else
        campo := copy (campo, 1, curx);
end;

end.
