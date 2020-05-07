.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L5:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %edi
	movl	%edi, %edi
	leal	L0, %ebx
	movl	%ebx, 0(%edi)
	movl	$1000, 4(%edi)
	movl	%edi, (%esi)
	leal	L3, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	$4, %ebx
	imull	$0, %ebx
	addl	%ebx, %edi
	movl	%esi, (%edi)
	movl	-164(%ebp), %esi
	movl	$1, %eax
	jmp	L4
L4:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L3: 				# string literal
	.long 8				# length of string
	.string "Somebody"				# content of string
L2: 				# string literal
	.long 8				# length of string
	.string "Somebody"				# content of string
L1: 				# string literal
	.long 6				# length of string
	.string "Nobody"				# content of string
L0: 				# string literal
	.long 6				# length of string
	.string "Nobody"				# content of string
