grammar CCompiler;


@header { 
import java.io.*;
import java.util.*;
}

@members {


public final int NOT_VALID = -1;
public final int NONE = -1;
public final int DATA_SIZE = 8;
public final String CONST_PREFIX = "const_";
public final String LABEL_PREFIX = "L";

public enum SymType {
	INT("INT"),
	CHAR("CHAR"), 
	BOOL("BOOL"),
	STR("STR"),
	VOID("VOID"),
	LABEL("LABEL"),
	INVALID("INVALID");
	public final String text;
    SymType(String text) {
		this.text = text;
	}
	public String toString() {
		return text;
	}
}

public enum Scope {
	GLOBAL("GLOBAL"),
	LOCAL("LOCAL"),
	CONST("CONST"),
	INVALID("INVALID");
	public final String text;
    Scope(String text) {
		this.text = text;
	}
	public String toString() {
		return text;
	}
}

public enum Opcode {
	ADD("ADD"), SUB("SUB"), MUL("MUL"), DIV("DIV"),
	NEG("NEG"), READ("READ"), WRITE("WRITE"), ASSIGN("ASSIGN"),
	GOTO("GOTO"), LT("LT"), GT("GT"), LE("LE"), GE("GE"), EQ("EQ"), NE("NE"), 
	PARAM("PARAM"), CALL("CALL"), RET("RET"), LABEL("LABEL"), INVALID("INVALID");
	public final String text;
	Opcode(String text) {
		this.text = text;
	}
	public String toString() {
		return text;
	}
}





public class IdGenerator {

	private int tempUid = -1;
	private int sUid = -1;
	private int stUid = -1;
	private int instrUid = -1;
	private int exprLabelUid = -1;
	
	public int symNextUid() {
		this.sUid += 1;
		return this.sUid;
	}
	
	public String nextTempName() {
		this.tempUid += 1;
		return CONST_PREFIX;
	}
	
	public int symtabNextUid() {
		this.stUid += 1;
		return this.stUid;
	}
	
	public int instrNextUid() {
		this.instrUid += 1;
		return this.instrUid;
	}
	
	public String nextExprLabelName() {
		this.exprLabelUid += 1;
		return LABEL_PREFIX + Integer.toString(this.exprLabelUid);
	}	
	
}





public class Symbol {

	private int id;
	private int tabid = 0;
	private String name; // n
	private SymType type; // t
	private Scope scope;
	private boolean isArray = false;
	private String arraySize = "0"; // a
	private boolean isInitialized = false;
	private String initVal = "0";
	
	public Symbol(SymType t) {
		id = idgen.symNextUid();
		name = idgen.nextTempName();
		type = t;
	}
	
	public Symbol(String n, SymType t) {
		id = idgen.symNextUid();
		name = n;
		type = t;
	}
	
	public Symbol(String n, SymType t, String a) {
		id = idgen.symNextUid();
		name = n;
		type = t;
		isArray = true;
		arraySize = a;
	}
	
	public String getName() {
		return name;
	}
	
	public int id() {
		return id;
	}
	
	public SymType type() {
		return this.type;
	}
	
	public void setTable(SymbolTable st) {
		this.tabid = st.id();
	}
	
	public void setScope(Scope s) {
		this.scope = s;
	}
	
	public void setInitVal(String val) {
		this.isInitialized = true;
		this.initVal = val;
		if (scope == Scope.CONST) {
			this.name = CONST_PREFIX + val;
		}
	}

	public void show() {
		System.out.println("> Sym [show]");
		System.out.println(this.id + ", " + this.tabid + ", " + this.name + ", " + this.type + ", " + this.scope + ", " + this.isArray + ", " + this.arraySize + ", " + isInitialized + ", " + initVal);
	}
	
	public String toCSVStr() {
		StringBuilder sb = new StringBuilder();
		sb.append(id);
		sb.append(',');
		sb.append(tabid);
		sb.append(',');
		sb.append(name);
		sb.append(',');
		sb.append(type);
		sb.append(',');

		sb.append(scope);
		sb.append(',');
		sb.append(isArray);
		sb.append(',');
		sb.append(arraySize);
		sb.append(',');
		sb.append(isInitialized);
		sb.append(',');
		sb.append(initVal);
		sb.append(',');
		sb.append('\n');
		return sb.toString();
	}

}






public class SymbolTable {

	private int id;
	private int pid;
	private List<Symbol> symbols = new ArrayList<>();
	
	public SymbolTable(int pid) {
		this.id = idgen.symtabNextUid();
		this.pid = pid;
	}
	
	public int getSymbolId(String name) {
		for (Symbol s : symbols) {
			if (name.equals(s.getName())) {
				return s.id();
			}
		}
		return NOT_VALID;
	}
		
	public Symbol getSymbol(String name) {
		for (Symbol s : symbols) {
			if (name.equals(s.getName())) {
				return s;
			}
		}
		return null;
	}
	
	public boolean symbolExists(String name) {
		return getSymbolId(name) != NOT_VALID;
	}
	
	public Symbol makeSymbol(SymType t) {
		Symbol s = new Symbol(t);
		s.setTable(this);
		s.setScope(Scope.CONST);
		symbols.add(s);
		return s;
	}
	
	public Symbol makeSymbol(String n, SymType t) {
		if (symbolExists(n)) return getSymbol(n);
		Symbol s = new Symbol(n, t);
		s.setTable(this);
		s.setScope(this.tableScope());
		symbols.add(s);
		return s;
	}
	
	public Symbol makeSymbol(String n, SymType t, String a) {
		if (symbolExists(n)) return getSymbol(n);
		Symbol s = new Symbol(n, t, a);
		s.setTable(this);
		s.setScope(this.tableScope());
		symbols.add(s);
		s.show();
		return s;
	}
	
	public Scope tableScope() {
		if (this.id == 0) return Scope.GLOBAL;
		if (this.id > 0) return Scope.LOCAL;
		return Scope.INVALID;
	}
	
	public int id() {
		return this.id;
	}
	
	public int pid() {
		return this.pid;
	}
	
	public List<Symbol> symbols() {
		return this.symbols;
	}
	
	public void show() {
		System.out.println("> SymTab [show]");
		System.out.println("ID: " + id + ", PID: " + pid + ", SymCount: " + symbols.size());	
	}
	
}




public class ParentTable {
	private int tid;
	private int pid;
	
	public ParentTable(int t, int p) {
		tid = t;
		pid = p;
	}
	
	public ParentTable(SymbolTable st) {
		tid = st.id();
		pid = st.pid();
	}
	
	public void show() {
		System.out.println(tid + ", " + pid);
	}
	
	public String toCSVStr() {
        StringBuilder sb = new StringBuilder();
		sb.append(tid);
		sb.append(",");
		sb.append(pid);
		sb.append(",");
		return sb.toString();
	}
}

public class SymbolTableStack {

	private Stack<SymbolTable> stack = new Stack();
	private List<SymbolTable> popped = new ArrayList<>();
	private List<ParentTable> history = new ArrayList<>();
	
	public SymbolTableStack() {
		this.makeNewTable();
	}
	
	public void push(SymbolTable t) {
		t.show();
		this.stack.push(t);
	}
	
	public SymbolTable pop() {
		SymbolTable st = this.stack.pop();
		this.popped.add(0, st);
		return st;
	}
	
	public SymbolTable peek() {
		return this.stack.peek();
	}
	
	public int lastId() {
		return this.stack.peek().id();
	}
	
	public int getSymbolId(String n) {
		for (SymbolTable st : stack) {
			System.out.println("Getting from tableid " + st.id());
			
			int id = st.getSymbolId(n);
			
			System.out.println("\t it returns " + id);
			if (id != NOT_VALID) return id;
		}
		return NOT_VALID;
	}
	
	public Symbol getSymbol(String n) {
		for (SymbolTable st : stack) {
			Symbol s = st.getSymbol(n);
			if (s != null) return s;
		}
		return null;
	}
	
	public Symbol add(SymType t) {
		SymbolTable top = this.stack.peek();
		return top.makeSymbol(t);
	}
	
	public Symbol add(String n, SymType t) {
		SymbolTable top = this.stack.peek();
		return top.makeSymbol(n, t);
	}
	
	public Symbol add(String n, SymType t, String a) {
		SymbolTable top = this.stack.peek();
		return top.makeSymbol(n, t, a);
	}
	
	public SymType strToSymType(String str) {
		switch (str) {
			case "int": return SymType.INT;
			case "boolean": return SymType.BOOL;
			case "void": return SymType.VOID;
		}
		return SymType.INVALID;
	}
	
	public Opcode strToOpcode(String str) {
		switch (str) {
			case "+": return Opcode.ADD;
			case "-": return Opcode.SUB;
			case "*": return Opcode.MUL;
			case "/": return Opcode.DIV;
			case "%": return Opcode.DIV;
			case "!": return Opcode.NEG;
			case "<": return Opcode.LT;
			case ">": return Opcode.GT;
			case "<=": return Opcode.LE;
			case ">=": return Opcode.GE;
			case "==": return Opcode.EQ;
			case "!=": return Opcode.NE;
		}
		return Opcode.INVALID;
	}
	
	public void makeNewTable() {
		int pid = -1;
		if (!this.stack.empty()) pid = this.lastId();
		SymbolTable st = new SymbolTable(pid);
		this.stack.push(st);
		ParentTable pt = new ParentTable(st);
		history.add(pt);
	}
	
	public void show() {
		System.out.println("> SymTS [show]");
		System.out.println("Stack size: " + this.stack.size() + ", Top TID: " + this.stack.peek().id());
	}
	
	public void showAll() {
		for (SymbolTable st : stack) {
			for (Symbol s : st.symbols()) {
				s.show();
			}
		}
		for (SymbolTable st : popped) {
			for (Symbol s : st.symbols()) {
				s.show();
			}
		}
	}
	
	public void showAllTables() {
		for (ParentTable pt : history) {
			pt.show();
		}
	}
	
	public void makeSymtablesCSV() throws FileNotFoundException {
		PrintWriter pw = new PrintWriter(new File("symtables.csv"));
        StringBuilder sb = new StringBuilder();
		for (ParentTable pt : history) {
			sb.append(pt.toCSVStr());
			sb.append("\n");
		}
        pw.write(sb.toString());
        pw.close();
	}
	
	public void makeSymbolsCSV() throws FileNotFoundException {
		PrintWriter pw = new PrintWriter(new File("symbols.csv"));
        StringBuilder sb = new StringBuilder();
		for (SymbolTable st : stack) {
			for (Symbol s : st.symbols()) {
				sb.append(s.toCSVStr());
			}
		}
		for (SymbolTable st : popped) {
			for (Symbol s : st.symbols()) {
				sb.append(s.toCSVStr());
			}
		}
        pw.write(sb.toString());
        pw.close();
	}


}


public class Instruction {

	private int id;
	private int res;
	private Opcode opc;
	private int op1;
	private int op2;
	
	public Instruction(int r, Opcode op, int o1, int o2) {
		id = idgen.instrNextUid();
		res = r;
		opc = op;
		op1 = o1;
		op2 = o2;
	}
	
	public int id() {
		return id;
	}
	
	public String toCSVStr() {
		return (id + ", " + res + ", " + opc + ", " + op1 + ", " + op2 + ",");
	}

}

public class InstructionTable {
	
	private List<Instruction> instrs = new ArrayList<>();
	
	public int gen(int r, Opcode op, int o1, int o2) {
		Instruction i = new Instruction(r, op, o1, o2);
		this.add(i);
		return i.id();
	}
	
	public void add(Instruction i) {
		this.instrs.add(i);
	}
	
	// instructions.csv
	public void makeInstructionsCSV() throws FileNotFoundException {
		PrintWriter pw = new PrintWriter(new File("instructions.csv"));
        StringBuilder sb = new StringBuilder();
		for (Instruction i : instrs) {
			sb.append(i.toCSVStr());
			sb.append("\n");
		}
        pw.write(sb.toString());
        pw.close();
	}
	
}

public class ExprLists {

	public List<Symbol> nextl = new ArrayList<>();
	public List<Symbol> breakl = new ArrayList<>();
	public List<Symbol> contl = new ArrayList<>();
	public List<Symbol> truel = new ArrayList<>();
	public List<Symbol> falsel = new ArrayList<>();

}

public class ExprLabels {
	
	public Symbol createLabel() {
		Symbol label = sts.add(idgen.nextExprLabelName(), SymType.LABEL);
		int id = itable.gen(label.id(), Opcode.LABEL, NONE, NONE);
		return label;
	}
	
}




// Instances

IdGenerator idgen = new IdGenerator();

SymbolTableStack sts = new SymbolTableStack();

InstructionTable itable = new InstructionTable();

}




















	


prog
	: Class Program '{' field_decl_els method_decl_els '}' EOF {
		/*
		sts.show();
		
		// symbols 
		System.out.println("");
		System.out.println(">\t Showing all symbols...");
		sts.showAll();
		
		// table stack
		System.out.println("");
		System.out.println(">\t Showing all tables...");
		sts.showAllTables();
		
		// instructions
		System.out.println("");
		System.out.println("\t Showing all instructions...");
		itable.show();
		*/
		
		
		
		try {
			sts.makeSymtablesCSV();
			sts.makeSymbolsCSV();
			itable.makeInstructionsCSV();
		} catch (FileNotFoundException e) {
			System.out.println("Exception occurred");
		}
	}
	;
	
literal returns [Symbol s]
	: Int_literal { 
		$s = sts.add(SymType.INT);
		String val = $Int_literal.text;
		$s.setInitVal(val);
	}
	| Char_literal { 
		$s = sts.add(SymType.CHAR);
		String val = $Char_literal.text;
		$s.setInitVal(val);
	}
	| Bool_literal { 
		$s = sts.add(SymType.BOOL);
		String val = $Bool_literal.text;
		$s.setInitVal(val);
	}
	;

Int_literal
	: Decimal_literal
	| Hex_literal
	;

Decimal_literal
	: Digit+
	;

Bool_literal
	: 'true'
	| 'false'
	;

Hex_literal
	: '0x' HexDigit+
	;

AssignOp
	: EqualOp
	| '-='
	| '+='
	;
	
EqualOp
	: '='
	;
	
BoolOp
	: RelOp
	| CondOp
	| EqOp
	;

RelOp
	: '<='
	| '>=' 
	| '<'
	| '>'
	;
	
EqOp
	: '=='
	| '!='
	;

ArithOp
	: '+'
	| '-'
	| '*'
	| '/'
	| '%'
	;

CondOp
	: '&&'
	| '||'
	| '!'
	;
	
Char_literal
	: '\''Char'\''
	;

String_literal
	: '"' ((~('\\' | '"')) | ('\\'.))* '"'
	;
	
program
	: Class Program OBrace field_decl* method_decl* CBrace
	;
	
field_decl_els
	:
	| field_decl_els field_decl SemiColon
	;

field_decl returns [Symbol s]
	: prev=field_decl Comma Ident {
		String n = $Ident.text;
		SymType t = $prev.s.type();
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	| prev=field_decl Comma Ident OBracket Int_literal CBracket {
		String n = $Ident.text;
		SymType t = $prev.s.type();
		String a = $Int_literal.text;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t, a);
		}
	}
	| Type Ident {
		String n = $Ident.text;
		SymType t = sts.strToSymType($Type.text);
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	| Type Ident OBracket Int_literal CBracket {
		String n = $Ident.text;
		SymType t = sts.strToSymType($Type.text);
		String a = $Int_literal.text;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t, a);
		}
	}
	| Type Ident AssignOp literal {
		String n = $Ident.text;
		SymType t = sts.strToSymType($Type.text);
		String val = $literal.text;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
		$s.setInitVal(val);

		itable.gen($s.id(), Opcode.ASSIGN, $s.id(), $literal.s.id());
	}
	;

method_decl returns [Symbol s]
	: Type Ident OParen {
		String n = $Ident.text;
		SymType t = SymType.LABEL;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
		
		itable.gen($s.id(), Opcode.LABEL, NONE, NONE);
	} method_params CParen block
	;
	
method_decl_els
	: 
	| method_decl method_decl_els 
	;
	
method_param returns [Symbol s]
	: Type Ident {
		String n = $Ident.text;
		SymType t = sts.strToSymType($Type.text);
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	;
	
method_params 
	:
	| method_param
	| method_params Comma method_param
	;
	
method_args
	:
	| expr
	| method_args Comma expr
	;

callout_arg
	: expr
	| String_literal
	;
	
callout_args returns [Symbol s, int count]
	: 
	| String_literal {
		String n = $String_literal.text;
		SymType t = SymType.STR;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
		$count = 1;
		
		itable.gen(NONE, Opcode.PARAM, $s.id(), NONE);
	}
	| expr {
		$s = $expr.s;
		$count = 1;
		itable.gen(NONE, Opcode.PARAM, $s.id(), NONE);
	}
	| c=callout_args Comma String_literal {
		String n = $String_literal.text;
		SymType t = SymType.STR;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
		$count = $c.count + 1;
		itable.gen(NONE, Opcode.PARAM, $s.id(), NONE);
	}
	| c=callout_args Comma expr {
		$s = $expr.s;
		$count = $c.count + 1;
		itable.gen(NONE, Opcode.PARAM, $s.id(), NONE);
	}
	;

method_call
	: mn=method_name OParen ma=method_args CParen {
		
	}
	| Callout OParen sl=String_literal { 
		String n = $sl.text;
		SymType t = SymType.STR;
		Symbol slSym = sts.getSymbol(n);
		if (slSym == null) {
			slSym = sts.add(n, t);
		}
	} Comma ca=callout_args CParen { 
		SymType t2 = SymType.INT;
		Symbol caSym = sts.add(t2);
		caSym.setInitVal(Integer.toString($ca.count));
		itable.gen(NONE, Opcode.CALL, slSym.id(), caSym.id());
	}
	;
	
method_name returns [Symbol s]
	: Ident {
		String n = $Ident.text;
		SymType t = SymType.STR;
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	;

block
	: OBrace {
		sts.makeNewTable();
	} var_decl_els statement_els CBrace {
		sts.pop();
	}
	;
	
statement_els returns [Symbol s]
	: statement_els statement 
	|
	;
	
var_decl_els 
	: var_decl_els var_decl SemiColon
	|
	;
	


var_decl returns [Symbol s]
	: prev=var_decl Comma Ident {
		String n = $Ident.text;
		SymType t = $prev.s.type();
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	| Type Ident {
		String n = $Ident.text;
		SymType t = sts.strToSymType($Type.text);
		$s = sts.getSymbol(n);
		if ($s == null) {
			$s = sts.add(n, t);
		}
	}
	;
	
location returns [Symbol s, Symbol offset]
	: Ident {
		String n = $Ident.text;
		$s = sts.getSymbol(n);
		$offset = null;
	}
	| Ident OBracket expr CBracket {
		String n = $Ident.text;
		$s = sts.getSymbol(n);
		$offset = sts.add(SymType.INT);
		itable.gen($offset.id(), Opcode.MUL, DATA_SIZE, $expr.s.id());
	}
	;
	
	
cases
	: Case literal Colon statement*
	| c=cases (Case literal Colon statement*)
	;
	
statement returns [Symbol s]
	: location AssignOp expr SemiColon {
	}
	| method_call SemiColon {

	}
	| If OParen e1=expr CParen e2=block {

	}
	| If OParen e1=expr CParen e2=block Else e3=block {

	}
	| Switch expr OBrace cases CBrace {
	
	}
	| While OParen expr CParen statement {

	}
	| Ret SemiColon {
		itable.gen(NONE, Opcode.RET, NONE, NONE);
	}
	| Ret expr SemiColon {
		itable.gen(NONE, Opcode.RET, $expr.s.id(), NONE);
	}
	| Brk SemiColon {

	}
	| Cnt SemiColon {

	}
	| block {
	
	}
	;
	
expr returns [Symbol s, ExprLists el, ExprLabels labels]
	: l=location {
		$s = $l.s;
		if ($l.offset != null) {
			itable.gen($s.id(), Opcode.READ, $l.s.id(), $l.offset.id());
		}
	}
	| method_call {
		
	}
	| literal {
		$s = $literal.s;
	}
	| e1=expr ArithOp e2=expr {
		SymType t1 = $e1.s.type();
		SymType t2 = $e2.s.type();
		if (t1 == t2 && (t1 != SymType.CHAR && t1 != SymType.BOOL)) {
			String opStr = $ArithOp.text;
			Opcode op = sts.strToOpcode(opStr);
			$s = sts.add(t1);
			itable.gen($s.id(), op, $e1.s.id(), $e2.s.id());
		}
	}
	| e1=expr BoolOp { 
		$labels = new ExprLabels(); 
		Symbol l1 = $labels.createLabel();
	} e2=expr {
		SymType t1 = $e1.s.type();
		SymType t2 = $e2.s.type();
		if (t1 == t2) {
			String opStr = $BoolOp.text;
			Opcode op = sts.strToOpcode(opStr);
			$s = sts.add(t1);
			itable.gen($s.id(), op, $e1.s.id(), $e2.s.id());
		}
	}
	| '-' expr {
		Opcode op = Opcode.NEG;
		$s = sts.add($expr.s.type());
		itable.gen($s.id(), op, $expr.s.id(), NONE);
	}
	| '!' expr {
		Opcode op = Opcode.NEG;
		$s = sts.add($expr.s.type());
		itable.gen($s.id(), op, $expr.s.id(), NONE);
	}
	| '(' expr ')' {

	}
	;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

Class
	: 'class'
	;

Program
	: 'Program'
	;

If
	: 'if'
	;

Else
	: 'else'
	;

While
	: 'while'
	;

Switch
	: 'switch'
	;

Case
	: 'case'
	;

Ret
	: 'return'
	;

Brk
	: 'break'
	;

Cnt
	: 'continue'
	;

Callout
	: 'callout'
	;
		
Num
	: Digit+
	;

HexNum
	: '0x'HexDigit+
	;

Type
	: 'int' 
	| 'boolean'
	| 'void'
	;
	
OParen
	: '('
	;

CParen
	: ')'
	;

OBrace
	: '{'
	;

CBrace
	: '}'
	;

OBracket
	: '['
	;

CBracket
	: ']'
	;

SemiColon
	: ';'
	;
	
Colon
	: ':'
	;

Comma
	: ','
	;
	
bin_op
	: ArithOp
	| BoolOp
	;	
	
Ident
	: Alpha AlphaNum* 
	;
	
WS
    :   [ \t\r\n]+ -> skip
    ;
	
Char
	: '\'' ~('\\') '\''
	| '\'\\' . '\'' 
	;

fragment Letter
	: [a-zA-Z]
	;

fragment Digit
	: [0-9]
	;
	
fragment HexDigit
	: Digit
	| [a-f]
	| [A-F]
	;

fragment Alpha
	: Letter
	| '_'
	;

fragment AlphaNum
	: Alpha
	| Digit
	;
