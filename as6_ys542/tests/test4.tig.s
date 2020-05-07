record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
MOVE(
 TEMP T100,
 ESEQ(
  SEQ(
   CJUMP(
NE,
    CONST 0,
    ESEQ(
     SEQ(
      MOVE(
       TEMP T110,
       CONST 0),
      SEQ(
       CJUMP(
EQ,
        MEM[4](
         BINOP(PLUS,
          CONST 12,
          TEMP T101)),
        CONST 0,
        L2,L3),
       SEQ(
        LABEL L2,
        SEQ(
         MOVE(
          TEMP T110,
          CONST 1),
         LABEL L3)))),
     TEMP T110),
    L4,L5),
   SEQ(
    LABEL L4,
    SEQ(
     MOVE(
      TEMP T111,
      CONST 1),
     SEQ(
      JUMP(
       NAME L6),
      SEQ(
       LABEL L5,
       SEQ(
        MOVE(
         TEMP T111,
         BINOP(MUL,
          MEM[4](
           BINOP(PLUS,
            CONST 12,
            TEMP T101)),
          CALL(
           NAME L1,
            MEM[4](
             BINOP(PLUS,
              CONST 8,
              TEMP T101)),
            BINOP(MINUS,
             MEM[4](
              BINOP(PLUS,
               CONST 12,
               TEMP T101)),
             CONST 1)))),
        LABEL L6)))))),
  TEMP T111))
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L8:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	je	L2
L3:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L4
L5:
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	12(%ebp), %edi
	movl	%edi, %edi
	subl	$1, %edi
	movl	%edi, 4(%esp)
	call	L1
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, %esi
	imull	%edi, %esi
	movl	%esi, %esi
L6:
	movl	%esi, %eax
	jmp	L7
L2:
	movl	$1, %esi
	jmp	L3
L4:
	movl	$1, %esi
	jmp	L6
L7:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
MOVE(
 TEMP T100,
 ESEQ(
  EXP(
   CALL(
    NAME L1,
     TEMP T101,
     CONST 4)),
  CONST 1))
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L10:
	movl	%ebp, 0(%esp)
	movl	$4, 4(%esp)
	call	L1
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L9
L9:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
