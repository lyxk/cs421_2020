record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L2:
	movl	$1, %eax
	jmp	L1
L1:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
