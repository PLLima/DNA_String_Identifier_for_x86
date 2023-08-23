
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

_CHAR_NULL			equ				0					; Caracteres Especiais
_CHAR_CR			equ				0Dh
_CHAR_LF			equ				0Ah             

_CHAR_+				equ				2Bh					; Caracteres Visíveis
_CHAR_-				equ				2Dh
_CHAR_ZERO			equ				30h
_CHAR_A				equ				41h
_CHAR_a				equ				61h
_CHAR_C				equ				43h
_CHAR_c				equ				63h
_CHAR_f				equ				66h
_CHAR_G				equ				47h
_CHAR_g				equ				67h
_CHAR_n				equ				6Eh
_CHAR_o				equ				6Fh
_CHAR_T				equ				54h
_CHAR_t				equ				74h

_BASE_10			equ				10					; Base Numérica 10

_SINGLE_BYTE		equ				1					; 1 Byte

;
; ===========================================================================================================================
; Segmento de Dados
; ===========================================================================================================================
;

	.data

psp_string			db				256 dup (?)			; String fornecida ao chamar o programa (do PSP)
filename_src		db				256 dup (?)			; Nomes dos arquivos de entrada e saída
filename_dst		db				256 dup (?)
filehandle_src		dw				0					; Handles dos arquivo de entrada e saída
filehandle_dst		dw				0

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

				lea		bx, psp_string					; Copiar string de entrada do programa
				call	copy_psp_s

	.exit		0										; Retornar programa bem sucedido para o OS

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

;
; ===========================================================================================================================
; CF, BX fopen(DS:DX)
; ===========================================================================================================================
;
; Função que abre um arquivo com o nome especificado:
;
; Entrada: DS:DX - Ponteiro para o nome do arquivo de entrada;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          BX    - Handle do arquivo.
;
; ===========================================================================================================================
;

fopen			proc	near

				mov		al, 0							; Chamar a respectiva interrupção de sistema
				mov		ah, 3Dh
				int		21h
				mov		bx, ax
				ret

fopen			endp

;
; ===========================================================================================================================
; CF, BX fcreate(DS:DX)
; ===========================================================================================================================
;
; Função que cria um arquivo com o nome especificado:
;
; Entrada: DS:DX - Ponteiro para o nome do arquivo de entrada;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          BX    - Handle do arquivo.
;
; ===========================================================================================================================
;

fcreate			proc	near

				mov		cx, 0							; Chamar a respectiva interrupção de sistema
				mov		ah, 3Ch
				int		21h
				mov		bx, ax
				ret

fcreate			endp

;
; ===========================================================================================================================
; CF, AX fread_b(BX, DX)
; ===========================================================================================================================
;
; Função que lê um byte de um arquivo especificado:
;
; Entrada: BX - Handle do arquivo;
;          DX - Endereço onde salvar byte a ser lido;
; Saída:   CF - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          AX - Número de bytes lidos;
;
; ===========================================================================================================================
;

fread_b			proc	near

				mov		ah, 3Fh							; Chamar a respectiva interrupção de sistema
				mov		cx, _SINGLE_BYTE
				int		21h
				ret

fread_b			endp

;
; ===========================================================================================================================
; CF, AX fwrite_b(BX, DS:DX)
; ===========================================================================================================================
;
; Função que escreve um byte de um arquivo especificado:
;
; Entrada: BX    - Handle do arquivo;
;          DS:DX - Endereço do byte a ser escrito;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          AX    - Número de bytes escritos;
;
; ===========================================================================================================================
;

fwrite_b		proc	near

				mov		ah, 40h							; Chamar a respectiva interrupção de sistema
				mov		cx, _SINGLE_BYTE
				int		21h
				ret

fwrite_b		endp

;
; ===========================================================================================================================
; CF fclose(BX)
; ===========================================================================================================================
;
; Função que fecha um arquivo com o nome especificado:
;
; Entrada: BX - Handle do arquivo;
; Saída:   CF - Flag indicando se a operação foi bem sucedida (0) ou não (1).
;
; ===========================================================================================================================
;

fclose			proc	near

				mov		ah, 3Eh							; Chamar a respectiva interrupção de sistema
				int		21h
				ret

fclose			endp

;
; ===========================================================================================================================
; void copy_psp_s(DS:BX)
; ===========================================================================================================================
;
; Função que copia a string de entrada fornecida ao chamar o programa (do Program Segment Prefix):
;
; Entrada: DS:BX - Ponteiro para o início da região de memória para onde será copiada a string.
;
; ===========================================================================================================================
;

copy_psp_s		proc	near

				push 	ds 								; Salvar segmentos na pilha
				push 	es

				mov 	ax, ds 							; Trocar DS <-> ES para poder usar o MOVSB
				mov 	cx, es
				mov 	ds, cx
				mov 	es, ax
				mov 	si, 80h 						; Obter o tamanho do string e colocar em CX
				mov 	ch, 0
				mov 	cl, [si]
				mov 	si, 81h 						; Inicializar ponteiros de origem e destino
				mov 	di, bx
				rep movsb

				inc		bx								; Colocar indicador de final de string '\0'
				mov		[bx], byte _CHAR_NULL

				pop 	es 								; Retornar as informações dos segmentos
				pop 	ds
				ret

copy_psp_s		endp

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------