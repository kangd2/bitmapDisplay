# HW4
# Evan Roman
# The following will draw a box of pixels that
# will have a marquee effect and the box can be
# moved by keyboard inputs

# Instructions:
# 	Set pixel dim to 4 x 4
#	Set display dim to 256 x 256
#	Use 0x10008000 ($gp) for base address for display
#	For keyboard, W = up, A = left, D = right, S = down
#	SPACE = quit

# width of screen in pixels
# 256 / 4 = 64
.eqv WIDTH 64

# height of screen in pixels
.eqv HEIGHT 64

# colors
.eqv	RED	0x00FF0000
.eqv	GREEN	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF

	.data
colors:	.word	MAGENTA, BLUE, GREEN, RED, YELLOW, CYAN, WHITE, -1
	.text

main:	# set up starting position
	addi 	$a0, $0, WIDTH    	# a0 = X = WIDTH/2
	sra 	$a0, $a0, 1
	addi 	$a1, $0, HEIGHT  	# a1 = Y = HEIGHT/2
	sra 	$a1, $a1, 1
	la	$t1, colors		# $t1 = colorArr[0]
	li	$s0, 7			# numPixels = 7, i < numPixels
	
loop:	# Use temporary registers for $a0 and $a1 (w and h)
	move	$t3, $a0
	move	$t4, $a1

initialize:	
	lw	$t2, ($t1)		# Load contents of address
	bne	$t2, -1, drawBox	# Contents are sentinel val
	la	$t1, colors		# $t1 = addr of colors[0]

drawBox:
	# Draw box function
	# Save $ra
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	jal	resetCounter		# i = 0 and $t5 = addr of arr
	
loopT:	# Loop for top line
	beq	$t0, $s0, drawRight	# i < numPixels
	
	beq	$t6, 1, skipTReset	# Input accepted
	lw	$a2, ($t5)		# Load color of arr
	
	bne	$a2, -1, skipTReset	# Element is not sentinel
	jal	resetPtr		# End of arr, reset color arr ptr
	
skipTReset:
	jal	draw_pixel		# Draw pixel and pause
	jal	increment		# Move color ptr and i++
	addi	$t3, $t3, 1		# Draw next pixel to right
	j	loopT
	
drawRight:
	jal	resetCounter		# i = 0 and $t5 = addr of arr
	
loopR:	# Loop for right line
	beq	$t0, $s0, drawBottom	# i < numPixels
	
	beq	$t6, 1, skipRReset	# Input accepted
	lw	$a2, ($t5)		# Load color of arr
	
	bne	$a2, -1, skipRReset	# Element is not sentinel
	jal	resetPtr		# End of arr, reset color arr ptr

skipRReset:
	jal	draw_pixel		# Draw pixel and pause
	jal	increment		# Move color ptr and i++
	addi	$t4, $t4, 1		# Draw next pixel down
	j	loopR
	
drawBottom:
	jal	resetCounter		# i = 0 and $t5 = addr of arr

loopB:	# Loop for bottom line
	beq	$t0, $s0, drawLeft	# i < numPixels
	
	beq	$t6, 1, skipBReset	# Input accepted
	lw	$a2, ($t5)		# Load color of arr
	
	bne	$a2, -1, skipBReset	# Element is not sentinel
	jal	resetPtr		# End of arr, reset color arr ptr

skipBReset:
	jal	draw_pixel		# Draw pixel and pause
	jal	increment		# Move color ptr and i++
	addi	$t3, $t3, -1		# Draw next pixel left
	j	loopB
	
drawLeft:
	jal	resetCounter		# i = 0 and $t5 = addr of arr
	
loopL:	# Loop for left line
	beq	$t0, $s0, drawReturn	# i < numPixels

	beq	$t6, 1, skipLReset	# Input accepted
	lw	$a2, ($t5)		# Load color of arr
	
	bne	$a2, -1, skipLReset	# Element is not sentinel
	jal	resetPtr		# End of arr, reset color arr ptr
	
skipLReset:
	jal	draw_pixel		# Draw pixel and pause
	jal	increment		# Move color ptr and i++
	addi	$t4, $t4, -1		# Draw next pixel up
	j	loopL

drawReturn:
	# Restore $ra
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	
	beq	$t6, 1, resetInput	# Check user input
	addi	$t1, $t1, 4		# Go to next color in color array
	j	input			# Detect input from kb
	
resetInput:
	# Default "bool" for kb input
	li	$t6, 0
	jr	$ra

input:
	# check for input
	lw $t0, 0xffff0000  		# $t0 holds if input available
    	beq $t0, 0, loop   		# If no input, keep displaying
    	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit		# input space
	beq	$s1, 119, up 		# input w
	beq	$s1, 115, down 		# input s
	beq	$s1, 97, left  		# input a
	beq	$s1, 100, right		# input d
	j	loop			# invalid input, ignore
	
	# process valid input
up:	li	$t6, 1
	li	$a2, 0		# black out the pixel
	jal	drawBox
	addi	$a1, $a1, -1
	j	loop

down:	li	$t6, 1
	li	$a2, 0		# black out the pixel
	jal	drawBox
	addi	$a1, $a1, 1
	j	loop
	
left:	li	$t6, 1
	li	$a2, 0		# black out the pixel
	jal	drawBox
	addi	$a0, $a0, -1
	j	loop
	
right:	li	$t6, 1
	li	$a2, 0		# black out the pixel
	jal	drawBox
	addi	$a0, $a0, 1
	j	loop
	
resetCounter:
	# save $ra
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	la	$t5, ($t1)		# store temp arr[0] to be added to
	li	$t0, 0			# i = 0
	
	# restore $ra
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
resetPtr:
	# save $ra
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	# reset color ptr to pt to color[0]
	la	$t5, colors		# Point back to colors[0]
	lw	$a2, ($t5)		# Load contents
	
	# restore $ra
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
increment:
	# save $ra
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
		
	# add to counter and color array
	addi	$t5, $t5, 4		# Next color
	addi	$t0, $t0, 1		# i++
	
	# restore $ra
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
draw_pixel:
	# draw pixel function
	# save $ra
	addi	$sp, $sp, -8
	sw	$ra, ($sp)
	sw	$a0, 4($sp)
	
	# $t9 = address = $gp + 4(x + y * width)
	mul	$t9, $t4, WIDTH   	# y * WIDTH
	add	$t9, $t9, $t3	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	sw	$a2, ($t9)	  	# store color at memory location
	
pause:	# pause function
	li	$v0, 32			# sleep syscall val
	li	$a0, 5			# sleep 5 ms
	syscall
	
	# restore $ra
	lw	$ra, ($sp)
	lw	$a0, 4($sp)
	addi	$sp, $sp, 8
	jr 	$ra
	
exit:	# Exit upon space bar input
	li	$v0, 10
	syscall
