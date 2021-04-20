org 0x0
jmp main1
;org 000BH ;isr of timer0
;	jmp isr_0
org 001BH ;isr of timer1
	jmp isr_1

	
	
	
	
	
	
	
org 0x30













;--------------------------------------------------------MAIN----------------------------------------------------------------------
main1:
mov 2FH,#0FFH
mov 2EH,#0FFH


mov TMOD,#00010000B



mov TL1,#078H
mov TH1,#04BH


setb EA

setb ET1


clr TF1


setb TR1
mov r6,#20
mov r5,#60
mov r0,#60
mov r1,#24
mov r4,#00
error:
call first_display
main:
call scanning_input


call input_check
mov a,40H
cjne a,#3AH,firstinput_hash
call time_set
call delay
jmp check_for_AM_PM
firstinput_hash:
mov a,40H
cjne a,#3BH,error
call alarm_set
check_for_AM_PM:
jmp main





;--------------------------------------------------------input_check----------------------------------------------------------------------
to_digit_1:
jmp error

input_check:
mov a,40H
d1:
cjne a,#3AH,c_hash1
jmp d2
c_hash1:
cjne a,#3BH,to_digit_1
d2:
mov a,41H
cjne a,#30H,c_hash2
jmp d3
c_hash2:
cjne a,#31H,to_digit_1
jmp d3
d3:
mov a,42H
cjne a,#30H,c_hash3
jmp d4
c_hash3:
cjne a,#31H,c_2_3
jmp d4
c_2_3:
cjne a,#32H,to_digit_1
jmp d4
d4:
mov a,43H
cjne a,#30H,c_hash4
jmp d5
c_hash4:
cjne a,#31H,c_2_4
jmp d5
c_2_4:
cjne a,#32H,c_3_4
jmp d5
c_3_4:
cjne a,#33H,c_4_4
jmp d5
c_4_4:
cjne a,#34H,c_5_4
jmp d5
c_5_4:
cjne a,#35H,to_digit_1
jmp d5
d5:
mov a,44H
cjne a,#3AH,c_hash5
jmp error
c_hash5:
cjne a,#3BH,d6
jmp error
d6:
mov a,45H
cjne a,#3AH,c_hash6
;setb p2.5
mov 1DH,#00H
jmp return_c
c_hash6:
cjne a,#3BH,to_digit_1
;clr p2.5
mov 1DH,#01H
return_c:
ret

scanning_input:
digit_1:
call SCANNING
call delay
mov 40H,r4;#3AH
digit_2:
call SCANNING
call delay
mov 41H,r4;#31H
digit_3:
call SCANNING
call delay
mov 42H,r4;#32H
digit_4:
call SCANNING
call delay
mov 43H,r4;#35H
digit_5:
call SCANNING
call delay
mov 44H,r4;#39H
digit_6:
call SCANNING
call delay
mov 45H,r4;#3BH
ret
;--------------------------------------------------------TIME_SET----------------------------------------------------------------------

time_set:
;clr TF1
;clr TR1
call input_dsep
mov a, 41H
swap a
mov b, 42H
add a,b
mov r2,a
mov a, 43H
swap a
mov b, 44H
add a,b
mov r3,a
mov a,#10
mov b,43H
mul ab
add a,44H
mov 17H,a
call digit_sep
call Converting
call disp
mov r6,#20
mov r5,#60
mov a,#60
mov b,17H
clr psw.7
clr psw.6
SUBB a,b
mov r0,a
mov r1,#24
mov r4,#00

;mov TL1,#078H
;mov TH1,#04BH
;setb TR1
ret



;--------------------------------------------------------ALARM_SET---------------------------------------------------------------------

alarm_set:

call input_dsep
mov a, 41H
swap a
mov b, 42H
add a,b
mov 2EH,a
mov a, 43H
swap a
mov b, 44H
add a,b
mov 2FH,a
;call digit_sep
;call Converting
;call disp
;mov TL0,#078H
;mov TH0,#04BH

;setb ET0
;clr TF0
;;clr TR1

;setb TR0
ret

c_alarm:
mov 68H,#200

mov a,r3
mov b,2FH
clr psw.7
clr psw.6
SUBB a,b
cjne a,#0,hr_not1
mov a,r2
mov b,2EH
clr psw.7
clr psw.6
SUBB a,b
cjne a,#0,min_not1
call digit_sep
call Converting
call disp
clr p0.5
Looper:
call delay
Djnz 68H,Looper
mov 2FH,#0FFH
mov 2EH,#0FFH
setb p0.5
;clr ET0
;clr TR0
;jmp end_isr0
hr_not1:
min_not1:
ret


;--------------------------------------------------------ISR_1_FOR_CLOCK----------------------------------------------------------------------
isr_1:

clr tr1
dec r6
CJNE_FOR_R6:
cjne r6,#0,not_zero
inc 10H
;cjne r4,#10,CJNE_FOR_R5   ;checking secs
;mov r4,#10H

CJNE_FOR_R5:
dec r5
cjne r5,#0,nsec_60
inc r3
jmp hr_not
nsec_60:
jmp not_60s
not_zero:
jmp not_equal_0
min_not:
hr_not:
cjne r3,#0AH,c_20   ;checking secs
mov r3,#10H
c_20:
cjne r3,#1AH,c_30  ;checking secs
mov r3,#20H
c_30:
cjne r3,#2AH,c_40  ;checking secs
mov r3,#30H
c_40:
cjne r3,#3AH,c_50   ;checking secs
mov r3,#40H
c_50:
cjne r3,#4AH,c_60  ;checking secs
mov r3,#50H
c_60:
cjne r3,#5AH,CJNE_FOR_R0   ;checking secs
mov r3,#00H


CJNE_FOR_R0:
call c_alarm
call digit_sep
call Converting
call disp

dec r0
cjne r0,#0,not_60min
inc r2
cjne r2,#0AH,c_11   ;checking secs
mov r2,#10H
c_11:
cjne r2,#11H,c_12   ;checking secs
mov r2,#11H
c_12:
cjne r2,#12H,c_13  ;checking secs
mov r2,#12H
mov 1EH,r7
mov r7,1DH
cjne r7,#00,TO_AM
TO_PM:
mov 1DH,#01H
mov r7,1EH
jmp c_13
TO_AM:
mov 1DH,#00H
mov r7,1EH
;call AM_PM
c_13:
cjne r2,#13H,CJNE_FOR_R1   ;checking secs
mov r2,#01H

CJNE_FOR_R1:
call c_alarm
call digit_sep
call Converting
call disp
;call digit_sep
;call delay
;call Converting
;call delay
;call disp
;call delay
dec r1
cjne r1,#0AAH,not_24hrs
;cjne r4,#10,CJNE_FOR_11th   ;checking secs
;mov r4,#00H

;clr EA
;clr p1.0
clr ET1
clr TR1
jmp end_isr1
not_24hrs:
mov r0,#60
not_60min:
mov r5,#60
not_60s:
mov r6,#20
not_equal_0:
mov TL1,#078H
mov TH1,#04BH
setb TR1
end_isr1:
RETI
;isr_2:
;jmp full_speed


;---------------------------------------------------------isr0---------------------------------------------------

;isr_0:

;mov a,r3
;mov b,1FH
;clr psw.7
;clr psw.6
;SUBB a,b
;cjne a,#0,hr_not
;mov a,r2
;mov b,1EH
;clr psw.7
;clr psw.6
;SUBB a,b
;cjne a,#0,min_not
;clr p0.4
;clr ET0
;clr TR0
;jmp end_isr0
;min_not:
;hr_not:
;mov TL0,#078H
;mov TH0,#04BH
;setb TR0
;end_isr0:
;RETI






;--------------------------------------------------------SCANNING----------------------------------------------------------------------
SCANNING:
;KEYPAD:

;--------------------------------------------------------INITIALIAZATION----------------------------------------------------------------------
mov p1,#0    ; port p1 is for rows (output port)
mov p2,#0ffh ; port p2 is for columns (input port)


;;;;; keypad info
rows equ  4
cols equ  3

;;;; creating mask for checking columns

mov a,#0h
mov r1,#0h
rot_again: 
setb c
inc r1
rlc a
cjne r1,#cols,rot_again	
start:
mov r7,a    ; mask is in r0
again:
mov r1,#0feh ; ground 0th row
mov 60H,#0
mov 61H,#0

next_row:
mov p1,r1 
mov a,p2

anl a,r7

cjne a,07h,key_pressed
mov a,r1
rl a
mov r1,a
inc 60H ; r2 will contain the row index
mov a,60H
cjne a,#rows,next_row
jmp again

key_pressed:
call delay	  ; debounce time
again1:
rrc a
jnc findkey
inc 61H			; r3 contains the column index
jmp again1

findkey:
mov a,#cols
mov b,60H
mul ab
add a,61H
mov dptr,#key
movc a,@a+dptr
mov r4,a
cjne r4,#2AH,check_hash
jmp value_of_star
check_hash:
cjne r4,#23H,release_key
jmp value_of_hash

value_of_star:
mov a,#3AH
mov r4,a
jmp release_key

value_of_hash:
mov a,#3BH
mov r4,a
jmp release_key

release_key:
mov a,p2
anl a,r7
cjne a,07h,release_key
call delay	  

RET


delay:

MOV 27H,#46
 lOOOP:
 MOV 28H,#255
 DJNZ 28H,$
 DJNZ 27H, LOOOP

ret

key: db '1','2','3','4','5','6','7','8','9','*','0','#',0 /* 1D index = column index + (row index * total no. of cols)*/
	
	

	
	
	
	

;--------------------------------------------------------DISPLAY----------------------------------------------------------------------
	
Disp:
;Data
;mov P3,#0FFH
mov 54H, #0CH 
call Commwrt
call delay

mov 54H, #01H 
call Commwrt
call delay

;mov 54H,#" "
;call Datawrt
;call delay
;mov 54H,#" "
;call Datawrt
;call delay
;mov 54H,#" "
;call Datawrt
;call delay
;mov 54H,#" "
;call Datawrt
;call delay

mov 54H,30H
mov 50H,30H
call Datawrt
call delay

mov 54H,31H
mov 51H,31H
call Datawrt
call delay

mov 54H,#":"
call Datawrt
call delay

mov 54H,32H
mov 52H,32H
call Datawrt
call delay

mov 54H,33H
mov 53H,33H
call Datawrt
call delay

mov 54H,#":"
call Datawrt
call delay

mov 1EH,r7
mov r7,1DH
cjne r7,#00H,ITS_PM

mov 54H,#"A"
call Datawrt
call delay

mov 54H,#"M"
call Datawrt
call delay

mov r7,1EH
jmp ret_disp
ITS_PM:
mov 54H,#"P"
call Datawrt
call delay

mov 54H,#"M"
call Datawrt
call delay

mov r7,1EH
ret_disp:
ret



first_display:
mov 54H, #0CH 
call Commwrt
call delay
mov 54H, #01H 
call Commwrt
call delay
mov 54H,#"E"
call Datawrt
call delay
mov 54H,#"N"
call Datawrt
call delay
mov 54H,#"T"
call Datawrt
call delay
mov 54H,#"E"
call Datawrt
call delay
mov 54H,#"R"
call Datawrt
call delay
mov 54H,#" "
call Datawrt
call delay
mov 54H,#"I"
call Datawrt
call delay
mov 54H,#"N"
call Datawrt
call delay
mov 54H,#"P"
call Datawrt
call delay
mov 54H,#"U"
call Datawrt
call delay
mov 54H,#"T"
call Datawrt
call delay
ret


;--------------------------------------------------------DIGIT_SEPARATION----------------------------------------------------------------------

digit_sep:
mov a,#0F0H
anl a,r2
swap a
mov 20H,a


mov a,#0FH
anl a,r2
mov 21H,a


mov a,#0F0H
anl a,r3
swap a
mov 22H,a


mov a,#0FH
anl a,r3
mov 23H,a

ret

input_dsep:
mov a,#0FH
anl a,41H
;swap a
mov 41H,a


mov a,#0FH
anl a,42H
mov 42H,a


mov a,#0FH
anl a,43H
;swap a
mov 43H,a


mov a,#0FH
anl a,44H
mov 44H,a

ret










;--------------------------------------------------------CONVERSION----------------------------------------------------------------------

Converting:

mov a,#30H
Add a,20H
mov 30H,a

mov a,#30H
Add a,21H
mov 31H,a

mov a,#30H
Add a,22H
mov 32H,a

mov a,#30H
Add a,23H
mov 33H,a

ret




















;--------------------------------------------------------command_data----------------------------------------------------------------------

Commwrt:
mov P3,54H
call delay
clr  P1.5
call delay
clr P1.6
call delay
setb P1.7
call delay
clr P1.7
call delay
ret
Datawrt:
mov P3,54H
call delay
setb P1.5
call delay
clr P1.6
call delay
setb P1.7
call delay
clr P1.7
call delay
ret
end_code:

end