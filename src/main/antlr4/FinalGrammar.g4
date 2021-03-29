grammar FinalGrammar;

gram: statement+ EOF
    ;

statement: parametr
         | format
         | subroutine_call
         | function_call
         | assignment
         | variableType
         | file
         | io_statement
         | stopStatement
         | comment
         | named_block
         | loop
         | if_block
         | go_to
         | functionDeclaration
         | subroutineDeclaration
         | intrinsicDeclaration
         | return_block
         | exit
         | stop
         | save
         | cycle
         | end
         ;

//Check this function declaration had to put ? after typeName to parse this kind of statement CHARACTER*128 FUNCTION a(asd). I am not sure if it is relevant fortran code.
functionDeclaration: typeName? functionKeyword function_call function_definition return_block END
                   ;

subroutineDeclaration: subroutineKeyword function_call function_definition return_block END
                     ;

intrinsicDeclaration: intrinsicKeyword INTRINSIC_NAME
                ;

intrinsicKeyword: INTRINSIC
            ;

functionKeyword: FUNCTION
               ;

subroutineKeyword: SUBROUTINE
                 ;

function_definition: statement*
                   ;

named_block: block_name COLON ( if_block | loop ) block_name
           ;

block_name: NAME
          ;

if_block: (
             if_rule
             else_if_rule *
             else_rule *
             end_if
         )
        | if_one_line
        ;

if_one_line: IF L_PARENTHESES ( value | condition ) R_PARENTHESES ( statement | statement_of_executable )
           ;

if_rule: IF L_PARENTHESES condition R_PARENTHESES THEN
    statement*
  ;

else_if_rule: ( ELSE IF | ELSE_IF )
            L_PARENTHESES condition R_PARENTHESES THEN
            statement*
            ;

else_rule: ELSE
          statement*
         ;

end_if: END IF
      | ENDIF
      ;

condition: ( logical_expression | L_PARENTHESES logical_expression R_PARENTHESES )
           ( logical_operator ( logical_expression | L_PARENTHESES logical_expression R_PARENTHESES ) )*
           |
           LOGICAL_OPERATOR_NOT?
           L_PARENTHESES
           ( logical_expression | L_PARENTHESES logical_expression R_PARENTHESES )
           ( logical_operator ( logical_expression | L_PARENTHESES logical_expression R_PARENTHESES ) )*
           R_PARENTHESES
         ;

logical_expression: LOGICAL_OPERATOR_NOT?
                  ( condition_value
                  | L_PARENTHESES condition_value R_PARENTHESES
                  | condition_value relational_operator condition_value
                  | L_PARENTHESES condition_value relational_operator condition_value R_PARENTHESES
                  )
                  ;

condition_value: condition_element ( ( relational_operator | logical_operator ) condition_element )*
               ;

condition_element: variable
                 | function_call
                 | NUMBER
                 | STRING_QM
                 | condition_element (arithmetic_operator condition_element)+
                 ;
variable: NAME
        ;


parametr: PARAMETER parametrBody
        ;

parametrBody: L_PARENTHESES ( assignment ( COMMA AMPERSAND? assignment )* )* R_PARENTHESES
            | assignment
            ;


format: FORMAT formatBody
      ;

formatBody: L_PARENTHESES ( descriptor ( ( COMMA | SLASH ) descriptor )* )* R_PARENTHESES
           ;

descriptor: DESCRIPTOR
          | STRING_QM
          | DOLLAR_SIGN
          | variable
          ;

go_to: GO_TO ( statement_of_executable | value )*
     ;

subroutine_call: CALL function_name function_body?
               ;

intrinsic_call: INTRINSIC_NAME
               |INTRINSIC_NAME L_PARENTHESES argument (COMMA arithmetic_operator? argument)* R_PARENTHESES
            ;

function_call: function_name function_body
             ;

function_name: NAME
            ;

function_body: L_PARENTHESES argument ( COMMA arithmetic_operator? argument )* R_PARENTHESES
            | L_PARENTHESES R_PARENTHESES
             ;

statement_of_executable: L_PARENTHESES? (element)+ (COMMA|element)* R_PARENTHESES?;

argument: ( PLUS | MINUS | AMPERSAND | ASTERISK )? variable
        | ( NUMBER? COLON )? function_call
        | ( PLUS | MINUS | AMPERSAND | ASTERISK )? NUMBER
        | STRING_QM
        | element ( arithmetic_operator element )*
        | intrinsic_call
        ;


assignment: ( array_elements | function_call | variable | NAME| function_call | arrayDeclarator ) ASSIGNMENT (value |NUMBER|NAME| function_call | arrayDeclarator| assignment| negativeNumber)
          ;

////assign is a string or function/array followed by an equal operator and a number, string or functionOrArray
//assign: (NAME| function_call | arrayDeclarator) ASSIGNMENT (NUMBER|NAME| function_call | arrayDeclarator);

value: element
      (( arithmetic_operator | CONCATENATION )? AMPERSAND?
        (
         ( L_PARENTHESES element R_PARENTHESES ) | element
        )
      )*
     | condition
     ;

element: array_elements
       | ( NUMBER? COLON )? function_call
       | parametr
       | format
       | variable
       | STRING_QM
       | descriptor
       | NUMBER
       | BOOLEAN
       | element (arithmetic_operator element)+
       ;

arithmetic_operator: PLUS
                   | MINUS
                   | ASTERISK
                   | SLASH
                   | EXPONENTIATION
                   ;

relational_operator: LESS_THAN
                   | LESS_THAN_OR_EQUAL
                   | EQUAL
                   | NOT_EQUAL
                   | GREATER_THAN
                   | GREATER_THAN_OR_EQUAL
                   ;

logical_operator: AND
                | OR
                | EQUIVALENT
                | NON_EQUIVALENT
                ;

array_elements: NAME L_PARENTHESES NUMBER (COLON NUMBER)? R_PARENTHESES
              ;

return_block: RETURN
      ;

exit: EXIT L_PARENTHESES ( NUMBER | NUMBER ) R_PARENTHESES
    | EXIT
    ;

stop: STOP
    ;

save: SAVE ( COLON COLON )? ( variable | structureVariableName | assignment )
    ( COMMA ( variable | structureVariableName | assignment ) )*
    ;

cycle: CYCLE
     ;

end: END
   ;


variableType: typeName variablesNameList
            | completeStructure
            | recordStructure
            | doublePrecisionVariable
            | externalVariable
            | realInit

            ;

variablesNameList: variableName (COMMA variableName)*
                 | characterVariable (COMMA characterVariable)*;

//Structure

completeStructure: structureTypeStart structureBodyContent structureTypeEnd;
structureTypeStart: STRUCTURE structureVariableName;
structureVariableName: SLASH NAME SLASH;
structureBodyContent: variableType*;
structureTypeEnd: typeName STRUCTURE;


//Record
recordStructure: recordStatement variablesNameList;
recordStatement: RECORD SLASH NAME SLASH;

//Double

doublePrecisionVariable: doublePrecision (NAME | NAME function_body);
doublePrecision: DOUBLE PRECISION ;

//External
externalVariable: typeName NAME;

//Array Declaration
arrayDeclarator: (NAME|REAL) L_PARENTHESES insideArrayDeclarator R_PARENTHESES;
insideArrayDeclarator: NUMBER (COMMA NUMBER)* | NAME*;



//REAL initialization
realInit: realVariable realValue (COMMA realValue)*;
realVariable: REAL;
realValue:NAME SLASH NUMBER SLASH;
//Variable Names
characterVariable: variableName (variableLengthSpec) | characterVariableLength;
characterVariableLength: L_PARENTHESES LEN ASSIGNMENT NUMBER R_PARENTHESES variableName | characterAltLength;
variableLengthSpec: ASTERISK characterLength;
variableName: NAME | arrayDeclarator;
typeName: INTEGER | REAL | DOUBLE | LOGICAL | CHARACTER | STRUCTURE | RECORD | EXTERNAL | DATA | END;
characterLength: NUMBER | L_PARENTHESES ASTERISK R_PARENTHESES;
characterAltLength: ASTERISK L_PARENTHESES? NUMBER R_PARENTHESES? (NAME | function_call)?;

//assign here                           and assign here
file: (data_init |data|assignment) ((data_init|data))*;

////data is a data initializer followed by a newline, &, slash, and then variables to assign to the data initialized
data: data_init AMPERSAND? data_initial;
data_initial: SLASH ( AMPERSAND? value ) ( COMMA ( AMPERSAND? value ) )* SLASH;
////data init is a data intializer that initializes variables, does not need to assign the variables
data_init: DATA NAME ( COMMA NAME )* ;
//functionOrArray: NAME L_PARENTHESES (NAME|NUMBER? R_PARENTHESES; //Not sure if needed to differeniate Array and Function

////////////////////////////

io_statement: read
            | write
            | open
            | print
            ;

        /* Following 4 parser rules specify the general format of each of the 4 IO Statements */
		read: (READ L_PARENTHESES reads_list2 R_PARENTHESES io_list)        //Supports format: READ([UNIT=] u [, [FMT=]f] [, IOSTAT=ios] [, REC=rn] [, END=s] [, ERR=s]) iolist
			 | (READ gr_name)                                    //Supports format: READ grname
			 | (READ L_PARENTHESES reads_list R_PARENTHESES)                 //Supports format: READ([UNIT=] u, [NML=] grname [, IOSTAT=ios] [, END=s] [, ERR=s])
		     | (READ read_format io_list)                        //Supports format: READ f [, iolist] where f is a format identifier
			 ;

		write: (WRITE L_PARENTHESES writes_list R_PARENTHESES)             //Suuports format: WRITE([ UNIT=] u, [NML=] grname [, IOSTAT=ios] [, ERR=s])
			 | (WRITE L_PARENTHESES writes_list2 R_PARENTHESES AMPERSAND? io_list)     //Supports format: WRITE([UNIT=] u [, [FMT=] f] [, IOSTAT=ios] [, REC=rn] [, ERR=s]) iolist
			 | WRITE write_format AMPERSAND? io_list
			 ;

		open: OPEN L_PARENTHESES open_format R_PARENTHESES;                //Supports one and only existing format of OPEN (according to Oracle Docs): OPEN ([UNIT=] u, slist)

		print: (PRINT print_format (COMMA io_list)? )          //Supports statements in the format: PRINT f [, iolist]
		      | (PRINT gr_name)                                 //Supports statements in the format: PRINT grname
		      ;

        /* Output Formats for/of each IO Statements */
		//plan to include formats other than an asterisk as well
		print_format: (L_PARENTHESES NUMBER COMMA ASTERISK R_PARENTHESES)
		            | ASTERISK | NUMBER | SINGLEQUOTED_STRING
		            | (L_PARENTHESES ASTERISK COMMA ASTERISK R_PARENTHESES)
		            ;
		read_format: (L_PARENTHESES NUMBER COMMA ASTERISK R_PARENTHESES)
        		   | ASTERISK COMMA
        		   | (L_PARENTHESES ASTERISK COMMA ASTERISK R_PARENTHESES)
        		   | (L_PARENTHESES (NAME | NUMBER | SINGLEQUOTED_STRING) COMMA (NUMBER | NAME| SINGLEQUOTED_STRING) R_PARENTHESES)
        		   ;
		write_format: (L_PARENTHESES (NUMBER | NAME | ASTERISK) COMMA (SINGLEQUOTED_STRING | NUMBER | NAME | ASTERISK) R_PARENTHESES)
			    	 //Single Quoted string is label that takes to a formatting option
					;
		 open_format: unit_s opens_list*
		            ;

		//IO_LIST is a list of variables that can appear in an IO statement
		//it should be implemented (later on) to include variables, substrings,
		// arrays, array_elements, record fields, and any other expressions
		//having to declare N | n | C | c separately to include variable names that are either just N or n or C or c because parser thinks its either ios or Comment
		io_list: (NAME | STRING_QM | SINGLEQUOTED_STRING | arr_decl1 | arrayDeclarator) (COMMA io_list)*;

		//list of specifiers for OPEN statements
		opens_list: COMMA AMPERSAND? (file_s | access_s | blank_s | err_s | form_s | ioStat_s | recl_s | status_s | fileOpt_s | action_s);

		reads_list: unit_s COMMA namelist_s (COMMA ioStat_s)? (COMMA end_s)? (COMMA err_s)?;
		reads_list2: unit_s (COMMA (format_s | ioStat_s | recl_s | err_s | end_s))*;

        writes_list: unit_s COMMA namelist_s (COMMA ioStat_s)? (COMMA err_s)?;
		writes_list2: unit_s (COMMA AMPERSAND? (format_s | ioStat_s | recl_s | err_s ))*;

		arr_decl1: L_PARENTHESES (NAME L_PARENTHESES NAME (COMMA NAME)* R_PARENTHESES) (COMMA NAME ASSIGNMENT NUMBER) (COMMA NUMBER) R_PARENTHESES;

		gr_name: NAME;

        //Specifier Statements
        unit_s: (UNIT ASSIGNMENT)? u;
		file_s: (FILE | NAME) ASSIGNMENT f_name;
		access_s: ACCESS ASSIGNMENT ACC;
		blank_s: BLANK ASSIGNMENT BLNK;
		err_s: ERR ASSIGNMENT s;
		form_s: FORM ASSIGNMENT FRM;
		ioStat_s: IOSTAT ASSIGNMENT ios;
		recl_s: RECL ASSIGNMENT rl;
		status_s: STATUS ASSIGNMENT STA;
		fileOpt_s: FILEOPT ASSIGNMENT FOPT;
		action_s: ACTION ASSIGNMENT ACT;
		namelist_s: (NML ASSIGNMENT)? gr_name;
		end_s: END ASSIGNMENT statement_label;
        format_s: (FMT ASSIGNMENT)? f;

//Comments
comment: COMMENT;

//Loops
loop: (do_loop | do_while) ;
do_loop: (DO loop_control block end_loop)       //Supports format: DO loop-control where loop control is specfied down below
       | DO statement_no (COMMA)? loop_control block terminal_statement;       //Supports format: DO s [,] loop-control where s is a statement number

//DO While has the following format: DO [ s [,]] WHILE (e)
do_while: DO WHILE (L_PARENTHESES condition R_PARENTHESES) block end_loop            //a DO while without a statement number
        | DO statement_no (COMMA)? WHILE (L_PARENTHESES condition R_PARENTHESES) block terminal_statement       //DO while WITH a statement number
        ;

//block of statements inside the loop construct
block: statement+;

statement_no: NUMBER;
terminal_statement: statement_no CONTINUE;      //cant be some particular statements...plan to specify these as ~

//The form of loop-control is variable = e1, e2 [, e3]
loop_control: variable ASSIGNMENT initial_value COMMA limit_value (COMMA increment_value)?;

//e1, e2, and e3 respectively
initial_value: NUMBER | realValue | variable;
limit_value: NUMBER | realValue | variable;
increment_value: NUMBER | realValue | variable;

end_loop: END DO;

/////////////////////////LEXER RULES/////////////////////////////

//keywords
INTEGER: 'integer' | 'INTEGER';
LOGICAL: 'logical' | 'LOGICAL';
CHARACTER: 'character' | 'CHARACTER';
DOUBLE: 'double' | 'DOUBLE';
PRECISION: 'precision' | 'PRECISION';
EXTERNAL: 'external' | 'EXTERNAL';
DIMENSION: 'dimension' | 'DIMENSION';
REAL: 'real' | 'REAL';
STRUCTURE: 'structure' | 'STRUCTURE';
RECORD: 'record' | 'RECORD';
END: 'end' | 'END';
DATA: 'data' | 'DATA';
IF: 'if' | 'IF';
THEN: 'then' | 'THEN';
ELSE: 'else' | 'ELSE';
ELSE_IF: 'elseif' | 'ELSEIF';
ENDIF: 'endif' | 'ENDIF';
STOP: 'stop' | 'STOP';
EXIT: 'exit' | 'EXIT';
GO_TO: 'GO TO' | 'GOTO' | 'go to' | 'goto';
LOGICAL_OPERATOR_NOT: '.not.' | '.NOT.';
CALL: 'call' | 'CALL';
PARAMETER : 'parameter' | 'PARAMETER';
FORMAT : 'format' | 'FORMAT';
SAVE: 'save' | 'SAVE';
CYCLE: 'cycle' | 'CYCLE';
LEN: 'len';

AND: '.and.' | '.AND.';
OR: '.or.' | '.OR.';
EQUIVALENT: '.eqv.' | '.EQV.';
NON_EQUIVALENT: '.neqv.' | '.NEQV.';

LESS_THAN: '<' | '.lt.' | '.LT.';
LESS_THAN_OR_EQUAL: '<=' | '.le.' | '.LE.';
EQUAL: '==' | '.eq.' | '.EQ.';
NOT_EQUAL: '/=' | '.ne.' | '.NE.';
GREATER_THAN: '>' | '.gt.' | '.GT.';
GREATER_THAN_OR_EQUAL: '>=' | '.ge.' | '.GE.';

//IO Statements
		PRINT: 'PRINT' | 'print';
		READ: 'READ' | 'read';
		WRITE: 'WRITE' | 'write';
		OPEN: 'OPEN' | 'open';
//IO Specifiers
		FILE: 'FILE';

		UNIT: 'UNIT';
		FMT: 'FMT';
		FORM: 'FORM';
		IOSTAT: 'IOSTAT';
		RECL: 'recl' | 'REC' | 'RECL';
		ERR: 'ERR';
		ACCESS: 'ACCESS';
		STATUS: 'STATUS';
		ACTION: 'ACTION';
		BLANK: 'BLANK';
		FILEOPT: 'FILEOPT';
		NML: 'NML'; //namelist
//Values of IO Specifiers
        //ACCESS = ACC
        ACC: '\'' 'SEQUENTIAL' '\'' | '\'' 'DIRECT' '\'' | '\'' 'APPEND' '\'';
        //FORM = FRM
        FRM: '\'' 'FORMATTED' '\'' | '\'' 'UNFORMATTED' '\'' | '\'' 'PRINT' '\'';
        //STATUS = STA
        STA: '\'' 'NEW' '\'' | '\'' 'OLD' '\'' | '\'' 'SCRATCH' '\'' | '\'' 'UNKNOWN' '\'';
        //ERR = s
        s: statement_label;
        //ACTION = ACT;
        ACT: '\'' 'READ' '\'' | '\'' 'WRITE' '\'' | '\'' 'READWRITE' '\'';
        //BLANK = BLNK
        BLNK: '\'' 'NULL' '\'' | '\'' 'ZERO' '\'';
        //FILEOPT = FOPT
        FOPT: '\'' 'NOPAD' '\'' | '\'' 'EOF' '\'' | '\'' 'BUFFER=n' '\'';
        //IOSTAT = ios
       ios: err_no | NAME;
       //FILE = f_name
       f_name: ASTERISK | STRING_QM | NAME;
       //RECL = RL
       rl: NUMBER;
       //UNIT = u
       u: ASTERISK | NUMBER;

       f: SINGLEQUOTED_STRING | NUMBER | ASTERISK;
       statement_label: NUMBER;
       err_no: NUMBER;

stopStatement: STOP (NUMBER | NAME);
negativeNumber: MINUS NUMBER;
//Lexers for function/subroutine declaration
FUNCTION: 'FUNCTION' | 'function';
SUBROUTINE: 'SUBROUTINE' | 'subroutine';
RETURN: 'RETURN' | 'return';

INTRINSIC: 'INTRINSIC' | 'intrinsic';
INTRINSIC_NAME: 'ABS' | 'SIN' | 'COS' | 'TAN' | 'ASIN' | 'ACOS' | 'ATAN'
                | 'SQRT' | 'EXP' | 'LOG' | 'MAX' | 'MIN' | 'MOD'
                | 'LGT' | 'LGE' | 'LLT' | 'LLE'
                | 'CHAR' | 'LEN' ;

//Lexers for Loop statements
DO: 'do' | 'DO';
WHILE: 'while' | 'WHILE';
CONTINUE: 'continue' | 'CONTINUE';
KIND: 'KIND' | 'kind';
//Comments
COMMENT: WS? ~([a-zA-Z0-9.%_() ])* (C|'!')+ (WS|'!' ID) ~([=></.]) ~('\n'|'\r')*;
BOOLEAN: TRUE | FALSE;
NUMBER: DIGIT+ ( [.] DIGIT* )? ( [Ee] ( PLUS | MINUS ) DIGIT+ )?;
DESCRIPTOR: ( [IFELA] | 'ES' | 'EN' ) NUMBER | NUMBER [Xx] ;
NAME: STRING ( DIGIT | STRING )*;
COMMA: ',';
L_PARENTHESES: '(';
R_PARENTHESES: ')';
ASSIGNMENT: '=';
COLON: ':';
ASTERISK: '*';
AMPERSAND: '&';
PLUS: '+';
MINUS: '-';
SLASH: '/';
EXPONENTIATION: '**';
CONCATENATION: '//';
DOLLAR_SIGN: '$';

ID: ([A-Za-z] [a-zA-Z0-9_]*);
STRING_QM: QUOTATION_MARK ( STRING | [= :#/] | ' ' )* QUOTATION_MARK;
DOUBLEQUOTED_STRING: '"' (~'"')* '"';
SINGLEQUOTED_STRING: '\'' (~'\'')* '\'';

/* Fragments are reusable parts of lexer rules which cannot match on their own
(cannot be used in parser) - they need to be referenced from a lexer rule.
A fragment will never be counted as a token.*/
fragment QUOTATION_MARK: ['"];
fragment STRING: [a-zA-Z0-9.%_]+;
fragment DIGIT : [0-9] ;
fragment TRUE: '.true.' | '.TRUE.';
fragment FALSE: '.false.' | '.FALSE.';
fragment C: 'c' | 'C';

WS : [ \t\r\n]+ -> skip;
