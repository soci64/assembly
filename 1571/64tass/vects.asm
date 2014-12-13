
        *=$ffe6
        .word    format
        .word    trnoff
ublock  .word    ublkrd
        .word    ublkwt
        .word    $0500   ; links to buffer #2
        .word    $0503
        .word    $0506
        .word    $0509
        .word    $050c
        .word    $050f

        *=$fffa
        .word    nnmi
        .word    dskint
        .word    sysirq
