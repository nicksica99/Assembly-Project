;;;  Name: Nick Sica
;;;  File: main.asm
;;;  UMBC EMail: nsica1@umbc.edu
;;;  UMBC ID: PG29736
;;;  Description: Displays a menu for the user and takes in the input
;;;  based on the user input, it can display the current message, read a new message
;;;  do a split or jump encrypt.
	
	extern	printf
	extern	validate
	extern  split
	extern 	square
	extern 	jump
	
	section .data

	;; all the messages that were necessary
welcome:	        db      "Encryption menu options: ", 10
welcome_len:	        equ     $-welcome

display_msg:		db      "d - display current message", 10
display_len:	        equ     $-display_msg

read_msg:	        db      "r - read new message", 10
read_len:		equ     $-read_msg

split_msg:		db      "s - split encrypt", 10
split_len:	        equ     $-split_msg

jump_msg:		db      "j - jump encrypt", 10
jump_len:	        equ     $-jump_msg

quit_msg:		db      "q - quit program", 10
quit_len:		equ     $-quit_msg

choice_msg:		db      "enter option letter -> ", 0
choice_len:		equ     $-choice_msg

current_msg:		db      "Current message: ", 0
current_len:	        equ     $-current_msg

enter_new_msg:		db      "Enter new message: ", 0
enter_new_len:		equ     $-enter_new_msg

invalid_msg:		db      "Invalid option, try again", 10
invalid_msg_len:	equ     $-invalid_msg

goodbye_msg:		db      "Goodbye!", 10
goodbye_len:		equ     $-goodbye_msg

invalid_new_msg:	db      "Invalid message, keeping current", 10
invalid_new_len:	equ     $-invalid_new_msg
	
split_enter_msg:	db      "Enter split value: ", 0
split_msg_len:		equ     $-split_enter_msg

initial_msg:		db	"This is the original message.", 10
initial_len:		db	30

	;; the max length was 255
max_len:		equ	255

	;; new line variable

new_line		db	10

	section .bss
	;; the variables that hold the message and length
overwrite_msg:		resb	255
start_len:		resb	255

	;; if user reads in a new message it goes here 
new_msg:		resb	255
new_msg_len		resb	255

	;; value at which user jumps at 
jump_val		resb	3
jump_choice		resb	4

	;; value at which user splits at 
split_val:		resb	3

	;; gets user choice 
user_choice:		resb	1
user_choice_len:	resb    10

	section .text

	global main

main:
	
	xor 	r10, r10

	;; checks to see if there is nothing in the message variable
	;; at this point, the original message is still in .data variable
	cmp	[overwrite_msg], r10
	je	start
	dec	r10

	;; gets length 
	mov	r10, [start_len]

	;; prints menu and gets the users input
	call 	print_menu

	call 	menu_select

	ret


start:
	;; calls loop to set original message into a longer variable
	xor     rax, rax
	xor 	rsi, rsi
	mov     r8b, [initial_len]

	call    start_loop
	
	jmp 	main

	
start_loop:
	;; gets the characters one by one from initial_msg and puts them in longer variable
	mov     r11b, [initial_msg + rax]
	mov     [overwrite_msg+rax], r11

	inc     rax

	;; condition is based on the length of the original message
	cmp     al, r8b

	;; loop
	jle     start_loop

	;; rax was 31 but length is 30, so i decrement (new line character was added on)
	dec	rax
	
	mov	[start_len], rax
	ret

print_menu:	
	
	;; prints the welcome message
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, welcome
	mov     rdx, welcome_len
	syscall

	;; prints display message
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, display_msg
	mov     rdx, display_len
	syscall

	;; prints read message
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, read_msg
	mov     rdx, read_len
	syscall

	;prints the split message
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, split_msg
	mov     rdx, split_len
	syscall

	;prints the jump message
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, jump_msg
	mov     rdx, jump_len
	syscall

	;prints the quit message
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, quit_msg
	mov     rdx, quit_len
	syscall

	;prompts the user for an input
	mov     rax, 1	
	mov     rdi, 1
	mov     rsi, choice_msg
	mov     rdx, choice_len
	syscall

	;takes in the input
	mov     rax, 0		
	mov     rdi, 0
	mov     rsi, user_choice
	syscall

	;stores the length of the menu choice
	mov     [user_choice_len], rax 

	ret


menu_select:

	xor	al, al
	xor 	bl, bl

	;; code that makes sure the user entered at most one letter 
	xor	r15, r15
	mov	r15, [user_choice_len]
	cmp	r15, 2
	jnz	invalid_input

	;; stores menu choice 
	mov	al, [user_choice]


display_check:
	;; checks to make sure user entered a d.
	;; if not it moves on, if so, it calls display
	mov	bl, 'd'
	cmp 	al, bl
	jne	read_check

	call 	display

	jmp 	main

read_check:
	;; checks to make sure user entered a r
	;; if not it moves on, if so, it calls read
	mov	bl, 'r'
	cmp 	al, bl
	jne	split_check

	call	read

	jmp 	main

split_check:
	;;  checks to make sure user entered a s.
	;;  if not it moves on, if so, it calls split
	mov	bl, 's'
	cmp	al, bl
	jne	jump_check

	call 	split_message

	jmp 	main

jump_check:
;;;  checks to make sure user entered a j.
;;;  if not it moves on, if so, it calls jump
	mov	bl, 'j'
	cmp	al, bl
	jne	quit_check

	call	jump_encrypt

	jmp	main

quit_check:
;;;  checks to make sure user entered a q.
;;;  if not it moves on, if so, it calls quit
	mov	bl, 'q'
	cmp	al, bl
	jne	invalid_input

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, goodbye_msg
	mov	rdx, goodbye_len
	syscall

	ret

invalid_input:
	;; prints invalid input message
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, invalid_msg
	mov	rdx, invalid_msg_len
	syscall

	jmp 	main

display:
	;; just to make sure that r10 holds correct length 
	mov	r10, [start_len]

	;; prints the current message
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, current_msg
	mov	rdx, current_len
	syscall

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, overwrite_msg
	mov	rdx, r10
	syscall

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, 10
	mov	rdx, 1
	syscall

	ret

read:
	;; prints enter new message input
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, enter_new_msg
	mov	rdx, enter_new_len
	syscall
	
	;; gets new message
	mov	rax, 0
	mov	rdi, 0
	mov	rsi, new_msg
	mov	rdx, 255
	syscall

	;; puts the length into variable
	mov	[new_msg_len], rax

	xor	r15, r15

	;; gets first character
	mov	al, [new_msg+r15]
	;; gets length, subtracts 2 so it drops the new line and enter
	mov	r11, [new_msg_len]
	sub	r11, 2
	;; gets last character
	mov	bl, [new_msg+r11]
	;; validates
	call 	validate
	;; if valid, it overwrites
	cmp	rax, 1
	jz 	overwrite
	jnz	invalid_message

	jmp	read_end

	ret
read_end:	
	;; just return 
	ret

invalid_message:
	;; prints invalid message 
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, invalid_new_msg
	mov	rdx, invalid_new_len
	syscall
	
	jmp	read_end


overwrite:
	;; calls clear and then the loop, this just xors everything
	mov	rsi, [start_len]
	mov	r15, [new_msg_len]
	
	xor 	rax, rax
	xor	r11, r11
	xor 	r12, r12
	
	call 	clear

	call 	overwrite_loop 
	
	

	jmp	read_end

overwrite_loop:
	;; goes through the message and puts the new message in
	;; goes character by character
	mov	r14, [new_msg+r12]
	mov	[overwrite_msg+r12], r14

	add	r12, 8
	;; compares lengths
	cmp	r15, r12
	ja	overwrite_loop
	;; when finished it updates the other variables
	mov	r13, [new_msg_len]
	mov	[start_len], r13

	xor	rsi, rsi
	ret
clear:
	;; puts 0s throughout the entire message
	mov	[overwrite_msg + rax], r11
	inc	rax

	;; loop condition
	cmp	rax, rsi
	jle	clear

	ret

split_message:
	;; prints and gets user input for split value
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, split_enter_msg
	mov	rdx, split_msg_len
	syscall

	mov	rax, 0
	mov	rdi, 0
	mov	rsi, split_val
	mov	rdx, 3
	syscall

	call	display
	;; gets all the variables and calls the split file
	mov	rdi, overwrite_msg
	
	xor	r11,  r11
	mov     r11b, [start_len]
	dec     r11b
	
	mov	rbx, [split_val]

	call 	split
	ret

		
jump_encrypt:
	;; just clearing some variables
	xor	rdi, rdi
	xor	r9, r9

	;; dec so it doesnt include the enter key
	mov	r9, [start_len]
	dec	r9

	;; calls square and gets the square root
	mov	rdi, r9
	call 	square
	
	mov	[jump_val], rax

	xor	rsi, rsi
	;; gets user input for jump vlaue
	mov	rax, 0
	mov	rdi, 0
	mov	rsi, jump_choice
	mov	rdx, 4
	syscall

	call	display
	;; calls jump file 
	mov	rdi, overwrite_msg

	mov	r11, [jump_val]
	mov	r10, [start_len]
	
	mov	rbx, [jump_choice]

	call 	jump
	
	ret

