;@.str = private constant [13 x i8] c"Hello World!\00", align 1 ;
;
;define i32 @main() ssp {
;entry:
;  %retval = alloca i32
;  %0 = alloca i32
;  %"alloca point" = bitcast i32 0 to i32
;  %1 = call i32 @puts(i8* getelementptr inbounds ([13 x i8]* @.str, i64 0, i64 0))
;  store i32 0, i32* %0, align 4
;  %2 = load i32* %0, align 4
;  store i32 %2, i32* %retval, align 4
;  br label %return
;return:
;  %retval1 = load i32* %retval
;  ret i32 %retval1
;}
;
;declare i32 @puts(i8*)

; llvm-as llvm.ll
; x86 assembly: llc llvm.bc -o llvm.s -march x86
; interpreter: lli llvm.bc

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128"

declare i32 @puts (i8*)

%char = type i8
%Int = type i32
%Float = type double


@global_str = constant [13 x i8] c"Hello World)\00"
@global_str_ptr = global i8* null
@0 = internal unnamed_addr constant [14 x i8] c"hello world!\0A\00"

define double @foo(){
  ret double 0.0
}

define double @bar(){
  ret double 0.1
}

define double @baz(double %x) {
entry:
  %ifcond = fcmp one double %x, 0.000000e+00
  br i1 %ifcond, label %then, label %else

then:       ; preds = %entry
  %calltmp = call double @foo()
  br label %ifcont

else:       ; preds = %entry
  %calltmp1 = call double @bar()
  br label %ifcont

ifcont:     ; preds = %else, %then
  %iftmp = phi double [ %calltmp, %then ], [ %calltmp1, %else ]
  ret double %iftmp
}

define i32 @main(...) {
  double @bar(){
    ret double 0.1
  }
  ;global_str_ptr = getelementptr [13 x i8]*  @global_str, i64 0, i64 0
  %temp = getelementptr [13 x i8]*  @global_str, i64 0, i64 0
  call i32 @puts(i8* %temp)
  ;%n = i32 5
  %n = alloca %Int
  store %Int 0, %Int* %n
  ;%sum = add i32 %n, 5
  ;call i32 @puts(i8* @0)
  call double @baz(double 8.0)
  ret i32 0
}