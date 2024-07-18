.data 
	A: .word -7, -4, -3, 0, 1, 4, 6
.text
	li $s1, 0 	#i = 0
	la $s2, A 	#s2 chua dia chi A
	li $s3, 7 	#n = 7
	li $s4, 1 	#step = 1
	li $s5, 0 	#max = 0
loop:
	beq $s1, $s3, finish 	#if(i == n) end
	add $t1, $s1, $s1 	#t1 = 2 * s1
	add $t1, $t1, $t1 	#t1 = 4 * s1
	add $t1,$t1,$s2 	#tinh dia chi A[i]
	lw $t0, 0($t1) 		#t0 = gia tri cua A[i]
	add $s1, $s1, $s4 	#i = i + step
	j sosanh0
sosanh0:
	bltz $t0, abs 		#if(t0 < 0) abs
	j sosanh
abs:
	sub $t0, $zero, $t0 	#abs cua t0
	j sosanh
sosanh:
	slt $t2, $s5, $t0 	#t2 = (max < t0) 1 : 0
	bne $t2, $zero, max 	#max < t0, max = t0
	beq $t2, $zero, loop 	#max >= t0, next
max:
	add $s5, $zero, $t0 	#max = t0
	j loop
finish:
