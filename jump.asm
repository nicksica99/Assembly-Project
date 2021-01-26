	;; Name: Nick Sica
	;; File: jump.asm
	;; Email: nsica1@umbc.edu
	;; UMBC ID: PG29736
	;; Description: creates a new encrypted string based on the input and jump value given

	section .data

	;; messages to be printed out to the screen
jump_encrypt_msg:	db      "Jump encryption: ", 0
jump_msg_len:	        equ     $-jump_encrypt_msg

jump_invalid_msg:	db      "Invalid jump interval", 10
jump_invalid_len:	equ     $-jump_invalid_msg

new_line		db	10

	section .bss
	;; holds new encrypted string
temp_string:		resb	255


	section .text
	global 	jump

jump:

	;; clear registers 
	xor     rax, rax
	xor     r12, r12
	xor	rcx, rcx
	mov	r12, 255
	;; i created this because i noticed that if i did a jump on a long string then
	;; read in a new string and jumped that, the previous would still be stored 
	call	clear_string

	xor	rax, rax
	xor	r12, r12
	;; this checks if it is a one digit number or a two digit number
	cmp	bh, 10

	je	one_digit

	jmp	two_digit


clear_string:
	;; clears the string by giving every value a 0
	mov	[temp_string+rax], rcx

	inc	rax

	cmp	rax, r12
	jl	clear_string

	ret

one_digit:

	;; gets the decimal value of the one digit number and validates its in the range
	sub	bl, 48

	mov	dl, bl

	cmp	dl, 2
	jl	jump_invalid

	cmp	dl, r11b
	jg	jump_invalid

	jmp	jump_message

two_digit:

	;; gets the decimal value of the two digit number
	sub	bl, 48
	sub	bh, 48

	mov	al, bl
	mov	bl, 10
	mul	bl

	mov	dl, al

	;; validate it is in the range
	cmp	dl, r11b
	jg	jump_invalid

	jmp	jump_message

jump_invalid:

	;; prints the invalid messages 
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, jump_invalid_msg
	mov     rdx, jump_invalid_len
	syscall

	ret
	

jump_message:

	;; moves the jump value to r9
	xor	r9,  r9
	mov	r9,  rdx
	;; checks whether the length is even or odd
	call	even_odd
	
	xor	rax, rax	
	xor	rbx, rbx	; counter for temp position
	xor     rcx, rcx	; counter at what position in the message it is at (jump value increments)
	xor	r14, r14	;counter for the inner loop
	xor	r15, r15	;counter for outer loop
	
	
	xor 	r8,  r8
	
	mov	r8, r10


	add	r8, r9		; all of this code is getting a value for the inner loop
	dec	r8		;r8 will hold a value that is the length (depends on if even/odd)
	
	mov	rdx, 0          ; then r8 will be decremented, and divided by jump value
	mov	rax, r8
	div	r9

	mov	r8, rax
	;; clears rdx afterwards
	xor	rdx, rdx
	;; moves the jump value back into rdx
	mov	rdx, r9

	jmp	outer_loop

outer_loop:
	;; rdx holds the jump value, so r15 should equal the jump value to finish the loop
	cmp	r15, rdx
	je	jump_final
	
	
inner_loop:
	;; gets the character and moves it into the new string
	mov	r9b, [rdi + rcx]
	mov	[temp_string + rbx], r9b
	;; increments
	inc	r14
	inc	rbx
	
	add	cl, dl
	;; if r14, r8 equal that means that r14 has hit the max number of characters it can hold
	;; that row, so it must be subtracted 
	cmp	r14, r8
	je	sub_loop

	;; otherwise keep going until it hits the cmp
	jmp	inner_loop


sub_loop:
	;; subtracts the counter back down to 1/2/3 etc
	sub	rcx, r10
	inc	rcx

	;; gets the counter for num characters back to 0 and increments number of rows done
	xor	r14, r14
	inc	r15

	;; goes back to outer loop
	jmp	outer_loop


even_odd:
	;; i noticed that if the length is an even value you dont need to decrement the value
	;; and it works fine, if it is odd decrementing and then looping through makes it work
	xor	rax, rax
	xor	rdx, rdx
	xor	r8, r8
	mov	r8, 2
	;; checks if it is even or odd using division
	mov	rdx, 0
	mov	rax, r10
	div	r8
	;; if it is even rdx should have nothing in it otherwise decrement the length
	cmp	rdx, 0
	je	even


	dec	r10
	ret


even:
	;; if its even just return
	ret


jump_final:
	;; prints the new encrypted string
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, jump_encrypt_msg
	mov	rdx, jump_msg_len
	syscall

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, temp_string
	mov     rdx, 255
	syscall

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, new_line
	mov	rdx, 1
	syscall
	
	ret
