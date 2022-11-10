.386
.model flat, stdcall
INCLUDE Irvine32.inc

FIELDLEN=32
DISPX=16

optionMenu MACRO

ENDM

displayChoices MACRO
	
ENDM

.data
;list DWORD "hello", "start", "catch", "tacos",0
intro BYTE "Welcome to WORDLE!",0
ruleIntro BYTE "The rules of the game are simple:",0
rule1 BYTE "1. The inputted word must be 5 characters.",0
rule2 BYTE "2. All words can be found in the English dictionary.",0
rule3 BYTE "3. You only have 5 chances to figure out the word.",0
luck BYTE "Good Luck!",0

user_input BYTE 80 DUP(?)
max BYTE 5
optionMenu 

.code
main PROC
 ; Write out the introductory message when the program is run.
 mov dl,25
 mov dh,0
 call GotoXY
 mov edx, OFFSET intro
 call WriteString
 call Crlf
 call Crlf
 mov edx, OFFSET ruleIntro
 call WriteString
 call Crlf
 call Crlf
 mov edx, OFFSET rule1
 call WriteString
 call Crlf
 mov edx, OFFSET rule2
 call WriteString
 call Crlf
 mov edx, OFFSET rule3
 call WriteString
 call Crlf
 call Crlf
 mov dl,29
 mov dh,8
 call GoToXY
 mov edx, OFFSET luck
 call WriteString
 call Crlf
 call Crlf
 call WaitMsg
 ; After the user has moved on clear the screen.
 call ClrScr
; call SetTextColor ( will use to show incorrect letters, correct placement, and valid letter but incorrect placement. )
; mov eax, green
; call SetTextColor
; revert color back to white, do this for each character read in from the user.
 mov esi,0
 L1:
	mov edx, OFFSET user_input
	mov ecx, (LENGTHOF user_input - 1)
	call ReadString
	mov edx, OFFSET user_input
	call WriteString
	call Crlf
	inc esi
	loop L1
main ENDP
END main