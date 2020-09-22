grammar C;

@header {
  import java.io.*;
}

program
  :'class Program {'Id'}'
  ;



Id
  : Alpha AlphaNum*
  ;

fragment
AlphaNum
  : Alpha
  | Digit
  ;

fragment
Alpha
    : [a-zA-Z_]
    ;

fragment
Digit
  : [0-9]
  ;
