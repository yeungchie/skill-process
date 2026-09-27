useNamespace("ycSubProcess")


defclass(Elapsed () (
    mark()          ; -> string | nil
    getStart()      ; -> string | nil
    getEnd()        ; -> string | nil
    getSeconds()    ; -> int
    humanReadable() ; -> string
))

defmethod(printself (self(Elapsed))
    lsprintf("<%A object; %A>"
        className(self)
        cond(
            (self->getEnd()     self->humanReadable())
            (self->getStart()   "active")
            (t                  "none")
        )
    )
)

inScheme(
defmethod(initializeInstance (self(Elapsed) \@rest _args) let((_start_ts _end_ts _second _humanReadable)
    procedure(_error(t_formatString \@key method \@rest g_args "tgl")
        error("%A%s: %s"
            className(self)
            method && lsprintf(strcat("->" stringp(method) && "%s" || "%A") method) || ""
            apply('lsprintf t_formatString g_args)
        )
    )
    self->mark = lambda(()
        cond(
            (!_start_ts
                _start_ts = getCurrentTime()
            )
            (!_end_ts
                _end_ts = getCurrentTime()
            )
        )
    )
    self->getStart = lambda(()
        _start_ts
    )
    self->getEnd = lambda(()
        _end_ts
    )
    self->getSeconds = lambda(()
        unless(_second
            unless(_start_ts
                _error("elapsed time has not been started" ?method 'getSeconds)
            )
            unless(_end_ts
                _error("elapsed time has not been ended" ?method 'getSeconds)
            )
            _second = compareTime(_end_ts _start_ts)
        )
        _second
    )
    self->humanReadable = lambda(()
        unless(_humanReadable
            self->getSeconds()
            _humanReadable = cond(
                (_second == 0
                    "~0s"
                )
                (_second < 60
                    lsprintf("%ds" _second)
                )
                (_second < 3600
                    let((s)
                        lsprintf("%dm%s"
                            _second/60
                            if((s = remainder(_second 60)) == 0
                                ""
                                lsprintf("%ds" s)
                            )
                        )
                    )
                )
                (t
                    let((m s)
                        lsprintf("%dh%s%s"
                            _second/3600
                            if((m = remainder(_second 3600)/60) == 0
                                ""
                                lsprintf("%dm" m)
                            )
                            if((s = remainder(_second 60)) == 0
                                ""
                                lsprintf("%ds" s)
                            )
                        )
                    )
                )
            )
        )
        _humanReadable
    )
))
)


unuseNamespace("ycSubProcess")

; END