.data
	s1: .asciiz "The sum of "
	s2: .asciiz " and "
	s3: .asciiz " is "
.text
main:
    # Nhập giá trị cho $s0
    li $v0, 5 		# v0 = 5 read integer
    syscall
    move $s0, $v0 	# Lưu giá trị nhập vào vào $s0
    # Nhập giá trị cho $s1
    li $v0, 5 		# v0 = 5 read integer
    syscall
    move $s1, $v0 	# Lưu giá trị nhập vào vào $s1
    # Tính tổng của $s0 và $s1
    add $t0, $s0, $s1
    # In chuỗi "The sum of "
    li $v0, 4 		# v0 = 4 print string
    la $a0, s1
    syscall 
    # In giá trị của $s0
    li $v0, 1 		# v0 = 1 print integer
    move $a0, $s0
    syscall
    # In chuỗi " and "
    li $v0, 4 		# v0 = 4 print string
    la $a0, s2
    syscall
    # In giá trị của $s1
    li $v0, 1 		# v0 = 1 print integer
    move $a0, $s1
    syscall
    # In chuỗi " is "
    li $v0, 4 		# v0 = 4 print string
    la $a0, s3
    syscall
    # In kết quả của phép cộng
    li $v0, 1 		# v0 = 1 print integer
    move $a0, $t0
    syscall
    # Kết thúc chương trình
    li $v0, 10 		#exit
    syscall
