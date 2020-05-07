.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L113:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getchar
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	%ebp, 0(%esp)
	call	L68
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	%ebp, %edi
	addl	$-164, %edi
	movl	%edi, %edi
	call	getchar
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%ebp, 0(%esp)
	call	L68
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	movl	%ebp, 0(%esp)
	movl	-164(%ebp), %edi
	movl	%edi, 4(%esp)
	movl	-164(%ebp), %edi
	movl	%edi, 8(%esp)
	call	L69
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, 0(%esp)
	movl	%edi, 4(%esp)
	call	L71
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L112
L112:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L71				# Linkable
.type	L71, @function
L71:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L115:
L110:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$4, %edi
	imull	$0, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L70
	movl	%eax, %esi
	leal	L107, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$4, %edi
	imull	$1, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L71
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
L111:
	movl	%esi, %eax
	jmp	L114
L109:
	leal	L105, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L111
L114:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L108: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L107: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L106: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L105: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
.globl	L70				# Linkable
.type	L70, @function
L70:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L117:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jl	L102
L103:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jg	L99
L100:
	leal	L97, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
L101:
	movl	%esi, %esi
L104:
	movl	%esi, %eax
	jmp	L116
L102:
	leal	L95, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%ebp, 0(%esp)
	movl	$0, %esi
	movl	12(%ebp), %edi
	subl	%edi, %esi
	movl	%esi, 4(%esp)
	call	L84
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L104
L99:
	movl	%ebp, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, 4(%esp)
	call	L84
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L101
L116:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L98: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L97: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L96: 				# string literal
	.long 1				# length of string
	.string "-"				# content of string
L95: 				# string literal
	.long 1				# length of string
	.string "-"				# content of string
.globl	L84				# Linkable
.type	L84, @function
L84:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L119:
	movl	$0, %esi
	movl	12(%ebp), %edi
	cmpl	%esi, %edi
	jg	L93
L94:
	movl	$0, %eax
	jmp	L118
L93:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	$0, %edx
	movl	12(%ebp), %esi
	movl	%esi, %eax
	movl	$10, %esi
	idivl	%esi
	movl	%eax, 4(%esp)
	call	L84
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
	leal	L85, %edi
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
	jmp	L94
L118:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L92: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L91: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L90: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L89: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L88: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L87: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L86: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L85: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
.globl	L69				# Linkable
.type	L69, @function
L69:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L121:
L82:
L79:
	movl	16(%ebp), %esi
	movl	%esi, %esi
	movl	$4, %edi
	imull	$0, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	$4, %ebx
	imull	$0, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	cmpl	%esi, %edi
	jl	L75
L76:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	16(%ebp), %edi
	movl	%edi, %edi
	movl	$4, %ebx
	imull	$0, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	%edi, 0(%esi)
	movl	$4, %edi
	addl	%esi, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, 0(%esp)
	movl	12(%ebp), %ebx
	movl	%ebx, 4(%esp)
	movl	16(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 8(%esp)
	call	L69
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
L77:
	movl	%esi, %esi
L80:
	movl	%esi, %esi
L83:
	movl	%esi, %eax
	jmp	L120
L81:
	movl	16(%ebp), %esi
	movl	%esi, %esi
	jmp	L83
L78:
	movl	12(%ebp), %esi
	movl	%esi, %esi
	jmp	L80
L75:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	$4, %ebx
	imull	$0, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	%edi, 0(%esi)
	movl	$4, %edi
	addl	%esi, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, 0(%esp)
	movl	12(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 4(%esp)
	movl	16(%ebp), %ebx
	movl	%ebx, 8(%esp)
	call	L69
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
	jmp	L77
L120:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl	L68				# Linkable
.type	L68, @function
L68:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$176, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L123:
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
	addl	$-164, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	-164(%ebp), %edi
	movl	%edi, 4(%esp)
	call	L0
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	$0, %esi
	cmpl	%ebx, %esi
	je	L73
L72:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, 0(%esi)
	movl	$4, %edi
	addl	%esi, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ebx
	movl	%ebx, 0(%esp)
	call	L68
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
L74:
	movl	%esi, %eax
	jmp	L122
L73:
	movl	$0, %esi
	jmp	L74
L122:
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
L125:
	movl	$0, -164(%ebp)
	movl	%ebp, 0(%esp)
	call	L2
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$4, %edi
	imull	$0, %edi
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
L66:
	movl	$0, %esi
	cmpl	%ebx, %esi
	je	L61
L67:
	movl	%ebp, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	movl	-164(%ebp), %edi
	movl	%edi, %edi
	imull	$10, %edi
	movl	%edi, %edi
	movl	8(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	-164(%ecx), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	ord
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %edi
	movl	%edi, %edi
	leal	L64, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	ord
	movl	%eax, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	%edi, %edi
	movl	-4(%ebp), %ecx # load pseudo-register
	subl	%ecx, %edi
	movl	%edi, (%esi)
	movl	8(%ebp), %esi
	movl	%esi, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getchar
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	jmp	L66
L61:
	movl	-164(%ebp), %esi
	movl	%esi, %eax
	jmp	L124
L124:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L65: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L64: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L63: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L62: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L60: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L59: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L58: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L57: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
.globl	L2				# Linkable
.type	L2, @function
L2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$176, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L55:
	movl	$0, %esi
	cmpl	%edi, %esi
	je	L54
L56:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	%esi, %esi
	addl	$-164, %esi
	movl	%esi, %esi
	call	getchar
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%esi)
	jmp	L55
L54:
	movl	$0, %eax
	jmp	L126
L126:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L48: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L47: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L46: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L45: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L44: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L43: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L42: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L41: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L40: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L34: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L33: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L32: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L31: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L30: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L29: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L28: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L27: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L26: 				# string literal
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
L128:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	call	ord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	leal	L11, %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	cmpl	%edi, %esi
	jge	L21
L22:
	movl	$0, %esi
L23:
	movl	%esi, %eax
	jmp	L127
L21:
	movl	$1, %esi
	movl	8(%ebp), %edi
	movl	8(%edi), %edi
	movl	-164(%edi), %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, %edi
	leal	L17, %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jle	L24
L25:
	movl	$0, %esi
L24:
	movl	%esi, %esi
	jmp	L23
L127:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L20: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L19: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L18: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L17: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L16: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L15: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
L14: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L13: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L12: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L11: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L10: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L9: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L8: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L7: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L6: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L5: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L4: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L3: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
