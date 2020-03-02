# Documentation about available registers:
# https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
#

from peachpy.x86_64 import (
        ADD, XOR, INC, LEA, MOV, INT, RET, CALL, LABEL, JMP, NOP, RETURN,
        PUSH, POP,
        ebx, ecx, edx, eax, abi, rax, rdx,
        Function, uarch,
        )
from peachpy.x86_64.operand import RIPRelativeOffset
from peachpy.x86_64.registers import rsp, rip

def print_fn(asm_fn, n=1):
    e = asm_fn.finalize(abi.system_v_x86_64_abi).encode()
    print("# %s:" % asm_fn.name)
    size = 0
    for i in e._instructions[n:]:
        hlen = len(i.encode().hex())
        size += hlen/2
        if hlen >= 12:
            tabs = "\t"
        elif hlen >= 6:
            tabs = "\t\t"
        else:
            tabs = "\t\t\t"
        line = "\t%s%s# %s" % (i.encode().hex(" "), tabs, i.format("gas"))
        print(line)
    print()
    print("# +%d" % size)

with Function("_start", (), None, target=uarch.default) as fn:
    CALL(RIPRelativeOffset(25+17-5))
    MOV(eax, 4)
    PUSH(rax)
    CALL(RIPRelativeOffset(25+17-(5+3+1+5)))
    ADD(rsp, rax)
    CALL(RIPRelativeOffset(3))
    POP(rax)
    #JMP(RIPRelativeOffset(-25))
    RET()
print_fn(fn, n=0)


with Function("putchar", (), None, target=uarch.default) as fn:
    XOR(ebx, ebx)
    INC(ebx)
    LEA(ecx, [rsp+4])
    MOV(edx, ebx)
    MOV(eax, 4)
    INT(0x80)
    RET()
print_fn(fn)

with Function("exit", (), None, target=uarch.default) as fn:
    XOR(eax, eax)
    MOV(ebx, eax)
    INC(eax)
    INT(0x80)
    RET()
print_fn(fn)
