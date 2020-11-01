format PE console

include 'win32a.inc'

entry start

;Студент: Гуницкий Рон Яковлевич БПИ-195
;Вариант 5
;Условие задачи:
;Разработать программу, определяющую
;число чисел-палиндромов (в восьмеричном
;представлении) в диапазоне от 1 до 10^6

section '.data' data readable writable

msg1       db 'Count of 8 palindroms: %d',10,0

arrSize    dd ?         ;размер массива, хронящего 8-е представление чисел
j          dd ?         ;счетчик
count      dd ?         ;количество палиндромов
eightsArr  rd 7         ;ссылка на массив 8-го представления числа
;Константы:
c8         dd 8         ;значение по модулю которого будут искаться палиндромы
maxVal     dd 1000000   ;верхняя граница проверки чисел


section '.code' code readable executable
;======================MAIN=================
start:
        mov  [j], 1             ;значение с которого начинается проверка
        mov  [count], 0         ;обнуляем счетчик
mainLoop:
        mov  ecx, [j]           ;копируем значение счетчика в ecx
        cmp  ecx, [maxVal]      ;сравниваем значение счетчика с maxVal
        jg   endLoop            ;если j >= maxVal

        ;создаем массив состоящий из цифр восьмеричного представления
        ;числа number
        push [j]                ;записываем в стек number
        call create8Arr         ;вызываем функцию create8Arr
        add  esp, 4             ;удаляем переданные аргументы

        ;определяем является ли восьмеричное представление палиндромом
        push eightsArr          ;записываем в стек ссылку на массив
        call isPalindrom        ;вызываем функцию isPalindrom
        add  esp, 4             ;удаляем переданные аргументы

        ;в случае если палиндром - увеличиваем счетчик
        add  [count], eax       ;прибавляем значение eax
        inc  [j]                ;j++
        jmp  mainLoop           ;возвращаемся в начало цикла

endLoop:
        push [count]            ;записываем количество в стек
        push msg1               ;записываем в стек шаблон
        call [printf]           ;выводим сообщение пользователю
        add  esp, 8             ;удаляем аргументы


exit:   ;считываем символ и завершаем выполнение программы
        call [getch]
        stdcall [ExitProcess], 0
;============================================


;=======Create8Arr(int number)==========
create8Arr:
;Аргументы функции
number  equ  ebp+16             ;переданное число

;Локальные переменные
i       equ  ebp-4              ;счетчик
copyNum equ  ebp-8              ;переменная для копии number
pointer equ  ebp-12             ;хранит указатель на элемент массива

        ;сохраняем регистры и выделяем память в стеке под лок. переменные
        push eax
        push edx
        push ebp
        mov  ebp, esp
        sub  esp, 12

        ;инициализируем переменные
        mov  [i], dword 0       ;обнуляем счетчик
        mov  edx, [number]      ;копируем значение number
        mov  [copyNum], edx     ;записываем значение number в copyNum
        mov  edx, eightsArr     ;присваиваем ecx ссылку на начало массива
        mov  [pointer], edx     ;записываем указатель на массив

createArrLoop:
        ;проверяем, что copyNum не равен нулю
        cmp  [copyNum], dword 0 ;сравниваем coppyNum с нулем
        je   endCreateArrLoop   ;если равно 0, то выходим из цикла

        ;делим наше число на константу (8)
        mov  eax, [copyNum]     ;записываем в eax copyNum (младшие 4 байта)
        mov  edx, 0             ;записываем в edx 0 (старшие 4 байта)
        div  [c8]               ;делим на 8

        ;добавляем в массив copyNum % 8
        mov  [copyNum], eax     ;записываем в copyNum результат деления
        mov  eax, [pointer]     ;eax = ref array
        mov  [eax], edx         ;добавляем остаток от деления на 8 в array

        ;готовим переменные к следующей итерации цикла
        inc  dword [i]          ;i++
        add  dword [pointer], 4 ;переход к следующему элементу массива
        jmp  createArrLoop      ;возвращаемся в начало цикла

endCreateArrLoop:
        mov  eax, [i]           ;eax = i
        mov  [arrSize], eax     ;сохраняем размер массива
        ;возвращаем значения регистров
        mov  esp, ebp
        pop  ebp
        pop  edx
        pop  eax
ret
;============================================

;========IsPalindrom(ref array)==============
isPalindrom:
;Аргументы функции
refArr  equ  ebp+16             ;ссылка на начало массива

;Локальные переменные
sPtr    equ  ebp-4              ;указатель идущий с начала
ePtr    equ  ebp-8              ;указатель идущий с конца
sElem   equ  ebp-12             ;значение элементов с начала
eElem   equ  ebp-16             ;значение элементов с конца

;сохраняем регистры и выделяем память в стеке под лок. переменные
        push ecx
        push edx
        push ebp
        mov  ebp, esp
        sub  esp, 16

        ;инициализируем переменные
        mov  edx, [refArr]      ;присваиваем ecx ссылку на начало массива
        mov  [sPtr], edx        ;записываем ссылку на массив
        mov  edx, [edx]         ;получаем значение элемента
        mov  [sElem], edx       ;записываем первый элемент массива
        mov  ecx, [arrSize]     ;получаем ссылку на конец+4 массива
        dec  ecx                ;вычетаем 1 из размера массива
        imul ecx, 4             ;получаем количество байт, на которое надо перейти
        mov  edx, [sPtr]        ;копируем ссылку на первый элемент
        add  edx, ecx           ;получаем ссылку на конец массива
        mov  [ePtr], edx        ;записываем ссылку на конец массива
        mov  edx, [edx]         ;получаем значение элемента
        mov  [eElem], edx       ;записываем последний элемент массива

isPalindromLoop:
        ;проверяем отношения ссылок на элементы
        mov  edx, [sPtr]        ;записываем ссылку на элемент массива
        cmp  edx, [ePtr]        ;сравниваем ссылку с конца и ссылку с начала
        jge  itIsPalindrom      ;если sPtr >= ePtr то это палиндром

        ;проверяем равенство символов
        mov  edx, [sElem]       ;записываем значение элемента с начала
        cmp  edx, [eElem]       ;сравниваем sElem с eElem
        jne  itIsNotPalindrom   ;если sElem != eElem, то это не палиндром

        add  dword [sPtr], 4    ;смещаем указатель на следующий элемент
        sub  dword [ePtr], 4    ;смещаем указатель на элемент назад
        mov  edx, [sPtr]        ;edx = sPtr
        mov  edx, [edx]         ;получаем значение элемента
        mov  [sElem], edx       ;записываем значение массива
        mov  edx, [ePtr]        ;edx = ePtr
        mov  edx, [edx]         ;получаем значение массива
        mov  [eElem], edx       ;записываем значение массива
        jmp  isPalindromLoop    ;возвращаемся в начало цикла

itIsPalindrom:
        mov  eax, 1             ;возвращаем 1
        jmp  endIsPalindrom     ;идем в конец функции

itIsNotPalindrom:
        mov  eax, 0             ;возвращаем 0

endIsPalindrom:
        ;возвращаем значения регистров
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