.text
	slt $t0, $s2, $s1 	# t0 = (s2 < s1) ? 1 : 0
	beq $t0, $zero, label 	# if not, label
label:
