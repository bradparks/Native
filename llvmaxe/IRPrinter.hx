/*
 * Copyright (C)2005-2013 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package llvmaxe;

import haxe.ds.StringMap;

import haxe.macro.Expr.Unop;
import haxe.macro.Expr.Binop;
import haxe.macro.Expr.TypeParam;
import haxe.macro.Expr.TypePath;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.TypeParamDecl;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Function;
import haxe.macro.Expr;

import haxe.macro.Type;
import haxe.macro.TypedExprTools;

using Lambda;
using haxe.macro.Tools;
using StringTools;

class IRPrinter {

	public static var insideConstructor:String = null;
	public static var superClass:String = null;

	public static var strings:Array<String> = [];
	public static var stringslen:Map<String,Int> = new Map();

	var tabs:String;
	var tabString:String;
	var bit:String = "64";

	public static var currentPath = "";
	public static var lastConstIsString = false;

	static var keywords = [];
	var kw = [ "abstract", "as", "assert", "break", "case", "catch", "class", "const",
							"continue", "default", "do", "dynamic", "else", "export", "external", "extends",
							"factory", "false", "final", "finally", "for", "get", "if", "implements",
							"import" , "in", "is", "library", "new", "null", "operator", "part",
							"return", "set", "static", "super", "switch", "this", "throw", "true",
							"try", "typedef", "var", "void", "while", "with" ];

	static var standardTypes:Map<String, String> = [
		"Array" => "List",
		"Int" => "int",
		"Float" => "double",
	];

	public static var pathHack = new StringMap();

	public static function mapStandardTypes(typeName)
	{
		var mappedType = standardTypes.get(typeName);
		return mappedType == null ? typeName : mappedType;
	}

	public static function handleKeywords(name)
	{
		if(keywords.indexOf(name) != -1)
			return "_" + name;
		return name;
	}

	public function new(?tabString = "\t") {
		tabs = "\t";
		this.tabString = tabString;
	}

	public function printUnop(op:Unop, val:String = null, inFront:Bool = false)
	if(val == null)
	return switch(op) {
		case OpIncrement: "++";
		case OpDecrement: "--";
		case OpNot: "!";
		case OpNeg: "-";
		case OpNegBits: "~";
	}else
	return switch(op) {
		case OpIncrement: inFront? 
		'(function () local _r = $val or 0; $val = _r + 1; return _r end)()'
		: '(function () $val = ($val or 0) + 1; return $val; end)()';
		case OpDecrement: inFront? 
		'(function () local _r = $val or 0; $val = _r - 1; return _r end)()'
		: '(function () $val = ($val or 0) - 1; return $val; end)()';
		case OpNot:       inFront? '$val!' : 'not $val';
		case OpNeg:       inFront? '$val-' : '-$val';
		case OpNegBits:   inFront? '$val~' : '~$val';
	}

	public function printBinop(op:Binop)
	return switch(op) {
		case OpAdd: "+";
		case OpMult: "*";
		case OpDiv: "/";
		case OpSub: "-";
		case OpAssign: "=";
		case OpEq: "==";
		case OpNotEq: "~=";// "!="
		case OpGt: ">";
		case OpGte: ">=";
		case OpLt: "<";
		case OpLte: "<=";
		case OpAnd: "&";
		case OpOr: "or";//TODO "|";
		case OpXor: "^";
		case OpBoolAnd: " and ";// "&&"
		case OpBoolOr: " or ";// "||"
		case OpShl: "<<";
		case OpShr: ">>";
		case OpUShr: ">>>";
		case OpMod: "%";
		case OpInterval: "...";
		case OpArrow: "=>";
		case OpAssignOp(op):
			printBinop(op)
			+ "=";
	}

	public static function printString(s:String) {
		if(strings.indexOf(s) == -1) strings.push(s);
		lastConstIsString = true;
		var n = '@global_str_${strings.length-1}';
			stringslen[n] = s.length + 1;
		return n;
		return '"' + s.split("\n").join("\\n").split("\t").join("\\t").split("'").join("\\'").split('"').join("\\\"") #if sys .split("\x00").join("\\x00") #end + '"';
	}

	public static function printConstant(c){
		lastConstIsString = false;
		return switch(c) {
			case TString(s): printString(s);
			case TThis: "self";
			case TNull: "nil";
			case TBool(true): "true";
			case TBool(false): "false";
			case TInt(s): ""+s;
			case TFloat(s): s;
			case TSuper: "super";
		}
	}

	public static function printStaticConstant(c){
		lastConstIsString = false;
		return switch(c) {
			case TString(s): printString(s);
			case TThis: "self";
			case TNull: "nil";
			case TBool(true): "true";
			case TBool(false): "false";
			case TInt(s): "global %Int "+s;
			case TFloat(s): s;
			case TSuper: "super";
		}
	}

	public function printMetadata(meta) return "";

	public function printAccess(access:Access) return switch(access) {
		case AStatic: "static";
		case APublic: "public";
		case APrivate: "private";
		case AOverride: "override";
		case AInline: "inline";
		case ADynamic: "dynamic";
		case AMacro: "macro";
	}

	function getArgTypeDef(e:haxe.macro.Type):{t:String,i:String}
    {
        var inited = "";
        var typed =
        switch (e) {
            case TAbstract(t,[]): 
                switch (t.toString()) {
                    case "Int": inited = " 0"; "%Int";
                    case "Float": inited = " 0.0"; "%Float";
                    case "Bool": inited = " 255"; "%Bool";
                    default: "TAbstract(t,[])>>" + t.toString();
                }
            case TInst(t,[]):
            switch (t.toString()) {
                    case "String": inited = " null"; "%PString";
                    default: "TInst(t,[])>>" + t.toString();
                }
            case TInst(t,a) if(a.length == 1): // TODO: multiple params case
            switch (t.toString()) {
                    case "Array":
                    var type = getArgTypeDef(a[0]);
                    // { [0 x type]*, i32 Len, i32 ARC }
                    inited = " null";
                    //'{ [0 x ${type.t}]* null, i32 0, i32 1 }';
                    '{ [0 x ${type.t}]*, i32, i32 }*';
                    default: "TInst(t,a)>>" + t.toString();
                }

            case _: "Type>" + e;
        }
        return { t: typed, i: inited };
    }

	public function printArgs(args:Array<{value:Null<TConstant>, v:TVar}>)
	{
		var argString = null;

		for(i in 0 ... args.length)
		{
			var arg = args[i];
			argString = (argString == null?"":argString+", ") + getArgTypeDef(arg.v.t).t + " %" + arg.v.name;
		}

		return (argString == null?"":argString);
	}

	public static var printFunctionHead = true;
	public function printFunction(func:TFunc)
	{
		var head = printFunctionHead;
		printFunctionHead = true;

		var body:String = (head?"function ":"") + "( " + printArgs(func.args) + " ) {";

		if(insideConstructor != null)
		{
			body +=
			'\n\t\tlocal self = {}' +
			'\n\t\tsetmetatable(self, $insideConstructor)';
		}

		var defret = "ret void";
		
		switch (func.expr.expr) {
			case TBlock(el) if (el.length == 0):    body += '\n\t$defret\n}';
			case _: body += opt(func.expr, printExpr, '\n${tabs}') + '\n\t$defret\n}';
		}

		return body;
	}

	public function printVar(v:TVar, expr:Null<TypedExpr>)
	{
		return v.name + opt(expr, printExpr, " = ");
	}

	function printField(e1:TypedExpr, fa:FieldAccess, isAssign:Bool = false)
	{
		var obj = switch (e1.expr) {
			case TConst(TSuper): "super()";
			case _: '${printExpr(e1)}';
		}

		var name = switch (fa) {
			case FInstance(_, cf): "." + cf.get().name;
			case FStatic(_,cf): "." + cf.get().name;
			case FAnon(cf): "." + cf.get().name;
			case FDynamic(s): "." + s;
			case FClosure(_,cf): "." + cf.get().name;
			case FEnum(_,ef): "." + ef.name;
			case _: "/printField/" + e1 + " " + fa;
		}

		return obj + name;
	}

	function printCall(e1:TypedExpr, el:Array<TypedExpr>, _static = false)
	{
		var id = printExpr(e1);

		if(id.indexOf(currentPath) == 0)
			id = id.substr(currentPath.length);

		switch(id)
		{
			case "trace" :
				return formatPrintCall(el);
			/*case "__llvm__":
				extractString(el[0]);
			case "__call__":
				'${printExpr(el.shift())}(${printExprs(el,", ")})';
			case "__assert__":
				'assert(${printExprs(el,", ")})';
			case "__new_named__":
				'new ${extractString(el.shift())}(${printExprs(el,", ")})';
			case "__call_named__":
				'${extractString(el.shift())}(${printExprs(el,", ")})';
			case "__is__":
				'(${printExpr(el[0])} is ${printExpr(el[1])})';
			case "__as__":
				'(${printExpr(el[0])} as ${printExpr(el[1])})';
			case "__call_after__":
				var methodName = extractString(el.shift());
				'(${printExpr(el[0])}).$methodName()';
			case "__cascade__":
				 '${printExpr(el.shift())}..${printExprs(el, ",")}';*/
			default:

			return (function(){

				switch (e1.expr) {
					case TField(e, field):
						switch (e.expr) {
							case TField(e, field):
							{
								return '$id(${printExprs(el,", ")})';
							};
							default:{};
						}
					default:{};
				}
				return '${_static?id : id.replace(".",":")}(${printExprs(el,", ")})';
			})();
		}

		/*if(result == "super()")
			result = '\t\t__inherit(self, $superClass.new())';*/

		return "$$$";
	}

	function extractString(e:haxe.macro.TypedExpr)
	{
		return switch(e.expr)
		{
			case TConst(TString(s)):s;
			default:"####";
		}
	}

	function formatPrintCall(el:Array<TypedExpr>)
	{
		var expr = el[0];
		var posInfo = Std.string(expr.pos);
		posInfo = posInfo.substring(5, posInfo.indexOf(" "));

		var traceString = printExpr(expr);

		var toStringCall = switch(expr.expr)
		{
			case TConst(TString(_)):"";
			default:".toString()";
		}

		var traceStringParts = traceString.split(" + ");
		var toString = ".toString()";

		for(i in 0 ... traceStringParts.length)
		{
			var part = traceStringParts[i];

			if(part.lastIndexOf('"') != part.length - 1 && part.lastIndexOf(toString) != part.length-toString.length)
			{
				traceStringParts[i] += "";
			}
		}

		traceString = traceStringParts.join(" .. ");

		return
			'%temp = getelementptr [${stringslen[traceString]} x i8]*  $traceString, i$bit 0, i$bit 0' +
			'\n\tcall i32 @puts(i8* %temp)';

		return 'print($traceString)';
	}

	function print_field(e1, name)
	{
		var expr = '${printExpr(e1)}.$name';

		if(pathHack.exists(expr))
			expr = pathHack.get(expr);

		if(expr.indexOf(currentPath) == 0)
			expr = expr.substr(currentPath.length);

		if(expr.startsWith("this."))
			expr = expr.replace("this.", "self.");

		return expr;
	}

	function printBaseType(tp:BaseType):String
	{
		return tp.module + "_" + tp.name;
	}

	public function printModuleType (t:ModuleType) 
	{
		return switch (t) 
		{
			case TClassDecl(ct): printBaseType(ct.get());
			case TEnumDecl(ct): printBaseType(ct.get());
			case TTypeDecl(ct): printBaseType(ct.get());
			case TAbstract(ct): printBaseType(ct.get());
		}
	}

	function printIfElse(econd, eif, eelse)
	{
		var ifExpr = printExpr(eif);
		var lastChar = ifExpr.charAt(ifExpr.length - 1);
		if(lastChar != ";" && lastChar != "}")
		{
			ifExpr += ";";
		}
	   return 'if(${printExpr(econd)})then $ifExpr  ${opt(eelse,printExpr,"else ")}';
	}

	public function printExpr(e:TypedExpr){
		return e == null ? "#NULL" : switch(e.expr) {
		
		case TConst(c): printConstant(c); // ok

		case TLocal(t): (""+handleKeywords(t.name)).replace("`trace", "trace"); // ok

		case TArray(e1, e2): '${printExpr(e1)}[${printExpr(e2)}]'; // ok

		case TField(e1, fa): printField(e1, fa);

		case TParenthesis(e1): '(${printExpr(e1)})';

		case TObjectDecl(fl):
			"setmetatable({ "
			 + fl.map(
				function(fld) {
					//insideEObjectDecl = true;
					//$type(fld);
					//trace(fld.expr.expr);
					var add = "+";
					var add = switch (fld.expr.expr) {
						case TFunction(//no,
						 func): add = "function ";
						default: "";   
					}
					return //'{fld.field}'
					fld.name +
					' = $add${printExpr(fld.expr)}'; // TODO
				}
			 ).join(", ")
			 + " },Object)";/**/

		case TArrayDecl(el): {
			var temp = printExprs(el, ", ");
			'setmetatable({' + (temp.length>0? '[0]=${temp}}, HaxeArrayMeta)' : '}, HaxeArrayMeta)');
		};

		case TTypeExpr(t): printModuleType(t);

		case TCall(e1 = { expr : TField(_,FStatic (_))}, el):
		 printCall(e1, el, true);
		
		case TCall(e1, el): printCall(e1, el);
		
		case TNew(tp, _, el): 
			var id:String = printBaseType(tp.get());
			'${id}.new(${printExprs(el,", ")})';

		case TBinop(OpAdd, e1, e2): // TODO extend not only for constants
		{
			var toStringCall = '${printBinop(OpAdd)}';

			toStringCall = switch(e1.expr)
			{
				case TConst(TString(_)):toStringCall == "+" ? '..': toStringCall;
				default:toStringCall;
			}

			toStringCall = switch(e2.expr)
			{
				case TConst(TString(_)):toStringCall == "+" ? '..': toStringCall;
				default:toStringCall;
			}

			'${printExpr(e1)} $toStringCall ${printExpr(e2)}';
		};

		case TBinop(op, e1, e2): 
			'${printExpr(e1)} ${printBinop(op)} ${printExpr(e2)}';
		
		case TUnop(op, true, e1): printUnop(op,printExpr(e1),true);
		case TUnop(op, false, e1): printUnop(op,printExpr(e1),false);
		
		case TFunction(func): printFunction(func);

		case TVar(v,e): "local " + printVar(v, e);
		
		case TBlock([]): '\n$tabs end';//'B{\n$tabs}B';
		case TBlock(el) if (el.length == 1): printShortFunction(printExprs(el, ';\n$tabs'));
		case TBlock(el):
			var old = tabs;
			tabs += tabString;
			var s = /*'{'*/ '\n$tabs' + printExprs(el, ';\n$tabs');//';\n$tabs');
			tabs = old;
			s + '\n${tabs}${insideConstructor!=null?"\treturn self\n\t":""}'/*'}'*/;

		case TIf(econd, eif, eelse): printIfElse(econd, eif, eelse); 
		
		case TWhile(econd, e1, true): 'while(${printExpr(econd)})do ${printExpr(e1)}end';
		case TWhile(econd, e1, false): 'do ${printExpr(e1)} while(${printExpr(econd)})';
		
		case TReturn(eo): "ret" + opt(eo, printExpr, " ");

		case TBreak: "break";
		case TContinue: "continue";
		
		case TThrow(e1): "throw " +printExpr(e1);
		
		case TCast(e1, _): printExpr(e1); // ok
		
		case TMeta(meta, e1): printMetadata(meta) + " " +printExpr(e1);

		case _: "\n\t-------"+e;
	};
	}

	function printShortFunction(value:String)
	{
		var hasReturn = value.indexOf("return ") == 0;
		return value + (hasReturn ? ";" : "");
	}

	function printSwitch(e1, cl, edef)
	{
		var old = tabs;
		tabs += tabString;
		var s = 'switch ${printExpr(e1)} {\n$tabs' +
					cl.map(printSwitchCase).join('\n$tabs');
		if (edef != null)
			s += '\n${tabs}default: ' + (edef.expr == null ? "" : printExpr(edef) + ";");

		tabs = old;
		s += '\n$tabs}';

		return s;
	}

	function printSwitchCase(c)
	{
		return 'case ${printExprs(c.values, ", ")}'
			   + (c.guard != null ? ' if(${printExpr(c.guard)}): ' : ":")
			   + (c.expr != null ? (opt(c.expr, printExpr)) + "; break;" : "");
	}

	public function printExprs(el:Array<TypedExpr>, sep:String) {
		return el.map(printExpr).join(sep);
	}

	function opt<T>(v:T, f:T->String, prefix = "") return v == null ? "" : (prefix + f(v));
}