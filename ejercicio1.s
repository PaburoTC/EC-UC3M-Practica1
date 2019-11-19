#--------------------------- DISCLAIMER -----------------------------------
# No hemos incluído en este fichero el segmento de memoria .text, pues 
# entendemos que no es necesario. A su vez, cabe mencionar que hemos
# puesto una única etiqueta de retorno para todas las funciones, que 
# se puede encontrar al final del fichero. Rogamos perdonen las molestias
# causadas.



  
inicializar:
	#ARGUMENTOS {$a0::= int[][] A, $a1::= int M, $a2 ::= int N,}
    move $t0, $a0       #Almacena la direccion de la matriz <== $a0
    move $t1, $a1       #Almacena el numero de filas de la matriz <== $a1
    move $t2, $a2       #Almacena el numero de columnas de la matriz <== $a2
    li $v0, -1			#Valor de retorno por defecto, negativo
    li $t3, 0x00200000	#$t3 almacena la direccion de comienzo de .data
    #Comprobamos que la matriz pasada ($a0), M y N ($a1, $a2) son mayores que cero. 
	bltz $t0, return    #Mientras que la dirección de la matriz si que podria ser 0, el numero de filas y de columas de la matriz no
    blez $t1, return
    blez $t2, return
    #Comprobamos que la direccion de la matriz no apunta al segmento reservado para .text
	blt $t0, $t3, return
	#Calculamos el numero de elementos de la matriz pasada, multiplicando filas x columnas, guardando el valor en $t0
	mul $t3, $t1, $t2
    li $t4, 0 			#Numero de elementos recorridos
    li $t5, 0			#Numero a insertar en todos los elementos de la matriz, 0 en este caso

    #Bucle que recorre la matriz, poniendo a 0 todos sus elementos
    #El bucle contiene la condicion de permanencia, el codigo del mismo se ejecuta bajo la etiqueta de prefijo 'then_'
    if_inicializar: 
    	blt $t4, $t3, then_inicializar	#Comprobamos que $t2 es menor que $t0, aun no hemos recorrido todos los elementos de la matriz
    	li $v0, 0						#Devolvemos 0
    	b return						#Salto al fin de la funci0n
    then_inicializar:
      	sw $t5, ($t0)		#Cargamos $t3 (0) en la direcci0n marcada por $t1 (elemento actual de la matriz)
        addi $t0, $t0, 4	#Apuntamos $t1 al siguiente elemento de la matriz
        addi $t4, $t4, 1	#Aumentamos en 1 el numero de elementos recorridos
        b if_inicializar	#Comprobamos que $t1 sigue apuntando a un elemento dentro de la matriz

sumar:
#ARGUMENTOS {$a0 ::= int[][] A, $a1 ::= int[][] B, $a2 ::= int[][] C, $a3 ::= int M, ($sp) ::= int N}
    move $t0, $a0       #Direccion de A
    move $t1, $a1       #Direccion de B
    move $t2, $a2       #Direccion de C
    move $t3, $a3       #M, número de filas de las tres matrices
    lw $t4, ($sp)       #N, número de columnas de las tres matrices
    li $v0, -1          #Output por defecto
    li $t5, 0x00200000  #$t5 almacena la dirección de comienzo de .data

    blez $t3, return    #Si M < 1, retornamos
    blez $t4, return    #Si N < 1, retornamos
    bltz $t0, return    #Comprobamos que dir(A) >= 0
    bltz $t1, return    #Comprobamos que dir(B) >= 0
    bltz $t2, return    #Comprobamos que dir(C) >= 0

    #Comprobamos que las direcciones de las tres matrices no apuntan al segmento de memoria reservado para .text
    blt $t0, $t5, return
    blt $t1, $t5, return
    blt $t2, $t5, return

    mul $t5, $t3, $t4   #Número total de elementos de una matriz
    li $t6, 0           #Contador

    if_sumar:
        blt $t6, $t5, then_sumar    #Comprobamos que no se han recorrido todos los elementos
        li $v0, 1                   #Más tarde imprimiremos 1 por pantalla, indicando que el método funcionó correctamente
        b return
    then_sumar:
        lw $t7, 0($t1)              #Cargamos el elemento de B
        lw $t8, 0($t2)              #Cargamos el elemento de C
        add $t9, $t7, $t8           #Sumamos los elementos de B y C
        sw $t9, 0($t0)              #Guardamos la suma en el elemento de A
        addi $t0, $t0, 4            #Apuntamos $t0 al siguiente elemento de A
        addi $t1, $t1, 4            #Apuntamos $t1 al siguiente elemento de B
        addi $t2, $t2, 4            #Apuntamos $t2 al siguiente elemento de C
        addi $t6, $t6, 1            #Aumentamos en 1 al contador de elementos recorridos
        b if_sumar                  #Iteramos de nuevo el bucle
      
extraerFila:			
	#ARGUMENTOS {$a0::= int[] A, $a1::= int[][] B, $a2::= int M, $a3 ::= int N, $s0::= j (pila)}
    move $t0, $a0       #Almacena la direccion de la matriz A <== $a0
    move $t1, $a1       #Almacena la direccion de la matriz B <== $a1
    move $t2, $a2       #Almacena el numero de filas de la matriz B <== $a2
    move $t3, $a3       #Almacena el numero de columas de la matriz B <== $a3
    lw $t4, ($sp) 		#Almacena la fila a extraer de la matriz B <== ($sp). Rango [0, M-1]
    li $v0, -1          #Valor de retorno por defecto, negativo
    li $t5, 0x00200000	#$t5 almacena la direccion de comienzo de .data. Será sobreescrito más adelante
    #Comprobamos que M, N y j ($a2, $a3, $s1) son mayores que cero y que j<=M 
	blez $t2, 	  return
    blez $t3,     return
    bltz $t4,     return
    bge $t4, $t3, return
    #Comprobamos que la direccion de la matriz no apunta al segmento reservado para .text
    blt $t0, $t5, return
    blt $t1, $t5, return

    #Apuntamos $t1 al primer elemento de la fila a extraer en la matriz B
    mul $t5, $t3, $t4	#Numero de elementos que dejamos atras en la matriz B. Se sobreescribe el valor anterior de $t5, pues ya no es de utilidad
  	li $t6, 4	        #Cantidad de bytes en un palabra		
    mul $t5, $t5, $t6 	#Numero de direcciones que dejamos atras en la matriz B
    add $t1, $t1, $t5	#Direccion de comienzo de la fila a extraer en la matriz B 
    
    li $t7, 0			#Numero de elementos extraidos de la fila escogida de la matriz B, lo usaremos como contador en el siguiente bucle
    #Bucle que recorre todos los elementos de la fila indicada de la matriz B y los inserta en la matriz A
    #El bucle contiene la condicion de permanencia, el codigo del mismo se ejecuta bajo la etiqueta de prefijo 'then_'
    if_extraerFila:
    	blt $t7, $t3, then_extraerFila #Comprobamos que el numero de elementos extraidos es menor al numero de columnas
    	li $v0, 0
        b return 
    then_extraerFila:
    	#Cargamos el elemento a copiar de la matriz B en $t3, para despues guardarlo en la matriz A, el posicion marcada por $t0
    	lw $t8, ($t1)
        sw $t8, ($t0)
        #Apuntamos $t0 y $t1 al siguiente elemento de su matriz
        addi $t0, $t0, 4
        addi $t1, $t1, 4
        #Incrementamos el numero de elementos copiados
        addi $t7, $t7, 1
        b if_extraerFila


masCeros:
#ARGUMENTOS {$a0 ::= int[][] A, $a1 ::= int[][] B, $a2 ::= int M, $a3 ::= int N}
    move $t0, $a0       #Almacena la dirección de la matriz A
    move $t1, $a1       #Almacena la dirección de la matriz B
    move $t2, $a2       #Almacena el número de filas de ambas matrices
    move $t3, $a3       #Almacena el número de columnas de ambas matrices  
    li $v0, -1          #Valor por defecto a devolver de la función
    li $t4, 0x00200000  #$t4 almacena la dirección de comienzo de .data
    blez $t2, return    #Si M<1, retornamos
    blez $t3, return    #Si N<1, retornamos
    bltz $t0, return    #Comprobamos que dir(A) >= 0
    bltz $t1, return    #Comprobamos que dir(B) >= 0
    #Comprobamos que ninguna de las dos matrices apuntan al segmento de memoria reservado para .text
    blt $t0, $t4, return
    blt $t1, $t4, return
#Llamada a calcular para la matriz A
    #Guardamos los registros necesarios antes de llamar a calcular
    addu $sp, $sp, -24
    sw $ra, 0($sp)
    sw $v0, 4($sp)
    sw $t0, 8($sp)
    sw $t1, 12($sp)
    sw $t2, 16($sp)
    sw $t3, 20($sp)
    #Preparamos los parámetros para la función calcular
                    #El parámetro $a0 ya tiene la dirección de la matriz A
    move $a1, $t2   #$a1 almacenará el número de filas de la matriz
    move $a2, $t3   #$a2 almacenará el número de columnas de la matriz
    li $a3, 0       #$a3 almacenará el valor repetido que queremos buscar, 0
    jal calcular
    move $t4, $v0   #Almacena el valor de $v0 devuelto por calcular, es decir, el numero de ceros de la matriz A
    #Recuperamos los registros guardados en pila
    lw $t3, 20($sp)
    lw $t2, 16($sp)
    lw $t1, 12($sp)
    lw $t0, 8($sp)
    lw $v0, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 24
#Llamada a calcular para la matriz B
    #Guardamos los registros necesarios antes de llamar a calcular
    addu $sp, $sp, -28
    sw $ra, 0($sp)
    sw $v0, 4($sp)
    sw $t0, 8($sp)
    sw $t1, 12($sp)
    sw $t2, 16($sp)
    sw $t3, 20($sp)
    sw $t4, 24($sp)
    #Preparamos los parámetros para la función calcular
    move $a0, $t1   #$a0 almacenará la dirección de la matriz B
    move $a1, $t2   #$a1 almacena el número de filas de la matriz
    move $a2, $t3   #$a2 almacena el número de columnas de la matriz
    li $a3, 0       #$a3 almacena el valor repetido que queremos buscar, 0
    jal calcular
    move $t5, $v0   #Almacena el valor de $v0 devuelto por calcular, es decir, el numero de ceros de la matriz B
    #Recuperamos los registros guardados en pila
    lw $t4, 24($sp)
    lw $t3, 20($sp)
    lw $t2, 16($sp)
    lw $t1, 12($sp)
    lw $t0, 8($sp)
    lw $v0, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 28
#Devolvemos los valores de los parámetros de entrada
    move $a0, $t0
    move $a1, $t1
    move $a2, $t2
    move $a3, $t3
#Ahora que tenemos el número de ceros de ambas matrices, podemos comprobar cuál tiene más
    if_masCeros:
        bgt $t4, $t5, then_A    
        blt $t4, $t5, then_B
        li $v0, 2               #Si el número de ceros de A no es ni mayor ni menor que los de B, entonces es que son iguales y devolvemos 2
        b return
    then_masCerosA:
        li $v0, 0               #Si el número de ceros de A es mayor que el de B, devolvemos 0
        b return
    then_masCerosB:
        li $v0, 1
        b return                #Si el número de ceros de B es mayor que el de A, devolvemos 1
           
return:
    jr $ra