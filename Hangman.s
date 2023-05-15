// Macros

/* Copied from Macros assignment
push
push a register to the stack
parameters:  register, the register to be pushed onto the stack
precondition: none
postcondition: passed in registers value is added to the stack and the stack pointer is pointing to it
return:    n/a
*/
.macro push register
    str \register, [sp, #-16]!  // store the value in the memory location pointed to by sp and decrement by 16
.endm


/* Copied from Macros assignment
pop
pop a register from the stack
parameters:  register, the register to be popped from the stack
precondition: the value has been pushed into the stack
postcondition: the passed in registers value copied from the stack and the stack pointer is pointing the next value on the stack
return:    n/a
*/
.macro pop register
    ldr \register, [sp], #16  // load the value in the memory location pointed to by sp and increment by 16
.endm


/* Copied from Macros assignment
endl, print an endline preserve all registers used
parameters: none
precondition: none 
postcondition: an endline character has been output to stdout
return: none
*/
.MACRO endl
push X0                 // preserve the registers we are going to use
push X1
push X2
push X8

mov x0, #0             // std out
ldr x1, =endline       // store the address of macro into x1
ldr x2, =endlineSize   // store the size of the macro string into x2
mov x8, #64            // store 64 to x8, this is the linux write call
svc 0     

pop X8                  // restore the registers
pop X2
pop X1
pop X0
.ENDM



// test if the player has won
.macro testWin
push x0
push x1
push x2
push x3
push x4
push x5
push x6
push x7
push x8

mov x0, #0				// loop counter
ldr x1, =underScore
ldrb w2, [x1]			// store underscore in register x2
ldr x3, =secretWord
ldr x5, =secretWordSize

// loop through secretWord to see if the player has guessed all letters
1:
	ldrb w4, [x3, x0]		// store secretWord letter at index into register 4
	cmp x4, x2
	B.EQ 3f
	
	add x0, x0, #1
	cmp x0, x5
	B.LT 1b
	
	B 2f

// update win flag to true
2:
	ldr x7, =winFlag
	ldrb w8, [x7]
	add x8, x8, #1
	strb w8, [x7]


// continue game
3:

pop x8
pop x7
pop x6
pop x5
pop x4
pop x3
pop x2
pop x1
pop x0
.endm



// test whether player guess is correct or incorrect
.macro testGuess playerGuess
push x0
push x1
push x2
push x3
push x4
push x5
push x6
push x7
push x8

mov x0, #0				// index variable
ldr x1, =\playerGuess	// store address of guess
ldrb w2, [x1]			// store value of guess
ldr x5, =wordLength		// store address of length of hidden word
ldrb w6, [x5]			// store value of length of hidden word
ldr x7, =numWrongGuesses
ldrb w8, [x7]


// loop to test if guess is in the hidden word
1:
	ldr x3, =hiddenWord
	ldrb w4, [x3, x0]		// store letter of hidden word at index saved in register 0
	cmp x4, x2 				// compare indexed letter to guess
	B.EQ 2f					// if found go to branch 2
	
	add x0, x0, #1			// else increment index
	cmp x0, x6				// and compare to length of hidden word
	B.LT 1b					// continue to index through the word
	
	B 3f					// branch to guess not found
	
	
// guess is found in word
2:	
	printGoodGuess
	B 4f
	
	
// guess not found in word
3:	
	add x8, x8, #1
	strb w8, [x7]
	printBadGuess
	

4:

pop x8
pop x7
pop x6
pop x5
pop x4
pop x3
pop x2
pop x1
pop x0
.endm
 



// print current hangman scene based on number of wrong guesses
.macro printCurScene wrongGuesses
push x0
push x1
push x2

ldr x0, =\wrongGuesses
ldrb w1, [x0]
mov x2, #0				// scene counter

cmp x1, x2				// match the number of incorrect guesses with the appropriate scene
B.HI 1f
printScene1


1:
	Add x2, x2, #1		// increase scene counter		
	cmp x1, x2
	B.HI 2f
	printScene2

2:
	Add x2, x2, #1		
	cmp x1, x2
	B.HI 3f
	printScene3

3:
	Add x2, x2, #1		
	cmp x1, x2
	B.HI 4f
	printScene4

4:
	Add x2, x2, #1		
	cmp x1, x2
	B.HI 5f
	printScene5

5:
	Add x2, x2, #1		
	cmp x1, x2
	B.HI 6f
	printScene6
	
6:
	Add x2, x2, #1		
	cmp x1, x2
	B.NE 7f
	printScene7
	
7:

pop x2
pop x1
pop x0
.endm



//
.macro updateSecretWord playerGuess
push x0
push x1
push x2
push x3
push x4
push x5
push x6
push x7
push x8
push x9
push x10

mov x0, #0				// loop counter and index variable
ldr x1, =\playerGuess	// store address of guess
ldrb w2, [x1]			// store value of guess
ldr x3, =wordLength		// store address of length of hidden word
ldrb w4, [x3]			// store value of length of hidden word	
ldr x5, =hiddenWord
ldr x6, =secretWord


//secret word loop
1:
	ldrb w7, [x5, x0]		// store letter of hidden word at index saved in register 0
	cmp x7, x2 				// compare indexed letter to guess
	B.EQ 2f
	
	add x0, x0, #1
	cmp x0, x4
	B.LT 1b
	
	B 3f

// update secretWord letter
2:
	mov x9, #2
	mul x8, x0, x9
	add x8, x8, #13
	strb w2, [x6, x8]
	
	add x0, x0, #1
	cmp x0, x3
	B.LT 1b
	

3:

pop x10
pop x9
pop x8
pop x7
pop x6
pop x5
pop x4
pop x3
pop x2
pop x1
pop x0
.endm



.macro printSecretWord
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =secretWord
ldr x2, =secretWordSize
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm



// print player guess
.macro printGuess
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =guess
ldr x2, =guessSize
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm



// invididual scene printing macros
.macro printScene1
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene1
ldr x2, =scene1Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene2
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene2
ldr x2, =scene2Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene3
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene3
ldr x2, =scene3Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene4
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene4
ldr x2, =scene4Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene5
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene5
ldr x2, =scene5Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene6
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene6
ldr x2, =scene6Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

.macro printScene7
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =scene7
ldr x2, =scene7Size
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm
// end of invididual scene printing macros



// print good guess message
.macro printGoodGuess
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =goodGuessMsg
ldr x2, =goodGuessMsgSize
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm

// print bad guess message
.macro printBadGuess
push x0
push x1
push x2
push x8

mov x0, #0
ldr x1, =badGuessMsg
ldr x2, =badGuessMsgSize
mov x8, #64
svc 0

push x8
push x2
push x1
push x0
.endm







.data  // start of the data segment

// gameplay variables
hiddenWord:
	.asciz "creature"
hiddenWordSize = .-hiddenWord

secretWord:
	.asciz "SECRET WORD: _ _ _ _ _ _ _ _ \n"
secretWordSize = .-secretWord

underScore:
	.asciz "_"
underScoreSize = .-underScore

guess:
	.skip 2 //.asciz " "
guessSize = .-guess

numWrongGuesses: 
	.byte 0
numWrongGuessesSize = .-numWrongGuesses

winFlag:
	.byte 0
winFlagSize = .-winFlag

wordLength:
	.byte 8
wordLengthSize = .-wordLength


// scene variables
scene1:
	.asciz "        ______\n        |     |\n              |\n              |\n              |\n              |\n              |\n----------------------\n"
scene1Size = .-scene1

scene2:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n              |\n              |\n              |\n----------------------\n"
scene2Size = .-scene2

scene3:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n        |     |\n              |\n              |\n----------------------\n"
scene3Size = .-scene3

scene4:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n       /|     |\n              |\n              |\n----------------------\n"
scene4Size = .-scene4

scene5:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n       /|\\    |\n              |\n              |\n----------------------\n"
scene5Size = .-scene5

scene6:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n       /|\\    |\n       /      |\n              |\n----------------------\n"
scene6Size = .-scene6

scene7:
	.asciz "        ______\n        |     |\n       _^_    |\n        O     |\n       /|\\    |\n       / \\    |\n              |\n----------------------\n"
scene7Size = .-scene7



// message variables
welcomeMsg:
	.asciz "--------------------------\n|** WELCOME TO HANGMAN **|\n--------------------------\n"
welcomeMsgSize = .-welcomeMsg

promptMsg:
	.asciz "Guess a lowercase letter: "
promptMsgSize = .-promptMsg

goodGuessMsg:
	.asciz "Good guess! \n"
goodGuessMsgSize = .-goodGuessMsg

badGuessMsg:
	.asciz "Not there! Too bad...\n"
badGuessMsgSize = .-badGuessMsg

winMsg:
	.asciz "Congratulations! You guessed the secret word!\n"
winMsgSize = .-winMsg

loseMsg:
	.asciz "Game over! Better luck next time...\n"
loseMsgSize = .-loseMsg



// macro variables
endline: 
    .asciz "\n"
endlineSize = .-endline





.text  // start o the text segment (Code)





.global _start // Linux Standard _start, similar to main in C/C++ 
_start:

// welcome message
mov x0, #0				// stdout
ldr x1, =welcomeMsg  	// store the address 
ldr x2, =welcomeMsgSize // store the size 
mov x8, #64          	// write
svc 0                	// Linux service call


ldr x21, =numWrongGuesses	
ldrb w20, [x21]				// store address of number of wrong guesses in register 20
ldr x19, =wordLength		
ldr x18, [x19]				// store length of secret word into register 18


mainGameLoop:

	printCurScene numWrongGuesses
	printSecretWord
	
	// prompt user to guess a letter
	mov x0, #0           	// stdout
	ldr x1, =promptMsg  	// store the address of promptMsg into x1
	ldr x2, =promptMsgSize  // store the size of the prompMsg string into x2
	mov x8, #64          	// store 64 to x8, this is the linux write call
	svc 0    

	// take letter guess from user
	mov x0, #0           	// stdin
	ldr x1, =guess      	// store the address into x1
	ldr x2, =guessSize   	// store the size of the string into x2
	mov x8, #63          	// store 63 to x8, this is the linux read call
	svc 0                	// Linux service call
	
	ldr x17, =guess			
	ldrb w16, [x17]			// load guess into register 16
	
	testGuess guess			// checks if guessed letter is in secretWord
    endl
    updateSecretWord guess	// updates the secretWord line if the guess contains the guessed letter
	testWin					// check if the secretWord has been fully revealed 
    
	// check if testWin has updated the win flag, branch to win if true	
    ldr x15, =winFlag
    ldrb w14, [x15]
    cmp x14, #1
    B.EQ win

	// branches to lose if player has run out of guesses, otherwise continues game loop
	ldr x21, =numWrongGuesses	// store address of number of wrong guesses in register 21
	ldrb w20, [x21]
    cmp x20, #6
    B.LT mainGameLoop
    B lose


win:
	printCurScene numWrongGuesses
	printSecretWord
	
	// tell user they won
	mov x0, #0           	// stdout
	ldr x1, =winMsg  	// store the address of promptMsg into x1
	ldr x2, =winMsgSize  // store the size of the prompMsg string into x2
	mov x8, #64          	// store 64 to x8, this is the linux write call
	svc 0    
	
	B end


lose:
	printCurScene numWrongGuesses
	printSecretWord
	
	// tell user they lost
	mov x0, #0           	// stdout
	ldr x1, =loseMsg  	// store the address of promptMsg into x1
	ldr x2, =loseMsgSize  // store the size of the prompMsg string into x2
	mov x8, #64          	// store 64 to x8, this is the linux write call
	svc 0    
	
	
end:

// Exit to the OS, essentially this code does this in c
// return 0;
mov x0, #0          // return value
mov x8, #93         // Service call code
svc 0               // Linux service call






