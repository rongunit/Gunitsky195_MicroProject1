format PE console

include 'win32a.inc'

entry start

;�������: �������� ��� ��������� ���-195
;������� 5
;������� ������:
;����������� ���������, ������������
;����� �����-����������� (� ������������
;�������������) � ��������� �� 1 �� 10^6

section '.data' data readable writable

msg1       db 'Count of 8 palindroms: %d',10,0

arrSize    dd ?         ;������ �������, ��������� 8-� ������������� �����
j          dd ?         ;�������
count      dd ?         ;���������� �����������
eightsArr  rd 7         ;������ �� ������ 8-�� ������������� �����
;���������:
c8         dd 8         ;�������� �� ������ �������� ����� �������� ����������
maxVal     dd 1000000   ;������� ������� �������� �����


section '.code' code readable executable
;======================MAIN=================
start:
        mov  [j], 1             ;�������� � �������� ���������� ��������
        mov  [count], 0         ;�������� �������
mainLoop:
        mov  ecx, [j]           ;�������� �������� �������� � ecx
        cmp  ecx, [maxVal]      ;���������� �������� �������� � maxVal
        jg   endLoop            ;���� j >= maxVal

        ;������� ������ ��������� �� ���� ������������� �������������
        ;����� number
        push [j]                ;���������� � ���� number
        call create8Arr         ;�������� ������� create8Arr
        add  esp, 4             ;������� ���������� ���������

        ;���������� �������� �� ������������ ������������� �����������
        push eightsArr          ;���������� � ���� ������ �� ������
        call isPalindrom        ;�������� ������� isPalindrom
        add  esp, 4             ;������� ���������� ���������

        ;� ������ ���� ��������� - ����������� �������
        add  [count], eax       ;���������� �������� eax
        inc  [j]                ;j++
        jmp  mainLoop           ;������������ � ������ �����

endLoop:
        push [count]            ;���������� ���������� � ����
        push msg1               ;���������� � ���� ������
        call [printf]           ;������� ��������� ������������
        add  esp, 8             ;������� ���������


exit:   ;��������� ������ � ��������� ���������� ���������
        call [getch]
        stdcall [ExitProcess], 0
;============================================


;=======Create8Arr(int number)==========
create8Arr:
;��������� �������
number  equ  ebp+16             ;���������� �����

;��������� ����������
i       equ  ebp-4              ;�������
copyNum equ  ebp-8              ;���������� ��� ����� number
pointer equ  ebp-12             ;������ ��������� �� ������� �������

        ;��������� �������� � �������� ������ � ����� ��� ���. ����������
        push eax
        push edx
        push ebp
        mov  ebp, esp
        sub  esp, 12

        ;�������������� ����������
        mov  [i], dword 0       ;�������� �������
        mov  edx, [number]      ;�������� �������� number
        mov  [copyNum], edx     ;���������� �������� number � copyNum
        mov  edx, eightsArr     ;����������� ecx ������ �� ������ �������
        mov  [pointer], edx     ;���������� ��������� �� ������

createArrLoop:
        ;���������, ��� copyNum �� ����� ����
        cmp  [copyNum], dword 0 ;���������� coppyNum � �����
        je   endCreateArrLoop   ;���� ����� 0, �� ������� �� �����

        ;����� ���� ����� �� ��������� (8)
        mov  eax, [copyNum]     ;���������� � eax copyNum (������� 4 �����)
        mov  edx, 0             ;���������� � edx 0 (������� 4 �����)
        div  [c8]               ;����� �� 8

        ;��������� � ������ copyNum % 8
        mov  [copyNum], eax     ;���������� � copyNum ��������� �������
        mov  eax, [pointer]     ;eax = ref array
        mov  [eax], edx         ;��������� ������� �� ������� �� 8 � array

        ;������� ���������� � ��������� �������� �����
        inc  dword [i]          ;i++
        add  dword [pointer], 4 ;������� � ���������� �������� �������
        jmp  createArrLoop      ;������������ � ������ �����

endCreateArrLoop:
        mov  eax, [i]           ;eax = i
        mov  [arrSize], eax     ;��������� ������ �������
        ;���������� �������� ���������
        mov  esp, ebp
        pop  ebp
        pop  edx
        pop  eax
ret
;============================================

;========IsPalindrom(ref array)==============
isPalindrom:
;��������� �������
refArr  equ  ebp+16             ;������ �� ������ �������

;��������� ����������
sPtr    equ  ebp-4              ;��������� ������ � ������
ePtr    equ  ebp-8              ;��������� ������ � �����
sElem   equ  ebp-12             ;�������� ��������� � ������
eElem   equ  ebp-16             ;�������� ��������� � �����

;��������� �������� � �������� ������ � ����� ��� ���. ����������
        push ecx
        push edx
        push ebp
        mov  ebp, esp
        sub  esp, 16

        ;�������������� ����������
        mov  edx, [refArr]      ;����������� ecx ������ �� ������ �������
        mov  [sPtr], edx        ;���������� ������ �� ������
        mov  edx, [edx]         ;�������� �������� ��������
        mov  [sElem], edx       ;���������� ������ ������� �������
        mov  ecx, [arrSize]     ;�������� ������ �� �����+4 �������
        dec  ecx                ;�������� 1 �� ������� �������
        imul ecx, 4             ;�������� ���������� ����, �� ������� ���� �������
        mov  edx, [sPtr]        ;�������� ������ �� ������ �������
        add  edx, ecx           ;�������� ������ �� ����� �������
        mov  [ePtr], edx        ;���������� ������ �� ����� �������
        mov  edx, [edx]         ;�������� �������� ��������
        mov  [eElem], edx       ;���������� ��������� ������� �������

isPalindromLoop:
        ;��������� ��������� ������ �� ��������
        mov  edx, [sPtr]        ;���������� ������ �� ������� �������
        cmp  edx, [ePtr]        ;���������� ������ � ����� � ������ � ������
        jge  itIsPalindrom      ;���� sPtr >= ePtr �� ��� ���������

        ;��������� ��������� ��������
        mov  edx, [sElem]       ;���������� �������� �������� � ������
        cmp  edx, [eElem]       ;���������� sElem � eElem
        jne  itIsNotPalindrom   ;���� sElem != eElem, �� ��� �� ���������

        add  dword [sPtr], 4    ;������� ��������� �� ��������� �������
        sub  dword [ePtr], 4    ;������� ��������� �� ������� �����
        mov  edx, [sPtr]        ;edx = sPtr
        mov  edx, [edx]         ;�������� �������� ��������
        mov  [sElem], edx       ;���������� �������� �������
        mov  edx, [ePtr]        ;edx = ePtr
        mov  edx, [edx]         ;�������� �������� �������
        mov  [eElem], edx       ;���������� �������� �������
        jmp  isPalindromLoop    ;������������ � ������ �����

itIsPalindrom:
        mov  eax, 1             ;���������� 1
        jmp  endIsPalindrom     ;���� � ����� �������

itIsNotPalindrom:
        mov  eax, 0             ;���������� 0

endIsPalindrom:
        ;���������� �������� ���������
        mov  esp, ebp
        pop  ebp
        pop  edx
        pop  ecx
ret
;============================================

section '.idata' data readable import

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'