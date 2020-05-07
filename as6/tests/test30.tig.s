.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
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
	movl	%esi, %esi
	movl	$2, %edi
	movl	%esi, 0(%esp)
	movl	%edi, 4(%esp)
	call	checkArrayBounds
	movl	%eax, %ebx
	movl	%esi, %esi
	movl	%edi, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	$1, %eax
	jmp	L0
L0:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
