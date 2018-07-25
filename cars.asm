##############################################################
##                                                          ##
## Autori: Boffelli Jacopo, Pirotta Nicola, Cantoni Giorgio ##
##                                                          ##
##############################################################


# DIRETTIVE ALL'ASSEMBLATORE
# Parte iniziale IN_OUT -> Passo vari dati alla memoria
         .data 0x10000000               # I valori vengono allocati nel data segment a partire dall'indirizzo
IN_OUT:  .half 0x0000                   
         .text                          # I valori successivi vengono messi nel user text segment

# AUTOVELOX
        la $t0, IN_OUT                  # Carico l'indirizzo di IN_OUT in $t0
        add $s0, $zero, $zero           # Contatore che viene utilizzato nei confronti delle varie velocità
        li $t7, 250000000               # Per l'attesa di 1 secondo
        li $t8, 125000000               # Per l'attesa di mezzo secondo
        li $t9, 1                       # Per ciclo2

# PRIMO SENSORE: Aspetta un auto (Il bit numero 15 va forzato a 1 per indicare il passaggio dell'auto)

ciclo1: lh $t1, 0($t0)                  # Carico tutti i 16bit di IN_OUT
        srl $t2, $t1, 15                # Considero solo il bit numero 15 -> primo sensore
        bne $t2, $zero, ciclo2          # Salto a ciclo2 se passa un'auto
        j ciclo1                        # Se non salto a ciclo2, ricontrollo il primo sensore


# SECONDO SENSORE: Aspetta l'autorizzazione del primo, poi avvia il contatore finchè viene forzato ad 1 (la macchine esce)

ciclo2: lh $t1, 0($t0)                  # Carico tutti i 16bit di IN_OUT
        srl $t3, $t1, 14                # Considero solo il bit numero 14 -> secondo sensore
        beq $t3, $t9, confronto         # Se l'auto esce, passo al confronto del contatore con le velocità
        addi $s0, $s0, 1                # Finche' l'auto non esce, incremento contatore

        j ciclo2                        # Se l'auto non esce, ricontrollo il secondo sensore


# CONTROLLO VELOCITA': Gestisco vari confronti per stabilire la velocita' dell'auto
# ed invio sui bit 7 e 6 un numero che rappresenta la velocità secondo la convenzione: 00 / 01 / 10 / 11

confronto: li $t3, 10000000 # Inizio a caricare gli equivalenti (in numero di clock) delle velocità per effettuare i confronti con il contatore
           li $t4, 8975000  # All'interno della relazione vi è il calcolo dei valori equivalenti
           li $t5, 8175000

           # Confronto0 rappresenta quando velocita' < 90 -> 00
           slt $t6, $s0, $t3            # Se contatore < t3 allora $t6=1, altrimenti $t6=0
           beq $t6, $zero, confronto0   # Se velocita' < 90 vado a confronto0, altrimenti proseguo

           # Confronto1 rappresenta quando 90 < velocita' < 100 -> 01
           slt $t6, $s0, $t4            # se contatore < t4, allora $t6=1, altrimenti $t6=0
           beq $t6, $zero, confronto1   # se velocita' < 100 vado a confronto1, altrimenti proseguo

           # Confronto2 rappresenta quando 100 < velocita' < 110 -> 10
           slt $t6, $s0, $t5            # se contatore < t5, allora $t6=1, altrimenti $t6=0
           beq $t6, $zero, confronto2   # se velocita' < 110 vado a confronto2, altrimenti proseguo

           # Confronto3 rappresenta quando velocita' > 110 -> 11
           j confronto3                 # la velocita' e' maggiore di 110, vado a confronto3


confronto0: lh $t1, 0($t0)            # Carico i 16 bit di IN_OUT in modo da poter lavorare su quelli necessari
            andi $t1, $t1, 0xFF3F     # Modifico il valore dei bit 7 e 6 in modo da ottenere la convenzione '00'
            sh $t1, 0($t0)


attesa: addi $t7, $t7, -1               # Decremento di 1 per far passare un secondo
        beq $t7, $zero, ciclo1          # se il secondo è passato, ritorno a ciclo1

        j attesa                        # atrimenti ritorno a decrementare


confronto1: lh $t1, 0($t0)              # Carico i 16 bit di IN_OUT in modo da poter lavorare su quelli necessari
            andi $t1, $t1, 0xFF3F
            ori $t1, $t1, 0x0040        # Modifico il valore dei bit 7 e 6 in modo da ottenere la convenzione '01'
            sh $t1, 0($t0)

            j attesafoto                # Salto per l'attesa di 1 secondo


confronto2: lh $t1, 0($t0)              # Carico i 16 bit di IN_OUT in modo da poter lavorare su quelli necessari
            andi $t1, $t1, 0xFF3F
            ori $t1, $t1, 0x0080        # Modifico il valore dei bit 7 e 6 in modo da ottenere la convenzione '10'
            sh $t1, 0($t0)

            j attesafoto                # Salto per l'attesa di 1 secondo


confronto3: lh $t1, 0($t0)              # Carico i 16 bit di IN_OUT in modo da poter lavorare su quelli necessari
            andi $t1, $t1, 0xFF3F
            ori $t1, $t1, 0x00C0        # Modifico il valore dei bit 7 e 6 in modo da ottenere la convenzione '11'
            sh $t1, 0($t0)

# FOTOCAMERA
attesafoto: addi $t7, $t7, -1           # Decremento di 1 per far passare un secondo
            beq $t7, $zero, camera      # Se il secondo è passato, vado a camera per scattare la foto

            j attesafoto                # Altrimenti ritorno a decrementare

camera: lh $t1, 0($t0)                  # Carico i 16 bit di IN_OUT in modo da poter lavorare su quelli necessari
        andi $t1, $t1, 0xFFF8
        ori $t1, $t1, 0x0008            # Modifico il valore del bit 3 per comandare lo scatto della fotocamera
        sh $t1, 0($t0)
        j attesa500                     # Salto per l'attesa di mezzo secondo

attesa500: addi $t8, $t8, -1            # Decremento di 1 per far passare 0,5 secondi
           beq $t8, $zero, camera2      # Se sono passati 0,5 secondi, vado a camera2

           j attesa500                  # Altrimenti torno a decrementare

camera2: lh $t1, 0($t0)                 # Carico i 16 bit di IN_OUT
         andi $t1, $t1, 0xFFF0          # Fine scatto fotocamera
         sh $t1, 0($t0)

         sh $zero, 0($t0)               # Riporto alla condizione iniziale IN_OUT prima di tornare a controllare il primo sensore

         j ciclo1                       # Ritorno a ciclo1 ossia aspetto una nuova auto nell'autovelox
