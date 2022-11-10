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
user_input BYTE 5 DUP(?)		; Limit on the number of characters that
								; can be read from the user by setting size
								; to 5

; String given by the user when the program begins, this is the string that
; will be used for comparisons from the user input
true_string BYTE 5 DUP(?)
prompt_message BYTE "Input expected String: ",0

index BYTE 1

.code
main PROC
 call OutputLoad
 call CollectString
 call WaitMsg
 call Crlf
 call Crlf
; call SetTextColor ( will use to show incorrect letters, correct placement, and valid letter but incorrect placement. )
; mov eax, green
; call SetTextColor
; revert color back to white, do this for each character read in from the user.
 
 mov al, index
 mov edi,6
 L1:
  call ProcessInput		; Want to implement a check to see if the user inputted a value that is actually of length 5
							; If greater than 5 output to the console and and notify the user and allow for reinput

							; implement a state machine to do character comparison, output each character in a color
							; to signifiy the input has correct placement, character is in word, or character is not in
							; the word

							; would like to have a display at the bottom of the screen of all valid characters, after each
							; input the list of characters would be updated to show whether that was tried and not in the word 
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
 call WriteString
 ;call DisableEcho ; Need to implement
 mov edx, OFFSET true_string
 mov ecx, (LENGTHOF true_string) + 1
 call ReadString
 ;call EnableEcho : Need to implement
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
 mov ecx, (LENGTHOF user_input) + 1
 call ReadString
; implement a state machine to do the comparison for all values of the input.
 mov edx, OFFSET attempt_string
 call WriteString
 ;mov index, al
 ;mov edx, OFFSET index
 ;call WriteInt
 mov edx, OFFSET user_input
 call WriteString
 call Crlf
 ret
ProcessInput ENDP

END main
