unit epvars;
interface

uses
classes;

const
    versao = '1.2';

type

    TNavPoint = record
        class_: string;
        id: string;
        playOrder: string;
        navLabel: string;
        content_src: string;
    end;

    TMetadata = record
        dc: string;
        content: string;
    end;

    TMeta = record // pode ter ou não
        name: string;
        content: string;
    end;

    TDTB = record // pode ter ou não
        name: string;
        content: string;
    end;

    TItem = record
        href: string;
        id: string;
        media_type: string;
    end;

    TItemRef = record
        ordem: string;
        idref: string;
    end;

    TReference = record
        href: string;
        title: string;
        type_: string;
    end;

    TImagem = record
        nome: string;
        src: string;
    end;

    TLocal = record
        nome: string;
        id: string;
    end;
    TPackage = record
        xmlns: string;
        unique_identifier: string;
        version: string;
    end;

    TStatusTag = (ABERTA, FECHADA);

var
    container_rootfile: string;
    title: string;
    nomeCurLivro: string;
    caminhoCurLivro: string;
    extCurLivro: string;
    caminhoCurTxt: string;
    CurDir: string;
    LocalSaida: string;
    hrefToc: string;
    dirConteiner: String;
    novoNomeLivro: string;
    
    execucaoAutomatica: boolean;
    processaImagem: boolean;
    oebps: boolean;
        
    PNavPoint: TNavPoint;
    PMetadata: TMetadata;
    PMeta: TMeta;
    PDTB: TDTB;    
    PItem : TItem;
    PItemRef: TItemRef;
    PReference: TReference;
    PPackage: TPackage;
    PImagem: TImagem;
    PLocal: TLocal;

    head: array of TDTB;    
    navMap: array of TNavPoint;

    manifest: array of TItem;
    spine: array of TItemRef;
    guide: array of TReference;

    rodapeIMG: array of TImagem;
    ListaIds:  array of TLocal;
    status: TStatusTag;
    j: Integer = 1;
    k: Integer = 1;
    
implementation

end.
