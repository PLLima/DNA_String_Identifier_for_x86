
;
; ===========================================================================================================================
; Dados de Identificação
; ===========================================================================================================================
;
; Autor:           Pedro Lubaszewski Lima;
; Cartão UFRGS:    00341810;
; Data de Criação: 2023-08-10.
;
; ===========================================================================================================================
;

	.model		small									; 1 Segmento de Código e 1 Segmento de Dados
	.stack												; Tamanho Indefinido de Pilha

;
; ===========================================================================================================================
; Contantes e Macro Funções
; ===========================================================================================================================
;

_CHAR_NULL			equ				0
_CHAR_CR			equ				0Dh					; Caracteres Especiais
_CHAR_LF			equ				0Ah             

_CHAR_ZERO			equ				30h					; Caracteres Visíveis

_BASE_10			equ				10					; Base Numérica 10

;
; ===========================================================================================================================
; Segmento de Dados
; ===========================================================================================================================
;

	.data



; Variáveis de Funções Auxiliares

sprintf_w_n			dw				0
sprintf_w_f			db				0
sprintf_w_m			dw				0

;
; ===========================================================================================================================
; Segmento de Código
; ===========================================================================================================================
;

    .code

	.startup



	.exit			0									; Retornar programa bem sucedido para o OS

;
; ===========================================================================================================================
; Funções Auxiliares
; ===========================================================================================================================
;
; ===========================================================================================================================
; AX atoi(DS:BX)
; ===========================================================================================================================
;
; Função que converte uma string para um valor hexadecimal:
;
; Entrada: DS:BX - Ponteiro para o início da string de origem;
; Saída:   AX    - Valor hexadecimal/decimal resultante.
;
; ===========================================================================================================================
;

atoi			proc 	near

				mov		ax, 0

atoi_loop:
				cmp		byte ptr[bx], _CHAR_NULL		; Testar se o caractere é nulo '\0'
				jz		atoi_return

				mov		cx, _BASE_10					; Calcular valor posicional do número
				mul		cx
				mov		ch, 0
				mov		cl, [bx]
				add		ax, cx
				sub		ax, _CHAR_ZERO

				inc		bx								; Incrementar a posição no string
				jmp		atoi_loop						; Continuar loop

atoi_return:
				ret										; Encerrar função

atoi			endp

;
; ===========================================================================================================================
; void sprintf_w(DS:BX, AX)
; ===========================================================================================================================
;
; Função que converte um número para uma string:
;
; Entrada: DS:BX - Ponteiro para o início da string de destino;
;          AX    - Valor inteiro para ser convertido.
;
; ===========================================================================================================================
;

sprintf_w		proc	near

				mov		sprintf_w_n, ax					; Inicializar variáveis internas
				mov		cx, 5
				mov		sprintf_w_m, 10000
				mov		sprintf_w_f, 0

sprintf_w_do:
				mov		dx, 0							; Dividir número pela potência de 10 respectiva
				mov		ax, sprintf_w_n
				div		sprintf_w_m
	
				cmp		al, 0							; Se não forem zeros à esquerda, calcular caractere para string
				jne		sprintf_w_store
				cmp		sprintf_w_f, 0
				je		sprintf_w_continue

sprintf_w_store:
				add		al, _CHAR_ZERO
				mov		[bx], al
				inc		bx
	
				mov		sprintf_w_f, 1

sprintf_w_continue:

				mov		sprintf_w_n, dx					; Colocar resto em n para continuar a divisão
	
				mov		dx, 0							; Dividir m por 10 para descobrir próximo caractere
				mov		ax, sprintf_w_m
				mov		bp, _BASE_10
				div		bp
				mov		sprintf_w_m, ax

				dec		cx								; Verificar continuação do loop
				cmp		cx, 0
				jnz		sprintf_w_do

				cmp		sprintf_w_f, 0					; Colocar caracteres zeros quando f for nulo
				jnz		sprintf_w_return
				mov		[bx], _CHAR_ZERO
				inc		bx

sprintf_w_return:
				mov		byte ptr[bx], _CHAR_NULL		; Colocar caractere de fim de string
				ret
		
sprintf_w		endp

;
; ===========================================================================================================================
; void printf_s(DS:BX)
; ===========================================================================================================================
;
; Função que escreve um string na tela (na posição indica pelo cursor):
;
; Entrada: DS:BX - Ponteiro para o início da string.
;
; ===========================================================================================================================
;

printf_s		proc	near

				mov		dl, [bx]						; Testar se o caractere é nulo '\0'
				cmp		dl, _CHAR_NULL
				je		printf_s_return

				push	bx								; Colocar caractere na tela
				mov		ah, 2
				int		21H
				pop		bx

				inc		bx								; Avança pro próximo caractere
				jmp		printf_s
		
printf_s_return:
				ret
	
printf_s		endp

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------