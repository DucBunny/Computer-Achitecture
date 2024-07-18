.data
	array: .word 0:10 		# Khởi tạo mảng 10 phần tử
	minEven: .word 0x7FFFFFFF 	# Khởi tạo giá trị nhỏ nhất cho số chẵn
	maxOdd: .word 0x80000000 	# Khởi tạo giá trị lớn nhất cho số lẻ
.text
main:
    	# Nhập mảng
    	la $t0, array 		# Load địa chỉ của mảng vào $t0
    	li $t1, 10 		# Số lượng phần tử trong mảng
    	li $s0, 0xFFFFFFFF
    	li $s1, 0x7FFFFFFF
input_loop:
    	li $v0, 5 		# syscall để nhập số nguyên
    	syscall
    	sw $v0, 0($t0) 		# Lưu giá trị vào mảng
    	addiu $t0, $t0, 4 	# Tăng địa chỉ mảng
    	addiu $t1, $t1, -1 	# Giảm số lượng phần tử
    	bnez $t1, input_loop 	# Nếu còn phần tử, quay lại vòng lặp

    	# Tìm số chẵn nhỏ nhất lớn hơn tất cả số lẻ
    	la $t0, array 		# Load địa chỉ của mảng vào $t0
    	li $t1, 10 		# Số lượng phần tử trong mảng
find_loop:
    	lw $t2, 0($t0) 		# Load giá trị từ mảng
    	andi $t3, $t2, 1 	# Kiểm tra số lẻ
    	beqz $t3, even 		# Nếu số chẵn, nhảy đến nhãn 'even'
    	# Xử lý số lẻ
    	slt $t3, $t2, $s0 	# So sánh với maxOdd
    	beqz $t3, update 	# Nếu nhỏ hơn, nhảy đến nhãn 'update'
    	move $s0, $t2 		# Cập nhật maxOdd
    	j update 		# Nhảy đến nhãn 'update'
even:
    	# Xử lý số chẵn
    	slt $t3, $s1, $t2 	# So sánh với minEven
    	beqz $t3, update 	# Nếu lớn hơn, nhảy đến nhãn 'update'
    	move $s1, $t2 		# Cập nhật minEven
update:
    	addiu $t0, $t0, 4 	# Tăng địa chỉ mảng
    	addiu $t1, $t1, -1 	# Giảm số lượng phần tử
    	bnez $t1, find_loop 	# Nếu còn phần tử, quay lại vòng lặp

    	# In kết quả
    	li $v0, 1 		# syscall để in số nguyên
    	move $a0, $s1 		# Chuyển minEven vào $a0 để in
    	syscall

    	# Kết thúc chương trình
    	li $v0, 10 		# syscall để kết thúc chương trình
    	syscall
