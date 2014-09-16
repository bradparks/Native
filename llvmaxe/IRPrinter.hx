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
        case OpNotEq: "~=";// "!=" in Lua
        case OpGt: ">";
        case OpGte: ">=";
        case OpLt: "<";
        case OpLte: "<=";
        case OpAnd: "&";
        case OpOr: "or";//TODO "|";
        case OpXor: "^";
        case OpBoolAnd: " and ";// "&&" in Lua
        case OpBoolOr: " or ";// "||" in Lua
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

    public function printString(s:String) {
        if(strings.indexOf(s) == -1) strings.push(s);
        lastConstIsString = true;
        var n = '@global_str_${strings.length-1}';
            stringslen[n] = s.length + 1;
        return n;
        return '"' + s.split("\n").join("\\n").split("\t").join("\\t").split("'").join("\\'").split('"').join("\\\"") #if sys .split("\x00").join("\\x00") #end + '"';
    }

    public function printConstant(c){
        lastConstIsString = false;
        return switch(c) {
            case TString(s): printString(s);
            //case CIdent(s),CInt(s), CFloat(s): s;
            //case CRegexp(s,opt): '~/$s/$opt'; TODO
            case TThis: "self";
            case TNull: "nil";
            case TBool(true): "true";
            case TBool(false): "false";
            case TInt(s): ""+s;
            case TFloat(s): s;
            case TSuper: "super";
        }
    }

    /*public function printTypeParam(param:TypeParam) return switch(param) {
        case TPType(ct): printComplexType(ct);
        case TPExpr(e): printExpr(e);
    }/**/

/*  public function printTypePath(tp:TypePath){
        if(tp.sub != null) return tp.sub ;
        return
        (tp.pack.length > 0 ? tp.pack.join("_") + "_" : "")
        + tp.name
        + (tp.sub != null ? '.${tp.sub}' : "")
        + (tp.params.length > 0 ? "<" + tp.params.map(printTypeParam).join(", ") + ">" : "");
    }/**/

/*  // TODO: check if this can cause loops
    public function printComplexType(ct:ComplexType) return switch(ct) {
        case TPath(tp): printTypePath(tp);
        case TFunction(args, ret): (args.length>0 ? args.map(printComplexType).join(" -> ") : "Void") + " -> " + printComplexType(ret);
        case TAnonymous(fields): "{ " + [for (f in fields) printField(f) + "; "].join("") + "}";
        case TParent(ct): "(" + printComplexType(ct) + ")";
        case TOptional(ct): "?" + printComplexType(ct);
        case TExtend(tp, fields): "";
        // '{' +
        // printTypePath(tp) + ' >,' + 
        // ' ${fields.map(printField).join(", ")} }';
    }/**/

    public function printMetadata(meta) return "";
    /*  '@${meta.name}'
        + (meta.params.length > 0 ? '(${printExprs(meta.params,", ")})' : "");/**/

    public function printAccess(access:Access) return switch(access) {
        case AStatic: "static";
        case APublic: "public";
        case APrivate: "private";
        case AOverride: "override";
        case AInline: "inline";
        case ADynamic: "dynamic";
        case AMacro: "macro";
    }

//  public function printField(field:Field) return
//      (field.doc != null && field.doc != "" ? "/**\n" + tabs + tabString + StringTools.replace(field.doc, "\n", "\n" + tabs + tabString) + "\n" + tabs + "**/\n" + tabs : "")
//      + (field.meta != null && field.meta.length > 0 ? field.meta.map(printMetadata).join(" ") + " " : "")
//      + (field.access != null && field.access.length > 0 ? field.access.map(printAccess).join(" ") + " " : "")
//      + switch(field.kind) {
//        case FVar(t, eo): 'var ${field.name}' + opt(t, printComplexType, " : ") + opt(eo, printExpr, " = ");
//        case FProp(get, set, t, eo): 'var ${field.name}($get, $set)' + opt(t, printComplexType, " : ") + opt(eo, printExpr, " = ");
//        case FFun(func): 'function ${field.name}' + printFunction(func);
//      }

//  public function printTypeParamDecl(tpd:TypeParamDecl) return
//      tpd.name
//      + (tpd.params != null && tpd.params.length > 0 ? "<" + tpd.params.map(printTypeParamDecl).join(", ") + ">" : "")
//      + (tpd.constraints != null && tpd.constraints.length > 0 ? ":(" + tpd.constraints.map(printComplexType).join(", ") + ")" : "");

    public function printArgs(args:Array<{value:Null<TConstant>, v:TVar}>)
    {
        var argString = null;
        //var optional = false;

        for(i in 0 ... args.length)
        {
            var arg = args[i];
            //var argValue = printExpr(arg.value);
//
            //if((arg.opt || argValue != "#NULL") && !optional)
            //{
            //    optional = true;
            //    argString += "[";
            //}
            //argString += arg.name;
//
            //if(argValue != null && argValue != "#NULL")
            //    argString += '= $argValue';
//
            //if(i < args.length - 1)
            //    argString += ",";
            argString = (argString == null?"":argString+", ") + arg.v.name;
        }

        //if(optional) argString += "]";

        return (argString == null?"":argString);
    }/**/

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

        //var t = tabs;
        //tabs += "\t";
        var defret = "ret void";
        
        switch (func.expr.expr) {
            case TBlock(el) if (el.length == 0):    body += "\n\t$defret\n}";
            case _: body += opt(func.expr, printExpr, '\n${tabs}') + '\n\t$defret\n}';
        }

        //tabs = t;

        return body;
    }

//        return
////  UNUSED  (func.params.length > 0 ? "<" + func.params.map(printTypeParamDecl).join(", ") + ">" : "") 
//        (head?"function ":"") + "( " + printArgs(func.args) + " )"
//////    DONE    + "( " + func.args.map(printFunctionArg).join(", ") + " )"
//////    UNUSED  + opt(func.ret, printComplexType, " : ")
//        + (insideConstructor != null ?
//            '\n\t\tlocal self = {}' +
//            '\n\t\tsetmetatable(self, $insideConstructor)'
//            //'\n\t\tinherit(self, $insideConstructor.new())'
//        : '') + '\n\t\t'
//        + opt(func.expr, printExpr, " ") + '\n${tabs}end';
//    }
////    public function printVar(v:Var)
////    {
////        return
////        v.name
////        //        + opt(v.type, printComplexType, " : ")
////        + opt(v.expr, printExpr, " = ");
////    }
//
    public function printVar(v:TVar, expr:Null<TypedExpr>)
    {
        return v.name + opt(expr, printExpr, " = ");
    }
//    public function printVar(v:TVar, expr:Null<TypedExpr>,context = "null")
//    {
//        function def () {
//            return
//            handleKeywords(v.name)
//            //      + opt(v.type, printComplexType, " : ")
//            + if (expr != null) opt(expr, printOpAssignRight.bind(_,context), " = ") else " = nil";
//        }
//
//        return if (expr != null) {
//            if (expr.expr != null)
//            {
//                switch (expr.expr) {
//                    case TFunction(f):
//                        printFunction(f /*,context,v.name*/);
//                    case _ : def();
//                }
//            } else {
//                def();
//            }
//        } else {
//
//            def();
//        }
//    }

//    function justPath(expr)
//    {
//        return switch(expr.expr)
//        {
//            case EConst(CIdent(s)):s;
//            case EField(e, field): justPath(e) + "_" + field;
//            default:"";
//        }
//       // return printExpr(expr);
//    }

    function printField(e1:TypedExpr, fa:FieldAccess, /*context:PrintContext,*/ isAssign:Bool = false)
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
/*
        function doDefault() {
            return '$obj.${handleKeywords(name)}';
        }

        return switch (fa) {
            case FInstance(isType("", "list") => true, cf) if (cf.get().name == "length" || cf.get().name == "get_length"):
                "_hx_builtin.len(" + printExpr(e1, context) + ")";
            case FInstance(x = isType("", "String") => true, cf) if (cf.get().name == "toUpperCase"):
                printExpr(e1, context) + ".toupper";
            case FInstance(isType("", "String") => true, cf) if (cf.get().name == "toLowerCase"):
                printExpr(e1, context) + ".tolower";
            

            case FInstance(ct, cf): 
                //var ct = ct.get();
                doDefault();
            case FStatic(x,cf): 
            
                doDefault();
            case FAnon(cf) if (name == "iterator" && !isAssign):
                switch (cf.get().type) {
                    case TFun(args,_) if (args.length == 0): 
                        '_hx_functools.partial(HxOverrides_iterator, $obj)';        
                    case _ : doDefault();
                }
            case FAnon(cf) if (name == "shift" && !isAssign):
                switch (cf.get().type) {
                    case TFun(args,_) if (args.length == 0): 
                        '_hx_functools.partial(HxOverrides_shift, $obj)';        
                    case _ : doDefault();
                }
            case FAnon(_):
                doDefault();
            case FDynamic("iterator"):
                '_hx_functools.partial(HxOverrides_iterator, $obj)';
            case FDynamic("length") if (!isAssign):
                'HxOverrides_length($obj)';
            case FDynamic("filter") if (!isAssign):
                '_hx_functools.partial(HxOverrides_filter, $obj)';
            case FDynamic("map") if (!isAssign):
                '_hx_functools.partial(HxOverrides_map, $obj)';
            case FDynamic(_):
                doDefault();
            case FClosure(ct,cf): 
                doDefault();
            case FEnum(_,ef): 
                doDefault();
        }
        /**/
    }

    function printCall(e1:TypedExpr, el:Array<TypedExpr>, _static = false)
    {
        var id = printExpr(e1);

        if(id.indexOf(currentPath) == 0)
            id = id.substr(currentPath.length);

        var result =  switch(id)
        {
            case "trace" :
                formatPrintCall(el);
            case "__lua__":
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
                 '${printExpr(el.shift())}..${printExprs(el, ",")}';
            default:
               //'$id(${printExprs(el,", ")})'; // <-- here to . :

            (function(){

                switch (e1.expr) {
                    case TField(e, field):
                        switch (e.expr) {
                            case TField(e, field):
                            {
                                //trace(e1.expr);

                                return '$id(${printExprs(el,", ")})'
                                .replace(".set(", ":set(")
                                .replace(".get(", ":get(")
                                .replace(".iterator(", ":iterator(");
                            };
                            /*case EConst(c):
                            {
                                trace("const!");
                                trace(c);
                                trace(id);
                                trace('$id(${printExprs(el,", ")})');
                            };*/
                            default:{};
                        }
                    default:{};
                }
                //trace(id);
                var r = '${_static?id : id.replace(".",":")}(${printExprs(el,", ")})';
                //return r.indexOf('.new(') == -1? r.replace(".",":") : r;
                //if() r = r.replace(".",":")
                return r
                    .replace(":new(", ".new(")
                    ;
            })();
        }

        if(result == "super()")
            result = '\t\t__inherit(self, $superClass.new())';//"--super()";

        return result;
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
                traceStringParts[i] += "";//".toString()";
            }
        }

        traceString = traceStringParts.join(" .. "); //(" + ");

        return
            '%temp = getelementptr [${stringslen[traceString]} x i8]*  $traceString, i$bit 0, i$bit 0' +
            '\n\tcall i32 @puts(i8* %temp)';

        return 'print($traceString)';
    }

    function print_field(e1, name)
    {
        var expr = '${printExpr(e1)}.$name';

        //var toFunc = false;

        //trace(e1);

        /*switch (e1.expr) {
            case EConst(c):
               trace(c); 
               switch (c) {
                    case CIdent(s)
                    default:{};
               }
            default:{};
        }*/

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
      //  trace(ifExpr);

       return 'if(${printExpr(econd)})then $ifExpr  ${opt(eelse,printExpr,"else ")}';
    }

//    public function enterExpr(e:Expr)
//    {
//
//    }
    //var insideEObjectDecl = false;

    
//
    public function printExpr(e:TypedExpr){
//        trace(e);
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
        // 'statico';
         printCall(e1, el, true);
        
        case TCall(e1, el): printCall(e1, el);
        
        //case TNew(tp, params, el): '${printTypePath(tp)}.new(${printExprs(el,", ")})';
        case TNew(tp, _, el): 
            //'${printTypePath(tp)}.new(${printExprs(el,", ")})';
            var id:String = printBaseType(tp.get());
            //'${id}';
            '${id}.new(${printExprs(el,", ")})';

        //case TBinop(OpAdd, e1, e2) if (e.t.match(TInst("String"))):
        //    '${printExpr(e1)} .. ${printExpr(e2)}';

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

        /*case TBinop(OpOr, e1, e2): 
            'OpOr(${printExpr(e1)}, ${printExpr(e2)})';*/

        case TBinop(op, e1, e2): 
            '${printExpr(e1)} ${printBinop(op)} ${printExpr(e2)}';
        
        case TUnop(op, true, e1): printUnop(op,printExpr(e1),true);//printExpr(e1) + printUnop(op);//, printExpr(e1));
        case TUnop(op, false, e1): printUnop(op,printExpr(e1),false);//printUnop(op) + printExpr(e1);
        
        //case TFunction(no, func) if (no != null): '$no' + printFunction(func);
        //case TFunction(/*_,*/ func): /*"function " +*/ printFunction(func);
        case TFunction(func): printFunction(func);

        //case TVars(vl): "local " +vl.map(printVar).join(", ");

        case TVar(v,e): "local " + printVar(v, e);
        
        case TBlock([]): '\n$tabs end';//'B{\n$tabs}B';
        case TBlock(el) if (el.length == 1): printShortFunction(printExprs(el, ';\n$tabs'));
        case TBlock(el):
            var old = tabs;
            tabs += tabString;
            var s = /*'{'*/ '\n$tabs' + printExprs(el, ';\n$tabs');//';\n$tabs');
            tabs = old;
            s + '\n${tabs}${insideConstructor!=null?"\treturn self\n\t":""}'/*'}'*/;
            //insideConstructor = null;

        //case TFor(e1, e2): 'for ${printExpr(e1)} do\n${tabs} ${printExpr(e2)}\n${tabs}end';//'for(${printExpr(e1)}) ${printExpr(e2)}';
        //case TIn(e1, e2): 'k,${printExpr(e1)} in ${printExpr(e2)}';//'${printExpr(e1)} in ${printExpr(e2)}';
        
        case TIf(econd, eif, eelse): printIfElse(econd, eif, eelse); // 'if(${printExpr(econd)}) ${printExpr(eif)}  ${opt(eelse,printExpr,"else ")}';
        
        case TWhile(econd, e1, true): 'while(${printExpr(econd)})do ${printExpr(e1)}end';
        case TWhile(econd, e1, false): 'do ${printExpr(e1)} while(${printExpr(econd)})';
        
        //case TSwitch(e1, cl, edef):  printSwitch(e1, cl, edef);
        /*case TTry(e1, cl):
            'try ${printExpr(e1)}'
            + cl.map(function(c) return ' catch(${c.name} ) ${printExpr(c.expr)}').join("");   //: ${printComplexType(c.type)}/**/
//      case EReturn(eo): "return " + printExpr(eo);

        case TReturn(eo): "return" + opt(eo, printExpr, " ");

        case TBreak: "break";
        case TContinue: "continue";
        
        case TThrow(e1): "throw " +printExpr(e1);
        //case TCast(e1, cto) if (cto != null): '${printExpr(e1)} as ${printComplexType(cto)}';
        
        case TCast(e1, _): printExpr(e1); // ok
        
        case TMeta(meta, e1): printMetadata(meta) + " " +printExpr(e1);

        case _: "\n\t-------"+e;
    };
    }

    function printShortFunction(value:String)
    {
        var hasReturn = value.indexOf("return ") == 0;
        //if(hasReturn) value = value.substr(7);
        return /*"=> " +*/ value + (hasReturn ? ";" : "");
    }

    function printSwitch(e1, cl, edef)
    {
//        trace(e1);
//        trace(cl);
//        trace(edef);

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

//        var id = null;
//
//        var sameID = [];
//
//        var idGroup = new Map<String, Array<Expr>>();
//
//        for(ex in el)
//        {
//            switch(ex.expr)
//            {
//                case ECall(e1, el):
//                        switch(e1.expr)
//                        {
//                            case EField(e1, n):
//                                switch(e1.expr)
//                                {
//                                    case EConst(CIdent(s)):
//                                        if(id == s){
////                                             trace(ex);
//                                            e1.expr = EConst(CIdent(""));
//                                            sameID.push(ex);
//                                        }
//                                        id = s;
//                                    default:
//                                }
//
//                            default:
//                        }
//                default:
//            }
//        }
//
//        if(id != null)
//            trace(sameID.map(printExpr).join("."));

        return el.map(printExpr).join(sep);
    }

//  public function printTypeDefinition(t:TypeDefinition, printPackage = true):String {
//      var old = tabs;
//      tabs = tabString;
//
//      var str = t == null ? "#NULL" :
//          (printPackage && t.pack.length > 0 && t.pack[0] != "" ? "package " + t.pack.join("_") + ";\n" : "") +
//          (t.meta != null && t.meta.length > 0 ? t.meta.map(printMetadata).join(" ") + " " : "") + (t.isExtern ? "extern " : "") + switch (t.kind) {
//              case TDEnum:
//                  "enum " + t.name + (t.params.length > 0 ? "<" + t.params.map(printTypeParamDecl).join(", ") + ">" : "") + " {\n"
//                  + [for (field in t.fields)
//                      tabs + (field.doc != null && field.doc != "" ? "/**\n" + tabs + tabString + StringTools.replace(field.doc, "\n", "\n" + tabs + tabString) + "\n" + tabs + "**/\n" + tabs : "")
//                      + (field.meta != null && field.meta.length > 0 ? field.meta.map(printMetadata).join(" ") + " " : "")
//                      + (switch(field.kind) {
//                          case FVar(_, _): field.name;
//                          case FProp(_, _, _, _): throw "FProp is invalid for TDEnum.";
//                          case FFun(func): field.name + printFunction(func);
//                      }) + ";"
//                  ].join("\n")
//                  + "\n}";
//              case TDStructure:
//                  "typedef " + t.name + (t.params.length > 0 ? "<" + t.params.map(printTypeParamDecl).join(", ") + ">" : "") + " = {\n"
//                  + [for (f in t.fields) {
//                      tabs + printField(f) + ";";
//                  }].join("\n")
//                  + "\n}";
//              case TDClass(superClass, interfaces, isInterface):
//                  (isInterface ? "interface " : "class ") + t.name + (t.params.length > 0 ? "<" + t.params.map(printTypeParamDecl).join(", ") + ">" : "")
//                  + (superClass != null ? " extends " + printTypePath(superClass) : "")
//                  + (interfaces != null ? (isInterface ? [for (tp in interfaces) " extends " + printTypePath(tp)] : [for (tp in interfaces) " implements " + printTypePath(tp)]).join("") : "")
//                  + " {\n"
//                  + [for (f in t.fields) {
//                      var fstr = printField(f);
//                      tabs + fstr + switch(f.kind) {
//                          case FVar(_, _), FProp(_, _, _, _): ";";
//                          case FFun(func) if (func.expr == null): ";";
//                          case _: "";
//                      };
//                  }].join("\n")
//                  + "\n}";
//              case TDAlias(ct):
//                  "typedef " + t.name + (t.params.length > 0 ? "<" + t.params.map(printTypeParamDecl).join(", ") + ">" : "") + " = "
//                  + printComplexType(ct)
//                  + ";";
//              case TDAbstract(tthis, from, to):
//                  "abstract " + t.name
//                  + (tthis == null ? "" : "(" + printComplexType(tthis) + ")")
//                  + (t.params.length > 0 ? "<" + t.params.map(printTypeParamDecl).join(", ") + ">" : "")
//                  + (from == null ? "" : [for (f in from) " from " + printComplexType(f)].join(""))
//                  + (to == null ? "" : [for (t in to) " to " + printComplexType(t)].join(""))
//                  + " {\n"
//                  + [for (f in t.fields) {
//                      var fstr = printField(f);
//                      tabs + fstr + switch(f.kind) {
//                          case FVar(_, _), FProp(_, _, _, _): ";";
//                          case FFun(func) if (func.expr == null): ";";
//                          case _: "";
//                      };
//                  }].join("\n")
//                  + "\n}";
//          }
//
//      tabs = old;
//      return str;
//  }

    function opt<T>(v:T, f:T->String, prefix = "") return v == null ? "" : (prefix + f(v));
}