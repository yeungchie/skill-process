;--------------------------
; Program  : skill-process(ycCommandList.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommandList2(\@key join(" ") type('std) \@rest cmd "Ssl")
    let((cid stdout errout)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        cmd = buildString(
            foreach(mapcar x cmd
                pcreReplace(pcreCompile("[\"]") artMakeString(x) "\\\\\\0" 0)
            )
            join
        )
        cid = ipcBeginProcess(
            cmd
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