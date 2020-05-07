.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$192, %esp
	movl	%esi, -176(%ebp)
	movl	%edi, -180(%ebp)
	movl	%ebx, -184(%ebp)
L56:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-168, %esi
	movl	%esi, %esi
	movl	%ebp, 0(%esp)
	call	L22
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-172, %esi
	movl	%esi, %esi
	movl	%ebp, %edi
	addl	$-164, %edi
	movl	%edi, %edi
	call	getch
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%ebp, 0(%esp)
	call	L22
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	movl	%ebp, 0(%esp)
	movl	-168(%ebp), %edi
	movl	%edi, 4(%esp)
	movl	-172(%ebp), %edi
	movl	%edi, 8(%esp)
	call	L23
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, 0(%esp)
	movl	%edi, 4(%esp)
	call	L25
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L55
L55:
	movl	-176(%ebp), %esi
	movl	-180(%ebp), %edi
	movl	-184(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L25				# Linkable
.type	L25, @function
L25:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L58:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	je	L52
L53:
	movl	8(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %edi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L24
	movl	%eax, %esi
	leal	L51, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	8(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %edi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$1, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L25
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
L54:
	movl	%esi, %eax
	jmp	L57
L52:
	leal	L50, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L54
L57:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L51: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L50: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
.globl	L24				# Linkable
.type	L24, @function
L24:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L60:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jl	L47
L48:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jg	L44
L45:
	leal	L43, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
L46:
	movl	%esi, %esi
L49:
	movl	%esi, %eax
	jmp	L59
L47:
	leal	L42, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%ebp, 0(%esp)
	movl	$0, %esi
	movl	12(%ebp), %edi
	subl	%edi, %esi
	movl	%esi, 4(%esp)
	call	L38
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L49
L44:
	movl	%ebp, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, 4(%esp)
	call	L38
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L46
L59:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L43: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L42: 				# string literal
	.long 1				# length of string
	.string "-"				# content of string
.globl	L38				# Linkable
.type	L38, @function
L38:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L62:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jg	L40
L41:
	movl	$0, %eax
	jmp	L61
L40:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	$0, %edx
	movl	12(%ebp), %esi
	movl	%esi, %eax
	movl	$10, %esi
	idivl	%esi
	movl	%eax, 4(%esp)
	call	L38
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edx
	movl	12(%ebp), %edi
	movl	%edi, %eax
	movl	$10, %edi
	idivl	%edi
	movl	%eax, %edi
	imull	$10, %edi
	subl	%edi, %esi
	movl	%esi, %esi
	leal	L39, %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, %esi
	addl	%edi, %esi
	movl	%esi, 0(%esp)
	call	chr
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L41
L61:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L39: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
.globl	L23				# Linkable
.type	L23, @function
L23:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L64:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	je	L35
L36:
	movl	$0, %esi
	movl	16(%ebp), %edi
	cmpl	%esi, %edi
	je	L32
L33:
	movl	12(%ebp), %esi
	movl	%esi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, %esi
	movl	16(%ebp), %edi
	movl	%edi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %edi
	movl	16(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	cmpl	%edi, %esi
	jl	L29
L30:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %edi
	addl	$0, %edi
	movl	%edi, %edi
	movl	16(%ebp), %ebx
	movl	%ebx, 0(%esp)
	call	checkNilRecord
	movl	%eax, %ebx
	movl	16(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, (%edi)
	movl	%esi, %edi
	addl	$4, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, %ebx
	movl	12(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	16(%ebp), %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	checkNilRecord
	movl	%eax, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	%ebx, 0(%esp)
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 4(%esp)
	movl	16(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 8(%esp)
	call	L23
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
L31:
	movl	%esi, %esi
L34:
	movl	%esi, %esi
L37:
	movl	%esi, %eax
	jmp	L63
L35:
	movl	16(%ebp), %esi
	movl	%esi, %esi
	jmp	L37
L32:
	movl	12(%ebp), %esi
	movl	%esi, %esi
	jmp	L34
L29:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %edi
	addl	$0, %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	movl	%ebx, 0(%esp)
	call	checkNilRecord
	movl	%eax, %ebx
	movl	12(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, (%edi)
	movl	%esi, %edi
	addl	$4, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, %ebx
	movl	12(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	checkNilRecord
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%ebx, 0(%esp)
	movl	12(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 4(%esp)
	movl	16(%ebp), %ebx
	movl	%ebx, 8(%esp)
	call	L23
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
	jmp	L31
L63:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L22				# Linkable
.type	L22, @function
L22:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$188, %esp
	movl	%esi, -172(%ebp)
	movl	%edi, -176(%ebp)
	movl	%ebx, -180(%ebp)
L66:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	$4, 0(%esp)
	call	allocRecord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	$0, 0(%edi)
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-168, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	-164(%ebp), %edi
	movl	%edi, 4(%esp)
	call	L0
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	-164(%ebp), %esi
	movl	%esi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %esi
	movl	$0, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	cmpl	%esi, %edi
	je	L27
L26:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	-168(%ebp), %edi
	movl	%edi, 0(%esi)
	movl	%esi, %edi
	addl	$4, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, 0(%esp)
	call	L22
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
L28:
	movl	%esi, %eax
	jmp	L65
L27:
	movl	$0, %esi
	jmp	L28
L65:
	movl	-172(%ebp), %esi
	movl	-176(%ebp), %edi
	movl	-180(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L0				# Linkable
.type	L0, @function
L0:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L68:
	movl	$0, -164(%ebp)
	movl	%ebp, 0(%esp)
	call	L2
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, 0(%esp)
	call	checkNilRecord
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	%esi, %esi
	movl	%ebp, 0(%esp)
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, 4(%esp)
	call	L1
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, 0(%esp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%edi, %esi
	je	L19
L21:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	imull	$10, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	-164(%ebx), %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, %edi
	addl	%ebx, %edi
	movl	%edi, %edi
	leal	L20, %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, %edi
	subl	%ebx, %edi
	movl	%edi, (%esi)
	movl	8(%ebp), %esi
	movl	%esi, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, 0(%esp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%edi, %esi
	jne	L21
L19:
	movl	-164(%ebp), %esi
	movl	%esi, %eax
	jmp	L67
L67:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L20: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
.globl	L2				# Linkable
.type	L2, @function
L2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L70:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	leal	L10, %esi
	movl	%esi, 4(%esp)
	call	stringEqual
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%edi, %esi
	je	L13
L12:
	movl	$1, %esi
L14:
	movl	$0, %edi
	cmpl	%edi, %esi
	je	L17
L18:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	%esi, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	leal	L10, %esi
	movl	%esi, 4(%esp)
	call	stringEqual
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%edi, %esi
	jne	L12
L13:
	movl	$1, %esi
	movl	8(%ebp), %edi
	movl	8(%edi), %edi
	movl	-164(%edi), %edi
	movl	%edi, 0(%esp)
	leal	L11, %edi
	movl	%edi, 4(%esp)
	call	stringEqual
	movl	%eax, %edi
	movl	%edi, %edi
	movl	$0, %ebx
	cmpl	%ebx, %edi
	je	L16
L15:
	movl	%esi, %esi
	jmp	L14
L16:
	movl	$0, %esi
	jmp	L15
L17:
	movl	$0, %eax
	jmp	L69
L69:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L11: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L10: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L72:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	call	ord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	leal	L3, %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	cmpl	%edi, %esi
	jge	L5
L6:
	movl	$0, %esi
L7:
	movl	%esi, %eax
	jmp	L71
L5:
	movl	$1, %esi
	movl	8(%ebp), %edi
	movl	8(%edi), %edi
	movl	-164(%edi), %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, %edi
	leal	L4, %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jle	L8
L9:
	movl	$0, %esi
L8:
	movl	%esi, %esi
	jmp	L7
L71:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L4: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L3: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
