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

points DWORD 600      ; Initial number of potential points

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

index BYTE 1        ; Used for number of attempts

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
 call OutputLoad                ; Show loading screen
 call CollectString             ; Take string from user
 call WaitMsg                
 call Crlf
 call Crlf 

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
mov eax, (black+16) + white
call SetTextColor
call Crlf
INVOKE ExitProcess,0       ; Once done, exit the program
main ENDP


;--------------------------------------------------------
;					OutputLoad PROC
; Function outputs the rules of the game to the console
; before waiting for user input. Allows the user to 
; understand how to play the game.
;--------------------------------------------------------
OutputLoad PROC
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
 mov edx, OFFSET ruleIntro	; Write the rule introduction
 call WriteString
 call Crlf
 call Crlf
;--------------------------------------------------------
; Output the various rules of the program to the console
; before it prompts the user for input.
;--------------------------------------------------------
 mov eax, (black*16) + lightGreen
 call SetTextColor
 mov edx, OFFSET green_message
 call WriteString
 call Crlf
 mov eax, (black*16) + yellow
 call SetTextColor
 mov edx, OFFSET yellow_message
 call WriteString
 call Crlf
 mov eax, (black*16) + lightRed
 call SetTextColor
 mov edx, OFFSET red_message
 call WriteString
 call Crlf
 call Crlf
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
 call Crlf
 call Crlf
 mov dl,29
 mov dh,17
 call GoToXY                ; Change position
 mov eax, (black*16) + lightMagenta
 call SetTextColor
 mov edx, OFFSET luck		; Output final message
 call WriteString
 call Crlf
 call Crlf
 mov eax, (black*16) + white
 call SetTextColor          ; Revert color back
 ret
OutputLoad ENDP


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
   INVOKE ExitProcess,0     ; Terminate the program

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

