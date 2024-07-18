# Định nghĩa Mars bot
.eqv	HEADING 0xffff8010	# Integer: An angle between 0 and 359
			# 0 : Lên
			# 90: Phải
			# 180: Xuống
			# 270: Trái
.eqv	MOVING 0xffff8050	# Boolean: whether or not to move
.eqv	LEAVETRACK 0xffff8020	# Boolean: whether or not to leave a track
.eqv	WHEREX 0xffff8030	# Integer: Current x-location of MarsBot
.eqv	WHEREY 0xffff8040	# Integer: Current y-location of MarsBot

# Định nghĩa Keyboard
.eqv	KEY_CODE 0xFFFF0004	# ASCII code from keyboard, 1 byte
.eqv	KEY_READY 0xFFFF0000	# = 1 if has a new keycode ?
				# Auto clear after lw
# Địa chỉ Hexa Keyboard
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014

#=============================================================================================
.data
# Lịch sử đường đi (trước khi đổi hướng)
	x_his:		.word 0 : 16	# 16: giá trị mỗi phần tử, tọa độ đổi hướng (x; y)
	y_his:		.word 0 : 16	
	a_his:		.word 0 : 16	# lịch sử góc
	l_his:		.word 4		# biến đếm độ dài
	a_cur:		.word 0		# góc hiện tại
	
	isGoing:		.word 0		# 1 -> chạy, 0 -> dừng
	isTracking:		.word 0		# 1 -> vết, 0 -> ngừng

	curCode:		.space 8		# lệnh nhập vào
	Length:			.word 0			# chiều dài lệnh 
	prevCode:		.space 8		# lệnh trước đó
	
# Mã điều khiển
	MOVE_CODE:		.asciiz "1b4"		# chuyển động
	STOP_CODE:		.asciiz "c68"		# dừng
	TURN_LEFT_CODE:		.asciiz "444"		# rẽ trái
	TURN_RIGHT_CODE:	.asciiz "666"		# rẽ phải
	TRACK_CODE:		.asciiz "dad" 		# tạo vết
	UNTRACK_CODE:		.asciiz "cbc"		# ngừng tạo vết
	BACK_CODE:		.asciiz "999"		# trở về
	error:			.asciiz "Khong ton tai lenh: "

#=============================================================================================
.text
	li $k0, KEY_CODE
 	li $k1, KEY_READY
 	
	li $t1, IN_ADRESS_HEXA_KEYBOARD		# ngắt Digital Lab Sim
	li $t3, 0x80				# 1000 0000: bit 7 = 1 cho phép ngắt
	sb $t3, 0($t1)

start: 
	addi	$t7, $zero, 4	# vị trí bắt đầu: x = 0; y = 0; a = 90
	sw	$t7, l_his	
	
	li	$t7, 90
	sw	$t7, a_cur	# a_cur = 90 -> hướng ban đầu: phải
	jal	ROTATE
	nop
	
	sw	$t7, a_his	# a_his[0] = 90
	
	j	waitForKey

printError: 
	li	$v0, 4
	la	$a0, error
	syscall
		
printCode:	
	li	$v0, 4
	la	$a0, curCode
	syscall
	j 	resetInput
	
repeatCode:			# quay lại lệnh trước đó
	jal CopyPrevToCur
	j checkCode

resetInput:	
	jal	strClear			
	nop						

waitForKey:	
	lw	$t5, 0($k1)			# $t5 = [$k1] = KEY_READY
	beq	$t5, $zero, waitForKey		# if $t5 == 0 -> Chờ nhập
	nop
	beq	$t5, $zero, waitForKey

readKey:	
	lw	$t6, 0($k0)			# $t6 = [$k0] = KEY_CODE
	beq	$t6, 0x7f , resetInput		# if $t6 == Delete -> Xóa toàn bộ lệnh
	beq 	$t6, 0x20, repeatCode		# if $t6 == Space -> Lặp lại lệnh

	bne	$t6, 0xa, waitForKey		# if $t6 != Enter -> Chờ Enter
	nop
	bne	$t6, 0xa, waitForKey

checkCode:
	lw	$s2, Length			
	bne	$s2, 3, printError		# chiều dài lệnh != 3 -> không tồn tại lệnh
		
	la	$s3, MOVE_CODE
	jal	strCmp
	beq	$t0, 1, go
		
	la	$s3, STOP_CODE
	jal	strCmp
	beq	$t0, 1, stop
		
	la	$s3, TURN_LEFT_CODE
	jal	strCmp
	beq	$t0, 1, turnLeft
	
	la	$s3, TURN_RIGHT_CODE
	jal	strCmp
	beq	$t0, 1, turnRight
	
	la	$s3, TRACK_CODE
	jal	strCmp
	beq	$t0, 1, track

	la	$s3, UNTRACK_CODE
	jal	strCmp
	beq	$t0, 1, untrack
	
	la	$s3, BACK_CODE
	jal	strCmp
	beq	$t0, 1, goBack
	nop
	
	j	printError

# Thực hiện lệnh =============================================================================
go: 	
	jal 	CopyCurToPrev
	jal	GO
	j	printCode
	
stop: 	
	jal 	CopyCurToPrev
	jal	STOP
	j	printCode

track: 	
	jal 	CopyCurToPrev
	jal	TRACK
	j	printCode
	
untrack:	
	jal 	CopyCurToPrev
	jal	UNTRACK
	j	printCode

turnRight:	
	jal 	CopyCurToPrev
	lw	$t7, isGoing
	lw	$s0, isTracking
	
	jal	STOP
	nop
	jal	UNTRACK
	nop
	
	la	$s5, a_cur
	lw	$s6, 0($s5)		# $s6 = hướng hiện tại
	addi	$s6, $s6, 90		# tăng 90 độ -> phải
	sw	$s6, 0($s5)		# chuyển hướng
	
	jal	saveHistory
	jal	ROTATE
	
	beqz	$s0, noTrack1
	nop
	jal	TRACK
	noTrack1:	
		nop
	
	beqz	$t7, noGo1
	nop
	jal	GO
	noGo1:	
		nop
	
	j	printCode	
	
turnLeft:
	jal 	CopyCurToPrev
	lw	$t7, isGoing
	lw	$s0, isTracking
	
	jal	STOP
	nop
	jal	UNTRACK
	nop
	
	la	$s5, a_cur
	lw	$s6, 0($s5)		# $s6 = hướng hiện tại
	addi	$s6, $s6, -90		# giảm 90 độ -> trái
	sw	$s6, 0($s5)		# chuyển hướng
	
	jal	saveHistory
	jal	ROTATE
	
	beqz	$s0, noTrack2
	nop
	jal	TRACK
	noTrack2:	
		nop
	
	beqz	$t7, noGo2
	nop
	jal	GO
	noGo2:	
		nop
	
	j	printCode	
	
goBack:	
	jal 	CopyCurToPrev
	li	$t7, IN_ADRESS_HEXA_KEYBOARD	# Không thể ngắt cho đến khi dừng
    	sb	$zero, 0($t7)

	lw	$s5, l_his			# $s5 = biến đếm độ dài
	jal	UNTRACK
	jal	GO
	
goBack_turn: 
	addi 	$s5, $s5, -4 			# biến đếm độ dài--
	lw	$s6, a_his($s5)			# $s6 = a_his[l_his]
	addi	$s6, $s6, 180			# quay hướng ngược lại
	sw	$s6, a_cur
	jal	ROTATE
	nop
	
goBack_toTurningPoint:
	lw $t9, x_his($s5) 		# $t9 = x_his[i] 
	get_x: 
		li $t8, WHEREX  	# $t8 = x_current
		lw $t8, 0($t8)
	
		bne $t8, $t9, get_x  	# x_current == x_his[i]
		nop   
		bne $t8, $t9, get_x 
	
 	lw $t7, y_his($s5) 		# $t9 = y_his[i]
	get_y: 
		li $t8, WHEREY   	# $t8 = y_current
		lw $t8, 0($t8)
	
		bne $t8, $t7, get_y  	# y_current == y_his[i]
		nop    
		bne $t8, $t7, get_y 
 
	beq $s5, 0, goBack_end  	# l_his == 0 -> end
	nop 
	
	j goBack_turn   		# else -> loop
	
goBack_end: 
	jal	STOP
	sw	$zero, a_cur		# vị trí bắt đầu
	jal	ROTATE
	
	addi	$s5, $zero, 4
	sw	$s5, l_his		# l_his = 0
	
	j	printCode
	
#=============================================================================================
saveHistory: 
	addi	$sp, $sp, 4		# sao lưu (không bị thay đổi giá trị khi lấy thực hiện)
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4
	sw	$t4, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s2, 0($sp)
	addi	$sp, $sp, 4
	sw	$s3, 0($sp)
	addi	$sp, $sp, 4
	sw	$s4, 0($sp)
	
	lw	$s1, WHEREX			# s1 = x	
	lw	$s2, WHEREY			# s2 = y
	lw	$s4, a_cur			# s4 = a_cur
	
	lw	$t3, l_his			# $t3 = l_his
	sw	$s1, x_his($t3)			# lưu x, y, alpha
	sw	$s2, y_his($t3)
	sw	$s4, a_his($t3)
	
	addi	$t3, $t3, 4			# cập nhật biến đếm độ dài
	sw	$t3, l_his
	
	lw	$s4, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$s3, 0($sp)
	addi	$sp, $sp, -4
	lw	$s2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t4, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
	jr	$ra		

# Cài đặt lệnh ===============================================================================
# GO -----------------------------------------------------------------------------------------
GO: 		
	addi	$sp, $sp, 4			# sao lưu
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$k0, 0($sp)

	li	$at, MOVING			# change MOVING port 
 	addi	$k0, $zero, 1			# to logic 1,
	sb	$k0, 0($at)			# to start running
	
	li	$t7, 1				
	sw	$t7, isGoing			# isGoing = 1 -> di chuyển
		
	lw	$k0, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	
	jr	$ra
	
# STOP ---------------------------------------------------------------------------------------
STOP: 	
	addi	$sp, $sp, 4			# sao lưu
	sw	$at, 0($sp)
	
	li	$at, MOVING			# change MOVING port to 0
	sb	$zero, 0($at)			# to stop
	
	sw	$zero, isGoing			# isGoing = 0 -> dừng
	
	lw	$at, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	
	jr $ra
	
# TRACK --------------------------------------------------------------------------------------
TRACK:	
	addi	$sp, $sp, 4			# sao lưu
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$k0, 0($sp)

 	li	$at, LEAVETRACK			# change LEAVETRACK port
	addi	$k0, $zero,1			# to logic 1,
 	sb	$k0, 0($at)			# to start tracking
 	
 	addi	$s0, $zero, 1
 	sw	$s0, isTracking			# isTracking = 1 -> tạo vết
 	
	lw	$k0, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	
	jr $ra
	
# UNTRACK ------------------------------------------------------------------------------------
UNTRACK:	
	addi	$sp, $sp, 4		# sao lưu
	sw	$at, 0($sp)
	
	li	$at, LEAVETRACK		# change LEAVETRACK port to 0
 	sb	$zero, 0($at)		# to stop drawing tail
 	
 	sw	$zero, isTracking	# isTracking = 0 -> ngừng tạo vết
 	
	lw	$at, 0($sp)		# khôi phục sao lưu
	addi	$sp, $sp, -4
	
 	jr	$ra
	
# ROTATE -------------------------------------------------------------------------------------
ROTATE:	
	addi	$sp, $sp, 4		# sao lưu
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	
	li	$t1, HEADING		# change HEADING port
	la	$t2, a_cur
	lw	$t3, 0($t2)		
 	sw	$t3, 0($t1)		# to rotate robot
 	
 	lw	$t3, 0($sp)		# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
	jr	$ra
	
# Các hàm xử lý xâu ==========================================================================
# strCmp -------------------------------------------------------------------------------------
# Đầu vào: $s3 - địa chỉ lệnh
# Đầu ra: $t0 = 1 nếu chuỗi thỏa mãn, 0 nếu ngược lại
strCmp:	
	addi	$sp, $sp, 4			# sao lưu
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp,$sp,4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	
	addi	$t0, $zero, 0			# mặc định $t0 = 0
	addi	$t1, $zero, 0			# biến đếm $t1 = i = 0
	
strCmp_loop: 
	beq	$t1, 3, strCmp_equal		# i = 3 -> thỏa mãn -> $t0 = 1
	nop
	
	lb	$t2, curCode($t1)		# $t2: lệnh nhập vào
			
	add	$t3, $s3, $t1			# $t3 = s + i
	lb	$t3, 0($t3)			# $t3 = s[i]
	
	beq	$t2, $t3, strCmp_next		# if $t2 == $t3 -> loop
	nop
	
	j	strCmp_end

strCmp_next: 
	addi	$t1, $t1, 1			# i++
	j	strCmp_loop

strCmp_equal: 
	add	$t0, $zero, 1			# $t0 = 1

strCmp_end: 
	lw	$t3, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4

	jr $ra

# strClear -----------------------------------------------------------------------------------
strClear:	
	addi	$sp, $sp, 4			# sao lưu
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4	
	sw	$t2, 0($sp)	
	addi	$sp, $sp, 4	
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4	
	sw	$s2, 0($sp)
	
	lw	$t3, Length			# $t3 = Length
	addi	$t1, $zero, -1			# $t1 = -1 = i
	
strClear_loop: 
	addi	$t1, $t1, 1			# i++	
	sb	$zero, curCode			# curCode[i] = '\0'
				
	bne	$t1, $t3, strClear_loop		# if $t1 != 3 -> loop
	nop
				
	sw	$zero, Length			# Length = 0
	
strClear_end: 
	lw	$s2, 0($sp)			# khôi phục sao lưu
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
	jr	$ra

# CopyPrevToCur ------------------------------------------------------------------------------
CopyPrevToCur:
	addi $sp, $sp, 4   			# sao lưu
	sw $t1, 0($sp)
	addi $sp, $sp, 4 
	sw $t2, 0($sp) 
	addi $sp, $sp, 4 
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4 
	sw $s2, 0($sp)
	
	li $t2, 0
	la $s1, curCode				# địa chỉ lệnh hiện tại
	la $s2, prevCode			# địa chỉ lệnh trước đó
	
CopyPrevToCur_loop:
	beq $t2, 3, CopyPrevToCur_end 		# if $t2 = 3 -> end 
	
	lb $t1, 0($s2)				# $t1 = lệnh trước[i]
	sb $t1, 0($s1)				# lưu vào lệnh hiện tại[i]
	
	addi $s1, $s1, 1			# $s1++
	addi $s2, $s2, 1			# $s2++
	addi $t2, $t2, 1			# $t2++
	
	j CopyPrevToCur_loop
	
CopyPrevToCur_end: 
	li $t3, 3
	sw $t3, Length				# chiều dài lệnh = 3
	
	lw $s2, 0($sp)   			# khôi phục sao lưu
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra	

# CopyCurToPrev ------------------------------------------------------------------------------
CopyCurToPrev:
	addi $sp, $sp, 4   			# sao lưu
	sw $t1, 0($sp)
	addi $sp, $sp, 4 
	sw $t2, 0($sp) 
	addi $sp, $sp, 4 
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4 
	sw $s2, 0($sp)
	
	li $t2, 0
	la $s1, prevCode			# địa chỉ lệnh trước đó
	la $s2, curCode				# địa chỉ lệnh hiện tại
	
CopyCurToPrev_loop:
	beq $t2, 3, CopyCurToPrev_end		# if $t2 = 3 -> end 
	
	lb $t1, 0($s2)				# $t1 = lệnh hiện tại[i]
	sb $t1, 0($s1)				# lưu vào lệnh trước[i]
	
	addi $s1, $s1, 1			# $s1++
	addi $s2, $s2, 1			# $s2++
	addi $t2, $t2, 1			# $t2++
	
	j CopyCurToPrev_loop
	
CopyCurToPrev_end: 
	lw $s2, 0($sp)   			# khôi phục sao lưu
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra

#=============================================================================================
.ktext	0x80000180 			# địa chỉ bắt đầu ngắt
backup:					# sao lưu dữ liệu vào ngăn xếp
	addi	$sp, $sp, 4
	sw	$ra, 0($sp)
	addi	$sp, $sp, 4
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4
	sw	$a0, 0($sp)
	addi	$sp, $sp, 4
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$s0, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t4, 0($sp)
	addi	$sp, $sp, 4
	sw	$s3, 0($sp)
	
# đọc kí tự từ Digital Lab Sim	---------------------------------------------------------------
	li	$t1, IN_ADRESS_HEXA_KEYBOARD
	li	$t2, OUT_ADRESS_HEXA_KEYBOARD

# duyệt các hàng của Digital Lab Sim	
# hàng 1
	li	$t3, 0x81 
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get
# hàng 2	
	li	$t3, 0x82
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get
# hàng 3
	li	$t3, 0x84
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get
# hàng 4
	li	$t3, 0x88
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get

get:
	beq	$a0, 0x11, case_0
	beq	$a0, 0x21, case_1
	beq	$a0, 0x41, case_2
	beq	$a0, 0x81, case_3
	beq	$a0, 0x12, case_4
	beq	$a0, 0x22, case_5
	beq	$a0, 0x42, case_6
	beq	$a0, 0x82, case_7
	beq	$a0, 0x14, case_8
	beq	$a0, 0x24, case_9
	beq	$a0, 0x44, case_a
	beq	$a0, 0x84, case_b
	beq	$a0, 0x18, case_c
	beq	$a0, 0x28, case_d
	beq	$a0, 0x48, case_e
	beq	$a0, 0x88, case_f
	
case_0:	li	$s0, '0'		
	j	storeCode
case_1:	li	$s0, '1'
	j	storeCode
case_2:	li	$s0, '2'
	j	storeCode
case_3:	li	$s0, '3'
	j	storeCode
case_4:	li	$s0, '4'
	j	storeCode
case_5:	li	$s0, '5'
	j	storeCode
case_6:	li	$s0, '6'
	j	storeCode
case_7:	li	$s0, '7'
	j	storeCode
case_8:	li	$s0, '8'
	j	storeCode
case_9:	li	$s0, '9'
	j	storeCode
case_a:	li	$s0, 'a'
	j	storeCode
case_b:	li	$s0, 'b'
	j	storeCode
case_c:	li	$s0, 'c'
	j	storeCode
case_d:	li	$s0, 'd'
	j	storeCode
case_e:	li	$s0, 'e'
	j	storeCode
case_f:	li	$s0, 'f'
	j	storeCode
	
storeCode:	
	la	$s1, curCode
	la	$s2, Length
	lw	$s3, 0($s2)			# $s3 = chiều dài lệnh
	addi	$t4, $t4, -1 			# $t4 = i 

storeCodeLoop: 
	addi 	$t4, $t4, 1
	bne	$t4, $s3, storeCodeLoop
	add	$s1, $s1, $t4			# $s1 = curCode + i
	sb	$s0, 0($s1)			# $s0 = curCode[i] 
	
	addi	$s0, $zero, '\n'		# xuống dòng khi kết thúc 1 lệnh
	addi	$s1, $s1, 1
	sb	$s0, 0($s1)
	
	addi	$s3, $s3, 1
	sw	$s3, 0($s2)			# cập nhật chiều dài lệnh
		
#---------------------------------------------------------------------------------------------
next_pc:					# tiếp tục lệnh tiếp theo sau khi ngắt
	mfc0	$at, $14		# $at = epc
	addi	$at, $at, 4		# $at = $at + 4 
	mtc0	$at, $14		# epc = $at
	
#---------------------------------------------------------------------------------------------
restore:					# khôi phục dữ liệu vào ngăn xếp
	lw	$s3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t4, 0($sp)
	addi	$sp, $sp, -4
	lw	$s2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$s0, 0($sp)
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	lw	$a0, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	lw	$ra, 0($sp)
	addi	$sp, $sp, -4
 	eret					# trở về sau khi ngắt
