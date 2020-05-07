.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$176, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L2:
	movl	$0, -164(%ebp)
	movl	%ebp, 0(%esp)
	movl	$2, 4(%esp)
	call	L0
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L1
L1:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L0				# Linkable
.type	L0, @function
L0:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L4:
	movl	12(%ebp), %esi
	movl	%esi, %eax
	jmp	L3
L3:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
