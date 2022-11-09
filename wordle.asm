.386
.model flat, stdcalll
include Irvine32.inc

.data
list DWORD "hello", "start", "catch", "tacos",0
user_input BYTE ?,0
max BYTE 5,0

.code
main PROC
mov ecx, 5
loop L1:
	; take input from the user
	; needs to execute 5 times if the result was not found beforehan
end L1

endp
END main

