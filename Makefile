.ONESHELL:
CC = gcc
FLAGS = -Wall -fPIC -g

all : loader shellcode
loader : loader.c
	$(CC) $(FLAGS) loader.c -o loader
shellcode : shellcode_elf
	MAIN_SYM_SPEC=$$(nm -SU shellcode_elf | grep main)
	MAIN_SYM_START=$$(echo $$MAIN_SYM_SPEC | awk '{print $$1}')
	MAIN_SYM_LENGTH=$$(echo $$MAIN_SYM_SPEC | awk '{print $$2}')
	dd if=shellcode_elf of=shellcode bs=1 skip=$$((0x$$MAIN_SYM_START)) count=$$((0x$$MAIN_SYM_LENGTH))
	rm shellcode_elf
shellcode_elf : shellcode.c
	$(CC) $(FLAGS) shellcode.c -o shellcode_elf

.PHONY : clean
clean :
	-rm loader shellcode
