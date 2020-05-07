.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$188, %esp
	movl	%esi, -172(%ebp)
	movl	%edi, -176(%ebp)
	movl	%ebx, -180(%ebp)
L4:
	movl	$0, -164(%ebp)
	movl	$0, -168(%ebp)
	movl	$100, %esi
	movl	-168(%ebp), %edi
	cmpl	%esi, %edi
	jle	L1
L0:
	movl	$1, %eax
	jmp	L3
L1:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	movl	$100, %esi
	movl	-168(%ebp), %edi
	cmpl	%esi, %edi
	jge	L0
L2:
	movl	-168(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -168(%ebp)
	jmp	L1
L3:
	movl	-172(%ebp), %esi
	movl	-176(%ebp), %edi
	movl	-180(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
