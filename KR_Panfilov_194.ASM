; Program written by: Egor Panfilov, 194
; Variant: 17
; Task: Find one of the roots from the fifth root. Use fast converging iterative algorithm. Use FPU.

format PE console

entry START

include 'win32a.inc'

section '.data' data readable writable

        answerOutput db 'Answer:  ', 0     ; ������ ��� ������ ������
        strInputA db 'Input A: ', 0        ; ������ ��� �����
        newLine db '', 10, 13, 0           ; ������ �������� �� ����� ������
        procLF db '%lf', 0                 ; ������ ��� ������/����� ������������� ����� � ��������� ������

        A dq ?                             ; ����� ��� ����� � �������� �����, �� �������� ����� ����� ������
        xn dq ?                            ; ����� ��� �������������� �������� � ����������
        support dq ?                       ; ����� ��� ������ � ������ �������

        i dd 1                             ; �����, ��� ������ �����
        four dq 4.0                        ; ������������ 4
        five dq 5.0                        ; ������������ 5
        floatNull dq 0.0                   ; ������������ 0
        null = 0                           ; �����, ����������� 0 ��� ���������� ���������
        numberOfRepeat = 200               ; ���-�� ��������

section '.code' code readable executable

        START:
                cinvoke printf, strInputA  ; ���� �
                cinvoke scanf, procLF, A   ; ------

                fld qword [A]              ; ��������� � � ������� ����� FPU

                fcom [floatNull]           ; ------
                fstsw ax                   ; ���������, �������� �� ����� 0. ���� ��, �� ���������
                sahf                       ; � ����� ���������
                je finish                  ; ------

                fstp qword [xn]            ; ��������� A � "x0"


        loop1:                             ; ���������/���������� ����

                mov eax, [i]               ; ------
                cmp eax, numberOfRepeat    ; ���������, ��������� �� �� ����. ���� ���������, ��������� � �����
                je finish                  ; ------

                fld qword [A]              ; ------
                fdiv [xn]                  ;         1                       A        �������� �������� �� ���� �������.
                fdiv [xn]                  ; Xk+1 = --- * ( (n - 1)*Xk + ----------)  ��� ��� � ��� n = 5, �� ��������� �:
                fdiv [xn]                  ;         n                   (Xk)^(n-1)
                fdiv [xn]                  ;
                fstp qword [support]       ;
                                           ;                      A
                fld qword [xn]             ; Xk+1 = ( 4 * Xk + ------ ) / 5  C ������ ������� ����� �� �������� � ��������� � � �������� ���������.
                fmul [four]                ;                    Xk^4         ����� ���� ������� ������ ����� ������, ���������� ����� ��������� � ����� ��
                fadd [support]             ;                                 5, � �������� ������ ��� �������.  ������� ������������ � �����������
                fdiv [five]                ; ����� ��� ������� � ������� ��������. ��� �������� ��������� ����� ������� FPU, �������� ����� � �������� ��������.
                fstp qword [xn]            ; ------

                mov eax, [i]               ; ------
                add eax, 1                 ; ������������� i �� 1 � ��������� ����
                mov [i], eax               ;
                jmp loop1                  ; ------

        finish:
                cinvoke printf, answerOutput                     ; ------
                invoke printf, procLF, dword[xn], dword[xn + 4]  ; ������� �����. ���� ��� ����� 0, �� ������� 0
                cinvoke printf, newLine                          ; ------

                call [getch]               ; ------
                push null                  ; ��������� �������
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