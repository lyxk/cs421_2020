.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L3:
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
	movl	-164(%ebp), %esi
	movl	%esi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %esi
	leal	L1, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	%esi, (%edi)
	movl	-164(%ebp), %esi
	movl	$1, %eax
	jmp	L2
L2:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L1:				# string literal: "Somebody"
	.long 8				# string's length
	.byte 83, 111, 109, 101, 98, 111, 100, 121				# string's bytes
L0:				# string literal: "Nobody"
	.long 6				# string's length
	.byte 78, 111, 98, 111, 100, 121				# string's bytes
