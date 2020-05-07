record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L7:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, 4(%esp)
	call	L2
	movl	%eax, %esi
	movl	$0, %eax
	jmp	L6
L6:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L3: 				# string literal
	.long 3				# length of string
	.string "str"				# content of string
L4: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
.globl	L2				# Linkable
.type	L2, @function
L2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L9:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	leal	L3, %esi
	movl	%esi, 4(%esp)
	movl	12(%ebp), %esi
	movl	%esi, 8(%esp)
	call	L1
	movl	%eax, %esi
	leal	L4, %esi
	movl	%esi, %eax
	jmp	L8
L8:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L5: 				# string literal
	.long 4				# length of string
	.string "str2"				# content of string
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L11:
	movl	%ebp, 0(%esp)
	leal	L5, %esi
	movl	%esi, 4(%esp)
	movl	$0, 8(%esp)
	call	L1
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L10
L10:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
