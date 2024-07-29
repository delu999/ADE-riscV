.data
listInput: .string "ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~ ADD(9) ~SSX~SORT~PRINT~DEL(b)~DEL(B) ~PRI~SDX~REV~PRINT"
# listInput: .string "ADD(1) ~ SSX ~ ADD(a) ~ add(B) ~ ADD(B) ~ ADD ~ ADD(9) ~PRINT~SORT(a)~PRINT~DEL(bb)~DEL(B) ~PRINT~REV~SDX~PRINT"
# listInput: .string "PRINT~SORT~REV~SSX~SDX~DEL(a)~ADD(1)~PRINT"
# listInput: .string "ADD(1)~SORT~REV~SSX~SDX~PRINT~DEL(1)~ADD(a)~PRINT"
newLine: .string "\n"

.text
main: 
    li s0, 0            # Puntatore alla testa della lista circolare
    la s1, listInput
    li s2, 30           # Comandi disponibili
    li s3, 0x00100000   # Indirizzo iniziale dove salvare i nodi della lista circolare
    li s4, 65           # A
    li s5, 90           # Z
    li s6, 97           # a
    li s7, 122          # z
    li s8, 48           # 0
    li s9, 57           # 9
    li s10, 0           # Indirizzo array per ordinamento

    j parse_commands

ADD:
    addi s3, s3, 20                # Genera indirizzo per un nuovo nodo
    sb a0, 0(s3)                   # Memorizza il valore a0 (DATA) nel nuovo nodo
    bnez s0, append_node

    add_first_node:
        mv s0, s3                  # s0 punta alla testa
        sw s0, 4(s3)               # Imposta il puntatore del nuovo nodo su se stesso
        j end_add

    append_node:
        mv t1, s0                  # Inizia dalla testa della lista

    find_last_ADD:
        mv t2, t1                  # Salva l'indirizzo del nodo corrente
        lw t1, 4(t1)               # Carica l'indirizzo del nodo successivo
        bne t1, s0, find_last_ADD  # Continua a cercare finché non si torna alla testa della lista

        # t2 contiene l'indirizzo dell'ultimo nodo della lista
        sw s0, 4(s3)           # Imposta il puntatore del nuovo nodo alla testa
        sw s3, 4(t2)           # Aggiorna il puntatore della vecchia coda per puntare alla nuova coda

    end_add:
        jr ra

DEL:
    beqz s0, end_del            # Se la lista è vuota, termina immediatamente
    mv t4, s0                   # Carica il puntatore della testa in t4

    start_loop:
        lb t1, 0(t4)            # Carica il valore in t1
        beq a0, t1, delete_head # Se il valore corrisponde a quello da eliminare e si trova nella testa, salta a delete_head
        mv t0, t4               # Altrimenti, carica l'indirizzo corrente in t0 (t0 sarà usato per tenere traccia del nodo precedente)

    delete_loop:
        lw t2, 4(t0)            # Carica l'indirizzo del nodo successivo in t2
        beq t2, s0, update_tail # Se il nodo successivo è la testa, significa che abbiamo raggiunto la coda; quindi, aggiorna la coda
        lb t1, 0(t2)            # Carica il valore del nodo successivo in t1
        beq t1, a0, delete_node # Se il valore del nodo successivo corrisponde a quello da eliminare, salta a delete_node
        mv t0, t2               # Altrimenti, sposta il puntatore al nodo successivo
        j delete_loop           # E ripeti il ciclo di cancellazione

    delete_node:
        lw t3, 4(t2)            # Carica l'indirizzo del nodo successivo al nodo da eliminare
        sw t3, 4(t0)            # Collega il nodo precedente al nodo successivo al nodo da eliminare, bypassando il nodo da eliminare
        j delete_loop           # Riprendi il ciclo di cancellazione per cercare altri nodi con lo stesso valore

    delete_head:
        lw t5, 4(t4)            # Carica l'indirizzo del secondo nodo (dopo la testa)
        beq t5, s0, reset_list  # Se la testa è l'unico nodo nella lista, svuota l'intera lista
        mv t4, t5               # Imposta t4 come nuova testa
        j start_loop            # Riprende la ricerca dalla nuova testa

    update_tail:
        mv s0, t4               # Aggiorna la vecchia testa della lista
        sw s0, 4(t0)            # Aggiorna il PAHEAD dell'ultimo nodo
        j end_del

    reset_list:
        li s0, 0                # Svuota la lista impostando la testa a 0

    end_del:
        jr ra

PRINT:
    beqz s0, end_print          # Se la lista è vuota, termina immediatamente
    mv t0, s0                   # Inizia dalla testa della lista

    print_loop:
        lb a0, 0(t0)            # Carica il valore del nodo corrente
        li a7, 11               # Imposta il codice del sistema per stampare un char
        ecall
        lw t0, 4(t0)            # Carica l'indirizzo del nodo successivo
        bne t0, s0, print_loop  # Se non siamo tornati alla testa, ripeti il ciclo

    print_new_line:
        la a0, newLine
        li a7, 4
        ecall

    end_print:
        jr ra

SORT:
    beqz s0, end_sort     # Se la lista è vuota, termina immediatamente
    addi sp, sp, -4
    sw ra, 0(sp)
    jal list_to_array     # Converto la lista in array
    mv a1, a0             # a1=end adesso contiene il numero di elementi dell'array
    addi a1, a1, -1       # Decremento il valore a1, in modo da poter fare array[end] nel quicksort
    li a0, 0              # a0=start
    jal quicksort
    jal array_to_list
    lw ra, 0(sp)
    addi sp, sp, 4
    
    end_sort:
        jr ra

REV:
    beqz s0, end_rev          # Se la lista è vuota, termina immediatamente
    lw t1, 4(s0)              # Carica l'indirizzo del secondo nodo
    beq t1, s0, end_rev       # Se c'è un solo nodo nella lista, non c'è bisogno di invertire
    mv t0, s0                 # Inizia dalla testa della lista

    rev_loop:
        mv t2, t1             # Sposta al nodo successivo
        lw t1, 4(t1)          # Carica l'indirizzo del nodo successivo
        sw t0, 4(t2)          # Inversione del puntatore
        mv t0, t2             # Aggiorna t0 al nodo corrente, in preparazione per il prossimo giro

        bne t1, s0, rev_loop  # Se non siamo ancora tornati alla testa, continua il loop
        sw t0, 4(t1)          # Ricollega l'ultimo nodo (originariamente il primo nodo) alla nuova testa
        mv s0, t2             # Aggiorna il puntatore di testa per puntare all'ultimo nodo della lista originale

    end_rev:
        jr ra
SDX:
    beqz s0, end_sdx # Se la lista è vuota, termina immediatamente
    mv t1, s0
    # Trovo l'ultimo elemento e faccio puntare s0 alla coda
    find_last_SDX:
        mv t2, t1
        lw t1, 4(t1)
        bne t1, s0, find_last_SDX  
        mv s0, t2    # Il puntatore alla testa, adesso punta alla coda. La lista è stata shiftata a destra

    end_sdx:
        jr ra

SSX:
    beqz s0, end_ssx
    lw s0, 4(s0)   # Il puntatore alla testa, adesso punta al secondo nodo. La lista è stata shiftata a sinistra

    end_ssx:
        jr ra

# Salva i nodi della lista in un array che inizia dall'indirizzo in s10, e restituisce il numero di elementi dell'array
list_to_array:
    mv t0, s0
    mv t1, s10
    
    list_to_array_loop:
        lb t2, 0(t0)                   # Carica il valore del nodo corrente
        sb t2, 0(t1)                   # Memorizza il valore nell'array
        lw t0, 4(t0)                   # Carica l'indirizzo del nodo successivo
        addi t1, t1, 1                 # Incrementa l'indice dell'array
        beq t0, s0, end_list_to_array  # Se non siamo tornati alla testa, continua il loop
        j list_to_array_loop

    end_list_to_array:
        sb zero, 0(t1)                 # Delimitatore
        mv a0, t1                      # Manda in output il numero di elementi dell'array
        jr ra

# Prend i nodi dall'array che inizia dall'indirizzo in s10 e li mette in una nuova lista circolare
array_to_list:
    addi sp, sp, -8
    sw ra, 4(sp)
    li s0, 0                        # Elimino la lista circolare non ordinata
    mv t0, s10

    array_to_list_loop:
        lb a0, 0(t0)                # Prendo DATA dall'array
        beqz a0, end_array_to_list  # Controllo che non siamo alla fine dell'array
        addi t0, t0, 1              # Incremento puntatore all'array
        sw t0, 0(sp)                # Salvo nello stack t0 prima di chiamare la funzione
        jal ADD
        lw t0, 0(sp)                # Riprendo il valore dallo stack
        j array_to_list_loop

    end_array_to_list:
        lw ra, 4(sp)
        addi sp, sp, 8
        jr ra

quicksort:
    addi sp, sp, -12                 # Riserva spazio nello stack per ra, a0 e a1
    sw ra, 8(sp)                     # Salva i valori correnti di ra, a0 e a1 nello stack
    sw a0, 4(sp)
    sw a1, 0(sp)
    
    blt a0, a1, continue_quicksort   # L'algoritmo continua finchè start < end
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra                 

    continue_quicksort:
        jal partition         
        mv t0, a0                    # Usa un registro temporaneo (t0) per mantenere il risultato di partition
        lw a0, 4(sp)                 # Carica i valori di a0 e a1
        lw a1, 0(sp)
        addi a1, t0, -1
        jal quicksort                # Chiama ricorsivamente quicksort per la prima metà

        lw a0, 4(sp)                 # Carica il valore di a0
        addi a0, t0, 1
        lw a1, 0(sp)
        jal quicksort                # Chiama ricorsivamente quicksort per la seconda metà

        lw ra, 8(sp)
        addi sp, sp, 12
        jr ra

partition: 
    addi sp, sp, -4       # Riserva spazio nello stack per ra
    sw ra, 0(sp)          # Salva ra
    mv a4, a0             # Inizializza a4 con a0 (low)
    mv a5, a1             # Inizializza a5 con a1 (high)
    lb a6, 0(a1)          # Carica il valore di pivot dalla posizione high
    addi a7, a0, -1       # Setta a7 (i) a low - 1

    partition_loop:
        bge a4, a5, end_partition  # Se low >= high, termina il loop
        lb a0, 0(a4)          # Carica il valore corrente in a0
        mv a1, a6             # Imposta il valore di pivot in a1
        jal should_swap       # Chiama la funzione should_swap per determinare se bisogna scambiare i valori
        beqz a0, inc          # Se non è necessario scambiare, incrementa a4 (low)

        addi a7, a7, 1        # Incrementa a7 (i)
        lb t1, 0(a7)          # Carica il valore di array[i] in t1
        lb t2, 0(a4)          # Carica il valore di array[low] in t2
        sb t1, 0(a4)          # Scambia i due valori
        sb t2, 0(a7)

    inc:
        addi a4, a4, 1        # Incrementa a4 (low)
        j partition_loop      # Torna all'inizio del loop

    end_partition:
        addi a7, a7, 1        # Incrementa a7 (i)
        lb t1, 0(a7)          # Carica il valore di array[i] in t1
        lb t2, 0(a5)          # Carica il valore di array[high] in t2
        sb t1, 0(a5)          # Scambia i due valori
        sb t2, 0(a7)
        mv a0, a7             # Imposta a0 con il valore di a7

        lw ra, 0(sp)          # Recupera ra
        addi sp, sp, 4        # Ripristina lo stack
        jr ra                 # Ritorna alla funzione chiamante

# Questa funzione determina se i caratteri ascii in a0 e a1 devono essere scambiati. 
# La funzione restituirà 1 se i caratteri sono uguali o se il carattere in a0 è minore 
# del carattere in a1 secondo l'ordinamento dato; altrimenti, restituirà 0  

should_swap:
    beq a0, a1, equal_char         # Se i caratteri sono uguali, salta alla label equal_char
    addi sp, sp, -8
    sw ra, 4(sp)

    jal adjust_char                # Chiamata a adjust_char per ordinare il carattere in a0
    sw a0, 0(sp)                   # Salva il risultato di adjust_char per il primo carattere
    mv a0, a1                      # Muovi il secondo carattere nel registro a0
    
    jal adjust_char                # Chiamata a adjust_char per ordinare il carattere ora in a0
    mv a1, a0                      # Muovi il risultato nel registro a1
    lw a0, 0(sp)                   # Carica il risultato di adjust_char per il primo carattere

    slt a0, a0, a1                 # Controlla se a0 < a1, imposta a0=1 se a0 è più grande
    j end_should_swap              # Salta alla fine

    equal_char:
        li a0, 0                   # Imposta il valore di ritorno a 0
        jr ra
        
    end_should_swap:
        lw ra, 4(sp)
        addi sp, sp, 8
        jr ra


# Funzione che prende un carattere in a0 e modifica il suo valore in base 
# all'ordinamento richiesto dal progetto: maiuscola > minuscola > numero > caratteri speciali.
adjust_char:
    check_uppercase:
        blt a0, s4, check_lowercase # a0 < A
        bgt a0, s5, check_lowercase # a0 > Z
        addi a0, a0, 1000           # a0 è una lettera maiuscola, incremento la sua priorità
        jr ra

    check_lowercase:
        blt a0, s6, check_number    # a0 < a
        bgt a0, s7, check_number    # a0 > z
        addi a0, a0, 100            # a0 è una lettera minuscola, incremento la sua priorità
        jr ra

    check_number:
        blt a0, s8, special_char    # a0 < 0
        bgt a0, s9, special_char    # a0 > 9
        jr ra                       # Lascio invariato

    special_char:
        addi a0, a0, -1000          # a0 è un carattere speciale, decremento la sua priorità
        jr ra

# Controllo dei comandi e della loro correttezza come richiesto dal progetto.
# Nei vari check (check_add, check_del ecc.) se i comandi sono corretti, prima di chiamare la relativa funzione,
# chiamo check_tilde_after_command che controlla se è presente la tilde dopo il comando.
# s2=30 viene decrementato ogni volta che viene eseguito un comando. Con s2=0 il programma termina, come richiesto dal progetto (max 30 comandi)
# In ADD e DEL controllo che DATA sia tra 32 e 125 compresi come richiesto dal progetto
parse_commands:
    beqz s2, end_main
    
    skip_spaces:
        lb t1, 0(s1)
        beqz t1, end_main
        li t2, 32
        bne t1, t2, process_command
        addi s1, s1, 1
        j skip_spaces

    process_command:
        lb t1, 0(s1)
        li t2, 65
        beq t1, t2, check_add
        li t2, 80
        beq t1, t2, check_print
        li t2, 68
        beq t1, t2, check_del
        li t2, 82
        beq t1, t2, check_rev
        li t2, 83
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        beq t1, t2, check_ssx
        li t2, 68
        beq t1, t2, check_sdx
        li t2, 79
        beq t1, t2, check_sort
        j check_next_command

    check_add:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 68
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 40
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb a0, 0(s1)
        li t4, 32
        blt a0, t4, check_next_command
        li t4, 125
        bgt a0, t4, check_next_command
        addi s1, s1, 1
        lb t2, 0(s1)
        li t3, 41
        bne t2, t3, check_next_command
        la t5, ADD
        j check_tilde_after_command

    check_print:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 82
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 73
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 78
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 84
        bne t1, t2, check_next_command
        la t5, PRINT
        j check_tilde_after_command

    check_del:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 69
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 76
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 40
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb a0, 0(s1)
        li t4, 32
        blt a0, t4, check_next_command
        li t4, 125
        bgt a0, t4, check_next_command
        addi s1, s1, 1
        lb t2, 0(s1)
        li t3, 41
        bne t2, t3, check_next_command
        la t5, DEL
        j check_tilde_after_command

    check_sort:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 82
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 84
        bne t1, t2, check_next_command
        la t5, SORT
        j check_tilde_after_command

    check_rev:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 69
        bne t1, t2, check_next_command
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 86
        bne t1, t2, check_next_command
        la t5, REV
        j check_tilde_after_command

    check_ssx:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 88
        bne t1, t2, check_next_command
        la t5, SSX
        j check_tilde_after_command

    check_sdx:
        addi s1, s1, 1
        lb t1, 0(s1)
        li t2, 88
        bne t1, t2, check_next_command
        la t5, SDX
        j check_tilde_after_command

    check_tilde_after_command:
        li t1, 32                                   # 32 = spazio
        li t2, 126                                  # 126 = ~ 
        li t4, 0                                    # t4 = 0  tilde dopo il comando trovata, t4 = 1 tilde non trovata

    check_tilde_after_command_loop:
        addi s1, s1, 1
        lb t3, 0(s1)
        beqz t3, execute_command                    # Se si tratta del fine stringa, termina la verifica
        beq t3, t1, check_tilde_after_command_loop  # Se è uno spazio, continua a controllare il prossimo carattere
        bne t3, t2, tilde_not_found                 # Se non è una tilde, vuol dire che ci sono due comandi non separati da tilde

    execute_command:
        bnez t4, check_next_command                 # Se la tilde non è stata trovata non eseguo la funzione
        jalr t5                                     # Esegui la funzione associata al comando individuato in precedenza
        addi s2, s2, -1                             # Decrementa il contatore delle istruzioni

    check_next_command:
        addi s1, s1, 1                              # Incrementa il puntatore della stringa listInput
        j parse_commands                            # Ritorna all'inizio per analizzare la prossima istruzione
        
    tilde_not_found:                                
        li t4, 1                                    # La tilde non è stata trovata
        j check_tilde_after_command_loop            # Prima di tornare al parser, continuo a scorrere la stringa finchè non trovo
                                                    # la prossima tilde. In questo modo vengono saltati i comandi non separati da tilde
                                                    # e quando si torna al parser s1 è si trova già al carattere dopo la tilde.
end_main:
    li a7, 10                                       # Imposta il codice di sistema per terminare l'esecuzione
    ecall
