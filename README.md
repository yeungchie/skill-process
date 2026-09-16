# skill-process

外部进程执行命令功能的面向对象封装。

## 依赖

[skill-loader](https://github.com/yeungchie/skill-loader)

---

## runJob

同步执行命令并等待完成，输出内容直接打印到终端。

```lisp
ycSubProcess::runJob(arg [args ...])
=> t | nil
```

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| arg | Any | 命令，非字符串会自动转换 |
| ... | Any | 命令的其余部分 |

返回 `t` 表示进程正常结束（returncode == 0），`nil` 表示执行失败（会自动终止进程）。

```lisp
ycSubProcess::runJob("whoami")
; yeung
; => t

ycSubProcess::runJob("date")
; Tue Sep 15 22:50:10 CST 2026
; => t

ycSubProcess::runJob("bad cmd")
; sh: bad: command not found
; => nil
```

---

## createJob

创建异步任务对象，可通过回调函数处理输出。

```lisp
ycSubProcess::createJob(arg [args ...] [?callback funcobj])
=> ycSubProcess::AsyncJob
```

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| arg | Any | 命令，非字符串会自动转换 |
| ... | Any | 命令的其余部分 |
| callback | funcobj | 可选，回调函数 |

回调函数签名：`callback(event_type, async_job)`

| event_type | 触发时机 |
| --- | --- |
| `'stdout` | 标准输出有新数据 |
| `'stderr` | 标准错误输出有新数据 |
| `'post` | 进程执行结束 |

```lisp
aj = ycSubProcess::createJob("free -h")
; => <ycSubProcess::AsyncJob object; ...>

printf("%s" aj->await())
;               total        used        free      shared  buff/cache   available
; Mem:            15G        1.6G        8.9G        140M        5.0G         13G
; Swap:          4.0G          0B        4.0G
```

---

## AsyncJob

异步任务对象，用于控制和获取进程信息。

> 使用 `->` 符号调用方法。

### 属性

| 名称 | 类型 | 说明 |
| --- | --- | --- |
| cmd | string | 执行的命令 |
| callback | funcobj | 回调函数 |
| ipcId | ipcId | 进程间通信 ID |
| returncode | int | 进程退出状态码 |
| stdout | Stream | 标准输出流 |
| stderr | Stream | 标准错误输出流 |

### 方法

#### start

启动进程。若已启动则报错。

```lisp
aj = ycSubProcess::createJob("whoami")
aj->start()
```

#### await

自动启动并等待完成，返回标准输出内容。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| check | bool | nil | 是否检查返回码，非零时抛出错误 |

```lisp
output = aj->await()
; => "yeung"

; check 为真时，进程返回码非零会抛出错误
output = aj->await(?check t)
```

#### print

向标准输入写入内容。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| fmt | string | - | 格式化字符串 |
| args | Any | - | 格式化参数 |
| end | string | "\n" | 结尾字符 |

```lisp
aj->print("hello")
aj->print("line %d\n" 1)
aj->print("no newline" ?end "")
```

#### state

获取进程状态。

```lisp
aj->state()
; => 'None    ; 未启动
; => 'Active  ; 运行中
; => 'Dead    ; 已结束
; => 'Stopped ; 已暂停
```

#### wait

等待进程完成。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| timeout | int | 1000000 | 超时时间（毫秒） |
| interval | int | 30 | 轮询间隔（毫秒） |

#### stop

暂停进程，类似 Ctrl+Z。

#### continue

继续执行已暂停的进程。

#### close

关闭标准输入通道。

#### kill

终止进程。

#### signal

发送信号。

| 参数 | 类型 | 可选值 |
| --- | --- | --- |
| signal | symbol | `'INT`、`'TERM`、`'QUIT`、`'KILL` |

```lisp
aj->signal('INT)   ; 中断进程
aj->signal('TERM)  ; 终止进程
aj->signal('QUIT)  ; 退出进程
aj->signal('KILL)  ; 强制终止进程
```

---

## Stream

数据流对象，用于获取进程输出。

### 方法

#### text

获取所有输出内容并拼接为字符串，空流时返回空字符串。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| clear | bool | nil | 获取后是否清空数据流 |

```lisp
aj->stdout->text()            ; => "hello\nworld\n"
aj->stdout->text(?clear t)    ; => "hello\nworld\n" 且清空
```

#### size

获取数据条数。

```lisp
aj->stdout->size() ; => 2
```

#### isEmpty

判断是否为空。

```lisp
aj->stdout->isEmpty() ; => nil
```

#### last

获取最后一条数据，无数据时返回 nil。

```lisp
aj->stdout->last() ; => "world"
```

#### shift

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
