.data
	string: .space 50
	stringdao: .space 50
	Message1: .asciiz "Nhap xau: "
	Message2: .asciiz "Reverse: "
.text
main:
get_string:
	li $v0, 4 	# print string
	la $a0, Message1
	syscall 
	
	li $v0, 8 	#read string
	la $a0, string
	li $a1, 50 	#max length
	syscall
 
get_length:
	la $a0,string 		# $a0 = address(string[0])
	add $t0,$zero,$zero 	# $t0 = i = 0
	add $v0,$zero,$zero 	# $v0 = length = 0
check_char: 
	add $t1,$a0,$t0 	# $t1 = $a0 + $t0
 				# = address(string[i])
 	lb $t2, 0($t1) 		# $t2 = string[i]
 	beq $t2, $zero, end_of_str 	# is null char? 
 	addi $s0, $s0, 1 	# v0 = v0 + 1 -> length = length + 1
 	addi $t0, $t0, 1 	# $t0 = $t0 + 1 -> i = i + 1
 	j check_char
end_of_str:
reverse:
	la $a1, stringdao
	add $s0, $s0, -1
	add $s1, $zero, $zero
L1:
	add $t3, $s0, $a0
	lb $t4, 0($t3)
	add $t5, $s1, $a1
	sb $t4, 0($t5)
	beq $t4, $zero, end_of_reverse
	nop
	addi $s0, $s0, -1
	addi $s1, $s1, 1
	j L1
	nop
end_of_reverse:
	li $v0, 59
	la $a0, Message2
	syscall
