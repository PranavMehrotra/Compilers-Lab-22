	.file	"test.c"
# GNU C17 (Ubuntu 9.4.0-1ubuntu1~20.04.1) version 9.4.0 (x86_64-linux-gnu)
#	compiled by GNU C version 9.4.0, GMP version 6.2.0, MPFR version 4.0.2, MPC version 1.1.0, isl version isl-0.22.1-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  -imultiarch x86_64-linux-gnu test.c -mtune=generic
# -march=x86-64 -auxbase-strip test_asm.s -fverbose-asm
# -fno-stack-protector -fasynchronous-unwind-tables -Wformat
# -Wformat-security -fstack-clash-protection -fcf-protection
# options enabled:  -fPIC -fPIE -faggressive-loop-optimizations
# -fassume-phsa -fasynchronous-unwind-tables -fauto-inc-dec -fcommon
# -fdelete-null-pointer-checks -fdwarf2-cfi-asm -fearly-inlining
# -feliminate-unused-debug-types -ffp-int-builtin-inexact -ffunction-cse
# -fgcse-lm -fgnu-runtime -fgnu-unique -fident -finline-atomics
# -fipa-stack-alignment -fira-hoist-pressure -fira-share-save-slots
# -fira-share-spill-slots -fivopts -fkeep-static-consts
# -fleading-underscore -flifetime-dse -flto-odr-type-merging -fmath-errno
# -fmerge-debug-strings -fpeephole -fplt -fprefetch-loop-arrays
# -freg-struct-return -fsched-critical-path-heuristic
# -fsched-dep-count-heuristic -fsched-group-heuristic -fsched-interblock
# -fsched-last-insn-heuristic -fsched-rank-heuristic -fsched-spec
# -fsched-spec-insn-heuristic -fsched-stalled-insns-dep -fschedule-fusion
# -fsemantic-interposition -fshow-column -fshrink-wrap-separate
# -fsigned-zeros -fsplit-ivs-in-unroller -fssa-backprop
# -fstack-clash-protection -fstdarg-opt -fstrict-volatile-bitfields
# -fsync-libcalls -ftrapping-math -ftree-cselim -ftree-forwprop
# -ftree-loop-if-convert -ftree-loop-im -ftree-loop-ivcanon
# -ftree-loop-optimize -ftree-parallelize-loops= -ftree-phiprop
# -ftree-reassoc -ftree-scev-cprop -funit-at-a-time -funwind-tables
# -fverbose-asm -fzero-initialized-in-bss -m128bit-long-double -m64 -m80387
# -malign-stringops -mavx256-split-unaligned-load
# -mavx256-split-unaligned-store -mfancy-math-387 -mfp-ret-in-387 -mfxsr
# -mglibc -mieee-fp -mlong-double-80 -mmmx -mno-sse4 -mpush-args -mred-zone
# -msse -msse2 -mstv -mtls-direct-seg-refs -mvzeroupper

	.text
	.section	.rodata
	.align 8
.LC0:
	.string	"Enter the string (all lowrer case): "
.LC1:
	.string	"%s"
.LC2:
	.string	"Length of the string: %d\n"
	.align 8
.LC3:
	.string	"The string in descending order: %s\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	subq	$64, %rsp	#,
# test.c:12:     printf("Enter the string (all lowrer case): ");
	leaq	.LC0(%rip), %rdi	#,
	movl	$0, %eax	#,
	call	printf@PLT	#
# test.c:13:     scanf("%s", str);
	leaq	-32(%rbp), %rax	#, tmp84
	movq	%rax, %rsi	# tmp84,
	leaq	.LC1(%rip), %rdi	#,
	movl	$0, %eax	#,
	call	__isoc99_scanf@PLT	#
# test.c:14:     len = length(str); // calling length function
	leaq	-32(%rbp), %rax	#, tmp85
	movq	%rax, %rdi	# tmp85,
	call	length	#
	movl	%eax, -4(%rbp)	# tmp86, len
# test.c:15:     printf("Length of the string: %d\n", len);
	movl	-4(%rbp), %eax	# len, tmp87
	movl	%eax, %esi	# tmp87,
	leaq	.LC2(%rip), %rdi	#,
	movl	$0, %eax	#,
	call	printf@PLT	#
# test.c:16:     sort(str, len, dest); // calling sorting function
	leaq	-64(%rbp), %rdx	#, tmp88
	movl	-4(%rbp), %ecx	# len, tmp89
	leaq	-32(%rbp), %rax	#, tmp90
	movl	%ecx, %esi	# tmp89,
	movq	%rax, %rdi	# tmp90,
	call	sort	#
# test.c:17:     printf("The string in descending order: %s\n", dest);
	leaq	-64(%rbp), %rax	#, tmp91
	movq	%rax, %rsi	# tmp91,
	leaq	.LC3(%rip), %rdi	#,
	movl	$0, %eax	#,
	call	printf@PLT	#
# test.c:18:     return 0;
	movl	$0, %eax	#, _9
# test.c:19: }
	leave	
	.cfi_def_cfa 7, 8
	ret	
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.globl	length
	.type	length, @function
length:
.LFB1:
	.cfi_startproc
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)	# str, str
# test.c:23:     for (i = 0; str[i] != '\0'; i++) // computing length of the string
	movl	$0, -4(%rbp)	#, i
# test.c:23:     for (i = 0; str[i] != '\0'; i++) // computing length of the string
	jmp	.L4	#
.L5:
# test.c:23:     for (i = 0; str[i] != '\0'; i++) // computing length of the string
	addl	$1, -4(%rbp)	#, i
.L4:
# test.c:23:     for (i = 0; str[i] != '\0'; i++) // computing length of the string
	movl	-4(%rbp), %eax	# i, tmp87
	movslq	%eax, %rdx	# tmp87, _1
	movq	-24(%rbp), %rax	# str, tmp88
	addq	%rdx, %rax	# _1, _2
	movzbl	(%rax), %eax	# *_2, _3
# test.c:23:     for (i = 0; str[i] != '\0'; i++) // computing length of the string
	testb	%al, %al	# _3
	jne	.L5	#,
# test.c:27:     return i;
	movl	-4(%rbp), %eax	# i, _8
# test.c:28: }
	popq	%rbp	#
	.cfi_def_cfa 7, 8
	ret	
	.cfi_endproc
.LFE1:
	.size	length, .-length
	.globl	sort
	.type	sort, @function
sort:
.LFB2:
	.cfi_startproc
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	subq	$48, %rsp	#,
	movq	%rdi, -24(%rbp)	# str, str
	movl	%esi, -28(%rbp)	# len, len
	movq	%rdx, -40(%rbp)	# dest, dest
# test.c:33:     for (i = 0; i < len; i++)
	movl	$0, -4(%rbp)	#, i
# test.c:33:     for (i = 0; i < len; i++)
	jmp	.L8	#
.L12:
# test.c:35:         for (j = 0; j < len; j++)
	movl	$0, -8(%rbp)	#, j
# test.c:35:         for (j = 0; j < len; j++)
	jmp	.L9	#
.L11:
# test.c:37:             if (str[i] < str[j]) // sorting in ascending order
	movl	-4(%rbp), %eax	# i, tmp97
	movslq	%eax, %rdx	# tmp97, _1
	movq	-24(%rbp), %rax	# str, tmp98
	addq	%rdx, %rax	# _1, _2
	movzbl	(%rax), %edx	# *_2, _3
# test.c:37:             if (str[i] < str[j]) // sorting in ascending order
	movl	-8(%rbp), %eax	# j, tmp99
	movslq	%eax, %rcx	# tmp99, _4
	movq	-24(%rbp), %rax	# str, tmp100
	addq	%rcx, %rax	# _4, _5
	movzbl	(%rax), %eax	# *_5, _6
# test.c:37:             if (str[i] < str[j]) // sorting in ascending order
	cmpb	%al, %dl	# _6, _3
	jge	.L10	#,
# test.c:39:                 temp = str[i];
	movl	-4(%rbp), %eax	# i, tmp101
	movslq	%eax, %rdx	# tmp101, _7
	movq	-24(%rbp), %rax	# str, tmp102
	addq	%rdx, %rax	# _7, _8
# test.c:39:                 temp = str[i];
	movzbl	(%rax), %eax	# *_8, tmp103
	movb	%al, -9(%rbp)	# tmp103, temp
# test.c:40:                 str[i] = str[j];
	movl	-8(%rbp), %eax	# j, tmp104
	movslq	%eax, %rdx	# tmp104, _9
	movq	-24(%rbp), %rax	# str, tmp105
	addq	%rdx, %rax	# _9, _10
# test.c:40:                 str[i] = str[j];
	movl	-4(%rbp), %edx	# i, tmp106
	movslq	%edx, %rcx	# tmp106, _11
	movq	-24(%rbp), %rdx	# str, tmp107
	addq	%rcx, %rdx	# _11, _12
# test.c:40:                 str[i] = str[j];
	movzbl	(%rax), %eax	# *_10, _13
# test.c:40:                 str[i] = str[j];
	movb	%al, (%rdx)	# _13, *_12
# test.c:41:                 str[j] = temp;
	movl	-8(%rbp), %eax	# j, tmp108
	movslq	%eax, %rdx	# tmp108, _14
	movq	-24(%rbp), %rax	# str, tmp109
	addq	%rax, %rdx	# tmp109, _15
# test.c:41:                 str[j] = temp;
	movzbl	-9(%rbp), %eax	# temp, tmp110
	movb	%al, (%rdx)	# tmp110, *_15
.L10:
# test.c:35:         for (j = 0; j < len; j++)
	addl	$1, -8(%rbp)	#, j
.L9:
# test.c:35:         for (j = 0; j < len; j++)
	movl	-8(%rbp), %eax	# j, tmp111
	cmpl	-28(%rbp), %eax	# len, tmp111
	jl	.L11	#,
# test.c:33:     for (i = 0; i < len; i++)
	addl	$1, -4(%rbp)	#, i
.L8:
# test.c:33:     for (i = 0; i < len; i++)
	movl	-4(%rbp), %eax	# i, tmp112
	cmpl	-28(%rbp), %eax	# len, tmp112
	jl	.L12	#,
# test.c:46:     reverse(str, len, dest);
	movq	-40(%rbp), %rdx	# dest, tmp113
	movl	-28(%rbp), %ecx	# len, tmp114
	movq	-24(%rbp), %rax	# str, tmp115
	movl	%ecx, %esi	# tmp114,
	movq	%rax, %rdi	# tmp115,
	call	reverse	#
# test.c:47: }
	nop	
	leave	
	.cfi_def_cfa 7, 8
	ret	
	.cfi_endproc
.LFE2:
	.size	sort, .-sort
	.globl	reverse
	.type	reverse, @function
reverse:
.LFB3:
	.cfi_startproc
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)	# str, str
	movl	%esi, -28(%rbp)	# len, len
	movq	%rdx, -40(%rbp)	# dest, dest
# test.c:52:     for (i = 0; i < len / 2; i++)
	movl	$0, -4(%rbp)	#, i
# test.c:52:     for (i = 0; i < len / 2; i++)
	jmp	.L14	#
.L19:
# test.c:54:         for (j = len - i - 1; j >= len / 2; j--) // reversing the string
	movl	-28(%rbp), %eax	# len, tmp99
	subl	-4(%rbp), %eax	# i, _1
# test.c:54:         for (j = len - i - 1; j >= len / 2; j--) // reversing the string
	subl	$1, %eax	#, tmp100
	movl	%eax, -8(%rbp)	# tmp100, j
# test.c:54:         for (j = len - i - 1; j >= len / 2; j--) // reversing the string
	nop	
# test.c:54:         for (j = len - i - 1; j >= len / 2; j--) // reversing the string
	movl	-28(%rbp), %eax	# len, tmp112
	movl	%eax, %edx	# tmp112, tmp113
	shrl	$31, %edx	#, tmp113
	addl	%edx, %eax	# tmp113, tmp114
	sarl	%eax	# tmp115
# test.c:54:         for (j = len - i - 1; j >= len / 2; j--) // reversing the string
	cmpl	%eax, -8(%rbp)	# _11, j
	jl	.L17	#,
# test.c:56:             if (i == j)
	movl	-4(%rbp), %eax	# i, tmp101
	cmpl	-8(%rbp), %eax	# j, tmp101
	je	.L22	#,
# test.c:60:                 temp = str[i];
	movl	-4(%rbp), %eax	# i, tmp102
	movslq	%eax, %rdx	# tmp102, _2
	movq	-24(%rbp), %rax	# str, tmp103
	addq	%rdx, %rax	# _2, _3
# test.c:60:                 temp = str[i];
	movzbl	(%rax), %eax	# *_3, tmp104
	movb	%al, -9(%rbp)	# tmp104, temp
# test.c:61:                 str[i] = str[j];
	movl	-8(%rbp), %eax	# j, tmp105
	movslq	%eax, %rdx	# tmp105, _4
	movq	-24(%rbp), %rax	# str, tmp106
	addq	%rdx, %rax	# _4, _5
# test.c:61:                 str[i] = str[j];
	movl	-4(%rbp), %edx	# i, tmp107
	movslq	%edx, %rcx	# tmp107, _6
	movq	-24(%rbp), %rdx	# str, tmp108
	addq	%rcx, %rdx	# _6, _7
# test.c:61:                 str[i] = str[j];
	movzbl	(%rax), %eax	# *_5, _8
# test.c:61:                 str[i] = str[j];
	movb	%al, (%rdx)	# _8, *_7
# test.c:62:                 str[j] = temp;
	movl	-8(%rbp), %eax	# j, tmp109
	movslq	%eax, %rdx	# tmp109, _9
	movq	-24(%rbp), %rax	# str, tmp110
	addq	%rax, %rdx	# tmp110, _10
# test.c:62:                 str[j] = temp;
	movzbl	-9(%rbp), %eax	# temp, tmp111
	movb	%al, (%rdx)	# tmp111, *_10
# test.c:63:                 break;
	jmp	.L17	#
.L22:
# test.c:57:                 break;
	nop	
.L17:
# test.c:52:     for (i = 0; i < len / 2; i++)
	addl	$1, -4(%rbp)	#, i
.L14:
# test.c:52:     for (i = 0; i < len / 2; i++)
	movl	-28(%rbp), %eax	# len, tmp116
	movl	%eax, %edx	# tmp116, tmp117
	shrl	$31, %edx	#, tmp117
	addl	%edx, %eax	# tmp117, tmp118
	sarl	%eax	# tmp119
# test.c:52:     for (i = 0; i < len / 2; i++)
	cmpl	%eax, -4(%rbp)	# _12, i
	jl	.L19	#,
# test.c:67:     for (i = 0; i < len; i++)
	movl	$0, -4(%rbp)	#, i
# test.c:67:     for (i = 0; i < len; i++)
	jmp	.L20	#
.L21:
# test.c:68:         dest[i] = str[i];
	movl	-4(%rbp), %eax	# i, tmp120
	movslq	%eax, %rdx	# tmp120, _13
	movq	-24(%rbp), %rax	# str, tmp121
	addq	%rdx, %rax	# _13, _14
# test.c:68:         dest[i] = str[i];
	movl	-4(%rbp), %edx	# i, tmp122
	movslq	%edx, %rcx	# tmp122, _15
	movq	-40(%rbp), %rdx	# dest, tmp123
	addq	%rcx, %rdx	# _15, _16
# test.c:68:         dest[i] = str[i];
	movzbl	(%rax), %eax	# *_14, _17
# test.c:68:         dest[i] = str[i];
	movb	%al, (%rdx)	# _17, *_16
# test.c:67:     for (i = 0; i < len; i++)
	addl	$1, -4(%rbp)	#, i
.L20:
# test.c:67:     for (i = 0; i < len; i++)
	movl	-4(%rbp), %eax	# i, tmp124
	cmpl	-28(%rbp), %eax	# len, tmp124
	jl	.L21	#,
# test.c:69: }
	nop	
	nop	
	popq	%rbp	#
	.cfi_def_cfa 7, 8
	ret	
	.cfi_endproc
.LFE3:
	.size	reverse, .-reverse
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
