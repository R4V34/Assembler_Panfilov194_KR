; Program written by: Egor Panfilov, 194
; Variant: 17
; Task: Find one of the roots from the fifth root. Use fast converging iterative algorithm. Use FPU.

format PE console

entry START

include 'win32a.inc'

section '.data' data readable writable

        answerOutput db 'Answer:  ', 0     ; Строка для вывода ответа
        strInputA db 'Input A: ', 0        ; Строка для ввода
        newLine db '', 10, 13, 0           ; Строка перехода на новую строку
        procLF db '%lf', 0                 ; Строка для вывода/ввода вещественного числа с плавающей точкой

        A dq ?                             ; Число для ввода и хранения числа, от которого будем брать корень
        xn dq ?                            ; Число для промежуточного значения и результата
        support dq ?                       ; Число для помощи в работе формулы

        i dd 1                             ; Число, для работы цикла
        four dq 4.0                        ; Вещественная 4
        five dq 5.0                        ; Вещественная 5
        floatNull dq 0.0                   ; Вещественный 0
        null = 0                           ; Целый, константный 0 для завершения программы
        numberOfRepeat = 200               ; Кол-во повторов

section '.code' code readable executable

        START:
                cinvoke printf, strInputA  ; Ввод А
                cinvoke scanf, procLF, A   ; ------

                fld qword [A]              ; Переводим А в вершину стека FPU

                fcom [floatNull]           ; ------
                fstsw ax                   ; Проверяем, является ли число 0. Если да, то переходим
                sahf                       ; в конец программы
                je finish                  ; ------

                fstp qword [xn]            ; Переносим A в "x0"


        loop1:                             ; Запускаем/продолжаем цикл

                mov eax, [i]               ; ------
                cmp eax, numberOfRepeat    ; Проверяем, закончили ли мы цикл. Если закончили, переходим в конец
                je finish                  ; ------

                fld qword [A]              ; ------
                fdiv [xn]                  ;         1                       A        Алгоритм работает на этой формуле.
                fdiv [xn]                  ; Xk+1 = --- * ( (n - 1)*Xk + ----------)  так как у нас n = 5, то подаствим её:
                fdiv [xn]                  ;         n                   (Xk)^(n-1)
                fdiv [xn]                  ;
                fstp qword [support]       ;
                                           ;                      A
                fld qword [xn]             ; Xk+1 = ( 4 * Xk + ------ ) / 5  C начала считаем дробь со степенью и сохраняем её в операнде помощнике.
                fmul [four]                ;                    Xk^4         После чего считаем вторую часть скобки, прибовляем ранее найденное и делим на
                fadd [support]             ;                                 5, и получаем нужный нам элемент.  Алгорим заколючается в приближении
                fdiv [five]                ; через эту формулу к нужному значению. Все действия выполняем через команды FPU, верхушку стека и введённые операнды.
                fstp qword [xn]            ; ------

                mov eax, [i]               ; ------
                add eax, 1                 ; Увеливичиваем i на 1 и повторяем цикл
                mov [i], eax               ;
                jmp loop1                  ; ------

        finish:
                cinvoke printf, answerOutput                     ; ------
                invoke printf, procLF, dword[xn], dword[xn + 4]  ; Выводим ответ. Если был введён 0, то выводим 0
                cinvoke printf, newLine                          ; ------

                call [getch]               ; ------
                push null                  ; Завершаем процесс
                call [ExitProcess]         ; ------

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'