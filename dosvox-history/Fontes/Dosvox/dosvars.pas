unit dosvars;

interface
uses classes;

const  // originalmente em dosmsg
     versao = '6.3';
     tipoVersao = '';      { alfa, beta, etc... }

var   // originalmente no programa principal
    hMutex: THandle;

var   // originalmente em dosgeral
    semLimpaBuf: boolean;

var   // originalmente em doscopia
    listArquivos: TList;
    podeSobrescrever: boolean;
    naoParaTodos: boolean;
    copiaFazSintclek: boolean;
    instrumentoEmCopiaDeArquivo: integer;

var   // originalmente em dosarq
    moverObjetos: boolean;
    copiaMuda: boolean;

var   // originalmente em dosdir
    penultSubDir: string;

implementation

begin
end.
