
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

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------