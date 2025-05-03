.ONESHELL:
CC = gcc
FLAGS = -Wall -fPIC -g

all : loader shellcode
loader : loader.c
	$(CC) $(FLAGS) loader.c -o loader
shellcode : shellcode.o
	MAIN_SYM_SPEC=$$(nm -SU shellcode.o | grep main)
	MAIN_SYM_OFFSET=$$(readelf -S shellcode.o | grep ' .text ' | awk '{print $$6}')
	MAIN_SYM_START=$$(echo $$MAIN_SYM_SPEC | awk '{print $$1}')
	MAIN_SYM_LENGTH=$$(echo $$MAIN_SYM_SPEC | awk '{print $$2}')

	echo "MAIN_SYM_START=$$MAIN_SYM_START"
	echo "MAIN_SYM_LENGTH=$$MAIN_SYM_LENGTH"
	echo "MAIN_SYM_OFFSET=$$MAIN_SYM_OFFSET"

	dd if=shellcode.o of=shellcode bs=1 \
		skip=$$((0x$$MAIN_SYM_START + 0x$$MAIN_SYM_OFFSET)) \
		count=$$((0x$$MAIN_SYM_LENGTH))
	rm shellcode.o
shellcode.o : shellcode.c
	$(CC) $(FLAGS) -c shellcode.c

.PHONY : clean
clean :
	- rm loader shellcode
	if [ -f shellcode.o ]; then rm shellcode.o; fi
