.data
	string: .space 50
	Message1: .asciiz "Nhap xau: "
	Message2: .asciiz "Do dai xau la: "
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
	jal get_length
 
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
	addi $s0, $s0, -1
	la $a1, ($s0)
	li $v0, 56
	syscall
