	.file	"ass1.c"								            # source file name
	.text											            # start of text segment (executable code)
	.section	.rodata								            # read-only data section
	.align 8										            # align with 8-byte boundary
.LC0:												            # Label of f-string 1st printf
	.string	"Enter the string (all lowrer case): "
.LC1:												            # Label of f-string scanf
	.string	"%s"
.LC2:												            # Label of f-string 2nd printf
	.string	"Length of the string: %d\n"
	.align 8
.LC3:												            # Label of f-string 3rd printf
	.string	"The string in descending order: %s\n"
	.text											            # Code Starts
	.globl	main									            # Main is a Global name
	.type	main, @function                                     # Main is a function
main: # Main starts
.LFB0: 
	.cfi_startproc                                              # Call Frame Information
	endbr64
	pushq	%rbp                                                # Save old base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                                          # rbp <-- rsp set new stack base pointer
	.cfi_def_cfa_register 6
	subq	$64, %rsp                                           # Create space for local array and variables

    # printf("Enter the string (all lowrer case): ");
	leaq	.LC0(%rip), %rdi                                    # .LC0 + rip -> rdi, store 1st parameter of printf
	movl	$0, %eax                                            # 0->eax, clear eax
	call	printf@PLT                                          # Call printf
    
    # scanf("%s", str);
	leaq	-32(%rbp), %rax                                     # (rbp - 32) -> rax , str -> rax
	movq	%rax, %rsi                                          # rax -> rsi, store str , 2nd paraameter of scanf
	leaq	.LC1(%rip), %rdi                                    # .LC1 + rip -> rdi, store 1st parameter of scanf
	movl	$0, %eax                                            # 0->eax, clear eax
	call	__isoc99_scanf@PLT                                  # call scanf

    # len = length(str);
	leaq	-32(%rbp), %rax                                     # (rbp - 32) -> rax , str -> rax
	movq	%rax, %rdi                                          # rax -> rdi , store first parameter of length
	call	length                                              # call length
	movl	%eax, -4(%rbp)                                      # eax -> (rbp-4), assign return value of length to len

    # printf("Length of the string: %d\n", len);
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, len -> eax
	movl	%eax, %esi                                          # eax -> esi, store 2nd parameter of printf
	leaq	.LC2(%rip), %rdi                                    # .LC2 + rip -> rdi, store 1st parameter of printf
	movl	$0, %eax                                            # 0 -> eax, clear eax
	call	printf@PLT                                          # call printf

    # sort(str, len, dest);
	leaq	-64(%rbp), %rdx                                     # (rbp - 64) -> rdx , dest -> rdx , store third parameter of sort
	movl	-4(%rbp), %ecx                                      # (rbp - 4) -> ecx , len -> ecx
	leaq	-32(%rbp), %rax                                     # (rbp - 32) -> rax, str -> rax
	movl	%ecx, %esi                                          # ecx -> esi, store second parameter of sort
	movq	%rax, %rdi                                          # rax -> rdi, store first parameter of sort
	call	sort                                                # call sort

    # printf("The string in descending order: %s\n", dest);    
	leaq	-64(%rbp), %rax                                     # (rbp - 64) -> rax, dest -> rax
	movq	%rax, %rsi                                          # rax -> rsi, store second parameter of printf
	leaq	.LC3(%rip), %rdi                                    # .LC3 + rip -> rdi, store 1st parameter of printf
	movl	$0, %eax                                            # 0 -> eax, clear eax
	call	printf@PLT                                          # call printf
    # return 0;
	movl	$0, %eax                                            # 0 -> eax, clear eax
    leave
	.cfi_def_cfa 7, 8
	ret                                                         # return from main
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.globl	length                                              # length is a global name
	.type	length, @function                                   # length is a function
length: # length starts
.LFB1:
	.cfi_startproc                                              # Call Frame Information
	endbr64
	pushq	%rbp                                                # Save old base pointer of the caller function
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                                          # rbp <-- rsp set new stack base pointer of the called function
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)                                     # rdi -> (rbp - 24) , store first function parameter recieved
    
    # for (i = 0; str[i] != '\0'; i++)
	movl	$0, -4(%rbp)                                        # 0 -> (rbp -4) , clear (rbp -4), i=0
	
    # for (i = 0; str[i] != '\0'; i++)
    jmp	.L4                                                     # jump to .L4
.L5:
	addl	$1, -4(%rbp)                                        # (rbp -4) + 1 -> (rbp - 4), i+1 -> i
.L4:
    # for (i = 0; str[i] != '\0'; i++)
	movl	-4(%rbp), %eax                                      # (rbp -4) -> eax, i -> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rax + rdx) -> rax , str + i -> str[i] -> rax
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to eax
	testb	%al, %al                                            # performs a bitwise AND of al and al, to check for null character
	jne	.L5                                                     # increment i, if (al&al) not equal to zero
	movl	-4(%rbp), %eax                                      # (rbp -4) -> eax, i -> eax
	popq	%rbp                                                # pop the base pointer of the caller function and reset the rbp register
	.cfi_def_cfa 7, 8
	ret                                                         # return from length
	.cfi_endproc
.LFE1:
	.size	length, .-length
	.globl	sort                                                # sort is a global name
	.type	sort, @function                                     # sort is a function
sort: # sort starts
.LFB2:
	.cfi_startproc                                              # Call Frame Information
	endbr64
	pushq	%rbp                                                # Save old base pointer of the caller function
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                                          # rbp <-- rsp set new stack base pointer of the called function
	.cfi_def_cfa_register 6
	subq	$48, %rsp                                           # Create space for local array and variables
	movq	%rdi, -24(%rbp)                                     # rdi -> (rbp - 24), save first parameter(str) of sort
	movl	%esi, -28(%rbp)                                     # esi -> (rbp - 28), save second parameter(len) of sort
	movq	%rdx, -40(%rbp)                                     # rdx -> (rbp - 40), save third parameter(dest) of sort
	
    # for (i = 0; i < len; i++)
    movl	$0, -4(%rbp)                                        # 0 -> (rbp-4), clear
	jmp	.L8                                                     # Uncoditional jump to .L8
.L12:
    # for (j = 0; j < len; j++)
	movl	$0, -8(%rbp)                                        # 0-> (rbp - 8), clear
	jmp	.L9                                                     # Uncoditional jump to .L9
.L11:
    # if (str[i] < str[j])
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, i-> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp - 24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + i -> str[i] -> rax
	movzbl	(%rax), %edx                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to edx
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j-> eax
	movslq	%eax, %rcx                                          # eax -> rcx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rcx, %rax                                          # (rcx + rax) -> rax, str + j -> str[j] -> rax
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to eax
	cmpb	%al, %dl                                            # comparing smallest parts of eax and edx
	jge	.L10                                                    # Jump if str[i] >= str[j]
	
	# temp = str[i];
	movl	-4(%rbp), %eax                                      # else, (rbp-4) -> eax, i -> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + i -> str[i] -> rax
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to eax
	movb	%al, -9(%rbp)                                       # al -> (rbp - 9) , Least significant 8-bits(char) of eax -> (rbp -9), which is equivalent to temp = str[i]
	
	# str[i] = str[j];
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j-> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + j -> str[j] -> rax
	movl	-4(%rbp), %edx                                      # (rbp - 4) -> edx, i -> edx
	movslq	%edx, %rcx                                          # edx -> rcx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rdx                                     # (rbp -24) -> rdx , str -> rdx
	addq	%rcx, %rdx                                          # (rdx + rcx) -> rdx, str + i -> str[i] -> rdx
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[j] to eax
	movb	%al, (%rdx)                                         # al -> rdx, str[j] -> (rdx), which is equivalent to str[i] = str[j]
	
	# str[j] = temp;
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j-> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rax, %rdx                                          # (rdx + rax) -> rdx, str + j -> str[j] -> rdx
	movzbl	-9(%rbp), %eax                                      # copy the lower 8 bits of source to destination, copying the char value of temp to eax
	movb	%al, (%rdx)                                         # al -> rdx, temp -> (rdx), which is equivalent to str[j] = temp
.L10:
	# j++ 
	addl	$1, -8(%rbp)                                        # (rbp - 8) + 1 -> (rbp - 8), j = j+1
.L9:
    # for (j = 0; j < len; j++)
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j -> eax
	cmpl	-28(%rbp), %eax                                     # compare j and len
	jl	.L11                                                    # if j < len , jump to .L11
	addl	$1, -4(%rbp)                                        # else i = i+1
.L8:
    # for (i = 0; i < len; i++)
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, i -> eax
	cmpl	-28(%rbp), %eax                                     # compare i and len
	jl	.L12                                                    # if i < len , jump to .L12
    
    # reverse(str, len, dest);
	movq	-40(%rbp), %rdx                                     # (rbp - 40) -> rdx, store third parameter(dest) of reverse
	movl	-28(%rbp), %ecx                                     # (rbp - 28) -> ecx, store second parameter(len) of reverse
	movq	-24(%rbp), %rax                                     # (rbp - 24) -> rbp, store first parameter(str) of reverse
	movl	%ecx, %esi                                          # ecx -> esi, as esi is the register to store the second parameter of a function
	movq	%rax, %rdi                                          # rax -> rdi, as rdi is the register to store the first parameter of a function
	call	reverse                                             # call reverse
	nop                                                         # NO operation aka nop
	leave
	.cfi_def_cfa 7, 8
	ret                                                         # return from sort
	.cfi_endproc
.LFE2:
	.size	sort, .-sort
	.globl	reverse                                             # reverse is a global name
	.type	reverse, @function                                  # reverse is a function
reverse: #reverse starts
.LFB3:
	.cfi_startproc                                              # Call Frame Information
	endbr64
	pushq	%rbp                                                # Save old base pointer of the caller function
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                                          # rbp <-- rsp set new stack base pointer of the called function
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)                                     # rdi -> (rbp - 24), save first parameter(str) of reverse
	movl	%esi, -28(%rbp)                                     # esi -> (rbp - 28), save second parameter(len) of reverse
	movq	%rdx, -40(%rbp)                                     # rdx -> (rbp - 40), save third parameter(dest) of reverse

    # for (i = 0; i < len / 2; i++)
	movl	$0, -4(%rbp)                                        # 0 -> (rbp - 4), clear
	jmp	.L14                                                    # Uncoditional jump to .L14
.L19:

    # for (j = len - i - 1; j >= len / 2; j--)
	movl	-28(%rbp), %eax                                     # (rbp - 28) -> eax, len -> eax
	subl	-4(%rbp), %eax                                      # eax - (rbp - 4) -> eax, Subtract i from len, len - i -> eax
	subl	$1, %eax                                            # eax - 1 -> eax, len - i - 1 -> eax
	movl	%eax, -8(%rbp)                                      # eax -> (rbp - 8), len - i - 1 -> j
	nop                                                         # NO operation aka nop
	movl	-28(%rbp), %eax                                     # (rbp - 28) -> eax, len -> eax
	movl	%eax, %edx                                          # eax -> edx
	
	# len / 2 -> edx
	shrl	$31, %edx                                           # unsigned bitwise right shift of edx by 31 bits
                                                                # to help in calculation of len/2
	addl	%edx, %eax                                          # edx + eax -> eax
	sarl	%eax                                                # arithmetic bitwise right shift of eax by 1 bit
	cmpl	%eax, -8(%rbp)                                      # compare eax and (rbp - 8), len / 2 and j
	jl	.L17                                                    # if eax < (rbp - 8), (if j >= len/2) jump tp .L17
	# if (i == j)
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, i -> eax
	cmpl	-8(%rbp), %eax                                      # compare (rbp - 8) , eax, compare j and i
	je	.L22                                                    # if equal, jump to .L22
	
	# temp = str[i];
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, i -> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp - 24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + j -> str[j] -> rax
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to eax
	movb	%al, -9(%rbp)                                       # al -> (rbp - 9) , Least significant 8-bits(char) of eax -> (rbp -9), which is equivalent to temp = str[i]
	
	# str[i] = str[j];
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j-> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp - 24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + j -> str[j] -> rax
	movl	-4(%rbp), %edx                                      # (rbp - 4) -> edx, i -> edx
	movslq	%edx, %rcx                                          # edx -> rcx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rdx                                     # (rbp - 24) -> rdx , str -> rdx
	addq	%rcx, %rdx                                          # (rcx + rdx) -> rdx, str + i -> str[i] -> rdx
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[j] to eax
	movb	%al, (%rdx)                                         # al -> rdx, str[j] -> (rdx), which is equivalent to str[i] = str[j]
	
	# str[j] = temp;
	movl	-8(%rbp), %eax                                      # (rbp - 8) -> eax, j-> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp -24) -> rax , str -> rax
	addq	%rax, %rdx                                          # (rdx + rax) -> rax, str + j -> str[j] -> rax
	movzbl	-9(%rbp), %eax                                      # copy the lower 8 bits of source to destination, copying the char value of temp to eax
	movb	%al, (%rdx)                                         # al -> rdx, temp -> (rdx), which is equivalent to str[j] = temp
	
	# break;
	jmp	.L17                                                    # Uncoditional jump to .L17
.L22:
	nop                                                         # NO operation aka nop
.L17:
    # for (i = 0; i < len / 2; i++)
	addl	$1, -4(%rbp)                                        # (rbp - 4) + 1 -> (rbp - 4), i++
.L14:
    # for (i = 0; i < len / 2; i++)
	movl	-28(%rbp), %eax                                     # (rbp - 28) -> eax, len -> eax
	movl	%eax, %edx                                          # eax -> edx
	
	# len / 2 -> edx
	shrl	$31, %edx                                           # unsigned bitwise right shift of edx by 31 bits
                                                                # to help in calculation of len/2 
	addl	%edx, %eax                                          # edx + eax -> eax
	sarl	%eax                                                # arithmetic bitwise right shift of eax by 1 bit
	cmpl	%eax, -4(%rbp)                                      # compare eax and (rbp - 4), len/2 and i
	jl	.L19                                                    # if eax < (rbp - 4), jump tp .L19, if i < len/2
	
	# for (i = 0; i < len; i++)
	movl	$0, -4(%rbp)                                        # 0 -> (rbp -4), clear
	jmp	.L20                                                    # Uncoditional jump to .L20
.L21:
    # dest[i] = str[i];
	movl	-4(%rbp), %eax                                      # (rbp - 28) -> eax, len -> eax
	movslq	%eax, %rdx                                          # eax -> rdx , move 32-bit source to 64-bit destination
	movq	-24(%rbp), %rax                                     # (rbp - 24) -> rax , str -> rax
	addq	%rdx, %rax                                          # (rdx + rax) -> rax, str + j -> str[j] -> rax
	movl	-4(%rbp), %edx                                      # (rbp - 4) -> edx, i -> edx
	movslq	%edx, %rcx                                          # edx -> rcx , move 32-bit source to 64-bit destination
	movq	-40(%rbp), %rdx                                     # (rbp - 40) -> rdx , dest -> rdx
	addq	%rcx, %rdx                                          # (rcx + rdx) -> rdx
	movzbl	(%rax), %eax                                        # copy the lower 8 bits of source to destination, copying the char value of str[i] to eax
	movb	%al, (%rdx)                                         # al -> rdx, str[j] -> (rdx), which is equivalent to dest[i] = str[i]
	
	# i++
	addl	$1, -4(%rbp)                                        # (rbp - 4) + 1 -> (rbp - 4), i = i+1
.L20:
    # for (i = 0; i < len; i++)
	movl	-4(%rbp), %eax                                      # (rbp - 4) -> eax, i -> eax
	cmpl	-28(%rbp), %eax                                     # compare (rbp -28) , eax, len and i
	jl	.L21                                                    # if (rbp - 28) > eax, if( i < len)
	nop                                                         # NO operation aka nop
	nop                                                         # NO operation aka nop
	popq	%rbp                                                # pop the base pointer of the caller function and reset the rbp register
	.cfi_def_cfa 7, 8
	ret                                                         # return from reverse
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
