;--------------------------
; Program  : skill-process(ycCommandList.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommandList(\@key join(" ") \@rest cmd "Sl")
    unless(cmd
        ycError("too few arguments - %A\n" cmd)
    )
    artSystemWithRead(buildString(mapcar('artMakeString cmd) join))
)

; END