.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L10:
	movl	$0, %esi
	movl	$1, %edi
	cmpl	%esi, %edi
	je	L6
L7:
	movl	$0, %esi
	movl	$1, %edi
	cmpl	%esi, %edi
	jne	L3
L4:
	movl	$8, %esi
L5:
	movl	%esi, %esi
L8:
	movl	$1, %eax
	jmp	L9
L6:
	movl	$1, %esi
	movl	$1, %edi
	cmpl	%esi, %edi
	je	L0
L1:
	movl	$6, %esi
L2:
	movl	%esi, %esi
	jmp	L8
L0:
	movl	$5, %esi
	jmp	L2
L3:
	movl	$7, %esi
	jmp	L5
L9:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
