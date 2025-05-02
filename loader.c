#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>

/* Read the contents of the binary file into a pre-allocated buffer. */
static bool load_shellcode_to_buffer(char *filename, void *buffer, size_t size) {
	int fd = open(filename, O_RDONLY);
	if (fd == -1) {
		perror("open");
		return false;
	}
	if (read(fd, buffer, size) == -1) {
		perror("read");
		return false;
	}
	return true;
}

/* Give the allocated shellcode buffer execution permissions and call it. */
static bool execute_shellcode_buffer(void *instructions, size_t length) {
	if (mprotect(instructions, length, PROT_READ | PROT_EXEC) == -1) return false;
	int (*callable_shellcode)();
	callable_shellcode = instructions;
	int result = callable_shellcode();
	printf("Shellcode returned %d\n", result);
	return true;
}

int main(int argc, char *argv[]) {
	if (argc != 2) {
		fprintf(stderr, "%s: invalid syntax\n", argv[0]);
		goto failed;
	}		
	const long BUF_SIZE = sysconf(_SC_PAGE_SIZE);
	void *shellcode = aligned_alloc(BUF_SIZE, BUF_SIZE);  // One page-size long buffer, aligned to page size
	if (!load_shellcode_to_buffer(argv[1], shellcode, BUF_SIZE)) goto failed; 
	if (!execute_shellcode_buffer(shellcode, BUF_SIZE)) goto failed;

	return 0;
failed:
	return -1;
}
