useNamespace("ycSubProcess")


defclass(Elapsed () (
    mark()          ; -> t
    getStart()      ; -> nil | string
    getEnd()        ; -> nil | string
    getSeconds()    ; -> int
    humanReadable() ; -> string
))

defmethod(printself (self(Elapsed)) let((st)
    lsprintf("<%A object; %A>"
        className(self)
        cond(
            (self->getEnd()     self->humanReadable())
            (self->getStart()   "active")
            (t                  "none")
        )
    )
))

inScheme(
defmethod(initializeInstance (self(Elapsed) \@rest _args) let((_start_ts _end_ts _second)
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
        t
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
        self->getSeconds()
        cond(
            (_second == 0
                "~0s"
            )
            (_second < 60
                lsprintf("%ds" _second)
            )
            (_second < 3600
                lsprintf("%dm%2ds" _second/60 remainder(_second 60))
            )
            (t
                lsprintf("%dh%2dm%2ds"
                    _second/3600
                    remainder(_second 3600)/60
                    remainder(_second 60)
                )
            )
        )
    )
))
)


unuseNamespace("ycSubProcess")

; END