package llvmaxe;

// Clang types:
abstract CBool8(Bool) from Bool to Bool {}

abstract CInt8(Int) from Int to Int {}
abstract CInt16(Int) from Int to Int {}
abstract CInt32(Int) from Int to Int {}
abstract CInt64(Int) from Int to Int {}
typedef Byte = CInt8;
typedef Short = CInt16;
typedef Long = CInt32;
typedef LongLong = CInt64;

abstract CFloat16(Float) from Float to Float {} // from CFloat16 ?
abstract CFloat32(Float) from Float to Float {}
abstract CFloat64(Float) from Float to Float {}
typedef Half = CFloat16;
typedef Single = CFloat32;
typedef Double = CFloat64;

abstract CChar8(Int) from Int to Int {}
typedef Char = CChar8;

// Clang pointers:

abstract Pointer32(Int) from Int to Int {}
abstract Pointer64(CInt64) from CInt64 to CInt64 {}

typedef Pointer = #if llvm64 Pointer64 #else Pointer32 #end;

abstract PBool8(Int) from Int to Int {}
abstract PPBool8(Int) from Int to Int {}

abstract PVoid(Int) from Int to Int {}
abstract PPVoid(Int) from Int to Int {}

class LLVM {}