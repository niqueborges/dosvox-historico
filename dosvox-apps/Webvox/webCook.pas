{-------------------------------------------------------------}
{
{    Webvox - Módulo de tratamento dos cookies
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webCook;

interface
uses windows, sysUtils, shellApi, classes,
     dvcrt, dvWin, dvInet, winsock, dvssl,
     webVars, webMsg, webutil;

function obtemCookie: string;
procedure montaCookies (url: string);
procedure enviaCookies;
procedure gravaCookie (s, nomePagina: string);
procedure inicCookies;
procedure finalizaCookies;

implementation

{-------------------------------------------------------------}
{                   carrega todos os cookies
{-------------------------------------------------------------}

procedure inicCookies;
var
   arq: textFile;
begin
    ArquivoDeCookies := TStringList.Create;
    try
       ArquivoDeCookies.LoadFromFile(arqCookie);
    except
       AssignFile (arq, arqCookie);
       {$I-} Rewrite (arq);  {$I+}
        if IOResult <> 0 then
           begin
              sintWriteln ('Arquivo de Cookies não foi aberto.');
              exit;
           end;
        close (arq);
    end;
    limpaArq;
    ArquivoDeCookies.SaveToFile(arqCookie);
end;

{-------------------------------------------------------------}
{                   limpa memória de cookies
{-------------------------------------------------------------}

procedure finalizaCookies;
begin
    limpaArq;
    ArquivoDeCookies.SaveToFile(arqCookie);
end;

{-------------------------------------------------------------}
{                   obtem o dominio do cookie
{-------------------------------------------------------------}

function pegaDominio (s: string): string;
var
   i : integer;
   s2: string;
   tam: integer;
   posicao: integer;
begin
   tam := length (s);
   s2 := s;
   for i := 1 to tam do
      s2 [i] := upcase (s2 [i]);

   posicao := 6 + pos ('DOMAIN=', s2);
   if posicao <> 0 then
      begin
        tam := tam -posicao;
        delete (s,1,posicao);
        posicao := pos ('*', s);
        if posicao = 0 then
           posicao := pos (';', s);

        delete (s,posicao,tam);
      end
   else
      s := '';

   pegaDominio := s;
end;

{-------------------------------------------------------------}
{                   obtem um cookie
{-------------------------------------------------------------}

function obtemCookie: string;

{-----------------------------------------------------------}

    function buscaCookie (texto: string): string;
    var s, resultado: string;
        i, n, tam: integer;
    label pula, erro, achou;
    begin
        buscaCookie := '';
        resultado := '';
        for n := 1 to nlinCabecHTTP do
            begin
                s := cabecHTTP [n];
                for i := 1 to length (texto) do
                   if upcase (texto[i]) <> upcase (s[i]) then
                      goto pula;

                tam := length (texto);
                s := copy (s, tam+1, length(s)-tam);

                s := trimLeft(s);
                if (s <> '') and (s[1] = '"') then delete (s, 1, 1);
                if (s <> '') and (s[length (s)] = '"') then delete (s, length(s), 1);

                resultado := resultado + '*' + s;
    pula:;
            end;

        delete (resultado, 1, 1);
        buscaCookie := resultado;
    end;

{-----------------------------------------------------------}

var
   s: string;
begin
    obtemCookie := '';
    s := buscaCookie ('Set-Cookie:');
    obtemCookie := s;
end;

{-------------------------------------------------------------}
{                      monta Cookies
{-------------------------------------------------------------}

procedure montaCookies (url: string);
var
   s,s2,url2: string;
   cont: integer;
   quant: integer;
   i,i2: integer;
begin
   cookie := '';
   cont := 0;
   quant := ArquivoDeCookies.Count;
   for i := 0 to quant-2 do
      begin
         s  := ArquivoDeCookies [i];
         s2 := ArquivoDeCookies [i+1];
         if pos ('dominio=', s) = 0 then
             continue;

         delete (s, 1, length ('dominio='));

         if pos ('caminho=', s2) = 0 then
             continue;

         delete (s2, 1, length ('caminho='));

         i2 := pos (s, url);
         if i2 = 0 then
            continue;
         url2 := url + '/';
         delete (url2, 1,i2 + length (s) -1);
         i2 := pos (s2, url2);
         if i2 = 0 then
            continue;

         s := ArquivoDeCookies [i+2];
         delete (s, 1, length ('nome='));

         (* da primeira diz que vai ser cookie *)
         if cont = 0 then
            cookie  := 'Cookie: '
         (* para enviar mais de um cookie eles devem estar
            separados por ponto e virgula *)
         else
            cookie :=  cookie +  '; ';

         cont := cont + 1;

         cookie := cookie + s;
      end;
end;


{-------------------------------------------------------------}
{                      envia Cookies
{-------------------------------------------------------------}

procedure enviaCookies;
var
   CookieAenviar: array [0..BUFSIZE-1] of char;
begin
   if cookie = '' then
      exit;

   strPcopy (CookieAenviar, cookie + CRLF);
   sendBuf (sockHTTP, CookieAenviar, strlen (CookieAenviar), 0);
   netDebug (CookieAenviar, strlen (CookieAenviar));
end;

(* extrai um set-cookie quando tem vários *)
function pegaUmcookie (var s: string): string;
var
   posicao: integer;
   cok: string;
begin
   posicao := pos ('*', s);
   if posicao <> 0 then
      begin
         cok := copy (s,1,posicao-1);
         delete (s,1,posicao);
      end
   else
      begin
         cok := s;
         s := '';
      end;

   pegaUmcookie := cok;
end;

(* separa as partes de um cookie *)
procedure ExtraiparteCookie (var partes: TCookie; cook: string);
var
   s: string;
   i: integer;
   s2: string;
   posinic: integer;
   posfinal: integer;
   tam: integer;
begin
    posfinal := pos (';',cook);
    if posfinal <> 0 then
       begin
          partes.nome := copy (cook, 1, posfinal-1);
          delete (cook, 1, posfinal);
          tam := length (cook);
          s := cook;
       end
    else
       begin
          partes.nome := cook;
          tam := 0;
       end;


    for i := 1 to tam do
       s [i] := upcase (s [i]);

    posinic := pos ('PATH', s);
    if posinic <> 0 then
       begin
          s2 := copy (s, posinic + 5, tam);
          posfinal := pos (';',s2);

          if posfinal = 0 then
             posfinal := tam;

          partes.path := copy (cook, posinic + 5 , posfinal -1);
          delete (cook, posinic, posfinal + 5);
          delete (s, posinic, posfinal + 5);

          tam := length (s);
       end;

    posinic := pos ('DOMAIN', s);
    if posinic <> 0 then
       begin
          s2 := copy (s, posinic + 7, tam);
          posfinal := pos (';',s2);

          if posfinal = 0 then
             posfinal := tam;

          partes.dominio := copy (cook, posinic + 7 , posfinal -1);
          delete (cook, posinic, posfinal + 7);
          delete (s, posinic, posfinal + 7);

          tam := length (s);
       end;

    posinic := pos ('COMMENT', s);
    if posinic <> 0 then
       begin
          s2 := copy (s, posinic + 8, tam);
          posfinal := pos (';',s2);

          if posfinal = 0 then
             posfinal := tam;

          partes.comentario := copy (cook, posinic + 8 , posfinal -1);
          delete (cook, posinic, posfinal + 8);
          delete (s, posinic, posfinal + 8);

          tam := length (s);
       end;

    posinic := pos ('VERSION', s);
    if posinic <> 0 then
       begin
          s2 := copy (s, posinic + 8, tam);
          posfinal := pos (';',s2);

          if posfinal = 0 then
             posfinal := tam;

          partes.versao := copy (cook, posinic + 8 , posfinal -1);
          delete (cook, posinic, posfinal + 8);
          delete (s, posinic, posfinal + 8);

          tam := length (s);
       end;

    posinic := pos ('EXPIRES', s);
    if posinic <> 0 then
       begin
          s2 := copy (s, posinic + 8, tam);
          posfinal := pos (';',s2);

          if posfinal = 0 then
             posfinal := tam;

          partes.tempo := copy (cook, posinic + 8 , posfinal -1);
          delete (cook, posinic, posfinal + 8);
          delete (s, posinic, posfinal + 8);
       end;

    posinic := pos ('SECURE', s);
    if posinic <> 0 then
       partes.seguranca := 'Secure';

end;

(* um cookie pode ter vários set-cookies *)
procedure salvaUmcookie (dom: string; cook: string; num: integer);
{-----------------------------------------------------------}
function jaExiste (parte: TCookie; var index: integer): boolean;
var
   i: integer;
   tam: integer;
   s: string;
   s2: string;
   posicao: integer;
   existe: boolean;
begin
   existe := false;
   index := 0;

   tam := ArquivoDeCookies.Count;

   for i := 0 to tam-1 do
      begin
         if (ArquivoDeCookies [i] <> 'dominio=' + parte.dominio) or (ArquivoDeCookies [i+1] <> 'caminho=' + parte.path) then
            continue;

         s := ArquivoDeCookies [i+2];
         delete (s, 1, length ('nome='));
         posicao := pos ('=',s);

         if posicao = 0 then
            continue;

         delete (s, posicao, length (s));

         s2 := parte.nome;
         posicao := pos ('=',s2);

         if posicao = 0 then
            continue;

         delete (s2, posicao, length (s2));

         if s <> s2 then
            continue;

         s := ArquivoDeCookies [i+4];
         delete (s, 1, length ('tempo='));

         if maiorData (s, parte.tempo) = 1 then
            continue;

         existe := true;
         index := i;
         break;
      end;

   result := existe;
end;
{-----------------------------------------------------------}
var
   dominio: string;
   parteCookie: TCookie;
   i: integer;
   existe: boolean;
begin

   ExtraiparteCookie (parteCookie, cook);
   if parteCookie.path = '' then
      parteCookie.path := '/';

   if parteCookie.dominio = '' then
      begin
         dominio := dom;
         { retira o http:// do dominio }
         i := pos ('//',dominio);
         if i <> 0 then
            delete (dominio, 1, i+1);

         {retira o www. do domínio}
         if length (dominio) > 5 then
            if (upcase (dominio [1]) = 'W') and (upcase (dominio [2]) = 'W') and (upcase (dominio [3]) = 'W') and (upcase (dominio [4]) = '.') then
                delete (dominio, 1, 4);

         { retira tudo depois da ? no dominio}
         i := pos ('?', dominio);
         if i <> 0 then
            delete (dominio, i, 99);

         i := length (dominio);

(*
         while (i > 0 ) do
            begin
               if dominio [i] = '/' then
                  break;
               i := i -1;
            end;
*)
i := pos ('/', dominio);
if i <> 0 then
        delete (dominio,i,99);

        parteCookie.dominio := dominio;
      end;

   existe := jaExiste (parteCookie, i);

   if existe and (i = 0) then
      exit;

   if i = 0 then
      begin
         ArquivoDeCookies.Add('');
         ArquivoDeCookies.Add ('dominio=' + parteCookie.dominio);
         ArquivoDeCookies.Add ('caminho=' + parteCookie.path);
         ArquivoDeCookies.Add ('nome=' +  parteCookie.nome);
         ArquivoDeCookies.Add ('comentario=' + parteCookie.comentario);
         ArquivoDeCookies.Add ('tempo=' + parteCookie.tempo);
         ArquivoDeCookies.Add ('versao=' + parteCookie.versao);
         ArquivoDeCookies.Add ('seguranca=' + parteCookie.seguranca);
      end
   else
      begin
         ArquivoDeCookies [i]   := 'dominio=' + parteCookie.dominio;
         ArquivoDeCookies [i+1] := 'caminho=' + parteCookie.path;
         ArquivoDeCookies [i+2] := 'nome=' + parteCookie.nome;
         ArquivoDeCookies [i+3] := 'comentario=' + parteCookie.comentario;
         ArquivoDeCookies [i+4] := 'tempo=' + parteCookie.tempo;
         ArquivoDeCookies [i+5] := 'versao=' + parteCookie.versao;
         ArquivoDeCookies [i+6] := 'seguranca=' + parteCookie.seguranca;
      end;

   ArquivoDeCookies.SaveToFile(arqCookie);
end;

procedure gravaCookie (s, nomePagina: string);
var
   dominio: string;
   cont: integer;
   naoacabou: boolean;
   umcookie: string;
begin
   cont := 1;
   naoacabou := true;
   dominio := pegaDominio (s);
   while naoacabou do
      begin
         umcookie := pegaUmcookie (s);
         if umcookie = '' then
            naoacabou := false
         else
            salvaUmcookie (nomePagina, umCookie, cont);

         cont := cont + 1;
      end;
end;

end.


