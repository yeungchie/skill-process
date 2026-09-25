useNamespace("ycSubProcess")


procedure(runJob(g_arg \@rest g_args "gg")  ; -> t | nil
    let((aj)
        (aj = apply('createJob g_arg ?verbose t g_args))->await()
        prog1(
            aj->returncode == 0
            aj->returncode || aj->kill()
        )
    )
)


procedure(createJob(g_arg \@key callback userData verbose \@rest g_args "ggggl")  ; -> AsyncJob
    AsyncJob(
        buildString(foreach(mapcar x cons(g_arg g_args)
            stringp(x) && x || lsprintf("%A" x)
        ))
        ?callback   callback
        ?userData   userData
        ?verbose    verbose
    )
)


procedure(AsyncJob(t_cmd \@key callback userData verbose "tggg")  ; -> AsyncJob
    makeInstance('AsyncJob
        ?cmd        t_cmd
        ?callback   callback
        ?userData   userData
        ?verbose    verbose && t
    )
)


defclass(AsyncJob () (
    ; argument
    cmd(
        \@initarg cmd
    )
    callback(
        \@initarg callback
        \@initform lambda((event_type async_job "sg") nil)
    )
    userData(
        \@initarg userData
        \@initform nil
    )
    verbose(
        \@initarg verbose
        \@initform nil
    )

    ; parameter
    ipcId(
        \@initform nil  ; ipcId
    )
    returncode(
        \@initform nil  ; int
    )
    elapsed(
        \@initform makeInstance('Elapsed)
    )

    ; stram
    stdout(
        \@initform makeInstance('Stream)
    )
    stderr(
        \@initform makeInstance('Stream)
    )

    ; method
    start()     ; begin
    wait()      ; wait for process to done
    await()     ; auto begin and wait for process to done
    kill()      ; send SIGKILL
    state()     ; return status: 'None 'Active 'Dead 'Stopped
    stop()      ; stop like Ctrl+Z
    continue()  ; continue like fg
    print()     ; write to stdin
    close()     ; close input channel
    signal()    ; send signal: 'INT 'TERM 'QUIT 'KILL
    sleep()     ; causes the parent process to be delayed
))

defmethod(printself (self(AsyncJob))
    lsprintf("<%A object; status=%A, returncode=%A>"
        className(self)
        self->state()
        self->returncode
    )
)

inScheme(let((_rsrec)

_rsrec = pcreCompile("[\"\\\\$]")

procedure(_rstring(s "t")  ; -> raw string
    pcreReplace(_rsrec s "\\\\\\0" 0)
)

defmethod(initializeInstance (self(AsyncJob) \@rest _args)
    procedure(_error(t_formatString \@key method \@rest g_args "tgl")
        error("%A%s: %s"
            className(self)
            method && lsprintf(strcat("->" stringp(method) && "%s" || "%A") method) || ""
            apply('lsprintf t_formatString g_args)
        )
    )
    procedure(_checkStarted(\@optional method "g")
        unless(self->ipcId
            _error("job has not started, current status is '%s" self->state() ?method method)
        )
    )
    self->start = lambda(()  ; -> self
        when(self->ipcId
            _error("job already started, current status is '%s" self->state() ?method 'start)
        )
        when(self->callback
            errset(funcall(self->callback 'beforeBegin self) t)
        )
        self->ipcId = ipcBeginProcess(_rstring(self->cmd) ""
            lambda((cid data)
                self->stdout->push(data)
                when(self->verbose
                    fprintf(inSkill(IL::stdout) "%s" data)
                )
                when(self->callback
                    funcall(self->callback 'stdout self)
                )
            )
            lambda((cid data)
                self->stderr->push(data)
                when(self->verbose
                    fprintf(inSkill(IL::stderr) "%s" data)
                )
                when(self->callback
                    funcall(self->callback 'stderr self)
                )
            )
            lambda((cid code)
                self->returncode = code
                self->elapsed->mark()
                when(self->callback
                    funcall(self->callback 'post self)
                )
            )
        )
        self->elapsed->mark()
        ipcWaitForProcess(self->ipcId)
        when(self->callback
            errset(funcall(self->callback 'afterBegin self) t)
        )
        self
    )
    self->wait = lambda((\@optional x_timeout(1000000) x_interval(30) "xx")  ; -> self
        _checkStarted('wait)
        ipcWait(self->ipcId x_interval x_timeout)
        self
    )
    self->await = lambda((\@key check)  ; -> string
        unless(self->ipcId
            self->start()
        )
        while(!self->returncode
            self->wait()
        )
        when(check && (self->returncode != 0)
            let((info)
                unless(blankstrp(info = self->stderr->text())
                    fprintf(inSkill(IL::stderr) "%s" info)
                )
            )
            _error("job failed, returncode is %d"
                self->returncode
                ?method 'await
            )
        )
        self->stdout->text()
    )
    self->kill = lambda(()  ; -> t / nil
        _checkStarted('kill)
        ipcKillProcess(self->ipcId)
    )
    self->state = lambda(()  ; -> 'None | 'Active | 'Dead | 'Stopped
        self->ipcId && self->ipcId->state || 'None
    )
    self->stop = lambda(()  ; -> t | nil
        _checkStarted('stop)
        ipcStopProcess(self->ipcId)
    )
    self->continue = lambda(()  ; -> t | nil
        _checkStarted('continue)
        ipcContProcess(self->ipcId)
    )
    self->print = lambda((t_formatString \@key end("\n") \@rest g_args "ttl")  ; -> self
        _checkStarted('print)
        ipcWriteProcess(self->ipcId
            strcat(apply('lsprintf t_formatString g_args) end)
        ) || _error("job process has expired, current status is '%s" self->state() ?method 'print)
        self
    )
    self->close = lambda(()  ; -> t | nil
        _checkStarted('close)
        ipcCloseProcess(self->ipcId)
    )
    self->signal = lambda((s_signal "s")  ; -> t | nil
        _checkStarted('signal)
        ipcSignalProcess(self->ipcId s_signal)
    )
    self->sleep = lambda((\@optional n_second(0) "n")  ; -> self
        ipcSleepMilli(fix2(n_second * 1e3))
        self
    )
    t
)

))


unuseNamespace("ycSubProcess")

; END