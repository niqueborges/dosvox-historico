unit doshabil;
interface
uses dvcrt, dvwin, windows, sysUtils,
     dosmsg, dvform;

procedure provaDeHabilidade;

implementation

var
    nivel, repet: integer;
    tempoTotal: integer;
    nBack: integer;
    nErradas: integer;
    soletrandoHabil: boolean;

const
    msgRepet: array [1..5] of string = (
        'Digite uma vez',
        'Digite duas vezes',
        'Digite três vezes',
        'Digite quatro vezes',
        'Digite cinco vezes'
    );

    questoes: array [0..9, 0..10] of string = (
        (' cada conjunto de letras que vou soletrar,'+^M^J+
                'apertando enter após cada conjunto.',

         'Sasdfg', 'Sçlkjh', 'Sqwert', 'Spoiuy',
         'Szxcvb', 'S;.,mn', 'S12345', 'S09876',
         'Saeiou', 'Sdosvox'
        ),
        (' cada palavra que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Ffada', 'Flata', 'Fmala', 'Fjaca',
         'Fbala', 'Fbanana', 'Fmata', 'Frasga',
         'Flama', 'Fsalada'
        ),
        (' cada palavra que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Fponta', 'Fmonte', 'Fcanto', 'Fjunto',
         'Ftomar', 'Fcarta', 'Fsolta', 'Fnorma',
         'Ftrama', 'Flonga'
        ),
        (' cada palavra sem acento que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Fqual', 'Fquase', 'quanto', 'Fquero',
         'Faquilo', 'Fquerido', 'Fquente', 'Ftoque',
         'Faquele', 'Frequerimento'
        ),
        (' cada palavra que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Fponteagudo', 'Fresponsabilidade', 'Fhorripilante', 'Fergonomia',
         'Fprovidencial', 'Fquadrado', 'Frelojoeiro', 'Frecomendado',
         'Fabsolutamente', 'Fmentiroso'
        ),
        (' cada conjunto de números que vou soletrar,'+^M^J+
                          'apertando enter após cada conjunto.'+^M^J+
                          'Sugestão: use o teclado numérico quando possível.',

         'S12345', 'S67890', 'S12313', 'S12346',
         'S45646', ',+-*/',  'S2+1=3', 'S3-2=1',
         'S3*2=6', 'S8/4=2'
        ),
        (' cada palavra acentuada que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Ffácil', 'Fúltimo', 'Fcafé', 'Fmétodo',
         'Ftomar', 'Fvício', 'Ffútil', 'Fgótico',
         'Ftrama', 'Flonga'
        ),
        (' cada palavra acentuada que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.',

         'Fcoração', 'Femoções', 'Fpaixão', 'Frazões',
         'Ftração', 'Fnoções', 'Fcamaleão', 'Fhabitação',
         'Fladrão', 'Fpunções'
        ),
        (' cada uma das frase que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.'+^M^J+
          'Comece as frases com letra maiúscula e termine com ponto.'+^M^J+
          'Não use vírgulas.',

         'FComer é bom.',
         'FNão é verdade.',
         'FEla está doente.',
         'FÉ um caso sério.',
         'FEle não é nordestino.',
         'FNós estaremos aqui.',
         'FVamos até o infinito.',
         'FAquela pessoa é encantadora.',
         'FEsta pessoa não é fofoqueira.',
         'FBeleza não é sinal de sucesso.'
        ),

        (' cada uma das frase que vou ditar,'+^M^J+
                          'apertando enter após cada uma delas.'+^M^J+
          'Comece as frases com letra maiúscula e termine com ponto.'+^M^J+
          'Não use vírgulas.',

         'FHoje sou feliz e canto.',
         'FQuem tudo quer tudo perde.',
         'FOs últimos serão os primeiros.',
         'FTrabalhando duro se alcança a vitória.',
         'FCada vez mais temos certeza do sucesso.',
         'FO Rio de Janeiro é uma cidade do Brasil.',
         'FPindamonhangaba está situada no interior de São Paulo.',
         'FRedemoinhos de estrelas invadem teu pensamento.',
         'FReais e dólares são muito utilizados no comércio.',
         'FDeveria cuidar mais de sua saúde corporal e mental.'
        )
    );

procedure exibeTeste (estilo: char; letras: string);
var n: integer;
begin
    delay (500);
    textColor (YELLOW);
    if estilo = 'S' then
        begin
            writeln (letras);
            limpaBufTec;
            for n := 1 to length(letras) do
                begin
                    limpaBufTec;
                    sintSoletra (letras[n]);
                    delay(500);
                end;
        end
    else
        begin
            limpaBufTec;
            sintWriteln (letras);
        end;
    textColor (WHITE);
end;

function pegaPalavras (estilo: char; palavra: string; repet: integer;
                       var tempoParcial: integer): boolean;
var lido: string;
    c: char;
    i: integer;
    h1, m1, s1, c1, h2, m2, s2, c2: word;
label tudoDeNovo, deNovo;
begin
tudoDeNovo:
    while not keypressed do;
    getTime(h1, m1, s1, c1);

    for i := 1 to repet do
        begin
deNovo:
            lido := '';
            repeat
                gotoxy (1, wherey);
                write (lido);
                clreol;

                c := readkey;
                case c of
                ESC:
                    begin
                        writeln;
                        mensagem ('DV_DESIST', 1);  {'Desistiu'}
                        result := false;
                        exit;
                    end;
                ENTER:
                    begin
                        writeln;
                        if lido = '' then
                            begin
                                exibeTeste (estilo, palavra);
                                if i = 1 then
                                    goto tudoDeNovo   // reseta tempo se foi a primeira vez
                                else
                                    goto deNovo;      // senão continua contando tempo
                            end
                        else
                        if lido = palavra then
                            sintClek
                        else
                            begin
                                sintBip;
                                nErradas := nErradas + 1;
                            end;
                   end;
                #0: if readkey = F4 then
                        soletrandoHabil := not soletrandoHabil;
              #$08: begin
                        nback := nback + 1;
                        if lido <> '' then
                            begin
                                c := lido[length(lido)];
                                sintSom ('_DEL');
                                sintCarac (c);
                                delete (lido, length(lido), 1);
                            end;
                    end;
                else
                    lido := lido + c;
                    write (c);
                    if soletrandoHabil then
                        sintCarac(c);
                end;

            until c = ENTER;
        end;

    getTime(h2, m2, s2, c2);
    tempoParcial := (((h2*60+m2)*60+s2)*100+c2)-(((h1*60+m1)*60+s1)*100+c1);
    result := true;
end;

procedure diagnostico;
var t, min, seg, cent: integer;
begin
    clrScr;
    textBackground (RED);
    mensagem ('DV_DIAGTEC', 2);    {'Diagnóstico de sua habilidade hoje'}
    textBackground (BLACK);

    mensagem ('DV_DIAGNIVEL', 0);      {'Nível de dificuldade: '}
    sintWriteln (intToStr(nivel));
    mensagem ('DV_DIAGREPET', 0);      {'Repetições de cada teste: '}
    sintWriteln (intToStr(repet));

    mensagem ('DV_TEMPOTEC', 0);      {'Seu tempo de teclagem: '}
    t := tempoTotal;
    cent := t mod 100;
    t := t div 100;
    seg :=  t mod 60;
    min := t div 60;

    if min = 1 then
        sintWrite (intToStr (min) + ' minuto, ')
    else
    if min > 1 then
        sintWrite (intToStr (min) + ' minutos, ');
    if seg > 0 then
        sintWrite (intToStr (seg) + ' segundos, ');
    sintWriteln (intToStr (cent) + ' centésimos.');

    mensagem ('DV_ERRTESTEC', 0);  {'Número de testes com erro: '}
    sintWriteln (intToStr(nErradas));
    mensagem ('DV_CORRTEC', 0);    {'Número de correções: '}
    sintWriteln (intToStr(nBack));
    writeln;
    writeln;
end;

procedure habilidade (nivel, repet: integer);
var i: integer;
    q: string;
    estilo: char;
    tempoParcial: integer;
begin
    writeln;
    textBackground (BLUE);
    mensagem ('DV_INITEC', 2);     {'Iniciando o teste de habilidade'}
    textBackground (BLACK);

    sintWriteln (msgRepet[repet] + questoes [nivel, 0]);   {'Digite n vezes...'}

    tempoTotal := 0;
    nback := 0;
    nErradas := 0;
    soletrandoHabil := true;

    while sintFalando do;
    delay (1000);

    for i := 1 to 10 do
        begin
            q := questoes[nivel, i];
            estilo := q[1];
            delete (q, 1, 1);

            exibeTeste (estilo, q);

            if not pegaPalavras (estilo, q, repet, tempoParcial) then break;
            tempoTotal := tempoTotal + tempoParcial;
        end;

     diagnostico;
end;

{--------------------------------------------------------}

procedure provaDeHabilidade;
var c: char;
begin
    clrScr;
    textBackground (BLUE);
    mensagem ('DV_HABTEC', 2);     {'Dosvox - Habilidade de Teclado'}
    textBackground (BLACK);

    mensagem ('DV_REPTEC', 0);     {'Quantas repetições deseja fazer (entre 1 e 5)? '}
    c := popupMenuPorLetra ('12345');

    if c = '?' then   // ? pede para ver de novo o diagnóstico
        begin
            if nivel = 0 then
                mensagem ('DV_NAOHABTEC', 2)   {'Não há provas de habilidade registradas'}
            else
                diagnostico;
            exit;
        end;

    if c in ['1'..'5'] then
        repet := ord(c)-ord('0')
    else
        begin
            mensagem ('DV_OPCINV', 2);    {'Opção inválida'}
            exit;
        end;

    mensagem ('DV_DIFTEC', 0);     {'Qual o nível de dificuldade (entre 0 e 9)? '}
    c := popupMenuPorLetra ('0123456789');
    if c in ['0'..'9'] then
        nivel := ord(c)-ord('0')
    else
    if c = ESC then
        begin
            mensagem ('DV_DESIST', 2);   {'Desistiu'}
            exit;
        end
    else
        begin
            mensagem ('DV_OPCINV', 2);    {'Opção inválida'}
            exit;
        end;

    habilidade(nivel, repet)
end;

end.

