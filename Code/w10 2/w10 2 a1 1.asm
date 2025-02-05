.eqv HEADING 0xffff8010		# Integer: An angle between 0 and 359 
			# 0 : North (up) 
 			# 90: East (right) 
 			# 180: South (down) 
 			# 270: West (left) 
.eqv MOVING 0xffff8050 		# Boolean: whether or not to move 
.eqv LEAVETRACK 0xffff8020 	# Boolean (0 or non-0): 
 				# whether or not to leave a track 
.eqv WHEREX 0xffff8030 		# Integer: Current x-location of MarsBot 
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot 
.text 
main:
	addi $a0, $zero, 90 	# Marsbot rotates 90* and start running 
 	jal ROTATE 
	jal GO 
	
	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,15000 
	syscall 
	
	addi $a0, $zero, 180 
 	jal ROTATE 
 	jal GO 
 
 	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,7000 
 	syscall 
sleep1: 
 	addi $a0, $zero, 150 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,7000 
 	syscall 
sleep2: 
 	addi $a0, $zero, 270 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,7000 
 	syscall 
sleep3: 
 	addi $a0, $zero, 30 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,7000 
 	syscall 
end_main: 
 	jal UNTRACK 		# keep old track 
 	addi $a0, $zero, 90 
 	jal ROTATE 
 	jal GO 
 	addi $v0,$zero,32 	# Keep running by sleeping in 1000 ms 
 	li $a0,3000 
 	syscall 
 	jal STOP 
 	li $v0, 10 
 	syscall 
GO: 
 	li $at, MOVING 		# change MOVING port 
 	addi $k0, $zero,1 	# to logic 1, 
 	sb $k0, 0($at) 		# to start running 
 	jr $ra 
ROTATE: 
 	li $at, HEADING 	# change HEADING port 
 	sw $a0, 0($at) 		# to rotate robot 
 	jr $ra 
STOP: 
 	li $at, MOVING 		# change MOVING port to 0 
 	sb $zero, 0($at) 	# to stop 
 	jr $ra 
TRACK: 
 	li $at, LEAVETRACK 	# change LEAVETRACK port 
 	addi $k0, $zero,1 	# to logic 1, 
 	sb $k0, 0($at) 		# to start tracking 
 	jr $ra 
UNTRACK: 
 	li $at, LEAVETRACK 	# change LEAVETRACK port to 0 
 	sb $zero, 0($at) 	# to stop drawing tail 
 	jr $ra 
