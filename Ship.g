grammar Ship;

tokens {

    
    ALL        = 'All';
    SENDER   = 'Sender';
    SUCCESS      = 'Success';
    FAILURE       = 'Failure';
    TIMEOUT         = 'Timeout';
  }

@init {
}
@members {

class CMD
  class << self; attr_accessor :destination,:signature,:notify_on,:notify_recipient,:notify_criteria end
  @destination='localhost';
  @signature='No' ;
  @notify_on ="Yes"
  @notify_recipient='All';
  @notify_criteria='Success';
 def self.toString
	cmd_str= "send -host=" << destination << " -signature=" << signature << " -notify_on=" << notify_on << " -notify_recipient=" << notify_recipient << " -notify_criteria=" << notify_criteria	;
	puts cmd_str;
 end	
end

class Query
  class << self; attr_accessor :connection_string,:query end
  @query='';
  @connection_string='default' ;
 def self.toString
        query_str= "sql -connection_string=" << connection_string << " -query= " <<query ;
        puts query_str;
 end
end

}
file 
    : object+ {CMD.toString;} {Query.toString;} 
    ;
object
   :       qid {#puts $qid.text;} (ID {#puts $ID.text;})? '{' assign* '}'  
    ;
assign 
    :   ID '=' expr ';' {#puts $ID.text;} {#puts $expr.value.to_s;}
    ;
expr returns [value] 
    :   STRING {$value= $STRING.text;}
    |   ('$')?ID {$value= $ID.text;}	
    |   INT {$value= $INT.text;}
    |   '[' ']'
    |   query {$value=$query.text;}{Query.query = $value}
    |   command {$value=$command.text;}
    |    {elements= Array.new;} 
       '[' e=expr {elements.push($e.value);}
	(',' e=expr {elements.push($e.value);} )* ']'
        {$value=elements;}
    ;
qid  
   :   a=ID ('.' b=ID {#puts $b.text;})*  {#puts $a.text;} 
   ;
query
     :    select_stmt where_stmt   
     ;
select_stmt 
     :  'select' '*' 'from' (directory | table)
     ;
directory
       : '/' ID  
       ;
table
       : ID
       ;
where_stmt 
     :  ('where' clause ('and' clause)*) ?
     ;
clause 
     : file_name
     | pattern
     | ID '=' STRING 
     ;
file_name
       : 'file'  '=' STRING
       ;
pattern
       :   'pattern'  '=' STRING
       ;

command
      :  (send_command delivery_options* 
      |  wait_command) 
      ;
send_command
      :	'Send' container? 'to' destination ('by' send_channel)? 
      ;
container
      :  ID  
      ;
destination
      : ID {CMD.destination=$ID.text;}  
      ;
send_channel
      : ID
      ;
delivery_options
     : 'Get' 'Signature' {CMD.signature="Yes";}
     |  notify_on  {CMD.notify_on="Yes";}
     ;
notify_on
      : 'Notify' notify_recipient 'on' notify_criteria
         {CMD.notify_recipient=$notify_recipient.value.to_s;}
	 {CMD.notify_criteria=$notify_criteria.value.to_s;} 
      ;
notify_recipient returns [value]
      : SENDER {$value=$SENDER;}
      | ALL {$value=$ALL;}
      ;
notify_criteria returns [value]
       : SUCCESS {$value=$SUCCESS;}
       | FAILURE {$value=$FAILURE;}
       | TIMEOUT {$value=$TIMEOUT;}
       ;
wait_command
        :       'wait' 'for' wait_criteria  notify_on?
        ;
wait_criteria
        : ID
        ;
	
STRING :('\''.*'\''|'"'.*'"');
INT :   '0'..'9'+ ;
ID  :   ('_'|'-'|'a'..'z'|'A'..'Z') ('_'|'-'|'\.'|'a'..'z'|'A'..'Z'|'0'..'9')* ;
WS  :   (' '|'\n'|'\t')+ {$channel=HIDDEN;} ;
CMT :   '/*' .* '*/'     {$channel=HIDDEN;} ;

