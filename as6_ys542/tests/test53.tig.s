record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L17:
	movl	$0, %esi
	movl	$0, %edi
	movl	$1, %ebx
	cmpl	%edi, %ebx
	je	L1
L2:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L13
L14:
	movl	$0, %esi
	movl	$0, %edi
	movl	$1, %ebx
	cmpl	%edi, %ebx
	jne	L8
L9:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L10
L11:
	movl	$8, %esi
L12:
	movl	%esi, %esi
L15:
	movl	$1, %eax
	jmp	L16
L1:
	movl	$1, %esi
	jmp	L2
L13:
	movl	$0, %esi
	movl	$1, %edi
	movl	$1, %ebx
	cmpl	%edi, %ebx
	je	L3
L4:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L5
L6:
	movl	$6, %esi
L7:
	movl	%esi, %esi
	jmp	L15
L3:
	movl	$1, %esi
	jmp	L4
L5:
	movl	$5, %esi
	jmp	L7
L8:
	movl	$1, %esi
	jmp	L9
L10:
	movl	$7, %esi
	jmp	L12
L16:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
