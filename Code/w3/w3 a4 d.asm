start: 
	add $t4, $s1, $s2 	#$t4 = i + j
	add $t5, $s3, $s4 	#$t5 = m + n
	slt $t0, $t4, $t5 	#$t0 = $t4 < $t5 ? 1 : 0 
	bne $t0, $zero, else 	#if(t0 != 0) goto "else"
	addi $t1, $t1, 1 	#x = x + 1 
	addi $t3, $zero, 1 	#z = 1 
	j endif 		#jump to endif
else: 
	addi $t2, $t2, -1 	#y = y - 1 
	add $t3, $t3, $t3 	#z = 2 * z 
endif:

#if(i + j > m + n)
