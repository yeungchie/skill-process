useNamespace("ycSubProcess")


defclass(Stream () (
    _data(
        \@initform nil
    )
    push()  ; -> t
    last()  ; -> str | nil
    shift()  ; -> str | nil
    text()  ; -> str
    size()  ; -> int
    isEmpty()  ; -> t | nil
))

defmethod(printself (obj(Stream))
    lsprintf("<%A object; size=%d>" className(obj) obj->size())
)

inScheme(
defmethod(initializeInstance \@before (obj(Stream) \@rest _args)
    unless(slotBoundp(obj 'push)
        obj->push = lambda((text "t") obj->_data = tconc(obj->_data text) t)
    )
    unless(slotBoundp(obj 'last)
        obj->last = lambda(() !obj->isEmpty() && cadr(obj->_data))
    )
    unless(slotBoundp(obj 'shift)
        obj->shift = lambda(()
            unless(obj->isEmpty()
                prog1(
                    caar(obj->_data)
                    car(obj->_data) := cdar(obj->_data)
                )
            )
        )
    )
    unless(slotBoundp(obj 'text)
        obj->text = lambda((\@key clear)
            obj->isEmpty() && "" || prog1(
                buildString(car(obj->_data) "")
                when(clear
                    obj->_data = nil
                )
            )
        )
    )
    unless(slotBoundp(obj 'size)
        obj->size = lambda(() length(car(obj->_data)))
    )
    unless(slotBoundp(obj 'isEmpty)
        obj->isEmpty = lambda(() !car(obj->_data))
    )
    t
)
)


unuseNamespace("ycSubProcess")

; END