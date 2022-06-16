.data

frameBuffer: .space 0x100000
newline: .asciiz  "\n"
space: .asciiz " "

.text


color:
li    $t3, 0x00FFFF00  # $t3 ← 0x00RRGGbb yellow
la $t1 , frameBuffer
li $t6, 262144 # 512 x 512
li $t4, 256 #  $t4 = x_center = 256
li $t5, 256 #  $t5 = y_center = 256
j moveUp
# Xem frame là đồ thị gốc 0 0 tại grid đầu tiên, 0x theo chiều xuống , 0y sang phải 
#
#
gameUpdate:
	lw	$t9, 0xffff0004		# get keypress from keyboard input

	beq	$t9, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t9, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t9, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t9, 115, moveDown	# else if key press = 's' branch to moveDown
	beq	$t9, 0, moveUp		# start game moving up



### move Up
moveUp:
#blt $t4 , 32, returnDown

li    $t3, 0x00FFFF00 
jal drawCircle

li    $t3, 0x000000
jal drawCircle




li $t0 , 4
sub $t4 , $t4 , $t0

li    $t3, 0x00FFFF00 

beq $t4 , 32, moveDown
j gameUpdate

moveDown:
li    $t3, 0x00FFFF00 
jal drawCircle

li    $t3, 0x000000
jal drawCircle




li $t0 , 4
add $t4 , $t4 , $t0

li    $t3, 0x00FFFF00 

beq $t4 , 480, moveUp
j gameUpdate

moveLeft:
li    $t3, 0x00FFFF00 
jal drawCircle

li    $t3, 0x000000
jal drawCircle




li $t0 , 4
sub $t5 , $t5 , $t0

li    $t3, 0x00FFFF00 

beq $t5 , 32, moveRight
j gameUpdate

moveRight:
li    $t3, 0x00FFFF00 
jal drawCircle

li    $t3, 0x000000
jal drawCircle




li $t0 , 4
add $t5 , $t5 , $t0

li    $t3, 0x00FFFF00 

beq $t5 , 480, moveLeft
j gameUpdate













###### ----------Draw circle-----------#################################
drawCircle:
sw $fp,-4($sp) #save frame pointer (1)
addi $fp,$sp,0 #new frame pointer point to the top (2)
addi $sp,$sp,-8 #adjust stack pointer (3)
sw $ra,0($sp) #save return address (4)

### Mid point argorithm
li $s0 , 32  # $s0 = x = R = 25
li $s1 , 0   # $s1 = y = 0

add $s3 , $s0 , $t4
add $s4 , $s1 , $t5
jal fillGrid

add $s3 , $s0 , $t4
sub $s4 , $t5 , $s1
jal fillGrid

add $s3 , $s1 , $t4
add $s4 , $s0 , $t5
jal fillGrid

sub $s3 , $t4 , $s1
add $s4 , $s0 , $t5
jal fillGrid


li $t7 , -31  # $t7 = P = 1 - R = 1- 25 = -24 
loop1:
addi $s1 , $s1 , 1

ble $t7 , $zero , P_LessOrEqual_0
subi $s0 , $s0 , 1
addi $t7 , $t7 , 1
add $t7 , $t7 , $s1 
add $t7 , $t7 , $s1
sub $t7 ,$t7 , $s0
sub $t7 , $t7 , $s0 # P = P + 2y - 2x + 1
j next1

P_LessOrEqual_0: addi $t7 , $t7 , 1
        	add $t7 , $t7 , $s1 
       		add $t7 , $t7 , $s1  # P = P +2y + 1
        	
        	
next1: 
blt $s0 , $s1 , done1 # if x < y , break
add $s3 , $s0 , $t4
add $s4 , $s1 , $t5
jal fillGrid
sub $s3 , $t4 , $s0
add $s4 , $s1 , $t5
jal fillGrid
add $s3 , $s0 , $t4
sub $s4 , $t5 , $s1
jal fillGrid
sub $s3 , $t4 , $s0
sub $s4 , $t5 , $s1
jal fillGrid


beq $s0 ,$s1 , nextLoop1
add $s3 , $s1 , $t4
add $s4 , $s0 , $t5
jal fillGrid
sub $s3 , $t4 , $s1
add $s4 , $s0 , $t5
jal fillGrid
add $s3 , $s1  , $t4
sub $s4 , $t5 , $s0
jal fillGrid
sub $s3 , $t4, $s1
sub $s4 , $t5 , $s0
jal fillGrid



nextLoop1:
bgt $s0 , $s1 , loop1
j done1



#### Fill the coordiate (x,y) = ( $s3, $s4)
fillGrid: 
sw $fp,-4($sp) #save frame pointer (1)
addi $fp,$sp,0 #new frame pointer point to the top (2)
addi $sp,$sp,-8 #adjust stack pointer (3)
sw $ra,0($sp)

 add $a0, $s3 , $zero
 li $v0, 1
 syscall
 li $v0,4
 la $a0, space
 syscall 
 add $a0, $s4 , $zero
 li $v0, 1
 syscall
 
la $t1 , frameBuffer # reset to (0,0)
mul $s3 , $s3, 512  #  $s3 , $s4 is x , y to filled
add $s3 , $s3 , $s4
mul $s3 , $s3 , 4  #   relative = (x*512 + y ) * 4

add $t1 , $t1 , $s3
sw $t3 , 0($t1)
la $t1 , frameBuffer # reset $t1 to (0,0)

 li $v0,4
 la $a0, newline
 syscall 
 # jr $ra
 
 lw $ra,0($sp) #restore return address (5)
 addi $sp,$fp,0 #return stack pointer (6)
 lw $fp,-4($sp) #return frame pointer (7)
 jr $ra

done1:
lw $ra,0($sp) #restore return address (5)
addi $sp,$fp,0 #return stack pointer (6)
lw $fp,-4($sp) #return frame pointer (7)
jr $ra 

end:

