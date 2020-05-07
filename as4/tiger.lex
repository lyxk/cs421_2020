type pos = int
type svalue = Tokens.svalue
type ('a,'b) token = ('a,'b) Tokens.token
type lexresult = (svalue,pos) token

val lineNum = ErrorMsg.lineNum
val linePos = ErrorMsg.linePos
fun err(p1,p2) = ErrorMsg.error p1
val commentNum = ref 0
val stringBuf = ref ""
val stringBegin = ref 0
fun escToCtrl (s) = (str (chr (ord (hd (tl (tl (explode s)))) - 64)));
fun escToAscii (s) = (str (chr (valOf (Int.fromString
				          (implode (tl (explode s)))))));
fun updateNumAndPos (c::cs, pos) = (if (c = #"\n") then (
				       lineNum := !lineNum + 1;
				       linePos := pos :: !linePos
				       )
				    else ();
				    updateNumAndPos (cs, pos+1))
  | updateNumAndPos (nil, pos) = ();
val eof = fn () => (let val pos = hd(!linePos) in
		        if (!stringBuf <> "") then
		            ErrorMsg.error pos ("unclosed string at eof: " ^ !stringBuf)
			else if (!commentNum > 0) then
		           ErrorMsg.error pos ("unclosed comment at eof")
			else ();
		        Tokens.EOF(pos,pos)
		    end);
%%
%header (functor TigerLexFun(structure Tokens: Tiger_TOKENS));
%s COMMENT STRING;
printables=([!#-Z]|"["|"]"|"^"|[_-~])+;
%%
<INITIAL>" "|"\t" => (continue());
<INITIAL>type => (Tokens.TYPE(yypos, yypos+4));
<INITIAL>var => (Tokens.VAR(yypos, yypos+3));
<INITIAL>function => (Tokens.FUNCTION(yypos, yypos+8));
<INITIAL>break => (Tokens.BREAK(yypos, yypos+5));
<INITIAL>of => (Tokens.OF(yypos, yypos+2));
<INITIAL>end => (Tokens.END(yypos, yypos+3));
<INITIAL>in => (Tokens.IN(yypos, yypos+2));
<INITIAL>nil => (Tokens.NIL(yypos, yypos+3));
<INITIAL>let => (Tokens.LET(yypos, yypos+3));
<INITIAL>do => (Tokens.DO(yypos, yypos+2));
<INITIAL>to => (Tokens.TO(yypos, yypos+2));
<INITIAL>for => (Tokens.FOR(yypos, yypos+3));
<INITIAL>while => (Tokens.WHILE(yypos, yypos+5));
<INITIAL>else => (Tokens.ELSE(yypos, yypos+4));
<INITIAL>then => (Tokens.THEN(yypos, yypos+4));
<INITIAL>if => (Tokens.IF(yypos, yypos+2));
<INITIAL>array => (Tokens.ARRAY(yypos, yypos+5));
<INITIAL>":=" => (Tokens.ASSIGN(yypos, yypos+2));
<INITIAL>"|" => (Tokens.OR(yypos, yypos+1));
<INITIAL>"&" => (Tokens.AND(yypos, yypos+1));
<INITIAL>">=" => (Tokens.GE(yypos, yypos+2));
<INITIAL>">" => (Tokens.GT(yypos, yypos+1));
<INITIAL>"<=" => (Tokens.LE(yypos, yypos+2));
<INITIAL>"<" => (Tokens.LT(yypos, yypos+1));
<INITIAL>"<>" => (Tokens.NEQ(yypos, yypos+2));
<INITIAL>"=" => (Tokens.EQ(yypos, yypos+1));
<INITIAL>"/" => (Tokens.DIVIDE(yypos, yypos+1));
<INITIAL>"*" => (Tokens.TIMES(yypos, yypos+1));
<INITIAL>"-" => (Tokens.MINUS(yypos, yypos+1));
<INITIAL>"+" => (Tokens.PLUS(yypos, yypos+1));
<INITIAL>"." => (Tokens.DOT(yypos, yypos+1));
<INITIAL>"}" => (Tokens.RBRACE(yypos, yypos+1));
<INITIAL>"{" => (Tokens.LBRACE(yypos, yypos+1));
<INITIAL>"]" => (Tokens.RBRACK(yypos, yypos+1));
<INITIAL>"[" => (Tokens.LBRACK(yypos, yypos+1));
<INITIAL>")" => (Tokens.RPAREN(yypos, yypos+1));
<INITIAL>"(" => (Tokens.LPAREN(yypos, yypos+1));
<INITIAL>";" => (Tokens.SEMICOLON(yypos, yypos+1));
<INITIAL>":" => (Tokens.COLON(yypos, yypos+1));
<INITIAL>"," => (Tokens.COMMA(yypos, yypos+1));
<INITIAL>\" => (stringBegin := yypos; YYBEGIN STRING; continue());
<STRING>\" => (let
	          val s = !stringBuf
	       in
		  stringBuf := "";
                  YYBEGIN INITIAL;
                  Tokens.STRING(s, !stringBegin, !stringBegin + size(s))
	       end);
<STRING>{printables}|" " => (stringBuf := !stringBuf ^ yytext; continue());
<STRING>\\n => (stringBuf := !stringBuf ^ "\n"; continue());
<STRING>\\t => (stringBuf := !stringBuf ^ "\t"; continue());
<STRING>\\"^"[@-_] => (stringBuf := !stringBuf ^ escToCtrl (yytext); continue());
<STRING>\\([01][0-9]{2}|2([0-4][0-9]|5[0-5])) => (stringBuf := !stringBuf ^ escToAscii (yytext); continue());
<STRING>\\\" => (stringBuf := !stringBuf ^ "\""; continue());
<STRING>\\\\ => (stringBuf := !stringBuf ^ "\\"; continue());
<STRING>\\[\032\t\n\012]+\\ => (updateNumAndPos (explode yytext, yypos);
			       continue());
<STRING>\\. => (ErrorMsg.error yypos ("illegal escape sequence: " ^ yytext); continue());
<STRING>. => (ErrorMsg.error yypos ("illegal character in string: " ^ yytext); continue());
<STRING>\n => (ErrorMsg.error yypos ("illegal newline in string");
	       lineNum := !lineNum+1; linePos := yypos :: !linePos;
	       continue());
<INITIAL>"/*" => (YYBEGIN COMMENT; commentNum := 1; continue());
<COMMENT>"/*" => (commentNum := !commentNum+1; continue());
<COMMENT>"*/" => (commentNum := !commentNum-1;
	          if (!commentNum = 0) then YYBEGIN INITIAL else ();
		  continue());
<COMMENT>\n => (lineNum := !lineNum+1; linePos := yypos :: !linePos;
                continue());
<COMMENT>. => (continue());
<INITIAL>[0-9]+ => (Tokens.INT(valOf (Int.fromString(yytext)), yypos,
                               yypos+size(yytext)));
<INITIAL>[a-zA-Z][a-zA-Z0-9_]* => (Tokens.ID(yytext, yypos,
				   yypos+size(yytext)));
\n	=> (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
.       => (ErrorMsg.error yypos ("illegal character " ^ yytext); continue());
