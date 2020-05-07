.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$176, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L215:
	movl	$8, -164(%ebp)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, 0(%esp)
	movl	$0, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L214
L214:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L217:
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	je	L211
L212:
	movl	$0, -164(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	%esi, -164(%ebp)
L209:
	movl	-164(%ebp), %esi
	movl	-164(%ebp), %edi
	cmpl	%esi, %edi
	jle	L210
L176:
	movl	$0, %esi
L213:
	movl	%esi, %eax
	jmp	L216
L211:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	call	L0
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L213
L210:
	movl	$0, %esi
	cmpl	%ebx, %esi
	je	L208
L207:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$1, (%edi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	addl	%edi, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$1, (%edi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$7, %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	subl	%edi, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$1, (%edi)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	8(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	-164(%ecx), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	movl	-4(%ebp), %edx # load pseudo-register
	addl	%esi, %edx
	movl	%edx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	movl	%edi, (%edx)
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$0, (%edi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	addl	%edi, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$0, (%edi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$7, %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	subl	%edi, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %edi
	movl	$0, (%edi)
L208:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	jmp	L209
L216:
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
	subl	$176, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L219:
	movl	$0, -164(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	%esi, -164(%ebp)
L108:
	movl	-164(%ebp), %esi
	movl	-164(%ebp), %edi
	cmpl	%esi, %edi
	jle	L109
L72:
	leal	L110, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %eax
	jmp	L218
L109:
	movl	$0, -164(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	%esi, -164(%ebp)
L104:
	movl	-164(%ebp), %esi
	movl	-164(%ebp), %edi
	cmpl	%esi, %edi
	jle	L105
L93:
	leal	L106, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	jmp	L108
L105:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	8(%ebp), %ebx
	movl	-164(%ebx), %ebx
	movl	%ebx, %ebx
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, %esi
	imull	$4, %esi
	addl	%esi, %ebx
	movl	(%ebx), %esi
	cmpl	%edi, %esi
	je	L96
L97:
	leal	L95, %esi
	movl	%esi, %esi
L98:
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	jmp	L104
L96:
	leal	L94, %esi
	movl	%esi, %esi
	jmp	L98
L218:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L111: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L110: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L107: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L106: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L100: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L99: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L95: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L94: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L89: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L88: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L84: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L83: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L79: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L78: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L74: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L73: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L71: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L70: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L64: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L63: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L59: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L58: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L53: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L52: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L48: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L47: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L43: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L42: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L38: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L37: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L36: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L35: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L29: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L28: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L24: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L23: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L18: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L17: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L13: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L12: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L8: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L7: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L3: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L2: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
