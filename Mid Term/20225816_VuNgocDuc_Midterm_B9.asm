.data
	in_le: .asciiz "Tong cac chu so le = "
	in_chan: .asciiz "\nTong cac chu so chan = "
.text
	li $v0, 5 		#read int
	syscall
	move $t0, $v0 		#t0 = N
	
	li $t1, 0 		#tong le
	li $t2, 0 		#tong chan
loop:
	beqz $t0, print 	#N = 0 => in
	rem $t3, $t0, 10 	#t3 = N % 10
	rem $t4, $t3, 2 	#t4 = t3 % 2
	beqz $t4, chan	
	j le
bo_so_cuoi:
	div $t0, $t0, 10 	#N /= 10
	j loop
le:
	add $t1, $t1, $t3 	#tong le += t3
	j bo_so_cuoi
chan:
	add $t2, $t2, $t3 	#tong chan += t3
	j bo_so_cuoi
print:
	li $v0, 4 		#in tong le
    	la $a0, in_le
    	syscall
	li $v0, 1
	move $a0, $t1
	syscall 
	
	li $v0, 4 		#in tong chan
    	la $a0, in_chan
    	syscall
	li $v0, 1
	move $a0, $t2 
	syscall
	
	li $v0, 10 		#exit
	syscall
