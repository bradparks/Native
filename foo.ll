; ModuleID = 'foo.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

@N = global i32 8, align 4
@M = global i32 8, align 4
@BANG = global i32 3, align 4
@pole = common global i32** null, align 8
@.str = private unnamed_addr constant [33 x i8] c"\D0\9F\D1\80\D0\B8\D0\B2\D0\B5\D1\82! Hello world Clang\0A\00", align 1

; Function Attrs: nounwind ssp uwtable
define void @swap(i32 %x1, i32 %y1, i32 %x2, i32 %y2) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %k = alloca i32, align 4
  store i32 %x1, i32* %1, align 4
  store i32 %y1, i32* %2, align 4
  store i32 %x2, i32* %3, align 4
  store i32 %y2, i32* %4, align 4
  %5 = load i32* %2, align 4
  %6 = sext i32 %5 to i64
  %7 = load i32* %1, align 4
  %8 = sext i32 %7 to i64
  %9 = load i32*** @pole, align 8
  %10 = getelementptr inbounds i32** %9, i64 %8
  %11 = load i32** %10, align 8
  %12 = getelementptr inbounds i32* %11, i64 %6
  %13 = load i32* %12, align 4
  store i32 %13, i32* %k, align 4
  %14 = load i32* %4, align 4
  %15 = sext i32 %14 to i64
  %16 = load i32* %3, align 4
  %17 = sext i32 %16 to i64
  %18 = load i32*** @pole, align 8
  %19 = getelementptr inbounds i32** %18, i64 %17
  %20 = load i32** %19, align 8
  %21 = getelementptr inbounds i32* %20, i64 %15
  %22 = load i32* %21, align 4
  %23 = load i32* %2, align 4
  %24 = sext i32 %23 to i64
  %25 = load i32* %1, align 4
  %26 = sext i32 %25 to i64
  %27 = load i32*** @pole, align 8
  %28 = getelementptr inbounds i32** %27, i64 %26
  %29 = load i32** %28, align 8
  %30 = getelementptr inbounds i32* %29, i64 %24
  store i32 %22, i32* %30, align 4
  %31 = load i32* %k, align 4
  %32 = load i32* %4, align 4
  %33 = sext i32 %32 to i64
  %34 = load i32* %3, align 4
  %35 = sext i32 %34 to i64
  %36 = load i32*** @pole, align 8
  %37 = getelementptr inbounds i32** %36, i64 %35
  %38 = load i32** %37, align 8
  %39 = getelementptr inbounds i32* %38, i64 %33
  store i32 %31, i32* %39, align 4
  ret void
}

; Function Attrs: nounwind ssp uwtable
define i32 @poisk(i32 %temp, i32 %i, i32 %j, i32 %x, i32 %y) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 %temp, i32* %2, align 4
  store i32 %i, i32* %3, align 4
  store i32 %j, i32* %4, align 4
  store i32 %x, i32* %5, align 4
  store i32 %y, i32* %6, align 4
  %7 = load i32* %2, align 4
  %8 = load i32* %4, align 4
  %9 = sext i32 %8 to i64
  %10 = load i32* %3, align 4
  %11 = sext i32 %10 to i64
  %12 = load i32*** @pole, align 8
  %13 = getelementptr inbounds i32** %12, i64 %11
  %14 = load i32** %13, align 8
  %15 = getelementptr inbounds i32* %14, i64 %9
  %16 = load i32* %15, align 4
  %17 = icmp eq i32 %7, %16
  br i1 %17, label %18, label %52

; <label>:18                                      ; preds = %0
  %19 = load i32* %3, align 4
  %20 = load i32* %5, align 4
  %21 = add nsw i32 %19, %20
  %22 = icmp sge i32 %21, 0
  br i1 %22, label %23, label %52

; <label>:23                                      ; preds = %18
  %24 = load i32* %3, align 4
  %25 = load i32* %5, align 4
  %26 = add nsw i32 %24, %25
  %27 = load i32* @N, align 4
  %28 = icmp slt i32 %26, %27
  br i1 %28, label %29, label %52

; <label>:29                                      ; preds = %23
  %30 = load i32* %4, align 4
  %31 = load i32* %6, align 4
  %32 = add nsw i32 %30, %31
  %33 = icmp sge i32 %32, 0
  br i1 %33, label %34, label %52

; <label>:34                                      ; preds = %29
  %35 = load i32* %4, align 4
  %36 = load i32* %6, align 4
  %37 = add nsw i32 %35, %36
  %38 = load i32* @M, align 4
  %39 = icmp slt i32 %37, %38
  br i1 %39, label %40, label %52

; <label>:40                                      ; preds = %34
  %41 = load i32* %2, align 4
  %42 = load i32* %3, align 4
  %43 = load i32* %5, align 4
  %44 = add nsw i32 %42, %43
  %45 = load i32* %4, align 4
  %46 = load i32* %6, align 4
  %47 = add nsw i32 %45, %46
  %48 = load i32* %5, align 4
  %49 = load i32* %6, align 4
  %50 = call i32 @poisk(i32 %41, i32 %44, i32 %47, i32 %48, i32 %49)
  %51 = add nsw i32 1, %50
  store i32 %51, i32* %1
  br label %66

; <label>:52                                      ; preds = %34, %29, %23, %18, %0
  %53 = load i32* %2, align 4
  %54 = load i32* %4, align 4
  %55 = sext i32 %54 to i64
  %56 = load i32* %3, align 4
  %57 = sext i32 %56 to i64
  %58 = load i32*** @pole, align 8
  %59 = getelementptr inbounds i32** %58, i64 %57
  %60 = load i32** %59, align 8
  %61 = getelementptr inbounds i32* %60, i64 %55
  %62 = load i32* %61, align 4
  %63 = icmp eq i32 %53, %62
  br i1 %63, label %64, label %65

; <label>:64                                      ; preds = %52
  store i32 1, i32* %1
  br label %66

; <label>:65                                      ; preds = %52
  store i32 0, i32* %1
  br label %66

; <label>:66                                      ; preds = %65, %64, %40
  %67 = load i32* %1
  ret i32 %67
}

; Function Attrs: nounwind ssp uwtable
define i32 @findLine() #0 {
  %flag = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %flag, align 4
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1                                       ; preds = %46, %0
  %2 = load i32* %i, align 4
  %3 = load i32* @N, align 4
  %4 = icmp slt i32 %2, %3
  br i1 %4, label %5, label %49

; <label>:5                                       ; preds = %1
  store i32 0, i32* %j, align 4
  br label %6

; <label>:6                                       ; preds = %42, %5
  %7 = load i32* %j, align 4
  %8 = load i32* @M, align 4
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %10, label %45

; <label>:10                                      ; preds = %6
  %11 = load i32* %j, align 4
  %12 = sext i32 %11 to i64
  %13 = load i32* %i, align 4
  %14 = sext i32 %13 to i64
  %15 = load i32*** @pole, align 8
  %16 = getelementptr inbounds i32** %15, i64 %14
  %17 = load i32** %16, align 8
  %18 = getelementptr inbounds i32* %17, i64 %12
  %19 = load i32* %18, align 4
  %20 = load i32* %i, align 4
  %21 = load i32* %j, align 4
  %22 = call i32 @poisk(i32 %19, i32 %20, i32 %21, i32 0, i32 1)
  %23 = load i32* @BANG, align 4
  %24 = icmp sge i32 %22, %23
  br i1 %24, label %40, label %25

; <label>:25                                      ; preds = %10
  %26 = load i32* %j, align 4
  %27 = sext i32 %26 to i64
  %28 = load i32* %i, align 4
  %29 = sext i32 %28 to i64
  %30 = load i32*** @pole, align 8
  %31 = getelementptr inbounds i32** %30, i64 %29
  %32 = load i32** %31, align 8
  %33 = getelementptr inbounds i32* %32, i64 %27
  %34 = load i32* %33, align 4
  %35 = load i32* %i, align 4
  %36 = load i32* %j, align 4
  %37 = call i32 @poisk(i32 %34, i32 %35, i32 %36, i32 1, i32 0)
  %38 = load i32* @BANG, align 4
  %39 = icmp sge i32 %37, %38
  br i1 %39, label %40, label %41

; <label>:40                                      ; preds = %25, %10
  store i32 1, i32* %flag, align 4
  br label %41

; <label>:41                                      ; preds = %40, %25
  br label %42

; <label>:42                                      ; preds = %41
  %43 = load i32* %j, align 4
  %44 = add nsw i32 %43, 1
  store i32 %44, i32* %j, align 4
  br label %6

; <label>:45                                      ; preds = %6
  br label %46

; <label>:46                                      ; preds = %45
  %47 = load i32* %i, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %i, align 4
  br label %1

; <label>:49                                      ; preds = %1
  %50 = load i32* %flag, align 4
  ret i32 %50
}

; Function Attrs: nounwind ssp uwtable
define void @generate() #0 {
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %i1 = alloca i32, align 4
  %j2 = alloca i32, align 4
  %fl = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1                                       ; preds = %60, %0
  %2 = load i32* %i, align 4
  %3 = load i32* @N, align 4
  %4 = icmp slt i32 %2, %3
  br i1 %4, label %5, label %63

; <label>:5                                       ; preds = %1
  store i32 0, i32* %j, align 4
  br label %6

; <label>:6                                       ; preds = %56, %5
  %7 = load i32* %j, align 4
  %8 = load i32* @M, align 4
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %10, label %59

; <label>:10                                      ; preds = %6
  br label %11

; <label>:11                                      ; preds = %53, %10
  %12 = call i64 @random()
  %13 = mul nsw i64 %12, 7
  %14 = trunc i64 %13 to i32
  %15 = load i32* %j, align 4
  %16 = sext i32 %15 to i64
  %17 = load i32* %i, align 4
  %18 = sext i32 %17 to i64
  %19 = load i32*** @pole, align 8
  %20 = getelementptr inbounds i32** %19, i64 %18
  %21 = load i32** %20, align 8
  %22 = getelementptr inbounds i32* %21, i64 %16
  store i32 %14, i32* %22, align 4
  br label %23

; <label>:23                                      ; preds = %11
  %24 = load i32* %j, align 4
  %25 = sext i32 %24 to i64
  %26 = load i32* %i, align 4
  %27 = sext i32 %26 to i64
  %28 = load i32*** @pole, align 8
  %29 = getelementptr inbounds i32** %28, i64 %27
  %30 = load i32** %29, align 8
  %31 = getelementptr inbounds i32* %30, i64 %25
  %32 = load i32* %31, align 4
  %33 = load i32* %i, align 4
  %34 = load i32* %j, align 4
  %35 = call i32 @poisk(i32 %32, i32 %33, i32 %34, i32 -1, i32 0)
  %36 = load i32* @BANG, align 4
  %37 = icmp sge i32 %35, %36
  br i1 %37, label %53, label %38

; <label>:38                                      ; preds = %23
  %39 = load i32* %j, align 4
  %40 = sext i32 %39 to i64
  %41 = load i32* %i, align 4
  %42 = sext i32 %41 to i64
  %43 = load i32*** @pole, align 8
  %44 = getelementptr inbounds i32** %43, i64 %42
  %45 = load i32** %44, align 8
  %46 = getelementptr inbounds i32* %45, i64 %40
  %47 = load i32* %46, align 4
  %48 = load i32* %i, align 4
  %49 = load i32* %j, align 4
  %50 = call i32 @poisk(i32 %47, i32 %48, i32 %49, i32 0, i32 -1)
  %51 = load i32* @BANG, align 4
  %52 = icmp sge i32 %50, %51
  br label %53

; <label>:53                                      ; preds = %38, %23
  %54 = phi i1 [ true, %23 ], [ %52, %38 ]
  br i1 %54, label %11, label %55

; <label>:55                                      ; preds = %53
  br label %56

; <label>:56                                      ; preds = %55
  %57 = load i32* %j, align 4
  %58 = add nsw i32 %57, 1
  store i32 %58, i32* %j, align 4
  br label %6

; <label>:59                                      ; preds = %6
  br label %60

; <label>:60                                      ; preds = %59
  %61 = load i32* %i, align 4
  %62 = add nsw i32 %61, 1
  store i32 %62, i32* %i, align 4
  br label %1

; <label>:63                                      ; preds = %1
  store i32 0, i32* %i1, align 4
  br label %64

; <label>:64                                      ; preds = %158, %63
  %65 = load i32* %i1, align 4
  %66 = load i32* @N, align 4
  %67 = icmp slt i32 %65, %66
  br i1 %67, label %68, label %161

; <label>:68                                      ; preds = %64
  store i32 0, i32* %j2, align 4
  br label %69

; <label>:69                                      ; preds = %154, %68
  %70 = load i32* %j2, align 4
  %71 = load i32* @M, align 4
  %72 = icmp slt i32 %70, %71
  br i1 %72, label %73, label %157

; <label>:73                                      ; preds = %69
  store i32 0, i32* %fl, align 4
  %74 = load i32* %i1, align 4
  %75 = load i32* @N, align 4
  %76 = sub nsw i32 %75, 1
  %77 = icmp slt i32 %74, %76
  br i1 %77, label %78, label %93

; <label>:78                                      ; preds = %73
  %79 = load i32* %i1, align 4
  %80 = load i32* %j2, align 4
  %81 = load i32* %i1, align 4
  %82 = add nsw i32 %81, 1
  %83 = load i32* %j2, align 4
  call void @swap(i32 %79, i32 %80, i32 %82, i32 %83)
  %84 = call i32 @findLine()
  %85 = icmp eq i32 %84, 1
  br i1 %85, label %86, label %87

; <label>:86                                      ; preds = %78
  store i32 1, i32* %fl, align 4
  br label %87

; <label>:87                                      ; preds = %86, %78
  %88 = load i32* %i1, align 4
  %89 = load i32* %j2, align 4
  %90 = load i32* %i1, align 4
  %91 = add nsw i32 %90, 1
  %92 = load i32* %j2, align 4
  call void @swap(i32 %88, i32 %89, i32 %91, i32 %92)
  br label %93

; <label>:93                                      ; preds = %87, %73
  %94 = load i32* %i1, align 4
  %95 = icmp sgt i32 %94, 0
  br i1 %95, label %96, label %111

; <label>:96                                      ; preds = %93
  %97 = load i32* %i1, align 4
  %98 = load i32* %j2, align 4
  %99 = load i32* %i1, align 4
  %100 = sub nsw i32 %99, 1
  %101 = load i32* %j2, align 4
  call void @swap(i32 %97, i32 %98, i32 %100, i32 %101)
  %102 = call i32 @findLine()
  %103 = icmp eq i32 %102, 1
  br i1 %103, label %104, label %105

; <label>:104                                     ; preds = %96
  store i32 1, i32* %fl, align 4
  br label %105

; <label>:105                                     ; preds = %104, %96
  %106 = load i32* %i1, align 4
  %107 = load i32* %j2, align 4
  %108 = load i32* %i1, align 4
  %109 = sub nsw i32 %108, 1
  %110 = load i32* %j2, align 4
  call void @swap(i32 %106, i32 %107, i32 %109, i32 %110)
  br label %111

; <label>:111                                     ; preds = %105, %93
  %112 = load i32* %j2, align 4
  %113 = load i32* @M, align 4
  %114 = sub nsw i32 %113, 1
  %115 = icmp slt i32 %112, %114
  br i1 %115, label %116, label %131

; <label>:116                                     ; preds = %111
  %117 = load i32* %i1, align 4
  %118 = load i32* %j2, align 4
  %119 = load i32* %i1, align 4
  %120 = load i32* %j2, align 4
  %121 = add nsw i32 %120, 1
  call void @swap(i32 %117, i32 %118, i32 %119, i32 %121)
  %122 = call i32 @findLine()
  %123 = icmp eq i32 %122, 1
  br i1 %123, label %124, label %125

; <label>:124                                     ; preds = %116
  store i32 1, i32* %fl, align 4
  br label %125

; <label>:125                                     ; preds = %124, %116
  %126 = load i32* %i1, align 4
  %127 = load i32* %j2, align 4
  %128 = load i32* %i1, align 4
  %129 = load i32* %j2, align 4
  %130 = add nsw i32 %129, 1
  call void @swap(i32 %126, i32 %127, i32 %128, i32 %130)
  br label %131

; <label>:131                                     ; preds = %125, %111
  %132 = load i32* %j2, align 4
  %133 = icmp sgt i32 %132, 0
  br i1 %133, label %134, label %149

; <label>:134                                     ; preds = %131
  %135 = load i32* %i1, align 4
  %136 = load i32* %j2, align 4
  %137 = load i32* %i1, align 4
  %138 = load i32* %j2, align 4
  %139 = sub nsw i32 %138, 1
  call void @swap(i32 %135, i32 %136, i32 %137, i32 %139)
  %140 = call i32 @findLine()
  %141 = icmp eq i32 %140, 1
  br i1 %141, label %142, label %143

; <label>:142                                     ; preds = %134
  store i32 1, i32* %fl, align 4
  br label %143

; <label>:143                                     ; preds = %142, %134
  %144 = load i32* %i1, align 4
  %145 = load i32* %j2, align 4
  %146 = load i32* %i1, align 4
  %147 = load i32* %j2, align 4
  %148 = sub nsw i32 %147, 1
  call void @swap(i32 %144, i32 %145, i32 %146, i32 %148)
  br label %149

; <label>:149                                     ; preds = %143, %131
  %150 = load i32* %fl, align 4
  %151 = icmp eq i32 %150, 1
  br i1 %151, label %152, label %153

; <label>:152                                     ; preds = %149
  br label %162

; <label>:153                                     ; preds = %149
  br label %154

; <label>:154                                     ; preds = %153
  %155 = load i32* %j2, align 4
  %156 = add nsw i32 %155, 1
  store i32 %156, i32* %j2, align 4
  br label %69

; <label>:157                                     ; preds = %69
  br label %158

; <label>:158                                     ; preds = %157
  %159 = load i32* %i1, align 4
  %160 = add nsw i32 %159, 1
  store i32 %160, i32* %i1, align 4
  br label %64

; <label>:161                                     ; preds = %64
  call void @generate()
  br label %162

; <label>:162                                     ; preds = %161, %152
  ret void
}

declare i64 @random() #1

; Function Attrs: nounwind ssp uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %i = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  %4 = load i32* @N, align 4
  %5 = sext i32 %4 to i64
  %6 = mul i64 %5, 4
  %7 = mul i64 %6, 2
  %8 = call i8* @malloc(i64 %7)
  %9 = bitcast i8* %8 to i32**
  store i32** %9, i32*** @pole, align 8
  store i32 0, i32* %i, align 4
  br label %10

; <label>:10                                      ; preds = %24, %0
  %11 = load i32* %i, align 4
  %12 = load i32* @N, align 4
  %13 = icmp slt i32 %11, %12
  br i1 %13, label %14, label %27

; <label>:14                                      ; preds = %10
  %15 = load i32* @M, align 4
  %16 = sext i32 %15 to i64
  %17 = mul i64 %16, 4
  %18 = call i8* @malloc(i64 %17)
  %19 = bitcast i8* %18 to i32*
  %20 = load i32* %i, align 4
  %21 = sext i32 %20 to i64
  %22 = load i32*** @pole, align 8
  %23 = getelementptr inbounds i32** %22, i64 %21
  store i32* %19, i32** %23, align 8
  br label %24

; <label>:24                                      ; preds = %14
  %25 = load i32* %i, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, i32* %i, align 4
  br label %10

; <label>:27                                      ; preds = %10
  call void @generate()
  store i32 11, i32* @N, align 4
  store i32 8, i32* @M, align 4
  %28 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([33 x i8]* @.str, i32 0, i32 0))
  %29 = load i32* %1
  ret i32 %29
}

declare i8* @malloc(i64) #1

declare i32 @printf(i8*, ...) #1

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)"}
