start: 
	li $s1, 1 		#i = 1
	li $s2, 3 		#j = 3
	slt $t0, $s2, $s1 	#$t0 = j < i ? 1 : 0 
	bne $t0, $zero, else 	#if(t0 != 0) goto "else"
	addi $t1, $t1, 1 	#x = x + 1 
	addi $t3, $zero, 1 	#z = 1 
	j endif 		#jump to endif
else: 
	addi $t2, $t2, -1 	#y = y - 1 
	add $t3, $t3, $t3 	#z = 2 * z 
endif:


#if(i <= j) 
#  x = x + 1; 
#  z = 1; 
#else 
#  y = y - 1; 
#  z = 2 * z;
