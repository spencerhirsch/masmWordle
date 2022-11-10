.386
.model flat, stdcall
INCLUDE Irvine32.inc

.data
;list DWORD "hello", "start", "catch", "tacos",0

; Messages that are displayed in the console once the program begins
intro BYTE "Welcome to WORDLE!",0
ruleIntro BYTE "The rules of the game are simple:",0
rule1 BYTE "1. The inputted word must be 5 characters.",0
rule2 BYTE "2. All words can be found in the English dictionary.",0
rule3 BYTE "3. You only have 5 chances to figure out the word.",0
luck BYTE "Good Luck!",0

user_input BYTE 5 DUP(?)		; Limit on the number of characters that
								; can be read from the user

.code
main PROC
 CALL rules
; call SetTextColor ( will use to show incorrect letters, correct placement, and valid letter but incorrect placement. )
; mov eax, green
; call SetTextColor
; revert color back to white, do this for each character read in from the user.
 
;CALL processInput
;INVOKE ExitProcess,0
; This don't work, no clue why, //TODO
 mov ecx,5
 L1:
	CALL processInput
	loop L1
INVOKE ExitProcess,0
main ENDP

;=====================================================================
;								rules PROC
; Function outputs the rules of the game to the console before waiting
; for user input. Allows the user to understand how to play the game.
;=====================================================================

rules PROC
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
 call WaitMsg
 ; After the user has moved on clear the screen.
 call ClrScr
rules ENDP

;======================================================
;					processInput PROC
; Procedure takes input from the user and compares it to
; a selected word from the list provided to check for
; the correctness of the users inputted value.
;======================================================
processInput PROC
 mov edx, OFFSET user_input
 mov ecx, (LENGTHOF user_input) + 1
 call ReadString
 mov edx, OFFSET user_input
 call WriteString
 call Crlf
processInput ENDP

END main
