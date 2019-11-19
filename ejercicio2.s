#--------------------------- DISCLAIMER -----------------------------------
# No hemos incluído en este fichero el segmento de memoria .text, pues 
# entendemos que no es necesario. A su vez, cabe mencionar que hemos
# puesto una única etiqueta de retorno para todas las funciones, que 
# se puede encontrar al final del fichero. Rogamos perdonen las molestias
# causadas.




extraerValores:
#ARGUMENTOS {$a0 ::= float[][] A, $a1 ::= M, $a2 ::= N, $a3 ::= int[] V}
#Utilizaremos las máscaras 0x80000000, 0x7F800000 y 0x00700000 para aislar el signo, el exponente y la mantisa, respectivamente, de un número flotante
	move $t0, $a0		#Dirección de memoria de la matriz A
	move $t1, $a1		#Número de filas de la matriz A
	move $t2, $a2		#Número de columnas de la matriz A
	move $t3, $a3 		#Dirección de memoria del vector V
	li $t4, 0x00200000  #$t4 almacena la dirección de comienzo de .data
	li $v0, -1			#Valor por defecto a devolver

    bltz $t0, return	#Comprobamos que direccion(A) >= 0
    blez $t1, return	#Comprobamos que el numero de filas es al menos 1
	blez $t2, return	#Comprobamos que el numero de columnas es al menos 1
	bltz $t3, return	#Comprobamos que direccion(V) >= 0

	#Comprobamos que ni la matriz A ni el vector V apuntan al segmento de memoria reservado para .text
	blt $t0, $t4, return
	blt $t3, $t4, return
    
	mul $t4, $t1, $t2	#Número de elementos de la matriz A

	li $t5, 0	#Contador

	if_extraerValores:
		blt $t5, $t4, then_extraerValores
		li $v0, 0
		b return
		then_extraerValores:
			l.s $f0, ($t0)						#Cargamos el elemento deseado de la matriz A
			mfc1 $t6, $f0 						#Movemos el valor del flotante al procesador principal
			and $t7, $t6, 0x7F800000			#Realizamos la máscara para aislar el exponente
			beq $t7, 0x7F800000, then_exp255	#Comprobamos si el exponente es 255
			beqz $t7, then_exp0					#Comprobamos si el exponente es 0
			#Si el exponente no es 0 ni 255, entonces es un número normalizado. Aumentamos en 1 el valor de la sexta posición de V
			lw $t8, 20($t3)
			addi $t8, $t8, 1							
			sw $t8, 20($t3)
			b reiterar_extraerValores 					
			then_exp255:
				and $t7, $t6, 0x00700000	#Realizamos la máscara para aislar la mantisa
				beqz $t7, then_exp255_man0	#Comprobamos si la mantisa es 0
				#Si la mantisa no es 0, entonces es un NaN. Aumentamos en 1 el valor de la cuarta posición de V
				lw $t8, 12($t3)
				addi $t8, $t8, 1
				sw $t8, 12($t3)
				b reiterar_extraerValores
				then_exp255_man0:
					and $t7, $t6, 0x80000000		#Realizamos la máscara para aislar el signo
					beqz $t7, then_exp255_man0_s0	#Comprobamos si el signo es 0
					#Si el signo es 1, entonces es un -infinito. Aumentamos en 1 el valor de la tercera posición de V
					lw $t8, 8($t3)
					addi $t8, $t8, 1
					sw $t8, 8($t3)
					b reiterar_extraerValores
					then_exp255_man0_s0:
						#Si el signo es 0, entonces es un +infinito. Aumentamos en 1 el valor de la segunda posición de V
						lw $t8, 4($t3)
						addi $t8, $t8, 1
						sw $t8, 4($t3)
						b reiterar_extraerValores
			then_exp0:
				and $t7, $t6, 0x00700000	#Realizamos la máscara para aislar la mantisa
				beqz $t7, then_exp0_man0	#Comprobamos si la mantisa es 0
				#Si la mantisa no es 0, se trata de un número desnormalizado. Aumentamos en 1 el valor de la quinta posición de V
				lw $t8, 16($t3)
				addi $t8, $t8, 1
				sw $t8, 16($t3)
				b reiterar_extraerValores
				then_exp0_man0:
					#Si la mantisa es 0, entonces el número es 0. Aumentamos en 1 el valor de la primera posición de V
					lw $t8, 0($t3)
					addi $t8, $t8, 1
					sw $t8, 0($t3)
					b reiterar_extraerValores
		reiterar_extraerValores:
			addi $t5, $t5, 1		#Añadimos 1 al contador
			addi $t0, $t0, 4		#Apuntamos al siguiente elemento de la matriz A
			b if_extraerValores 	#Volvemos al bucle

sumar:
#ARGUMENTOS {$a0::= int[][] A, $a1::= int[][] B, $a2::= int[][] C, $a3 ::= int M, ($sp) ::= int N}
	move $t0, $a0		#direccion(A)
    move $t1, $a1		#direccion(B)
    move $t2, $a2		#direccion(C)
    move $t3, $a3		#M
    lw $t4, ($sp)		#N
    li $v0, -1			#Outpur por defecto
    li $t6, 0x00200000	#Apuntamos $t6 al comienzo de .data

    blez $t3, return		#Comprobamos que M>0
    blez $t4, return		#Comprobamos que N>0
    bltz $t0, return 		#Comprobamos que dirreccion(A) >=0
   	bltz $t1, return 		#Comprobamos que dirreccion(B) >=0
    bltz $t2, return 		#Comprobamos que dirreccion(C) >=0
    
    #Comprobamos que ninguna matriz apunta a .text
    blt $t0, $t6, return
    blt $t1, $t6, return
    blt $t2, $t6, return

    mul $t8, $t3, $t4		#Guardamos en $t8 el numero de elementos de las matrices
    li $t7, 0 				#Contador de elementos
    if_sumar:
    	blt $t7, $t8, then_sumar	#Comprobamos que no hayamos recorrido todos los elementos
        li $v0,1					
        addu $sp, $sp, 4
        b return
    then_sumar:
    	lwc1 $f0, 0($t1)		#Cargamos el elemento de B
        lwc1 $f1, 0($t2)		#Cargamos el emento de C
        add.s $f2, $f0, $f1		#B+C
        swc1 $f2, 0($t0)		#Guardamos la suma en el elemento correspondiente de A
        addi $t0, $t0, 4		#Apuntamos $t0 al siguiente elemento de A
        addi $t1, $t1, 4		#Apuntamos $t2 al siguiente elemento de B
        addi $t2, $t2, 4		#Apuntamos $t3 al siguiente elemento de C
        addi $t7, $t7, 1		#Aumentamos en 1 el numero de elementos recorridos
    	b if_sumar
    	
return:
	jr $ra