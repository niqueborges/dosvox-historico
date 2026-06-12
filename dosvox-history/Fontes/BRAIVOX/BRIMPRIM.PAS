{--------------------------------------------------------}
{                  Módulo de impressao
{--------------------------------------------------------}

unit brImprim;
interface
uses dvCrt, dvWin, windows, sysutils, classes,
     brVars, brMsg, brUtil, brLeBuf, brUnif, brAntigo, brDevice;

procedure impressao;

implementation

var
    texto: string;
    nlsai: integer;
    recuoDeDois, sepSilabas: boolean;
    tituloPag: string;
    npagImpressa: integer;
    caracMargemEsq: string;
    maxCaracImpr: integer;
    autoJunta: boolean;

const
    tabAscii: array [0..63] of char = (

  {0}   ' ',  'a',  ',',  'b', '''',  'k',  ';',  'l',
        '^',  'c',  'i',  'f', 'í',   'm',  's',  'p',

  {1}   '~', 'e', ':', 'h', '*', 'o', '!', 'r',
        '@', 'd', 'j', 'g', 'ã', 'n', 't', 'q',

  {2}   '`', 'â', '?', 'ê', '-', 'u', '{', 'v',
        ']', 'ì', 'õ', 'à', 'ó', 'x', 'è', 'ç',

  {3}   '\', 'ù', '.', 'ü', '}', 'z', '(', 'á',
        '_', 'ô', 'w', 'ï', '#', 'y', 'ú', 'é' );

    tabAscii2: array [0..63] of char = (

  {0}   ' ',  'a',  ',',  'b', '''',  'k',  ';',  'l',
        '^',  'c',  'i',  'f', 'í',   'm',  's',  'p',

  {1}   '~', 'e', ':', 'h', '*', 'o', '!', 'r',
        '¬', 'd', 'j', 'g', 'ã', 'n', 't', 'q',

  {2}   'ý', 'â', '?', 'ê', '-', 'u', '"', 'v',
        '{', 'î', 'õ', 'à', 'ó', 'x', 'è', 'ç',

  {3}   '$', 'û', 'ÿ', 'ü', '}', 'z', '=', 'á',
        '_', 'ô', 'w', 'ï', '#', 'y', 'ú', 'é' );

const
    CRLF = #$0d + #$0a;

{--------------------------------------------------------}
{                  escreve o gráfico
{--------------------------------------------------------}

function escreveGrafico (s: string): boolean;
var texto: TStringList;
    x, y: integer;
    xm, ym: integer;
    linha: string;
    b: byte;
    modo: char;

    grafico: array[0..300, 0..300] of boolean;

label pula;

begin
   escreveGrafico := false;

   if (s[1] = '<') and (upcase (s[2]) = 'G') and (s [length (s)] = '>') then
      begin
         modo := s [3];
         if modo = ' ' then modo := '6'
         else delete (s,3,1);

         delete (s,1,3);
         delete (s,length (s),9);
      end
   else
      exit;

    escreveDispositivo (#$1b + modo);

    texto := TStringList.create;
    try
       texto.loadFromFile (s);
    except
       escreveGrafico := false;
       exit;
    end;

    for x := 0 to 300 do
       for y := 0 to 300 do
          grafico [y, x] := false;

    ym := texto.count-1;
    if ym > 300 then ym := 300;
    for y := 1 to ym do
       begin
          s := texto[y];
          xm := length(s);
          if xm > 300 then xm := 300;
             for x := 1 to xm do
                grafico[y, x-1] := s[x] <> ' ';
       end;

  if usaBrailleAntigo then
      begin
          usaBrailleAntigo := false;
          carregaTabBraille;
          usaBrailleAntigo := true;
      end;

  ym := 1;    // descobre limite inferior do gráfico;
  for y := 299 downto 1 do
      begin
          for x := 0 to 299 do
              if grafico [y, x] then
                  begin
                      ym := y;
                      goto pula;
                  end;
      end;

pula:
  for y := 0 to (ym div 3) do
      begin
          linha := '';
          for x := 0 to (299 div 2) do
              begin
                  b := ord(grafico [y*3+0, x*2+0]) shl 0 +
                       ord(grafico [y*3+1, x*2+0]) shl 1 +
                       ord(grafico [y*3+2, x*2+0]) shl 2 +
                       ord(grafico [y*3+0, x*2+1]) shl 3 +
                       ord(grafico [y*3+1, x*2+1]) shl 4 +
                       ord(grafico [y*3+2, x*2+1]) shl 5;
                  linha := linha + chr (tabPrinter [tabAscii2 [b]]);
              end;
          escreveDispositivo (trimRight (linha) + CRLF);
      end;

  escreveDispositivo (#$1b + ']' + CRLF);

  escreveGrafico := true;
  if usaBrailleAntigo then
      carregaTabBraille;
end;

{--------------------------------------------------------}
{             imprime na impressora matricial
{--------------------------------------------------------}

(*
procedure imprimeNaMatricial (texto: string);
var s: string;
    bit, i, linha: integer;
begin
    escreveDispositivo (#$1b +'A' + #$8);  { impressao comprimida }
    for linha := 0 to 2 do
        begin
            s := '';
            for i := 1 to length (texto) do
                begin
                    bit := 1 shl linha;
                    if (tabBraille [texto[i]] and bit) <> 0 then
                        s := s + '.'
                    else
                        s := s + ' ';

                    bit := 8 shl linha;
                    if (tabBraille [texto[i]] and bit) <> 0 then
                        s := s + '.'
                    else
                        s := s + ' ';
                end;

            s := s + '                                        ';
            s := s + '                                        ';

            for i := (maxcarac * 2) downto 1 do
                escreveDispositivo (s[i]);
            escreveDispositivo (#$0d);
            for i := (maxcarac * 2) downto 1 do
                escreveDispositivo (s[i]);
            escreveDispositivo (CRLF);
        end;

    escreveDispositivo (#$1b + 'A' + #$12);  { impressao normal }
    escreveDispositivo (CRLF);
end;
*)

{--------------------------------------------------------}
{                  da Saida
{--------------------------------------------------------}

procedure escreveSaida (texto: string);
var i: integer;
begin
    nlSai := nlSai + 1;
    nlin := nlin + 1;

    if npagImpressa < paginic then exit;
    if npagImpressa > pagfinal then exit;

    texto := caracMargemEsq + texto;
    for i := 1 to length (texto) do
       texto[i] := chr (tabPrinter [texto[i]]);

    if not escreveDispositivo (texto+CRLF) then
        begin
            mensagem ('BRERRESC', 1);  {'Erro de escrita no dispositivo de impressão'}
            mensagem ('BRESCCAN', 1);  {'ENTER continua, ESC cancela'}
            if readkey = ESC then
                begin
                    close (arq);
                    fechaDispositivo;
                    sintFim;
                    doneWinCrt;
                end;
        end;

    if tempoLinha <> 0 then
        delay (tempoLinha);
end;

{--------------------------------------------------------}
{             Escolhe a conversão que será feita
{--------------------------------------------------------}

function convBraille (texto: string): string;
var
   s: string;
begin
   if usaBrailleAntigo  then s := brailleAntigo (texto)
                        else s := brailleUnificado (texto);
   result := s;
end;

{--------------------------------------------------------}
{                     escreve o titulo
{--------------------------------------------------------}

procedure escreveTitulo;
var tituloConv: string;
    i, nbrancos, brAntes, brDepois: integer;
    origConv, numPagConv, salva: string;
    algoFoiImpresso, salvaIng: boolean;

const brancos: string =
    '                                           ';
begin
    npag := npag + 1;
    npagImpressa := npagImpressa + 1;
    algoFoiImpresso := nlin <> 0;
    nlin := 1;

    if (npagImpressa > paginic) and algoFoiImpresso then
        escreveDispositivo (SALTOPAG);

    if npagImpressa > pagFinal then exit;
    if not comTitulo then exit;

    if (tipoCabec <> 2) and (not odd(npagImpressa)) and frenteVerso then exit;
    if npagimpressa < paginic then exit;

    salvaIng := txtIngles;
    txtIngles := cabecIngles;
    tituloConv := convBraille (tituloPag);

    origConv := '';
    if numeraOrig and (odd(npagImpressa) or (not frenteVerso)) and (pagOrig <> 0) then
        begin
            str (pagOrig, origConv);
            origConv := '  ' + convBraille (origConv);
        end;

    str (npag+numinic-1, numPagConv);
    numPagConv := convBraille (numPagConv);

    if frenteVerso and (not odd(npagImpressa)) and afastaCabecPar then
        numPagConv := '  ' + numPagConv;

    nbrancos := maxCarac - length (origConv)
                         - length (tituloConv)
                         - length (numPagConv);

    brAntes := nbrancos div 2;
    brDepois := nbrancos - brAntes;
    tituloConv := copy (brancos, 1, brAntes) + tituloConv +
                  copy (brancos, 1, brDepois);

    if odd(npagImpressa) or (not frenteVerso) then
         tituloConv := origConv + tituloConv + numPagConv
    else
         tituloConv := numPagConv + tituloConv;

    for i := length (tituloConv) downto 1 do
        if tituloConv [i] <> ' ' then
            begin
                delete (tituloConv, i+1, 999);
                break;
            end;

    salva := caracMargemEsq;
    caracMargemEsq := '';
    escreveSaida (tituloConv);
    caracMargemEsq := salva;

    txtIngles := salvaIng;
end;

{--------------------------------------------------------}
{            divide a linha Braille em duas
{--------------------------------------------------------}

procedure quebraSaida (var texto, parte1: string);
var posic: integer;
begin
    if texto [maxCaracImpr+1] = ' ' then
        begin
            posic := maxCaracImpr;
            while (posic > 10) and (texto [posic] = ' ') do
                posic := posic - 1;
            parte1 := copy (texto, 1, posic);
            posic := maxCaracImpr + 2;
            while (posic <= length (texto)) and (texto [posic] = ' ') do
                posic := posic + 1;
            texto := copy (texto, posic, length (texto) - posic + 1);
            exit;
        end;

    if texto[maxCaracImpr] = ' ' then
        posic := maxCaracImpr+1
    else
        begin
            posic := maxCaracImpr;

            while (posic > 10) and (texto[posic-1] <> ' ') and

                not (     { fimsilaba }
                  sepSilabas and
                  (texto[posic-2] <> ' ') and
                      (
                          (texto[posic-1] in VOGAIS) and
                          (texto[posic] in CONSOANTES) and
                          (texto[posic+1] in VOGAIS)
                      )
                      or
                      (
                          (texto[posic-1] in ['S', 's', 'N', 'n', 'R', 'r']) and
                          (texto[posic] in CONSOANTES) and
                          (texto[posic+1] in VOGAIS)
                      )
                      or
                      (
                          (texto[posic-1] in ['L', 'l']) and
                          (texto[posic] in CONSOANTES) and
                          ( not (texto[posic] in ['L', 'l'])) and
                          (texto[posic+1] in VOGAIS)
                      )
                      or
                      (
                          (texto[posic-1] in ['S', 's', 'N', 'n', 'R', 'r']) and
                          (texto[posic] in ['C','c','D','d','F','f','G','g','T','t','V','v']) and
                          (texto[posic+1] in ['R', 'r', 'L', 'l'])
                      )
                      or
                      (
                          (texto[posic-1] in ['M', 'm']) and
                          (texto[posic] in ['P','p','B','b']) and
                          (texto[posic+1] in ['R', 'r', 'L', 'l'])
                      )
                      or
                      (
                          (texto[posic-1] in VOGAIS) and
                          (texto[posic] in ['n', 'c', 'l', 'N', 'C', 'L']) and
                          (texto[posic+1] in ['H', 'h'])
                      )
                )

                do
                       posic := posic - 1;
            if posic = 10 then posic := maxCaracImpr;
        end;

    parte1 := copy (texto, 1, posic-1);
    if texto[posic-1] <> ' ' then
        parte1 := parte1 + '-'
    else
        while (length (parte1) > 0) and (parte1 [length (parte1)] = ' ') do
            delete (parte1, length(parte1), 1);

    texto  := copy (texto, posic, length(texto)-posic+1);
end;

{--------------------------------------------------------}
{           descarrega a linha já convertida
{--------------------------------------------------------}

procedure descarregaLinha (limpaTudo: boolean);
var s, parteInic: string;
    aIncluir: integer;
    i: integer;
begin
    s := trimRight (sobraAnterior);

    repeat
        if (nlin = 0) or (nlin > maxlin) then
            escreveTitulo;

        if (nlin = 1) and (npag > 1) and (s = '') and tiraBrancasInicioPag then
            begin
                sobraAnterior := '';
                exit;
            end;

        if centrando then
            begin
                s := trim (s);
                if length (s) > maxCaracImpr then
                    quebraSaida (s, parteInic)
                else
                    begin
                        parteInic := trim (s);
                        s := '';
                    end;

                aIncluir := (maxCaracImpr - length (parteInic)) div 2;
                for i := 1 to aIncluir do
                    parteInic := ' ' + parteInic;

                escreveSaida (parteInic);
                sobraAnterior := s;
            end

        else
        if length (s) > maxCaracImpr then
            begin
                quebraSaida (s, parteInic);
                escreveSaida (parteInic);

                sobraAnterior := s;
                if recuoDeDois then  s := '  ' + s;
            end
        else
            begin
                if limpaTudo then
                    begin
                        escreveSaida (s);
                        sobraAnterior := '';
                    end
                else
                    sobraAnterior := s;
                s := '';
            end;

    until (s = '');

    if sobraAnterior <> '' then
        sobraAnterior := sobraAnterior + ' ';
end;

{--------------------------------------------------------}
{                   converte uma linha
{--------------------------------------------------------}

procedure converteLinha (texto: string);
begin
    if autoJunta and (sobraAnterior <> '') then
       if (texto = '') or (texto[1] = ' ') or (texto[1] = '•') then
           descarregaLinha (true);

    if texto = '' then
        begin
           descarregaLinha (true);
           exit;
        end;

    if autojunta and (texto[1] = ' ') and (texto[2] <> ' ') then
        delete (texto, 1, 1);

    sobraAnterior := sobraAnterior + convBraille (texto);

    descarregaLinha (not autoJunta);
end;

{--------------------------------------------------------}
{             troca os TABS por dois brancos
{--------------------------------------------------------}

procedure tiraTabs (var texto: string);
const TAB = #$09;
var i: integer;
begin
    for i := length(texto) downto 1 do
        begin
            if texto[i] = TAB then
                begin
                    insert (' ', texto, i);
                    texto [i+1] := ' ';
                end;
        end;
end;

{--------------------------------------------------------}
{    remove brancos ao final e so' deixa dois no inicio
{--------------------------------------------------------}

procedure compactaLinha (var texto: string);
begin
    while (texto <> '') and (texto [length (texto)] = ' ') do
        delete (texto, length(texto), 1);

    if autoJunta then
        while (length (texto) > 2) and
          (texto [1] = ' ') and (texto [2] = ' ') and (texto [3] = ' ') do
            delete (texto, 1, 1);
end;

{--------------------------------------------------------}
{              processa controles do texto
{--------------------------------------------------------}

function processaControles (texto: string): boolean;
var erro: integer;
begin
    processaControles := false;
    if (length (texto) = 1) then
        begin
            processaControles := false;
            exit;
        end;

    if (texto = '<p>') or (texto = '<P>') then
        begin
            if autoJunta and (sobraAnterior <> '') then
                descarregaLinha (true);

            escreveTitulo;
        end
    else

    if upcase (texto[2]) = 'T' then
        begin
            if autoJunta and (sobraAnterior <> '') then
                descarregaLinha (true);

            if copy (texto, 3, 2) = '->' then
                comTitulo := false
            else
            if copy (texto, 3, 2) = '+>' then
                comTitulo := true
            else
            if (length (texto) >= 5) and
               (copy (texto, 3, 1) = '+') and
               (texto [4] in ['0'..'9']) and
               (texto [length(texto)] = '>') then
                   begin
                       comTitulo := true;
                       val (copy (texto, 4, length(texto)-4), npag, erro);
                       npag := npag - 1;
                       escreveTitulo;
                   end
            else
                begin
                    tituloPag := copy (texto, 3, length (texto)-2);
                    if tituloPag [length(tituloPag)] = '>' then
                        delete (tituloPag, length(tituloPag), 1);
                end;
        end
    else

    if upcase (texto[2]) = 'F' then
        begin
            if autoJunta and (sobraAnterior <> '') then
                descarregaLinha (true);

            if copy (texto, 3, 2) = '->' then autoJunta := false
            else
            if copy (texto, 3, 2) = '+>' then autoJunta := true;
        end
    else

    if upcase (texto[2]) = 'S' then
        begin
            if copy (texto, 3, 2) = '->' then sepSilabas := false
            else
            if copy (texto, 3, 2) = '+>' then sepSilabas := true;
        end
    else

    if upcase (texto[2]) = 'R' then
        begin
            if autoJunta and (sobraAnterior <> '') then
                descarregaLinha (true);

            if copy (texto, 3, 2) = '+>' then recuoDeDois := true
            else
            if copy (texto, 3, 2) = '->' then recuoDeDois := false;
        end
    else

    if upcase (texto[2]) = 'I' then
        begin
            if copy (texto, 3, 2) = '->' then txtIngles := false
            else
            if copy (texto, 3, 2) = '+>' then txtIngles := true;
        end
    else

    if upcase (texto[2]) = 'G' then
       begin
          if autoJunta and (sobraAnterior <> '') then
                descarregaLinha (true);

          if (npag mod 2) = 1 then
             begin
               if not escreveGrafico (texto) then
                  begin
                     mensagem ('BRGRFNAO', 1); {'Arquivo gráfico não foi achado'}
                     exit;
                  end;

                escreveDispositivo (CRLF);
                nlSai := nlSai + 1;
                escreveDispositivo (SALTOPAG);
             end
          else
             begin
                escreveTitulo;
                if not escreveGrafico (texto) then
                    begin
                        mensagem ('BRGRFNAO', 1); {'Arquivo gráfico não foi achado'}
                        exit;
                    end;

                escreveDispositivo (CRLF);
                escreveTitulo;
                npag := npag + 1;
             end;
       end
    else

    if upcase (texto[2]) = 'M' then
        begin
            if sobraAnterior <> '' then
                descarregaLinha (true);
            maxCaracImpr := maxCarac;

            caracMargemEsq := copy (texto, 3, 999);
            if (caracMargemEsq <> '') and
                (copy (caracMargemEsq, length(caracMargemEsq), 1) = '>') then
                    delete (caracMargemEsq, length(caracMargemEsq), 1);
            if length (caracMargemEsq) > maxCarac-2 then
                caracMargemEsq := copy (caracMargemEsq, 1, maxCarac-2);

            maxCaracImpr := maxCaracImpr - length (caracMargemEsq);
        end

    else
    if texto[2] in ['0'..'9'] then
        begin
            erro := 1;
            if texto [length(texto)] = '>' then
                val (copy (texto, 2, length(texto)-2), pagOrig, erro);
            if erro <> 0 then exit;   {retorna falso}
        end;

    processaControles := true;
end;

{--------------------------------------------------------}
{                   corpo da impressao
{--------------------------------------------------------}

procedure impressao;
label
    impr, fim, ok, naoImprime;

begin
    linhaNoRascunho := 0;
    nlSai := 0;

    nlin := 0;
    npag := 0;
    npagImpressa := 0;
    pagOrig := 0;
    texto := '';
    sobraAnterior := '';
    abre_aspas := true;
    abriuParentLiterario := false;
    abre_aspas_inu := true;
    txtIngles := textoIngles;
    sepSilabas := separaSilabas;
    autoJunta := autoFormata;
    tituloPag := titulo;

    maxCaracImpr := maxCarac;
    caracMargemEsq := '';

    inicBufArq;
    while not fimDoArq do
        begin
            if npag > pagFinal then goto fim;

            texto := carregaUmaLinha;
            if veioDoEdit then
                oemToAnsi (pchar (texto), pchar (texto));
            tiraTabs (texto);

            centrando := autoJunta and (length (texto) > 10) and
                         (copy (texto, 1, 10) = '          ');

            compactaLinha (texto);

            if (texto <> '') and (texto[1] = '<') then
                begin
                    if not processaControles (texto) then
                        converteLinha (texto);
                end
            else
                converteLinha (texto);
        end;

    if (npag <= pagFinal) and (sobraAnterior <> '') then
        descarregaLinha (true);

    if nlin > 1 then
        begin
            escreveDispositivo (SALTOPAG);
            npag := npag + 1;
        end;

fim:
    if (not odd(npag)) and (npag > 0) and (frenteVerso) then
        begin
            escreveDispositivo (CRLF);
            nlSai := nlSai + 1;
            escreveDispositivo (SALTOPAG);
        end;
end;

end.
