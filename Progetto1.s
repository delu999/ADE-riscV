#AMOAssEMBLY
#LAUREATO
#esempio di messaggio criptato -1
#myStr0ng P4ssW_
#BUONANOTTE

.data
    newline: .string "\n\n"
 
    myplaintext: .string "ASSEMBLYAAA"
    sostK: .word -2
    blocKey: .string "OLE"
    cipherOrder: .string "C"
    pt: .string ""
    ct: .string ""
    
.text
init:
    li s1, 0
    li s2, 66  # B
    li s3, 67  # C
    li s4, 68  # D
    li s5, 69  # E
    li s6, 32  # spazio
    li s7, 65  # A
    li s8, 90  # Z
    li s9, 97  # a
    li s10, 122 # z
    
    la a0, myplaintext
    la s0, cipherOrder
    la s11, cipherOrder
    
cipher:
    jal print
    
    lb s1, 0(s0)
    beqz s1, decipher  
    addi s0, s0, 1

    beq s1, s7, if_A_cipher
    beq s1, s2, if_B_cipher        
    beq s1, s3, if_C_cipher
    beq s1, s4, if_D_cipher
    beq s1, s5, if_E_cipher
    j cipher
    
decipher:
    addi s0, s0, -1
    lb s1, 0(s0)

    beq s1, s7, if_A_decipher
    beq s1, s2, if_B_decipher       
    beq s1, s3, if_C_decipher
    beq s1, s4, if_D_decipher
    beq s1, s5, if_E_decipher
    j end
 
# ----- IF per cifratura -----
   
if_A_cipher:
    lw a1, sostK
    jal CIF_DI_CESARE
    j cipher
if_B_cipher:
    la a1, blocKey
    jal CIF_A_BLOCCHI
    j cipher
if_C_cipher:
    jal CIF_OCCORRENZE
    j cipher
if_D_cipher:
    jal DIZIONARIO
    j cipher
if_E_cipher:
    jal INVERSIONE
    j cipher
    
# ----- IF per DEcifratura -----

if_A_decipher:
    lw a1, sostK
    jal DECIF_DI_CESARE
    j if_end
if_B_decipher:
    la a1, blocKey
    jal DECIF_A_BLOCCHI
    j if_end
if_C_decipher:
    jal DECIF_OCCORRENZE
    j if_end
if_D_decipher:
    jal DECIF_DIZIONARIO
    j if_end
if_E_decipher:
    jal DECIF_INVERSIONE
    j if_end
    
if_end:
    jal print 
    beq s0, s11, end 
    j decipher

end:
    li a7, 10
    ecall 

  
# ---------- cifratura di Cesare ------
    # assembly
    # -2
CIF_DI_CESARE: 
cc_init:
    mv t0, a0   # carico plain text
    mv t1, a1   # carico sost k
    li t3, 26   # carico 26 per modulo

cc_while:
    lb t2, 0(t0)
    beqz t2, cc_end
    blt t2, s7, cc_inc_index     # Se < A -> invariato
    ble t2, s8, cc_if_uppercase  # Se <= Z -> lettera maiuscola
    blt t2, s9, cc_inc_index     # Se < a -> invariato
    ble t2, s10, cc_if_lowercase  # Se <= -> lettera minuscola 
    
cc_inc_index:
    addi t0, t0, 1
    j cc_while
    
cc_if_uppercase:
    li t4, 65
    j cc_cipher

cc_if_lowercase:
    li t4, 97

cc_cipher:
    sub t2, t2, t4    # cif = cod(x) - A oppure cod(x) - a
    add t2, t2, t1    # cif = cif + K
    rem t2, t2, t3    # cif = cif % 26
    addi t2, t2, 26   # cif = cif + 26 
    rem t2, t2, t3    # cif = cif % 26
    add t2, t2, t4    # cif = cif + A oppure cif + a
    sb t2, 0(t0)
    j cc_inc_index

cc_end:
    jr ra

   
# ---------- decifratura di Cesare ------

DECIF_DI_CESARE: 
dc_init:
    mv t0, a0   # carico cipher text
    mv t1, a1   # carico sost k
    li t3, 26   # carico 26 per modulo

dc_while:
    lb t2, 0(t0)
    beqz t2, dc_end
    blt t2, s7, dc_inc_index     # Se < A -> invariato
    ble t2, s8, dc_if_uppercase  # Se <= Z -> lettera maiuscola
    blt t2, s9, dc_inc_index     # Se < a -> invariato
    ble t2, s10, dc_if_lowercase  # Se <= z -> lettera minuscola 
    
dc_inc_index:
    addi t0, t0, 1
    j dc_while
    
dc_if_uppercase:
    li t4, 65
    j dc_decipher

dc_if_lowercase:
    li t4, 97

dc_decipher:
    sub t2, t2, t4    # y = cod(x) - a  oppure cod(x) - A
    sub t2, t2, t1    # y = y - key 
    rem t2, t2, t3    # y = y mod 26
    add t2, t2, t4    # y = y + A oppure y = y + a
    sb t2, 0(t0)
    j dc_inc_index

dc_end:
    jr ra


# ---------- cifratura a blocchi ------

CIF_A_BLOCCHI:
    # assembly
    # OLE
cb_init:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    jal length  # lunghezza stringa in a1 ovvero della key
    
    mv t0, a0   # t0 len key
    mv t1, zero # i
    lw a0, 0(sp) # ripristino a0
    li t6, 96  #per modulo
    
cb_loop:
    add t2, t1, a0   # indirizzo plaintext + i 
    lb t3, 0(t2)     # carico plaintText[i]
    beqz t3, cb_end  # plaintext[i] == 0

    rem t4, t1, t0  # pos = i % keyLength
    add t4, t4, a1  # indirizzo key + pos 
    lb t4, 0(t4)    # carico key[pos]
    
    add t5, t4, t3  # a = plaintext[i] + key[pos]
    rem t5, t5, t6  # a = a % 96
    addi t5, t5, 32 # a = a + 32
    
    sb t5, 0(t2)
    addi t1, t1, 1  # i++
    j cb_loop

cb_end:
    lw ra, 4(sp)
    addi sp, sp, 8
    jr ra


# ---------- decifratura a blocchi ------

DECIF_A_BLOCCHI:
db_init:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    jal length  # lunghezza stringa in a1 ovvero della key
    
    mv t0, a0   # t0 len key
    mv t1, zero # i
    lw a0, 0(sp) # ripristino a0
    li t6, 96  #per modulo
    li a2, -32
    li a3, 127
    
db_loop:
    add t2, t1, a0   # indirizzo plaintext + i 
    lb t3, 0(t2)     # carico plaintText[i]
    beqz t3, db_end  # plaintext[i] == 0

    remu t4, t1, t0  # pos = i % keyLength
    add t4, t4, a1  # indirizzo key + pos 
    lb t4, 0(t4)    # carico key[pos]
    
    sub t5, t3, t4  # a = plaintext[i] - key[pos]
    rem t5, t5, t6  # a = a % 96
    add t5, t5, t6  # a = (a + 96)  questa e 
    rem t5, t5, t6  # a = a % 96    questa corregono i valori neg
    addi t5, t5, 64 # a = a + 64
    
    ble t5, a3, db_store_char  # se a <= 127 finito

db_not_decrypted_yet:
    rem t5, t5, t6  # %96   # altrimenti faccio modulo
 
db_store_char:
    sb t5, 0(t2)
    addi t1, t1, 1  # i++
    j db_loop

db_end:
    lw ra, 4(sp)
    addi sp, sp, 8
    jr ra


# ---------- cifratura occorrenza ------

# assembly
# A-0 S-1-2 E-3 M-4 B-5 L-6 Y-7

CIF_OCCORRENZE:
co_init:
    la a1, ct
    mv t0, a1 # t0 = indirizzo cipherText
    mv t1, a0 # t1 = indirizzo plainText per for_1
    li a2, 1  # marca le lettere 
    li a3, 0x7ffffff0
    li a4, 10
    li a5, 45

co_for1:
    lb t2, 0(t1) # t2 = char di plaintext per for_1

    beqz t2, co_end  # se t2 e` \0 fine funzione
    beq t2, a2, co_inc_for1_index  # se t4 e` 1 l'ho gia` controllata

    sb t2, 0(t0)
    addi t0, t0, 1
    mv t3, t1 # t3 = indirizzo plainText per for_2
    
co_for2:
    lb t4, 0(t3)  # t4 = char di plaintext per for_1
    
    beqz t4, co_end_for1   # controllo se t4 e` \0
    bne t4, t2, co_inc_for2_index # controllo se t2 = t4
    beq t4, a2, co_inc_for2_index  # se t4 e` 126 l'ho gia` controllata
    
    sb a2, 0(t3) # segno la lettera corrente con 127
    
    sb a5, 0(t0) # cypher text + '-'
    addi t0, t0, 1 # indirizzo cyperText + 1
    
    sub t5, t3, a0  # index j 
    blt t5, a4, co_single_digit  # pos < 10

co_store_dec_to_ascii:
    beqz t5, co_pop
    
    rem t6, t5, a4 #cifra o digit
    addi t6, t6, 48
    
    addi sp, sp, -1  #alloco spazio per stack
    sb t6, 0(sp)  # metto digit nello stack
        
    div t5, t5, a4
    j co_store_dec_to_ascii

co_pop:
    beq sp, a3, co_inc_for2_index
    
    lb t5, 0(sp)   #pop stack
    addi sp, sp, 1  #cifra successiva
    
    sb t5, 0(t0)   # carico la cifra in cipher text
    addi t0, t0, 1

    j co_pop

co_single_digit:
    addi t5, t5, 48
    sb t5, 0(t0)
    addi t0, t0, 1
    
co_inc_for2_index:
    addi t3, t3, 1 # indirizzo plainText for_2 + 1
    j co_for2
    
co_end_for1:
    sb s6, 0(t0)   # metto lo spazio in cipher text
    addi t0, t0, 1 # indirizzo cyperText + 1
    
co_inc_for1_index: 
    addi t1, t1, 1 # indirizzo plainText for_1 + 1
    j co_for1

co_end:
    addi t0, t0, -1
    sb zero, 0(t0)  # carattere di fine stringa
    mv a0, a1
    jr ra


# ---------- decifratura occorrenza ------

DECIF_OCCORRENZE:
do_init:
    la a7, pt
    mv a2, ra
    mv t0, a0 # t1 = indirizzo cipherText per for_1
    li a3, 0
    mv t6, zero
    mv a1, zero # final position
    li a5, 10
    li a6, 45
    li t4, 0
    
do_for1:
    lb t1, 0(t0) # t2 = char di ct per for_1
    beqz t1, do_end  # se t2 e` \0 fine funzione
    addi t2, t0, 2 # t3 = indirizzo cipherText per for_2
    
do_for2:
    lb t3, 0(t2) # t2 = char di ct per for_2
    beq t3, a6, do_save_pointer # salta se trattino e vado a ritirare dallo stack
    beq t3, s6, do_save_pointer #salta se spazio
    beqz t3, do_save_pointer #salta se \0
    
do_store_ascii_to_stack:
    addi t4, t4, 1
    j do_inc_index_for2
    
do_save_pointer:    
    mv a4, t2
    sub t2, t2, t4 
    
do_stack_to_int:
    beqz t4, do_set_char_in_pos

    lb t5, 0(t2) # prendere la n digit dallo stack
    addi t5, t5, -48
    addi t2, t2, 1
    addi t4, t4, -1
    
    mv a0, t4
    jal pow 
    mul a0, t5, a0 # moltiplico per la potenza
    add a1, a1, a0 # sommo la cifra al totale
    j do_stack_to_int
    
do_set_char_in_pos:
    add a1, a7, a1
    sb t1, 0(a1)
    addi a3, a3, 1
    mv t2, a4
    
do_inc_index_for2:
    addi t2, t2, 1 # j++
    beq t3, s6, do_inc_index_for1 #salta se spazio
    beqz t3, do_inc_index_for1 #salta se \0
    mv a1, zero # n digit
    j do_for2
    
do_inc_index_for1:
    mv t0, t2
    j do_for1

do_end:
    mv a0, a7
    add a3, a0, a3
    sb zero, 0(a3)
    mv ra, a2
    jr ra

    
# ---------- dizionario ------

DIZIONARIO:  
diz_init:
    mv t0, a0
    li t3, 187 # z + a - 32 
    li t4, 105 # 0 in ascii + 9 in ascii 
    li t5, 48
    li t6, 57
    
diz_for:
    lb t1, 0(t0)
    beqz t1, diz_end
    blt t1, t5, diz_inc_index # Se < di 0 in ascii -> sys
    ble t1, t6, diz_if_number # Se <= di 9 in ascii -> numero
    blt t1, s7, diz_inc_index # Se < A -> sys
    ble t1, s8, diz_if_letter # Se <= Z -> lettera
    blt t1, s9, diz_inc_index # Se < a -> sys
    ble t1, s10, diz_if_letter # Se <= z -> lettera

diz_inc_index:
    addi t0, t0, 1
    j diz_for    
 
diz_if_number:
    sub t1, t4, t1
    sb t1, 0(t0)
    j diz_inc_index 
    
diz_if_letter:
    sub t1, t3, t1
    sb t1, 0(t0)
    j diz_inc_index 

diz_end:
    jr ra


# ---------- decifratura dizionario ------

DECIF_DIZIONARIO:
addi sp, sp, -4
sw ra, 0(sp)

jal DIZIONARIO

lw ra, 0(sp)
addi sp, sp, 4
jr ra


# ---------- inversione ------

INVERSIONE:
inv_init:
    mv t0, a0          # carico plaintext
    mv t2, a0 
    
inv_push:
    lb t1, 0(t0)    # carico primo carattere plaintext    
    beqz t1, inv_pop
    
    addi t0, t0, 1
    addi sp, sp, -1
    sb t1, 0(sp)  # carico il carattere in cipher text

    j inv_push
    
inv_pop:
    beq t2, t0, inv_end
    
    lb t1, 0(sp)    # carico primo carattere plaintext 
    sb t1, 0(t2)  # carico il carattere in cipher text
    
    addi sp, sp, 1
    addi t2, t2, 1
    
    j inv_pop

inv_end:
    jr ra
    

# ---------- decif inversione ------

DECIF_INVERSIONE:
addi sp, sp, -4
sw ra, 0(sp)

jal INVERSIONE

lw ra, 0(sp)
addi sp, sp, 4
jr ra


#---------- UTILS ------

#funzione che mostra in console il contenuto di a2
print: 
    li a7, 4
    ecall
    mv t0, a0
    la a0, newline
    ecall
    mv a0, t0
    
    jr ra


#lunghezza stringa passata input in a2, output in a0
length:
    mv t0, zero

length_loop:
    add t1, t0, a1
    lb t2, 0(t1)					# Current charachter
    beqz t2, end_length_loop		# End of string
    addi t0, t0, 1
    j length_loop

end_length_loop:
    mv a0, t0
    jr ra
    
pow:
    addi sp, sp, -8
    sw a1, 4(sp)
    sw a2, 0(sp)
    li a1, 10 # base
    li a2, 1  # risultato finale
pow_loop:    
    beqz a0, pow_end
    mul a2, a2, a1
    addi a0, a0, -1
    j pow_loop
pow_end:
    mv a0, a2
    lw a1, 4(sp)
    lw a2, 0(sp)
    addi sp, sp, 8
    jr ra  
    
    