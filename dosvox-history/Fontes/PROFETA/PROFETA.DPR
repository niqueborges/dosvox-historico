{--------------------------------------------------------------------}
{      Programa : Profeta.pas
{      Author   : Kelly
{      Data     : 01/08/94
{--------------------------------------------------------------------}

uses dvcrt, dvwin, windows;
const
    N_Emocao = 44;
    N_Quem = 41;
    N_Previsao = 66;
    CRLF = #$0d#$0a;

var
    usouEmocao: array [1..N_Emocao] of boolean;
    usouQuem: array[1..N_Quem] of boolean;
    usouPrevisao: array[1..N_Previsao] of boolean;
    aFalar: array [1..10] of string;
    textoTotal: string;

const
    titulo = 'ASSIM FALOU O PROFETA';

    Emocao : array [1..N_Emocao] of string = (
        'a Vida', 'a Esperança','o Amor','a Guerra','a Paz','os Sem Coração','a Praga',
        'a Luxúria','a Justiça','a Viagem','a Dificuldade','as Perdas',
        'o Esquecimento','a Visão','a Escolha','a Cegueira','a Feiúra',
        'a Beleza','o Hábito','a Vida Saudável','a Ignorância',
        'os Amigos','o Mal','o Bem','a Água','o Ar','as Grandes Perdas',
        'as Antigas Histórias','as Renúncias','a Música','a Luz','a Escuridão',
        'o Conhecimento','o Corpo','a Mente','a Desforra','a Destruição',
        'os Papéis','a Sabedoria','os Trabalhos','os Drogados',
        'o Mundo da Escuridão','os Segredos','os Sábios');

    Quem : array[1..N_Quem] of string = (
        'o Carro','o Albatroz','o Desengonçado','o Coringa',
        'o Ceifador', 'o Desalmado','aquele que tem Maldade no Coração',
        'o Senhor d~E', 'a Criança', 'o Guardião d~E', 'o Ceifador d~E',
        'o Cavaleiro','aquele que Canta com os Pássaros','a fonte de todos ~E',
        'o Mestre','o Campeão','o Mago',
        'o Herdeiro d~E','o Esperto','o Pequeno','o Velho',
        'o Intrigante','aquele que tem o Poder sobre ~E',
        'aquele que traz ~E','aquele que se aliou a~E', 'aquele que Clama sobre ~E',
        'o Amante d~E','o Consorte d~E','aquele que Define as Normas',
        'aquele que vive na Poeira das Ruas', 'o Primeiro e Único',
        'o Sábio e Poderoso', 'o Louco','o Ímpio', 'o Governante',
        'o Filho da Terra','o Mentor d~E','a Criança Grande',
        'o Homem Triste', 'o Desesperado', 'o seu Defensor'
        );

    Previsao: array[1..N_Previsao] of string = (
         'você imagina que ~P. Você conjecturou sobre isso e talvez de forma '
               +'inconsciente uma decisão importante foi tomada.',
         'a postura dos que lhe cercam lhe transmite uma insegurança muito grande. ~P.',
         'você pensa que a dor será inevitável, mas confie, e ~Q '
               +'vai trazer o que você mais deseja de volta sob uma perspectiva '
               +'mais definida.',
         'você vai se livrar de alguns bens materiais com a ajuda d~Q. '
               +'Isso é preciso para alinhar sua vida e tornar você uma pessoa mais humana.',
         'um som estridente, um dia soará em seu caminho. Será alguém que '
               +'você já não esperava, com notícias d~Q.',
         'você quer agir imediatamente mas não responda nada definitivo. '
               +'Deixe uma breve mensagem, pois a hora dos grandes ajustes '
               +'está muito próxima.',
         'uma mensagem poderá fazer você sofrer muito, mas saiba que '
               +'~Q sorri para você.',
         'você sobreviverá a esses momentos, não tema. É que '
               +'~Q agora exige que você mostre que aprendeu e é digno da confiança.',
         'sua vida foi exatamente o que você plantou.',
         'você um dia terá crises de depressão e sentimentos e de inutilidade.',
         'você nutrirá um desejo secreto de tornar-se como ~Q. '
               +'Obedeça a este desejo, é o melhor que tem a fazer.',
         'seu karma não é muito difícil e ~P.',
         'a Força está intensa em seu íntimo esperando para ser libertada.',
         'seus parentes algumas vezes divergem de você. Apesar disso ~P.',
         'sua face traduz o estado geral de sua alma. ~P.',
         'o papel não trará exatamente aquela mensagem que você tanto espera.',
         'você não deve se preocupar, vai suportar todas as provas.',
         'você fará uma viagem em breve.  Ela trará algumas novidades: ~P.',
         'você sentirá que pode fazer muito mais com o seu potencial. ~P.',
         'você não poderia mesmo estar completamente satisfeito com sua posição. ~P.',
         'as coisas já começaram a melhorar, portanto não se preocupe.',
         'esta coisa que afetou o seu corpo está agora falando mais alto e você compreende. ~P.',
         'os estranhos contactarão você este ano. Você os irá '
              +'reconhecer, eles darão o sinal.',
         'aquilo que você quer, você conseguirá obter.',
         'você vai ganhar alguns bens inesperados em um sorteio. Obedeça ao que ordena ~Q.',
         'seu nome mudará algumas vezes nos próximos anos. '
              +'Não tema, você não será obrigado a mudar nada que seja ligado a~Q.',
         '~Q vai continuar a influenciar você, não importa para onde você vá.',
         'amigos prudentes podem dizer: "~P".',
         'você deve tentar escapar d~Q a cada momento. Seja vigilante nisso.',
         'você não deve confiar nas previsões que lhe fizeram. '
              +'Olhe seu interior e descubra sua verdade.',
         'o que poderia ser uma leve neblina está hoje limitando sua percepção.',
         'seu corpo vai a pouco ficando diferente. Sim, existe uma causa. ~P.',
         'boas novas esperam por você a cada esquina.',
         'o problema não é o que você faz, mas como você faz.',
         'o triunfo o espera ao final. Olhe para ~Q, ele será seu guia.',
         'sua vida é um sobe-desce. Neste momento você poderia se sentir '
              +'descendo, mas não é assim.',
         'você tem um futuro de coisas lindas. Mas não poderá nunca descansar: ~P.',
         'você está sentindo um desejo ardente de obter mais respostas, '
              +'mas nada será mostrado neste momento.',
         'você deveria tomar mais conta de seu trabalho. Mesmo que ~Q o atrase, '
              +'não esmoreça.',
         '~Q previu que ~P. Não é bem isso, penses e você entenderá.',
         '~Q não deveria ter tanta certeza do que diz. Entretanto, ~P.',
         'a afirmação d~Q é que ~P. Todo mal pode ser evitado: leia o que escreveu ~Q.',
         'o mundo vai sorrir para você, e você vai ficar surpreso ao descobrir que ~P.',
         'não pode atribuir maior importância ao tratamento severo que lhe impõe ~Q.',
         'é provável que ~Q possa ajudá-lo, mas siga sempre seu coração.',
         'eu vejo claramente: ~P.',
         '~Q reafirma que ~P.',
         'a mensagem críptica que você encontrou indica que ~P.',
         'se o que aconteceu não é nada agradável, um dia se tornará claro que ~P.',
         'o que parece não ser, pode na verdade ser, pois tudo pode ser mudado. Confie: ~P.',
         'não deve ignorar o que ~Q diz, para que não venha a provocar uma decepção desnecessária.',
         'sua vida se parece muitas vezes com um turbilhão. Assim ~P.',
         '~Q tem as respostas que você ansiosamente busca.',
         'alguns falsos colegas sopram inverdades. Porém ~Q irá conduzir você com vigor.',
         'você deve trabalhar duro confiando em si mesmo. Está claro que ~P.',
         '~Q vem dizendo que ~P. Só que muito mais se espera de você.',
         'envie os recursos, como lhe pediu ~Q. Aja com cautela: ~P.',
         'você deve lavar suas mãos na presença d~Q, mesmo sabendo que ~P.',
         'cuidado, ~Q disse que ~P. Pode ser, mas ~P.',
         'disse ~Q: "Eu vejo que ~P". Mas ouça bem: ~P.',
         'saiba que ~P. Tudo isso ~Q viu e avisou. Lembre-se, é preciso sempre agir com prudência.',
         'tudo indica que ~P.',
         '~Q sabe muito mais do que você pensa. Você logo vai tomar ciência que ~P.',
         'você receberá uma mensagem d~Q. Ignore-a com a consciência tranquila.',
         'ouça bem, dê atenção a~Q, que lhe mostrará o que paira sobre sua cabeça é sério mas tem solução.',
         'está muito claro que ~P.'
     );

{--------------------------------------------------------}

var saida: string;
    n: integer;

procedure analisa (s: string);
var i: integer;
begin
    i := 1;
    while i <= length (s) do
        begin
            if s[i] = '~' then
                begin
                    i := i + 1;
                    case s[i] of
                        'E': begin
                                  repeat
                                       n := random (N_Emocao) + 1;
                                  until not usouEmocao[n];
                                  usouEmocao[n] := true;
                                  analisa (emocao[n]);
                             end;
                        'Q': begin
                                  repeat
                                       n := random (N_Quem) + 1;
                                  until not usouQuem[n];
                                  usouQuem[n] := true;
                                  analisa (quem[n]);
                             end;
                        'P': begin
                                  repeat
                                       n := random (N_previsao) + 1;
                                  until not usouprevisao[n];
                                  usouPrevisao[n] := true;
                                  analisa (previsao[n]);
                             end;
                    end;
                end
            else
                saida := saida + s[i];

            i := i + 1;
        end;
end;

{--------------------------------------------------------}

procedure ajusta (var saida: string);
var i: integer;
begin
    for i := length (saida)-1 downto 1 do
        if (saida[i] = 'a') and (saida[i+1] = 'a') then
            begin
                delete (saida,i, 1);
                saida[i] := 'à';
            end;
    for i := length (saida)-1 downto 1 do
        if (saida[i] = '.') and (saida[i+1] = '.') then
            delete (saida,i, 1);
    for i := length (saida)-1 downto 1 do
        if (saida[i] = '.') and (saida[i+1] = '"') then
            delete (saida,i, 1);
    for i := length (saida)-2 downto 1 do
        if (saida[i] = '.') and (saida[i+1] = ' ') and (saida[i+2] in
                        ['a'..'z']) then
            saida[i+2] := upcase (saida[i+2]);
    saida[1] := upcase (saida[1]);
    if saida[1] = 'é' then saida[1] := 'É';

end;

{--------------------------------------------------------}

procedure formata (saida: string);
var i, nc: integer;
begin
    nc := 0;
    for i := 1 to length (saida) do
        begin
            write (saida[i]);
            textoTotal := textoTotal + saida[i];
            nc := nc + 1;
            if (saida[i] = ' ') and (nc > 60) then
                begin
                    writeln;
                    nc := 0;
                end;
        end;
    writeln;
    textoTotal := textoTotal + CRLF;
end;

{--------------------------------------------------------}

var
    i, numpar, cod_erro: integer;
begin
     sintInic (0, '');
     textbackground(blue);
     textcolor(white);
     clrscr;

     saida := titulo;
     sintWriteln (saida);
     writeln;
     textoTotal := saida + CRLF + CRLF;

     randomize;
     for i := 1 to N_Emocao do usouEmocao[i] := false;
     for i := 1 to N_Quem do usouQuem[i] := false;
     for i := 1 to N_Previsao do usouPrevisao[i] := false;

     if paramcount > 0 then
         begin
             val (paramstr(1), numpar, cod_erro);
             if numPar > 10 then numPar := 10;
         end
     else
         numpar := 3;

     for i := 1 to numpar do
         begin
             saida := '';

             repeat
                 n := random (N_previsao) + 1;
             until not usouprevisao[n];
             usouPrevisao[n] := true;
             analisa (previsao[n]);

             ajusta (saida);
             aFalar[i] := saida;

             formata (saida);
             if i <> numpar then
                 begin
                     writeln;
                     textoTotal := textoTotal + CRLF;
                 end;
	 end;

     for i := 1 to numPar do
          sintetiza (aFalar[i]);

     if keypressed then readln;
     sintBip;

     putClipboard (@textoTotal[1]);
     sintFim;
     donewincrt;
end.
