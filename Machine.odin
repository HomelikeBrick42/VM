package vm

import "core:fmt"
import "core:mem"

Register :: enum {
	rz,
	rip,
	rfp,
	rsp,
	ra,
	rt,
	r1,
	r2,
	r3,
	r4,
	r5,
	r6,
	r7,
	r8,
}

Machine :: struct {
	registers:    [Register]u64,
	instructions: []Instruction,
	stack:        [1024 * 1024]byte,
}
#assert(size_of(u64) == size_of(uintptr))

Init :: proc(machine: ^Machine, instructions: []Instruction) {
	machine.registers = {}
	machine.registers[.rsp] = transmute(u64)&machine.stack[len(machine.stack) - 1]
	mem.zero(&machine.stack[0], size_of(machine.stack))
	machine.instructions = instructions
}

Exectute :: proc(using machine: ^Machine) {
	for {
		switch i in instructions[registers[.rip]] {
		case Exit:
			return
		case Goto:
			registers[.rip] = i.loc - 1
		case GotoIf:
			if registers[i.reg] != 0 {
				registers[.rip] = i.loc - 1
			}
		case GotoIfZero:
			if registers[i.reg] == 0 {
				registers[.rip] = i.loc - 1
			}
		case Jump:
			registers[.ra] = registers[.rip]
			registers[.rip] = i.loc - 1
		case JumpIf:
			if registers[i.reg] != 0 {
				registers[.ra] = registers[.rip]
				registers[.rip] = i.loc - 1
			}
		case JumpIfZero:
			if registers[i.reg] == 0 {
				registers[.ra] = registers[.rip]
				registers[.rip] = i.loc - 1
			}
		case Load8:
			(^u8)(&registers[i.reg])^ = (transmute(^u8)registers[i.adr])^
		case Load16:
			(^u16)(&registers[i.reg])^ = (transmute(^u16)registers[i.adr])^
		case Load32:
			(^u32)(&registers[i.reg])^ = (transmute(^u32)registers[i.adr])^
		case Load64:
			(^u64)(&registers[i.reg])^ = (transmute(^u64)registers[i.adr])^
		case Store8:
			(transmute(^u8)registers[i.adr])^ = (^u8)(&registers[i.reg])^
		case Store16:
			(transmute(^u16)registers[i.adr])^ = (^u16)(&registers[i.reg])^
		case Store32:
			(transmute(^u32)registers[i.adr])^ = (^u32)(&registers[i.reg])^
		case Store64:
			(transmute(^u64)registers[i.adr])^ = (^u64)(&registers[i.reg])^
		case Push:
			registers[.rsp] -= size_of(u64)
			(transmute(^u64)registers[.rsp])^ = registers[i.reg]
		case Pop:
			registers[i.reg] = (transmute(^u64)registers[.rsp])^
			registers[.rsp] += size_of(u64)
		case Mov:
			registers[i.dst] = registers[i.src]
		case EQ:
			registers[i.dst] = u64(registers[i.a] == registers[i.b])
		case NE:
			registers[i.dst] = u64(registers[i.a] != registers[i.b])
		case MovI:
			registers[i.dst] = i.val
		case AddI:
			registers[i.dst] = registers[i.a] + registers[i.b]
		case SubI:
			registers[i.dst] = registers[i.a] - registers[i.b]
		case MulI:
			registers[i.dst] = registers[i.a] * registers[i.b]
		case DivI:
			registers[i.dst] = registers[i.a] / registers[i.b]
		case ModI:
			registers[i.dst] = registers[i.a] % registers[i.b]
		case LTI:
			registers[i.dst] = u64(registers[i.a] < registers[i.b])
		case LEI:
			registers[i.dst] = u64(registers[i.a] <= registers[i.b])
		case PrintI:
			fmt.println(registers[i.reg])
		case MovF:
			registers[i.dst] = transmute(u64)i.val
		case AddF:
			registers[i.dst] = transmute(u64)(transmute(f64)registers[i.a] + transmute(f64)registers[i.b])
		case SubF:
			registers[i.dst] = transmute(u64)(transmute(f64)registers[i.a] - transmute(f64)registers[i.b])
		case MulF:
			registers[i.dst] = transmute(u64)(transmute(f64)registers[i.a] * transmute(f64)registers[i.b])
		case DivF:
			registers[i.dst] = transmute(u64)(transmute(f64)registers[i.a] / transmute(f64)registers[i.b])
		case LTF:
			registers[i.dst] = u64(transmute(f64)registers[i.a] < transmute(f64)registers[i.b])
		case LEF:
			registers[i.dst] = u64(transmute(f64)registers[i.a] <= transmute(f64)registers[i.b])
		case PrintF:
			fmt.println(transmute(f64)registers[i.reg])
		}
		registers[.rip] += 1
		registers[.rz] = 0
	}
}
