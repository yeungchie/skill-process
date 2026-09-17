# skill-process

外部进程执行命令功能的面向对象封装。

## 依赖

[skill-loader](https://github.com/yeungchie/skill-loader)

---

## ycSubProcess::runJob `function`

同步执行命令并等待完成，输出内容直接打印到终端。
返回 `t` 表示进程正常结束；`nil` 表示执行失败，即进程返回状态码非零。

```text
ycSubProcess::runJob(
    g_arg
    [ g_args ... ]
)
=> t / nil
```

### 参数

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| g_arg | Any | 命令，非字符串会自动转换 |
| g_args | Any | 命令的其余部分 |

### 例程

```lisp
ycSubProcess::runJob("whoami")
; yeung
; => t
```

```lisp
ycSubProcess::runJob("date")
; Tue Sep 15 22:50:10 CST 2026
; => t
```

```lisp
ycSubProcess::runJob("bad cmd")
; sh: bad: command not found
; => nil
```

---

## ycSubProcess::createJob `function`

创建异步任务对象，可通过回调函数处理输出。

```text
ycSubProcess::createJob(
    g_arg
    [ g_args ... ]
    [ ?callback g_funcobj ]
)
=> ycSubProcess::AsyncJob
```

### 参数

| 名称 | 类型 | 说明 |
| --- | --- | --- |
| g_arg | Any | 命令，非字符串会自动转换 |
| g_args | Any | 命令的其余部分 |
| ?callback g_funcobj | nil / symbol / funobj | 可选，回调函数 |

回调函数签名：`callback(event_type, async_job)`

+ `event_type`指定事件类型。

    | 有效值 | 触发时机 |
    | --- | --- |
    | `'stdout` | 标准输出有新数据 |
    | `'stderr` | 标准错误输出有新数据 |
    | `'post` | 进程执行结束 |

+ `async_job`为 `AsyncJob` 对象。

### 例程

```lisp
aj = ycSubProcess::createJob("free -h")
; => <ycSubProcess::AsyncJob object; status=None, returncode=nil>

printf("%s" aj->await())
;               total        used        free      shared  buff/cache   available
; Mem:            15G        1.6G        8.9G        140M        5.0G         13G
; Swap:          4.0G          0B        4.0G
```

---

## ycSubProcess::AsyncJob `class`

异步任务对象，用于控制和获取进程信息。

### 属性

| 名称 | 类型 | 说明 |
| --- | --- | --- |
| cmd | string | 执行的命令 |
| userData | Any | 可用于携带任意数据 |
| callback | nil / symbol / funcobj | 特定事件触发的回调函数 |
| ipcId | nil / ipcId | 进程间通信 ID，任务还未启动时的值为 `nil` |
| returncode | nil / int | 进程退出状态码，任务还未启动时的值为 `nil` |
| stdout | ycSubProcess::Stream | 标准输出流 |
| stderr | ycSubProcess::Stream | 标准错误输出流 |

### 方法

> 必须使用 `->` 符号调用方法。

#### start `method`

```text
aj->start()
=> t / nil
```

启动进程。若已启动则报错。

```lisp
aj = ycSubProcess::createJob("whoami")
aj->start()
; => t
```

#### print `method`

```text
aj->print(
    t_fmt
    [ g_args ... ]
    [ ?end t_string ]
)
=> t_string
```

向标准输入写入内容。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| t_fmt | string | | 格式化字符串 |
| g_args | Any | | 格式化参数 |
| ?end t_string | string | `"\n"` | 结尾字符 |

```lisp
aj->print("hello")
aj->print("line %d\n" 1)
aj->print("no newline" ?end "")
```

#### wait `method`

```text
aj->wait(
    [ x_timeout ]
    [ x_interval ]
)
=> t / nil
```

等待进程完成。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| x_timeout | int | 1000000 | 单位 **秒**，等待超时时间 |
| x_interval | int | 30 | 单位 **秒**，提示信息打印时间间隔 |

```lisp
aj->wait()
; => t
```

#### kill `method`

```text
aj->kill()
=> t / nil
```

终止进程。

#### await `method`

```text
aj->await(
    [ ?check g_enable ]
)
=> t_string
```

自动启动并等待完成，返回标准输出内容。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| ?check g_enable | bool | nil | 是否检查返回码，非零时抛出错误 |

```lisp
aj = ycSubProcess::createJob("whoami")
aj->await()
; => "yeung\n"
```

```lisp
; check 为真时，进程返回码非零会抛出错误
aj = ycSubProcess::createJob("whoamii")
aj->await(?check t)
; sh: whoamii: command not found
; *Error* funcall: job failed, returncode is 127
```

#### state `method`

```text
aj->state()
=> s_state
```

获取进程状态。

```lisp
aj->state()
; => 'None
```

| 状态 | 说明 |
| --- | --- |
| `'None` | 未启动 |
| `'Active` | 运行中 |
| `'Dead` | 已结束 |
| `'Stopped` | 已暂停 |

#### stop `method`

```text
aj->stop()
=> t / nil
```

暂停进程，类似 Ctrl+Z。

#### continue `method`

```text
aj->continue()
=> t / nil
```

继续执行已暂停的进程。

#### close `method`

```text
aj->close()
=> t / nil
```

关闭标准输入通道。

#### signal `method`

```text
aj->signal(
    s_signal
)
=> t / nil
```

发送信号。

| 参数 | 类型 | 有效值 |
| --- | --- | --- |
| s_signal | symbol | `'INT` / `'TERM` / `'QUIT` / `'KILL` |

```lisp
aj->signal('INT)   ; 中断进程
aj->signal('TERM)  ; 终止进程
aj->signal('QUIT)  ; 退出进程
aj->signal('KILL)  ; 强制终止进程
```

---

## Stream `class`

一个 FIFO 数据流对象，用于获取进程输出。

### 方法

#### text `method`

获取所有输出内容并拼接为字符串，空流时返回空字符串。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| clear | bool | nil | 获取后是否清空数据流 |

```lisp
aj->stdout->text()            ; => "hello\nworld\n"
aj->stdout->text(?clear t)    ; => "hello\nworld\n" 且清空
```

#### size `method`

获取数据条数。

```lisp
aj->stdout->size() ; => 2
```

#### isEmpty `method`

判断是否为空。

```lisp
aj->stdout->isEmpty() ; => nil
```

#### last `method`

获取最后一条数据，无数据时返回 nil。

```lisp
aj->stdout->last() ; => "world"
```

#### shift `method`

获取并移除第一条数据，无数据时返回 nil。

```lisp
aj->stdout->shift() ; => "hello"
```

---

## 示例

```lisp
; 同步执行
ycSubProcess::runJob("echo hello")

; 异步执行并获取输出
aj = ycSubProcess::createJob("echo hello && echo world")
output = aj->await()
; => "hello\nworld\n"

; 使用回调处理输出
aj = ycSubProcess::createJob("ping -c 3 localhost"
    lambda((et aj)
        case(et
            (stdout printf("OUT: %s" aj->stdout->last()))
            (stderr printf("ERR: %s" aj->stderr->last()))
        )
    )
)
aj->start()
aj->wait()
```
