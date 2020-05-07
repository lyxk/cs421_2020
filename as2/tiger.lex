type pos = int
type lexresult = Tokens.token
val lineNum = ErrorMsg.lineNum
val linePos = ErrorMsg.linePos

(* Inside a string or not *)
val strMode = ref false
(* Depth of nested comments *)
val comDepth = ref 0
(* Start position of a string *)
val stringStart = ref 0
(* Current content of a string *)
val currString = ref ""

(* Append s to currString *)
fun appendStr s = ( currString := !currString ^ s; () )

(* Increase lineNum and append yypos to linePos *)
fun nextLine pos = ( lineNum := !lineNum + 1; linePos := pos :: !linePos; () )

(* Function for printing error position and error message *)
fun err (p,m) = ErrorMsg.error p m

fun eof () =
    let 
        val pos = hd(!linePos);
    in 
        (if !comDepth <> 0 then err(pos, "unclosed comment") else (); ErrorMsg.reset(); Tokens.EOF(pos,pos) )
    end

%%

%s COMMENT STRING STRING_ESCAPE STRING_ESCAPE_MULTI;
alpha = [a-zA-Z];
alphas = {alpha}+;
digit = [0-9];
digits = {digit}+;
control = [A-Z\[\]\\^_];
ws = [\ \t];

%%
<INITIAL>type => ( Tokens.TYPE(yypos, yypos + 3) );
<INITIAL>var => ( Tokens.VAR(yypos, yypos + 3) );
<INITIAL>function => ( Tokens.FUNCTION(yypos, yypos + 8) );
<INITIAL>break => ( Tokens.BREAK(yypos, yypos + 5) );
<INITIAL>of => ( Tokens.OF(yypos, yypos + 2) );
<INITIAL>end => ( Tokens.END(yypos, yypos + 3) );
<INITIAL>in => ( Tokens.IN(yypos, yypos + 2) );
<INITIAL>nil => ( Tokens.NIL(yypos, yypos + 3) );
<INITIAL>let => ( Tokens.LET(yypos, yypos + 3) );
<INITIAL>do => ( Tokens.DO(yypos, yypos + 2) );
<INITIAL>to => ( Tokens.TO(yypos, yypos + 2) );
<INITIAL>for => ( Tokens.FOR(yypos, yypos + 3) );
<INITIAL>while => ( Tokens.WHILE(yypos, yypos + 5) );
<INITIAL>else => ( Tokens.ELSE(yypos, yypos + 4) );
<INITIAL>then => ( Tokens.THEN(yypos, yypos + 4) );
<INITIAL>if => ( Tokens.IF(yypos, yypos + 2) );
<INITIAL>array => ( Tokens.ARRAY(yypos, yypos + 5) );

<INITIAL>":=" => ( Tokens.ASSIGN(yypos, yypos + 2) );
<INITIAL>"|" => ( Tokens.OR(yypos, yypos + 1) );
<INITIAL>"&" => ( Tokens.AND(yypos, yypos + 1) );
<INITIAL>">=" => ( Tokens.GE(yypos, yypos + 2) );
<INITIAL>">" => ( Tokens.GT(yypos, yypos + 1) );
<INITIAL>"<=" => ( Tokens.LE(yypos, yypos + 2) );
<INITIAL>"<" => ( Tokens.LT(yypos, yypos + 1) );
<INITIAL>"<>" => ( Tokens.NEQ(yypos, yypos + 2) );
<INITIAL>"=" => ( Tokens.EQ(yypos, yypos + 1) );
<INITIAL>"/" => ( Tokens.DIVIDE(yypos, yypos + 1) );
<INITIAL>"*" => ( Tokens.TIMES(yypos, yypos + 1) );
<INITIAL>"-" => ( Tokens.MINUS(yypos, yypos + 1) );
<INITIAL>"+" => ( Tokens.PLUS(yypos, yypos + 1) );
<INITIAL>"." => ( Tokens.DOT(yypos, yypos + 1) );
<INITIAL>"}" => ( Tokens.RBRACE(yypos, yypos + 1) );
<INITIAL>"{" => ( Tokens.LBRACE(yypos, yypos + 1) );
<INITIAL>"]" => ( Tokens.RBRACK(yypos, yypos + 1) );
<INITIAL>"[" => ( Tokens.LBRACK(yypos, yypos + 1) );
<INITIAL>")" => ( Tokens.RPAREN(yypos, yypos + 1) );
<INITIAL>"(" => ( Tokens.LPAREN(yypos, yypos + 1) );
<INITIAL>";" => ( Tokens.SEMICOLON(yypos, yypos + 1) );
<INITIAL>":" => ( Tokens.COLON(yypos, yypos + 1) );
<INITIAL>"," => ( Tokens.COMMA(yypos, yypos + 1) );
<INITIAL>{ws}+ => ( continue() );
<INITIAL>\n	=>  ( nextLine(yypos); continue() );
<INITIAL>{digit}+ => ( Tokens.INT (valOf (Int.fromString yytext), yypos, yypos + size yytext) );
<INITIAL>{alpha}({alpha}|{digit}|"_")* => ( Tokens.ID(yytext, yypos, yypos + size yytext) );
<INITIAL>"/*" => ( YYBEGIN COMMENT; comDepth := !comDepth + 1; continue() );
<INITIAL>"\"" => ( YYBEGIN STRING; strMode := true; currString := ""; stringStart := yypos; continue() );
<INITIAL>. => ( err(yypos, "illegal character " ^ yytext); continue() );

<COMMENT>"/*" => ( comDepth := !comDepth + 1; continue() );
<COMMENT>"*/" => ( comDepth := !comDepth - 1; if !comDepth = 0 then YYBEGIN INITIAL else (); continue() );
<COMMENT>\n => ( nextLine(yypos); continue() );
<COMMENT>. => ( continue() );


<STRING>"\"" => ( YYBEGIN INITIAL; strMode := false; Tokens.STRING(!currString, !stringStart, yypos + size yytext) );
<STRING>"\\" => ( YYBEGIN STRING_ESCAPE; continue() );
<STRING>\t => ( err(yypos, "illegal character \\t causing unclosed string"); continue() );
<STRING>\n => ( err(yypos, "illegal character \\n causing unclosed string"); nextLine(yypos); continue() );
<STRING>. => ( currString := !currString ^ yytext; continue() );

<STRING_ESCAPE>n => ( YYBEGIN STRING; currString := !currString ^ "\n"; continue() );
<STRING_ESCAPE>t => ( YYBEGIN STRING; currString := !currString ^ "\t"; continue() );
<STRING_ESCAPE>"\"" => ( YYBEGIN STRING; currString := !currString ^ "\""; continue() );
<STRING_ESCAPE>"\\" => ( YYBEGIN STRING; currString := !currString ^ "\\"; continue() );
<STRING_ESCAPE>"^"{control} => ( YYBEGIN STRING; currString := !currString ^ String.str( chr( ord( String.sub(yytext, 1) ) - 64 ) ); continue() );
<STRING_ESCAPE>{digit}{3} => ( YYBEGIN STRING; currString := !currString ^ String.str ( chr ( valOf (Int.fromString yytext) ) ); continue() );
<STRING_ESCAPE>\n => ( YYBEGIN STRING_ESCAPE_MULTI; nextLine(yypos); continue() );
<STRING_ESCAPE>{ws} => ( YYBEGIN STRING_ESCAPE_MULTI; continue() );
<STRING_ESCAPE>. => ( err(yypos, "illega escape sequence \\" ^ yytext ^ " inside string"); continue() );

<STRING_ESCAPE_MULTI>\n => ( nextLine(yypos); continue() );
<STRING_ESCAPE_MULTI>{ws}+ => ( continue() );
<STRING_ESCAPE_MULTI>"\\" => ( YYBEGIN STRING; continue() );
<STRING_ESCAPE_MULTI>. => ( err(yypos, "illegal escape sequence \\" ^ yytext ^ " inside string"); continue() );