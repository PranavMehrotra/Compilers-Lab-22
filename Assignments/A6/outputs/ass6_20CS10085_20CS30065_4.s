.section	.rodata
.LC0:
	.string "Entered for iteration "
.LC1:
	.string "\n"
.LC2:
	.string "\nScope 1: "
.LC3:
	.string "\nScope 2: "
.LC4:
	.string "\nEntered in the p == 13 condition if block."
.LC5:
	.string "\nScope 3: "
.LC6:
	.string "\n"
# printStr: 
# printInt: 
# readInt: 
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$144, %rsp
# t0 = 1
	movl	$1, -4(%rbp)
# loop_count = t0
	movl	-4(%rbp), %eax
	movl	%eax, -8(%rbp)
# param .LC0
.L0:
# t1 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -20(%rbp)
	addq	$4, %rsp
# t2 = loop_count
	movl	-8(%rbp), %eax
	movl	%eax, -28(%rbp)
# loop_count = loop_count + 1
	movl	-8(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
# param t2
# t3 = call printInt, 1
	movq	-28(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -32(%rbp)
	addq	$4, %rsp
# param .LC1
# t4 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -40(%rbp)
	addq	$4, %rsp
# t5 = 10
	movl	$10, -44(%rbp)
# t6 = 1
	movl	$1, -48(%rbp)
# if loop_count < t5 goto .L0
	movl	-8(%rbp), %eax
	cmpl	-44(%rbp), %eax
	jge	.L4
	jmp	.L0
.L4:
# t6 = 0
	movl	$0, -48(%rbp)
# goto .L1
	jmp	.L1
# goto .L1
	jmp	.L1
# t7 = 32
.L1:
	movl	$32, -52(%rbp)
# p = t7
	movl	-52(%rbp), %eax
	movl	%eax, -56(%rbp)
# param .LC2
# t8 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -64(%rbp)
	addq	$4, %rsp
# param p
# t9 = call printInt, 1
	movq	-56(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -68(%rbp)
	addq	$4, %rsp
# t10 = 27
	movl	$27, -72(%rbp)
# p = t10
	movl	-72(%rbp), %eax
	movl	%eax, -56(%rbp)
# param .LC3
# t11 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -80(%rbp)
	addq	$4, %rsp
# param p
# t12 = call printInt, 1
	movq	-56(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -84(%rbp)
	addq	$4, %rsp
# t13 = 13
	movl	$13, -88(%rbp)
# p = t13
	movl	-88(%rbp), %eax
	movl	%eax, -56(%rbp)
# t14 = 13
	movl	$13, -92(%rbp)
# t15 = 1
	movl	$1, -96(%rbp)
# if p == t14 goto .L2
	movl	-56(%rbp), %eax
	cmpl	-92(%rbp), %eax
	jne	.L5
	jmp	.L2
.L5:
# t15 = 0
	movl	$0, -96(%rbp)
# goto .L3
	jmp	.L3
# goto .L3
	jmp	.L3
# param .LC4
.L2:
# t16 = call printStr, 1
	movq	$.LC4, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -104(%rbp)
	addq	$4, %rsp
# goto .L3
	jmp	.L3
# param .LC5
.L3:
# t17 = call printStr, 1
	movq	$.LC5, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -112(%rbp)
	addq	$4, %rsp
# param p
# t18 = call printInt, 1
	movq	-56(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -116(%rbp)
	addq	$4, %rsp
# param .LC6
# t19 = call printStr, 1
	movq	$.LC6, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -124(%rbp)
	addq	$4, %rsp
# t20 = 0
	movl	$0, -128(%rbp)
# return t20
	movq	-128(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
