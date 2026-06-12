unit ckutil;

interface

uses dvcrt, dvwin,
     windows, shellApi, sysutils,
     ckjan, ckvars;

    procedure sintReadword (var n: word);
    function existeArq (nomearq: string): boolean;

implementation

procedure sintReadword (var n: word);
var
    erro: integer;
    s: string;
begin
    s := '';
    sintEdita (s, wherex, wherey, 81 - wherex, true);
    val (trim(s), n, erro);
    writeln;
end; {Procedure}

function existeArq (nomearq: string): boolean;
var existe: boolean;
    arqVer: file;
begin

    assign (arqVer,nomearq);
    {$I-}  reset (arqVer); {$i+}
    existe := ioresult = 0;
    if existe then close (arqVer);
    existeArq := existe;

end; {Procedure}

end.
