
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

_SEEK_SET					equ				0					; Posições para posicionar cursor no arquivo
_SEEK_CUR					equ				1
_SEEK_END					equ				2

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
_ERROR_UNKNOWN_MSG			equ				9					; Mensagem desconhecida
_ERROR_FILE_READING			equ				10					; Problema de leitura no arquivo

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
option_o					db				?
option_plus					db				?
option_t					db				?

filename_src				db				256 dup (?)			; Nomes dos arquivos de entrada e saída
filename_dst				db				256 dup (?)
filehandle_src				dw				0					; Handles dos arquivo de entrada e saída
filehandle_dst				dw				0
filechar					db				0, _CHAR_NULL		; Caractere lido do arquivo (com espaço para uma "string")
filechar_newline			db				?					; Flag indicando leitura de linefeed no arquivo
filelines					dw				0					; Quantidade de linhas do arquivo de entrada
filelines_string			db				6 dup (?)			; String com a quantidade de linhas do arquivo de entrada
fileoffset_src				dw				?					; Offset para retornar no arquivo de entrada
fileheader_dst				db				19 dup (?)			; Cabeçalho do arquivo de saída
fileline_dst				db				39 dup (?)			; Conteúdo de uma linha do arquivo de saída

dna_group_size				dw				0					; Tamanho de cada grupo de bases de DNA
dna_group_size_string		db				256 dup (?)			; String com o tamanho de cada grupo de bases
dna_group_amount			dw				0					; Quantidade de grupos de bases de DNA
dna_group_amount_string		db				6 dup (?)			; String com a quantidade de grupos de bases de DNA
dna_base_amount				dw				0					; Quantidade de bases de DNA
dna_base_amount_string		db				6 dup (?)			; String com a quantidade de bases de DNA

specialchar_count			dw				?					; Contagem de caracteres especiais
dna_group_count				dw				?					; Contador de grupos de DNA
dna_base_a_amount			dw				?					; Contagem de bases de cada tipo por grupo
dna_base_t_amount			dw				?
dna_base_c_amount			dw				?
dna_base_g_amount			dw				?
dna_base_string				db				13 dup (?)			; String utilizada para montar os grupos no arquivo de saída

; Strings Constantes
null_msg					db				_CHAR_NULL
newline						db				_CHAR_CR, _CHAR_LF, _CHAR_NULL
semicolumn					db				';', _CHAR_NULL
semicolumn_newline			db				';', _CHAR_CR, _CHAR_LF, _CHAR_NULL
dot_newline					db				'.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
filename_dst_std			db				'a.out', _CHAR_NULL
valid_input_msg				db				_CHAR_CR, _CHAR_LF, 'Entrada Valida:', _CHAR_CR, _CHAR_LF, _CHAR_CR, _CHAR_LF, _CHAR_NULL
filename_src_msg			db				'Arquivo de Entrada: ', _CHAR_NULL
filename_dst_msg			db				'Arquivo de Saida: ', _CHAR_NULL
dna_group_size_msg			db				'Tamanho dos Grupos de Bases de DNA: ', _CHAR_NULL
output_information_msg		db				'Bases Contabilizadas na Saida: ', _CHAR_NULL
output_information_a		db				'A ', _CHAR_NULL
output_information_t		db				'T ', _CHAR_NULL
output_information_c		db				'C ', _CHAR_NULL
output_information_g		db				'G ', _CHAR_NULL
output_information_plus		db				'A+T C+G ', _CHAR_NULL
data_processing_msg			db				_CHAR_CR, _CHAR_LF, 'Dados a serem processados:', _CHAR_CR, _CHAR_LF, _CHAR_CR, _CHAR_LF, _CHAR_NULL
dna_base_amount_msg			db				'Numero de Bases na Entrada: ', _CHAR_NULL
dna_group_amount_msg		db				'Numero de Grupos de Bases na Entrada: ', _CHAR_NULL
filelines_amount_msg		db				'Numero de Linhas com Bases na Entrada: ', _CHAR_NULL
dna_base_a_column			db				'A;', _CHAR_NULL
dna_base_t_column			db				'T;', _CHAR_NULL
dna_base_c_column			db				'C;', _CHAR_NULL
dna_base_g_column			db				'G;', _CHAR_NULL
dna_base_plus_column		db				'A+T;C+G;', _CHAR_NULL
valid_output_msg			db				_CHAR_CR, _CHAR_LF, 'Arquivo de Saida Criado com Sucesso.', _CHAR_CR, _CHAR_LF, _CHAR_NULL

; Variáveis de Funções Auxiliares
sprintf_w_n					dw				0
sprintf_w_f					db				0
sprintf_w_m					dw				0

; Variáveis do Tratador de Erros
error_code					db				_ERROR_NONE			; Código de erro
error_string1				db				256 dup (?)			; Strings com informações do respectivo erro
error_string2				db				256 dup (?)
error_string3				db				256 dup (?)

; Mensagens de Erro Constantes
error_invalid_msg_o			db				'" invalido.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_invalid_msg_a			db				'" invalida.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_inexistent_msg		db				'" inexistente.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_duplicate_msg			db				'" duplicada.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_option_f_msg			db				' -f', _CHAR_NULL
error_option_n_msg			db				' -n', _CHAR_NULL
error_option_atcg_msg		db				' -atcg+', _CHAR_NULL
error_filename_msg			db				_CHAR_CR, _CHAR_LF, 'Erro 01: nome de arquivo "', _CHAR_NULL
error_small_filesize_msg1	db				_CHAR_CR, _CHAR_LF, 'Erro 02: arquivo "', _CHAR_NULL
error_small_filesize_msg2	db				'" muito pequeno. Necessario minimo de "', _CHAR_NULL
error_small_filesize_msg3	db				'" bases de DNA no arquivo.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_big_filesize_msg1		db				_CHAR_CR, _CHAR_LF, 'Erro 03: arquivo "', _CHAR_NULL
error_big_filesize_msg2		db				'" muito grande. Numero maximo de bases de DNA aceitas eh 10.000.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_insuficient_psp_msg1	db				_CHAR_CR, _CHAR_LF, 'Erro 04: opcoes de entrada insuficientes. Faltam as opcoes "', _CHAR_NULL
error_insuficient_psp_msg2	db				' ".', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_invalid_psp_msg		db				_CHAR_CR, _CHAR_LF, 'Erro 05: opcao de entrada "', _CHAR_NULL
error_duplicate_psp_msg		db				_CHAR_CR, _CHAR_LF, 'Erro 06: opcao de entrada "', _CHAR_NULL				
error_invalid_psp_param_msg1 db				_CHAR_CR, _CHAR_LF, 'Erro 07: parametro "', _CHAR_NULL
error_invalid_psp_param_msg2 db				'" da opcao "', _CHAR_NULL
error_invalid_psp_param_msgv db				_CHAR_CR, _CHAR_LF, 'Erro 07: parametro da opcao "', _CHAR_NULL
error_invalid_char_msg1		db				_CHAR_CR, _CHAR_LF, 'Erro 08: caractere "', _CHAR_NULL
error_invalid_char_msg2		db				'" do arquivo "', _CHAR_NULL
error_invalid_char_msg3		db				'" na linha "', _CHAR_NULL
error_unknown_msg1			db				_CHAR_CR, _CHAR_LF, 'Erro 09: trecho "', _CHAR_NULL
error_unknown_msg2			db				'" nao reconhecido.', _CHAR_CR, _CHAR_LF, _CHAR_NULL
error_file_reading_msg1		db				_CHAR_CR, _CHAR_LF, 'Erro 10: falha de leitura do arquivo "', _CHAR_NULL
error_file_reading_msg2		db				'" na linha "', _CHAR_NULL
error_file_reading_msg3		db				'".', _CHAR_CR, _CHAR_LF, _CHAR_NULL

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
				mov		option_o, _DISABLED
				mov		option_plus, _DISABLED
				mov		option_t, _DISABLED
				mov		psp_string_segment_cursor, offset psp_string
				mov		psp_string_segments, 0
				mov		dna_group_size, 0
				mov		dna_group_amount, 0
				mov		dna_base_amount, 0
				mov		dna_base_a_amount, 0
				mov		dna_base_t_amount, 0
				mov		dna_base_c_amount, 0
				mov		dna_base_g_amount, 0
				mov		filelines, 1
				mov		filechar_newline, _DISABLED
				mov		dna_group_count, 0
				mov		specialchar_count, 0

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
				cmp		option_f, _ENABLED				; Avaliar se há opção duplicada
				jne		not_duplicate_f

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

not_duplicate_f:
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
				cmp		option_o, _ENABLED				; Avaliar se há opção duplicada
				jne		not_duplicate_o

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

not_duplicate_o:
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
				mov		option_o, _ENABLED				; Habilitar opção 'o' quando há parâmetro válido

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
				cmp		option_n, _ENABLED				; Avaliar se há opção duplicada
				jne		not_duplicate_n

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

not_duplicate_n:
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
				je		valid_option_a
				cmp		[bp], byte ptr _CHAR_L_T
				je		valid_option_t
				cmp		[bp], byte ptr _CHAR_L_C
				je		valid_option_c
				cmp		[bp], byte ptr _CHAR_L_G
				je		valid_option_g
				cmp		[bp], byte ptr _CHAR_PLUS
				je		valid_option_plus

				jmp		unknown_option					; Se houver algum caractere inválido, retornar erro

valid_option_a:											; Verificar se não há opções duplicadas
				cmp		option_a, _ENABLED				; Se não houver, habilitar opções normalmente
				jne		enable_option_a

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

enable_option_a:
				mov		option_a, _ENABLED
				jmp		option_atcg_loop_increment

valid_option_t:
				cmp		option_t, _ENABLED				; Se não houver, habilitar opções normalmente
				jne		enable_option_t

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

enable_option_t:
				mov		option_t, _ENABLED
				jmp		option_atcg_loop_increment

valid_option_c:
				cmp		option_c, _ENABLED				; Se não houver, habilitar opções normalmente
				jne		enable_option_c

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

enable_option_c:
				mov		option_c, _ENABLED
				jmp		option_atcg_loop_increment

valid_option_g:
				cmp		option_g, _ENABLED				; Se não houver, habilitar opções normalmente
				jne		enable_option_g

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

enable_option_g:
				mov		option_g, _ENABLED
				jmp		option_atcg_loop_increment

valid_option_plus:
				cmp		option_plus, _ENABLED			; Se não houver, habilitar opções normalmente
				jne		enable_option_plus

				mov		error_code, _ERROR_DUPLICATE_PSP

				lea		di, error_string1				; Guardar mensagem de erro a ser mostrada
				mov		si, psp_string_segment_cursor
				call	strcpy

				jmp		main_return						; Encerrar programa com erro

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
				mov		error_code, _ERROR_UNKNOWN_MSG		; Atribuir respectivo código de erro

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

file_validation_loop:									; Loop de validação de arquivo de entrada
				mov		bx, filehandle_src
				mov		cx, _SINGLE_BYTE
				lea		dx, filechar
				call	fread
				jnc		valid_file_reading

				mov		error_code, _ERROR_FILE_READING	; Indicar erro de leitura de arquivo

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, filename_src
				call	strcpy

				mov		ax, filelines
				lea		bx, filelines_string
				call	sprintf_w
				lea		di, error_string2
				lea		si, filelines_string
				call	strcpy

				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose

				jmp		main_return						; Encerrar programa com erro

valid_file_reading:
				cmp		ax, _SINGLE_BYTE				; Descobrir se ainda há bytes a serem lidos no arquivo
				jne		file_validation_loop_end

				cmp		filechar, _CHAR_LF				; Verificar se houve nova linha no arquivo
				jne		not_filechar_newline

				mov		filechar_newline, _ENABLED		; Habilitar flag de incremento de linhas

				jmp		file_validation_loop

not_filechar_newline:
				cmp		filechar, _CHAR_U_A				; Validar se leu um caractere válido
				je		valid_char
				cmp		filechar, _CHAR_U_T
				je		valid_char
				cmp		filechar, _CHAR_U_C
				je		valid_char
				cmp		filechar, _CHAR_U_G
				je		valid_char
				cmp		filechar, _CHAR_CR
				je		file_validation_loop

				cmp		filechar_newline, _ENABLED			; Confere se houve caractere inválido no início da linha
				jne		no_line_increment_invalid_char

				inc		filelines
				mov		filechar_newline, _DISABLED

no_line_increment_invalid_char:
				mov		error_code, _ERROR_INVALID_CHAR	; Indicar erro de caractere inválido

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, filechar
				call	strcpy

				lea		di, error_string2
				lea		si, filename_src
				call	strcpy

				mov		ax, filelines
				lea		bx, filelines_string
				call	sprintf_w
				lea		di, error_string3
				lea		si, filelines_string
				call	strcpy

				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose

				jmp		main_return						; Encerrar programa com erro

valid_char:
				cmp		filechar_newline, _ENABLED			; Confere se houve quebra de linha
				jne		no_line_increment_valid_char

				inc		filelines
				mov		filechar_newline, _DISABLED

no_line_increment_valid_char:
				inc		dna_base_amount					; Incrementar número de bases

				jmp		file_validation_loop

file_validation_loop_end:
				mov		ax, dna_group_size
				cmp		dna_base_amount, ax				; Validar tamanho do arquivo
				jb		no_dna_groups
				cmp		dna_base_amount, _MAX_DNA_GROUP_SIZE
				ja		too_many_dna_bases

				mov		dx, dna_base_amount				; Descobrir o número de grupos a serem processados
				sub		dx, dna_group_size
				inc		dx
				mov		dna_group_amount, dx

				jmp		file_validation_end

no_dna_groups:
				mov		error_code, _ERROR_SMALL_FILESIZE; Indicar erro de arquivo muito pequeno

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, filename_src
				call	strcpy

				lea		di, error_string2
				lea		si, dna_group_size_string
				call	strcpy

				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose

				jmp		main_return						; Encerrar programa com erro

too_many_dna_bases:
				mov		error_code, _ERROR_BIG_FILESIZE	; Indicar erro de arquivo muito grande

				lea		di, error_string1				; Guardar mensagens de erro a serem mostradas
				lea		si, filename_src
				call	strcpy

				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose

				jmp		main_return						; Encerrar programa com erro

file_validation_end:
				call	print_valid_input				; Escrever todos os dados de entrada

				mov		bx, filehandle_src				; Colocar cursor do arquivo de entrada no início dele
				call	rewind

				lea		dx, filename_dst				; Criar arquivo de saída
				call	fcreate
				mov		filehandle_dst, bx

				lea		di, fileheader_dst				; Montar cabeçalho de arquivo de saída
				call	format_header_string			; (CX recebe o número de bytes do cabeçalho)

				mov		bx, filehandle_dst				; Escrever cabeçalho no arquivo de saída
				lea		dx, fileheader_dst
				call	fwrite

file_output_loop:
				mov		ax, dna_group_count				; Descobrir se já foram lidas todas as bases do arquivo de entrada
				cmp		ax, dna_group_amount
				je		file_output_loop_end

file_output_read_char:
				mov		bx, filehandle_src				; Ler arquivo de entrada byte a byte
				mov		cx, _SINGLE_BYTE
				lea		dx, filechar
				call	fread

				cmp		filechar, _CHAR_LF				; Validar qual caractere foi lido
				je		special_char
				cmp		filechar, _CHAR_CR
				je		special_char
				cmp		filechar, _CHAR_U_A
				je		a_char
				cmp		filechar, _CHAR_U_T
				je		t_char
				cmp		filechar, _CHAR_U_C
				je		c_char
				cmp		filechar, _CHAR_U_G
				je		g_char

				jmp		dna_group_validation

special_char:
				inc		specialchar_count				; Contabilizar a quantidade de caracteres de cada tipo
				jmp		dna_group_validation

a_char:
				inc		dna_base_a_amount
				jmp		dna_group_validation

t_char:
				inc		dna_base_t_amount
				jmp		dna_group_validation

c_char:
				inc		dna_base_c_amount
				jmp		dna_group_validation

g_char:
				inc		dna_base_g_amount

dna_group_validation:
				mov		ax, dna_base_a_amount			; Descobrir se um grupo já foi processado
				add		ax, dna_base_t_amount
				add		ax, dna_base_c_amount
				add		ax, dna_base_g_amount
				cmp		ax, dna_group_size
				jne		file_output_read_char

				inc		dna_group_count					; Contabilizar grupos

				lea		di, fileline_dst				; Montar string com os dados de um grupo
				call	format_dna_group_string			; (CX recebe o número de bytes da string)

				mov		bx, filehandle_dst				; Escrever string no arquivo de saída
				lea		dx, fileline_dst
				call	fwrite

				mov		ax, dna_group_size				; Calcular e formatar offset do arquivo
				add		ax, specialchar_count
				dec		ax
				neg		ax
				call	fseek_offset

				mov		bx, filehandle_src				; Ajustar offset no arquivo de entrada
				mov		al, _SEEK_CUR
				call	fseek

				mov		specialchar_count, 0			; Reiniciar contagem de todos os caracteres
				mov		dna_base_a_amount, 0
				mov		dna_base_t_amount, 0
				mov		dna_base_c_amount, 0
				mov		dna_base_g_amount, 0

				jmp		file_output_loop

file_output_loop_end:
				mov		bx, filehandle_src				; Fechar arquivo de entrada
				call	fclose
				mov		bx, filehandle_dst				; Fechar arquivo de saída
				call	fclose

				lea		bx, newline						; Indicar que acabou o processamento da saída
				call	printf_s
				lea		bx, valid_output_msg
				call	printf_s

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
; CX strlen(ES:DI)
; ===========================================================================================================================
;
; Função que copia uma string para outro lugar da memória:
;
; Entrada: ES:DI - Ponteiro para o início da string;
; Saída:   CX    - Tamanho da string de entrada em caracteres (excluindo marcador de final).
;
; ===========================================================================================================================
;

strlen			proc	near

				mov		cx, 0							; Inicializar variáveis e parâmetros internos
				cld
				mov		al, _CHAR_NULL
strlen_loop:
				scasb									; Contar caracteres até encontrar o marcador de final de string
				je		strlen_return

				inc		cx

				jmp		strlen_loop

strlen_return:
				ret

strlen			endp

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
; ES:DI, DS:SI strcat(ES:DI, DS:SI)
; ===========================================================================================================================
;
; Função que concatena a string de origem na string de destino:
;
; Entrada: ES:DI - Ponteiro para o início da string de destino;
;          DS:SI - Ponteiro para o início da string de origem;
; Saída:   ES:DI - Ponteiro para o marcador de final de string de destino;
;          DS:SI - Ponteiro para o marcador de final de string de origem.
;
; ===========================================================================================================================
;

strcat			proc	near

				cld										; Inicializar parâmetros de entrada
				mov		al, _CHAR_NULL
strcat_beginning_loop:
				scasb									; Encontrar marcador de final de string de destino
				jne		strcat_beginning_loop

				dec		di

strcat_copy_loop:
				movsb									; Copiar a string de origem para o destino
				cmp		[si - 1], byte ptr _CHAR_NULL
				jne		strcat_copy_loop

				dec		si
				dec		di

				ret

strcat			endp

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
;          DS:DX - Endereço dos bytes a serem escritos;
;          CX    - Número de bytes para serem escritos;
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
; CF, DX:AX fseek(BX, DX:CX, AL)
; ===========================================================================================================================
;
; Função que muda o ponteiro do arquivo para a posição desejada:
;
; Entrada: BX    - Handle do arquivo;
;          DX:CX - Offset para mover o ponteiro (4 bytes com número positivo ou negativo, DX é o LSB e CX é o MSB);
;          AL    - Modo de navegação no arquivo:
;                  > _SEEK_SET - Início do arquivo;
;                  > _SEEK_CUR - Meio do arquivo;
;                  > _SEEK_END - Final do arquivo;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          DX:AX - Posição alterada no arquivo (DX é MSB e AX é LSB);
;
; ===========================================================================================================================
;

fseek			proc	near

				mov		ah, 42h							; Chamar a respectiva interrupção de sistema
				int		21h

				ret

fseek			endp

;
; ===========================================================================================================================
; DX:CX fseek_offset(AX)
; ===========================================================================================================================
;
; Função que tranforma um offset de uma word em um offset double word:
;
; Entrada: AX    - Offset de uma word;
; Saída:   DX:CX - Offset double word (DX é LSB e CX é MSB);
;
; ===========================================================================================================================
;

fseek_offset	proc	near

				cwd										; Tranformar valor de word para double word

				mov		cx, dx							; Mover os dados para os devidos registradores
				mov		dx, ax

				ret

fseek_offset	endp

;
; ===========================================================================================================================
; CF, DX:AX rewind(BX)
; ===========================================================================================================================
;
; Função que retorna o ponteiro do arquivo para o posição inicial:
;
; Entrada: BX    - Handle do arquivo;
; Saída:   CF    - Flag indicando se a operação foi bem sucedida (0) ou não (1);
;          DX:AX - Posição inicial do arquivo;
;
; ===========================================================================================================================
;

rewind			proc	near

				mov		cx, 0							; Configurar offset para início do arquivo
				mov		dx, 0
				mov		al, _SEEK_SET
				mov		ah, 42h							; Chamar a respectiva interrupção de sistema
				int		21h

				ret

rewind			endp

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
; void print_valid_input(...)
; ===========================================================================================================================
;
; Função que escreve os dados de uma entrada válida do programa:
;
; Entrada: ...        - Variáveis globais necessárias para imprimir a entrada válida.
;
; ===========================================================================================================================
;

print_valid_input	proc	near

				lea		bx, newline							; Imprimir linha vazia
				call	printf_s

				lea		bx, valid_input_msg					; Colocar primeiro cabeçalho
				call	printf_s

				lea		bx, filename_src_msg				; Nome do arquivo de entrada
				call	printf_s
				lea		bx, filename_src
				call	printf_s
				lea		bx, semicolumn_newline
				call	printf_s

				lea		bx, filename_dst_msg				; Nome do arquivo de saída
				call	printf_s
				lea		bx, filename_dst
				call	printf_s
				lea		bx, semicolumn_newline
				call	printf_s
				
				lea		bx, dna_group_size_msg				; Tamanho de cada grupo de DNA
				call	printf_s
				lea		bx, dna_group_size_string
				call	printf_s
				lea		bx, semicolumn_newline
				call	printf_s

				lea		bx, output_information_msg			; Informações do arquivo de entrada a serem processadas
				call	printf_s

				cmp		option_a, _ENABLED					; Validar quais bases serão contabilizadas
				jne		option_a_disabled

				lea		bx, output_information_a
				call	printf_s

option_a_disabled:
				cmp		option_t, _ENABLED
				jne		option_t_disabled

				lea		bx, output_information_t
				call	printf_s

option_t_disabled:
				cmp		option_c, _ENABLED
				jne		option_c_disabled

				lea		bx, output_information_c
				call	printf_s

option_c_disabled:
				cmp		option_g, _ENABLED
				jne		option_g_disabled

				lea		bx, output_information_g
				call	printf_s

option_g_disabled:
				cmp		option_plus, _ENABLED
				jne		option_plus_disabled

				lea		bx, output_information_plus
				call	printf_s

option_plus_disabled:
				lea		bx, dot_newline
				call	printf_s				

				lea		bx, newline							; Imprimir linha vazia
				call	printf_s

				lea		bx, data_processing_msg				; Colocar segundo cabeçalho
				call	printf_s

				lea		bx, dna_base_amount_msg				; Número de bases de DNA
				call	printf_s
				lea		bx, dna_base_amount_string
				mov		ax, dna_base_amount
				call	sprintf_w
				lea		bx, dna_base_amount_string
				call	printf_s
				lea		bx, semicolumn_newline
				call	printf_s

				lea		bx, dna_group_amount_msg			; Número de grupos de bases de DNA
				call	printf_s
				lea		bx, dna_group_amount_string
				mov		ax, dna_group_amount
				call	sprintf_w
				lea		bx, dna_group_amount_string
				call	printf_s
				lea		bx, semicolumn_newline
				call	printf_s

				lea		bx, filelines_amount_msg			; Número de linhas com bases no arquivo de entrada
				call	printf_s
				lea		bx, filelines_string
				mov		ax, filelines
				call	sprintf_w
				lea		bx, filelines_string
				call	printf_s
				lea		bx, dot_newline
				call	printf_s

				ret

print_valid_input	endp

;
; ===========================================================================================================================
; CX format_header_string(DS:DI)
; ===========================================================================================================================
;
; Função que monta a string de cabeçalho do arquivo de saída:
;
; Entrada: DS:DI - String para armazenar o cabeçalho;
; Saída:   CX    - Quantidade de caracteres no cabeçalho.
;
; ===========================================================================================================================
;

format_header_string proc	near

				push	di									; Guardar início da string para avaliar o tamanho total

				lea		si, null_msg						; Limpar a string de saída
				call	strcpy

				cmp		option_a, _ENABLED					; Validar quais bases serão impressas no cabeçalho
				jne		column_a_disabled

				lea		si, dna_base_a_column
				call	strcat

column_a_disabled:
				cmp		option_t, _ENABLED
				jne		column_t_disabled

				lea		si, dna_base_t_column
				call	strcat

column_t_disabled:
				cmp		option_c, _ENABLED
				jne		column_c_disabled

				lea		si, dna_base_c_column
				call	strcat

column_c_disabled:
				cmp		option_g, _ENABLED
				jne		column_g_disabled

				lea		si, dna_base_g_column
				call	strcat

column_g_disabled:
				cmp		option_plus, _ENABLED
				jne		column_plus_disabled

				lea		si, dna_base_plus_column
				call	strcat

column_plus_disabled:
				dec		di									; Remover o último ';' da linha
				mov		[di], byte ptr _CHAR_NULL

				pop		di									; Descobrir o tamanho da string de cabeçalho
				call	strlen

				ret

format_header_string endp

;
; ===========================================================================================================================
; CX format_dna_group_string(DS:DI)
; ===========================================================================================================================
;
; Função que monta a string de cada grupo do arquivo de saída:
;
; Entrada: DS:DI - String para armazenar as contagens do grupo;
; Saída:   CX    - Quantidade de caracteres no cabeçalho.
;
; ===========================================================================================================================
;

format_dna_group_string proc	near

				push	di									; Guardar início da string para avaliar o tamanho total

				lea		si, null_msg						; Limpar a string de saída
				call	strcpy

				lea		si, newline							; Colocar nova linha no início da string
				call	strcat

				cmp		option_a, _ENABLED					; Validar quais bases serão impressas no cabeçalho
				jne		base_a_disabled						; Contabilizando as respectivas bases

				push	di									; Guardar ponteiro de string de destino

				mov		ax, dna_base_a_amount				; Formatar a informação de uma base
				lea		bx, dna_base_string
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				pop		di
				lea		si, dna_base_string
				call	strcat

base_a_disabled:
				cmp		option_t, _ENABLED
				jne		base_t_disabled

				push	di									; Guardar ponteiro de string de destino

				mov		ax, dna_base_t_amount				; Formatar a informação de uma base
				lea		bx, dna_base_string
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				pop		di
				lea		si, dna_base_string
				call	strcat

base_t_disabled:
				cmp		option_c, _ENABLED
				jne		base_c_disabled

				push	di									; Guardar ponteiro de string de destino

				mov		ax, dna_base_c_amount				; Formatar a informação de uma base
				lea		bx, dna_base_string
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				pop		di
				lea		si, dna_base_string
				call	strcat

base_c_disabled:
				cmp		option_g, _ENABLED
				jne		base_g_disabled

				push	di									; Guardar ponteiro de string de destino

				mov		ax, dna_base_g_amount				; Formatar a informação de uma base
				lea		bx, dna_base_string
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				pop		di
				lea		si, dna_base_string
				call	strcat

base_g_disabled:
				cmp		option_plus, _ENABLED
				jne		base_plus_disabled

				push	di									; Guardar ponteiro de string de destino

				mov		ax, dna_base_a_amount				; Processar A+T e colocar a informação na string de base
				add		ax, dna_base_t_amount
				lea		bx, dna_base_string
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				mov		ax, dna_base_c_amount				; Processar C+G e colocar a informação na string de base
				add		ax, dna_base_g_amount
				mov		bx, di
				call	sprintf_w

				lea		di, dna_base_string
				lea		si, semicolumn
				call	strcat

				pop		di
				lea		si, dna_base_string
				call	strcat

base_plus_disabled:
				dec		di									; Remover o último ';' da linha
				mov		[di], byte ptr _CHAR_NULL

				pop		di									; Descobrir o tamanho da string total
				call	strlen

				ret

format_dna_group_string endp

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

				lea		bx, error_small_filesize_msg1	; Escrever o erro, o nome do arquivo e o tamanho mínimo do arquivo muito pequeno
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_small_filesize_msg2
				call	printf_s
				lea		bx, error_string2
				call	printf_s
				lea		bx, error_small_filesize_msg3
				call	printf_s

				jmp		error_handler_return

not_small_filesize_error:
				cmp		error_code, _ERROR_BIG_FILESIZE
				jne		not_big_filesize_error

				lea		bx, error_big_filesize_msg1		; Escrever o erro, o nome do arquivo e o tamanho máximo do arquivo muito grande
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_big_filesize_msg2
				call	printf_s

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

				lea		bx, error_invalid_char_msg1		; Escrever o erro, o caractere inválido, o arquivo e a linha no arquivo
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_invalid_char_msg2
				call	printf_s
				lea		bx, error_string2
				call	printf_s
				lea		bx, error_invalid_char_msg3
				call	printf_s
				lea		bx, error_string3
				call	printf_s
				lea		bx, error_invalid_msg_o
				call	printf_s

				jmp		error_handler_return

not_invalid_char_error:
				cmp		error_code, _ERROR_UNKNOWN_MSG
				jne		not_unknown_msg_error

				lea		bx, error_unknown_msg1			; Escrever o erro e o texto não reconhecido
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_unknown_msg2
				call	printf_s

				jmp		error_handler_return

not_unknown_msg_error:
				cmp		error_code, _ERROR_FILE_READING
				jne		error_handler_return

				lea		bx, error_file_reading_msg1		; Escrever o erro, o arquivo e a linha do problema de leitura do arquivo
				call	printf_s
				lea		bx, error_string1
				call	printf_s
				lea		bx, error_file_reading_msg2
				call	printf_s
				lea		bx, error_string2
				call	printf_s
				lea		bx, error_file_reading_msg3
				call	printf_s

error_handler_return:
				ret

error_handler	endp

; ---------------------------------------------------------------------------------------------------------------------------
    end
; ---------------------------------------------------------------------------------------------------------------------------