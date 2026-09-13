;--------------------------
; Program  : skill-process(ycCommand2.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommand2(
      \@key
        interval(30)
        timeout(300)
        row("")
        join(" ")
        type('std)
        chomp
      \@rest
        cmd
      "xxSSsgl"
    )
    let((result output)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        when(result = apply('ycCommandList2
                ?interval interval
                ?timeout timeout
                ?join join
                ?type type
                cmd
            )
            output = if(type == 'all
                foreach(mapcar x result
                    pairp(x) && buildString(x row) || x
                )
                pairp(result) && buildString(result row) || result
            )
        )
        when(chomp && output
            output = case(type(output)
                (list
                    foreach(mapcar x output
                        stringp(x) && pcreReplace(pcreCompile("\n$") x "" 1) || x
                    )
                )
                (string
                    pcreReplace(pcreCompile("\n$") output "" 1)
                )
            )
        )
        output
    )
)

; END