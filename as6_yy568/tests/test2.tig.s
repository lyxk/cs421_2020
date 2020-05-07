.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L1:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	$10, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	-164(%ebp), %esi
	movl	$1, %eax
	jmp	L0
L0:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
