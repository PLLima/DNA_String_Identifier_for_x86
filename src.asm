
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

_CHAR_NULL					equ				0					; Caracteres Especiais
_CHAR_CR					equ				0Dh
_CHAR_LF					equ				0Ah             

_CHAR_PLUS					equ				2Bh					; Caracteres Visíveis
_CHAR_MINUS					equ				2Dh
_CHAR_ZERO					equ				30h
_CHAR_U_A					equ				41h
_CHAR_L_A					equ				61h
_CHAR_U_C					equ				43h
_CHAR_L_C					equ				63h
_CHAR_L_F					equ				66h
_CHAR_U_G					equ				47h
_CHAR_L_G					equ				67h
_CHAR_L_N					equ				6Eh
_CHAR_L_O					equ				6Fh
_CHAR_U_T					equ				54h
_CHAR_L_T					equ				74h

_BASE_10					equ				10					; Base Numérica 10

_SINGLE_BYTE				equ				1					; 1 Byte

; Tabela de Códigos de Erro

_ERROR_NONE					equ				0					; Nenhum erro
_ERROR_FILENAME				equ				1					; Nome do arquivo de entrada incorreto/inexistente
_ERROR_SMALL_FILESIZE		equ				2					; Caracteres no arquivo menor que o valor de 'n'
_ERROR_BIG_FILESIZE			equ				3					; Mais que 10.000 caracteres no arquivo
_ERROR_INSUFICIENT_PSP		equ				4					; String de entrada incompleta (faltando opções)
_ERROR_INVALID_PSP			equ				5					; String de entrada inválida (opções '-xXx' incorretas)
_ERROR_INVALID_PSP_PARAM	equ				6					; String de entrada inválida (parâmetros de opções incorretos)
_ERROR_INVALID_CHAR			equ				7					; Caractere inválido no arquivo de entrada

;
; ===========================================================================================================================
; Segmento de Dados
; ===========================================================================================================================
;

	.data

psp_string					db				256 dup (?)			; String fornecida ao chamar o programa (do PSP)
psp_string_cursor			dw				?					; Ponteiro para navegar a string PSP
filename_src				db				256 dup (?)			; Nomes dos arquivos de entrada e saída
filename_dst				db				256 dup (?)
filehandle_src				dw				0					; Handles dos arquivo de entrada e saída
filehandle_dst				dw				0

; Variáveis de Funções Auxiliares

sprintf_w_n					dw				0
sprintf_w_f					db				0
sprintf_w_m					dw				0

error_code					db				_ERROR_NONE			; Variáveis do tratador de erros

;
; ===========================================================================================================================
; Segmento de Código
; ===========================================================================================================================
;

    .code

	.startup
				mov		error_code, _ERROR_NONE			; Inicializar variáveis do programa
				lea		psp_string_cursor, psp_string

				lea		bx, psp_string					; Copiar string de entrada do programa
				call	copy_psp_s

				call	fix_segments					; Unificar segmentos de dados

main_return:
				call	error_handler

	.exit		_ERROR_NONE								; Retornar programa bem sucedido para o OS

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
; CF, AX fread(BX, DS:DX, CX)
; ===========================================================================================================================
;
; Função que lê um byte de um arquivo especificado:
;
; Entrada: BX    - Handle do arquivo;
;          DS:DX - Endereço onde salvar byte a ser lido;
;          CX    - Número de bytes para serem lidos;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          AX    - Número de bytes lidos;
;
; ===========================================================================================================================
;

fread			proc	near

				mov		ah, 3Fh							; Chamar a respectiva interrupção de sistema
				int		21h
				ret

fread			endp

;
; ===========================================================================================================================
; CF, AX fwrite(BX, DS:DX, CX)
; ===========================================================================================================================
;
; Função que escreve um byte de um arquivo especificado:
;
; Entrada: BX    - Handle do arquivo;
;          DS:DX - Endereço do byte a ser escrito;
;          CX    - Número de bytes para serem lidos;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          AX    - Número de bytes escritos;
;
; ===========================================================================================================================
;

fwrite			proc	near

				mov		ah, 40h							; Chamar a respectiva interrupção de sistema
				int		21h
				ret

fwrite			endp

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

				pop 	es 								; Retornar as informações dos segmentos
				pop 	ds

				inc		di								; Colocar indicador de final de string '\0'
				mov		byte [di], _CHAR_NULL
				ret

copy_psp_s		endp

;
; ===========================================================================================================================
; Funções da Aplicação
; ===========================================================================================================================
;
; ===========================================================================================================================
; void fix_segments(void)
; ===========================================================================================================================
;
; Função que aponta o segmento extra para o segmento de dados.
;
; ===========================================================================================================================
;

fix_segments	proc	near

				mov 	ax, ds 							; Colocar ES <- DS para utilizar o modelo small do MASM
				mov 	es, ax

				ret

fix_segments	endp


;
; ===========================================================================================================================
; void error_handler(error_code, ...)
; ===========================================================================================================================
;
; Função que lida com todos os erros tratáveis do programa:
;
; Entrada: error_code - Variável global com a informação do respectivo erro;
;          ...        - Outras variáveis globais necessárias para tratar cada cada erro.
;
; ===========================================================================================================================
;

error_handler	proc	near

				cmp		error_code, _ERROR_NONE			; Se não houve erro, ignorar função
				je		error_handler_return

				cmp		error_code, _ERROR_FILENAME
				jne		not_filename_error

														; Tratar erro de nome de arquivo
				jmp		error_handler_return

not_filename_error:
				cmp		error_code, _ERROR_SMALL_FILESIZE
				jne		not_small_filesize_error

														; Tratar erro de arquivo muito pequeno
				jmp		error_handler_return

not_small_filesize_error:
				cmp		error_code, _ERROR_BIG_FILESIZE
				jne		not_big_filesize_error

														; Tratar erro de arquivo muito grande
				jmp		error_handler_return

not_big_filesize_error:
				cmp		error_code, _ERROR_INSUFICIENT_PSP
				jne		not_insuficient_psp_error

														; Tratar erro de string de entrada insuficiente
				jmp		error_handler_return

not_insuficient_psp_error:
				cmp		error_code, _ERROR_INVALID_PSP
				jne		not_invalid_psp_error

														; Tratar erro de opções de entrada inválidas
				jmp		error_handler_return

not_invalid_psp_error:
				cmp		error_code, _ERROR_INVALID_PSP_PARAM
				jne		not_invalid_psp_param_error

														; Tratar erro de parâmetros de opções de entrada inválidos
				jmp		error_handler_return

not_invalid_psp_param_error:
				cmp		error_code, _ERROR_INVALID_CHAR
				jne		error_handler_return

														; Tratar erro de parâmetros de caractere inválido no arquivo

error_handler_return:
				ret

error_handler	endp

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------