record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
L10: 				# string literal
	.long 2				# length of string
	.string " O"				# content of string
L11: 				# string literal
	.long 2				# length of string
	.string " ."				# content of string
L19: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L24: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -172(%ebp)
	movl	%edi, -176(%ebp)
	movl	%ebx, -180(%ebp)
L80:
	movl	$0, -164(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jle	L22
L21:
	leal	L24, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %eax
	jmp	L79
L22:
	movl	$0, -168(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jle	L17
L16:
	leal	L19, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	-164(%ebp), %edi
	cmpl	%esi, %edi
	jge	L21
L23:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	jmp	L22
L17:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	-172(%edi), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	movl	%ebx, %ebx
	movl	(%edi), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L6
L5:
	leal	array_error, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
L6:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L5
L7:
	movl	-168(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	$1, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	addl	%ebx, %edx
	movl	%edx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %edi
	je	L8
L9:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L12
L13:
	leal	L11, %esi
	movl	%esi, %esi
L14:
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	-168(%ebp), %edi
	cmpl	%esi, %edi
	jge	L16
L18:
	movl	-168(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -168(%ebp)
	jmp	L17
L8:
	movl	$1, %esi
	jmp	L9
L12:
	leal	L10, %esi
	movl	%esi, %esi
	jmp	L14
L79:
	movl	-172(%ebp), %esi
	movl	-176(%ebp), %edi
	movl	-180(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L2				# Linkable
.type	L2, @function
L2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L82:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	je	L25
L26:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L76
L77:
	movl	$0, -164(%ebp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jle	L74
L73:
	movl	$0, %esi
L78:
	movl	%esi, %eax
	jmp	L81
L25:
	movl	$1, %esi
	jmp	L26
L76:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	call	L1
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L78
L74:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	-168(%edi), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	movl	%ebx, %ebx
	movl	(%edi), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L29
L28:
	leal	array_error, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
L29:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L28
L30:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	$1, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	addl	%ebx, %edx
	movl	%edx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %edi
	je	L31
L32:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L38
L39:
	movl	$0, %esi
L40:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L46
L47:
	movl	$0, %esi
L48:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L70
L71:
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, %esi
	subl	$1, %esi
	movl	-164(%ebp), %edi
	cmpl	%esi, %edi
	jge	L73
L75:
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, -164(%ebp)
	jmp	L74
L31:
	movl	$1, %esi
	jmp	L32
L38:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	-176(%edi), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	movl	%ebx, %ebx
	movl	12(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	%ebx, %ebx
	movl	(%edi), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L34
L33:
	leal	array_error, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
L34:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L33
L35:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	$1, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	addl	%ebx, %edx
	movl	%edx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %edi
	je	L36
L37:
	movl	%esi, %esi
	jmp	L40
L36:
	movl	$1, %esi
	jmp	L37
L46:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	-180(%edi), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	movl	%ebx, %ebx
	addl	$7, %ebx
	movl	%ebx, %ebx
	movl	12(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	subl	%ecx, %ebx
	movl	%ebx, %ebx
	movl	(%edi), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L42
L41:
	leal	array_error, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
L42:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %ebx
	jl	L41
L43:
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	$1, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	addl	%ebx, %edx
	movl	%edx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	cmpl	%ecx, %edi
	je	L44
L45:
	movl	%esi, %esi
	jmp	L48
L44:
	movl	$1, %esi
	jmp	L45
L70:
	movl	8(%ebp), %esi
	movl	-168(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L50
L49:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L50:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L49
L51:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$1, (%esi)
	movl	8(%ebp), %esi
	movl	-176(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L53
L52:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L53:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L52
L54:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$1, (%esi)
	movl	8(%ebp), %esi
	movl	-180(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	addl	$7, %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	subl	%ebx, %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L56
L55:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L56:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L55
L57:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$1, (%esi)
	movl	8(%ebp), %esi
	movl	-172(%esi), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L59
L58:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L59:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L58
L60:
	movl	-164(%ebp), %ebx
	movl	%esi, %esi
	movl	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	addl	%edi, %edx
	movl	%edx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	%ebx, (%esi)
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	addl	$1, %esi
	movl	%esi, 4(%esp)
	call	L2
	movl	%eax, %esi
	movl	8(%ebp), %esi
	movl	-168(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L62
L61:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L62:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L61
L63:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$0, (%esi)
	movl	8(%ebp), %esi
	movl	-176(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L65
L64:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L65:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L64
L66:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$0, (%esi)
	movl	8(%ebp), %esi
	movl	-180(%esi), %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	addl	$7, %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	subl	%ebx, %edi
	movl	%edi, %edi
	movl	(%esi), %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jl	L68
L67:
	leal	array_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L68:
	movl	$0, %ebx
	cmpl	%ebx, %edi
	jl	L67
L69:
	movl	%esi, %esi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	$0, (%esi)
	jmp	L71
L81:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$200, %esp
	movl	%esi, -184(%ebp)
	movl	%edi, -188(%ebp)
	movl	%ebx, -192(%ebp)
L84:
	movl	$8, -164(%ebp)
	movl	$-168, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, (%ebx)
	movl	%ebx, (%esi)
	movl	$-172, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, (%ebx)
	movl	%ebx, (%esi)
	movl	$-176, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, %edi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, (%ebx)
	movl	%ebx, (%esi)
	movl	$-180, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	-164(%ebp), %ebx
	addl	%ebx, %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, %edi
	movl	$1, %ebx
	addl	%edi, %ebx
	movl	%ebx, 0(%esp)
	movl	$0, 4(%esp)
	call	initArray
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, (%ebx)
	movl	%ebx, (%esi)
	movl	%ebp, 0(%esp)
	movl	$0, 4(%esp)
	call	L2
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L83
L83:
	movl	-184(%ebp), %esi
	movl	-188(%ebp), %edi
	movl	-192(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
