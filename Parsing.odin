package vm

import "core:fmt"

Parse :: proc(filepath, source: string) -> (
	instructions: []Instruction,
	error: Maybe(Error),
) {
	labels: map[string]u64
	defer delete(labels)
	pending_labels: map[string][dynamic]u64
	defer {
		for _, list in pending_labels {
			delete(list)
		}
		delete(pending_labels)
	}
	ops: [dynamic]Instruction
	lexer := Lexer_Create(filepath, source)
	for Lexer_PeekToken(lexer) or_return.kind != .EOF {
		token := Lexer_NextToken(&lexer) or_return
		#partial switch token.kind {
		case .Newline:
			continue
		case .Label:
			name := token.data.(string)
			if _, ok := labels[name]; ok {
				error = Error {
					location = token.location,
					message  = fmt.aprintf("Label ':%s' is already defined", name),
				}
				return {}, error
			}
			labels[name] = u64(len(ops))
			if list, ok := &pending_labels[name]; ok {
				for index in list {
					#partial switch i in &ops[index] {
					case Goto:
						i.loc = labels[name]
					case GotoIf:
						i.loc = labels[name]
					case GotoIfZero:
						i.loc = labels[name]
					case Jump:
						i.loc = labels[name]
					case JumpIf:
						i.loc = labels[name]
					case JumpIfZero:
						i.loc = labels[name]
					case:
						unreachable()
					}
				}
				clear(list)
			}
		case .Exit:
			append(&ops, Exit{})
		case .Goto:
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, Goto{loc = loc})
		case .GotoIf:
			reg := ExpectRegister(&lexer) or_return
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, GotoIf{reg = reg, loc = loc})
		case .GotoIfZero:
			reg := ExpectRegister(&lexer) or_return
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, GotoIfZero{reg = reg, loc = loc})
		case .Jump:
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, Jump{loc = loc})
		case .JumpIf:
			reg := ExpectRegister(&lexer) or_return
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, JumpIf{reg = reg, loc = loc})
		case .JumpIfZero:
			reg := ExpectRegister(&lexer) or_return
			label := ExpectToken(&lexer, .Label) or_return.data.(string)
			loc: u64
			if i, ok := labels[label]; ok {
				loc = i
			} else {
				if _, ok := pending_labels[label]; !ok {
					pending_labels[label] = make([dynamic]u64)
				}
				append(&pending_labels[label], u64(len(ops)))
			}
			append(&ops, JumpIfZero{reg = reg, loc = loc})
		case .Load8:
			reg := ExpectRegister(&lexer) or_return
			adr := ExpectRegister(&lexer) or_return
			append(&ops, Load8{reg = reg, adr = adr})
		case .Load16:
			reg := ExpectRegister(&lexer) or_return
			adr := ExpectRegister(&lexer) or_return
			append(&ops, Load16{reg = reg, adr = adr})
		case .Load32:
			reg := ExpectRegister(&lexer) or_return
			adr := ExpectRegister(&lexer) or_return
			append(&ops, Load32{reg = reg, adr = adr})
		case .Load64:
			reg := ExpectRegister(&lexer) or_return
			adr := ExpectRegister(&lexer) or_return
			append(&ops, Load64{reg = reg, adr = adr})
		case .Store8:
			adr := ExpectRegister(&lexer) or_return
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Store8{adr = adr, reg = reg})
		case .Store16:
			adr := ExpectRegister(&lexer) or_return
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Store16{adr = adr, reg = reg})
		case .Store32:
			adr := ExpectRegister(&lexer) or_return
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Store32{adr = adr, reg = reg})
		case .Store64:
			adr := ExpectRegister(&lexer) or_return
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Store64{adr = adr, reg = reg})
		case .Push:
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Push{reg = reg})
		case .Pop:
			reg := ExpectRegister(&lexer) or_return
			append(&ops, Pop{reg = reg})
		case .Mov:
			dst := ExpectRegister(&lexer) or_return
			src := ExpectRegister(&lexer) or_return
			append(&ops, Mov{dst = dst, src = src})
		case .EQ:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, EQ{dst = dst, a = a, b = b})
		case .NE:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, NE{dst = dst, a = a, b = b})
		case .MovI:
			dst := ExpectRegister(&lexer) or_return
			val := ExpectToken(&lexer, .Integer) or_return.data.(u64)
			append(&ops, MovI{dst = dst, val = val})
		case .AddI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, AddI{dst = dst, a = a, b = b})
		case .SubI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, SubI{dst = dst, a = a, b = b})
		case .MulI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, MulI{dst = dst, a = a, b = b})
		case .DivI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, DivI{dst = dst, a = a, b = b})
		case .ModI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, ModI{dst = dst, a = a, b = b})
		case .PrintI:
			reg := ExpectRegister(&lexer) or_return
			append(&ops, PrintI{reg = reg})
		case .LTI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, LTI{dst = dst, a = a, b = b})
		case .LEI:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, LEI{dst = dst, a = a, b = b})
		case .MovF:
			dst := ExpectRegister(&lexer) or_return
			val := ExpectToken(&lexer, .Float) or_return.data.(f64)
			append(&ops, MovF{dst = dst, val = val})
		case .AddF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, AddF{dst = dst, a = a, b = b})
		case .SubF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, SubF{dst = dst, a = a, b = b})
		case .MulF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, MulF{dst = dst, a = a, b = b})
		case .DivF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, DivF{dst = dst, a = a, b = b})
		case .LTF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, LTF{dst = dst, a = a, b = b})
		case .LEF:
			dst := ExpectRegister(&lexer) or_return
			a := ExpectRegister(&lexer) or_return
			b := ExpectRegister(&lexer) or_return
			append(&ops, LEF{dst = dst, a = a, b = b})
		case .PrintF:
			reg := ExpectRegister(&lexer) or_return
			append(&ops, PrintF{reg = reg})
		case:
			error = Error {
				location = token.location,
				message  = fmt.aprintf("Unexpected '%v'", token.kind),
			}
			return {}, error
		}
		if Lexer_PeekToken(lexer) or_return.kind == .EOF {
			break
		}
		ExpectToken(&lexer, .Newline) or_return
	}
	for name, list in pending_labels {
		for element in list {
			error = Error {
				location = {filepath = filepath},
				message = fmt.aprintf("Unable to find label ':%s'", name),
			}
			return {}, error
		}
	}
	return ops[:], nil
}

ExpectToken :: proc(lexer: ^Lexer, kind: TokenKind) -> (
	token: Token,
	error: Maybe(Error),
) {
	token = Lexer_NextToken(lexer) or_return
	if token.kind != kind {
		error = Error {
			location = token.location,
			message  = fmt.aprintf("Expected '%v', but got '%v'", kind, token.kind),
		}
		return {}, error
	}
	return token, nil
}

ExpectRegister :: proc(lexer: ^Lexer) -> (register: Register, error: Maybe(Error)) {
	token := Lexer_NextToken(lexer) or_return
	#partial switch token.kind {
	case .RZ:
		return .rz, nil
	case .RIP:
		return .rip, nil
	case .RFP:
		return .rfp, nil
	case .RSP:
		return .rsp, nil
	case .RA:
		return .ra, nil
	case .RT:
		return .rt, nil
	case .R1:
		return .r1, nil
	case .R2:
		return .r2, nil
	case .R3:
		return .r3, nil
	case .R4:
		return .r4, nil
	case .R5:
		return .r5, nil
	case .R6:
		return .r6, nil
	case .R7:
		return .r7, nil
	case .R8:
		return .r8, nil
	case:
		error = Error {
			location = token.location,
			message  = fmt.aprintf("Expected a register, but got '%v'", token.kind),
		}
		return {}, error
	}
}
