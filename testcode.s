	.text
	.align	2
	.globl	f
	.type	f, @function
f:
addiu	$sp,$sp,-24
sw	$fp,20($sp)
move	$fp,$sp
lw	$8,16($fp)
sw	$8,16($fp)
lw	$8,20($fp)
sw	$8,20($fp)
lw	$8,16($fp)
lw	$9,20($fp)
mult	$8,$9
mflo	$8
sw	$8,12($fp)
lw	$2,12($fp)
move	$sp,$fp
lw	$fp,20($sp)
addiu	$sp,$sp,24
j	$31
nop

