.eqv KEY_CODE 0xFFFF0004 	# ASCII code from keyboard, 1 byte 
.eqv KEY_READY 0xFFFF0000 	# =1 if has a new keycode ? 
				# Auto clear after lw 
.eqv DISPLAY_CODE 0xFFFF000C 	# ASCII code to show, 1 byte 
.eqv DISPLAY_READY 0xFFFF0008 	# =1 if the display has already to do 
 				# Auto clear after sw 
.text 
 	li $k0, KEY_CODE 
 	li $k1, KEY_READY 
 	li $s0, DISPLAY_CODE 	# chua ky tu can in ra man hinh 
 	li $s1, DISPLAY_READY 
Loop: 
	nop 
WaitForKey: 
 	lw $t1, 0($k1) 			# $t1 = [$k1] = KEY_READY 
 	beq $t1, $zero, WaitForKey 	# if $t1 == 0 then Polling 
ReadKey: 
 	lw $t0, 0($k0) 			# $t0 = [$k0] = KEY_CODE 
WaitForDis: 
 	lw $t2, 0($s1) 			# $t2 = [$s1] = DISPLAY_READY 
 	beq $t2, $zero, WaitForDis 	# if $t2 == 0 then Polling 
Check: 
Check_E: 
 	beq $t3, 1, Check_X 
 	beq $t0, 101, Co 
Check_X: 
 	beq $t3, 2, Check_I
 	beq $t0, 120, Co 
Check_I: 
 	beq $t3, 3, Check_T 
 	beq $t0, 105, Co 
Check_T: 
 	beq $t3, 4, Print
 	beq $t0, 116, Co 
Reset: 
 	addi $t3, $zero, 0 
Print: 
ChuHoa: 
 	bgt $t0, 90, ChuThuong 
 	blt $t0, 65, ChuThuong 
 	addi $t0, $t0, 32 
 	j ShowKey 
ChuThuong: 
 	bgt $t0, 122, ChuSo 
 	blt $t0, 97, ChuSo 
 	addi $t0, $t0, -32 
 	j ShowKey 
ChuSo: 
 	bgt $t0, 57, Other
 	blt $t0, 48, Other
 	addi $t0, $t0, 0 
 	j ShowKey 
Other: 
 	addi $t0, $zero, 42 
ShowKey: 
 	sw $t0, 0($s0) 		# show key 
 	nop 
 	beq $t3, 4, Exit 
 	j Loop 
Co: 
 	addi $t3, $t3, 1 
 	j Print
Exit: 
 	li $v0, 10 
 	syscall
