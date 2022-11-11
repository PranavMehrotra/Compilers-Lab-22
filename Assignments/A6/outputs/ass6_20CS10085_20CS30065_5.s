.section	.rodata
.LC0:
	.string " "
.LC1:
	.string "\n"
.LC2:
	.string "Merge Sort\n"
.LC3:
	.string "Original array: \n"
.LC4:
	.string "Sorted array: \n"
# printStr: 
# printInt: 
# readInt: 
# merge: 
# merge_sort: 

	.text
	.globl	merge_sort
	.type	merge_sort, @function
merge_sort:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
# t0 = 1
	movl	$1, -4(%rbp)
# if l < r goto .L0
	movl	24(%rbp), %eax
	cmpl	32(%rbp), %eax
	jge	.L25
	jmp	.L0
.L25:
# t0 = 0
	movl	$0, -4(%rbp)
# goto .L1
	jmp	.L1
# goto .L1
	jmp	.L1
# t1 = l + r
.L0:
	movl	24(%rbp), %eax
	movl	32(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
# t2 = 2
	movl	$2, -12(%rbp)
# t3 = t1 / t2
	movl	-8(%rbp), %eax
	cltd
	idivl	-12(%rbp)
	movl	%eax, -16(%rbp)
# m = t3
	movl	-16(%rbp), %eax
	movl	%eax, -20(%rbp)
# param a
# param l
# param m
# call merge_sort, 3
	movq	-20(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	movq	16(%rbp), %rdi
	movq	%rdi, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	merge_sort
	addq	$16, %rsp
# t6 = 1
	movl	$1, -36(%rbp)
# t7 = m + t6
	movl	-20(%rbp), %eax
	movl	-36(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -40(%rbp)
# param a
# param t7
# param r
# call merge_sort, 3
	movq	32(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdx
	movq	-40(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	movq	16(%rbp), %rdi
	movq	%rdi, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	merge_sort
	addq	$16, %rsp
# param a
# param l
# param m
# param r
# t9 = call merge, 4
	movq	32(%rbp), %rax
	pushq	%rax
	movq	%rax, %rcx
	movq	-20(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	movq	16(%rbp), %rdi
	movq	%rdi, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	merge
	movq	%rax, -52(%rbp)
	addq	$20, %rsp
# goto .L1
	jmp	.L1
# function merge_sort ends
.L1:
	leave
	ret
	.size	merge_sort, .-merge_sort
# print_arr: 

	.text
	.globl	print_arr
	.type	print_arr, @function
print_arr:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
# t10 = 0
	movl	$0, -8(%rbp)
# i = t10
	movl	-8(%rbp), %eax
	movl	%eax, -4(%rbp)
# t11 = 1
.L4:
	movl	$1, -12(%rbp)
# if i < n goto .L2
	movl	-4(%rbp), %eax
	cmpl	24(%rbp), %eax
	jge	.L26
	jmp	.L2
.L26:
# t11 = 0
	movl	$0, -12(%rbp)
# goto .L3
	jmp	.L3
# goto .L3
	jmp	.L3
# t12 = i
.L5:
	movl	-4(%rbp), %eax
	movl	%eax, -16(%rbp)
# i = i + 1
	movl	-4(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -4(%rbp)
# goto .L4
	jmp	.L4
# t13 = 0
.L2:
	movl	$0, -24(%rbp)
# t14 = i
	movl	-4(%rbp), %eax
	movl	%eax, -28(%rbp)
# t14 = t14 * 4
	movl	-28(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -28(%rbp)
# t13 = t14
	movl	-28(%rbp), %eax
	movl	%eax, -24(%rbp)
# t15 = a[t13]
	movl	-24(%rbp), %edx
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movq	(%rdx) ,%rax
	movq	%rax, -32(%rbp)
# param t15
# t16 = call printInt, 1
	movq	-32(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -36(%rbp)
	addq	$4, %rsp
# param .LC0
# t17 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -48(%rbp)
	addq	$4, %rsp
# goto .L5
	jmp	.L5
# param .LC1
.L3:
# t18 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -56(%rbp)
	addq	$4, %rsp
# function print_arr ends
	leave
	ret
	.size	print_arr, .-print_arr
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$208, %rsp
# param .LC2
# t19 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -12(%rbp)
	addq	$4, %rsp
# t20 = 6
	movl	$6, -16(%rbp)
# n = t20
	movl	-16(%rbp), %eax
	movl	%eax, -20(%rbp)
# t21 = 6
	movl	$6, -24(%rbp)
# t22 = 0
	movl	$0, -52(%rbp)
# t23 = 0
	movl	$0, -56(%rbp)
# t24 = t22
	movl	-52(%rbp), %eax
	movl	%eax, -60(%rbp)
# t24 = t24 * 4
	movl	-60(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -60(%rbp)
# t23 = t24
	movl	-60(%rbp), %eax
	movl	%eax, -56(%rbp)
# t25 = 123
	movl	$123, -64(%rbp)
# a[t23] = t25
	movl	-56(%rbp), %edx
	movl	-64(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# t26 = 1
	movl	$1, -68(%rbp)
# t27 = 0
	movl	$0, -72(%rbp)
# t28 = t26
	movl	-68(%rbp), %eax
	movl	%eax, -76(%rbp)
# t28 = t28 * 4
	movl	-76(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -76(%rbp)
# t27 = t28
	movl	-76(%rbp), %eax
	movl	%eax, -72(%rbp)
# t29 = 1
	movl	$1, -80(%rbp)
# a[t27] = t29
	movl	-72(%rbp), %edx
	movl	-80(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# t30 = 2
	movl	$2, -84(%rbp)
# t31 = 0
	movl	$0, -88(%rbp)
# t32 = t30
	movl	-84(%rbp), %eax
	movl	%eax, -92(%rbp)
# t32 = t32 * 4
	movl	-92(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -92(%rbp)
# t31 = t32
	movl	-92(%rbp), %eax
	movl	%eax, -88(%rbp)
# t33 = 34
	movl	$34, -96(%rbp)
# a[t31] = t33
	movl	-88(%rbp), %edx
	movl	-96(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# t34 = 3
	movl	$3, -100(%rbp)
# t35 = 0
	movl	$0, -104(%rbp)
# t36 = t34
	movl	-100(%rbp), %eax
	movl	%eax, -108(%rbp)
# t36 = t36 * 4
	movl	-108(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -108(%rbp)
# t35 = t36
	movl	-108(%rbp), %eax
	movl	%eax, -104(%rbp)
# t37 = 3212
	movl	$3212, -112(%rbp)
# a[t35] = t37
	movl	-104(%rbp), %edx
	movl	-112(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# t38 = 4
	movl	$4, -116(%rbp)
# t39 = 0
	movl	$0, -120(%rbp)
# t40 = t38
	movl	-116(%rbp), %eax
	movl	%eax, -124(%rbp)
# t40 = t40 * 4
	movl	-124(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -124(%rbp)
# t39 = t40
	movl	-124(%rbp), %eax
	movl	%eax, -120(%rbp)
# t41 = 344
	movl	$344, -128(%rbp)
# a[t39] = t41
	movl	-120(%rbp), %edx
	movl	-128(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# t42 = 5
	movl	$5, -132(%rbp)
# t43 = 0
	movl	$0, -136(%rbp)
# t44 = t42
	movl	-132(%rbp), %eax
	movl	%eax, -140(%rbp)
# t44 = t44 * 4
	movl	-140(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -140(%rbp)
# t43 = t44
	movl	-140(%rbp), %eax
	movl	%eax, -136(%rbp)
# t45 = 2
	movl	$2, -144(%rbp)
# a[t43] = t45
	movl	-136(%rbp), %edx
	movl	-144(%rbp), %eax
cltq
	movl	%eax, -48(%rbp,%rdx,1)
# param .LC3
# t46 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -152(%rbp)
	addq	$4, %rsp
# param a
# param n
# call print_arr, 2
	movq	-20(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	leaq	-48(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	print_arr
	addq	$12, %rsp
# t49 = 0
	movl	$0, -172(%rbp)
# t50 = 1
	movl	$1, -176(%rbp)
# t51 = n - t50
	movl	-20(%rbp), %edx
	movl	-176(%rbp), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -180(%rbp)
# param a
# param t49
# param t51
# call merge_sort, 3
	movq	-180(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdx
	movq	-172(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	leaq	-48(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	merge_sort
	addq	$16, %rsp
# param .LC4
# t52 = call printStr, 1
	movq	$.LC4, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -188(%rbp)
	addq	$4, %rsp
# param a
# param n
# call print_arr, 2
	movq	-20(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	leaq	-48(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	print_arr
	addq	$12, %rsp
# t54 = 0
	movl	$0, -196(%rbp)
# return t54
	movq	-196(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
# merge: 

	.text
	.globl	merge
	.type	merge, @function
merge:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$352, %rsp
# t55 = mid - l
	movl	32(%rbp), %edx
	movl	24(%rbp), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -16(%rbp)
# t56 = 1
	movl	$1, -20(%rbp)
# t57 = t55 + t56
	movl	-16(%rbp), %eax
	movl	-20(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -24(%rbp)
# n1 = t57
	movl	-24(%rbp), %eax
	movl	%eax, -28(%rbp)
# t58 = r - mid
	movl	40(%rbp), %edx
	movl	32(%rbp), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -32(%rbp)
# n2 = t58
	movl	-32(%rbp), %eax
	movl	%eax, -36(%rbp)
# t59 = 6
	movl	$6, -40(%rbp)
# t60 = 6
	movl	$6, -44(%rbp)
# t61 = 0
	movl	$0, -96(%rbp)
# i = t61
	movl	-96(%rbp), %eax
	movl	%eax, -4(%rbp)
# t62 = 1
.L8:
	movl	$1, -100(%rbp)
# if i < n1 goto .L6
	movl	-4(%rbp), %eax
	cmpl	-28(%rbp), %eax
	jge	.L27
	jmp	.L6
.L27:
# t62 = 0
	movl	$0, -100(%rbp)
# goto .L7
	jmp	.L7
# goto .L7
	jmp	.L7
# t63 = i
.L9:
	movl	-4(%rbp), %eax
	movl	%eax, -104(%rbp)
# i = i + 1
	movl	-4(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -4(%rbp)
# goto .L8
	jmp	.L8
# t64 = 0
.L6:
	movl	$0, -108(%rbp)
# t65 = i
	movl	-4(%rbp), %eax
	movl	%eax, -112(%rbp)
# t65 = t65 * 4
	movl	-112(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -112(%rbp)
# t64 = t65
	movl	-112(%rbp), %eax
	movl	%eax, -108(%rbp)
# t66 = l + i
	movl	24(%rbp), %eax
	movl	-4(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -116(%rbp)
# t67 = 0
	movl	$0, -120(%rbp)
# t68 = t66
	movl	-116(%rbp), %eax
	movl	%eax, -124(%rbp)
# t68 = t68 * 4
	movl	-124(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -124(%rbp)
# t67 = t68
	movl	-124(%rbp), %eax
	movl	%eax, -120(%rbp)
# t69 = a[t67]
	movl	-120(%rbp), %edx
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movq	(%rdx) ,%rax
	movq	%rax, -128(%rbp)
# left[t64] = t69
	movl	-108(%rbp), %edx
	movl	-128(%rbp), %eax
cltq
	movl	%eax, -68(%rbp,%rdx,1)
# goto .L9
	jmp	.L9
# t70 = 0
.L7:
	movl	$0, -132(%rbp)
# j = t70
	movl	-132(%rbp), %eax
	movl	%eax, -8(%rbp)
# t71 = 1
.L12:
	movl	$1, -136(%rbp)
# if j < n2 goto .L10
	movl	-8(%rbp), %eax
	cmpl	-36(%rbp), %eax
	jge	.L28
	jmp	.L10
.L28:
# t71 = 0
	movl	$0, -136(%rbp)
# goto .L11
	jmp	.L11
# goto .L11
	jmp	.L11
# t72 = j
.L13:
	movl	-8(%rbp), %eax
	movl	%eax, -140(%rbp)
# j = j + 1
	movl	-8(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
# goto .L12
	jmp	.L12
# t73 = mid + j
.L10:
	movl	32(%rbp), %eax
	movl	-8(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -144(%rbp)
# t74 = 1
	movl	$1, -148(%rbp)
# t75 = t73 + t74
	movl	-144(%rbp), %eax
	movl	-148(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -152(%rbp)
# q = t75
	movl	-152(%rbp), %eax
	movl	%eax, -156(%rbp)
# t76 = 0
	movl	$0, -160(%rbp)
# t77 = j
	movl	-8(%rbp), %eax
	movl	%eax, -164(%rbp)
# t77 = t77 * 4
	movl	-164(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -164(%rbp)
# t76 = t77
	movl	-164(%rbp), %eax
	movl	%eax, -160(%rbp)
# t78 = 0
	movl	$0, -168(%rbp)
# t79 = q
	movl	-156(%rbp), %eax
	movl	%eax, -172(%rbp)
# t79 = t79 * 4
	movl	-172(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -172(%rbp)
# t78 = t79
	movl	-172(%rbp), %eax
	movl	%eax, -168(%rbp)
# t80 = a[t78]
	movl	-168(%rbp), %edx
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movq	(%rdx) ,%rax
	movq	%rax, -176(%rbp)
# right[t76] = t80
	movl	-160(%rbp), %edx
	movl	-176(%rbp), %eax
cltq
	movl	%eax, -92(%rbp,%rdx,1)
# goto .L13
	jmp	.L13
# t81 = 0
.L11:
	movl	$0, -180(%rbp)
# i = t81
	movl	-180(%rbp), %eax
	movl	%eax, -4(%rbp)
# t82 = 0
	movl	$0, -184(%rbp)
# j = t82
	movl	-184(%rbp), %eax
	movl	%eax, -8(%rbp)
# k = l
	movl	24(%rbp), %eax
	movl	%eax, -12(%rbp)
# t83 = 1
.L20:
	movl	$1, -188(%rbp)
# if i < n1 goto .L14
	movl	-4(%rbp), %eax
	cmpl	-28(%rbp), %eax
	jge	.L29
	jmp	.L14
.L29:
# t83 = 0
	movl	$0, -188(%rbp)
# goto .L15
	jmp	.L15
# t84 = 1
.L14:
	movl	$1, -192(%rbp)
# if j < n2 goto .L16
	movl	-8(%rbp), %eax
	cmpl	-36(%rbp), %eax
	jge	.L30
	jmp	.L16
.L30:
# t84 = 0
	movl	$0, -192(%rbp)
# goto .L15
	jmp	.L15
# goto .L15
	jmp	.L15
# t85 = 0
.L16:
	movl	$0, -196(%rbp)
# t86 = i
	movl	-4(%rbp), %eax
	movl	%eax, -200(%rbp)
# t86 = t86 * 4
	movl	-200(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -200(%rbp)
# t85 = t86
	movl	-200(%rbp), %eax
	movl	%eax, -196(%rbp)
# t87 = left[t85]
	movl	-196(%rbp), %edx
cltq
	movl	-68(%rbp,%rdx,1), %eax
	movl	%eax, -204(%rbp)
# t88 = 0
	movl	$0, -208(%rbp)
# t89 = j
	movl	-8(%rbp), %eax
	movl	%eax, -212(%rbp)
# t89 = t89 * 4
	movl	-212(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -212(%rbp)
# t88 = t89
	movl	-212(%rbp), %eax
	movl	%eax, -208(%rbp)
# t90 = right[t88]
	movl	-208(%rbp), %edx
cltq
	movl	-92(%rbp,%rdx,1), %eax
	movl	%eax, -216(%rbp)
# t91 = 1
	movl	$1, -220(%rbp)
# if t87 <= t90 goto .L17
	movl	-204(%rbp), %eax
	cmpl	-216(%rbp), %eax
	jg	.L31
	jmp	.L17
.L31:
# t91 = 0
	movl	$0, -220(%rbp)
# goto .L18
	jmp	.L18
# goto .L19
	jmp	.L19
# t92 = 0
.L17:
	movl	$0, -224(%rbp)
# t93 = k
	movl	-12(%rbp), %eax
	movl	%eax, -228(%rbp)
# t93 = t93 * 4
	movl	-228(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -228(%rbp)
# t92 = t93
	movl	-228(%rbp), %eax
	movl	%eax, -224(%rbp)
# t94 = 0
	movl	$0, -232(%rbp)
# t95 = i
	movl	-4(%rbp), %eax
	movl	%eax, -236(%rbp)
# t95 = t95 * 4
	movl	-236(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -236(%rbp)
# t94 = t95
	movl	-236(%rbp), %eax
	movl	%eax, -232(%rbp)
# t96 = left[t94]
	movl	-232(%rbp), %edx
cltq
	movl	-68(%rbp,%rdx,1), %eax
	movl	%eax, -240(%rbp)
# a[t92] = t96
	movl	-224(%rbp), %edx
	movl	-240(%rbp), %eax
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movl	%eax, (%rdx)
# t97 = i
	movl	-4(%rbp), %eax
	movl	%eax, -244(%rbp)
# i = i + 1
	movl	-4(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -4(%rbp)
# goto .L19
	jmp	.L19
# t98 = 0
.L18:
	movl	$0, -248(%rbp)
# t99 = k
	movl	-12(%rbp), %eax
	movl	%eax, -252(%rbp)
# t99 = t99 * 4
	movl	-252(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -252(%rbp)
# t98 = t99
	movl	-252(%rbp), %eax
	movl	%eax, -248(%rbp)
# t100 = 0
	movl	$0, -256(%rbp)
# t101 = j
	movl	-8(%rbp), %eax
	movl	%eax, -260(%rbp)
# t101 = t101 * 4
	movl	-260(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -260(%rbp)
# t100 = t101
	movl	-260(%rbp), %eax
	movl	%eax, -256(%rbp)
# t102 = right[t100]
	movl	-256(%rbp), %edx
cltq
	movl	-92(%rbp,%rdx,1), %eax
	movl	%eax, -264(%rbp)
# a[t98] = t102
	movl	-248(%rbp), %edx
	movl	-264(%rbp), %eax
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movl	%eax, (%rdx)
# t103 = j
	movl	-8(%rbp), %eax
	movl	%eax, -268(%rbp)
# j = j + 1
	movl	-8(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
# goto .L19
	jmp	.L19
# t104 = k
.L19:
	movl	-12(%rbp), %eax
	movl	%eax, -272(%rbp)
# k = k + 1
	movl	-12(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -12(%rbp)
# goto .L20
	jmp	.L20
# t105 = 1
.L15:
	movl	$1, -276(%rbp)
# if i < n1 goto .L21
	movl	-4(%rbp), %eax
	cmpl	-28(%rbp), %eax
	jge	.L32
	jmp	.L21
.L32:
# t105 = 0
	movl	$0, -276(%rbp)
# goto .L22
	jmp	.L22
# goto .L22
	jmp	.L22
# t106 = 0
.L21:
	movl	$0, -280(%rbp)
# t107 = k
	movl	-12(%rbp), %eax
	movl	%eax, -284(%rbp)
# t107 = t107 * 4
	movl	-284(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -284(%rbp)
# t106 = t107
	movl	-284(%rbp), %eax
	movl	%eax, -280(%rbp)
# t108 = 0
	movl	$0, -288(%rbp)
# t109 = i
	movl	-4(%rbp), %eax
	movl	%eax, -292(%rbp)
# t109 = t109 * 4
	movl	-292(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -292(%rbp)
# t108 = t109
	movl	-292(%rbp), %eax
	movl	%eax, -288(%rbp)
# t110 = left[t108]
	movl	-288(%rbp), %edx
cltq
	movl	-68(%rbp,%rdx,1), %eax
	movl	%eax, -296(%rbp)
# a[t106] = t110
	movl	-280(%rbp), %edx
	movl	-296(%rbp), %eax
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movl	%eax, (%rdx)
# t111 = i
	movl	-4(%rbp), %eax
	movl	%eax, -300(%rbp)
# i = i + 1
	movl	-4(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -4(%rbp)
# t112 = k
	movl	-12(%rbp), %eax
	movl	%eax, -304(%rbp)
# k = k + 1
	movl	-12(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -12(%rbp)
# goto .L15
	jmp	.L15
# t113 = 1
.L22:
	movl	$1, -308(%rbp)
# if j < n2 goto .L23
	movl	-8(%rbp), %eax
	cmpl	-36(%rbp), %eax
	jge	.L33
	jmp	.L23
.L33:
# t113 = 0
	movl	$0, -308(%rbp)
# goto .L24
	jmp	.L24
# goto .L24
	jmp	.L24
# t114 = 0
.L23:
	movl	$0, -312(%rbp)
# t115 = k
	movl	-12(%rbp), %eax
	movl	%eax, -316(%rbp)
# t115 = t115 * 4
	movl	-316(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -316(%rbp)
# t114 = t115
	movl	-316(%rbp), %eax
	movl	%eax, -312(%rbp)
# t116 = 0
	movl	$0, -320(%rbp)
# t117 = j
	movl	-8(%rbp), %eax
	movl	%eax, -324(%rbp)
# t117 = t117 * 4
	movl	-324(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -324(%rbp)
# t116 = t117
	movl	-324(%rbp), %eax
	movl	%eax, -320(%rbp)
# t118 = right[t116]
	movl	-320(%rbp), %edx
cltq
	movl	-92(%rbp,%rdx,1), %eax
	movl	%eax, -328(%rbp)
# a[t114] = t118
	movl	-312(%rbp), %edx
	movl	-328(%rbp), %eax
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movl	%eax, (%rdx)
# t119 = j
	movl	-8(%rbp), %eax
	movl	%eax, -332(%rbp)
# j = j + 1
	movl	-8(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
# t120 = k
	movl	-12(%rbp), %eax
	movl	%eax, -336(%rbp)
# k = k + 1
	movl	-12(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -12(%rbp)
# goto .L22
	jmp	.L22
# t121 = 0
.L24:
	movl	$0, -340(%rbp)
# return t121
	movq	-340(%rbp), %rax
	leave
	ret
# function merge ends
	leave
	ret
	.size	merge, .-merge
