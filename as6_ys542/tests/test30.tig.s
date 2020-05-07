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
	subl	$176, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L5:
	movl	$-164, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	$10, %edi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, (%ebx)
	movl	%ebx, (%esi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	$2, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L2
L1:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L2:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L1
L3:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	$1, %eax
	jmp	L4
L4:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
