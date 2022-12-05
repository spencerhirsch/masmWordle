;--------------------------------------------------------
; Authors: Spencer Hirsch, shirsch2020@my.fit.edu, James
;          Pabisz, jpabisz2020@my.fit.edu
; Program: Wordle in Assembly (Contest 1)
; Course: Computer Architecture and Assembly, Fall 2022
;--------------------------------------------------------

.386
INCLUDE Irvine32.inc
;-------------------------------------------------------
; Macro used to convert all of the characters in a given
; string to uppercase. So that the inputs will always
; match regardless of case.
;-------------------------------------------------------
ToUpper MACRO char
 mov esi, char                  ; Move string to reg
 mov ecx, 5                     ; Counter for loop
 StandardizeCase:
  mov al, [esi]
  cmp al, 0                     ; Do comparison
  je OutLoop                    
  cmp al, 'a'
  jb NextLetter                 ; Jump
  cmp al, 'z'
  ja NextLetter                 ; Jump
  and BYTE PTR [esi], 11011111b
  
 NextLetter:                    ; Move to next letter
  inc esi                       ; in string
  jmp StandardizeCase
 
 OutLoop:                  
  mov ecx, 0
ENDM

UserSetup MACRO char
  mov eax, (black*16) + lightGreen ;turns text green
  call SetTextColor
  mov edx, OFFSET inform
  call WriteString ;prints msg in inform
  mov edx, OFFSET char
  call WriteString ;prints msg in char
  mov edx, OFFSET exclaim
  call WriteString ;prints msg in exclaim
  call Crlf
ENDM

ScoreBoard MACRO char1, char2, char3, char4, char5
  mov edx, OFFSET char1
  call WriteString ;prints char1
  mov edx, OFFSET exclaim
  call WriteString ;prints exclaim
  call Crlf
  call Crlf
  mov edx, OFFSET divider
  call WriteString ;prints divider
  mov dl, 0
  mov dh, 3
  call Gotoxy
  mov edx, OFFSET player
  call WriteString ;prints player at gotoxy location
  mov dl, 14
  mov dh, 3
  call Gotoxy
  mov edx, OFFSET points_message
  call WriteString ;prints points_message at gotoxy location
  call Crlf
  mov edx, OFFSET divider
  call WriteString ;prints divider
  call Crlf
  mov dl, 0
  mov dh, 5
  call Gotoxy
  mov edx, OFFSET char2
  call WriteString ;prints char2 at gotoxy location
  mov dl, 15
  mov dh, 5
  call Gotoxy
  mov eax, char3
  call WriteInt ;prints char3 at gotoxy location
  call Crlf
  mov dl, 0
  mov dh, 6
  call Gotoxy
  mov edx, OFFSET char4
  call WriteString ;prints char4 at gotoxy location
  mov dl, 15
  mov dh, 6
  call Gotoxy
  mov eax, char5
  call WriteInt ;prints char5 at gotoxy location
  call Crlf
  jmp MoveOn
  jmp MoveOn
ENDM

ColorMsg MACRO char1, char2
  mov eax, (black*16) + char1
 call SetTextColor
 mov edx, OFFSET char2
 call WriteString
 call Crlf
 call Crlf
ENDM
 
.data
;--------------------------------------------------------
; All of the messages displayed to the user upon
; beginning the program.
;--------------------------------------------------------
intro BYTE "Welcome to WORDLE!",0
ruleIntro BYTE "The rules of the game are simple:",0
green_message BYTE "Green: Letter included in string, correct placement.",0
yellow_message BYTE "Yellow: Letter included in string, incorrect placement.",0
red_message BYTE "Red: Letter is not included within the string.",0
rule1 BYTE "1. This is more fun with two people, therefore, a two player game.",0
rule2 BYTE "2. One user must input a word for the other to guess.",0
rule3 BYTE "3. The inputted word must be 5 characters.",0
rule4 BYTE "4. If a string exceeds 5 characters the remaining characters will be dropped.",0
rule5 BYTE "5. If a string contains less than 5 characters the game ends.",0
rule6 BYTE "6. You only have 6 chances to figure out the word.",0
rule7 BYTE "7. There are a possible 600 points to score.",0

;--------------------------------------------------------
;  Set of options that displays upon running the program
;--------------------------------------------------------
opt1 BYTE "1",0
opt2 BYTE "2",0
opt3 BYTE "3",0
opt4 BYTE "4",0
options BYTE "Please select an option: ",0
option1 BYTE "(1). Rules",0
option2 BYTE "(2). Helpful Tips",0
option3 BYTE "(3). How Scoring Works",0
option4 BYTE "(4). Play Game",0
inputOptionPrompt BYTE "Type the number of the option you would like: ",0
helpful BYTE "Here are some helpful tips: ",0
helpful1 BYTE "1. Use vowels.",0
helpful2 BYTE "2. Use common letters",0
helpful3 BYTE "3. Avoid repeat letters not included.",0
scoring BYTE "This is how the scoring works.",0
scoring1 BYTE "1. Scores are calculated based on number of tries.",0
scoring2 BYTE "2. Scores are summed over a specified number of games.",0
scoring3 BYTE "3. Each player has the same number of tries per game.",0
scoring4 BYTE "4. The person with the most points wins!",0
invalidInput BYTE "The input character is invalid. Your game ends here. Better luck next time!",0
inputOption BYTE 2 DUP(?)


;--------------------------------------------------------
; All of the potential messages that are used upon the 
; completion of the program.
;--------------------------------------------------------
luck BYTE "Good Luck!",0
fail BYTE "Better Luck Next Time!",0
attempt1 BYTE "interesting... ig good job",0
pass BYTE "Wow! That Was Impressive!",0
ok_message BYTE "That was ok, you can do better.",0
score_message BYTE "You scored: ",0
points_message BYTE " Points",0
minus_points BYTE "-100 Points!",0
current_points BYTE "Potential points: ",0
not_valid BYTE "The inputted string is of an invalid size.",0
correct_word BYTE "The correct word was: ",0
foundWord DWORD 0
points DWORD 600      ; Initial number of potential points
currentPointsMsg BYTE "You currently have: ",0

;--------------------------------------------------------
; Messages displayed to the use once the program begins
; taking input during gameplay.
;--------------------------------------------------------
input_string BYTE "Input: ",0
attempt_string BYTE "Attempt: ",0

;--------------------------------------------------------
; Variable that is used to store the user input from the 
; ReadString function. Limit on the number of characters 
; that can be read from the user by setting size to 5 plus 
; the null pointer.
;--------------------------------------------------------
user_input BYTE 6 DUP(?)


;--------------------------------------------------------
; String given by the user when the program begins, this 
; is the string that will be used for comparisons from the 
; user input
;--------------------------------------------------------
true_string BYTE 6 DUP(?)
prompt_message BYTE "Input expected String (INPUT IS HIDDEN): ",0
welcomeMsg BYTE "Welcome ",0
user1 BYTE 10 DUP(?)
user2 BYTE 10 DUP(?)
promptUser1 BYTE "Player 1: ",0
promptUser2 BYTE "Player 2: ",0
promptNumber BYTE "Number of Rounds (1-5): ",0
pointsUser1 DWORD 0
pointsUser2 DWORD 0
numberOfRounds DWORD ?
index BYTE 1        ; Used for number of attempts
currentRound DWORD 1
inform BYTE "Choose a word ",0
startPlay BYTE "You're good to start guessing ",0
exclaim BYTE "!",0
currentPlayer BYTE 10 DUP(?)
tieMsg BYTE "it's a tie!",0
player BYTE "Player", 0

;--------------------------------------------------------
; Values used for the outputted screen of the scores
;--------------------------------------------------------
winnerMsg BYTE "Congratulations, ",0
divider BYTE 50 DUP ("=")

.code
;--------------------------------------------------------
;                         Main PROC
; Used as a driver for the program. Call all of the
; necessary procedures for the program to execute 
; properly. Calculates the number of attempts as well as
; the number of points a user can receive.
;--------------------------------------------------------
main PROC
 ; Call the procedures
 call DisplayLoad
 call ClrScr
 mov edx, OFFSET promptUser1
 call WriteString
 mov edx, OFFSET user1
 mov ecx, (LENGTHOF user1)
 call ReadString
 mov edx, OFFSET welcomeMsg
 call WriteString
 mov edx, OFFSET user1
 call WriteString
 call Crlf
 call Crlf
 mov edx, OFFSET promptUser2
 call WriteString
 mov edx, OFFSET user2
 mov ecx, (LENGTHOF user2)
 call ReadString
 mov edx, OFFSET welcomeMsg
 call WriteString
 mov edx, OFFSET user2
 call WriteString
 call Crlf
 call Crlf
 mov edx, OFFSET promptNumber
 call WriteString
 call ReadInt
 mov numberOfRounds, eax
 mov eax, 0
 cmp numberOfRounds, 0
 ja Good
 jbe NotValid 

 NotValid: ;exits game if an invalid number of rounds is selected
  call Crlf
  mov eax, (black*16) + lightRed
  call SetTextColor
  mov edx, OFFSET not_valid
  call WriteString
  mov eax, (black*16) + white
  call SetTextColor
  call Crlf
  INVOKE ExitProcess,0
 
 Good:
  cmp numberOfRounds, 5
  ja NotValid
 
 mov eax, numberOfRounds 
 mov ecx, 2
 mul ecx
 mov numberOfRounds, eax
 
 Control: ; Loop used to control the number of rounds of the game
 mov foundWord, 0
 mov index, 1
 mov points, 600 
 mov edx, 0
 mov eax, currentRound
 mov ecx, 2
 div ecx
 cmp edx, 0
 je PlayerOne
 jne PlayerTwo
 push edx
 PlayerOne:
  UserSetup user2
  jmp Cont

 PlayerTwo:
  UserSetup user1

 Cont:
  mov eax, (black*16) + white
  call SetTextColor
 
 call CollectString             ; Take string from user
 call WaitMsg
 call Crlf
 call Crlf
 mov eax, (black*16) + lightGreen
 call SetTextColor
 mov edx, OFFSET startPlay
 call WriteString
 ;pop edx
 mov edx, 0
 mov eax, currentRound
 mov ecx, 2
 div ecx
 cmp edx, 1
 je Two
 jne One

 One:
  mov edx, OFFSET user1
  jmp PassTwo
 Two:
  mov edx, OFFSET user2
 PassTwo:
  call WriteString
 mov edx, OFFSET exclaim
 call WriteString
 call Crlf                
 call Crlf 
 mov eax, (black*16) + white
 call SetTextColor
 mov al, index                  ; Initialize number of attempts
 mov edi,6                      ; Loop decrement varialbe

;--------------------------------------------------------
; Driver loop that takes care of the number of attempts
; of the user. Calculates the number of points the user
; has earned as well as the number of attempts the user
; has taken.
;--------------------------------------------------------
 L1:
  mov edx, OFFSET attempt_string
  call WriteString          
  call WriteInt             ; Write the number of attempts
                            ; to console
  call Crlf
  push edi                  ; Save values to stack
  push eax
  call ProcessInput         ; Take input from user and process
                            ; it accordingly
  cmp foundWord, 1
  je Break

  mov eax, points           ; Do point calculations based on
  sub eax, 100              ; number of attempts
  mov points, eax
  mov edx, OFFSET current_points
  call WriteString          
  mov eax, points
  call WriteInt             ; Print number of points to console
  mov edx, OFFSET points_message
  call WriteString
  call Crlf
  call Crlf
  pop eax		            ; Remove value from the stack
  inc al
  mov index, al             ; Load the current index into variable
  pop edi                   ; Remove value from the stack
  dec edi                   ; Decrement loop counter
  jnz L1

mov eax, (black*16) + lightRed
call SetTextColor           
mov edx, OFFSET fail
call WriteString            ; Write faile message
call Crlf
mov edx, OFFSET score_message
call WriteString            
mov al, 0
call WriteInt
mov edx, OFFSET points_message
call WriteString            ; Write number of points
                            ; to the console
call Crlf
call Crlf
mov eax, (black*16) + white
call SetTextColor
mov edx, OFFSET correct_word
call WriteString
mov eax, (black*16) + lightGreen
call SetTextColor
mov edx, OFFSET true_string
call WriteString
Break:
mov eax, (black*16) + white
call SetTextColor
call Crlf
mov edx, OFFSET currentPointsMsg
call WriteString
mov edx, 0
mov eax, currentRound
mov ecx, 2
div ecx
cmp edx, 1
je CurrentPointsOne
jne CurrentPointsTwo

CurrentPointsOne:
 mov eax, points
 add pointsUser1, eax
 ;mov pointsUser1, eax
 mov eax, pointsUser1
 call WriteInt
 jmp Skip

CurrentPointsTwo:
 mov eax, points
 add pointsUser2, eax
 mov eax, pointsUser2
 call WriteInt

Skip:
mov edx, OFFSET points_message
call WriteString
call Crlf
call Crlf
call WaitMsg
call Crlf
mov eax, currentRound
add eax, 1
mov currentRound, eax
cmp eax, numberOfRounds
jbe Control 
;call Crlf
call ScoreScreen
INVOKE ExitProcess,0       ; Once done, exit the program
main ENDP

DisplayLoad PROC
 mov eax, (black*16) + lightMagenta
 call SetTextColor
 mov dl,25					; Change the position of the 
                            ; text written to the console
 mov dh,0
 call GotoXY		
 mov edx, OFFSET intro
 call WriteString			; Write the intro message
 call Crlf
 call Crlf
 mov eax, (black*16) + lightGreen
 call SetTextColor
 mov edx, OFFSET options
 call WriteString
 mov eax, (black*16) + white
 call SetTextColor
 call Crlf
 call Crlf
 mov eax, (black*16) + yellow
 call SetTextColor
 mov edx, OFFSET option1
 call WriteString
 call Crlf
 mov edx, OFFSET option2
 call WriteString
 call Crlf
 mov edx, OFFSET option3
 call WriteString
 call Crlf
 mov edx, OFFSET option4
 call WriteString
 call Crlf
 call Crlf
 mov eax, (black*16) + white
 call SetTextColor
 mov edx, OFFSET inputOptionPrompt
 call WriteString
 mov edx, OFFSET inputOption
 mov ecx, (lengthof inputOption)
 mov eax, (black*16) + lightGreen
 call SetTextColor
 call ReadString
 mov eax, (black*16) + white
 call SetTextColor

 mov al, [inputOption]
 cmp al, [opt1]
 je First
 cmp al, opt2
 je Second
 cmp al, opt3
 je Third
 cmp al, opt4
 je Fourth
 jne Invalid
 
 First: ;prints the rules of the game
  call ClrScr
  call DisplayRules
  call WaitMsg
  call ClrScr
  jmp Home

 Second: ;prints helpful hints for the game
  call ClrScr
  mov eax, (black*16) + lightGreen
  call SetTextColor
  mov edx, OFFSET helpful
  call WriteString
  mov eax, (black*16) + yellow
  call SetTextColor
  call Crlf
  call Crlf
  mov edx, OFFSET helpful1  
  call WriteString
  call Crlf
  mov edx, OFFSET helpful2
  call WriteString
  call Crlf
  mov edx, OFFSET helpful3
  call WriteString
  call Crlf
  call Crlf
  mov eax, (black*16) + white
  call SetTextColor
  call WaitMsg
  call ClrScr
  jmp Home
 
 Third: ;prints out information on scoring
  call ClrScr
  mov eax, (black*16) + lightGreen
  call SetTextColor
  mov edx, OFFSET scoring
  call WriteString
  mov eax, (black*16) + yellow
  call SetTextColor
  call Crlf
  call Crlf
  mov edx, OFFSET scoring1
  call WriteString
  call Crlf
  mov edx, OFFSET scoring2
  call WriteString
  call Crlf
  mov edx, OFFSET scoring3
  call WriteString
  call Crlf
  mov edx, OFFSET scoring4
  call WriteString
  call Crlf
  call Crlf
  mov eax, (black*16) + white
  call SetTextColor
  call WaitMsg
  call ClrScr
  jmp Home

 Fourth: ;starts the game
  jmp Escape

 Invalid: ;invalid option was selected game closes
  mov eax, (black*16) + lightRed
  call SetTextColor
  call Crlf
  mov edx, OFFSET invalidInput
  call WriteString
  mov eax, (black*16) + white
  call SetTextColor
  call Crlf
  INVOKE ExitProcess,0

 Home:
  call DisplayLoad
    
 Escape:
  ret 
DisplayLoad ENDP

ScoreScreen PROC
 call ClrScr 
 mov edx, OFFSET winnerMsg
 call WriteString
 mov eax, pointsUser1
 cmp eax, pointsUser2 ; decides who the winner was based on points accumulated
 je Tie
 jb TwoWon
 ja OneWon

 Tie:
  ScoreBoard tieMsg, user2, pointsUser1, user1, pointsUser2 ;print the scoreboard with a tie

 OneWon:
  ScoreBoard user2, user2, pointsUser1, user1, pointsUser2 ;print scoreboard with player 1 as champ

 TwoWon:
  ScoreBoard user1, user1, pointsUser2, user2, pointsUser1 ;print scoreboard with player 2 as champ
 
 MoveOn:
  mov edx, OFFSET divider
  call WriteString
  call Crlf
  call Crlf
  ret
ScoreScreen ENDP

;--------------------------------------------------------
;					DisplayRules PROC
; Output the various rules of the program to the console
; before it prompts the user for input.
;--------------------------------------------------------
DisplayRules PROC
 ColorMsg lightGreen, green_message
 ColorMsg yellow, yellow_message
 ColorMsg lightRed, red_message
 mov eax, (black*16) + cyan
 call SetTextColor
 mov edx, OFFSET rule1		
 call WriteString
 call Crlf
 mov edx, OFFSET rule2		
 call WriteString
 call Crlf
 mov edx, OFFSET rule3
 call WriteString
 call Crlf
 mov edx, OFFSET rule4		
 call WriteString
 call Crlf
 mov edx, OFFSET rule5		
 call WriteString
 call Crlf
 mov edx, OFFSET rule6
 call WriteString
 call Crlf
 mov edx, OFFSET rule7		
 call WriteString
 call Crlf
 mov dl,29
 mov dh,14
 call GoToXY                ; Change position
 ColorMsg lightMagenta, luck
 mov eax, (black*16) + white
 call SetTextColor          ; Revert color back
 ret
DisplayRules ENDP


;--------------------------------------------------------
;				    CollectString PROC
; Procedure that takes input for the value of the string
; that the comparisons will be paried against.
;--------------------------------------------------------
CollectString PROC
 mov edx, OFFSET prompt_message
 call WriteString			; Output message		 
 mov eax, (black*16) + black
 call SetTextColor			; Hide input from user
 mov edx, OFFSET true_string
 mov ecx, (LENGTHOF true_string)
 call ReadString            ; Read input
 ToUpper edx                ; Call toUpper macro
 mov eax, (black*16) + white
 call SetTextColor			; Revert text color to white
 mov edi, OFFSET [true_string]
 mov ecx, LENGTHOF true_string - 1
 call IsValid		        ; Check if input length is valid
 call Crlf
 ret                        ; Return back to callee proc
CollectString ENDP


;--------------------------------------------------------
;                   IsValid PROC
; Check validity of the inputted strings. If strings are
; determined to be invalid. Exit the program. The user
; must ensure that the length of the string meets the 
; requirements.
;--------------------------------------------------------
IsValid PROC
 mov al, 0h                 ; Move null character to register
 cld
 repne scasb                ; Search string for null
 jnz Return                 ; If not found
 jz NotValid                ; If found
 
 NotValid:
  call Crlf
  mov eax,(black*16) + lightRed  
  call SetTextColor         ; Change text to red
  mov edx, OFFSET not_valid 
  call WriteString          ; Write invalid message
  mov eax,(black*16) + white
  call SetTextColor         ; Rever color
  call Crlf
  INVOKE ExitProcess,0      ; Exit the program
   
 Return:
  ret                       ; Return to callee
IsValid ENDP
 

;--------------------------------------------------------
;					ProcessInput PROC
; Procedure takes input from the user and compares it to
; a selected word from the list provided to check for
; the correctness of the users inputted value.
;--------------------------------------------------------
ProcessInput PROC
 mov edx, OFFSET input_string       
 call WriteString           ; Output input header

 mov edx, OFFSET user_input         
 mov ecx, (LENGTHOF user_input) 
 call ReadString            ; Take user input
 
 ToUpper edx                ; Call toUpper macro

 mov edi, OFFSET [user_input]
 mov ecx, LENGTHOF user_input - 1 
 call IsValid               ; Check to see if input is
                            ; valid

 mov edx, OFFSET attempt_string     
 call WriteString           ; Output attempt header
 
 ; Initialize register values with input from the users
 mov edi, OFFSET [true_string]      
 mov esi, OFFSET [user_input]
 
 mov ecx, LENGTHOF true_string
 repe cmpsb                 ; Check to see if strings match 
 cmp ecx, 0
 je CompleteEqual           ; If equal output to user and 
                            ; terminate program
 jne NotEqual               ; If not jump to NotEqual


;--------------------------------------------------------
; If compare function jumps, the strings are exact
; matches. In this case, output the number of points to
; the user and congratulate. Once, completed. Terminate
; the program.
;--------------------------------------------------------
 CompleteEqual:            
  mov eax,(black*16) + lightGreen 
  call SetTextColor         ; Change text color to light green
  mov edx, OFFSET user_input
  call WriteString          ; Print user inputted value
  call Crlf
  call Crlf

  mov eax, points
  
  cmp eax, 600              ; Determine output based on 
  je Impossible             ; number of points acquired
  cmp eax, 300
  jae Good
  jb Ok
  
  Impossible:               ; If guessed correctly first try
   mov edx, OFFSET attempt1
   call WriteString         ; Write string
   jmp Break               
  
  Good:                     ; If gotten within four tries
   mov edx, OFFSET pass
   call WriteString         ; Write string
   jmp Break
  
  Ok:                       ; If gotten in 5 or 6 tries
   mov edx, OFFSET ok_message
   call WriteString         ; Write string
   jmp Break
  
  Break:                    ; Output messages to user, terminate
   mov eax, (black*16) + white
   call SetTextColor        ; Revert textcolor
   call Crlf
   mov edx, OFFSET score_message
   call WriteString         ; Output leading score message
   mov eax, points          
   call WriteInt            ; Output number of points
   mov edx, OFFSET points_message
   call WriteString         ; Follow by the unit (Points)
   call Crlf
   mov foundWord, 1
   ret
   ; INVOKE ExitProcess,0     ; Terminate the program

;--------------------------------------------------------
; If the input did not match the correct string. Iterate 
; through the two strings and determine the color of the
; character to output to the console.Once completed return 
; to main and continue iterating through the program until
; either, the correct string is inputted or the number of 
; tries has run out.
;--------------------------------------------------------

 NotEqual:                  ; If complete equality was not acheived
  mov edi, OFFSET [user_input]       ; Reinitialize registers
  mov esi, OFFSET [true_string]
  mov cl, 1                 ; Initialize counter register
  outer:                    ; Iterate through characters in string
   mov al, [edi]            ; Byte comparison for strings
   mov dl, [esi]
   cmp al, dl               ; Check for equality
   je DirectMatch           ; If character match
   jne PotentialMatch       ; Else

   DirectMatch:             ; Given that the characters match
    mov eax,(black*16) + lightGreen
    call SetTextColor       ; Change text color
    mov al, [edi]
    call WriteChar          ; Output character
    mov eax,(black*16) + white
    call SetTextColor       ; Revert text color
    jmp Escape              ; Jump to Escape

   PotentialMatch:          ; Check to see if instance of character
    mov al, [edi]           ; exists within the user inputted string
    push esi                
    push edi                ; Store values on stack
    push ecx
    mov edi, OFFSET [true_string]
    mov ecx, LENGTHOF true_string 
    cld
    repne scasb             ; Check for instance of inputted character
    pop ecx                 ; in given string
    pop edi
    pop esi                 ; Pop all of the values from the stack
    mov al, [edi]
    jnz NotFound            ; If no instance of character
    jz Found                ; Else

   Found:                   ; If character exists within the string
    mov eax,(black*16) + yellow
    call SetTextColor       ; Change text color
    mov al, [edi]
    call WriteChar          ; Output character
    mov eax,(black*16) + white
    call SetTextColor       ; Revert text color
    jmp Escape              ; Jump to escape

   NotFound:                ; If not instance of character is found
    mov eax,(black*16) + lightRed
    call SetTextColor       ; Change color of output
    mov al, [edi]       
    call WriteChar          ; Write character to console
    mov eax,(black*16) + white
    call SetTextColor       ; Revert text color
    jmp Escape              ; Jump to escape

   Escape:                  ; Increment the loop until no longer
    inc esi                 ; valid. Check every characeter in
    inc edi                 ; string.
    inc cl
    cmp cl, 6
    jne outer

 call Crlf
 call Crlf
 mov edx, OFFSET minus_points
 call WriteString           ; Out number of points lost
 call Crlf
 ret                        ; Return to driver loop in main PROC
ProcessInput ENDP
END main
