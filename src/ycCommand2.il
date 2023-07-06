;--------------------------
; Program  : skill-process(ycCommand2.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommand2(\@key row("") type('std) chomp \@rest cmd "Ssgl")
    let((result output)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        when(result = apply('ycCommandList2 append(list(?type type) cmd))
            output = if(type == 'all
                mapcar(lambda((x) buildString(x row)) result)
                buildString(result row)
            )
        )
        when(chomp && output
            output = if(listp(output) output list(output))
            output = foreach(mapcar x output
                when(x pcreReplace(pcreCompile("\n$") x "" 0))
            )
        )
        output
    )
)

; END