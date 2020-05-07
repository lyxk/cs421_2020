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
	subl	$180, %esp
	movl	%esi, -172(%ebp)
	movl	%edi, -176(%ebp)
	movl	%ebx, -180(%ebp)
L7:
	movl	$0, -164(%ebp)
	movl	$0, -168(%ebp)
	movl	$100, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jle	L4
L3:
	movl	$1, %eax
	jmp	L6
L4:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	movl	$100, %esi
	movl	-168(%ebp), %edi
	cmpl	%esi, %edi
	jge	L3
L5:
	movl	-168(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -168(%ebp)
	jmp	L4
L6:
	movl	-172(%ebp), %esi
	movl	-176(%ebp), %edi
	movl	-180(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
