.data
	space: .asciiz " " 	#dau cach
.text
	li $v0, 5 		#read int
	syscall
	move $t1, $v0 		#t1 = N
	
	li $t2, 0 		#bien dem i = 0
loop:
	addi $t2, $t2, 1 	#i += 1
	slt $s1, $t2, $t1 	#s1 = (i < N) ? 1 : 0
	bne $s1, $zero, check3
	j exit
check3:
	rem $t3, $t2, 3 	#t3 = t2 % 3
	beqz $t3, print
	bnez $t3, check5
check5:
	rem $t4, $t2, 5 	#t4 = t2 % 5
	beqz $t4, print
	j loop
print: 
	move $a0, $t2 
	li $v0, 1 		#in i thoa man
	syscall 
	
	li $v0, 4 		#in space
        la $a0, space 
        syscall
        
        j loop
exit: 
	li $v0, 10
	syscall
