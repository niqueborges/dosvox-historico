{
    VoxTube - utilitário de acessibilização do YouTube  ;

Módulo de interação com o usuário;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_men;
interface
procedure processaFuncao (c1, c2: char; apertouShift: boolean;
                         ultFolheado: integer;
                         var mudouPagina: boolean);

implementation
uses
dvcrt,
dvwin,
dvhora,
sysutils,
vt_aju,
vt_fun,
vt_var,
vt_msg;

procedure processaFuncao (c1, c2: char; apertouShift: boolean;
                         ultFolheado: integer;
                         var mudouPagina: boolean);
var clipboardAcum : string;

label denovo, informenomedoarquivo, fazdownload;

const
    NOPLAYER = false;
    NONAVEGADOR = true;

begin
    mudouPagina := false;

denovo:
    clrscr;
    case upcase(c1) of
        ESC:  begin
                  mensagem ('VTFOLTRM', 1); {'Folheamento terminado'}
                  mudouPagina := true;
              end;

        ENTER:
            begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
                tocavideo (filme.paginaWeb[ultfolheado], NOPLAYER);
            end;

        #10:   tocavideo (Filme.paginaWeb[ultfolheado], NONAVEGADOR);

        'S': begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
                salvaFilme (ultfolheado);
             end;

        'M': begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
                Extraiaudio(ultfolheado);
             end;

        tab:
begin
sintclek;
pagatual := pagatual + 1;
mudoupagina := true;
end;

        #8:
if pagatual > 1 then
begin
sintclek;
                     pagAtual := pagAtual - 1;
                     mudouPagina := true;
                 end
else begin
sintbip;
    mensagem('VTPAG', 0);  {'Página: '}
sintwriteint(pagatual);
end;

        'Q': begin
                textColor (YELLOW);
                writeln (Filme.titulo[ultfolheado]);
                textColor (WHITE);
                writeln;
                sintWriteln (intToStr(ultFolheado+1) +' de '+inttostr(quantoslinks)+', na página '+ intToStr (pagAtual) + '.');
                writeln;
                sintClek;
             end;

        'D': begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
sintclek;
infovideoselec(false,ultfolheado);
end;

        ^D: begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
sintclek;
infovideoselec(true, ultfolheado);
end;

'I': begin
                 textColor (yellow);
                 writeln (Filme.titulo[ultfolheado]);
                 textColor (white);

                 sintClek;
                 writeln;
                 writeln;

                 sintClek;
                 mensagem ('VTAUTOR', 0);  {'Autor: '}
                 textColor (yellow);
                 sintWriteln (Filme.autor[ultfolheado]);
                         sintClek;
                         textColor (white);
                                 mensagem ('VTTRANSM', 0);   {'Transmitido em: '}
                                 textColor (yellow);
                                 sintWriteln (Filme.datapub[ultfolheado]);
                                 textColor (white);

                         sintClek;
                         textColor (white);
                         mensagem ('VTDURA', 0);   {'Duração: '}
                         textColor (yellow);
                         sintWriteln (Filme.duracao[ultfolheado]);

                         sintClek;
                         textColor (white);
                         mensagem ('VTVISUAL', 0);  {'Visualizações: '}
                         textColor (yellow);
                         sintWriteln (Filme.visto[ultfolheado]);

                 textColor (white);
                 writeln;
             end;

        ^C:  // control-c   -->  titulo<crlf>paginaweb<crlf>
             begin
clipboardacum := '';
clipboardacum := filme.titulo[ultfolheado]+crlf+filme.paginaweb[ultfolheado];
putclipboard(pchar(clipboardacum));
sintclek;
end;

        ^l:
            begin
putclipboard(pchar(filme.paginaweb[ultfolheado]));
sintclek;
            end;

                 'A': sintetiza (Filme.autor[ultfolheado]);
                 'V': sintetiza (Filme.visto[ultfolheado]);
                 'P': sintetiza (Filme.datapub[ultfolheado]);
                 'T': sintetiza (Filme.duracao[ultfolheado]);

        #0:  case c2 of
dir: sintetiza (Filme.autor[ultfolheado]);
ctldir: begin
                if sintFalarTudo then mensagem ('VTMOMENT', 1);   {'Um momento.'}
sintclek;
infovideoselec(false, ultfolheado);
end;
esq:
if apertoushift then
 sintetiza (Filme.visto[ultfolheado])
else
 sintetiza (Filme.datapub[ultfolheado]);
ctlesq: sintetiza (Filme.duracao[ultfolheado]);
                 DEL: sintetiza (versao);

                 F1: ajuda;
                 F8: falaHora;
                 CTLF8: falaDia;
                 F9: begin
                        if ultFolheado > 0 then
                            begin
                                writeln (Filme.titulo[ultfolheado]);
                                writeln;
                            end;

                         c1 := selSetasOpcao;
                         goto denovo;
                     end;
             end;
    end;
end;

end.
