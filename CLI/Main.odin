package main

import "core:os"
import "core:fmt"

import "../../vm"

main :: proc() {
	if len(os.args) != 2 {
		fmt.eprintf("Usage: %s <filepath>\n", os.args[0])
		os.exit(1)
	}

	filepath := os.args[1]

	bytes, ok := os.read_entire_file(filepath)
	if !ok {
		fmt.printf("Unable to read file '%s'\n", filepath)
		os.exit(1)
	}
	defer delete(bytes)
	source := string(bytes)

	instructions, error := vm.Parse(filepath, source)
	defer delete(instructions)
	if error, ok := error.?; ok {
		fmt.printf("%s:%i:%i: %s\n", error.filepath, error.line, error.column, error.message)
		delete(error.message)
		os.exit(1)
	}

	when false {
		for op in instructions {
			fmt.println(op)
		}
		fmt.println()
	}

	machine := new(vm.Machine)
	defer free(machine)

	vm.Init(machine, instructions)
	vm.Exectute(machine)

	return
}
