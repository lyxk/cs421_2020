record_error: 				# string literal
	.long 41				# length of string
	.string "Error: nil record cannot be dereferenced\n"				# content of string
array_error: 				# string literal
	.long 32				# length of string
	.string "Error: array index out of range\n"				# content of string
L4: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
L7: 				# string literal
	.long 1				# length of string
	.string "9"				# content of string
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
GE,
        CALL(
         NAME ord,
          MEM[4](
           BINOP(PLUS,
            CONST ~164,
            MEM[4](
             BINOP(PLUS,
              CONST 8,
              MEM[4](
               BINOP(PLUS,
                CONST 8,
                TEMP T101))))))),
        CALL(
         NAME ord,
          NAME L4),
        L5,L6),
       SEQ(
        LABEL L5,
        SEQ(
         MOVE(
          TEMP T110,
          CONST 1),
         LABEL L6)))),
     TEMP T110),
    L10,L11),
   SEQ(
    LABEL L10,
    SEQ(
     MOVE(
      TEMP T112,
      ESEQ(
       SEQ(
        MOVE(
         TEMP T111,
         CONST 0),
        SEQ(
         CJUMP(
LE,
          CALL(
           NAME ord,
            MEM[4](
             BINOP(PLUS,
              CONST ~164,
              MEM[4](
               BINOP(PLUS,
                CONST 8,
                MEM[4](
                 BINOP(PLUS,
                  CONST 8,
                  TEMP T101))))))),
          CALL(
           NAME ord,
            NAME L7),
          L8,L9),
         SEQ(
          LABEL L8,
          SEQ(
           MOVE(
            TEMP T111,
            CONST 1),
           LABEL L9)))),
       TEMP T111)),
     SEQ(
      JUMP(
       NAME L12),
      SEQ(
       LABEL L11,
       SEQ(
        MOVE(
         TEMP T112,
         CONST 0),
        LABEL L12)))))),
  TEMP T112))
.globl	L2				# Linkable
.type	L2, @function
L2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L95:
	movl	$0, %esi
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
	jge	L5
L6:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L10
L11:
	movl	$0, %esi
L12:
	movl	%esi, %eax
	jmp	L94
L5:
	movl	$1, %esi
	jmp	L6
L10:
	movl	$0, %esi
	movl	8(%ebp), %edi
	movl	8(%edi), %edi
	movl	-164(%edi), %edi
	movl	%edi, 0(%esp)
	call	ord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, %edi
	leal	L7, %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	cmpl	%ebx, %edi
	jle	L8
L9:
	movl	%esi, %esi
	jmp	L12
L8:
	movl	$1, %esi
	jmp	L9
L94:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L13: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
L14: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
MOVE(
 TEMP T100,
 ESEQ(
  SEQ(
   LABEL L19,
   SEQ(
    CJUMP(
EQ,
     CONST 0,
     ESEQ(
      SEQ(
       CJUMP(
NE,
        CONST 0,
        CALL(
         NAME stringEqual,
          MEM[4](
           BINOP(PLUS,
            CONST ~164,
            MEM[4](
             BINOP(PLUS,
              CONST 8,
              MEM[4](
               BINOP(PLUS,
                CONST 8,
                TEMP T101)))))),
          NAME L13),
        L15,L16),
       SEQ(
        LABEL L15,
        SEQ(
         MOVE(
          TEMP T113,
          CONST 1),
         SEQ(
          JUMP(
           NAME L17),
          SEQ(
           LABEL L16,
           SEQ(
            MOVE(
             TEMP T113,
             CALL(
              NAME stringEqual,
               MEM[4](
                BINOP(PLUS,
                 CONST ~164,
                 MEM[4](
                  BINOP(PLUS,
                   CONST 8,
                   MEM[4](
                    BINOP(PLUS,
                     CONST 8,
                     TEMP T101)))))),
               NAME L14)),
            LABEL L17)))))),
      TEMP T113),
     L20,L21),
    SEQ(
     LABEL L21,
     SEQ(
      EXP(
       ESEQ(
        MOVE(
         MEM[4](
          BINOP(PLUS,
           CONST ~164,
           MEM[4](
            BINOP(PLUS,
             CONST 8,
             MEM[4](
              BINOP(PLUS,
               CONST 8,
               TEMP T101)))))),
         CALL(
          NAME getch)),
        CONST 0)),
      SEQ(
       JUMP(
        NAME L19),
       LABEL L20))))),
  CONST 0))
.globl	L3				# Linkable
.type	L3, @function
L3:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$172, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L19:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	leal	L13, %esi
	movl	%esi, 4(%esp)
	call	stringEqual
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L15
L16:
	movl	8(%ebp), %esi
	movl	8(%esi), %esi
	movl	-164(%esi), %esi
	movl	%esi, 0(%esp)
	leal	L14, %esi
	movl	%esi, 4(%esp)
	call	stringEqual
	movl	%eax, %esi
	movl	%esi, %esi
L17:
	movl	$0, %edi
	cmpl	%esi, %edi
	je	L20
L21:
	movl	$-164, %esi
	movl	8(%ebp), %edi
	movl	8(%edi), %edi
	addl	%edi, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	jmp	L19
L15:
	movl	$1, %esi
	jmp	L17
L20:
	movl	$0, %eax
	jmp	L96
L96:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L25: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
MOVE(
 TEMP T100,
 ESEQ(
  MOVE(
   MEM[4](
    BINOP(PLUS,
     CONST ~164,
     TEMP T101)),
   CONST 0),
  ESEQ(
   SEQ(
    EXP(
     CALL(
      NAME L3,
       TEMP T101)),
    SEQ(
     EXP(
      ESEQ(
       MOVE(
        ESEQ(
         SEQ(
          MOVE(
           TEMP T114,
           MEM[4](
            BINOP(PLUS,
             CONST 12,
             TEMP T101))),
          SEQ(
           CJUMP(
NE,
            CONST 0,
            TEMP T114,
            L23,L22),
           SEQ(
            LABEL L22,
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
              LABEL L23))))),
         MEM[4](
          BINOP(PLUS,
           TEMP T114,
           BINOP(MUL,
            CONST 0,
            CONST 4)))),
        CALL(
         NAME L2,
          TEMP T101,
          MEM[4](
           BINOP(PLUS,
            CONST ~164,
            MEM[4](
             BINOP(PLUS,
              CONST 8,
              TEMP T101)))))),
       CONST 0)),
     EXP(
      ESEQ(
       SEQ(
        LABEL L26,
        SEQ(
         CJUMP(
EQ,
          CONST 0,
          CALL(
           NAME L2,
            TEMP T101,
            MEM[4](
             BINOP(PLUS,
              CONST ~164,
              MEM[4](
               BINOP(PLUS,
                CONST 8,
                TEMP T101))))),
          L27,L28),
         SEQ(
          LABEL L28,
          SEQ(
           EXP(
            ESEQ(
             EXP(
              ESEQ(
               MOVE(
                MEM[4](
                 BINOP(PLUS,
                  CONST ~164,
                  TEMP T101)),
                BINOP(MINUS,
                 BINOP(PLUS,
                  BINOP(MUL,
                   MEM[4](
                    BINOP(PLUS,
                     CONST ~164,
                     TEMP T101)),
                   CONST 10),
                  CALL(
                   NAME ord,
                    MEM[4](
                     BINOP(PLUS,
                      CONST ~164,
                      MEM[4](
                       BINOP(PLUS,
                        CONST 8,
                        TEMP T101)))))),
                 CALL(
                  NAME ord,
                   NAME L25))),
               CONST 0)),
             ESEQ(
              MOVE(
               MEM[4](
                BINOP(PLUS,
                 CONST ~164,
                 MEM[4](
                  BINOP(PLUS,
                   CONST 8,
                   TEMP T101)))),
               CALL(
                NAME getch)),
              CONST 0))),
           SEQ(
            JUMP(
             NAME L26),
            LABEL L27))))),
       CONST 0)))),
   MEM[4](
    BINOP(PLUS,
     CONST ~164,
     TEMP T101)))))
.globl	L1				# Linkable
.type	L1, @function
L1:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -168(%ebp)
	movl	%edi, -172(%ebp)
	movl	%ebx, -176(%ebp)
L98:
	movl	$0, -164(%ebp)
	movl	%ebp, 0(%esp)
	call	L3
	movl	%eax, %esi
	movl	12(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L23
L22:
	leal	record_error, %edi
	movl	%edi, 0(%esp)
	call	print
	movl	%eax, %edi
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %edi
L23:
	movl	%esi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	%esi, %esi
	movl	%ebp, 0(%esp)
	movl	8(%ebp), %edi
	movl	-164(%edi), %edi
	movl	%edi, 4(%esp)
	call	L2
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
L26:
	movl	%ebp, 0(%esp)
	movl	8(%ebp), %esi
	movl	-164(%esi), %esi
	movl	%esi, 4(%esp)
	call	L2
	movl	%eax, %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	je	L27
L28:
	movl	$-164, %esi
	addl	%ebp, %esi
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
	leal	L25, %ebx
	movl	%ebx, 0(%esp)
	call	ord
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%edi, %edi
	subl	%ebx, %edi
	movl	%edi, (%esi)
	movl	$-164, %esi
	movl	8(%ebp), %edi
	addl	%edi, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	jmp	L26
L27:
	movl	-164(%ebp), %esi
	movl	%esi, %eax
	jmp	L97
L97:
	movl	-168(%ebp), %esi
	movl	-172(%ebp), %edi
	movl	-176(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
MOVE(
 TEMP T100,
 ESEQ(
  SEQ(
   MOVE(
    MEM[4](
     BINOP(PLUS,
      CONST ~164,
      TEMP T101)),
    ESEQ(
     SEQ(
      MOVE(
       TEMP T115,
       CALL(
        NAME allocRecord,
         CONST 4)),
      MOVE(
       MEM[4](
        BINOP(PLUS,
         TEMP T115,
         CONST 0)),
       CONST 0)),
     TEMP T115)),
   MOVE(
    MEM[4](
     BINOP(PLUS,
      CONST ~168,
      TEMP T101)),
    CALL(
     NAME L1,
      MEM[4](
       BINOP(PLUS,
        CONST 8,
        TEMP T101)),
      MEM[4](
       BINOP(PLUS,
        CONST ~164,
        TEMP T101))))),
  ESEQ(
   SEQ(
    CJUMP(
NE,
     CONST 0,
     ESEQ(
      SEQ(
       MOVE(
        TEMP T116,
        MEM[4](
         BINOP(PLUS,
          CONST ~164,
          TEMP T101))),
       SEQ(
        CJUMP(
NE,
         CONST 0,
         TEMP T116,
         L34,L33),
        SEQ(
         LABEL L33,
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
           LABEL L34))))),
      MEM[4](
       BINOP(PLUS,
        TEMP T116,
        BINOP(MUL,
         CONST 0,
         CONST 4)))),
     L35,L36),
    SEQ(
     LABEL L35,
     SEQ(
      MOVE(
       TEMP T118,
       ESEQ(
        SEQ(
         MOVE(
          TEMP T117,
          CALL(
           NAME allocRecord,
            CONST 8)),
         SEQ(
          MOVE(
           MEM[4](
            BINOP(PLUS,
             TEMP T117,
             CONST 0)),
           MEM[4](
            BINOP(PLUS,
             CONST ~168,
             TEMP T101))),
          MOVE(
           MEM[4](
            BINOP(PLUS,
             TEMP T117,
             CONST 4)),
           CALL(
            NAME L29,
             MEM[4](
              BINOP(PLUS,
               CONST 8,
               TEMP T101)))))),
        TEMP T117)),
      SEQ(
       JUMP(
        NAME L37),
       SEQ(
        LABEL L36,
        SEQ(
         MOVE(
          TEMP T118,
          CONST 0),
         LABEL L37)))))),
   TEMP T118)))
.globl	L29				# Linkable
.type	L29, @function
L29:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$188, %esp
	movl	%esi, -172(%ebp)
	movl	%edi, -176(%ebp)
	movl	%ebx, -180(%ebp)
L100:
	movl	$-164, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	$4, 0(%esp)
	call	allocRecord
	movl	%eax, %edi
	movl	%edi, %edi
	movl	$0, 0(%edi)
	movl	%edi, (%esi)
	movl	$-168, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	8(%ebp), %edi
	movl	%edi, 0(%esp)
	movl	-164(%ebp), %edi
	movl	%edi, 4(%esp)
	call	L1
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	-164(%ebp), %esi
	movl	%esi, %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L34
L33:
	leal	record_error, %edi
	movl	%edi, 0(%esp)
	call	print
	movl	%eax, %edi
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %edi
L34:
	movl	%esi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L35
L36:
	movl	$0, %esi
L37:
	movl	%esi, %eax
	jmp	L99
L35:
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
	call	L29
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
	jmp	L37
L99:
	movl	-172(%ebp), %esi
	movl	-176(%ebp), %edi
	movl	-180(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
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
       TEMP T119,
       CONST 0),
      SEQ(
       CJUMP(
EQ,
        MEM[4](
         BINOP(PLUS,
          CONST 12,
          TEMP T101)),
        CONST 0,
        L38,L39),
       SEQ(
        LABEL L38,
        SEQ(
         MOVE(
          TEMP T119,
          CONST 1),
         LABEL L39)))),
     TEMP T119),
    L62,L63),
   SEQ(
    LABEL L62,
    SEQ(
     MOVE(
      TEMP T132,
      MEM[4](
       BINOP(PLUS,
        CONST 16,
        TEMP T101))),
     SEQ(
      JUMP(
       NAME L64),
      SEQ(
       LABEL L63,
       SEQ(
        MOVE(
         TEMP T132,
         ESEQ(
          SEQ(
           CJUMP(
NE,
            CONST 0,
            ESEQ(
             SEQ(
              MOVE(
               TEMP T120,
               CONST 0),
              SEQ(
               CJUMP(
EQ,
                MEM[4](
                 BINOP(PLUS,
                  CONST 16,
                  TEMP T101)),
                CONST 0,
                L40,L41),
               SEQ(
                LABEL L40,
                SEQ(
                 MOVE(
                  TEMP T120,
                  CONST 1),
                 LABEL L41)))),
             TEMP T120),
            L59,L60),
           SEQ(
            LABEL L59,
            SEQ(
             MOVE(
              TEMP T131,
              MEM[4](
               BINOP(PLUS,
                CONST 12,
                TEMP T101))),
             SEQ(
              JUMP(
               NAME L61),
              SEQ(
               LABEL L60,
               SEQ(
                MOVE(
                 TEMP T131,
                 ESEQ(
                  SEQ(
                   CJUMP(
NE,
                    CONST 0,
                    ESEQ(
                     SEQ(
                      MOVE(
                       TEMP T123,
                       CONST 0),
                      SEQ(
                       CJUMP(
LT,
                        ESEQ(
                         SEQ(
                          MOVE(
                           TEMP T121,
                           MEM[4](
                            BINOP(PLUS,
                             CONST 12,
                             TEMP T101))),
                          SEQ(
                           CJUMP(
NE,
                            CONST 0,
                            TEMP T121,
                            L43,L42),
                           SEQ(
                            LABEL L42,
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
                              LABEL L43))))),
                         MEM[4](
                          BINOP(PLUS,
                           TEMP T121,
                           BINOP(MUL,
                            CONST 0,
                            CONST 4)))),
                        ESEQ(
                         SEQ(
                          MOVE(
                           TEMP T122,
                           MEM[4](
                            BINOP(PLUS,
                             CONST 16,
                             TEMP T101))),
                          SEQ(
                           CJUMP(
NE,
                            CONST 0,
                            TEMP T122,
                            L45,L44),
                           SEQ(
                            LABEL L44,
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
                              LABEL L45))))),
                         MEM[4](
                          BINOP(PLUS,
                           TEMP T122,
                           BINOP(MUL,
                            CONST 0,
                            CONST 4)))),
                        L46,L47),
                       SEQ(
                        LABEL L46,
                        SEQ(
                         MOVE(
                          TEMP T123,
                          CONST 1),
                         LABEL L47)))),
                     TEMP T123),
                    L56,L57),
                   SEQ(
                    LABEL L56,
                    SEQ(
                     MOVE(
                      TEMP T130,
                      ESEQ(
                       SEQ(
                        MOVE(
                         TEMP T126,
                         CALL(
                          NAME allocRecord,
                           CONST 8)),
                        SEQ(
                         MOVE(
                          MEM[4](
                           BINOP(PLUS,
                            TEMP T126,
                            CONST 0)),
                          ESEQ(
                           SEQ(
                            MOVE(
                             TEMP T124,
                             MEM[4](
                              BINOP(PLUS,
                               CONST 12,
                               TEMP T101))),
                            SEQ(
                             CJUMP(
NE,
                              CONST 0,
                              TEMP T124,
                              L49,L48),
                             SEQ(
                              LABEL L48,
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
                                LABEL L49))))),
                           MEM[4](
                            BINOP(PLUS,
                             TEMP T124,
                             BINOP(MUL,
                              CONST 0,
                              CONST 4))))),
                         MOVE(
                          MEM[4](
                           BINOP(PLUS,
                            TEMP T126,
                            CONST 4)),
                          CALL(
                           NAME L30,
                            MEM[4](
                             BINOP(PLUS,
                              CONST 8,
                              TEMP T101)),
                            MEM[4](
                             BINOP(PLUS,
                              CONST 16,
                              TEMP T101)),
                            ESEQ(
                             SEQ(
                              MOVE(
                               TEMP T125,
                               MEM[4](
                                BINOP(PLUS,
                                 CONST 12,
                                 TEMP T101))),
                              SEQ(
                               CJUMP(
NE,
                                CONST 0,
                                TEMP T125,
                                L51,L50),
                               SEQ(
                                LABEL L50,
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
                                  LABEL L51))))),
                             MEM[4](
                              BINOP(PLUS,
                               TEMP T125,
                               BINOP(MUL,
                                CONST 1,
                                CONST 4)))))))),
                       TEMP T126)),
                     SEQ(
                      JUMP(
                       NAME L58),
                      SEQ(
                       LABEL L57,
                       SEQ(
                        MOVE(
                         TEMP T130,
                         ESEQ(
                          SEQ(
                           MOVE(
                            TEMP T129,
                            CALL(
                             NAME allocRecord,
                              CONST 8)),
                           SEQ(
                            MOVE(
                             MEM[4](
                              BINOP(PLUS,
                               TEMP T129,
                               CONST 0)),
                             ESEQ(
                              SEQ(
                               MOVE(
                                TEMP T127,
                                MEM[4](
                                 BINOP(PLUS,
                                  CONST 16,
                                  TEMP T101))),
                               SEQ(
                                CJUMP(
NE,
                                 CONST 0,
                                 TEMP T127,
                                 L53,L52),
                                SEQ(
                                 LABEL L52,
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
                                   LABEL L53))))),
                              MEM[4](
                               BINOP(PLUS,
                                TEMP T127,
                                BINOP(MUL,
                                 CONST 0,
                                 CONST 4))))),
                            MOVE(
                             MEM[4](
                              BINOP(PLUS,
                               TEMP T129,
                               CONST 4)),
                             CALL(
                              NAME L30,
                               MEM[4](
                                BINOP(PLUS,
                                 CONST 8,
                                 TEMP T101)),
                               ESEQ(
                                SEQ(
                                 MOVE(
                                  TEMP T128,
                                  MEM[4](
                                   BINOP(PLUS,
                                    CONST 16,
                                    TEMP T101))),
                                 SEQ(
                                  CJUMP(
NE,
                                   CONST 0,
                                   TEMP T128,
                                   L55,L54),
                                  SEQ(
                                   LABEL L54,
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
                                     LABEL L55))))),
                                MEM[4](
                                 BINOP(PLUS,
                                  TEMP T128,
                                  BINOP(MUL,
                                   CONST 1,
                                   CONST 4)))),
                               MEM[4](
                                BINOP(PLUS,
                                 CONST 12,
                                 TEMP T101)))))),
                          TEMP T129)),
                        LABEL L58)))))),
                  TEMP T130)),
                LABEL L61)))))),
          TEMP T131)),
        LABEL L64)))))),
  TEMP T132))
.globl	L30				# Linkable
.type	L30, @function
L30:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$184, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L102:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	je	L38
L39:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L62
L63:
	movl	$0, %esi
	movl	$0, %edi
	movl	16(%ebp), %ebx
	cmpl	%edi, %ebx
	je	L40
L41:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L59
L60:
	movl	$0, %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	cmpl	%edi, %ebx
	jne	L43
L42:
	leal	record_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L43:
	movl	%edi, %edi
	movl	$0, %ebx
	imull	$4, %ebx
	addl	%ebx, %edi
	movl	(%edi), %edi
	movl	%edi, %edi
	movl	16(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	cmpl	%ebx, %edx
	jne	L45
L44:
	leal	record_error, %ecx
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
L45:
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	cmpl	%ebx, %edi
	jl	L46
L47:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L56
L57:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %edi
	addl	$0, %edi
	movl	%edi, %edi
	movl	16(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	cmpl	%ebx, %edx
	jne	L53
L52:
	leal	record_error, %ecx
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
L53:
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
	movl	16(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	$0, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	-8(%ebp), %edx # load pseudo-register
	cmpl	%ecx, %edx
	jne	L55
L54:
	leal	record_error, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
L55:
	movl	%ebx, 0(%esp)
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	movl	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 4(%esp)
	movl	12(%ebp), %ebx
	movl	%ebx, 8(%esp)
	call	L30
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
L58:
	movl	%esi, %esi
L61:
	movl	%esi, %esi
L64:
	movl	%esi, %eax
	jmp	L101
L38:
	movl	$1, %esi
	jmp	L39
L62:
	movl	16(%ebp), %esi
	movl	%esi, %esi
	jmp	L64
L40:
	movl	$1, %esi
	jmp	L41
L59:
	movl	12(%ebp), %esi
	movl	%esi, %esi
	jmp	L61
L46:
	movl	$1, %esi
	jmp	L47
L56:
	movl	$8, 0(%esp)
	call	allocRecord
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %edi
	addl	$0, %edi
	movl	%edi, %edi
	movl	12(%ebp), %ebx
	movl	%ebx, %ebx
	movl	$0, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %edx # load pseudo-register
	cmpl	%ebx, %edx
	jne	L49
L48:
	leal	record_error, %ecx
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
L49:
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
	movl	16(%ebp), %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	12(%ebp), %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ecx
	movl	%ecx, -8(%ebp) # save pseudo-register
	movl	$0, %ecx
	movl	%ecx, -12(%ebp) # save pseudo-register
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	-12(%ebp), %edx # load pseudo-register
	cmpl	%ecx, %edx
	jne	L51
L50:
	leal	record_error, %ecx
	movl	%ecx, -12(%ebp) # save pseudo-register
	movl	-12(%ebp), %ecx # load pseudo-register
	movl	%ecx, 0(%esp)
	call	print
	movl	%eax, %ecx
	movl	%ecx, -12(%ebp) # save pseudo-register
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ecx
	movl	%ecx, -12(%ebp) # save pseudo-register
L51:
	movl	%ebx, 0(%esp)
	movl	-4(%ebp), %ecx # load pseudo-register
	movl	%ecx, 4(%esp)
	movl	-8(%ebp), %ecx # load pseudo-register
	movl	%ecx, %ebx
	movl	$1, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	imull	$4, %ecx
	movl	%ecx, -4(%ebp) # save pseudo-register
	movl	-4(%ebp), %ecx # load pseudo-register
	addl	%ecx, %ebx
	movl	(%ebx), %ebx
	movl	%ebx, 8(%esp)
	call	L30
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%esi, %esi
	jmp	L58
L101:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L68: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
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
       TEMP T133,
       CONST 0),
      SEQ(
       CJUMP(
GT,
        MEM[4](
         BINOP(PLUS,
          CONST 12,
          TEMP T101)),
        CONST 0,
        L66,L67),
       SEQ(
        LABEL L66,
        SEQ(
         MOVE(
          TEMP T133,
          CONST 1),
         LABEL L67)))),
     TEMP T133),
    L69,L70),
   SEQ(
    LABEL L69,
    SEQ(
     EXP(
      ESEQ(
       EXP(
        CALL(
         NAME L65,
          MEM[4](
           BINOP(PLUS,
            CONST 8,
            TEMP T101)),
          BINOP(DIV,
           MEM[4](
            BINOP(PLUS,
             CONST 12,
             TEMP T101)),
           CONST 10))),
       CALL(
        NAME print,
         CALL(
          NAME chr,
           BINOP(PLUS,
            BINOP(MINUS,
             MEM[4](
              BINOP(PLUS,
               CONST 12,
               TEMP T101)),
             BINOP(MUL,
              BINOP(DIV,
               MEM[4](
                BINOP(PLUS,
                 CONST 12,
                 TEMP T101)),
               CONST 10),
              CONST 10)),
            CALL(
             NAME ord,
              NAME L68)))))),
     LABEL L70))),
  CONST 0))
.globl	L65				# Linkable
.type	L65, @function
L65:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L104:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	jg	L66
L67:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L69
L70:
	movl	$0, %eax
	jmp	L103
L66:
	movl	$1, %esi
	jmp	L67
L69:
	movl	8(%ebp), %esi
	movl	%esi, 0(%esp)
	movl	$0, %edx
	movl	12(%ebp), %esi
	movl	%esi, %eax
	movl	$10, %esi
	idivl	%esi
	movl	%eax, 4(%esp)
	call	L65
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
	leal	L68, %edi
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
	jmp	L70
L103:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L73: 				# string literal
	.long 1				# length of string
	.string "-"				# content of string
L76: 				# string literal
	.long 1				# length of string
	.string "0"				# content of string
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
       TEMP T134,
       CONST 0),
      SEQ(
       CJUMP(
LT,
        MEM[4](
         BINOP(PLUS,
          CONST 12,
          TEMP T101)),
        CONST 0,
        L71,L72),
       SEQ(
        LABEL L71,
        SEQ(
         MOVE(
          TEMP T134,
          CONST 1),
         LABEL L72)))),
     TEMP T134),
    L80,L81),
   SEQ(
    LABEL L80,
    SEQ(
     MOVE(
      TEMP T137,
      ESEQ(
       EXP(
        CALL(
         NAME print,
          NAME L73)),
       CALL(
        NAME L65,
         TEMP T101,
         BINOP(MINUS,
          CONST 0,
          MEM[4](
           BINOP(PLUS,
            CONST 12,
            TEMP T101)))))),
     SEQ(
      JUMP(
       NAME L82),
      SEQ(
       LABEL L81,
       SEQ(
        MOVE(
         TEMP T137,
         ESEQ(
          SEQ(
           CJUMP(
NE,
            CONST 0,
            ESEQ(
             SEQ(
              MOVE(
               TEMP T135,
               CONST 0),
              SEQ(
               CJUMP(
GT,
                MEM[4](
                 BINOP(PLUS,
                  CONST 12,
                  TEMP T101)),
                CONST 0,
                L74,L75),
               SEQ(
                LABEL L74,
                SEQ(
                 MOVE(
                  TEMP T135,
                  CONST 1),
                 LABEL L75)))),
             TEMP T135),
            L77,L78),
           SEQ(
            LABEL L77,
            SEQ(
             MOVE(
              TEMP T136,
              CALL(
               NAME L65,
                TEMP T101,
                MEM[4](
                 BINOP(PLUS,
                  CONST 12,
                  TEMP T101)))),
             SEQ(
              JUMP(
               NAME L79),
              SEQ(
               LABEL L78,
               SEQ(
                MOVE(
                 TEMP T136,
                 CALL(
                  NAME print,
                   NAME L76)),
                LABEL L79)))))),
          TEMP T136)),
        LABEL L82)))))),
  TEMP T137))
.globl	L31				# Linkable
.type	L31, @function
L31:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L106:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	jl	L71
L72:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L80
L81:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	jg	L74
L75:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L77
L78:
	leal	L76, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
L79:
	movl	%esi, %esi
L82:
	movl	%esi, %eax
	jmp	L105
L71:
	movl	$1, %esi
	jmp	L72
L80:
	leal	L73, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%ebp, 0(%esp)
	movl	$0, %esi
	movl	12(%ebp), %edi
	subl	%edi, %esi
	movl	%esi, 4(%esp)
	call	L65
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
	jmp	L82
L74:
	movl	$1, %esi
	jmp	L75
L77:
	movl	%ebp, 0(%esp)
	movl	12(%ebp), %esi
	movl	%esi, 4(%esp)
	call	L65
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L79
L105:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
L85: 				# string literal
	.long 1				# length of string
	.string "\n"				# content of string
L88: 				# string literal
	.long 1				# length of string
	.string " "				# content of string
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
       TEMP T138,
       CONST 0),
      SEQ(
       CJUMP(
EQ,
        MEM[4](
         BINOP(PLUS,
          CONST 12,
          TEMP T101)),
        CONST 0,
        L83,L84),
       SEQ(
        LABEL L83,
        SEQ(
         MOVE(
          TEMP T138,
          CONST 1),
         LABEL L84)))),
     TEMP T138),
    L91,L92),
   SEQ(
    LABEL L91,
    SEQ(
     MOVE(
      TEMP T141,
      CALL(
       NAME print,
        NAME L85)),
     SEQ(
      JUMP(
       NAME L93),
      SEQ(
       LABEL L92,
       SEQ(
        MOVE(
         TEMP T141,
         ESEQ(
          SEQ(
           EXP(
            CALL(
             NAME L31,
              MEM[4](
               BINOP(PLUS,
                CONST 8,
                TEMP T101)),
              ESEQ(
               SEQ(
                MOVE(
                 TEMP T139,
                 MEM[4](
                  BINOP(PLUS,
                   CONST 12,
                   TEMP T101))),
                SEQ(
                 CJUMP(
NE,
                  CONST 0,
                  TEMP T139,
                  L87,L86),
                 SEQ(
                  LABEL L86,
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
                    LABEL L87))))),
               MEM[4](
                BINOP(PLUS,
                 TEMP T139,
                 BINOP(MUL,
                  CONST 0,
                  CONST 4)))))),
           EXP(
            CALL(
             NAME print,
              NAME L88))),
          CALL(
           NAME L32,
            MEM[4](
             BINOP(PLUS,
              CONST 8,
              TEMP T101)),
            ESEQ(
             SEQ(
              MOVE(
               TEMP T140,
               MEM[4](
                BINOP(PLUS,
                 CONST 12,
                 TEMP T101))),
              SEQ(
               CJUMP(
NE,
                CONST 0,
                TEMP T140,
                L90,L89),
               SEQ(
                LABEL L89,
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
                  LABEL L90))))),
             MEM[4](
              BINOP(PLUS,
               TEMP T140,
               BINOP(MUL,
                CONST 1,
                CONST 4))))))),
        LABEL L93)))))),
  TEMP T141))
.globl	L32				# Linkable
.type	L32, @function
L32:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$180, %esp
	movl	%esi, -164(%ebp)
	movl	%edi, -168(%ebp)
	movl	%ebx, -172(%ebp)
L108:
	movl	$0, %esi
	movl	$0, %edi
	movl	12(%ebp), %ebx
	cmpl	%edi, %ebx
	je	L83
L84:
	movl	$0, %edi
	cmpl	%esi, %edi
	jne	L91
L92:
	movl	8(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	cmpl	%edi, %ebx
	jne	L87
L86:
	leal	record_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L87:
	movl	%esi, 0(%esp)
	movl	%edi, %esi
	movl	$0, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L31
	movl	%eax, %esi
	leal	L88, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	8(%ebp), %esi
	movl	%esi, %esi
	movl	12(%ebp), %edi
	movl	%edi, %edi
	movl	$0, %ebx
	cmpl	%edi, %ebx
	jne	L90
L89:
	leal	record_error, %ebx
	movl	%ebx, 0(%esp)
	call	print
	movl	%eax, %ebx
	movl	$1, 0(%esp)
	call	exit
	movl	%eax, %ebx
L90:
	movl	%esi, 0(%esp)
	movl	%edi, %esi
	movl	$1, %edi
	imull	$4, %edi
	addl	%edi, %esi
	movl	(%esi), %esi
	movl	%esi, 4(%esp)
	call	L32
	movl	%eax, %esi
	movl	%esi, %esi
	movl	%esi, %esi
L93:
	movl	%esi, %eax
	jmp	L107
L83:
	movl	$1, %esi
	jmp	L84
L91:
	leal	L85, %esi
	movl	%esi, 0(%esp)
	call	print
	movl	%eax, %esi
	movl	%esi, %esi
	jmp	L93
L107:
	movl	-164(%ebp), %esi
	movl	-168(%ebp), %edi
	movl	-172(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
MOVE(
 TEMP T100,
 ESEQ(
  SEQ(
   MOVE(
    MEM[4](
     BINOP(PLUS,
      CONST ~164,
      TEMP T101)),
    CALL(
     NAME getch)),
   SEQ(
    MOVE(
     MEM[4](
      BINOP(PLUS,
       CONST ~168,
       TEMP T101)),
     CALL(
      NAME L29,
       TEMP T101)),
    MOVE(
     MEM[4](
      BINOP(PLUS,
       CONST ~172,
       TEMP T101)),
     ESEQ(
      EXP(
       ESEQ(
        MOVE(
         MEM[4](
          BINOP(PLUS,
           CONST ~164,
           TEMP T101)),
         CALL(
          NAME getch)),
        CONST 0)),
      CALL(
       NAME L29,
        TEMP T101))))),
  ESEQ(
   EXP(
    CALL(
     NAME L32,
      TEMP T101,
      CALL(
       NAME L30,
        TEMP T101,
        MEM[4](
         BINOP(PLUS,
          CONST ~172,
          TEMP T101)),
        MEM[4](
         BINOP(PLUS,
          CONST ~168,
          TEMP T101))))),
   CONST 1)))
.globl	tigermain				# Linkable
.type	tigermain, @function
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$196, %esp
	movl	%esi, -176(%ebp)
	movl	%edi, -180(%ebp)
	movl	%ebx, -184(%ebp)
L110:
	movl	$-164, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	call	getch
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	$-168, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	%ebp, 0(%esp)
	call	L29
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	$-172, %esi
	addl	%ebp, %esi
	movl	%esi, %esi
	movl	$-164, %edi
	addl	%ebp, %edi
	movl	%edi, %edi
	call	getch
	movl	%eax, %ebx
	movl	%ebx, %ebx
	movl	%ebx, (%edi)
	movl	%ebp, 0(%esp)
	call	L29
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%edi, (%esi)
	movl	%ebp, %esi
	movl	%ebp, 0(%esp)
	movl	-172(%ebp), %edi
	movl	%edi, 4(%esp)
	movl	-168(%ebp), %edi
	movl	%edi, 8(%esp)
	call	L30
	movl	%eax, %edi
	movl	%edi, %edi
	movl	%esi, 0(%esp)
	movl	%edi, 4(%esp)
	call	L32
	movl	%eax, %esi
	movl	$1, %eax
	jmp	L109
L109:
	movl	-176(%ebp), %esi
	movl	-180(%ebp), %edi
	movl	-184(%ebp), %ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
