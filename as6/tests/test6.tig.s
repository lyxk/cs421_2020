.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L5:
	movl	%ebp, 0(%esp)
	movl	$0, 4(%esp)
	leal	L3, %esi
	movl	%esi, 8(%esp)
	call	L0
	movl	%eax, %esi
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
	.long 4				# length of string
	.string "str2"				# content of string
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
	movl	%esi, 4(%esp)
	leal	L2, %esi
	movl	%esi, 8(%esp)
	call	L0
	movl	%eax, %esi
	movl	%esi, %eax
	jmp	L6
L6:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L2: 				# string literal
	.long 3				# length of string
	.string "str"				# content of string
.globl	L0				# Linkable
.type	L0, @function
L0:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L9:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	%esi, %eax
	jmp	L8
L8:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
