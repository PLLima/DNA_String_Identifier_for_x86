
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

_ENABLED					equ				1					; Habilitado/Desabilitado
_DISABLED					equ				0

_INVALID_NUMBER				equ				0FFFFh				; Número Inválido

_CHAR_NULL					equ				0					; Caracteres Especiais
_CHAR_CR					equ				0Dh
_CHAR_LF					equ				0Ah             

_CHAR_SPACE					equ				20h					; Caracteres Visíveis
_CHAR_PLUS					equ				2Bh
_CHAR_MINUS					equ				2Dh
_CHAR_ZERO					equ				30h
_CHAR_NINE					equ				39h
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

_MIN_DNA_GROUP_SIZE			equ				1					; Tamanhos mínimo e máximo de grupos de DNA
_MAX_DNA_GROUP_SIZE			equ				10000

; Tabela de Códigos de Erro

_ERROR_NONE					equ				0					; Nenhum erro
_ERROR_FILENAME				equ				1					; Nome do arquivo de entrada incorreto/inexistente
_ERROR_SMALL_FILESIZE		equ				2					; Caracteres no arquivo menor que o valor de 'n'
_ERROR_BIG_FILESIZE			equ				3					; Mais que 10.000 caracteres no arquivo
_ERROR_INSUFICIENT_PSP		equ				4					; String de entrada incompleta (faltando opções)
_ERROR_INVALID_PSP			equ				5					; String de entrada inválida (opções '-xXx' incorretas)
_ERROR_DUPLICATE_PSP		equ				6					; String de entrada com opção duplicada
_ERROR_INVALID_PSP_PARAM	equ				7					; String de entrada inválida (parâmetros de opções incorretos)
_ERROR_INVALID_CHAR			equ				8					; Caractere inválido no arquivo de entrada
_ERROR_UNKNOWN				equ				9					; Erro desconhecido

;
; ===========================================================================================================================
; Segmento de Dados
; ===========================================================================================================================
;

	.data

psp_string					db				256 dup (?)			; String fornecida ao chamar o programa (do PSP)
psp_string_size				db				?					; Tamanho do string de entrada
psp_string_segments			db				?					; Contador de segmentos da string de entrada
psp_string_segment_cursor	dw				?					; Ponteiro para início de segmentos da string PSP

option_a					db				?					; Flags de opções de entrada
option_c					db				?				
option_f					db				?
option_g					db				?
option_n					db				?
option_plus					db				?
option_t					db				?

filename_src				db				256 dup (?)			; Nomes dos arquivos de entrada e saída
filename_dst				db				256 dup (?)
filehandle_src				dw				0					; Handles dos arquivo de entrada e saída
filehandle_dst				dw				0

dna_group_size				dw				0					; Tamanho de cada grupo de bases de DNA
dna_group_size_string		db				256 dup (?)			; String com o tamanho de cada grupo de bases

; Strings Constantes
null_msg					db				_CHAR_NULL
newline						db				_CHAR_CR, _CHAR_LF, _CHAR_NULL
filename_dst_std			db				'a.out', _CHAR_NULL	; String de saída padrão

; Variáveis de Funções Auxiliares
sprintf_w_n					dw				0
sprintf_w_f					db				0
sprintf_w_m					dw				0

; Variáveis do Tratador de Erros
error_code					db				_ERROR_NONE			; Código de erro
error_string1				db				256 dup (?)			; Strings com informações do respectivo erro
error_string2				db				256 dup (?)

; Mensagens de Erro Constantes
error_invalid_msg_o			db				'" invalido.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_invalid_msg_a			db				'" invalida.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_inexistent_msg		db				'" inexistente.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_duplicate_msg			db				'" duplicada.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_option_f_msg			db				' -f', _CHAR_NULL
error_option_n_msg			db				' -n', _CHAR_NULL
error_option_atcg_msg		db				' -atcg+', _CHAR_NULL
error_filename_msg			db				_CHAR_CR, _CHAR_LF, 'Erro 01: nome de arquivo "', _CHAR_NULL
error_small_filesize_msg1	db				_CHAR_CR, _CHAR_LF, 'Erro 02: arquivo muito pequeno. Necessario minimo de ', _CHAR_NULL
error_small_filesize_msg2	db				' caracteres no arquivo.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_big_filesize_msg		db				_CHAR_CR, _CHAR_LF, 'Erro 03: arquivo muito grande. Numero maximo de caracteres aceitos eh 10.000.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_insuficient_psp_msg1	db				_CHAR_CR, _CHAR_LF, 'Erro 04: opcoes de entrada insuficientes. Faltam as opcoes "', _CHAR_NULL
error_insuficient_psp_msg2	db				' ".', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_invalid_psp_msg		db				_CHAR_CR, _CHAR_LF, 'Erro 05: opcao de entrada "', _CHAR_NULL
error_duplicate_psp_msg		db				_CHAR_CR, _CHAR_LF, 'Erro 06: opcao de entrada "', _CHAR_NULL				
error_invalid_psp_param_msg1 db				_CHAR_CR, _CHAR_LF, 'Erro 07: parametro "', _CHAR_NULL
error_invalid_psp_param_msg2 db				'" da opcao "', _CHAR_NULL
error_invalid_psp_param_msgv db				_CHAR_CR, _CHAR_LF, 'Erro 07: parametro da opcao "', _CHAR_NULL
error_invalid_char_msg1		db				_CHAR_CR, _CHAR_LF, 'Erro 08: caractere "', _CHAR_NULL
error_invalid_char_msg2		db				'" do arquivo na linha "', _CHAR_NULL
error_unknown_msg			db				_CHAR_CR, _CHAR_LF, 'Erro desconhecido.', _CHAR_CR, _CHAR_LF, _CHAR_NULL

;
; ===========================================================================================================================
; Segmento de Código
; ===========================================================================================================================
;

    .code

	.startup
				mov		error_code, _ERROR_NONE			; Inicializar variáveis do programa
				mov		option_a, _DISABLED
				mov		option_c, _DISABLED
				mov		option_f, _DISABLED
				mov		option_g, _DISABLED
				mov		option_n, _DISABLED
				mov		option_plus, _DISABLED
				mov		option_t, _DISABLED
				mov		psp_string_segment_cursor, offset psp_string
				mov		psp_string_segments, 0
				mov		dna_group_size, 0

				lea		bx, psp_string					; Copiar string de entrada do programa
				call	copy_psp_s

				call	fix_segments					; Unificar segmentos de dados

				lea		si, filename_dst_std			; Inicializar arquivo de saída como 'a.out'
				lea		di, filename_dst
				call	strcpy

				lea		bx, psp_string					; Contar substrings e separá-las por '\0'
				mov		ch, 0
				mov		cl, psp_string_size
				call	convert_spaces_to_null
				mov		psp_string_segments, dl

input_loop:
				dec		psp_string_segments

				inc		psp_string_segment_cursor		; Inicializar busca em um segmento
				mov		bp, psp_string_segment_cursor

				cmp		[bp], byte ptr _CHAR_MINUS		; Verificar se o caractere comparado é um hífen
				jne		unknown_string

				inc		bp								; Se for um hífen, verificar próximos caracteres

				cmp		[bp], byte ptr _CHAR_L_F		; Se for uma opção 'f'
				jne		not_option_f

				inc		bp
				cmp		[bp], byte ptr _CHAR_NULL		; Descobrir se é uma opção válida
				je		valid_option_f

				mov		error_code, _ERROR_INVALID_PSP	; Atribuir respectivo código de erro

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_option_f:
				cmp		psp_string_segments, 0			; Avaliar se há parâmetro a ser processado
				jne		valid_param_f

				mov		error_code, _ERROR_INVALID_PSP_PARAM

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				mov		si, psp_string_segment_cursor
				call	strcpy

				lea		di, error_string2
				lea		si, null_msg
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_param_f:
				mov		option_f, _ENABLED				; Habilitar opção 'f'

				inc		bp
				mov		si, bp							; Copiar string com o nome de arquivo
				lea		di, filename_src
				call	strcpy
				mov		psp_string_segment_cursor, si	; Atualizar apontador de segmentos

				dec		psp_string_segments				; Descontar um segmento no contador

				jmp		segment_increment

not_option_f:
				cmp		[bp], byte ptr _CHAR_L_O		; Se for uma opção 'o'
				jne		not_option_o

				inc		bp
				cmp		[bp], byte ptr _CHAR_NULL		; Descobrir se é uma opção válida
				je		valid_option_o

				mov		error_code, _ERROR_INVALID_PSP	; Atribuir respectivo código de erro

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_option_o:
				cmp		psp_string_segments, 0			; Avaliar se há parâmetro a ser processado
				jne		valid_param_o

				mov		error_code, _ERROR_INVALID_PSP_PARAM

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				mov		si, psp_string_segment_cursor
				call	strcpy

				lea		di, error_string2
				lea		si, null_msg
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_param_o:
				inc		bp
				mov		si, bp							; Copiar string com o nome de arquivo
				lea		di, filename_dst
				call	strcpy
				mov		psp_string_segment_cursor, si	; Atualizar apontador de segmentos

				dec		psp_string_segments				; Descontar um segmento no contador

				jmp		segment_increment

not_option_o:
				cmp		[bp], byte ptr _CHAR_L_N		; Se for uma opção 'n'
				jne		option_atcg_loop

				inc		bp
				cmp		[bp], byte ptr _CHAR_NULL		; Descobrir se é uma opção válida
				je		valid_option_n

				mov		error_code, _ERROR_INVALID_PSP	; Atribuir respectivo código de erro

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_option_n:
				cmp		psp_string_segments, 0			; Avaliar se há valido parâmetro a ser processado
				jne		existent_param_n

				mov		error_code, _ERROR_INVALID_PSP_PARAM

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				mov		si, psp_string_segment_cursor
				call	strcpy

				lea		di, error_string2
				lea		si, null_msg
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

existent_param_n:
				inc		bp

				lea		di, dna_group_size_string		; Adquire a informação do tamanho dos grupos de DNA (se válido)
				mov		si, bp							; Como string
				call	strcpy
				mov		bp, si

				lea		bx, dna_group_size_string		; E como número
				call	atoi
				mov		dna_group_size, ax

				dec		psp_string_segments				; Descontar um segmento no contador

				cmp		dna_group_size, _INVALID_NUMBER	; Avaliar se há parâmetro válido a ser processado
				je		invalid_param_n
				cmp		dna_group_size, _MIN_DNA_GROUP_SIZE
				jb		invalid_param_n
				cmp		dna_group_size, _MAX_DNA_GROUP_SIZE
				ja		invalid_param_n

				mov		option_n, _ENABLED				; Habilitar opção 'n' quando há parâmetro válido

				mov		psp_string_segment_cursor, bp	; Atualizar próximo segmento a ser analisado

				jmp		segment_increment

invalid_param_n:
				mov		error_code, _ERROR_INVALID_PSP_PARAM

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, dna_group_size_string
				call	strcpy

				lea		di, error_string2
				mov		si, psp_string_segment_cursor
				call	strcpy

				mov		psp_string_segment_cursor, bp	; Atualizar próximo segmento a ser analisado

				jmp		main_return						; Encerrar programa com erro

option_atcg_loop:
				cmp		[bp], byte ptr _CHAR_L_A		; Se for uma opção 'a' ou 't' ou 'c' ou 'g' ou '+'
				je		enable_option_a
				cmp		[bp], byte ptr _CHAR_L_T
				je		enable_option_t
				cmp		[bp], byte ptr _CHAR_L_C
				je		enable_option_c
				cmp		[bp], byte ptr _CHAR_L_G
				je		enable_option_g
				cmp		[bp], byte ptr _CHAR_PLUS
				je		enable_option_plus

				jmp		unknown_option					; Se houver algum caractere inválido, retornar erro

enable_option_a:										; Habilitar as respectivas opções
				mov		option_a, _ENABLED
				jmp		option_atcg_loop_increment
enable_option_t:
				mov		option_t, _ENABLED
				jmp		option_atcg_loop_increment
enable_option_c:
				mov		option_c, _ENABLED
				jmp		option_atcg_loop_increment
enable_option_g:
				mov		option_t, _ENABLED
				jmp		option_atcg_loop_increment
enable_option_plus:
				mov		option_plus, _ENABLED
				jmp		option_atcg_loop_increment

option_atcg_loop_increment:
				inc		bp
				cmp		[bp], byte ptr _CHAR_NULL
				jne		option_atcg_loop

				mov		psp_string_segment_cursor, bp	; Atualizar próximo segmento a ser analisado
				jmp		segment_increment

unknown_option:
				mov		error_code, _ERROR_INVALID_PSP	; Atribuir respectivo código de erro

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

unknown_string:
				mov		error_code, _ERROR_UNKNOWN		; Atribuir respectivo código de erro

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro	

segment_increment:
				cmp		psp_string_segments, 0			; Continuar loop até percorrer todos segmentos
				jne		input_loop

				cmp		option_f, _ENABLED				; Descobrir se todas as opções obrigatórias foram especificadas
				jne		insuficient_options				; Equivalente à Se [f E n E (a OU t OU c OU g OU +)]
				cmp		option_n, _ENABLED
				jne		insuficient_options
				cmp		option_a, _ENABLED
				je		mandatory_options_enabled
				cmp		option_t, _ENABLED
				je		mandatory_options_enabled
				cmp		option_c, _ENABLED
				je		mandatory_options_enabled
				cmp		option_g, _ENABLED
				je		mandatory_options_enabled
				cmp		option_plus, _ENABLED
				je		mandatory_options_enabled

insuficient_options:
				mov		error_code, _ERROR_INSUFICIENT_PSP
				jmp		main_return						; Encerrar programa com erro

mandatory_options_enabled:
				lea		dx, filename_src				; Tentar abrir o arquivo de entrada
				call	fopen
				jnc		valid_filename

				mov		error_code, _ERROR_FILENAME		; Indicar erro de nome do arquivo

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, filename_src
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

valid_filename:
				mov		filehandle_src, bx

; CÓDIGO TEMPORÁRIO DE TESTE
				lea		bx, newline
				call	printf_s
				lea		bx, filename_src
				call	printf_s
				lea		bx, newline
				call	printf_s
				lea		bx, filename_dst
				call	printf_s
				lea		bx, newline
				call	printf_s
				lea		bx, dna_group_size_string
				call	printf_s
				lea		bx, newline
				call	printf_s
				lea		bx, dna_group_size_string
				mov		ax, dna_group_size
				call	sprintf_w
				lea		bx, dna_group_size_string
				call	printf_s
;

				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose

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
; Saída:   AX    - Valor hexadecimal/decimal resultante ou 65535 se for um número inválido.
;
; ===========================================================================================================================
;

atoi			proc 	near

				mov		ax, 0

atoi_loop:
				cmp		[bx], byte ptr _CHAR_NULL		; Testar se o caractere é nulo '\0'
				jz		atoi_return

				cmp		[bx], byte ptr _CHAR_ZERO		; Testar se o caractere é um número natural
				jb		atoi_invalid_char
				cmp		[bx], byte ptr _CHAR_NINE
				ja		atoi_invalid_char

				mov		cx, _BASE_10					; Calcular valor posicional do número
				mul		cx
				mov		ch, 0
				mov		cl, [bx]
				add		ax, cx
				sub		ax, _CHAR_ZERO

				inc		bx								; Incrementar a posição no string
				jmp		atoi_loop						; Continuar loop

atoi_invalid_char:
				mov		ax, _INVALID_NUMBER				; Caso não seja válido, retornar erro

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

				push	bp								; Salvar bp na pilha

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
				mov		[bx], byte ptr _CHAR_ZERO
				inc		bx

sprintf_w_return:
				mov		[bx], byte ptr _CHAR_NULL		; Colocar caractere de fim de string

				pop		bp								; Retornar valor de bp

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
; ES:DI, DS:SI strcpy(ES:DI, DS:SI)
; ===========================================================================================================================
;
; Função que copia uma string para outro lugar da memória:
;
; Entrada: ES:DI - Ponteiro para o início da string de destino;
;          DS:SI - Ponteiro para o início da string de origem;
; Saída:   ES:DI - Ponteiro para o marcador de final de string de destino;
;          DS:SI - Ponteiro para o marcador de final de string de origem.
;
; ===========================================================================================================================
;

strcpy			proc	near

				cld
strcpy_loop:
				movsb									; Copiar a string de origem para o destino
				cmp		[si - 1], byte ptr _CHAR_NULL
				jne		strcpy_loop

				dec		si
				dec		di

				ret

strcpy			endp

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

				mov		si, 80h							; Obter o tamanho do string e colocar em CX
				mov		dl, [si]
				mov 	ch, 0
				mov 	cl, dl

				mov 	si, 81h 						; Inicializar ponteiros de origem e destino
				mov 	di, bx
				rep movsb

				pop 	es 								; Retornar as informações dos segmentos
				pop 	ds

				mov		psp_string_size, dl				; Colocar indicador de final de string '\0'
				dec 	di
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
; DX convert_spaces_to_null(DS:BX, CX)
; ===========================================================================================================================
;
; Função que troca os espaços de uma string para caracteres nulos:
;
; Entrada: DS:BX - Ponteiro para o início da string;
;          CX    - Tamanho do string.
; Saída:   DX    - Número de segmentos encontrados
;
; ===========================================================================================================================
;

convert_spaces_to_null	proc	near

				mov		dx, 0							; Inicializar variáveis internas e de saída

				mov		di, bx							; Configurar parâmetros para a instrução de comparação
				mov		ah, _CHAR_NULL
				mov		al, _CHAR_SPACE
				cld

convert_spaces_to_null_loop:
				repne scasb								; Encontrar a próxima ocorrência de espaço na sentença

				cmp		cx, 0							; Descobrir se a string terminou
				je		convert_spaces_to_null_return

				mov		[di - 1], ah					; Colocar nulo no lugar de espaço e 
				inc		dx
				jmp		convert_spaces_to_null_loop

convert_spaces_to_null_return:
				ret

convert_spaces_to_null	endp

;
; ===========================================================================================================================
; DS:BX find_end_of_string(DS:BX)
; ===========================================================================================================================
;
; Função que encontra o marcador final de uma string:
;
; Entrada: DS:BX - Ponteiro para o início da string;
; Saída:   DS:BX - Ponteiro para o final da string ('\0').
;
; ===========================================================================================================================
;

find_end_of_string	proc	near

find_end_of_string_loop:
				cmp		[bx], byte ptr _CHAR_NULL			; Encontrar final de uma string ('\0')
				je		find_end_of_string_return

				inc		bx
				jmp		find_end_of_string_loop

find_end_of_string_return:
				ret

find_end_of_string	endp

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

				lea		bx, error_filename_msg			; Escrever o erro e o nome do arquivo inválido
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_invalid_msg_o
				call	printf_s

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

				lea		bx, error_insuficient_psp_msg1	; Tratar erro de string de entrada insuficiente
				call	printf_s

				cmp		option_f, _DISABLED				; Julgar quais parâmetros estão faltando
				jne		option_f_enabled

				lea		bx, error_option_f_msg
				call	printf_s

option_f_enabled:
				cmp		option_n, _DISABLED
				jne		option_n_enabled
				
				lea		bx, error_option_n_msg
				call	printf_s

option_n_enabled:
				cmp		option_a, _DISABLED
				jne		print_insuficient_options_end
				cmp		option_t, _DISABLED
				jne		print_insuficient_options_end
				cmp		option_c, _DISABLED
				jne		print_insuficient_options_end
				cmp		option_g, _DISABLED
				jne		print_insuficient_options_end
				cmp		option_plus, _DISABLED
				jne		print_insuficient_options_end

				lea		bx, error_option_atcg_msg
				call	printf_s

print_insuficient_options_end:
				lea		bx, error_insuficient_psp_msg2	; Finalizar mensagem de erro
				call	printf_s

				jmp		error_handler_return

not_insuficient_psp_error:
				cmp		error_code, _ERROR_INVALID_PSP
				jne		not_invalid_psp_error

				lea		bx, error_invalid_psp_msg		; Escrever o erro e a opção de entrada inválida
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_invalid_msg_a
				call	printf_s

				jmp		error_handler_return

not_invalid_psp_error:
				cmp		error_code, _ERROR_DUPLICATE_PSP
				jne		not_duplicate_psp_error

				lea		bx, error_duplicate_psp_msg		; Escrever o erro e a opção de entrada duplicada
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_duplicate_msg
				call	printf_s

				jmp		error_handler_return

not_duplicate_psp_error:
				cmp		error_code, _ERROR_INVALID_PSP_PARAM
				jne		not_invalid_psp_param_error

				cmp		[error_string2], byte ptr _CHAR_NULL; Julgar se faltou ou se houve parâmetro inválido
				jne		not_empty_psp_param_error

				lea		bx, error_invalid_psp_param_msgv; Escrever o erro e a opção entrada inválida (faltando parâmetro)
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_inexistent_msg
				call	printf_s

				jmp		error_handler_return

not_empty_psp_param_error:
				lea		bx, error_invalid_psp_param_msg1; Escrever o erro, a opção e o parâmetro de entrada inválidos
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_invalid_psp_param_msg2
				call	printf_s
				lea		bx, error_string2
				call	printf_s
				lea		bx, error_invalid_msg_o
				call	printf_s

				jmp		error_handler_return

not_invalid_psp_param_error:
				cmp		error_code, _ERROR_INVALID_CHAR
				jne		not_invalid_char_error

														; Tratar erro de parâmetros de caractere inválido no arquivo
				jmp		error_handler_return

not_invalid_char_error:
				cmp		error_code, _ERROR_UNKNOWN
				jne		error_handler_return

				lea		bx, error_unknown_msg			; Escrever o erro desconhecido
				call	printf_s

error_handler_return:
				ret

error_handler	endp

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------