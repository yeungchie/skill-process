;--------------------------
; Program  : skill-process(ycCommand2.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommand2(\@key row("") join(" ") type('std) chomp \@rest cmd "SSsgl")
    let((result output)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        when(result = apply('ycCommandList2 append(list(?join join ?type type) cmd))
            output = if(type == 'all
                mapcar(lambda((x) buildString(x row)) result)
                buildString(result row)
            )
        )
        when(chomp && output
            output = pcreReplace(pcreCompile("\n$") output "" 0)
        )
        output
    )
)

; END