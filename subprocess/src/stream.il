useNamespace("ycSubProcess")


defclass(Stream () (
    push()  ; -> t
    last()  ; -> str | nil
    shift()  ; -> str | nil
    text()  ; -> str
    size()  ; -> int
    isEmpty()  ; -> t | nil
))

defmethod(printself (self(Stream))
    lsprintf("<%A object; size=%d>" className(self) self->size())
)

inScheme(
defmethod(initializeInstance (self(Stream) \@rest _args) let((_data)
    self->push = lambda((text "t")
        _data = tconc(_data text)
        t
    )
    self->last = lambda(()
        !self->isEmpty() && cadr(_data)
    )
    self->shift = lambda(()
        unless(self->isEmpty()
            prog1(
                caar(_data)
                car(_data) := cdar(_data)
            )
        )
    )
    self->text = lambda((\@key clear)
        self->isEmpty() && "" || prog1(
            buildString(car(_data) "")
            when(clear
                _data = nil
            )
        )
    )
    self->size = lambda(()
        length(car(_data))
    )
    self->isEmpty = lambda(()
        !car(_data)
    )
    t
))
)


unuseNamespace("ycSubProcess")

; END