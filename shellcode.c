int main() {
	// Pre-known offsets, fetched from objdump output for loader
	long CALLER_INSTRUCTION_OFFSET = 0x12f9;
	long PRINTF_OFFSET = 0x10c0;
	void *caller_instruction;
	void *base_addr;
	int (*printf_plt)(char *, ...);

	__asm__ (
		"movq 8(%%rbp), %0"
		: "=r" (caller_instruction)
	);
	
	// Now we can find out the process's base address
	base_addr = caller_instruction - CALLER_INSTRUCTION_OFFSET;	
	printf_plt = base_addr + PRINTF_OFFSET;
	printf_plt("I made it, mom!");

	return 0;
}
