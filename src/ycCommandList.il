;--------------------------
; Program  : skill-process(ycCommandList.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommandList(\@rest cmd "g")
    unless(cmd
        ycError("too few arguments - %A\n" cmd)
    )
    artSystemWithRead(buildString(mapcar('artMakeString cmd) " "))
)

; END