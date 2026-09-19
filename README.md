# skill-process

进程间通信 (IPC) 功能的面向对象封装。

## 安装

+ skill-loader
    依赖 [skill-loader](https://github.com/yeungchie/skill-loader)，已安装可以跳过。

    ```sh
    git clone --depth=1 https://github.com/yeungchie/skill-loader.git
    ```

    在 `.cdsinit` 文件中追加：

    ```lisp
    load("<path-to-dir>/skill-loader/load.il")
    ```

+ skill-process

    ```sh
    git clone --depth=1 https://github.com/yeungchie/skill-process.git
    ```

    在 `.cdsinit` 文件中追加：

    ```lisp
    load("<path-to-dir>/skill-process/load.il")
    ```

---

## ycSubProcess::runJob `function`

```text
ycSubProcess::runJob(
    g_arg
    [ g_args ... ]
)
=> t / nil
```

执行给定命令并等待任务完成，子进程输出内容将实时打印。
返回 `t` 表示任务进程正常结束；`nil` 表示执行失败，即进程返回状态码非零。

### 参数

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| g_arg | Any | | 命令，非字符串会自动转换 |
| g_args | Any | | 命令的其余部分 |

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

```text
ycSubProcess::createJob(
    g_arg
    [ g_args ... ]
    [ ?callback g_funcobj ]
    [ ?verbose g_enable ]
)
=> ycSubProcess::AsyncJob
```

创建异步任务对象，可通过回调函数处理输出。

### 参数

| 名称 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| g_arg | Any | | 命令，非字符串会自动转换 |
| g_args | Any | | 命令的其余部分 |
| ?callback g_funcobj | nil / symbol / funobj | nil | 可选，回调函数 |
| ?verbose g_enable | nil / t | nil | 可选，控制是否实时打印子进程输出 |

回调函数签名：`callback(event_type, async_job)`

+ `event_type`指定事件类型。

    | 有效值 | 触发时机 |
    | --- | --- |
    | `'stdout` | 标准输出有新数据 |
    | `'stderr` | 标准错误输出有新数据 |
    | `'post` | 任务进程执行结束 |

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

异步任务对象，用于控制和获取任务及进程信息。

### 属性

| 名称 | 类型 | 说明 |
| --- | --- | --- |
| cmd | string | 执行的命令 |
| userData | Any | 可用于携带任意数据 |
| callback | nil / symbol / funcobj | 特定事件触发的回调函数 |
| verbose | nil / t | 控制是否实时打印子进程输出 |
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

运行任务，启动进程。若已启动则报错。

```lisp
aj = ycSubProcess::createJob("whoami")
aj->start()
; => t
```

#### wait `method`

```text
aj->wait(
    [ x_timeout ]
    [ x_interval ]
)
=> t / nil
```

等待任务完成。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| x_timeout | int | 1000000 | 单位 **秒**，等待超时时间 |
| x_interval | int | 30 | 单位 **秒**，提示信息打印时间间隔 |

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
ycSubProcess::createJob("whoami")->await()
; => "yeung\n"
```

设置 `?check t` 时，进程返回码非零会抛出错误。

```lisp
ycSubProcess::createJob("whoamii")->await(?check t)
; sh: whoamii: command not found
; *Error* funcall: job failed, returncode is 127
```

#### kill `method`

```text
aj->kill()
=> t / nil
```

强制终止任务。

#### state `method`

```text
aj->state()
=> s_state
```

获取任务进程状态。

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

暂停任务，类似 Ctrl+Z。

#### continue `method`

```text
aj->continue()
=> t / nil
```

继续执行已暂停的任务。

#### print `method`

```text
aj->print(
    t_formatString
    [ g_args ... ]
    [ ?end t_string ]
)
=> t / nil
```

向标准输入写入内容。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| t_formatString | string | | 格式化字符串 |
| g_args | Any | | 格式化参数 |
| ?end t_string | string | `"\n"` | 结尾字符 |

```lisp
aj = ycSubProcess::createJob("cat")
aj->start()
; => t

aj->print("123")
aj->stdout->text()
; => "123\n"

aj->print("456")
aj->print("789")
aj->close()
aj->await()
; => "123\n456\n789\n"
```

#### close `method`

```text
aj->close()
=> t / nil
```

关闭标准输入通道，类似 `Ctrl + D`。

#### signal `method`

```text
aj->signal(
    s_signal
)
=> t / nil
```

发送信号。

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| s_signal | symbol | 向任务进程发送信号 |

| 有效值 | 说明 |
| --- | --- |
| `'INT` | 中断任务进程，类似 `Ctrl + C` |
| `'QUIT` | 退出任务进程，类似 `Ctrl + \` |
| `'TERM` | 终止任务进程， 类似 `kill -15 PID` |
| `'KILL` | 强制终止任务进程，类似 `kill -9 PID` |

---

## Stream `class`

一个 FIFO 数据流对象，用于获取任务进程输出。

### 方法

#### text `method`

```text
aj->stdout->text(
    [ ?clear g_enable ]
)
=> t_string
```

获取所有输出内容并拼接为字符串，空流时返回空字符串。

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| ?clear g_enable | bool | nil | 获取后是否清空数据流 |

```lisp
aj->stdout->text()
; => "hello world\n"
```

#### size `method`

```text
aj->stdout->size()
=> x_number
```

获取数据流中数据数量。

#### isEmpty `method`

```text
aj->stdout->isEmpty()
=> t / nil
```

判断数据是否为空。

#### last `method`

```text
aj->stdout->last()
=> t_string / nil
```

获取最后一条数据，无数据时返回 nil。

#### shift `method`

```text
aj->stdout->shift()
=> t_string / nil
```

获取并移除第一条数据，无数据时返回 nil。

---
