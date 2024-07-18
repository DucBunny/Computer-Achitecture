.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050 
.eqv LEAVETRACK 0xffff8020 
.eqv WHEREX 0xffff8030 
.eqv WHEREY 0xffff8040 
.eqv KEY_CODE 0xFFFF0004 	
.eqv KEY_READY 0xFFFF0000 
.eqv DISPLAY_CODE 0xFFFF000C 	
.eqv DISPLAY_READY 0xFFFF0008 
.text
	li $k0, KEY_CODE 
 	li $k1, KEY_READY 
 	li $s0, DISPLAY_CODE 
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
Print: 
 	beq $t0, 65, sleepA 
 	beq $t0, 97, sleepA 
 	beq $t0, 87, sleepW 
 	beq $t0, 119, sleepW 
 	beq $t0, 68, sleepD 
 	beq $t0, 100, sleepD 
 	beq $t0, 83, sleepS 
 	beq $t0, 115, sleepS 
 	beq $t0, 32, Nghiem 
 	beq $t0, 67, Ditiep 
 	beq $t0, 99, Ditiep 
ShowKey: 
 	sw $t0, 0($s0) 		# show key 
 	nop 
 	j Loop 
sleepW: 
 	addi $a0, $zero, 0 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	j ShowKey 
sleepS: 
 	addi $a0, $zero, 180 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	j ShowKey 
sleepD: 
 	addi $a0, $zero, 90 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	j ShowKey 
sleepA: 
 	addi $a0, $zero, 270 
 	jal ROTATE 
 	jal GO 
 	jal UNTRACK 		# keep old track 
 	jal TRACK 		# and draw new track line 
 	j ShowKey 
Nghiem: 
 	jal STOP 
 	j ShowKey 
Ditiep: 
 	jal GO 
 	j ShowKey 
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
