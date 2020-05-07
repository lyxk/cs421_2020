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
	movl	$10, 4(%esp)
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
.globl	L0				# Linkable
.type	L0, @function
L0:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L7:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	je	L1
L2:
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	12(%ebp), %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, 4(%esp)
	call	L0
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, %esi
	imull	%edi, %esi
	movl	%esi, %esi
L3:
	movl	%esi, %eax
	jmp	L6
L1:
	movl	$1, %esi
	jmp	L3
L6:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
