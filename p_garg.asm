title "Proyecto: Tetris" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 512 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		30
;Valores de referencia para la posición inicial de la primera pieza
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	1

;Valores para la posición de los controles e indicadores dentro del juego
;Next
next_col 		equ  	lim_derecho+7
next_ren 		equ  	4

;Data
hiscore_ren	 	equ 	10
hiscore_col 	equ 	lim_derecho+7
level_ren	 	equ 	12
level_col 		equ 	lim_derecho+7
lines_ren	 	equ 	14
lines_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+15
stop_ren 		equ 	lim_inferior-4
stop_izq 		equ 	stop_col
stop_der 		equ 	stop_col+2
stop_sup 		equ 	stop_ren
stop_inf 		equ 	stop_ren+2

;Botón PAUSE
pause_col 		equ 	lim_derecho+25
pause_ren 		equ 	lim_inferior-4
pause_izq 		equ 	pause_col
pause_der 		equ 	pause_col+2
pause_sup 		equ 	pause_ren
pause_inf 		equ 	pause_ren+2

;Botón PLAY
play_col 		equ 	lim_derecho+35
play_ren 		equ 	lim_inferior-4
play_izq 		equ 	play_col
play_der 		equ 	play_col+2
play_sup 		equ 	play_ren
play_inf 		equ 	play_ren+2

;Piezas
linea 			equ 	0
cuadro 			equ 	1
lnormal 		equ 	2
linvertida	 	equ 	3
tnormal 		equ 	4
snormal 		equ 	5
sinvertida 		equ 	6

;status
paro 			equ 	0
activo 			equ 	1
pausa			equ 	2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"TETRIS"
finTitulo 		db 		""
levelStr 		db 		"LEVEL"
finLevelStr 	db 		""
linesStr 		db 		"LINES"
finLinesStr 	db 		""
hiscoreStr		db 		"HI-SCORE"
finHiscoreStr 	db 		""
nextStr			db 		"NEXT"
finNextStr 		db 		""
blank			db 		"     "
lines_score 	dw 		0
hiscore 		dw 		0
speed 			dw 		4
next 			db 		0
level           dw      1
dkb             db      0
div20			db		20
tiempo_bajada	dw		3E80h
tiempo_dkb		db		50

;Coordenadas de la posición de referencia para la pieza en el área de juego
pieza_col		db 		ini_columna
pieza_ren		db 		ini_renglon
;Coordenadas de los pixeles correspondientes a la pieza en el área de juego
;El arreglo cols guarda las columnas, y rens los renglones
pieza_cols 		db 		0,0,0,0
pieza_rens 		db 		0,0,0,0
giro          db    1
giro_aux      db    1
;Valor de la pieza actual correspondiente a las constantes Piezas
pieza_actual 	db 		linea
;Color de la pieza actual, correspondiente a los colores del carácter
actual_color 	db 		0
;Coordenadas de los pixeles correspondientes a la pieza siguiente
next_cols 		db 		0,0,0,0
next_rens 		db 		0,0,0,0
;Color de la pieza siguiente, correspondiente con los colores del carácter
next_color 		db 		6
;Valor de la pieza siguiente correspondiente a Piezas
pieza_next 		db 		lnormal
;A continuación se tienen algunas variables auxiliares
;Variables min y max para almacenar los extremos izquierdo, derecho, inferior y superior, para detectar colisiones
pieza_col_max 	db 		0
pieza_col_min 	db 		0
pieza_ren_max 	db 		0
pieza_ren_min 	db 		0
;Variable para pasar como parámetro al imprimir una pieza
pieza_color 	db 		0
;Variables auxiliares de uso general
aux1	 		db 		0
aux2 			db 		0
auxw      dw    0
;Variables auxiliares para el manejo de posiciones
col_aux 		db 		0
ren_aux 		db 		0

;variables para manejo del reloj del sistema
ticks 			dw		0 		;contador de ticks
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
diez 			dw 		10

status 			db 		0 		;Status de juegos: 0 stop, 1 active, 2 pause
conta 			db 		0 		;Contador auxiliar para algunas operaciones

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
;matriz
doscuatro			db 	30
matriz_pos1 db	720 dup(0)
matriz_col1 db	720 dup(0)
;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 		'No se encuentra driver de mouse. Presione [enter] para salir$'

;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h.
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna'
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'.
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos
							;'bg_color' define los 4 bits más significativos
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'.
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos
							;'bg_color' define los 4 bits más significativos
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;Ejemplo: Si la int 33h devuelve la posición (400,120)
;Al convertir a resolución => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => (50,15)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;delimita_mouse_h - Delimita la posición del mouse horizontalmente dependiendo los valores 'minimo' y 'maximo'
delimita_mouse_h 	macro minimo,maximo
	mov cx,minimo  	;establece el valor mínimo horizontal en CX
	mov dx,maximo  	;establece el valor máximo horizontal en CX
	mov ax,7		;opcion 7
	int 33h			;llama interrupcion 33h para manejo del mouse
endm
; lee la tecla presionada
comprueba_teclado   macro
	mov ax, 0100h
	int 16h		; se usa la interrupcion 16h 01h
endm
; espera 16 milisegundos
espera macro
	mov ax, 8600h 	;preparamos interrupcion de espera
	mov cx, 0000h   ; movemos a cx 0 ya que no se requiere texto
	mov dx, 3e80h   ; en dx ponemos el valor de 16000 en hexadecimal
	int 15h ;se realiza la espera
endm
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.
	jmp salir_enter		;salta a 'salir_enter'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz de usuario
	call IMPRIME_SCORES
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	posiciona_cursor_mouse 320d,16d	;establece la posición del mouse
;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	cmp dx,play_ren+1
	je boton_t
	cmp dx,play_ren+2
	je boton_t
	cmp dx,play_ren
	je boton_t
	jmp mouse_no_clic
boton_x:
	jmp boton_x1
;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

	jmp mouse_no_clic
;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
boton_t:
	jmp boton_t1
;Lógica para revisar si el mouse fue presionado en el boton play
boton_t1:
	cmp cx,play_col
	jge boton_t2
	cmp cx, stop_col
	jge boton_stop2
	jmp mouse_no_clic
boton_t2:
	cmp cx,play_col+2
	jbe boton_t3
	jmp mouse_no_clic
boton_t3:
	;Se cumplieron todas las condiciones
	jmp empieza
	jmp mouse_no_clic
;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
boton_stop:
	jmp boton_stop1
;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_stop1:
	cmp cx, stop_col
	jge boton_stop2
	jmp mouse_no_clic
boton_stop2:
	cmp cx, stop_col+2
	jbe boton_stop3
	jmp mouse_no_clic
boton_stop3:
	;Se cumplieron todas las condiciones
	jmp imprime_ui
	jmp mouse_no_clic
;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
empieza:
	call PIEZAMBAJAV            ;busca la pieza mas abajo en vertical para calcular las veces que la pieza bajara en el juego
	mov cx, lim_inferior				; se mueve a cx el valor del pixel mas bajo al que se puede llegar
	sub cl, ah								; resta el dato que calculamos era el mayor con el mas bajo

uptfps:
	push cx  					;metemos cx a la pila para evitar que se nos pierda el contenido de las veces que faltan para que toque el fondo
	call BUSCAABAJO   ;busca si no hay una pieza un pixek abajo de la pieza que estamos moviendo si la encuentra devuelve bx= 1
	cmp bx, 0         ; si no se encontro una píeza abajo (colision)
	je actualiza      ;salta a seguir el flujo normal
	pop cx						; si si encontro una pieza saca a cx de la pila
	mov cx,1					; movemos a cx 1 para que no nos de un valor negativo al momento de decrementar
	push cx						;guardamos otra vez en la pila a cx
	jmp repite				;saltamos a rapite para que se deje de mover la pieza y guarde la posicion
actualiza:
	call DIBUJA_UPDT ;se llama a dibujar la pieza con un dezplazamiento hacia abajo
	push cx
	mov cl,[tiempo_dkb]
	mov dkb,cl		;movemos a dkb 50 que son las veces que se actualiza el programa para saber si fue presionada una tecla
	mov cx,0
	pop cx
cmpkb:
lee_mouse ;leemos el mouse para saber si fue presionado algun boton como el de pausa o el de stop
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz teclado			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

	cmp dx,0
	je boton_xj

	cmp dx,stop_ren+1 ;compara la posicioncon el boton de stop intermedio
	je boton_stop22  	;si realmente esta sobre el renglon se realizan las comparaciones en stop 22
	cmp dx,stop_ren+2 ;compara la posicion del boton stop parte superior
	je boton_stop22   ;si realmente esta sobre el renglon se realizan las comparaciones en stop 22
	cmp dx,stop_ren   ;compara la posicion del boton stop parte inferior
	je boton_stop22   ;si realmente esta sobre el renglon se realizan las comparaciones en stop 22
	jmp teclado				; si el mouse no esta sobre este renglon no se realiza ninguna comparacion extra y salta a revisar el estado del teclado
	
	boton_xj:
	jmp boton_xj1
	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_xj1:
	cmp cx,76
	jge boton_xj2
	jmp teclado
	boton_xj2:
	cmp cx,78
	jbe boton_xj3
	jmp teclado
	boton_xj3:
	;Se cumplieron todas las condiciones
	jmp salir

	boton_stop22:
	jmp boton_stop11
	;Lógica para revisar si el mouse fue presionado en el boton stop
	;el boton stop se encuentra en renglon 0 y entre columnas stop_col y stop_col +2
	boton_stop11:
	cmp cx, stop_col
	jge boton_stop21
	jmp boton_pause11	;si no se cumple el clic sobre el boton stop se salta a comprobar el teclado
	boton_stop21:
	cmp cx, stop_col+2
	jbe boton_stop31
	jmp boton_pause11 ; si no se cumple el clic sobre el boton stop se salta a comprobar el teclado
	boton_stop31:
	;Se cumplieron todas las condiciones
	call VACIAR_COORDENADAS
	call BORRA_SCORES
	call IMPRIME_DATOS_INICIALES
	jmp inicio

	boton_pause11:
	cmp cx,pause_col
	jge boton_pause21
	jmp teclado
	boton_pause21:
	cmp cx,pause_col+2
	jbe boton_pause31
	jmp teclado
	boton_pause31:
	mov [status],pausa
	push ax
	push dx
	push cx
	push bx
	jmp while_pausa
	salir_pausa:
		pop bx
		pop cx
		pop dx
		pop ax
		cmp [status],activo
		je teclado
	while_pausa:
		lee_mouse ;leemos el mouse para saber si fue presionado algun boton como el de pausa o el de stop
		mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
		div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

		mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
		div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

		;Aquí se revisa si se hizo clic en el botón izquierdo
		test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
		jz while_pausa			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

		cmp dx,0
		je boton_x11
		jmp botones_click	;No se hizo click en el renglon 0, se verifica si fue en otro
		
		boton_x11:
		jmp boton_x111
		;Lógica para revisar si el mouse fue presionado en [X]
		;[X] se encuentra en renglon 0 y entre columnas 76 y 78
		boton_x111:
			cmp cx,76
			jge boton_x21
			jmp while_pausa
		boton_x21:
			cmp cx,78
			jbe boton_x31
			jmp while_pausa
		boton_x31:
			;Se cumplieron todas las condiciones
			jmp salir
			jmp while_pausa

		;Lógica para revisar si el mouse fue presionado en los renglones 19-21,
		;se revisará si fue en un boton de STOP, PAUSE o PLAY
		botones_click:
			cmp dx,19
			jge botones_click1
			jmp while_pausa
		botones_click1:
			cmp dx,21
			jbe botones_click2
			jmp while_pausa
		botones_click2:
			;Se confirma que se hizo click en los renglones de los 3 botones,
			;se buscará en sus columnas en cual botón o si fue en los espacios entre ellos
			;Se comienza verificando si fue en el boton de STOP
			cmp cx,play_izq
			jge boton_PLAY1
			jmp while_pausa
		boton_PLAY1:
			cmp cx,play_der
			jbe boton_PLAY2
			jmp while_pausa
		boton_PLAY2:
			mov [status],activo
			jmp salir_pausa
			jmp while_pausa

	teclado:
	comprueba_teclado ;macro propia que devuelve en al la tecla presionada por el teclado
	cmp al, 61h       ;comparamos la tecla presionada con "a"
	je clla
	cmp al, 64h				;;comparamos la tecla presionada con "d"
	je clld
	cmp al, 73h				;comparamos la tecla presionada con "s"
	je clls
	cmp al, 71h				;;comparamos la tecla presionada con "q"
	je cllq
	cmp al, 65h				;comparamos la tecla presionada con "e"
	je clle
	jmp comparat			;si no se presiono ninguna se salta a seguir el flujo del programa
clla:
	call IZQ					;llama a la funcion para mover la pieza a la izquierda
	jmp comparat			;sigue el flujo del programa

clld:
	call DER					;llama a la funcion para mover la pieza a la derecha
	jmp comparat			;sigue con el flujo del programa
clls:
	cmp dkb, 2h				;compara el valor de dkb con 2 para saber si lo disminuye mas o no
	jbe comparat			;si si vale 2 sige el flujo para evitar numeros negativos
	sub dkb, 2h				; si no vale 2 le resta 2 y sigue el flujo del programa
	jmp comparat
cllq:
	call GIRO_DER     ;llama a la funcion para girar a la pieza a la derecha
	jmp comparat
clle:
	call GIRO_IZQ			;llama a la funcion para girar a la pieza a la derecha
comparat:
	mov ax, 0C00h
	int 21h						;se borra el buffer del teclado para no producir movimiento fantasma y evitar errores con int 21h y ah 0Ch
tmp1:
	mov ax, 8600h     ;espera 16 ms con la int 15h y ah 86h
	mov cx, 0000h
	mov dx, [tiempo_bajada]
	int 15h
	dec dkb						;baja el valor de dbk para que la espera en total sea de 0.8 segundos para bajar la pieza si es que no se presiona s
	cmp dkb, 0				;si dkb es 0 ya se repitio la espera acumulando 0.8 segundos
	ja cmpkb					;si no se cumplio el tiempo se repite todo desde cuando revisa el estado del mouse

repite:

	pop cx						;saca cx de la pila
	dec cx						;disminuye el valor de cx
	cmp cx, 0					;compara el valor de cx con 0 para saber si ya se acabo el dezplazamiento de la pieza
	ja uptfps					;si no se ha acabado entonces repite el ciclo desde cuando se baja la pieza un pixel
	call GUARDAPIEZA  ;si ya llego al punto final la pieza se guarda el estado
	call BUSCCAM  		;se comprueba que no haya una linea completa y si la hay se elimina esto se hace 4 veces ya que como maximo se podran completar 4 lineas
	call BUSCCAM
	call BUSCCAM
	call BUSCCAM
	call REDIBUJA  		;se redibuja el cuadro de juego por si se realizo la eliminacion de alguna linea
	call BORRA_PIEZA_ACTUAL ;borra la pieza actual, cambia pieza siguente a ser la nueva pieza actual y calcula la nueva pieza siguiente
	call BORRA_NEXT  ;borra la pieza siguiente del ui e imprime la pieza que sigue
	call DIBUJA_ACTUAL ;dibuja la pieza actual en la posicion que le corresponde
	call IMPRIME_SCORES
	call PERDIO
	jmp empieza				;repite el ciclo para bajar la pieza y revisar colisiones y movimiento

salir_enter:
	mov ah,08h
	int 21h 			;int 21h opción 08h: recibe entrada de teclado sin eco y guarda en AL
	cmp al,0Dh			;compara la entrada de teclado si fue [enter]
	jnz salir_enter 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cGrisClaro,bgNegro

		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cGrisClaro,bgNegro

		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cGrisClaro,bgNegro

		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cGrisClaro,bgNegro

		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Derecho
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Interno
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cGrisClaro,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cGrisClaro,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cGrisClaro,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cGrisClaro,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],finTitulo-titulo,cBlanco,bgNegro
		call IMPRIME_TEXTOS
		call IMPRIME_BOTONES
		call IMPRIME_DATOS_INICIALES
		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "NEXT"
		posiciona_cursor next_ren,next_col
		imprime_cadena_color nextStr,finNextStr-nextStr,cGrisClaro,bgNegro

		;Imprime cadena "LEVEL"
		posiciona_cursor level_ren,level_col
		imprime_cadena_color levelStr,finlevelStr-levelStr,cGrisClaro,bgNegro

		;Imprime cadena "LINES"
		posiciona_cursor lines_ren,lines_col
		imprime_cadena_color linesStr,finLinesStr-linesStr,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,finHiscoreStr-hiscoreStr,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],stop_ren
		mov [boton_columna],stop_col
		call IMPRIME_BOTON
		;Botón PAUSE
		mov [boton_caracter],19d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],pause_ren
		mov [boton_columna],pause_col
		call IMPRIME_BOTON
		;Botón PLAY
		mov [boton_caracter],16d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],play_ren
		mov [boton_columna],play_col
		call IMPRIME_BOTON
		ret
	endp

	IMPRIME_SCORES proc
		call IMPRIME_LINES
		call IMPRIME_HISCORE
		call IMPRIME_LEVEL
		ret
	endp

	IMPRIME_LINES proc
		mov [ren_aux],lines_ren
		mov [col_aux],lines_col+20
		mov bx,[lines_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[hiscore]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_LEVEL proc
		mov [ren_aux],level_ren
		mov [col_aux],level_col+20
		mov bx,[level]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor lines_ren,lines_col+20 		;posiciona el cursor relativo a lines_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		call IMPRIME_SCORES
		call DIBUJA_NEXT
		call DIBUJA_ACTUAL
		;implementar
		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [pieza_actual],linea
		mov [pieza_next],lnormal
		mov [lines_score],0
		mov [hiscore],0
		mov [level],1
		mov [tiempo_bajada],3E80h
		mov [pieza_rens],ini_renglon
		mov [pieza_cols],ini_columna
		mov [pieza_ren],ini_renglon
		mov [pieza_col],ini_columna

		;agregar otras variables necesarias
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento IMPRIME_BOTON para el ensamblador

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Los siguientes procedimientos se utilizan para dibujar piezas y utilizan los mismos parámetros
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Como parámetros se utilizan:
	;col_aux y ren_aux: Toma como referencia los valores establecidos en ren_aux y en col_aux
	;esas coordenadas son la referencia (esquina superior izquierda) de una matriz 4x4
	;si - apuntador al arreglo de renglones en donde se van a guardar esas posiciones
	;di - apuntador al arreglo de columnas en donde se van a guardar esas posiciones
	;si y di están parametrizados porque se puede dibujar la pieza actual o la pieza next
	;Se calculan las posiciones y se almacenan en los arreglos correspondientes
	;posteriormente se llama al procedimiento DIBUJA_PIEZA que hace uso de esas posiciones para imprimir la pieza en pantalla

	;Procedimiento para dibujar una pieza de cuadro
	DIBUJA_CUADRO proc
		mov [pieza_color],cAmarillo
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de línea
	DIBUJA_LINEA proc
		mov [pieza_color],cCyanClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L
	DIBUJA_L proc
		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si],al
		mov [di],ah
		dec al
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T proc
		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec al
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de S
	DIBUJA_S proc
		mov [pieza_color],cVerdeClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		add al,2
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		dec al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de S invertida
	DIBUJA_S_INVERTIDA proc
		mov [pieza_color],cRojoClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;DIBUJA_PIEZA - procedimiento para imprimir una pieza en pantalla
	;Como parámetros recibe:
	;si - apuntador al arreglo de renglones
	;di - apuntador al arreglo de columnas
	DIBUJA_PIEZA proc
		mov cx,4
	loop_dibuja_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		imprime_caracter_color 254,[pieza_color],bgGrisOscuro
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_dibuja_pieza
		ret
	endp

	;DIBUJA_NEXT - se usa para imprimir la pieza siguiente en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza siguiente
	DIBUJA_NEXT proc
		lea di,[next_cols]
		lea si,[next_rens]
		mov [col_aux],next_col+10
		mov [ren_aux],next_ren-1
		cmp [pieza_next],cuadro
		je next_cuadro
		cmp [pieza_next],linea
		je next_linea
		cmp [pieza_next],lnormal
		je next_l
		cmp [pieza_next],linvertida
		je next_l_invertida
		cmp [pieza_next],tnormal
		je next_t
		cmp [pieza_next],snormal
		je next_s
		cmp [pieza_next],sinvertida
		je next_s_invertida
		jmp salir_dibuja_next
	next_cuadro:
		mov [pieza_next],cuadro
		mov [next_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_dibuja_next
	next_linea:
		mov [pieza_next],linea
		mov [next_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_dibuja_next
	next_l:
		mov [pieza_next],lnormal
		mov [next_color],cCafe
		call DIBUJA_L
		jmp salir_dibuja_next
	next_l_invertida:
		mov [pieza_next],linvertida
		mov [next_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_dibuja_next
	next_t:
		mov [pieza_next],tnormal
		mov [next_color],cMagenta
		call DIBUJA_T
		jmp salir_dibuja_next
	next_s:
		mov [pieza_next],snormal
		mov [next_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_dibuja_next
	next_s_invertida:
		mov [pieza_next],sinvertida
		mov [next_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
	salir_dibuja_next:
		ret
	endp
	PIEZAMBAJAV proc
		mov ah, [pieza_rens]        ; movemos a al el valor de pieza rens a al
		cmp ah, [pieza_rens+1]      ; comparamos cual es mayor
		jb chng11										; si es correcto se salta a el primer ambio
	scmp1:
		cmp ah, [pieza_rens+2]			; comparamos al ahora con el segundo dato
		jb chng12										; si es menor al  se salta a el primer cambio
	tcmp1:
		cmp ah, [pieza_rens+3]			; comparamos al con el tercer dato
		jb chng13										; si es mayor el tercer dato se salta al tercer cambio
		jmp resta										; salta resta
	chng11:
		mov ah, [pieza_rens+1]      ; en el primer cambio se mueve al con el dato mayor comparado
		jmp scmp1										; vuelve a la comparacion con el segundo dato
	chng12:
		mov ah, [pieza_rens+2]			; en el segundo cambio se mueve a al el dato mayor comparado
		jmp tcmp1										; vuelve a la comparacion del tercer dato
	chng13:
		mov ah, [pieza_rens+3]			; en el tercer cambio se mueve a al el dato mayor comparado
	resta:
		ret
	endp
	PIEZAMALTAV proc
		mov ah, [pieza_rens]        ; movemos a al el valor de pieza rens a al
		cmp ah, [pieza_rens+1]      ; comparamos cual es mayor
		ja chngalt1										; si es correcto se salta a el primer ambio
	scmpalt:
		cmp ah, [pieza_rens+2]			; comparamos al ahora con el segundo dato
		ja chngalt2									; si es mayor al  se salta a el primer cambio
	tcmpalt:
		cmp ah, [pieza_rens+3]			; comparamos al con el tercer dato
		ja chngalt3									; si es mayor el tercer dato se salta al tercer cambio
		jmp retpalta								; salta retpalta
	chngalt1:
		mov ah, [pieza_rens+1]      ; en el primer cambio se mueve al con el dato mayor comparado
		jmp scmpalt										; vuelve a la comparacion con el segundo dato
	chngalt2:
		mov ah, [pieza_rens+2]			; en el segundo cambio se mueve a al el dato mayor comparado
		jmp tcmpalt										; vuelve a la comparacion del tercer dato
	chngalt3:
		mov ah, [pieza_rens+3]			; en el tercer cambio se mueve a al el dato mayor comparado
	retpalta:
		ret
	endp
	;es lo mismo que PIEZAMBAJAH pero esta vez se usa cols para saber cual pieza es la que esta mas a la izquierda
	PIEZAMBAJAH proc
		mov al, [pieza_cols]
		cmp al, [pieza_cols+1]
		ja chng1lss
	scmplss:
		cmp al, [pieza_cols+2]
		ja chng2lss
	tcmplss:
		cmp al, [pieza_cols+3]
		ja chng3lss
		jmp mayorlss
	chng1lss:
		mov al, [pieza_cols+1]
		jmp scmplss
	chng2lss:
		mov al, [pieza_cols+2]
		jmp tcmplss
	chng3lss:
		mov al, [pieza_cols+3]
	mayorlss:
		ret
	endp
	;es lo mismo que PIEZAMBAJAV pero esta vez se usa cols para saber cual pieza es la que esta mas a la derecha
	PIEZAMALTAH proc
		mov al, [pieza_cols]
		cmp al, [pieza_cols+1]
		jb chng1
	scmp:
		cmp al, [pieza_cols+2]
		jb chng2
	tcmp:
		cmp al, [pieza_cols+3]
		jb chng3
		jmp mayor
	chng1:
		mov al, [pieza_cols+1]
		jmp scmp
	chng2:
		mov al, [pieza_cols+2]
		jmp tcmp
	chng3:
		mov al, [pieza_cols+3]
	mayor:
		ret
	endp
	;DIBUJA_ACTUAL - se usa para imprimir la pieza actual en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza actual
	DIBUJA_ACTUAL proc
		mov giro, 0
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov al,ini_columna
		mov ah,ini_renglon
		mov [col_aux],al
		mov [ren_aux],ah
		mov [pieza_col],al
		mov [pieza_ren],ah
		cmp [pieza_actual],cuadro
		je inicia_actual_cuadro
		cmp [pieza_actual],linea
		je inicia_actual_linea
		cmp [pieza_actual],lnormal
		je inicia_actual_l
		cmp [pieza_actual],linvertida
		je inicia_actual_l_invertida
		cmp [pieza_actual],tnormal
		je inicia_actual_t
		cmp [pieza_actual],snormal
		je inicia_actual_s
		cmp [pieza_actual],sinvertida
		je inicia_actual_s_invertida
	inicia_actual_cuadro:
		mov [actual_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_inicia_actual
	inicia_actual_linea:
		mov [actual_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_inicia_actual
	inicia_actual_l:
		mov [actual_color],cCafe
		call DIBUJA_L
		jmp salir_inicia_actual
	inicia_actual_t:
		mov [actual_color],cMagenta
		call DIBUJA_T
		jmp salir_inicia_actual
	inicia_actual_s:
		mov [actual_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_inicia_actual
	inicia_actual_s_invertida:
		mov [actual_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
		jmp salir_inicia_actual
	inicia_actual_l_invertida:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_inicia_actual
	salir_inicia_actual:
		ret
	endp
	;dibuja la pieza actual una pieza abajo
DIBUJA_UPDT proc
		lea di,[pieza_cols]
		lea si,[pieza_rens]		;se guardan las direcciones de las posiciones de las columnas y renglones en si y di
		call BORRA_PIEZA      ;se borra la pieza con la funcion borra piez
		lea di,[pieza_cols]
		lea si,[pieza_rens]		;se guardan las direcciones de las posiciones de las columnas y renglones en si y di otra vez para dibujar nuevamente la pieza en la nueva posicion
		inc [pieza_ren]
		inc [pieza_rens]      ;se aumenta la parte de pieza rens que indica el renglon en el que se encuentran las piezas
		inc [pieza_rens+1]
		inc [pieza_rens+2]
		inc [pieza_rens+3]
		call DIBUJA_PIEZA			;se llama a la funcion que dibuja la pieza para que asi se dibuje en la nueva posicion
		ret
	endp


	BORRA_PIEZA_ACTUAL proc
		mov [pieza_ren], ini_renglon	;mueve las posiciones de todos los apuntadores al inicio
		mov [pieza_col], ini_columna
		mov [pieza_rens], ini_renglon
		mov [pieza_cols], ini_columna
		call RANDX1										;se llama a esta funcion que calcula el valor de la pieza siguiente de forma aleatorea
		ret
	endp
	RANDX1 proc
		mov ah, 00h
		int 1Ah
		mov ax, dx
		xor dx, dx
		mov cx, 10
		div cx
		;obtiene un numero al azar del 1 al 10
		cmp dx, 6  ;compara el resultado y si es mayor de 6 (num piezas totales) le resta 5 para que asi solo los numeros aletorios sean del 0 al 6
		jbe rndx1f ;si no es mayor a 6 continua el procesos
		sub dx, 5

	rndx1f:
		mov al, [pieza_next] 			;movemos la pieza siguiente a la pieza actual con ayuda de al
		mov [pieza_actual], al
		mov [pieza_next], dl			;movemos la pieza obtenida con el rand a pieza next
		ret
	endp
	BORRA_NEXT proc
		lea si,[next_rens]				;guarda las direcciones de memoria de las columnas y los renglones en si y di
		lea di,[next_cols]
		call BORRA_PIEZA					;las piezas se pintan de negro para que no se no	te el cambio
		call DIBUJA_NEXT					;dibuja la nueva pieza next
		ret
	endp
; un copia y pega del dibuja pieza pero ahora la pinta de color negro completamente
	BORRA_PIEZA proc
		mov cx,4
	loop_borra_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		imprime_caracter_color 254,cNegro,bgNegro
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_borra_pieza
		ret
	endp
	;supervisa todo lo relacionado a las vueltas
	REVISAG proc
			call PIEZAMBAJAV
			mov [ren_aux], ah
			call PIEZAMBAJAH
			mov [aux1], al
			call PIEZAMALTAH
			mov [aux2], al
			;se guardan las posiciones mas bajas y a la izquiera o derecha segun sea el caso que se requiera
			lea si,[pieza_rens]
			lea di,[pieza_cols]
			call BORRA_PIEZA
			;se borra la pieza en la posicion en la que estaba con borra pieza
		revisa:
			call PIEZAMBAJAV
			mov al , ah
			call PIEZAMALTAV
			sub al, ah
			;se busca las nuevas partes mas altas y mas bajas de la pieza y se restan
			cmp al, 1
			je ccresta
			;para el caso 1 cuando la resta entre los dos datos es igual a uno significa que la altura de esta pieza es de 2 y
			; para invertirlo solo tenemos que invertir la pieza y girar los ejes
			cmp al, 2
			je ccsuma
			;para el caso 1 cuando la resta entre los dos datos es igual a dos significa que la altura de esta pieza es de 3 y
			; para invertirlo solo tenemos que invertir la pieza y girar los ejes
			jmp sologira
			;en esta parte se busca las partes de la pieza mas bajas y se les resta 2 para que esten de forma inversa
		ccresta:
			mov al, ah
			call PIEZAMBAJAV
			cmp ah, [pieza_rens]
			je cresta1
		sigue1:
			cmp ah, [pieza_rens+1]
			je cresta2
		sigue2:
			cmp ah, [pieza_rens+2]
			je cresta3
		sigue3:
			cmp ah, [pieza_rens+3]
			je cresta4
			jmp sologira
		cresta1:
			dec [pieza_rens]
			dec [pieza_rens]
			jmp sigue1
		cresta2:
			dec [pieza_rens+1]
			dec [pieza_rens+1]
			jmp sigue2
		cresta3:
			dec [pieza_rens+2]
			dec [pieza_rens+2]
			jmp sigue3
		cresta4:
			dec [pieza_rens+3]
			dec [pieza_rens+3]
			jmp sologira
			;en esta parte se busca las partes de la pieza mas bajas y mas altas que se encuentren y se les resta o suman 2 unidades para que esten de forma inversa
		ccsuma:
			mov al, ah
			call PIEZAMBAJAV
			cmp ah, [pieza_rens]
			je ccresta1
			cmp al, [pieza_rens]
			je ccsuma1
		siguer1:
			cmp ah, [pieza_rens+1]
			je ccresta2
			cmp al, [pieza_rens+1]
			je ccsuma2
		siguer2:
			cmp ah, [pieza_rens+2]
			je ccresta3
			cmp al, [pieza_rens+2]
			je ccsuma3
		siguer3:
			cmp ah, [pieza_rens+3]
			je ccresta4
			cmp al, [pieza_rens+3]
			je ccsuma4
			jmp sologira
		ccresta1:
			dec [pieza_rens]
			dec [pieza_rens]
			jmp siguer1
		ccresta2:
			dec [pieza_rens+1]
			dec [pieza_rens+1]
			jmp siguer2
		ccresta3:
			dec [pieza_rens+2]
			dec [pieza_rens+2]
			jmp siguer3
		ccresta4:
			dec [pieza_rens+3]
			dec [pieza_rens+3]
			jmp sologira
		ccsuma1:
			inc [pieza_rens]
			inc [pieza_rens]
			jmp siguer1
		ccsuma2:
			inc [pieza_rens+1]
			inc [pieza_rens+1]
			jmp siguer2
		ccsuma3:
			inc [pieza_rens+2]
			inc [pieza_rens+2]
			jmp siguer3
		ccsuma4:
			inc [pieza_rens+3]
			inc [pieza_rens+3]
			jmp sologira
	sologira:
			;para volver a girar la pieza y esta vez en la posicion correcta se gira cambiando los ejes de orden (cols pasa a ser rens y rens pasa a ser cols)
			mov al, [pieza_cols+3]
			mov ah, [pieza_rens+3]
			mov [pieza_cols+3], ah
			mov [pieza_rens+3], al
			mov al, [pieza_cols+2]
			mov ah, [pieza_rens+2]
			mov [pieza_cols+2], ah
			mov [pieza_rens+2], al
			mov al, [pieza_cols+1]
			mov ah, [pieza_rens+1]
			mov [pieza_cols+1], ah
			mov [pieza_rens+1], al
			mov al, [pieza_cols]
			mov ah, [pieza_rens]
			mov [pieza_cols], ah
			mov [pieza_rens], al
			;en esta parte se compara el tipo de giro ya que si es un giro normal solo se gira una vez
			;pero si es un giro inverso se dan otros 3 giros siguiendo el mismo procedimiento
			dec giro
			cmp giro, 0
			ja revisa
		trevisa:
			; en esta parte se reacomoda todas las piezas en su posicion original para asi evitar problemas debido al cambio de eje

			call PIEZAMBAJAV
			sub [pieza_rens], ah
			sub [pieza_rens+1], ah
			sub [pieza_rens+2], ah
			sub [pieza_rens+3], ah
			mov ah, [ren_aux]
			add [pieza_rens], ah
			add [pieza_rens+1], ah
			add [pieza_rens+2], ah
			add [pieza_rens+3], ah

			;aqui revisa que se usara para la pieza mas baja y mas alta para evitar que se salgan del espacio de juego al momento de girar
			call PIEZAMBAJAH
			cmp al, 12
			jb rstpos1
			; si esta mas pegada a la izquiera se hace el procedimiento de rstpos1
			cmp al, 12
			ja rstpos11
			; si esta mas pegada a la izquiera se hace el procedimiento de rstpos11
			cmp al, [pieza_col]
			je revisafn
		rstpos1:
			call PIEZAMALTAH
			sub [pieza_cols], al
			sub [pieza_cols+1], al
			sub [pieza_cols+2], al
			sub [pieza_cols+3], al
			mov al, [aux2]
			add [pieza_cols], al
			add [pieza_cols+1], al
			add [pieza_cols+2], al
			add [pieza_cols+3], al
			call PIEZAMBAJAH
			cmp al, 1
			jae revisafn
			;aqui la dibuja se redibuja dentro de los limites de juego
			inc [pieza_cols]
			inc [pieza_cols+1]
			inc [pieza_cols+2]
			inc [pieza_cols+3]
			;si se pasa por una pieza esta se recorre hacia la derecha
			call PIEZAMBAJAH
			cmp al, 1
			jae revisafn

			inc [pieza_cols]
			inc [pieza_cols+1]
			inc [pieza_cols+2]
			inc [pieza_cols+3]
		rstpos11:
			call PIEZAMBAJAH
			;aqui la dibuja se redibuja dentro de los limites de juego
			sub [pieza_cols], al
			sub [pieza_cols+1], al
			sub [pieza_cols+2], al
			sub [pieza_cols+3], al
			mov al, [aux1]
			add [pieza_cols], al
			add [pieza_cols+1], al
			add [pieza_cols+2], al
			add [pieza_cols+3], al
			call PIEZAMALTAH
			;si se pasa por una pieza esta se recorre hacia la derecha
			cmp al, 30
			jbe revisafn
			dec [pieza_cols]
			dec [pieza_cols+1]
			dec [pieza_cols+2]
			dec [pieza_cols+3]

		revisafn:
			;como ultimo paso se compara si es que no existe alguna colision entre las piezas puestas
			call BUSCACOL
			cmp bx, 0
			je revisafns
			;si se encuantra una colision en un giro normal pieza se realiza un giro inverso para volver a la misma posicion y viceversa
			cmp giro_aux, 1
			je regresa1
			cmp giro_aux, 3
			je regresa2
		revisafns:
		;redibuja todo por si en la colision se tocaron las piezas
			call REDIBUJA
			lea si,[pieza_rens]
			lea di,[pieza_cols]
		;dibuja la pieza movida o en su misma posicion segun sea el caso
			call DIBUJA_PIEZA
			mov ax, 0
			ret
			;funciones para realizar el giro inverso
		regresa1:
			call GIRO_IZQ
			ret
		regresa2:
			call GIRO_DER
			ret
	endp

	GIRO_DER proc
		;implementar

		mov giro, 1
		mov giro_aux, 1 ;mueve al auxiliar y a giro normal el tipo de giro realizado
		call REVISAG
		ret
	endp

	GIRO_IZQ proc
		;implementar
		mov giro, 3
		mov giro_aux,3	;mueve al auxiliar y a giro normal el tipo de giro realizado
		call REVISAG
		ret
	endp

	;funcion mover a la derecha
	DER proc
		call PIEZAMALTAH
		mov ah, 30
		cmp al, ah			;comprueba que no este cerca de los limites del juego
		je salir_inicia_der
		call BUSCADER				;comprueba que no haya una pieza a la derecha con la cual colisionar
		cmp bx, 1
		je salir_inicia_der
		;se borra la pieza en la posicion que tenia
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		call BORRA_PIEZA
		;se dibuja nuevamente pero ahora movida a la derecha
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		inc [pieza_col]
		inc [pieza_cols]
		inc [pieza_cols+1]
		inc [pieza_cols+2]
		inc [pieza_cols+3]
		call DIBUJA_PIEZA
	salir_inicia_der:
		ret
	endp

	IZQ proc

		push ax
		call PIEZAMBAJAH
		;comprueba que no este cerca de los limites del juego
		mov ah, 1
		cmp al, ah
		pop ax
		je salir_inicia_izq
		call BUSCAIZQ
		;comprueba que no haya una pieza a la derecha con la cual colisionar
		cmp bx, 1
		je salir_inicia_izq
		;se borra la pieza en la posicion que tenia
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		call BORRA_PIEZA
		;se dibuja nuevamente pero ahora movida a la derecha
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		dec [pieza_col]
		dec [pieza_cols]
		dec [pieza_cols+1]
		dec [pieza_cols+2]
		dec [pieza_cols+3]
		call DIBUJA_PIEZA
	salir_inicia_izq:
		ret
	endp
	GUARDAPIEZA proc
		mov bl, [pieza_rens]
		mov bh, [pieza_cols]
		call GUARDAPOS
		mov bl, [pieza_rens+1]
		mov bh,[pieza_cols+1]
		call GUARDAPOS
		mov bl, [pieza_rens+2]
		mov bh,[pieza_cols+2]
		call GUARDAPOS
		mov bl, [pieza_rens+3]
		mov bh,[pieza_cols+3]
		call GUARDAPOS
		ret
	endp
	GUARDAPOS proc
		push cx
		mov al, bl
		mul [doscuatro]
		mov bl, bh
		mov bh,0
		add ax, bx
		mov si, ax
		dec si
		cmp si, 02D0h
		ja salir_guardar
		mov [matriz_pos1+si], 1
		mov ch, 0
		mov	cl, actual_color
		mov [matriz_col1+si], cl
		pop cx
		jmp salir_guardar
		salir_guardar:
		ret
	endp
	BUSCAPOS proc
		mov al, bl
		mul [doscuatro]
		mov bl, bh
		mov bh,0
		add ax, bx
		mov [auxw], ax
		mov si, ax
		dec si
		cmp si, 02D0h
		jae salcero
		cmp [matriz_pos1+si], 1
		je saluno
		jmp salcero
	salcero:
		mov bx, 0
		ret
	saluno:
		mov bx, 1
		ret
	endp
	BUSCAABAJO proc
		mov bl, [pieza_rens]
		mov bh, [pieza_cols]
		inc bl
		call BUSCAPOS
		cmp bx, 1
		je termina_ciclo
		mov bl, [pieza_rens+1]
		mov bh,[pieza_cols+1]
		inc bl
		call BUSCAPOS
		cmp bx, 1
		je termina_ciclo
		mov bl, [pieza_rens+2]
		mov bh,[pieza_cols+2]
		inc bl
		call BUSCAPOS
		cmp bx, 1
		je termina_ciclo
		mov bl, [pieza_rens+3]
		mov bh,[pieza_cols+3]
		inc bl
		call BUSCAPOS
		cmp bx, 1
		je termina_ciclo
		termina_ciclo:
		ret
	endp
	BUSCAIZQ proc
		mov bl, [pieza_rens]
		mov bh, [pieza_cols]
		dec bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bizq
		mov bl, [pieza_rens+1]
		mov bh,[pieza_cols+1]
		dec bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bizq
		mov bl, [pieza_rens+2]
		mov bh,[pieza_cols+2]
		dec bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bizq
		mov bl, [pieza_rens+3]
		mov bh,[pieza_cols+3]
		dec bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bizq
		termina_bizq:
		ret
	endp
	BUSCADER proc
		mov bl, [pieza_rens]
		mov bh, [pieza_cols]
		inc bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bder
		mov bl, [pieza_rens+1]
		mov bh,[pieza_cols+1]
		inc bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bder
		mov bl, [pieza_rens+2]
		mov bh,[pieza_cols+2]
		inc bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bder
		mov bl, [pieza_rens+3]
		mov bh,[pieza_cols+3]
		inc bh
		call BUSCAPOS
		cmp bx, 1
		je termina_bder
		termina_bder:
		ret
	endp
	BUSCACOL proc
		mov bl, [pieza_rens]
		mov bh, [pieza_cols]
		call BUSCAPOS
		cmp bx, 1
		je termina_bsq
		mov bl, [pieza_rens+1]
		mov bh,[pieza_cols+1]
		call BUSCAPOS
		cmp bx, 1
		je termina_bsq
		mov bl, [pieza_rens+2]
		mov bh,[pieza_cols+2]
		call BUSCAPOS
		cmp bx, 1
		je termina_bsq
		mov bl, [pieza_rens+3]
		mov bh,[pieza_cols+3]
		call BUSCAPOS
		cmp bx, 1
		je termina_ciclo
		termina_bsq:
		ret
	endp
	ELIMINA proc
		push cx
		dec di
		mov si, di
		sub si, 1Eh
		m1:
		mov cl,[matriz_pos1+si]
		mov [matriz_pos1+di], cl
		mov cl, [matriz_col1+si]
		mov [matriz_col1+di], cl
		cmp si, 0
		jbe borrault
		dec si
		dec di
		jmp m1
		borrault:
		dec di
		mov [matriz_pos1+di],0
		mov [matriz_col1+di],0
		cmp di, 0
		jbe salp
		jmp borrault
		salp:
		pop cx
		ret
	endp
	BUSCCAM proc
		mov di, 02D0h
		mov bl, 23
		mov bh, 1
		push cx
		push ax
		mov ax,0
		mov cx, 30
		jmp ncol
		nren:
		mov cx, 30
		cmp ax, 30
		je borraren
		regmas:
		dec bl
		sub di, 1Eh
		mov ax, 0
		cmp bl, 0
		je fbuscam
		mov bh, 1
		ncol:
		mov [aux1], bl
		mov [aux2], bh
		push ax
		call BUSCAPOS
		pop ax
		cmp bx, 1
		je incax
		jmp cont
		incax:
		inc ax
		cont:
		mov bl, [aux1]
		mov bh, [aux2]
		inc bh
		dec cx
		cmp cx, 0
		je nren
		jmp ncol
		borraren:
		call ELIMINA
		pop ax
		pop cx
		inc [lines_score]
		add [hiscore],10
		call SUBIR_NIVEL
		ret
		fbuscam:
		pop ax
		pop cx
		ret
	endp
	REDIBUJA proc
		mov bl, 23
		mov bh, 1
		push cx
		mov cx, 30
		jmp rdcol
		rdren:
		mov cx, 30
		dec bl
		add di, 30
		cmp bl, 0
		je rdfbuscam
		mov bh, 1
		rdcol:
		mov [aux1], bl
		mov [aux2], bh
		call BUSCAPOS
		cmp bx, 1
		je dibujapunt
		jmp sigupos
		dibujapunt:
		mov bl, [aux1]
		mov bh, [aux2]
		push cx
		push bx
		mov si, [auxw]
		dec si
		posiciona_cursor bl,bh
		imprime_caracter_color 254,[matriz_col1+si],bgGrisOscuro
		pop bx
		pop cx
		lea si, [aux1]
		lea di,	[aux2]
		jmp dibujocolor
		sigupos:
		mov bl, [aux1]
		mov bh, [aux2]
		push cx
		push bx
		posiciona_cursor bl,bh
		imprime_caracter_color 254,cNegro,bgNegro
		pop bx
		pop cx
		mov [aux1], bl
		mov [aux2], bh
		lea si, [aux1]
		lea di,	[aux2]
		dibujocolor:
		inc bh
		dec cx
		cmp cx, 0
		je rdren
		jmp rdcol
		rdfbuscam:
		pop cx
		ret
	endp
	SUBIR_NIVEL proc
		push ax
		mov ax,[hiscore]
		cmp ax,10
		je salir_subir
		div div20
		cmp ah,0
		je subir_nivel_et
		jmp salir_subir
		subir_nivel_et:
			inc [level]
			disminute_tiempo:
			sub [tiempo_dkb],10
		salir_subir:
		pop ax
		ret
	endp
	VACIAR_COORDENADAS proc
		push cx
		push si
		mov cx,720
		mov si,0
		for_vaciar:
			mov [matriz_pos1+si],0
			mov [matriz_col1+si],0
			inc si
			loop for_vaciar
		pop si
		pop cx
		ret
	endp
	PERDIO proc
		call BUSCAABAJO
		cmp bx,1
		je boton_stop31
		ret
	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa
