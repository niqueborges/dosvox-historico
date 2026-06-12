program gerasonsutil;

uses dvwin, dvcrt, dvsapi, SysUtils;

var lista: array [1..114] of string = (
    'L,@\monit32.exe,-UTMONIT,Leitor de telas Monitvox',
    'C,@\calcuvox.exe,-UTCALCU,Calculadora Vocal',
    'T,@\televox.exe,-UTTELE,Caderno de telefones',
    'A,@\agenvox.exe,-UTAGEN,Agenda de compromissos',
    'G,@\agenda.exe,-UTAGENDA,Agenda multi-uso',
    'D,c:\dicvox\dicvox.exe,-UTDIC,Dicionários Eletrônicos',
    'X,@\pptvox.exe,-UTPPT,Exibidor de apresentações interativas',
    'R,@\clockvox.exe,-UTCLOCK,Relógio Despertador',
    'S,@\scripvox.exe,-UTSCRIPT,Executor de script de comandos',
    'P,@\planivox.exe,-UTPLAN,Planilha eletrônica',
    'B,@\powervox.exe,-UTPOWER,Verificador no nível da bateria',
    'M,@\manvox2.exe,-UTMAN,Manual de instruções',
    'Y,@\traduvox.exe,-UTTRAD,Tradutor multilíngüe',
    '1,@\pyvox.exe,-UTPYVOX,Executor de scripts em Python',
    '2,@\timervox.exe,-UTTIMERVOX,Temporizador Vox',
    'E,@\epubvox.exe,-UTEPUBVOX,Conversor de livros EPUB para TXT',
    '+,[OUTROS],-UTOUTROS,Mais utilitários',
    '/,[UTILOBSOLETOS],-UTOBSOLE,Utilitários obsoletos',
    '*,[PROGUTIL],-UTVOLTAR,Volta aos utilitários principais',
    'B,c:\biblivox\biblivox.exe,-UTBIBLI,Bíblia Eletrônica',
    'H,@\hardvox.exe,-UTHARD,Descrição do hardware do computador',
    'E,@\minied.exe,-UTMINIED,Editor simplificado',
    'I,@\criaicon.exe,-UTCRIAIC,Gestor de ícones e teclas de atalho',
    'D,@\desenvox.exe,-UTDESEN,Desenhador',
    'F,@\fichavox.exe,-UTFICHA,Fichário de arquivos',
    'K,@\cronovox.exe,-UTCRONO,Relógio cronômetro',
    'M,@\matvox.exe,-UTMATVOX,Extensão matemática do Edivox',
    'H,@\hp12cvox.exe,-UTHP12CVOX,Calculadora Financeira HP12c Vox',
    'C,@\cdrec.exe,-UTCDREC,Gravador de CD para Windows',
    'B,@\transcod.exe,-UTTRANSC,Preprocessador de Braille Matemático',
    'F,@\formvox.exe,-UTFORM,Preenchedor de formulários',
    'X,@\cheqvox.exe,-UTCHEQ,Emissor de cheques',
    'C,@\cartex.exe,-UTCARTEX,Gerador de cartas padronizadas',
    'F,@\FORCAVOX.EXE,-JOFORCA,Jogo da Forca',
    'M,@\MEMOVOX.EXE,-JOMEMO,Jogo da Memorização de Letras',
    'I,@\MISTUVOX.EXE,-JOMISTU,Jogo de Mistura de Sons',
    'J,@\JOGAVOX.EXE,-JOJOGA,Jogavox',
    'E,[JOGOSEDUCATIVOS],-JOEDUCA,Jogos educativos',
    'R,[JOGOSRPG],-JORPG,Jogos de RPG',
    'P,[JOGOSPASSATEMPO],-JOPASSAT,Passatempos',
    'D,[JOGOSDESAFIO],-JODESAFI,Desafios',
    'O,[JOGOSORACULOS],-JOORACUL,Oráculos',
    'L,@\LETRAVOX.EXE,-JOLETRA,Letravox',
    'T,@\CONTAVOX.EXE,-JOCONTA,Jogo de tabuada',
    'X,@\LETRIX.EXE,-JOLETRIX,Letrix o jogo das palavrinhas',
    'R,@\SORTEVOX.EXE,-JOSORTE,Jogo de adivinhar números',
    'Q,@\QUESTVOX.EXE,-JOQUEST,Questionário automático',
    'F,@\FORCA2.EXE,-JOFORCA2,Forquinha para crianças',
    '*,[PROGJOGOS],-JOVOLTAR,Volta aos jogos principais',
    'A,@\PROFETA.EXE,-JOPROFET,Profeta',
    'O,@\ICHINVOX.EXE,-JOICHING,Oráculo Chinês (I-Ching)',
    'V,@\VIDAVOX.EXE,-JOVIDA,Dados sobre sua vida',
    'J,@\PIRATVOX.EXE,-JOPIRAT,Julius o Pirata',
    'E,@\COLOSSAL.EXE,-JOCOLOSS,Explorador da Caverna Colossal',
    'Y,@\SQUENTIN.EXE,-JOSQUENT,Fuga de San Quêntin',
    'V,@\VELHAVOX.EXE,-JOVELHA,Jogo da Velha',
    '$,@\CASINO.EXE,-JOCASINO,Cassino (Alto ou Baixo)',
    '3,@\X3VOX.EXE,-JO3X3,Jogo 3 x 3',
    'M,@\MEMOJOGO.EXE,-JOMEMOJO,Memo Jogo',
    'S,@\SUECAVOX.EXE,-JOSUECA,Jogo de Sueca',
    'G,@\GOVOX.EXE,-JOGOVOX,Jogo de GoVox',
    'D,@\DOMIVOX.EXE,-JODOMINO,Dominó',
    'C,@\CATAVOX.EXE,-JOCATA,Cata palavras',
    'P,@\PALAVROX.EXE,-JOPALAVR,Palavrox (anagramas)',
    'N,@\NIMVOX.EXE,-JOPALITI,Nimvox o Jogo dos Palitinhos',
    'B,@\BARONVOX.EXE,-JOBARON,Jogo do barão',
    'U,@\sudovox.exe,-JOSUDOVO,Sudovox',
    'P,@\PACIENCI.EXE,-JOPACIEN,Paciência',
    'S,@\SENHAVOX.EXE,-JOSENHA,Jogo da Senha',
    'X,@\chessvox.exe,-JOXADREZ,Jogo de Xadrez',
    'L,@\lunarvox.EXE,-JOLUNAR,Aterrissagem Lunar',
    'C,@\cruzavox.EXE,-JOCRUZA,Palavras cruzadas',
    'A,@\DIALUP.EXE,-RDDIALUP,Acesso discado por modem 3G',
    'C,@\CARTAVOX.EXE,-RDCARTA,Correio eletrônico',
    'I,@\IMAPUTIL.EXE,-RDIMAP,Acesso IMAP ao correio eletrônico',
    'H,@\WEBVOX.EXE,-RDWEB,Acesso a home pages',
    'G,@\GOOGLEVOX.EXE,-RDGOOGLEVOX,GoogleVox - acesso ao Google',
    'N,@\VOXNEWS.EXE,-RDVOXNEWS,VoxNews - acesso ao noticiário',
    'P,@\PAPOVOX.EXE,-RDPAPO,Bate-papo sonoro pela Internet',
    'Y,@\TWITVOX.EXE,-RDTWIT,Twitvox - acesso a redes sociais Twitter',
    'V,@\VOXTUBE.EXE,-RDVOXTUB,VoxTube - acesso ao YouTube',
    'F,@\FTPVOX.EXE,-RDFTP,Transferência de arquivos via FTP',
    'W,@\WIFIVOX.EXE,-RDWIFI,Detector de redes WIFI',
    'R,@\RADIO50.EXE,-RDRADIO50,Rádios online',
    'E,@\RECADO.EXE,-RDRECADO,Envio de recados eletrônicos',
    'O,@\PONTEVOX.EXE,-RDPONTEVOX,Configurador de pontes',
    'D,@\EDIPONTE.EXE,-RDEDIPONTE,Transporte genérico pelas pontes',
    '/,[REDEOUTROS],-RDOUTROS,Outros utilitários de rede',
    'G,@\INTERVOX.EXE,-RDINTER,Gerador de homepages Intervox',
    'T,@\TNETVOX.EXE,-RDTELNET,Telnet falado',
    'S,@\SITIOVOX.EXE,-RDSITIO,Servidor de Bate-papo pela Internet',
    'M,@\MINIWEB.EXE,-RDMNWEB,Mini servidor de homepages',
    'W,@\WWWVOX.EXE,-RDWWW,Gerador de homepages - versão antiga',
    'K,@\MIRCVOX.EXE,-RDMIRC,Acesso sonoro ao IRC',
    'U,@\UUVOX.EXE,-RDUU,Conversores UUEncode e UUDecode',
    'I,@\MIMEVOX.EXE,-RDMIME,Conversor de formato MIME64',
    'L,@\PRELISTA.EXE,-RDLISTA,Preparador de cartas para listas de pessoas',
    'D,@\DISCAVOX.EXE,-RDDISCA,Discavox - acesso pela porta COM',
    '*,[PROGREDE],-MMRETREDE,Volta aos principais de rede',
    'S,@\sapiutil.exe,-MMSAPIUT,Configurador da fala SAPI',
    'M,@\midiavox.exe,-MMMIDIA,Processador multimídia (áudio midi CD)',
    'G,@\minigrav.exe,-MMMNGRAV,Gravador de som',
    'V,@\tmix.exe,-MMVOLUME,Controle do volume geral',
    'T,@\testamic.exe,-MMTMIC,Teste do microfone',
    '3,@\cdmp3.exe,-MMTXTMP3,Conversor de texto para MP3',
    'A,@\metrovox.exe,-MMMETRON,Afinador para violão com Metrônomo',
    'J,@\juntawav.exe,-MMJWAV,Juntador de arquivos WAV',
    'F,@\convsons.exe,-MMCSONS,Conversor de formatos de sons',
    'H,@\harmonyvox.exe,-MMHARMO,Harmonyvox para violão',
    '/,[MULTIOBSOLETOS],-MMOBSOLE,Utilitários multimídia obsoletos',
    'C,@\cdwav.exe,-MMCDWAV,Transcritor de trilha de CD',
    'R,@\convrm.exe,-MMCONVRM,Conversor para formato Real Media',
    'X,@\mixervox.exe,-MMMIXER,Mixer geral do Windows',
    '*,[PROGMULTI],-MMVOLTAR,Volta aos principais de multimídia');

var i, p: integer;
    s, som: string;
    l: char;
    nome: string;
begin
   clrscr;
   for i := 1 to 114 do
       begin
            s := lista[i];
            l := s[1];
            delete (s, 1, pos(',', s));
            delete (s, 1, pos(',', s));
            delete (s, 1, 1);
            p := pos (',', s);
            som := copy (s, 1, p-1);
            delete (s, 1, p);
            nome := l + '-' + s;
            writeln (nome);

            sapiInic (1, 2, 0, 5, 'c:\winvox\som\dosvox50\util\'+som+'.wav');
            sapiFala (s);
            sapiFim;

            readln;

       end;
end.

