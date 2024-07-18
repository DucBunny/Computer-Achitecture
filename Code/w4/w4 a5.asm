.text 
	addi $s1, $zero, 4096 
	addi $s2, $zero, 4 
	addi $t1, $zero, 1 
loop:
	beq $s1, $t1, exit 
	sll $s2, $s2, 1 
	sra $s1, $s1, 1 
	j loop
exit:
