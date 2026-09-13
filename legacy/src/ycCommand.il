;--------------------------
; Program  : skill-process(ycCommand.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommand(\@key join(" ") row("\n") \@rest cmd "SSl")
    let((result)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        when(result = apply('ycCommandList
                ?join join
                cmd
            )
            buildString(result row)
        )
    )
)

; END