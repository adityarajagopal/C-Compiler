	.text
	.align	2
	.globl	main
	.type	main, @function
main:
addiu	$sp,$sp,-40
sw	$fp,36($sp)
move	$fp,$sp
lw	$8,12($fp)
move	$8,$4
sw	$8,12($fp)
lw	$8,16($fp)
move	$8,$5
sw	$8,16($fp)
lw	$8,12($fp)
sw	$8,12($fp)
lw	$8,24($fp)
li	$8,12
sw	$8,24($fp)
lw	$8,24($fp)
sw	$8,12($fp)
lw	$8,12($fp)
sw	$8,12($fp)
lw	$8,36($fp)
li	$8,4
sw	$8,36($fp)
lw	$8,12($fp)
sw	$8,12($fp)
lw	$8,12($fp)
lw	$9,36($fp)
add	$8,$8,$9
sw	$8,32($fp)
lw	$8,32($fp)
sw	$8,12($fp)
lw	$8,12($fp)
sw	$8,12($fp)
lw	$2,12($fp)
move	$sp,$fp
lw	$fp,36($sp)
addiu	$sp,$sp,40
j	$31
nop

