	;; Name: Nick Sica
	;; File: split.asm
	;; Email: nsica1@umbc.edu
	;; UMBC ID: PG29736
	;; Description: Gets a value from a user and splits the string at that value
	;; and prints that new string in front of the other string

	extern printf
	section .data

	
	;; all the necessary displays 
split_func_msg:	         	db      "Split encryption: ", 0
split_func_len:	         	equ     $-split_func_msg

split_invalid_msg:		db      "invalid split value", 10
split_invalid_len:	      	equ     $-split_invalid_msg

	;; formatted using printf
split_invalid_fmt:	      	db      "Split value has to be less than message length. Current message length is = %ld", 10

new_line:			db	10
	section .bss

	;; new variables to hold new message
temp_split:		resb	255

char_buff		resb	1

	section .text

	global split

	;; rdi- holds the message
	;; r11 - holds the length of the message
	;; rbx - holds the value at which to split 

split:
	;; clears the string to make sure nothing is in it at the beginning
	xor	rax, rax
	xor	rcx, rcx
	xor	r12, r12
	mov	r12, 255

	call 	clear_string
	
	;; in the registers the one digit numbers woudld have an a (10) in
	;; the bh register while the two digit numbers would make up the bh
	;; and bl registers, this just figures out which is which
	cmp	bh, 10
	je	one_digit
	
	jmp	two_digit


clear_string:
	;; goes through the string and clears it with 0s
	mov	[temp_split+rax], rcx

	inc	rax

	cmp	rax, r12
	jl	clear_string

	ret

one_digit:

	;; if one digit, it subtracts 48 and move it. 
	sub	bl, 48
	
	mov	dl, bl

	;; gets the length and compares it to the value to split at
	mov	r14, r11
	
	cmp	dl, r11b 
	jg	split_invalid

	jmp 	get_split

two_digit:

	;; subtracts 48 to get the real numbers
	sub	bl, 48
	sub	bh, 48

	;; multiplies the value by the number so it gets the right number
	mov	al, bl
	mov	bl, 10
	mul	bl

	mov	dl, al
	
	mov	r14, r11
	;; checks whether the number is invalid or not 
	cmp     dl, r11b
	jg      split_invalid

	jmp     get_split

split_invalid:
	;; prints the invalid message statements 
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, split_invalid_msg
	mov	rdx, split_invalid_len
	syscall
	
	mov	rdi, split_invalid_fmt
	mov	rsi, r14
	mov	rax, 0
	call 	printf
	
	ret
	
get_split:
	;; xors and increments r14 back to the correct length (was decremented for the invalid msg)
	xor 	rax, rax
	add	r14, 2

	;; this is to get the difference of length and split
	xor	r12, r12
	mov	r12b, r14b
	sub	r12b, dl
	
	sub	r12b, 2

	;; mov the split value into r13 
	xor	r13, r13
	mov	r13b, dl
	

	jmp	split_loop

split_loop:
	;; gets the characters from the split on and moves them to temp variable 
	mov	r9b, [rdi + r13]
	mov	[temp_split+rax], r9b

	;; increments and compares if less, then keep going
	inc	rax
	inc	r13

	cmp	r13, r14
	jle	split_loop

	;; xors to get 0 values and make sure nothing is in the registers
	xor	rcx, rcx
	xor	r10, r10
	jmp	split_final
	

split_final:	
	;; moves the rcx value into r10b and gets the specific character
	mov	r10b, cl
	add	rdi, r10
	mov	al, [rdi]
	mov	[temp_split+r12], al
	;; resets rdi to make sure characters are correct
	sub	rdi, r10
	;; increments
	inc	rcx
	inc 	r12
	;; compares and if less than or equal  keep going
	cmp	cl, dl
	jle	split_final

	jmp	print_split

print_split:
	;; prints out split message
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, split_func_msg
	mov	rdx, split_func_len 
	syscall
	
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, temp_split
	mov	rdx, 255
	syscall

	mov     rax, 1
	mov     rdi, 1
	mov     rsi, new_line
	mov     rdx, 1
	syscall

	ret
	
	
	
	
