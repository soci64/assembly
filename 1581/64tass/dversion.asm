
        *=$8000
        .fill $8000,$ff

        *=$8000                 ; start of ROM  03/20/87  csum = $8E8B

signature_lo
        .byte  $4d
signature_hi
        .byte  $19

cchksm  .byte  $cd

dversion
        .byte  $01

