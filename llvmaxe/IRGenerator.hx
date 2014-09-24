/*
 * Copyright (C)2005-2012 Haxe Foundation
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
 *
 *
 */
package llvmaxe;

import haxe.macro.Type;
import haxe.macro.JSGenApi;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.TypedExprTools;

using Lambda;
using StringTools;

typedef FieldInitialiser = {
    expr : haxe.macro.TypedExpr,
    id : String
}

class IRGenerator
{
    static var imports = [];

    var api : JSGenApi;
    var buf : StringBuf;
    var topLevelBuf : StringBuf;
    var storeBuf : StringBuf;
    var packages : haxe.ds.StringMap<Bool>;
    var forbidden : haxe.ds.StringMap<Bool>;

    static var staticFieldInitialisers:Array<FieldInitialiser> = []; 

    public function new(api)
    {
        this.api = api;
        buf = new StringBuf();
        topLevelBuf = new StringBuf();
        packages = new haxe.ds.StringMap();
        forbidden = new haxe.ds.StringMap();
        api.setTypeAccessor(getType);
    }

    function getType(t : Type)
    {
        return switch(t) {
            case TInst(c, _): getPath(c.get());
            case TEnum(e, _): getPath(e.get());
            default: throw "assert";
        };
    }

    inline function print(str)
    {
        buf.add(str);
    }

    inline function newline()
    {
        print("\n");
        var x = indentCount;
        while(x-- > 0)	print("\t");
    }

    inline function genExpr(e:haxe.macro.TypedExpr)
    {
        var expr:haxe.macro.TypedExpr = e;
        var exprString = new IRPrinter().printExpr(expr);

        print(exprString.replace("super(", "super.init("));
    }

    function field(p : String)
    {
    	return IRPrinter.handleKeywords(p);
    }

    static var classCount = 0;

    function genPathHacks(t:Type)
    {
        switch( t ) {
            case TInst(c, _):
                var c = c.get();
                if(!c.isExtern)classCount++;
                getPath(c);
            case TEnum(r, _):
                var e = r.get();
                getPath(e);
            default:
        }
    }

    function getPath(t : BaseType)
    {
		var fullPath = t.name;

		if(t.pack.length > 0)
		{
		    var dotPath = t.pack.join(".") + "." + t.name;
		    fullPath =  t.pack.join("_") + "_" + t.name;

		    if(!IRPrinter.pathHack.exists(dotPath))
		        IRPrinter.pathHack.set(dotPath, fullPath);
		}

	//	if(t.module != t.name)   //TODO(av) see what this does with sub classes in packages
		{
		    var modulePath = t.module + "." + t.name;
//           trace(fullPath + " " + t);
//           trace(LuaPrinter.pathHack.exists(modulePath));
		    if(!IRPrinter.pathHack.exists(modulePath))
		        IRPrinter.pathHack.set(modulePath, t.name);
		}
        return t.module + "_" + t.name;
        return fullPath;
    }

    function checkFieldName(c : ClassType, f : ClassField)
    {
        if(forbidden.exists(f.name))
            Context.error("The field " + f.name + " is not allowed in LLVM", c.pos);
    }

    function genClassField(c : ClassType, p : String, f : ClassField)
    {
        checkFieldName(c, f);
        var field = field(f.name);
        var e = f.expr();
        if(e == null)
        {
            print('--var $field;');
        }
        else switch( f.kind )
        {
            case FMethod(_):
                print('function $p:$field');
                IRPrinter.printFunctionHead = false;
                genExpr(e);
                newline();
            default:
                print('var $field = ');
                genExpr(e);
                print(";");
                newline();
        }
        newline();
    }

    function getStaticTypeDef(e:haxe.macro.Type):{t:String,i:String}
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
                    var type = getStaticTypeDef(a[0]);
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

    function genStaticField(c : ClassType, p : String, f : ClassField)
    {
        var classes = classCount > 1;

        checkFieldName(c, f);

//        var topLevel = false;
//
//        for(meta in f.meta.get())
//        {
//            if(meta.name == ":top_level")
//            {
//                topLevel = true;
//                storeBuf = buf;
//                buf = topLevelBuf;
//                break;
//            }
//        }

        var stat = classCount > 1 ? 'static' : "";

        var field = field(f.name);
        var e = f.expr();
        if(e == null)
        {
            print('@${p}.$field = global '); //TODO(av) initialisation of static vars if needed
            var t = getStaticTypeDef(f.type);
            print(t.t+t.i);
            print(";");
            newline();
        }
        else switch( f.kind ) {
            case FMethod(_):
//                if(topLevel)
//                    print('$field ');
//                else
                    //print('$stat $field ');
                print('define void @${p}.$field');
                IRPrinter.printFunctionHead = false;
                genExpr(e);
                newline();
            default:
                print('@${p}.$field = ');

                switch (e.expr) {
                    case TConst(c): print(IRPrinter.printStaticConstant(c));
                    case _: 
                    staticFieldInitialisers.push({
                        id : '@${p}.$field',
                        expr : e
                    });
                    print("global ");
                    var t = getStaticTypeDef(f.type);
                    print(t.t+t.i);
                    print("; initialised with ");
                    genExpr(e);
                }

                
                print(";");
                newline();
//                statics.add( { c : c, f : f } );
        }

//        if(topLevel)
//            buf = storeBuf;
    }

    function genClass(c : ClassType)
    {
        for(meta in c.meta.get())
        {
            if(meta.name == ":library" || meta.name == ":feature")
            {
                for(param in meta.params)
                {
                    switch(param.expr){
                        case EConst(CString(s)):
                            if(Lambda.indexOf(imports, s) == - 1)
                                imports.push(s);
                        default:
                    }
                }
            }

            if(meta.name == ":remove")
            {
                return;
            }
        }

        api.setCurrentClass(c);
        var p = getPath(c);

        IRPrinter.currentPath = p + ".";

        if(classCount > 1)
        {
            var psup:String = null;
            IRPrinter.superClass = null;
            if(c.superClass != null)
            {
                psup = getPath(c.superClass.t.get());
                print('; class $p extends $psup');
                IRPrinter.superClass = psup;
            } else print('; class $p');

            var ignorance = [
            "haxe_ds_IntMap", 
            "IMap", 
            "Std", "Std_Std", 
            "Array",
            "HxOverrides",
            "js_Boot",
            "haxe_Log"];

            if(ignorance.has(p))
            {
                print('\n-- ignored --\n\n');
                return ;
            }

            if(c.isInterface)
                print(' abstract class $p');
            else
                {
                 /*   print('\n$p = {};');
                    if(psup != null)
                    print('\n__inherit($p, ${psup});');
                    else
                    print('\n__inherit($p, Object);');

                    print('\n$p.__index = $p;');
                    //print('\n$p.__index = ${psup != null?psup : p};');*/
                }

            if(c.interfaces.length > 0)
            {
                var me = this;
                var inter = c.interfaces.map(function(i) return me.getPath(i.t.get())).join(",");
                print(' -- implements $inter');
            }

            openBlock();
        }

        if(c.constructor != null)
        {
            newline();
            print('function $p.new');
            IRPrinter.insideConstructor = p;
            IRPrinter.printFunctionHead = false;
            genExpr(c.constructor.get().expr());
            IRPrinter.insideConstructor = null;
            newline();
        }

        for(f in c.statics.get())
            genStaticField(c, p, f);

        for(f in c.fields.get())
        {
            switch( f.kind ) {
                case FVar(r, _):
                    if(r == AccResolve) continue;
                default:
            }
            genClassField(c, p, f);
        }

        if(classCount > 1)
        {
            closeBlock();
        }
    }

    static var firstEnum = true;

    function genEnum(e : EnumType)
    {
        if(firstEnum)
        {
            generateBaseEnum();
            firstEnum = false;
        }

        var p = getPath(e);

        print('class $p extends Enum {');
        newline();
        print('$p(t, i, [p]):super(t, i, p);');
        newline();
        for(c in e.constructs.keys())
        {
            var c = e.constructs.get(c);
            var f = field(c.name);
            print('static final $f = ');
            switch( c.type ) {
                case TFun(args, _):
                    var sargs = args.map(function(a) return a.name).join(",");
                    print('($sargs) => new $p("${c.name}", ${c.index}, [$sargs]);');
                default:
                    print('new $p(${api.quoteString(c.name)}, ${c.index});');
            }
            newline();
        }
        print("} --<-- huh?");
        newline();
    }


    function genStaticValue(c : ClassType, cf : ClassField)
    {
        var p = getPath(c);
        var f = field(cf.name);
        print('$p$f = ');
        genExpr(cf.expr());
        newline();
    }

    function genType(t : Type)
    {
        switch( t ) {
            case TInst(c, _):
                var c = c.get();
                if(! c.isExtern) genClass(c);
            case TEnum(r, _):
                var e = r.get();
                if(! e.isExtern) genEnum(e);
            default:
        }
    }

    function generateBaseEnum()
    {
        print("abstract class Enum {
        	String tag;
        	int index;
        	List params;
        	Enum(this.tag, this.index, [this.params]);
        	toString()=>params == null ? tag : tag + '(' + params.join(',') + ')';
        	}");	// String toString() { return haxe.Boot.enum_to_string(this); }
        newline();
    }

    public function generate()
    {
        for(t in api.types)
            genPathHacks(t);

        var starter = "";

        if(api.main != null && classCount > 1)
        {
            print("");

            genExpr(api.main);
            print(";");
            newline();

            starter = buf.toString();
            buf = new StringBuf();
        }

        for(t in api.types)
            genType(t);

        var importsBuf = new StringBuf();//currently only works within a single output file. Needs to be handled module by module

        for(mpt in imports)
            importsBuf.add("import '" + mpt + "';\n");

        var boot = "";
        var path = ".";
        boot = "" + sys.io.File.getContent('$path/llvmaxe/boot/boot.ll');

        var combined = importsBuf.toString() + topLevelBuf.toString() +  buf.toString();

        // strings
        // TODO utf8/16
        var strs = "; master strings";
        var strid = -1;
        for(s in llvmaxe.IRPrinter.strings)
        {   
            strid++;
            strs += '\n@global_str_$strid = constant [${s.length+1} x i8] c"$s\\00"';
        }

        // type declarations
        // TODO

        // static functions
        // TODO

        // Quest: 
        //call i32 @puts(i8* getelementptr([13 x i8]* @global_str, i32 0, i32 0))
        //%temp = getelementptr [13 x i8]*  @global_str, i64 0, i64 0
  		//call i32 @puts(i8* %temp)

        // main
        var smain = 
			"\ndefine i32 @main(...) {"	+
			"\n	call void @Main_Main.main()" +
			"\n	ret i32 0"	+
			"\n}";

        sys.io.File.saveContent(api.outputFile, 
        	boot + strs + "\n\n" +
        	combined +
        	smain
        	);
    }

    static var indentCount : Int = 0;

    function openBlock()
    {
        newline();
        print(";do");
        indentCount ++;
        newline();
    }

    function closeBlock()
    {
        indentCount --;
        newline();
        print(";end");
        newline();
        newline();
    }

    #if macro
	public static function use() {
		Compiler.setCustomJSGenerator(function(api) new IRGenerator(api).generate());
	}
	#end
}