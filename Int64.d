/***********************************\
              Int64
\***********************************/

class int64 { // Just if someone wants to use this... It's not really necessary.
        var int lo;
        var int hi;
};
instance int64@(int64) {
        lo = -1060454374;
        hi = -1378545154;
};
func void mk64(var int dest, var int lo, var int hi) { // Make Int64 // hi has to be -1 for negative 32bit lo
        MEM_WriteInt(dest, lo);
        MEM_WriteInt(dest+4, hi);
};

const int neg64_asm = 0;
func void neg64(var int dest /*dest<- -dest*/) {
        var int dest0; var int dest4;
        dest0 = MEM_ReadInt(dest); dest4 = MEM_ReadInt(dest+4);
        if (!neg64_asm) {

                /*      push eax                        50
                        mov eax, [dest]         A1 ?? ?? ?? ??
                        neg eax                         F7 D8
                        mov [dest], eax         A3 ?? ?? ?? ??
                        mov eax, [dest+4]       A1 ?? ?? ?? ??
                        adc eax, 0                      83 D1 00
                        neg eax                         F7 D8
                        mov [dest+4], eax       A3 ?? ?? ?? ??
                        pop eax                         58
                */

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(247); ASM_1(216);

                ASM_1(163); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(161); ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(131); ASM_1(209); ASM_1(0);

                ASM_1(247); ASM_1(216);

                ASM_1(163); ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(88);

                neg64_asm = ASM_Close();
        };
        ASM_Run(neg64_asm);
        MEM_WriteInt(dest, dest0);
        MEM_WriteInt(dest+4, dest4);
};

const int add64_asm = 0;
func void add64(var int dest, var int src/*dest<-dest+src*/) {
        var int dest0; var int dest4; var int src0; var int src4;
        dest0 = MEM_ReadInt(dest); dest4 = MEM_ReadInt(dest+4);
        src0 = MEM_ReadInt(src); src4 = MEM_ReadInt(src+4);
        if (!add64_asm) {
                /* Assembly code - Look up Opcodes?
                push eax                50
                push edx                52
                mov eax, [dest]         A1 ?? ?? ?? ??
                mov edx, [dest+4]       8B 15 ?? ?? ?? ??
                add eax, [src]          03 05 ?? ?? ?? ?? // This comes out to 38 Byte
                adc edx, [src+4]        13 15 ?? ?? ?? ??
                mov dest, eax           A3 ?? ?? ?? ??
                mov dest+4, edx         89 15 ?? ?? ?? ??
                pop edx                 5A
                pop eax                 58
                */


                ASM_Open(50);

                ASM_1(80);

                ASM_1(82);

                ASM_1(161);  ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(139);  ASM_1(21);  ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(3);  ASM_1(5);  ASM_4(MEM_GetIntAddress(src0));

                ASM_1(19);  ASM_1(21);  ASM_4(MEM_GetIntAddress(src4));

                ASM_1(163); ASM_4(dest);

                ASM_1(137); ASM_1(21); ASM_4(dest+4);

                ASM_1(90);

                ASM_1(88);

                add64_asm = ASM_Close();

        };
        ASM_Run(add64_asm);
        MEM_WriteInt(dest, dest0);
        MEM_WriteInt(dest+4, dest4);
};

const int sub64_asm = 0;
func void sub64(var int dest, var int src/*dest<-dest-src*/) {
        var int dest0; var int dest4; var int src0; var int src4;
        dest0 = MEM_ReadInt(dest); dest4 = MEM_ReadInt(dest+4);
        src0 = MEM_ReadInt(src); src4 = MEM_ReadInt(src+4);
        if (!sub64_asm) {
                /* Assembly Code - Look up opcodes
                push eax                50
                push edx                52
                mov eax, [dest]         A1 ?? ?? ?? ??
                mov edx, [dest+4]       8B 15 ?? ?? ?? ??
                sub eax, [src]          2B 05 ?? ?? ?? ?? // This comes out to 38 Byte
                sbb edx, [src+4]        1B 15 ?? ?? ?? ??
                mov dest+4, eax         A3 ?? ?? ?? ??
                mov dest, edx           89 15 ?? ?? ?? ??
                pop edx                 5A
                pop eax                 58
                */

                ASM_Open(50);

                ASM_1(80);

                ASM_1(82);

                ASM_1(161);  ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(139);  ASM_1(21);  ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(43);  ASM_1(5);  ASM_4(MEM_GetIntAddress(src0));

                ASM_1(27);  ASM_1(21);  ASM_4(MEM_GetIntAddress(src4));

                ASM_1(163); ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(137); ASM_1(21); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(90);

                ASM_1(88);

                sub64_asm = ASM_Close();
        };
        ASM_Run(sub64_asm);
        MEM_WriteInt(dest, dest0);
        MEM_WriteInt(dest+4, dest4);
};

// Everything below is certainly not working!
// ToDo:
//                      Make the ASM dynamic so I don't have to recreate it every time.
//                      Care for the sign of the numbers (using neg64()).
const int  mul64_asm = 0;
func void mul64(var int dest, var int src /*dest<-dest*src*/) {
        var int dest0; var int dest4; var int src0; var int src4;
        dest0 = MEM_ReadInt(dest); dest4 = MEM_ReadInt(dest+4);
        src0 = MEM_ReadInt(src); src4 = MEM_ReadInt(src+4);
        var int sign; sign = 1; /*positive*/ if (dest4 < 0) { sign = -sign; neg64(dest); }; // It's okay to change the original value because it gets overridden anyway.

        var int ptr; ptr = 0;
        if (src4 < 0) {
                sign = -sign;
                 ptr  = MEM_Alloc(8); MEM_CopyWords(src, ptr, 2);
                src = ptr; // I can't change the original value!
                neg64(src);
        };

        dest0 = MEM_ReadInt(dest); dest4 = MEM_ReadInt(dest+4);
        src0 = MEM_ReadInt(src); src4 = MEM_ReadInt(src+4);             // Init it again because signs might have changed.

        if (!mul64_asm) {
                /* Assembler Code - Look up Opcodes? HI first

                mov eax, [dest+4]       A1 ?? ?? ?? ??
                push eax                50
                mov eax, [dest]         A1 ?? ?? ?? ??
                push eax                50
                mov eax, [src+4]        A1 ?? ?? ?? ??
                push eax                50
                mov eax, [src]          A1 ?? ?? ?? ??
                push eax                50
                call __allmul           E8 ?? ?? ?? ??
                mov dest, eax           A3 ?? ?? ?? ??
                mov dest+4, edx         89 15 ?? ?? ?? ??


                I hope - since it says allmul - I don't have to care about signed/unsigned, but I'm not quite sure. */

                ASM_Open(200);

        //      ASM_1(96);

                ASM_1(161); ASM_4(MEM_GetIntAddress(dest4));   //4040 - 0440 - 0404 - 4004

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(src4));

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(src0));

                ASM_1(80);

                ASM_1(232); ASM_4(8221184-ASM_Here()-4);

                ASM_1(163); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(137); ASM_1(21); ASM_4(MEM_GetIntAddress(dest4));

                //ASM_1(97);
                //
                mul64_asm = ASM_Close();
        };
        ASM_Run(mul64_asm);
        MEM_WriteInt(dest, dest0);
        MEM_WriteInt(dest+4, dest4);
        if (sign == -1) { neg64(dest); };
        if (ptr) { MEM_Free(ptr); };
};

const int div64_asm = 0;
func void div64(var int dest, var int src /*dest<- dest/src*/) {
        var int dest0; var int dest4; var int src0; var int src4;
        /* for no reason dest and src are swapped, this might make the code somewhat harder to understand, though*/
        dest0 = MEM_ReadInt(src); dest4 = MEM_ReadInt(src+4);
        src0 = MEM_ReadInt(dest); src4 = MEM_ReadInt(dest+4);
        var int sign; sign = 1; /*positive*/ if (dest4 < 0) { sign = -sign; neg64(dest); }; // It's okay to change the original value because it gets overridden anyway.

        var int ptr; ptr = 0;
        if (src4 < 0) {
                sign = -sign;
                 ptr  = MEM_Alloc(8); MEM_CopyWords(src, ptr, 2);
                src = ptr; // I can't change the original value!
                neg64(src);
        };

        dest0 = MEM_ReadInt(src); dest4 = MEM_ReadInt(src+4);
        src0 = MEM_ReadInt(dest); src4 = MEM_ReadInt(dest+4);           // Init it again because signs might have changed.

        if (!div64_asm) {
                /* Assembler Code - Look up Opcodes? HI first

                mov eax, [dest+4]       A1 ?? ?? ?? ??
                push eax                50
                mov eax, [dest]         A1 ?? ?? ?? ??
                push eax                50
                mov eax, [src+4]        A1 ?? ?? ?? ??
                push eax                50
                mov eax, [src]          A1 ?? ?? ?? ??
                push eax                50
                call __allmul           E8 ?? ?? ?? ??
                mov dest, eax           A3 ?? ?? ?? ??
                mov dest+4, edx         89 15 ?? ?? ?? ??


                I hope - since it says allmul - I don't have to care about signed/unsigned, but I'm not quite sure. */

                ASM_Open(200);


                ASM_1(161); ASM_4(MEM_GetIntAddress(dest4));

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(src4));

                ASM_1(80);

                ASM_1(161); ASM_4(MEM_GetIntAddress(src0));

                ASM_1(80);

                ASM_1(232); ASM_4(8244256/*0x7DCC20*/-ASM_Here()-4);

                ASM_1(163); ASM_4(MEM_GetIntAddress(dest0));

                ASM_1(137); ASM_1(21); ASM_4(MEM_GetIntAddress(dest4));

                div64_asm = ASM_Close();
        };
        ASM_Run(div64_asm);
                MEM_WriteInt(dest, dest0);
        MEM_WriteInt(dest+4, dest4);
        if (sign == -1) { neg64(dest); };
        if (ptr) { MEM_Free(ptr); };
};