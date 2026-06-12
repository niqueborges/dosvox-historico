{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de variáveis
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colvars;
interface
const
    LANGFILE = 'advpor';
    VERSION = '1.2';

    MAXLOC = 140;
    MAXOBJ = 100;
    DWARFMAX = 7;

var
    { estados dos lugares }
    cond: array [0..MAXLOC] of integer = (
        {0}    0,
        {1}    5,1,5,5,1,1,5,17,1,1,0,0,
        {13}   32,0,0,2,0,0,64,2,
        {21}   2,2,0,6,0,2,0,0,0,0,
        {31}   2,2,0,0,0,0,0,4,0,2,0,
        {42}   128,128,128,128,136,136,136,128,128,
        {51}   128,128,136,128,136,0,8,0,2,
               0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        {79}   2,128,128,136,0,0,8,136,128,0,2,2,0,0,0,0,
        {95}   4,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,
        {113}  4,0,1,1,0,0,0,0,0,
        {122}  8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0
    );

    { lugares dos objetos }
    place: array [0..MAXOBJ] of integer = (
        {0}    0,
        {1}    3,3,8,10,11,0,14,13,94,96,
        {11}   19,17,101,103,0,106,0,0,3,3,0,0,
        {23}   109,25,23,111,35,0,97,0,
        {31}   119,117,117,0,130,0,126,140,0,96,0,0,0,0,0,0,0,0,0,
        {50}   18,27,28,29,30,0,
        {56}   92,95,97,100,101,0,119,127,130,
               0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0,0,0,0,0
        );

    { objetos fixos }
    fixed: array [0..MAXOBJ] of integer = (
        {0}     0,0,0,
        {3}     9,0,0,0,15,0,-1,0,
        {11}    -1,27,-1,0,0,0,-1,0,0,0,0,0,
        {23}    -1,-1,67,-1,110,0,-1,-1,
        {31}    121,122,122,0,-1,-1,-1,-1,0,-1,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        {62}    121,0,-1,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    );

    { mensagens padrões dos verbos }
    actmsg: array [0..31] of integer = (
        {0}     0,24,29,0,33,0,33,38,38,42,14,
        {11}    43,110,29,110,73,75,29,13,59,59,
        {21}    174,109,67,13,147,155,195,146,110,13,13
    );

    { lugares dos anões }
    dloc: array [0..DWARFMAX] of integer = (
        0,19,27,33,44,64,114,0
    );

{--------------------------------------------------------}
{                 definições dos objetos
{--------------------------------------------------------}

const
    KEYS      = 1;
    LAMP      = 2;
    GRATE     = 3;
    CAGE      = 4;
    ROD	      = 5;
    ROD2      = 6;
    STEPS     = 7;
    BIRD      = 8;
    DOOR      = 9;
    PILLOW    = 10;
    SNAKE     = 11;
    FISSURE   = 12;
    TABLET    = 13;
    CLAM      = 14;
    OYSTER    = 15;
    MAGAZINE  = 16;
    DWARF     = 17;
    KNIFE     = 18;
    FOOD      = 19;
    BOTTLE    = 20;
    WATER     = 21;
    OIL	      = 22;
    MIRROR    = 23;
    PLANT     = 24;
    PLANT2    = 25;
    AXE	      = 28;
    DRAGON    = 31;
    CHASM     = 32;
    TROLL     = 33;
    TROLL2    = 34;
    BEAR      = 35;
    MESSAGE   = 36;
    VEND      = 38;
    BATTERIES = 39;
    NUGGET    = 50;
    COINS     = 54;
    CHEST     = 55;
    EGGS      = 56;
    TRIDENT   = 57;
    VASE      = 58;
    EMERALD   = 59;
    PYRAMID   = 60;
    PEARL     = 61;
    RUG       = 62;
    SPICES    = 63;
    CHAIN     = 64;

{--------------------------------------------------------}
{             definições alternativas das ações
{--------------------------------------------------------}

const
    NULLX	= 21;
    BACK	= 8;
    LOOK	= 57;
    CAVEX	= 67;
    ENTRANCE	= 64;
    DEPRESSION	= 63;

{--------------------------------------------------------}
{               definições dos verbos de ação
{--------------------------------------------------------}

const
    TAKE	= 1;
    DROP	= 2;
    SAY	        = 3;
    OPEN	= 4;
    NOTHING	= 5;
    LOCK	= 6;
    ON	        = 7;
    OFF	        = 8;
    WAVE	= 9;
    CALM	= 10;
    WALK	= 11;
    KILL	= 12;
    POUR	= 13;
    EAT	        = 14;
    DRINK	= 15;
    RUB	        = 16;
    THROW	= 17;
    QUIT	= 18;
    FIND	= 19;
    INVENTORY	= 20;
    FEED	= 21;
    FILL	= 22;
    BLAST	= 23;
    SCORE	= 24;
    FOO	        = 25;
    BRIEF	= 26;
    READ	= 27;
    BREAK	= 28;
    WAKE	= 29;
    SUSPEND	= 30;
    HOURS	= 31;
    LOG	        = 32;

{--------------------------------------------------------}
{        bits do vetor cond, que indica status do lugar
{--------------------------------------------------------}

const
    LIGHT   = 1;
    WATOIL  = 2;
    LIQUID  = 4;
    NOPIRAT = 8;
    HINTC   = 16;
    HINTB   = 32;
    HINTS   = 64;
    HINTM   = 128;
    HINT    = 240;

{--------------------------------------------------------}
{                  definições gerais
{--------------------------------------------------------}

const
    MAXDIE = 3;       { max # of deaths before close	}
    MAXTRS = 79;      { max # of treasures }
    MAXSCORE = 350;   { max score }

{--------------------------------------------------------}
{                 definições do dicionário
{--------------------------------------------------------}

const
    noAccents: string =
        'AAAAAAÆÇEEEEIIIIÐNOOOOO×ØUUUUÝÞßaaaaaaæçeeeeiiiiðnooooo÷øuuuuýþÿ';

var
    globalDir: string;    { directory where messages are stored }

type
    TWac = record
	aword: pchar;
	acode: integer;
    end;

const
    MAXWORDS = 500;	{ max # of adventure words   }
    MAXIGNORED = 100;   { max # of ignored words }
    WORDSIZE = 20; 	{ max # of chars in commands }

    T_MOTION = 0;
    T_OBJECT = 1;
    T_VERB   = 2;       { such as "carry" or "attack" }
    T_SPVERB = 3;       { special verb such as "dig"  with no real action }
    T_IGNORE = 4;       { ignored words }

   { note: a word can have 2 codes ! }
   { objects from 50 to (currently, anyway) 79
              are considered treasures (for pirate, closeout).  }

var
    numWords: integer;
    wc: array [1..MAXWORDS] of TWac;

    numIgnored: integer;
    wig: array [1..MAXIGNORED] of pchar;

{--------------------------------------------------------}
{                 definições dos percursos
{--------------------------------------------------------}

type
    TTrav = record
	tdest: integer;
	tverb: integer;
	tcond: integer;
    end;

const
    MAXTRAV = (16+1);	{ max # of travel directions from loc	}
			{ +1 for terminator travel[x].tdest=-1	}
var
    travel: array [0..MAXTRAV] of TTrav;

{--------------------------------------------------------}
{                    variáveis
{--------------------------------------------------------}

var
    firstVar: char;    { essa deve ser a primeira variável }

    rflag, dbugflg: boolean;
    fd1, fd2, fd3, fd4: text;

    visited: array [0..MAXLOC] of boolean;    { if has been here }
    prop: array [0..MAXOBJ-1] of integer;     { objects' properties }

    odloc: array [0..DWARFMAX-1] of integer;  { dwarf old locations }
    dseen: array [0..DWARFMAX-1] of integer;  { dwarf seen flag }

    playing: boolean;  { is playing }
    turns: integer;    { tallies how many commands he's given }
    gaveup: boolean;   { left via `quit' }
    panic: boolean;    { he found he's trapped in the cave }

    closing: boolean;  { closing time }
    closed: boolean;   { all the way closed }
    dkill: integer;    { number of dwarves killed }
    wzdark: boolean;   { loc he's leaving was dark }
    holding: integer;  { number of holding objects }
    detail: integer;   { how often we've said "not allowed to give more detail" }
    limit: integer;    { lifetime of lamp (not set here) }
    tally: integer;    { count of treasures remaining }
    tally2: integer;   { count of treasures destroyed or inaccessible }

    clock: integer;    { number of turns from finding last treasure till closing }
    clock2: integer;   { number of turns from first warning till blinding flash }
    bonus: integer;    { used to determine amount of bonus if he reaches closing }
    numdie: integer;   { number of times killed so far }
    lmwarn: integer;   { warned about lamp going dim }

    daltloc: integer;  { alternate appearance }
    foobar: integer;   { fie fie foe foo... }

    loc: integer;      {location variables }
    newloc: integer;
    oldloc: integer;
    oldloc2: integer;

    knfloc: integer;   { knife location }
    chloc: integer;    { chest locations }
    chloc2: integer;

    dflag: integer;    { dwarf flag }
    saveflg: boolean;  { if game being saved }

    verb: integer;     { verb }
    xobject: integer;  { object referenced }
    object1: integer;  { to help intrans. }
    motion: integer;   { motion control }

    word1, word2: array [0..80] of char;

    theScore: integer; { the final score }

    savedFileName: string[144];   {the last saved file name}

    lastVar: char;     { essa deve ser a última variável }

implementation
end.
