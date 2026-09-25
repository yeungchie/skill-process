assert(ycSubProcess::createJob("echo 123")->await() == "123\n")

let((aj)
    aj = ycSubProcess::createJob("python3 -iqu")
    errset({
        assert(aj->state() == 'None)
        assert(aj->start() == aj)
        assert(aj->state() == 'Active)

        assert(aj->print("print(123)") == aj)
        aj->wait(1)
        assert(aj->stdout->last() == "123\n")

        assert(aj->print("print(456)") == aj)
        aj->wait(1)
        assert(aj->stdout->last() == "456\n")

        assert(aj->print("print(789)") == aj)
        aj->wait(1)
        assert(aj->stdout->last() == "789\n")

        assert(aj->stdout->size() == 3)
        assert(aj->stdout->isEmpty() == nil)
        
        assert(aj->stdout->text() == "123\n456\n789\n")
        assert(aj->stdout->shift() == "123\n")
        assert(aj->stdout->shift() == "456\n")
        assert(aj->stdout->shift() == "789\n")
        assert(aj->stdout->text() == "")

        assert(aj->stdout->isEmpty() == t)
    } t)
    when(aj->state() == 'Active
        aj->kill()
    )
    assert(aj->state() == 'Dead)
)

; END