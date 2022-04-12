package vm

import "core:strconv"
import "core:unicode"
import "core:fmt"

Lexer :: struct {
	using location: SourceLocation,
	source:         string,
}

Lexer_Create :: proc(filepath, source: string) -> Lexer {
	return Lexer{
		location = {filepath = filepath, position = 0, line = 1, column = 1},
		source = source,
	}
}

Lexer_CurrentChar :: proc(lexer: Lexer) -> rune {
	if lexer.position < len(lexer.source) {
		return rune(lexer.source[lexer.position])
	} else {
		return 0
	}
}

Lexer_NextChar :: proc(lexer: ^Lexer) -> rune {
	current := Lexer_CurrentChar(lexer^)
	if current != 0 {
		lexer.position += 1
		lexer.column += 1
		if current == '\n' {
			lexer.line += 1
			lexer.column = 1
		}
	}
	return current
}

Lexer_NextToken :: proc(lexer: ^Lexer) -> (token: Token, error: Maybe(Error)) {
	for
	    unicode.is_white_space(Lexer_CurrentChar(lexer^)) && Lexer_CurrentChar(lexer^) != '\n' {
		Lexer_NextChar(lexer)
	}

	start_location := lexer.location
	chr := Lexer_NextChar(lexer)

	if chr == 0 {
		return Token{
			kind = .EOF,
			location = start_location,
			length = lexer.location.position - start_location.position,
		}, nil
	}

	if chr == '\n' {
		return Token{
			kind = .Newline,
			location = start_location,
			length = lexer.location.position - start_location.position,
		}, nil
	}

	if unicode.is_digit(chr) || chr == '_' {
		for
		    unicode.is_alpha(Lexer_CurrentChar(lexer^)) || unicode.is_digit(
			    Lexer_CurrentChar(lexer^),
		    ) || Lexer_CurrentChar(lexer^) == '.' || Lexer_CurrentChar(lexer^) == '_' {
			Lexer_NextChar(lexer)
		}
		string := lexer.source[start_location.position:lexer.position]
		int_value, int_ok := strconv.parse_u64_maybe_prefixed(string)
		if int_ok {
			return Token{
				kind = .Integer,
				location = start_location,
				length = lexer.location.position - start_location.position,
				data = int_value,
			}, nil
		}
		float_value, float_ok := strconv.parse_f64(string)
		if !float_ok {
			error = Error {
				location = start_location,
				message  = fmt.aprintf("Invalid number literal: '%s'", string),
			}
			return {}, error
		}
		return Token{
			kind = .Float,
			location = start_location,
			length = lexer.location.position - start_location.position,
			data = float_value,
		}, nil
	}

	if chr == ':' {
		for
		    unicode.is_alpha(Lexer_CurrentChar(lexer^)) || unicode.is_digit(
			    Lexer_CurrentChar(lexer^),
		    ) || Lexer_CurrentChar(lexer^) == '_' {
			Lexer_NextChar(lexer)
		}
		name := lexer.source[start_location.position + 1:lexer.position]
		return Token{
			kind = .Label,
			location = start_location,
			length = lexer.location.position - start_location.position,
			data = name,
		}, nil
	}

	if unicode.is_alpha(chr) || chr == '_' {
		for
		    unicode.is_alpha(Lexer_CurrentChar(lexer^)) || unicode.is_digit(
			    Lexer_CurrentChar(lexer^),
		    ) || Lexer_CurrentChar(lexer^) == '_' {
			Lexer_NextChar(lexer)
		}
		name := lexer.source[start_location.position:lexer.position]
		if kind, ok := token_kind_keywords[name]; ok {
			return Token{
				kind = kind,
				location = start_location,
				length = lexer.location.position - start_location.position,
			}, nil
		}
		return Token{
			kind = .Name,
			location = start_location,
			length = lexer.location.position - start_location.position,
			data = name,
		}, nil
	}

	error = Error {
		location = start_location,
		message  = fmt.aprintf("Unknown character: '%c'", chr),
	}
	return {}, error
}

Lexer_PeekToken :: proc(lexer: Lexer) -> (token: Token, error: Maybe(Error)) {
	copy := lexer
	return Lexer_NextToken(&copy)
}
