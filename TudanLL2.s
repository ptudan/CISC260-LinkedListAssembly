@ read integers from a file and insert them into a linked-list to get sorted
@ and print the sorted list to the screen (stdout).

.text
main:

	@ open an input file to read integers
	ldr r0, =InFileName
	mov r1, #0
	swi 0x66  @ open file
	ldr r1, =InFileHandle
	str r0, [r1]
	swi 0x6c 
	mov r3, r0 
	mov r0, #8 
	swi 0x12 @get 8 bytes on heap
	mov r2, r0 @copy addy to r2
	str r2, =MyList @store addy to MyList
	str r3, [r2,#0] @store first val in list to first word of root
	mov r7, #1 
	sub r7, r7, #2
	str r7, [r2,#4] @stores -1 in pointer loc (escape char)

   loop:
	mov r0, #3
	ldr r1, =InFileHandle
	str r0, [r1] @read int from file
	swi 0x6c
	BCS finish
	mov r3, r0 @move int into r3
	mov r0, #8
	swi 0x12 @get 8 bytes on heap
	mov r2, r0 @move addy of words to r2
	ldr r4, =MyList
	mov r6, #0

   insert: @val to insert in r3, temp node in r4, previous node in r6
	ldr r5, [r4,#0] @puts value of node in r5
	cmp r3, r5
	ble inif @if r3 is less than temp node
	mov r6, r4 @update previous node
	ldr r7, [r4,#4] 
	cmp r7, #0 @check for escape char (end of linked list)
	blt inlast
	ldr r4, [r4,#4] @update temp node
	b insert

   inif: @inserts node
	str r3, [r2,#0]
	str r4, [r2,#4]
	cmp r6, #0 @checks if root needs updating
	beq inroot
	str r2, [r6,#4] @points previous node to new node
	b loop

   inroot: @changes to root
	str r2, =MyList
	b loop

   inlast: @inserts node at last value
	str r2, [r4,#4]
	str r3, [r2,#0]
	mov r7, #1
	sub r7, r7, #2
	str r7, [r2,#4] @stores escape char into pointer location
	b loop

finish:
	ldr r0, =InFileHandle
	ldr r0, [r0]
	swi 0x68 @close open file
	mov r4, #1
	sub r4, r4, #2 @sets r4 to check for escape char
	ldr r2, =MyList
print: 
	mov r0, #1
	ldr r1, [r2,#0]
	swi 0x6b @prints vals of nodes
	mov r0, #1
	ldr r1, =Space @prints spaces
	swi 0x69
	ldr r3, [r2,#4] @loads next node
	cmp r3, r4 @checks if pointer is escape char
	beq finallydonelol
	mov r2, r3 @updates current node
	b print
	
finallydonelol:
	swi 0x11
	

.data
MyList: .word 0
InFileName: .asciz "list.txt"
InFileHandle: .word 0
OutFileName: .asciz "sorted_list.txt"
OutFileHandle: .word 0
Space: .ascii " "