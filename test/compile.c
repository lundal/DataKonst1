#include <endian.h>
#include <stdint.h>
#include <stdio.h>

#define OP_RRR 0
#define OP_LW (35 << 26)
#define OP_BEQ (4 << 26)
#define OP_SW (43 << 26)
#define OP_J (2 << 26)

#define FUNC_ADD 32
#define FUNC_SLT 42

#define RS(x) (x << 21)
#define RT(x) (x << 16)
#define RD(x) (x << 11)

typedef union {
    int16_t half[2];
    uint32_t whole;
} half_to_word_t;

int main(int argc, char *argv) {
    half_to_word_t minusfour;
    minusfour.half[1] = 0;
    minusfour.half[0] = -4;

    uint32_t numbers[10] = {
        OP_LW  | RT(1) | RS(0) | 0x1, //LW $1,0x1($0)
        OP_LW  | RT(2) | RS(0) | 0x2, //LW $2,0x2($0)
        OP_LW  | RT(3) | RS(0) | 0xf, //LW $3,0xf($0)
        OP_RRR | RD(4) | RS(1) | RT(2) | FUNC_ADD, //ADD $4,$1,$2
        OP_RRR | RD(1) | RS(2) | RT(0) | FUNC_ADD, //ADD $1,$2,$0
        OP_RRR | RD(2) | RS(4) | RT(0) | FUNC_ADD, //ADD $2,$4,$0
        OP_RRR | RD(4) | RS(3) | RT(2) | FUNC_SLT, //SLT $4,$3,$2
        OP_BEQ | RS(0) | RT(4) | minusfour.whole, //BEQ $0,$4,0x4
        OP_SW  | RT(3) | RS(0) | 0x10, //SW $3,0x10($0)
        OP_J   | 0xa //J 0xa
    };
    int i;

    for (i = 0; i < 10; i++) {
        numbers[i] = htobe32(numbers[i]);
    }

    FILE *fp = fopen("instructions.bin", "w");
    fwrite(numbers, sizeof(*numbers), 10, fp);
    fclose(fp);

    return 0;
}
