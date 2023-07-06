;--------------------------
; Program  : skill-process(ycCommand.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommand(\@key row("\n") \@rest cmd "Sl")
    let((result)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        when(result = apply('ycCommandList cmd)
            buildString(result row)
        )
    )
)

; END