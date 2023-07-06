# skill-process

外部进程执行命令并接收返回值。

## cmd

```text
cmd(
    g_cmd1
    [ g_cmd2 ... ]
    [ S_row ]
)
```

> alias to `ycCommand`

+ 调用内置 `artSystemWithRead` 函数
+ 无法区分结尾是否存在换行符
+ 无法执行分号 ';' 串行的符合命令
+ 返回结果不以换行符为结尾时存在 BUG，获取的返回结果有误

```lisp
cmd("echo" 123)
; => "123"

cmd("echo -n" 123) ; bug case
; => "12"
```

## cmd2

```text
cmd2(
    g_cmd1
    [ g_cmd2 ... ]
    [ S_row ]
    [ s_type ]
    [ g_chomp ]
)
```

> alias to `ycCommand2`

+ 调用 IPC 函数，解决上述问题
+ 支持标准输出和错误输出分离

```lisp
cmd2("echo -n" 123)
; => "123"

cmd2("echo 123 ; date +'%F %T' >&2" ?type 'all)
; => ("123\n" "2021-09-08 23:46:24\n")
```
