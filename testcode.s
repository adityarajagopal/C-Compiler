	.text
	.align	2
	.globl	f
	.ent	f
	.type	f, @function
f:
addiu	$sp,$sp,-32
sw	$fp,28($sp)
move	$fp,$sp
lw	$8,12($fp)
move	$8,$4
sw	$8,12($fp)
lw	$8,16($fp)
move	$8,$5
sw	$8,16($fp)
lw	$8,12($fp)
sw	$8,12($fp)
lw	$8,16($fp)
sw	$8,16($fp)
lw	$8,12($fp)
lw	$9,16($fp)
mult	$8,$9
mflo	$8
sw	$8,20($fp)
lw	$2,20($fp)
move	$sp,$fp
lw	$fp,28($sp)
addiu	$sp,$sp,32
j	$31
nop
	.end	f

