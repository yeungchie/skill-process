useNamespace("ycSubProcess")
errset({


procedure(runJob(cmd "t")  ; -> str
    let((aj done)
        aj = AsyncJob(cmd
            ?handle lambda((htype aj)
                case(htype
                    (stdout
                        fprintf(poport "%s" aj->stdout->last())
                    )
                    (stderr
                        fprintf(errport "%s" aj->stderr->last())
                    )
                )
            )
        )
        aj->start()
        errset(aj->wait() t)
        prog1(
            aj->returncode == 0
            aj->returncode || aj->kill()
        )
    )
)


procedure(AsyncJob(cmd \@key handle "tg")  ; -> AsyncJob    
    makeInstance('AsyncJob ?cmd cmd ?handle handle)
)


defclass(AsyncJob () (
    ; argument
    cmd(
        \@initarg cmd
    )
    handle(
        \@initarg handle
        \@initform lambda((handleType aj "sg") nil)  ; aj: AsyncJob
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
    print()     ; write to stdin
    stop()      ; stop like Ctrl+Z
    continue()  ; continue like fg
    close()     ; close input channel
    kill()      ; send SIGKILL
    signal()    ; send signal: 'INT 'TERM 'QUIT 'KILL
    state()     ; return status: 'None 'Active 'Dead 'Stopped
    wait()      ; wait for process to done
    await()     ; auto begin and wait for process to done
))

defmethod(printself (obj(AsyncJob))
    lsprintf("<%A object; status=%A, ipcId=%A, returncode=%A>"
        className(obj)
        obj->state()
        obj->ipcId
        obj->returncode
    )
)

inScheme(
defmethod(initializeInstance \@before (obj(AsyncJob) \@rest _args)
    unless(slotBoundp(obj 'start)
        obj->start = lambda(()
            when(obj->ipcId
                ycError("job already started - %A" obj)
            )
            obj->ipcId = ipcBeginProcess(obj->cmd ""
                lambda((cid data)
                    obj->stdout->push(data)
                    when(obj->handle
                        funcall(obj->handle 'stdout obj)
                    )
                    t
                )
                lambda((cid data)
                    obj->stderr->push(data)
                    when(obj->handle
                        funcall(obj->handle 'stderr obj)
                    )
                    t
                )
                lambda((cid code)
                    obj->returncode = code
                    when(obj->handle
                        funcall(obj->handle 'post obj)
                    )
                    t
                )
            )
            ipcWaitForProcess(obj->ipcId)
        )
    )
    unless(slotBoundp(obj 'print)
        obj->print = lambda((fmt \@key end("\n") \@rest args "ttl")
            when(obj->ipcId
                ipcWriteProcess(obj->ipcId strcat(apply('lsprintf fmt args) end))
            )
        )
    )
    unless(slotBoundp(obj 'stop)
        obj->stop = lambda(()
            when(obj->ipcId
                ipcStopProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'continue)
        obj->continue = lambda(()
            when(obj->ipcId
                ipcContProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'close)
        obj->close = lambda(()
            when(obj->ipcId
                ipcCloseProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'kill)
        obj->kill = lambda(()
            when(obj->ipcId
                ipcKillProcess(obj->ipcId)
            )
        )
    )
    unless(slotBoundp(obj 'signal)
        obj->signal = lambda((signal "s")
            when(obj->ipcId
                ipcSignalProcess(obj->ipcId signal)
            )
        )
    )
    unless(slotBoundp(obj 'state)
        obj->state = lambda(()
            obj->ipcId && obj->ipcId->state || 'None
        )
    )
    unless(slotBoundp(obj 'wait)
        obj->wait = lambda((\@optional timeout(1000000) interval(30) "xx")
            when(obj->ipcId
                ipcWait(obj->ipcId interval timeout)
            )
        )
    )
    unless(slotBoundp(obj 'await)
        obj->await = lambda((\@key check)
            unless(obj->ipcId
                obj->start()
            )
            unless(obj->returncode
                obj->wait()
            )
            when(check && (obj->returncode != 0)
                let((info)
                    unless(blankstrp(info = obj->stderr->text())
                        fprintf(errport "%s" info)
                    )
                )
                ycError("job failed, returncode is %d" obj->returncode)
            )
            obj->stdout->text()
        )
    )
    t
)
)


} t)
unuseNamespace("ycSubProcess")

; END