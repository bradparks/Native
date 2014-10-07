using Math;

class Main {
	public static var N:Int=8; // TODO: remove :Int to TCast
	public static var M=8;
	public static var BANG=3;
	
	public static var I:Int;
	public static var F:Float;
	public static var S:String;
	public static var B:Bool;

	public static var pole = new Array< Array< Int > >();

	static function swap(x1,y1,x2,y2) {
		/*var k=pole[x1][y1];
		pole[x1][y1]=pole[x2][y2];
		pole[x2][y2]=k;*/
	}

	static function poisk(temp, i, j, x, y) {
		/*if (temp==pole[i][j] && i+x>=0 && i+x<N && j+y>=0 && j+y<M) {
			return 1+poisk(temp,i+x,j+y,x,y);
		}
		if (temp==pole[i][j]) {
			return 1;
		}*/
		return 0;
	}

	static function findLine() {
		/*var flag=false;
		for (i in 0...N) {
			for (j in 0...M) {
				if (poisk(pole[i][j],i,j,0,1)>=BANG || poisk(pole[i][j],i,j,1,0)>=BANG) {
					flag=true;
				}
			}
		}
		return flag;*/
	}


	static function generate() {
		/*for (i in 0...N) {
			for (j in 0...M) {
				do {
					pole[i][j]=Math.ceil(Math.random()*7);
				} while(poisk(pole[i][j],i,j,-1,0)>=BANG || poisk(pole[i][j],i,j,0,-1)>=BANG);
			}
		}
		for (i in 0...N) {
			for (j in 0...M) {
				var fl=0;
				if (i<N-1) {
					swap(i,j,i+1,j);
					if (findLine()==true) fl=1;
					swap(i,j,i+1,j);
				}
				if (i>0) {
					swap(i,j,i-1,j);
					if (findLine()==true) fl=1;
					swap(i,j,i-1,j);
				}
				if (j<M-1) {
					swap(i,j,i,j+1);
					if (findLine()==true) fl=1;
					swap(i,j,i,j+1);
				}
				if (j>0) {
					swap(i,j,i,j-1);
					if (findLine()==true) fl=1;
					swap(i,j,i,j-1);
				}
				if (fl==1) return;
			}
		}
		generate();*/
	}


	public static function main() {
		for (i in 0...N) {
			//if(pole[i] == null) pole[i] = [];
		}
		generate();/*
		for (i in 0...N) {
			var str="";
			for (j in 0...M) {
				str=str+pole[i][j]+' ';
			}
			trace('${str}');
		}*/
		I = 7;
		F = 16.6;
		//S = "S";
		B = true;
	}
}
/*
class Main
{
	static function test(x:Dynamic,v:Dynamic) {
		if(x != v) trace("Fail");
	}	

	public static function main() {
		trace("Hello Haxe World!:)");
		trace("Hello Haxe World!:)");
		trace("Hello 2");

	//	test(0,0);
	//	test(0xFF, 255);

	//	test(0xBFFFFFFF,0xBFFFFFFF);
	//	test(0x7FFFFFFF, 0x7FFFFFFF);

	//	test(-123,-123);
	//	var a = -123;
	//	test(a,-123);
	//	test(1.546,1.546);
	//	test(.545,.545);
	//	test('bla',"bla");
	//	test(null,null);
	//	test(true,true);
	//	test(false,false);
	//	var a = 1;
	//	test(a == 2,false);
	//	var a = 1.3;
	//	test(a == 1.3,true);
	//	var a = 5;
	//	test(a > 3,true);
	//	var a = 0;
	//	test(a < 0,false);
	//	var a = -1;
	//	test(a <= -1,true);
	//	test(1 + 2,3);
	//	test(~545,-546);
	//	test('abc' + 55,"abc55");
	//	test('abc' + 'de',"abcde");
	//	test(-1 + 2,1);
	//	test(1 / 5,0.2);
	//	test(3 * 2 + 5,11);
	//	test(3 * (2 + 5),21);
	//	test(3 * 2 + 6,12);
	//	test(3 + 5,8);
	//	test([55,66,77][1],66);

	//	var a = [55];
		//test(a[0] *= 2; a[0],110);
		//test(x,55,{ x : 55 });
		//test(var y = 33; y,33);
		//test({ 1; 2; 3; },3);
		//test({ var x = 0; } x,55,{ x : 55 });
		//test(o.val,55,{ o : { val : 55 } });
		//test(o.val,null,{ o : {} });

	//	var a = 1; 
	//	test(a++,1);

		//test(var a = 1; a++; a,2);
		//test(var a = 1; ++a,2);
		//test(var a = 1; a *= 3,3);
		//test(a = b = 3; a + b,6);
		//test(add(1,2),3,{ add : function(x,y) return x + y });
		//test(a.push(5); a.pop() + a.pop(),8,{ a : [3] });
		//test(if( true ) 1 else 2,1);
		//test(if( false ) 1 else 2,2);
		//test(var t = 0; for( x in [1,2,3] ) t += x; t,6);
		//test(var a = new Array(); for( x in 0...5 ) a[x] = x; a.join('-'),"0-1-2-3-4");
		//test((function(a,b) return a + b)(4,5),9);
		//test(var y = 0; var add = function(a) y += a; add(5); add(3); y, 8);
		//test(var a = [1,[2,[3,[4,null]]]]; var t = 0; while( a != null ) { t += a[0]; a = a[1]; }; t,10);
		//test(var t = 0; for( x in 1...10 ) t += x; t, 45);

		//test(var t = 0; for( x in new IntIterator(1,10) ) t +=x; t, 45);

		//test(var x = 1; try { var x = 66; throw 789; } catch( e : Dynamic ) e + x,790);
		//test(var x = 1; var f = function(x) throw x; try f(55) catch( e : Dynamic ) e + x,56);
		//test(var i=2; if( true ) --i; i,1);
		//test(var i=0; if( i++ > 0 ) i=3; i,1);
		//test(var a = 5/2; a,2.5);
		//test({ x = 3; x; }, 3);
		//test({ x : 3, y : {} }.x, 3);
		//test(function bug(){ \n }\nbug().x, null);
	//	test(1 + 2 == 3, true);
	//	test(-2 == 3 - 5, true);

	//	var s = "s";
	//	var k = "kl";
	//	var z = 90;

	//	function a(){
	//		s = "u";
	//		k = s;
	//		var z = 3;
	//		trace("a");
	//	}

	//	function b()
	//	{
	//		z = 5;
	//		a();
	//	}

	//	b();
	//	trace("Done");

	//	Test.main();
	}
}*/