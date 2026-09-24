assert(ycSubProcess::runJob("test -r /") == t)
assert(ycSubProcess::runJob("test -w /") == nil)

; END