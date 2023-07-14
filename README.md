# skill-process

外部进程执行命令并接收返回值。

## 项目依赖

+ skill-loader [ [GitHub](https://github.com/yeungchie/skill-loader "https://github.com/yeungchie/skill-loader") / [Gitee](https://gitee.com/yeungchie/skill-loader "https://gitee.com/yeungchie/skill-loader") ]

## cmd

```text
cmd(
    g_cmd1
    [ g_cmd2 ... ]
    [ ?row  S_row ]
)
```

> alias to `ycCommand`

调用内置 `artSystemWithRead` 函数，执行 Shell 语句，接受返回值。

1. **g_cmd**
    + 执行的 Shell 语句，非字符串会被转为字符串。
    + 多个语句会用单空格 `" "` 拼接作为执行的语句。
    + 类型限制：*all*

2. `?row` **S_row**
    + 指定字符串用于拼接多次获取到的结果。
    + 由于 `cmd()` 无法获取到结尾的换行符，因此这个参数默认值设定为 `"\n"`。
    + 非字符串会被转为字符串。
    + 类型限制：*string, symbol*

```lisp
cmd( "echo 123" )
; => "123"
```

存在缺陷：

+ 运行串行的组合命令，无法获取完整结果

```lisp
cmd( "echo 123 && echo 456" )
; => "456"
```

+ 返回结果不以换行符为结尾时存在 BUG，获取的返回结果有误

```lisp
cmd( "echo -n 123" )
; => "12"
```

## cmd2

```text
cmd2(
    g_cmd1
    [ g_cmd2 ... ]
    [ ?row  S_row ]
    [ ?type  s_type ]
    [ ?chomp  g_chomp ]
)
```

> alias to `ycCommand2`

调用 IPC 函数，解决上述 `cmd()` 中存在的问题，并支持标准输出和错误输出分离。

1. **g_cmd**
    + 执行的 Shell 语句，非字符串会被转为字符串。
    + 多个语句会用单空格 `" "` 拼接作为执行的语句。
    + 类型限制：*all*

2. `?row` **S_row**
    + 指定字符串用于拼接多次获取到的结果，默认值设定为空字符 `""`。
    + 非字符串会被转为字符串。
    + 类型限制：*string, symbol*

3. `?type` **s_type**
    + 指定需要获取的输出类型，默认为 `'std`，即获取标准输出。
    + 指定 `'err` 则只获取错误输出。
    + 指定 `'all` 则返回一个 *list* 包含所有输出。
    + 类型限制：*symbol*

4. `?chomp` **g_chomp**
    + 指定是否需要将每次获取的结果的行尾换行符移除。
    + 默认为 `nil`。如果指定为非 `nil`，这移除行尾换行符。
    + 类型限制：*all*

+ 可以获取都结尾的换行符

```lisp
cmd2( "echo 123" )
; => "123\n"
```

+ 不以换行符结尾可以获取到完整结果

```lisp
cmd2( "echo -n 123" )
; => "123"
```

+ 运行串行命令可以获取到完整结果

```lisp
cmd2( "echo 123 && echo 456" )
; => "123\n456\n"
```

+ 分离标准输出和错误输出

```lisp
cmd2( "echo 123 ; echo 456 >&2" ?type 'all )
; => ("123\n" "456\n")
```
