;--------------------------------------------------------
; Authors: Spencer Hirsch, shirsch2020@my.fit.edu, James
;          Pabisz, jpabisz2020@my.fit.edu
; Program: Wordle in Assembly (Contest 1)
; Course: Computer Architecture and Assembly, Fall 2022
;--------------------------------------------------------

.386
;.model flat, stdcall
INCLUDE Irvine32.inc

.data
;--------------------------------------------------------
; All of the messages displayed to the user upon
; beginning the program.
;--------------------------------------------------------
intro BYTE "Welcome to WORDLE!",0
ruleIntro BYTE "The rules of the game are simple:",0
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
prompt_message BYTE "Input expected String: ",0

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
  call WriteInt
  call Crlf
  push edi
  push eax
  call ProcessInput
  mov eax, points
  sub eax, 100
  mov points, eax
  mov edx, OFFSET current_points
  call WriteString
  mov eax, points
  call WriteInt
  mov edx, OFFSET points_message
  call WriteString
  call Crlf
  call Crlf
  pop eax		
  inc al
  mov index, al
  pop edi
  dec edi
  jnz L1

mov eax, (black*16) + lightRed
call SetTextColor
mov edx, OFFSET fail
call WriteString
call Crlf
mov edx, OFFSET score_message
call WriteString
mov al, 0
call WriteInt
mov edx, OFFSET points_message
call WriteString
call Crlf
call Crlf
mov eax, (black*16) + white
call SetTextColor
INVOKE ExitProcess,0
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
 ; Output the list of rules to the console for the user
 ; to read
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
 mov dh,12
 call GoToXY
 mov eax, (black*16) + lightMagenta
 call SetTextColor
 mov edx, OFFSET luck		; Output final message
 call WriteString
 call Crlf
 call Crlf
 mov eax, (black*16) + white
 call SetTextColor
 ret
OutputLoad ENDP


;--------------------------------------------------------
;				    CollectString PROC
; Procedure that takes input for the value of the string
; that the comparisons will be paried against.
;--------------------------------------------------------
CollectString PROC
 mov edx, OFFSET prompt_message
 call WriteString					
 mov edx, OFFSET true_string
 mov ecx, (LENGTHOF true_string)
 call ReadString
 mov edi, OFFSET [true_string]
 mov ecx, LENGTHOF true_string - 1
 call IsValid		
 call Crlf
 ret
CollectString ENDP

;--------------------------------------------------------
;                   IsValid PROC
; Check validity of the inputted strings. If strings are
; determined to be invalid. Exit the program. The user
; must ensure that the length of the string meets the 
; requirements.
;--------------------------------------------------------
IsValid PROC
 mov al, 0h
 ;mov edi, OFFSET [true_string]
 ;mov ecx, LENGTHOF true_string - 1
 cld
 repne scasb
 jnz Return
 jz NotValid
 
 NotValid:
  call Crlf
  mov eax,(black*16) + red
  call SetTextColor
  mov edx, OFFSET not_valid
  call WriteString
  mov eax,(black*16) + white
  call SetTextColor
  call Crlf
  INVOKE ExitProcess,0
   
 Return:
  ret 
IsValid ENDP
 
;--------------------------------------------------------
;					ProcessInput PROC
; Procedure takes input from the user and compares it to
; a selected word from the list provided to check for
; the correctness of the users inputted value.
;--------------------------------------------------------
ProcessInput PROC
 mov edx, OFFSET input_string       ; Output input header
 call WriteString
 mov edx, OFFSET user_input         ; Take user input
 mov ecx, (LENGTHOF user_input) 
 call ReadString
 mov edi, OFFSET [user_input]
 mov ecx, LENGTHOF user_input - 1 
 call IsValid
 mov edx, OFFSET attempt_string     ; Output attempt header
 call WriteString
 
 ; Initialize register values with input from the users
 mov edi, OFFSET [true_string]      
 mov esi, OFFSET [user_input]
 
 ; Do a complete comparison of the strings
 mov ecx, LENGTHOF true_string
 repe cmpsb             ; 
 cmp ecx, 0
 je CompleteEqual       ; If equal output to user and terminate program
 jne NotEqual           ; If not call the NotEqual function
 CompleteEqual:         ; Check for complete equality of the inputted value
  mov eax,(black*16) + lightGreen      ; Change text color to gree
  call SetTextColor
  mov edx, OFFSET user_input
  call WriteString                ; Print user inputted value
  mov eax,(black*16) + lightGreen
  call SetTextColor
  call Crlf
  call Crlf

  mov eax, points
  
  cmp eax, 600
  je Impossible
  cmp eax, 300
  jae Good
  jb Ok
  
  Impossible:
   mov edx, OFFSET attempt1
   call WriteString
   jmp Break
  
  Good:
   mov edx, OFFSET pass
   call WriteString
   jmp Break
  
  Ok:
   mov edx, OFFSET ok_message
   call WriteString
   jmp Break
  
  Break:
   mov eax, (black*16) + white
   call SetTextColor
   call Crlf
   mov edx, OFFSET score_message
   call WriteString
   mov eax, points
   call WriteInt
   mov edx, OFFSET points_message
   call WriteString
   call Crlf
   INVOKE ExitProcess,0            ; Input was correct, terminate the program

 NotEqual:                        ; If complete equality was not acheived
  mov edi, OFFSET [user_input]       ; Reinitialize registers
  mov esi, OFFSET [true_string]
  mov cl, 1                          ; initialize counter register
  outer:
   mov al, [edi]                     ; Byte comparison for strings
   mov dl, [esi]
   cmp al, dl                        ; Check for equality
   je DirectMatch
   jne PotentialMatch

   ; Given that the characters match
   DirectMatch:
    mov eax,(black*16) + lightGreen
    call SetTextColor
    mov al, [edi]
    call WriteChar
    mov eax,(black*16) + white
    call SetTextColor
    jmp Escape

   PotentialMatch:
    mov al, [edi]
    push esi
    push edi
    push ecx
    mov edi, OFFSET [true_string]
    mov ecx, LENGTHOF true_string 
    cld
    repne scasb
    pop ecx
    pop edi
    pop esi
    mov al, [edi]
    jnz NotFound
    jz Found

   Found:
    mov eax,(black*16) + yellow
    call SetTextColor
    mov al, [edi]
    call WriteChar
    mov eax,(black*16) + white
    call SetTextColor
    jmp Escape

   NotFound:
    mov eax,(black*16) + lightRed
    call SetTextColor
    mov al, [edi]       ; probs
    call WriteChar
    mov eax,(black*16) + white
    call SetTextColor
    jmp Escape

   Escape:
    inc esi
    inc edi
    inc cl
    cmp cl, 6
    jne outer

 call Crlf
 call Crlf
 mov edx, OFFSET minus_points
 call WriteString
 call Crlf
 ret
ProcessInput ENDP
END main