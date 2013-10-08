; Find the first fibbonacci number over the integer stored at memory location
; 0xf and store it at 0x10. 0x1 should contain the integer 1 and 0x2 should
; contain the integer 2.

LW $1,0x1($0) ; $1=Fn-2
LW $2,0x2($0) ; $2=Fn-1
LW $3,0xf($0) ; $3=Number limit

ADD $4,$1,$2
ADD $1,$2,$0 ; Move $2 to $1
ADD $2,$4,$0 ; Move $4 to $2
SLT $4,$3,$2 ; $4 = $3 < $2
BEQ $0,$4,-0x4 ; If $3 > $2, go to 0x4

SW $3,0x10($0) ; Store value at 0x10
J 0x
