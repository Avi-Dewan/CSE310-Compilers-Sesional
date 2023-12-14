#ifndef _asm_
#define _asm_

#include<fstream>
#include<string>

using namespace std;

class AsmWrite
{
public:
    int levelNumber;
    FILE* asmout;

    AsmWrite();
    ~AsmWrite();

    void start();
    void writeRaw(string s);
    void globalCode(string var);
    void varWrite(int var_number);
    void func_start(string func_name);
    void func_end(string func_name, int total_param_end);
    void func_println();
    void func_newLine();
    void call_println(string accessinfo);


};

AsmWrite::AsmWrite(/* args */)
{
    asmout  = fopen("asm_code.asm", "w");
    levelNumber = 0;
}

AsmWrite::~AsmWrite()
{
}


void AsmWrite::start() {
    fprintf(asmout,
";-------\n\
;\n\
;-------\n\
.MODEL SMALL\n\
.STACK 1000H\n\
.Data\n\
\tCR EQU 0DH\n\
\tLF EQU 0AH\n");
}

void AsmWrite::globalCode(string var) {
    fprintf(asmout, "\t%s DW 1 DUP (0000H)\n", var.c_str());
}

void AsmWrite::varWrite(int var_number) {
    fprintf(asmout, "\tSUB SP, %d\n", var_number*2);
}


void AsmWrite::writeRaw(string s) {
    fprintf(asmout, "%s\n", s.c_str());
}

void AsmWrite::func_start(string func_name) {
    fprintf(asmout, "%s PROC\n", func_name.c_str());

    if(func_name == "main") {
        fprintf(asmout, "\tMOV AX, @DATA\n\
\tMOV DS, AX\n");
    }

    fprintf(asmout, "\tPUSH BP\n\
\tMOV BP, SP\n");

}

void AsmWrite::func_end(string func_name, int total_param_var) {

    fprintf(asmout, "\tADD SP,%d\n\tPOP BP\n", total_param_var*2);

    if(func_name == "main") {
        fprintf(asmout, "\tMOV AX,4CH\n\tINT 21H\n");
    }

    fprintf(asmout, "%s ENDP\n\n", func_name.c_str());

    
}

void AsmWrite::func_println() {
    
    fprintf(asmout, "\
PRINT_OUTPUT PROC\n\
    PUSH AX\n\
    PUSH BX\n\
    PUSH CX\n\
    PUSH DX\n\
\n\
    ; if AX < 0\n\
    OR AX, AX\n\
    JGE @END_IF1\n\
\n\
    ; then\n\
    PUSH AX         ; save number\n\
    MOV DL, '-'     ; get '-'\n\
    MOV AH, 2       ; print char function\n\
    INT 21H         \n\
    POP AX          ; get AX back\n\
    NEG AX          ; AX = - AX\n\
@END_IF1:\n\
    \n\
    ; get decimal digits                   \n\
    XOR CX, CX      ; CX counts digits\n\
    MOV BX, 10D     ; BX has divisor\n\
                                \n\
DEC_OUTPUT_WHILE:\n\
    XOR DX, DX      ; prepare high word of dividend\n\
    DIV BX          ; AX = quotient, DX = remainder\n\
    PUSH DX         ; save remainder on stack\n\
    INC CX          ; count = count + 1\n\
    \n\
    ; until\n\
    OR AX,  AX      ; quotient = 0?\n\
    JNE DEC_OUTPUT_WHILE      \n\
    \n\
    ; convert digit to char and print\n\
    MOV AH, 2       ; print char function\n\
DEC_PRINT_LOOP:\n\
    POP DX          ; digit in DL\n\
    OR DL, 30H      ; convert to char\n\
    INT 21H         ; print digit\n\
    LOOP DEC_PRINT_LOOP\n\
    \n\
    ; end for\n\
    \n\
    POP DX  \n\
    POP CX     \n\
    POP BX\n\
    POP AX       \n\
    RET\n\
PRINT_OUTPUT ENDP\n");


}


void AsmWrite::func_newLine() {
    fprintf(asmout, "NEW_LINE PROC\n\
    PUSH AX\n\
    PUSH DX\n\
    \n\
    MOV AH, 2       ; output a char\n\
    MOV DL, 0DH     \n\
    INT 21H         ; print CR\n\
    MOV DL, 0AH     \n\
    INT 21H         ; print LF\n\
    \n\
    POP DX                    \n\
    POP AX                    \n\
    RET\n\
NEW_LINE ENDP\n");

}

void AsmWrite::call_println(string access_info) {

    fprintf(asmout, "\tMOV AX,%s\n", access_info.c_str());

    fprintf(asmout, "\tCALL PRINT_OUTPUT\n\tCALL NEW_LINE\n");

}






#endif