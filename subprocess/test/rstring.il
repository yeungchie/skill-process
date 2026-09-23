assert(ycSubProcess::createJob("echo -n '123'")->await() == "123")
assert(ycSubProcess::createJob("echo -n '\"123\"'")->await() == "\"123\"")
assert(ycSubProcess::createJob("echo -n '\"1\\23\"'")->await() == "\"1\\23\"")
assert(ycSubProcess::createJob("echo -n $HOME")->await() == getShellEnvVar("HOME"))
assert(ycSubProcess::createJob("echo -n '$HOME'")->await() == "$HOME")

; END
