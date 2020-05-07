record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
L1: 				# string literal
	.long 6				# length of string
	.string "Nobody"				# content of string
L4: 				# string literal
	.long 8				# length of string
	.string "Somebody"				# content of string
MOVE(
 TEMP T100,
 ESEQ(
  MOVE(
   MEM[4](
    BINOP(PLUS,
     CONST ~164,
     TEMP T101)),
   ESEQ(
    SEQ(
     MOVE(
      TEMP T110,
      CALL(
       NAME allocRecord,
        CONST 8)),
     SEQ(
      MOVE(
       MEM[4](
        BINOP(PLUS,
         TEMP T110,
         CONST 0)),
       NAME L1),
      MOVE(
       MEM[4](
        BINOP(PLUS,
         TEMP T110,
         CONST 4)),
       CONST 1000))),
    TEMP T110)),
  ESEQ(
   SEQ(
    EXP(
     ESEQ(
      MOVE(
       ESEQ(
        SEQ(
         MOVE(
          TEMP T111,
          MEM[4](
           BINOP(PLUS,
            CONST ~164,
            TEMP T101))),
         SEQ(
          CJUMP(
NE,
           CONST 0,
           TEMP T111,
           L3,L2),
          SEQ(
           LABEL L2,
           SEQ(
            EXP(
             CALL(
              NAME print,
               NAME record_error)),
            SEQ(
             EXP(
              CALL(
               NAME exit,
                CONST 1)),
             LABEL L3))))),
        MEM[4](
         BINOP(PLUS,
          TEMP T111,
          BINOP(MUL,
           CONST 0,
           CONST 4)))),
       NAME L4),
      CONST 0)),
    EXP(
     MEM[4](
      BINOP(PLUS,
       CONST ~164,
       TEMP T101)))),
   CONST 1)))
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$176, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L6:
	movl	$-164, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %edi
	movl	%edi, %edi
	leal	L1, %ebx
	movl	%ebx, 0(%edi)
	movl	$1000, 4(%edi)
	movl	%edi, (%esi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L3
L2:
	leal	record_error, %edi
	movl	%edi, 0(%esp)
	call	print
	movl	%eax, %edi
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %edi
L3:
	leal	L4, %edi
	movl	%esi, %esi
	movl	$0, %ebx
	imull	$4, %ebx
	addl	%ebx, %esi
	movl	%edi, (%esi)
	movl	-164(%ebp), %esi
	movl	$1, %eax
	jmp	L5
L5:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
