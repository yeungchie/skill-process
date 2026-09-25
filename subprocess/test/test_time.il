assert(ycSubProcess::createJob("sleep 0")->start()->wait()->elapsed->getSeconds() <= 1)
assert(ycSubProcess::createJob("sleep 1")->start()->wait()->elapsed->getSeconds() <= 2)

; END