.386
.model flat, stdcall
INCLUDE Irvine32.inc

.data

; Messages that are displayed in the console once the program begins
intro BYTE "Welcome to WORDLE!",0
ruleIntro BYTE "The rules of the game are simple:",0
rule1 BYTE "1. The inputted word must be 5 characters.",0
rule2 BYTE "2. All words can be found in the English dictionary.",0
rule3 BYTE "3. You only have 6 chances to figure out the word.",0
luck BYTE "Good Luck!",0
; Messages displayed as the user inputs words into the console
input_string BYTE "Input: ",0
attempt_string BYTE "Attempt: ",0

; Variable that is used to store the user input from the ReadString function
user_input BYTE 6 DUP(?)		; Limit on the number of characters that
								; can be read from the user by setting size
								; to 5

; String given by the user when the program begins, this is the string that
; will be used for comparisons from the user input
true_string BYTE 6 DUP(?)
prompt_message BYTE "Input expected String: ",0

index BYTE 1

.code
main PROC
 ; Call the procedures
 call OutputLoad
 call CollectString
 call WaitMsg
 call Crlf
 call Crlf 

 mov al, index
 mov edi,6
 L1:
  call ProcessInput		
  inc al
  mov index, al
  push edi
  pop edi
  dec edi
  jnz L1

INVOKE ExitProcess,0
main ENDP

;======================================================
;					OutoutLoad PROC
; Function outputs the rules of the game to the console
; before waiting for user input. Allows the user to 
; understand how to play the game.
;======================================================

OutputLoad PROC
 ; Write out the introductory message when the program is run.
 mov dl,25					; Change the position of the text written to the console
 mov dh,0
 call GotoXY		
 mov edx, OFFSET intro
 call WriteString			; Write the intro message to the console
 call Crlf
 call Crlf
 mov edx, OFFSET ruleIntro	; Write the rule intro to the console
 call WriteString
 call Crlf
 call Crlf
 mov edx, OFFSET rule1		; Write the first rule to the console
 call WriteString
 call Crlf
 mov edx, OFFSET rule2		; Write the second rule to the console
 call WriteString
 call Crlf
 mov edx, OFFSET rule3		; Write the last rule to the console
 call WriteString
 call Crlf
 call Crlf
 mov dl,29
 mov dh,8
 call GoToXY
 mov edx, OFFSET luck		; Output final message before program begins
 call WriteString
 call Crlf
 call Crlf
 ; After the user has moved on clear the screen.
 ret
OutputLoad ENDP


;======================================================
;				    CollectString PROC
; Procedure that takes input for the value of the string
; that the comparisons will be paried against.
;======================================================
CollectString PROC
 mov edx, OFFSET prompt_message
 call WriteString					; print message to console asking for input

 mov edx, OFFSET true_string
 mov ecx, (LENGTHOF true_string)
 call ReadString					; save the inputted value for true_string
 call Crlf
 ret
CollectString ENDP

;======================================================
;					ProcessInput PROC
; Procedure takes input from the user and compares it to
; a selected word from the list provided to check for
; the correctness of the users inputted value.
;======================================================
ProcessInput PROC
 mov edx, OFFSET input_string
 call WriteString
 mov edx, OFFSET user_input
 mov ecx, (LENGTHOF user_input) 
 call ReadString ;;;;;;;;;

 mov edx, OFFSET attempt_string
 call WriteString
 
 ; Didn't work, would like to implement.
 ;mov esi, OFFSET [true_string]
 ;mov edi, OFFSET [user_input]
 ;repe cmpsb

 ;je Equal
 ;Equal:
 ; mov eax, (black*16) + green
 ; call SetTextColor
 ; mov edx, OFFSET user_input
 ; call WriteString
 ; mov eax, (black*16) + white
 ; call SetTextColor
 ; INVOKE ExitProcess,0
  

 mov esi,0 
 mov esi, OFFSET [true_string]
 
 ;mov ebx, 0
 ;mov ebx, OFFSET user_input
 mov edi, OFFSET [user_input]
 
 ;mov ecx, (LENGTHOF true_string) - 1
 mov ecx, LENGTHOF true_string
 repe cmpsb
 cmp ecx, 0
 je Here
 jne NotEqual
 Here:
    mov eax,(black*16) + green
    call SetTextColor
    mov edx, OFFSET user_input
    call WriteString
    mov eax,(black*16) + white
    call SetTextColor
    INVOKE ExitProcess,0

 ;NotEqual:
 ;  mov edi, OFFSET [user_input]
 ;  mov esi, OFFSET [true_string]
 ;  mov ecx, (LENGTHOF true_string)
   
 ;  cmpsb
 ;  je Match
 ;  jne PotentialMatch2
 NotEqual:
 mov edi, OFFSET [user_input]
 mov esi, OFFSET [true_string]
 mov dl, 1
 outer:
  mov al, [esi]
  mov dl, [edi]
  cmp al, dl
  je DirectMatch
  ;cld
  cmpsb
  dec edi
  dec esi
  je DirectMatch
  jne PotentialMatch

  DirectMatch:
   mov eax,(black*16) + green
   call SetTextColor
   mov al, [edi]
   call WriteChar
   mov eax,(black*16) + white
   call SetTextColor
   mov al, 0
   cmp al, 0
   je Escape

  PotentialMatch:
   mov al, [edi]
   mov edi, OFFSET [true_string]
   mov ecx, LENGTHOF true_string
   cld
   repne scasb
   mov edi, OFFSET [user_input]
   jnz NotFound
   ;dec edi
   jz Found

  Found:
   mov eax,(black*16) + yellow
   call SetTextColor
   ;mov al, [ebx]
   mov al, [edi]
   call WriteChar
   mov eax,(black*16) + white
   call SetTextColor
   mov al, 0
   cmp al,0
   je Escape

   NotFound:
    mov eax,(black*16) + red
    call SetTextColor
    mov al, [edi]
    call WriteChar
    mov eax,(black*16) + white
    call SetTextColor
    mov al, 0
    cmp al,0
    je Escape

   Escape:
    inc esi
    inc edi
    ;dec cx
    inc dl
    cmp dl, 6
    jne outer

 call Crlf
 ret
ProcessInput ENDP

END main
