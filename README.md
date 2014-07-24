llvmaxe-haxe-llvm
=================

Haxe LLVM code gen backend (not for Neko JIT)

Hello everyone. I saw this git was in haxe roundup, cool.

So, to be clear: there is another implementation of LLVM target called haxe-genc, the primary idea to generate C code. Almost all works, except Dynamic and Garbage Collection. I am not contributing to that git. I have my own vision of the problem.

Haxe is great language with deep possibilities of optimization, fast compiler, own concepts. But it lacks of runtime. I think it would be great to directly compile Haxe to platform specific bytecode, with ASM like LLVM. You probably thought that LLVM is main target, but not. LLVM is just cool, industry leading environment of creation ultrafast crossplatform assemblies.

Generating C code is good idea, but C dont provide all features that LLVM IR have, and limits possibilities of optimisations. YES, C *is* fast, but not enought. Look for example at Lua - some basic concepts made it runtime the fastets. But same Lua code converted to JS, using V8, is soo slow. Why we need to use C+"VM simulator" for Haxe? Maybe some key haXe-specific concepts implemented in "ASM" (LLVM) is the way to go?

I have some "breakingly" concepts. For ex extended ARC, not GC for mem management. Bad idea? Why? Make issue. But Haxe dont limits me to GC. It dont lomits me to provide "true" dynamic as we see in HXCPP. Haxe dont allow dynamic code generation so there no need for any VM-like structures, everything can be precomputed and boiled into bytecode, not to C code - taht is full of "undefined behavior" etc.

Stay in touch and make issues, provide ideas. We need *true* Haxe runtime. But, LuaXe is my primary target for now, for practise before LLVM.

Have a nice day! 
