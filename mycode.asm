.model small
.stack 100h
.data                 
Buffer dw 0h
Numbers dw 30 dup (?)          
MedianStr db 10, 13, 'Median: $'
NumberStr db 10, 13, 'Enter a number:', 10, 13, '$'     
NewLine db 10,13, '$'

.code   
output_message macro message   ;;Output message 
        mov ah,9
        lea dx, message
        int 21h
endm 

start:
    mov ax, @data
    mov ds, ax
    mov es, ax
    mov ah, 0h; screen cleaning
    mov al, 2h     
    int 10h          
    lea di, Numbers  
    mov cx, 30  ;quantity of numbers
    cld    ;for movs
ArrayInput:        
    output_message numberStr
    call NumberInput  
    mov Buffer, ax
    lea si, Buffer
    movsw          
    loop ArrayInput    
    output_message medianStr
    mov bx, 0h   ;min
Sort:;selection
    cmp bx, 58
    je MedianOutput
    mov si, bx   ;cur
    jmp minFind
change:
    mov numbers[si], ax
    mov numbers[bx], dx 
    jmp findContinue
MinFind:
    add si, 2h
    mov ax, numbers[bx]
    mov dx, numbers[si]
    cmp ax, dx
    jg change
findContinue:
    cmp si, 58 
    jne MinFind  
    add bx, 2h 
    jmp sort       
MedianOutput:    
    mov ax, Numbers[30] 
    call NumberOutput
    mov ah, 4ch
    int 21h
    
NumberInput proc 
    push cx
    xor dx, dx  
    mov ah, 01h  ;char input  
    mov bx, 0h
Input:    
    int 21h 
    cmp al, '-'
    mov cx, 5
    je Negative
    cmp al, '+'
    je Positive
    cmp al, '0'
    jl Input
    cmp al, '9'
    jg Input
    sub al, '0'
    mov dl, al    ;
    mov cx, 4      
Positive:     
    mov ah, 01h
    int 21h
    cmp al, 13
    je Return
    cmp al, '0'
    jl Positive
    cmp al, '9'
    jg Positive         
    sub al, '0'
    mov bl, al ;char saving
    mov ax, dx ;number saving
    mov dl, 10d
    mul dl
    add ax, bx    
    mov dx, ax
    loop Positive   
    jmp Return   
ErrorCheck:
    cmp dx, 0
    je Negative
    neg dx 
    jmp Return
Negative: 
    mov ah, 01h
    int 21h
    cmp al, 13
    je ErrorCheck
    cmp al, '0'
    jl Negative
    cmp al, '9'
    jg Negative
    sub al, '0'
    mov bl, al ;char saving
    mov ax, dx ;number saving
    mov dl, 10d
    mul dl
    add ax, bx    
    mov dx, ax ;
    loop Negative
Return:    
    mov ax, dx
    jo correct
    jmp endInput
correct:
    mov ax, 32767d
endInput:  
    pop cx
    ret 
NumberInput endp  

NumberOutput proc
    test ax, ax
    jns mod   ;if>0
    push ax
    mov ah, 02h
    mov dl, '-' ;minus output
    int 21h
    pop ax  
    neg ax
mod:
    mov bx, 10
    xor cx, cx
rem: 
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz rem
    mov ah, 6h
digit:
    pop dx
    add dl, '0'
    int 21h
    loop digit
    ret
NumberOutput endp       