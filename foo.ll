; ModuleID = 'foo.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

%struct.parameters = type { double, double }

@.str = private unnamed_addr constant [33 x i8] c"\D0\9F\D1\80\D0\B8\D0\B2\D0\B5\D1\82! Hello world Clang\0A\00", align 1

; Function Attrs: nounwind ssp uwtable
define i32 @func(i32 %a) #0 {
  %1 = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  %2 = load i32* %1, align 4
  %3 = add nsw i32 %2, 4
  ret i32 %3
}

; Function Attrs: nounwind ssp uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i8**, align 8
  %p = alloca %struct.parameters*, align 8
  store i32 %argc, i32* %1, align 4
  store i8** %argv, i8*** %2, align 8
  %3 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([33 x i8]* @.str, i32 0, i32 0))
  %4 = call i8* @malloc(i64 16)
  %5 = bitcast i8* %4 to %struct.parameters*
  store %struct.parameters* %5, %struct.parameters** %p, align 8
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

declare i8* @malloc(i64) #1

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)"}
