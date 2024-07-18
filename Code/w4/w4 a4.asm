.text
start:
	addi $s1, $zero, -2147483647
	addi $s2, $zero, -2

	li $t0, 0 		#No overflow
	addu $s3, $s1, $s2 	# s3 = s1 + s2
	xor $t1, $s1, $s2 	# S1, s2 have the same sign
	bltz $t1, EXIT 		# if not, exit
	xor $t2, $s3, $s1 	# s3, s1 have the same sign
	bltz $t2, OVERFLOW 	# if not, overflow
	j EXIT 
OVERFLOW:
	li $t0, 1
EXIT:
