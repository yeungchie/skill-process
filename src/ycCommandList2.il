;--------------------------
; Program  : skill-process(ycCommandList.il)
; Language : Cadence Skill
; Author   : YEUNGCHIE
;--------------------------

procedure(ycCommandList2(
      \@key
        interval(30)
        timeout(300)
        join(" ")
        type('std)
      \@rest
        cmd
      "xxSsl"
    )
    let((cid time waited stdout errout status)
        unless(cmd
            ycError("too few arguments - %A\n" cmd)
        )
        cmd = buildString(
            foreach(mapcar x cmd
                pcreReplace(pcreCompile("[\"\\$]") artMakeString(x) "\\\\\\0" 0)
            )
            join
        )
        cid = ipcBeginProcess(
            cmd
            ""
            lambda((_cid data)
                stdout = cons(data stdout)
            )
            lambda((_cid data)
                errout = cons(data errout)
            )
        )

        time = getCurrentTime()
        ipcWait(cid interval timeout)
        timeout += compareTime(time getCurrentTime())
        ipcSignalProcess(cid 'TERM)
        if(timeout > 0
            ipcWait(cid interval timeout)
            ipcSleepMilli(50)
        )


        when(ipcIsAliveProcess(cid)
            ipcKillProcess(cid)
        )
        status = ipcGetExitStatus(cid)
        stdout = reverse(stdout)
        errout = reverse(errout)
        case(type
            (all    list(stdout errout status))
            (std    stdout)
            (err    errout)
            (status status)
            (t      nil)
        )
    )
)

; END