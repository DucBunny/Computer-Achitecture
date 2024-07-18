.data
	str: .space 100 	#Khai báo mảng lưu trữ xâu nhập vào
	result: .space 100 	#Mảng lưu trữ ký tự khác nhau
.text
    	li $v0, 8 		#read string
  	la $a0, str
   	li $a1, 100
   	syscall

    	jal print_unique_chars #Gọi hàm để in ra các ký tự khác nhau
    	j exit
print_unique_chars:   
    	li $t0, 0 	#Số lượng ký tự khác nhau    
    	li $t1, 0 	#Mảng để đánh dấu ký tự đã xuất hiện  
    	li $t2, 0 	#Con trỏ vòng lặp
loop:
    	lb $t3, str($t2) 	#Đọc ký tự từ xâu
    	beqz $t3, end_loop 	#Nếu ký tự là kết thúc xâu thì kết thúc vòng lặp
    
    	lb $t4, result($t3) 	#Kiểm tra xem ký tự đã xuất hiện chưa
    	beqz $t4, add_char 	#Nếu ký tự chưa xuất hiện, thêm vào mảng và in ra
    	j next_char
add_char:
    	sb $t3, result($t3) 	#Thêm ký tự vào mảng kết quả
    	li $v0, 11 		#print char
    	move $a0, $t3
    	syscall
    	addi $t0, $t0, 1 	#Tăng số lượng ký tự khác nhau
next_char:
    	addi $t2, $t2, 1 	#Tăng con trỏ vòng lặp
    	j loop
end_loop:
    	jr $ra 			#Trở về hàm gọi
exit: 
	li $v0, 10
    	syscall
