	;; Name: Nick Sica
	;; File: validate.asm
	;; Email: nsica1@umbc.edu
	;; UMBC ID: PG29736
	;; Description: validates the user's message input

	section .text

	global validate

validate:
	;; checks capital letters first 
	cmp	al, 'A'
	jl	invalid

	cmp	al, 'Z'
	jg	invalid

	

	;; checks if message ends in the punctuation
	cmp 	bl, '!'
	je	valid

	cmp	bl, '?'
	je	valid

	cmp	bl, '.'
	je	valid

	jmp	invalid

valid:

	;; if the new message is valid it returns a 1
	xor	rax, rax
	mov	rax, 1

	ret

invalid:

	;; if the new message is invalid it returns a 0
	xor	rax, rax
	mov	rax, 0

	ret
