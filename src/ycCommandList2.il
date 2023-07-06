;--------------------------
; Program  : skill-process(ycCommandList.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommandList2(\@key type('std) \@rest cmd "sl")
    let((cid stdout errout)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        cid = ipcBeginProcess(
            buildString(mapcar('artMakeString cmd) " ")
            ""
            lambda((cid data)
                stdout = cons(data stdout)
            )
            lambda((cid data)
                errout = cons(data errout)
            )
        )
        ipcWait(cid)
        when(ipcIsAliveProcess(cid)
            ipcCloseProcess(cid)
        )
        stdout = reverse(stdout)
        errout = reverse(errout)
        case(type
            (all  list(stdout errout))
            (std  stdout)
            (err  errout)
            (t    nil)
        )
    )
)

; END