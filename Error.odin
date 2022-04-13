package vm

Error :: struct {
	using location: SourceLocation,
	message:        string,
}
