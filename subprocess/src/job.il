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
        \@initform nil
    )
    returncode(
        \@initform nil
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
    _error()
))

defmethod(printself (obj(AsyncJob))
    lsprintf("<%A object; status=%A, returncode=%A>"
        className(obj)
        obj->state()
        obj->returncode
    )
)

inScheme(
defmethod(initializeInstance \@before (obj(AsyncJob) \@rest _args)
    unless(slotBoundp(obj 'start)
        obj->start = lambda(()  ; -> t | nil
            when(obj->ipcId
                obj->_error("job already started, current status is '%s"
                    obj->state()
                    ?method 'start
                )
            )
            obj->ipcId = ipcBeginProcess(obj->cmd ""
                lambda((cid data)
                    obj->stdout->push(data)
                    when(obj->verbose
                        fprintf(inSkill(IL::stdout) "%s" data)
                    )
                    when(obj->callback
                        funcall(obj->callback 'stdout obj)
                    )
                    t
                )
                lambda((cid data)
                    obj->stderr->push(data)
                    when(obj->verbose
                        fprintf(inSkill(IL::stderr) "%s" data)
                    )
                    when(obj->callback
                        funcall(obj->callback 'stderr obj)
                    )
                    t
                )
                lambda((cid code)
                    obj->returncode = code
                    when(obj->callback
                        funcall(obj->callback 'post obj)
                    )
                    t
                )
            )
            ipcWaitForProcess(obj->ipcId)
        )
    )
    unless(slotBoundp(obj 'wait)
        obj->wait = lambda((\@optional x_timeout(1000000) x_interval(30) "xx")  ; -> t | nil
            when(obj->ipcId
                ipcWait(obj->ipcId x_interval x_timeout)
            )
        )
    )
    unless(slotBoundp(obj 'await)
        obj->await = lambda((\@key check)  ; -> string
            unless(obj->ipcId
                obj->start()
            )
            unless(obj->returncode
                obj->wait()
            )
            when(check && (obj->returncode != 0)
                let((info)
                    unless(blankstrp(info = obj->stderr->text())
                        fprintf(inSkill(IL::stderr) "%s" info)
                    )
                )
                obj->_error("job failed, returncode is %d"
                    obj->returncode
                    ?method 'await
                )
            )
            obj->stdout->text()
        )
    )
    unless(slotBoundp(obj 'kill)
        obj->kill = lambda(()  ; -> t / nil
            when(obj->ipcId
                ipcKillProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'state)
        obj->state = lambda(()  ; -> 'None | 'Active | 'Dead | 'Stopped
            obj->ipcId && obj->ipcId->state || 'None
        )
    )
    unless(slotBoundp(obj 'stop)
        obj->stop = lambda(()  ; -> t | nil
            when(obj->ipcId
                ipcStopProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'continue)
        obj->continue = lambda(()  ; -> t | nil
            when(obj->ipcId
                ipcContProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'print)
        obj->print = lambda((t_formatString \@key end("\n") \@rest g_args "ttl")  ; -> t | nil
            when(obj->ipcId
                ipcWriteProcess(obj->ipcId
                    strcat(apply('lsprintf t_formatString g_args) end)
                )
            )
        )
    )
    unless(slotBoundp(obj 'close)
        obj->close = lambda(()  ; -> t | nil
            when(obj->ipcId
                ipcCloseProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'signal)
        obj->signal = lambda((s_signal "s")  ; -> t | nil
            when(obj->ipcId
                ipcSignalProcess(obj->ipcId s_signal)
            )
        )
    )
    unless(slotBoundp(obj '_error)
        obj->_error = lambda((t_formatString \@key method \@rest g_args "tgl")
            error("%A%s: %s"
                className(obj)
                method && lsprintf(strcat("->" stringp(method) && "%s" || "%A") method) || ""
                apply('lsprintf t_formatString g_args)
            )
        )
    )
    t
)
)


unuseNamespace("ycSubProcess")

; END