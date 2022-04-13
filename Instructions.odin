package vm

Instruction :: union {
	// Control flow
	Exit,
	Goto,
	GotoIf,
	GotoIfZero,
	Jump,
	JumpIf,
	JumpIfZero,

	// Loads
	Load8,
	Load16,
	Load32,
	Load64,

	// Stores
	Store8,
	Store16,
	Store32,
	Store64,

	// Push/Pop
	Push,
	Pop,

	// Register
	Mov,
	EQ,
	NE,

	// Integer
	MovI,
	AddI,
	SubI,
	MulI,
	DivI,
	ModI,
	PrintI,
	LTI,
	LEI,
	MovF,
	AddF,
	SubF,
	MulF,
	DivF,
	LTF,
	LEF,
	PrintF,
}

Exit :: struct {}
Goto :: struct {
	loc: u64,
}
GotoIf :: struct {
	reg: Register,
	loc: u64,
}
GotoIfZero :: struct {
	reg: Register,
	loc: u64,
}
Jump :: struct {
	loc: u64,
}
JumpIf :: struct {
	reg: Register,
	loc: u64,
}
JumpIfZero :: struct {
	reg: Register,
	loc: u64,
}

Load8 :: struct {
	reg, adr: Register,
}
Load16 :: struct {
	reg, adr: Register,
}
Load32 :: struct {
	reg, adr: Register,
}
Load64 :: struct {
	reg, adr: Register,
}

Store8 :: struct {
	adr, reg: Register,
}
Store16 :: struct {
	adr, reg: Register,
}
Store32 :: struct {
	adr, reg: Register,
}
Store64 :: struct {
	adr, reg: Register,
}

Push :: struct {
	reg: Register,
}
Pop :: struct {
	reg: Register,
}

Mov :: struct {
	dst, src: Register,
}
EQ :: struct {
	dst, a, b: Register,
}
NE :: struct {
	dst, a, b: Register,
}

MovI :: struct {
	dst: Register,
	val: u64,
}
AddI :: struct {
	dst, a, b: Register,
}
SubI :: struct {
	dst, a, b: Register,
}
MulI :: struct {
	dst, a, b: Register,
}
DivI :: struct {
	dst, a, b: Register,
}
ModI :: struct {
	dst, a, b: Register,
}
LTI :: struct {
	dst, a, b: Register,
}
LEI :: struct {
	dst, a, b: Register,
}
PrintI :: struct {
	reg: Register,
}

MovF :: struct {
	dst: Register,
	val: f64,
}
AddF :: struct {
	dst, a, b: Register,
}
SubF :: struct {
	dst, a, b: Register,
}
MulF :: struct {
	dst, a, b: Register,
}
DivF :: struct {
	dst, a, b: Register,
}
LTF :: struct {
	dst, a, b: Register,
}
LEF :: struct {
	dst, a, b: Register,
}
PrintF :: struct {
	reg: Register,
}
