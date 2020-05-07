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
	movl	$1, %esi
	movl	$2, %edi
	movl	$3, %ebx
	movl	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$5, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	$6, %ecx
	movl	%ecx, -12(%ebp) # save pseudo-register
	movl	$7, %ecx
	movl	%ecx, -16(%ebp) # save pseudo-register
	movl	$8, %ecx
	movl	%ecx, -20(%ebp) # save pseudo-register
	movl	$9, %ecx
	movl	%ecx, -24(%ebp) # save pseudo-register
	movl	$10, %ecx
	movl	%ecx, -28(%ebp) # save pseudo-register
	movl	$11, %ecx
	movl	%ecx, -32(%ebp) # save pseudo-register
	movl	$12, %ecx
	movl	%ecx, -36(%ebp) # save pseudo-register
	movl	$13, %ecx
	movl	%ecx, -40(%ebp) # save pseudo-register
	movl	$14, %ecx
	movl	%ecx, -44(%ebp) # save pseudo-register
	movl	$15, %ecx
	movl	%ecx, -48(%ebp) # save pseudo-register
	movl	-48(%ebp), %ecx # load pseudo-register
	addl	$16, %ecx
	movl	%ecx, -48(%ebp) # save pseudo-register
	movl	-48(%ebp), %ecx # load pseudo-register
	movl	-44(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -44(%ebp) # save pseudo-register
	movl	-44(%ebp), %ecx # load pseudo-register
	movl	-40(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -40(%ebp) # save pseudo-register
	movl	-40(%ebp), %ecx # load pseudo-register
	movl	-36(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -36(%ebp) # save pseudo-register
	movl	-36(%ebp), %ecx # load pseudo-register
	movl	-32(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -32(%ebp) # save pseudo-register
	movl	-32(%ebp), %ecx # load pseudo-register
	movl	-28(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -28(%ebp) # save pseudo-register
	movl	-28(%ebp), %ecx # load pseudo-register
	movl	-24(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -24(%ebp) # save pseudo-register
	movl	-24(%ebp), %ecx # load pseudo-register
	movl	-20(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -20(%ebp) # save pseudo-register
	movl	-20(%ebp), %ecx # load pseudo-register
	movl	-16(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -16(%ebp) # save pseudo-register
	movl	-16(%ebp), %ecx # load pseudo-register
	movl	-12(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -12(%ebp) # save pseudo-register
	movl	-12(%ebp), %ecx # load pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	addl	%ecx, %edx
	movl	%edx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	addl	%ebx, %edi
	addl	%edi, %esi
	movl	$1, %eax
	jmp	L0
L0:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
