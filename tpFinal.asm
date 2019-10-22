                                         ;/*** TP Organización del computador 2019 1er CUATRIMESTRE ***/ 
                      ;/*** Torres Pablo (42099772/2018), Maza Thomas (42370811/2018), Montenegro Tomas (41874099/2018) ***/ 
org 100h
      
jmp inicio 
;consigna inicial
consigna db 10,13,"                         BIENVENIDO",10,13,10,13,"   RESPONDA A LAS SIGUIENTES PREGUNTAS SELECCIONANDO CON",10,13," LA TECLA 'ENTER' A LAS LETRAS QUE CONFORMAN A SU RESPUESTA.",10,13,"   PARA CONFIRMAR SU RESPUESTA, PRESIONE LA TECLA 'TAB'.",10,13,10,13,"  RECUERDE QUE SOLO PUEDE EQUIVOCARSE 2 VECES POR PREGUNTA",10,13,"                     DISFRUTE DEL JUEGO",10,13,"$"

;definicion de las dimensiones del tablero
ancho db 15; ancho del tablero en cantidad de caracteres
alto db 20; alto del tablero en cantidad de caracteres 

;posiciones iniciales del tablero y cursor
posX db 62                                         
posY db 3                                          

;juego
respuesta_Usuario db 11 dup (?);almacena la palabra que va formando el usuario 
espacio7 db 100 dup (0) 
largo_Respuesta_Usuario db 0
largo_Respuesta db 0
incorrecto db "INCORRECTA!!  -8$" 
espacio3 db 100 dup (0)
correcto db "CORRECTA!!  +10$"
espacio4 db 100 dup (0)
mensaje_Ganador db "                 GANASTE!!!$"
espacio5 db 100 dup (0)
mensaje_Perdedor db "                PERDISTE!!!$"       
espacio6 db 100 dup (0)
puntaje_Total db "PUNTAJE TOTAL: $"
indice dw 0;de ayuda para comprobar si el usuario ha respondido a todas las preguntas
intentos db 2;cantidad de intentos que tiene el usuario para contestar una pregunta 
puntos db ?;cantidad de puntos del usuario  
puntaje_Ascii db equ 4;puntaje del usuario en ascii   

;etiquetas auxiliares 
auxiliar_Fila db 10  
auxiliar_Columna db 12 

;lectura de los archivos .txt
path_Preguntas db "C:\emu8086\vdrive\tpFinal\tpPreguntas.txt"  
preguntas db 1000 dup (0)   
espacio0 db 100 dup (0)  
path_Respuestas db "C:\emu8086\vdrive\tpFinal\tpRespuestas.txt"   
espacio1 db 100 dup (0)
respuestas db 500 dup (0) 
 
espacio2 db 100 dup (0)
handle_Preguntas dw ?   
handle_Respuestas dw ?

;tablero
vector_Letras_Random db 300 dup (?)	
tamanio_Vector_Letras_Random dw 300	
nueva_Linea db 10,13,'$';enter para imprimir el tablero correctamente
cantidad_Letras db 26;divisor de las letras random
tablero     db "XXXxXXXXXXXXXXX"
            db "XXXxXXXXXXXXXXX"
            db "XXXxXxxxXXXXXxx"
            db "XXXXXXXXXXXxXXX"
            db "XXXXXXXXXXXxXXX"
            db "XXXXXXXXXXXxXXX"
            db "XXXXXXXXXXXxXXX"
            db "XXXXxxxxxxxxxxx"
            db "xXXXXXXXXXXXXXX"
            db "xXXXXXXXXXXXXXX"
            db "xXXXXXXXXXXXXXX" 
            db "xXXXXXXXXXXXXXX"
            db "XXxxxxxXXXXXxxx"
            db "XXXXXXXXXXXXXXX"
            db "XXXXXxXXXXXXXXX"
            db "XXXXxXXXXXXXXXX"
            db "XXXxXXXXXXXXXXX"
            db "XXxXXXXXXXXXXXX"
            db "XxXXXXXXXXXXXXX"
            db "xXXXxxxxxxxxxxX",'$'  
;************************************************************************************;
inicio:;main 
call leer_Archivos
call imprimir    
call interaccion_Usuario
call imprimir_Puntaje  

ret  
;************************************************************************************;
limpiar proc;limpia a los registros
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx
xor bp, bp
xor si, si 
xor di, di

ret
endp limpiar
;************************************************************************************;  
proc leer_Archivos;lee archivos txt de preguntas y respuestas
call leer_Preguntas  
call leer_Respuestas     

ret
leer_Archivos endp        
;************************************************************************************;  
proc leer_Preguntas;lee el txt de preguntas y lo almacena en un vector
call limpiar
lea dx, path_Preguntas
mov ah, 0x3d;abre archivo txt
int 21h
jc error
mov handle_Preguntas, ax
mov ax,0
lea dx, preguntas 

leer:
mov ah, 0x3f;lee archivo txt
mov cx,1
mov bx, handle_Preguntas        
int 21h
jc error
cmp ax, 0
jz cerrar
inc dx
jmp leer

cerrar:
mov ah, 0x3e;cierra archivo txt
mov bx, handle_Preguntas
int 0x21

error:
ret
endp leer_Preguntas  
;************************************************************************************;
proc leer_Respuestas;lee el txt de respuestas y lo almacena en un vector 
call limpiar
lea dx, path_Respuestas
mov ah, 0x3d;abre archivo txt
int 21h
jc error_En_Archivo
mov handle_Respuestas, ax
mov ax,0
lea dx, respuestas 

leer_Archivo:
mov ah, 0x3f;lee archivo txt
mov cx,1
mov bx, handle_Respuestas        
int 21h
jc cerrar_Archivo
cmp ax, 0
jz cerrar
inc dx
jmp leer_Archivo

cerrar_Archivo:
mov ah, 0x3e;cierra archivo txt
mov bx, handle_Respuestas
int 0x21

error_En_Archivo:
ret
endp leer_Respuestas   
;************************************************************************************;
imprimir proc;imprime a la consigna, a las preguntas y al tablero
call imprimir_Consigna   
call imprimir_Preguntas 
call imprimir_Tablero         
ret
imprimir endp   
;************************************************************************************;
imprimir_Consigna proc;imprime a la consigna
mov al, 03h
mov ah, 0;establece al modo de video en modo texto
int 10h 
lea bx, consigna       

seguir_Imprimiendo_Consigna:
mov dl,[bx]
inc bx
mov ah,2;imprime por caracter en dl
int 21h
cmp [bx], "$"
jne seguir_Imprimiendo_Consigna

ret
imprimir_Consigna endp        
;************************************************************************************;
imprimir_Preguntas proc;imprime a lo leido del txt preguntas    
lea si,preguntas
mov dh,10;fila 
mov dl,0;columna
mov bh,0;pagina

guardar_Letra:          
inc dl
mov bl,dl
    
mov ah,2;muevo la posicion del cursor
int 10h  

mov dl,bl

mov cx,[si]
cmp cl, 0xD
je es_Salto
jne imprimir_Caracter

es_Salto:;si es un salto, aumento a la fila y vuelvo a la 
         ;primer columna 
inc dh
mov dl, 0 

add si, 2 
jmp guardar_Letra

imprimir_Caracter:
mov dl,cl;en dl el caracter a imprimir        
inc si

cmp cl, "$"
je fin

mov ah,2;imprime por caracter en dl
int 21h  

mov dl, bl
cmp cl, "$"
jne guardar_Letra

fin: 
ret
endp imprimir_Preguntas 
;************************************************************************************;
imprimir_Tablero proc;imprime a los caracteres en el tablero matriz base
mov alto, 0x14   
lea bp, respuestas
lea si,vector_Letras_Random 
nueva_Fila:
mov ancho, 0xF
generar_Letras:
mov ah, 2ch;captura el tiempo
int 21h
xor ah, ah
mov al, dl
cmp [si], al
je generar_Letras
inc si
div [cantidad_Letras]
add ah,41h;transformo al numero en ascii
mov vector_Letras_Random[di], ah 
;comparo cual caracter debe ir, si el de respuestas
;o si debe ir uno del vector de letras random
cmp tablero[di],"X" 
je imprimir_Letra_Random
jne imprimir_Letra_Respuestas

imprimir_Letra_Random:          
mov dl, vector_Letras_Random[di]
inc di
jmp restar_Letra_Impresa

imprimir_Letra_Respuestas:
cmp [bp],13
je evitar_Salto
jne no_Salto

evitar_Salto:
add bp,2 
    
no_Salto:    
mov dl, [bp]   
inc bp
inc di

restar_Letra_Impresa:     
dec tamanio_Vector_Letras_Random    
push dx

mov dh, [posY]
mov dl, [posX]
mov ah,2;muevo la posicion del cursor
int 10h

inc [posX]

pop dx
mov ah, 02;imprime por caracter en dl
int 21h 

dec ancho;cuento la cantidad de caracteres por fila
cmp ancho,0
jne generar_Letras

mov [posX], 62 
inc [posY] 
lea dx, nueva_Linea
mov ah, 09h;imprime cadena terminada en $
int 21h
dec alto;bajo una fila
cmp alto, 0
jne nueva_Fila
mov [posY],3

ret
endp imprimir_Tablero          
;************************************************************************************;
interaccion_Usuario proc;registra la interaccion el usuario con el teclado y el juego
mov dh,auxiliar_Fila 
mov dl,58
mov bh,0;pagina
mov ah,2;muevo la posicion del cursor
int 10h 

mov dl,"<" 
mov ah, 2;imprime por caracter en dl
int 21h
inc auxiliar_Fila

mov dh, posY
mov dl, posx
mov bh, 0    
xor si, si

cursor:
mov ah, 2;muevo la posicion del cursor
int 10h 

mov ah,07h;almacena en AL la tecla presionada   
int 21h  
;comparo si la tecla presionada es w,a,s,d,ENTER,TAB.
;Si no es ninguna de estas, vuelvo a cursor.
cmp al,0x77
je mover_arriba

cmp al,0x73
je mover_abajo

cmp al,0x61
je mover_izquierda

cmp al,0x64
je mover_derecha                           

cmp al, 0xD
je guardar_Caracter  

cmp al,0x9
je salto
jne cursor
;Segun la tecla que fue presionada, aumento a 
;la posicion X o Y del cursor hacia una direccion  
mover_arriba:
cmp dh, 3
je cursor
sub dh,1 
jmp cursor  
    
mover_abajo: 
cmp dh, 22
je cursor
add dh,1 
jmp cursor           

mover_izquierda:  
cmp dl, 62
je cursor
sub dl,1 
jmp cursor

mover_derecha:
cmp dl, 76
je cursor
add dl,1 
jmp cursor
;si apreto enter, guardo la letra en un vector
guardar_Caracter: 
push dx 
mov bh,0
mov ah,0x8;almacena en AL el caracter de la posicion del cursor
int 0x10
mov respuesta_Usuario[si], al
inc si  

mov dh,23;fila 
mov dl,auxiliar_Columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h
inc auxiliar_Columna

mov dl, al
mov ah, 2;imprime por caracter en dl
int 21h  
pop dx
jmp cursor  
;cuando apreta tab, agrego un "$" a la respuesta
salto:
push dx      
mov auxiliar_Columna, 12 
mov respuesta_Usuario[si],"$"  
inc si  

xor dx,dx
xor di,di
xor si,si

mov dh,23;fila 
mov dl,25;auxiliar_Columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h
;comienzo a medir los largos de las respuestas
lea di, respuesta_Usuario  
mov bp, [indice]

medir_Largo_Usuario:;mide al largo de la respuesta del usuario
cmp [di],"$"
je medir_Largo_Respuesta
inc largo_Respuesta_Usuario 
inc di
jmp medir_Largo_Usuario  

medir_Largo_Respuesta:;mide al largo de la respuesta verdadera  
cmp respuestas[bp],13
je comparar_Largos
inc largo_Respuesta 
inc bp
jmp medir_Largo_Respuesta 

comparar_Largos:
mov ah,largo_Respuesta_Usuario
cmp ah,largo_Respuesta
je posiblemente_Correcta
jg resultado_Incorrecto
jb resultado_Incorrecto

posiblemente_Correcta:;las respuestas tienen el mismo largo
xor cx,cx
mov cl,largo_Respuesta_Usuario
mov bp, [indice] 
lea di, respuesta_Usuario  
jmp comparar

comparar:;compara a las respuestas posiblemente correctas
mov ah, respuestas[bp] 
cmp [di],ah 
jne resultado_Incorrecto
inc di
inc bp
cmp respuestas[bp],0xD
je  resultado_Correcto 
loop comparar

resultado_Correcto:  
mov intentos, 2      
add puntos, 10
mov indice, bp
xor di,di
add indice, 2

imprimir_Mensaje_Correcto:
mov dl, correcto[di] 
cmp dl,"$"
je agregar_Apuntador
inc di
mov ah, 2;imprime por caracter en dl
int 21h
jmp imprimir_Mensaje_Correcto

resultado_Incorrecto:
dec intentos          
sub puntos, 8
xor di,di 

imprimir_Mensaje_Incorrecto: 
mov dl, incorrecto[di]  
cmp dl,"$"  
je limpiar_Respuesta
inc di
mov ah, 2;imprime por caracter en dl
int 21h
jmp imprimir_Mensaje_Incorrecto                             

;comparo si las preguntas son de 2 renglones o de 1
agregar_Apuntador:
cmp auxiliar_Fila, 12
je mover_2_Filas
cmp auxiliar_Fila, 15
je mover_2_Filas  
cmp auxiliar_Fila, 22
je limpiar_Respuesta
jmp imprimir_Apuntador
;si lo es, salto 2 filas
mover_2_Filas:
inc auxiliar_Fila 

imprimir_Apuntador:;apunta a la pregunta a responder 
mov dh,auxiliar_Fila 
mov dl,58;columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h 

mov dl,"<" 
mov ah, 2;imprime por caracter en dl
int 21h 
inc auxiliar_Fila 

limpiar_Respuesta:;limpia la respuesta del usuario
mov dh,23;fila 
mov dl,12;columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h
xor di,di 
mov cx,32

vaciar_Respuesta_Anterior:;limpia la respuesta del usuario
mov dl," "
mov ah,2;imprime por caracter en dl
int 21h
loop vaciar_Respuesta_Anterior 

;reinicio todo
mov largo_Respuesta_Usuario,0
mov largo_Respuesta,0                            
pop dx 
;comparo si se quedo sin intentos
cmp intentos,0
je call imprimir_Mensaje_Perdedor  
je fin_Del_Juego       
;si respondio a todas las preguntas, gana
cmp [indice],71
je usuario_Gana
jmp cursor;si no paso nada de aquello, sigue jugando 

usuario_Gana:
call imprimir_Mensaje_Ganador  

fin_Del_Juego:
ret
interaccion_Usuario endp        
;************************************************************************************;
imprimir_Mensaje_Ganador proc;imprime al mensaje ganador
mov dh,23;fila 
mov dl,0;columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h      

lea bx, mensaje_Ganador   

imprimir_Ganador:
mov dl,[bx]
mov ah,2;imprime por caracter en dl
int 21h
inc bx
cmp [bx], "$"
jne imprimir_Ganador 
ret 
imprimir_Mensaje_Ganador endp  
;************************************************************************************;
imprimir_Mensaje_Perdedor proc;imprime al mensaje perdedor
mov dh,23;fila 
mov dl,0;columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor 
int 10h   

lea bx, mensaje_Perdedor   

imprimir_Perdedor:
mov dl,[bx]
mov ah,2;imprime por caracter en dl
int 21h
inc bx
cmp [bx], "$"
jne imprimir_Perdedor 
ret 
imprimir_Mensaje_Perdedor endp
;************************************************************************************;
imprimir_Puntaje proc;pasa el puntaje a ascci y lo imprime
call limpiar     
mov dh,23;fila 
mov dl,30;auxiliar_Columna
mov bh,0;pagina
mov ah,2;mueve la posicion del cursor
int 10h    

lea bx, puntaje_Total

imprimir_Puntaje_Final:
mov dl,[bx]
mov ah,2;imprime por caracter en dl 
int 21h 
inc bx
cmp [bx], "$"
jne imprimir_Puntaje_Final 

call limpiar;limpio los registros 

cmp puntos,0
jl cambiar_Signo;puntos negativos, necesita transformar
jge pasar_Ascii_Positivo;puntos positivos

cambiar_Signo:
;imprime el "-"
mov dl,0xF0
mov ah,2;imprime por caracter en dl
int 21h
;pasa al numero negativo a positivo para poder 
;realizar los calculos necesarios
mov al, puntos
mov cl, al
mov bl,-2
mul bl 
add al,cl
mov dl, al;ya tengo el numero original en positivo 

xor ah,ah 
xor bx,bx
jmp pasar_Ascii_Negativo

pasar_Ascii_Positivo:
mov dl, [puntos]
mov al, [puntos]
pasar_Ascii_Negativo:
mov cl, 100
call pasar_Puntaje_Ascii
    
ret
imprimir_Puntaje endp    
;************************************************************************************;
pasar_Puntaje_Ascii proc;pasa de decimales a ascii
separar_Cifras:       
div cl;saco centena
mov puntaje_Ascii[si], al
inc si
cmp si, 0x3 
je comenzar_Transformacion

mov al, ah 
xor ah,ah 

cmp si, 2
je unidad

mov cl, 10;decena
jne separar_Cifras

unidad:          
mov cl, 1 
jmp separar_Cifras   

comenzar_Transformacion:;comienza pasaje a ascii
lea bx, puntaje_Ascii
mov cx, 0x3

transformar_Ascii:
add [bx], 0x30;paso a ascii el numero
inc bx
loop transformar_Ascii    
mov [bx],"$" 

lea bx, puntaje_Ascii;imprimo puntaje 

seguir_Puntaje:  
cmp [bx],"$"
je final
mov dl,[bx]
mov ah,2;imprime por caracter en dl  
int 21h 
inc bx
jmp seguir_Puntaje    

final:
ret         
pasar_Puntaje_Ascii endp
;************************************************************************************;