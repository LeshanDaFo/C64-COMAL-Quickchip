; ###############################################################
; #                                                             #
; #  C64 COMAL80 QUICKCHIP EXTENSION SOURCE CODE                #
; #  Version 1.0 (2023.08.26)                                   #
; #  Copyright (c) 2023 Claus Schlereth                         #
; #                                                             #
; #  This version of the source code is under MIT License       #
; #                                                             #
; #  This source code can be found at:                          #
; #  https://github.com/LeshanDaFo/C64-COMAL-Quickchip          #
; #  This source code is bsed on the existing Modules           #
; #  found in several locations in the Internet                 #
; #                                                             #
; ###############################################################

FNDPAR  =   $c896               ;Find parameter (asm.calls)
RESET   =   $ca29               ;reset program pointers
!source"code/c64symb.asm"

*= $8000
start
    !word COLD
    !word WARM

    !pet "CBM80comal"

    !by >start                  ; $80
    !by PAGE5 + ROMMED          ; PAGE 5 =$84 + %00010000 <> $94

    !word $bfff;.end                  ; the program end address
    !word signal                ; the address of the signal handler

; start of package table
; package 1
    !pet $09, "quickchip"       ; char amount, 'name'
    !word proct1                ; proc's name table address
    !word init1                 ; package init address (here only RTS)
    !by $00

; table of procedure names
; name length    cheader pointer
 ; $8023
proct1
    !pet $09,"load'fast"
    !word loadfast_h
    !by $00

; $8030
loadfast_h    !by PROC, <loadfast,>loadfast,    $01,$73, ENDPRC ;$8036

; end package table

; $8036
loadfast
L8036
    LDA #$01
    JSR FNDPAR                  ;Find parameter (asm.calls)
    LDY #$01                    ;index
    LDA (COPY1),Y
    BNE L8044                   ;branch to aktivate fast load

    LDX #<L8100
    !by $2c
L8044
    LDX #<L8107
; with the HIGH-BYTE have to be careful that it is on the same page (here; $81xx)
    LDY #>L8100
    LDA #PAGE5                   ;#$84

    STA RESET+3
    STX RESET+4
    STY RESET+5

; $8053
init1
    RTS

; $8054
signal 
    CPY #$01                    ; POWER2, after power on
    BNE init1                   ; rts
    JSR L8044
    LDY #msgend-msgstart-1      ; msg pointer
loop
; copy message to $c000 - 
    LDA msgstart,Y              ; copy chars
    STA $C000,Y                 ;
    DEY
    BPL loop
; prepare msg pointer into $c865-$c867
    LDA #msgend-msgstart        ; char amount
    STA $C865
    LDA #$00                    ; msg address low byte
    STA $C866
    LDA #$C0                    ; msg address high byte
    STA $C867
    RTS    

fill1
    !fill $8100-fill1,$ff

; $8100
; it seems that the following part has something todo with the RESET routine
; but i'm not sure what happen here.
L8100
    JSR $CAEE
    STA ($BB,X)
    LDA ($60,X)
L8107
    JSR $CAEE
    STA ($BB,X)
    LDA ($EA,X)

    TSX
    LDA $0108,X
    CMP #$8C
    BNE L8169
    LDA $0107,X
    CMP #$BA
    BNE L8169
    CLC
    ADC #$04
    STA $0107,X
    JSR L8245
    CPY #$A0
    BNE L8130
    CPX #$EA
    BNE L816A
    BEQ L813E
L8130
    CPY #$3F
    BNE L816A
    CPX #$E8
    BNE L816A
    JSR L81DA
    JMP L8141
---------------------------------
L813E
    JSR L816F
L8141
    SEI
    LDA $D011
    AND #$EF
    STA $D011
    LDA #$FF
    STA $C01F
    LDA $C7DE
    STA $C0FE
    LDA $C7DF
    STA $C0FF
    LDA #$E0
    STA $C7DE
    LDA #$C0
    STA $C7DF
    LDX #$08
    LDA #$C0
L8169
    RTS
---------------------------------
L816A
    LDX #$4E
    LDA #$CE
    RTS
---------------------------------
L816F
    LDY #$00
-   LDA L8A00,Y
    STA $C000,Y
    INY
    BNE -
L817A
; copy to floppy memory
    LDA $BA
    JSR $FFB1
    LDA #$6F
    JSR $FF93
    LDA #$4D
    JSR $FFA8
    LDA #$2D
    JSR $FFA8
    LDA #$57
    JSR $FFA8
    TYA
    JSR $FFA8
    LDA #$04
    JSR $FFA8
    LDA #$20
    JSR $FFA8
    LDX #$20
L81A3
    LDA L8B00,Y
    JSR $FFA8
    INY
    DEX
    BNE L81A3
    JSR $FFAE
    CPY #$C0
    BNE L817A
; do memory execute
    LDA $BA
    JSR $FFB1
    LDA #$6F
    JSR $FF93
    LDA #$4D
    JSR $FFA8
    LDA #$2D
    JSR $FFA8
    LDA #$45
    JSR $FFA8
    LDA #$81
    JSR $FFA8
    LDA #$04
    JSR $FFA8
    JMP $FFAE
---------------------------------
; copy c64 fast loade to $c000
L81DA
    LDY #$00
L81DC
    LDA L8A00,Y
    STA $C000,Y
    INY
    BNE L81DC
L81E5
; memory write to floppy
    LDA $BA
    JSR $FFB1
    LDA #$6F
    JSR $FF93
    LDA #$4D
    JSR $FFA8
    LDA #$2D
    JSR $FFA8
    LDA #$57
    JSR $FFA8
    TYA
    JSR $FFA8
    LDA #$04
    JSR $FFA8
    LDA #$20
    JSR $FFA8
    LDX #$20
L820E
; copy from c64 memory to floppy memory
    LDA L8C00,Y
    JSR $FFA8
    INY
    DEX
    BNE L820E
    JSR $FFAE
    CPY #$C0
    BNE L81E5
; memory execute in floppy
    LDA $BA
    JSR $FFB1
    LDA #$6F
    JSR $FF93
    LDA #$4D
    JSR $FFA8
    LDA #$2D
    JSR $FFA8
    LDA #$45
    JSR $FFA8
    LDA #$00
    JSR $FFA8
    LDA #$04
    JSR $FFA8
    JMP $FFAE
---------------------------------
; floppy memory read
L8245
    LDA $BA
    JSR $FFB1
    LDA #$6F
    JSR $FF93
    LDA #$4D
    JSR $FFA8
    LDA #$2D
    JSR $FFA8
    LDA #$52
    JSR $FFA8
    LDA #$FC
    JSR $FFA8
    LDA #$FF
    JSR $FFA8
    LDA #$02
    JSR $FFA8
    JSR $FFAE
    LDA $BA
    JSR $FFB4
    LDA #$6F
    JSR $FF96
    JSR $FFA5
    TAY
    JSR $FFA5
    TAX
    JMP $FFAB

fill2
    !fill $8500-fill2,$ff

; $8500
L8500
    LDA $C102
    CLC
    ADC #$12
    JSR L854E
    STX $0201
    STY $0202
    LDY #$00
L8511
    LDA L8560,Y
    STA $0203,Y
    INY
    CPY #$0C
    BNE L8511
    LDA $C103
    JSR L854E
    STX $020F
    STY $0210
    LDA #$2C
    STA $0211
    LDA $C104
    JSR L854E
    STX $0212
    STY $0213
    LDA #$13
    STA $0200
    LDA $C102
    CLC
    ADC #$DA
    LDX #$00
    LDY #$00

    JSR GOTO                    ;jmp to another page
    !by PAGE3                   ;$82
    !by $E0                     ;Address low byte
    !by $C0                     ;Adress high byte

L854E    
    LDX #$FF
L8550
    INX
    SEC
    SBC #$0A
    BCS L8550
    ADC #$0A
    ORA #$30
    TAY
    TXA
    ORA #$30
    TAX
    RTS   

L8560
!pet ",read error,"
msgstart
L856c
!text "  dIETER wOHLLEBEN  4400 mUENSTER    ";,$64,"ieter ",$77,"ohlleben  4400 ",$6D,"uenster    "
!by $11,$0d
!text " kOENIGSBERGER sTR. 59          ";!pet $20,$6B,"oenigsberger ",$73,"tr. 59          "
!by $11,$0D
msgend
fill3
    !fill $8A00-fill3,$ff

L8A00
    JSR $C026
    LDA #$01
    STA $C01F
    INC $C01F
    BEQ L8A00
    LDX #$00
    LDA $C100
    BNE L8A1E
    LDA $C01F
    CMP $C101
    BCC L8A1E
    LDX #$40
L8A1E
    LDA $C1FF
    STX $90
    BIT $90
    RTS
---------------------------------
    STY $C0FD
    SEI
L8A2A
    LDA $DD00
    AND #$0F
    TAY
    ORA #$10
    STA $DD00
    NOP
    NOP
    STY $DD00
    LDX #$04
L8A3C
    BIT $DD00
    BPL L8A4D
    INY
    BPL L8A3C
    BMI L8A2A
L8A46
    LDX #$04
L8A48
    BIT $DD00
    BMI L8A48
L8A4D
    PHA
    PLA
    PHA
    PLA
    PHA
    PLA
    CMP ($F0,X)
L8A55
    LDA $DD00
    ASL
    ROL $FF
    ASL
    ROL $FF
    CMP $FF
    NOP
    NOP
    DEX
    BNE L8A55
    LDA $FF
    STA $C100
    INC $C068
    BNE L8A46
    LDA $C100
    BNE L8A8D
    LDA $C0FE
    STA $C7DE
    LDA $C0FF
    STA $C7DF
    LDA $D011
    ORA #$10
    STA $D011
    LDA $C101
    BEQ L8A91
L8A8D
    LDY $C0FD
    RTS
---------------------------------
L8A91
    JSR GOTO                    ;jmp to another page
    !by PAGE5                   ;$84
    !by <L8500                  ;Address low byte
    !by >L8500                  ;Address high byte
 
fill4
!fill $8AE0-fill4,$ff

; $8ae0
    PHA
    LDA $C0FE
    STA $C7DE
    LDA $C0FF
    STA $C7DF
    LDA $D011
    ORA #$10
    STA $D011
    PLA
    JMP ($C0FE)
---------------------------------
    !by $ff,$ff,$ff,$ff,$ff,$ff,$ff

L8B00
    LDA #$03
    STA $31
    LDA $22
    CMP $08
    BNE L8B2C
    JSR $F50A
L8B0D
    BVC L8B0D
    CLV
    LDA $1C01
    STA ($30),Y
    INY
    BNE L8B0D
    LDY #$BA
L8B1A
    BVC L8B1A
    CLV
    LDA $1C01
    STA $0100,Y
    INY
    BNE L8B1A
    JSR $F8E0
    JMP $0437
---------------------------------
L8B2C
    LDA #$00
    !by $2c
L8B2F
    LDA #$01
    !by $2c
L8B32
    LDA #$01
    JMP $F969
---------------------------------
    LDA $0301
    STA $09
    LDA $0300
    STA $08
L8B41
    LDA $1800
    BMI L8B32
    BEQ L8B41
L8B48
    LDA $0300
    STA $21
    LDX #$04
    LDA #$02
    STA $1800
L8B54
    LDA #$00
    ASL $21
    ROL
    ASL $21
    ROL
    TAY
    LDA $047D,Y
    STA $1800
    DEX
    BNE L8B54
    PHA
    PLA
    PHA
    PLA
    PHA
    PLA
    LDA #$00
    STA $1800
    INC $0449
    BNE L8B48
    LDA $08
    BEQ L8B2F
    JMP $0400
---------------------------------
    !by $0a,$02,$08,$00
---------------------------------
    LDY #$00
    STY $1800
    LDA $18
    STA $08
    LDA $19
    STA $09
L8B8E
    LDA #$E0
    STA $01
L8B92
    LDA $01
    BMI L8B92
    BEQ L8B8E
    CMP #$01
    BEQ L8BBD
    LDA #$00
    STA $0300
    STA $0301
    LDA $01
    STA $0302
    LDA $18
    STA $0303
    LDA $19
    STA $0304
    LDA #$60
    STA $0476
    SEI
    JSR $0441
    CLI
L8BBD
    RTS

fill5
!fill $8C00-fill5,$ff

L8C00
    LDA #$30
    STA $02
    LDA $4C2A
    STA $4C0C
    LDA $4C2B
    STA $4C18
    LDA #$80
    ORA $54
    STA $4C00
L8C17
    LDA $4C00
    BMI L8C17
    CMP #$01
    BEQ L8C3D
    STA $4002
    LDA #$00
    STA $4000
    STA $4001
    LDA $4C0C
    STA $4003
    LDA $4C18
    STA $4004
    JMP $413D
---------------------------------
    JMP $419D
---------------------------------
L8C3D
    !by $78,$DF,$00,$FD,$BF,$00,$F6

L8C44
    LDA $4000
    STA $41
    LDX #$04
    LDA #$00
    STA $02
L8C4F
    LDA #$00
    ASL $41
    ROL
    ASL $41
    ROL
    TAY
    LDA $41A3,Y
    STA $0002
    DEX
    BNE L8C4F
    PHA
    PLA
    PHA
    PLA
    PHA
    PLA
    LDA #$30
    STA $02
    INC $4145
    BNE L8C44
    CLI
    LDA $4000
    BEQ L8C9D
    STA $4C0C
    LDX $54
    CMP $4E88,X
    BEQ L8C94
    SEC
    SBC $4E88,X
    BPL L8C88
    EOR #$FE
L8C88
    CMP #$01
    BNE L8C8F
    LDA #$02
    !by $2C
L8C8F
    LDA #$04
    STA $4E8C
L8C94
    LDA $4001
    STA $4C18
    JMP $4110
---------------------------------
L8C9D
    LDA #$05
    STA $4E8C
    RTS

    !by $00,$10,$20,$30

fill6
!fill $bfff-fill6,$ff

.end
    !by $ff