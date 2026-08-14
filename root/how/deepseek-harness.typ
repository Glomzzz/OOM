
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[深入 DeepSeek Harness：一切皆插件]
#page-title[深入 DeepSeek Harness]
#date[2026-08-14]
#author[Glomzzz]

2026 年 8 月 13 日, DeepSeek 在开源 DeepSeek-V4-Pro-0813 的同一天, 把代号 `dsh` 的智能体框架 #link("https://github.com/deepseek-ai/deepseek-harness")[DeepSeek Harness] 以 MIT 协议开源了, 版本号 v0.1 开发者预览.

这算是一篇"一边用、一边读源码"的笔记. 仓库里也有一句话我很喜欢: _Everything is a Plugin_, 一切皆插件. 这篇文章就围绕这句话展开: 它是什么, 它怎么工作, 以及它到底做对了什么.


#feature[速览][][
*是什么*: DeepSeek AI 开源的 agent harness(智能体框架), 官方公式 *Model + Harness = Agent*\
*口号*: Everything is a Plugin — 一切皆插件\
*底座*: 基于 #link("https://github.com/cordiverse/cordis")[Cordis] 插件框架, 设计源自论文 _A Programming Paradigm for Spatiotemporal Composability_\
*协议与状态*: MIT, v0.1 开发者预览 — 官方明说未来将有破坏兼容性的变更\
*怎么跑*: `npx @deepseek-ai/dsh web`, 默认 Web UI 在 `http://127.0.0.1:3080`\
*对标*: OpenAI Codex 与 Claude Cowork, 主打编程与办公场景
]

= 它是什么

== "Harness" 是什么

"Harness" 的本意是马具、挽具 — 把马的力量"接"到车上的那套装置. 在 AI 领域, harness 指的是把大模型"接"到真实环境里的那套装置: 上下文管理、工具调用、任务状态、反馈与边界. DeepSeek 官方招聘信息里给过一个很干净的公式:

#example[Model + Harness = Agent][][
模型本身只是"会说话的脑子"; 是 harness 调度上下文与工具、维护任务状态、划清边界, 才把模型变成能在真实环境里干活的智能体.
]

产品定位上, DeepSeek Harness 对标 #link("https://openai.com/codex/")[OpenAI Codex] 与 Claude Cowork, 主打编程与办公生产力场景 — 你可以把它理解为"DeepSeek 版的 agent 执行环境".

== 时间线与定位

- 8 月 2 日, 团队负责人崔添翼公开征集 Harness 内测用户;
- 8 月 13 日, 与 DeepSeek-V4-Pro-0813(1.6T 总参数 MoE, 单 token 激活 49B, 百万上下文)同日发布: Harness v0.1 开发者预览版, MIT 协议, 同步开放插件生态 — #link("https://www.ithome.com/0/989/446.htm")[IT之家] 以"对标 Claude Cowork"为题报道了公测与插件生态.

开源首日 star 数就冲到了数万(有报道称 28k), 截至本文写作时已经超过 *9 万* — 对发布不到一周的仓库来说, 这个热度本身就是市场情绪的写照.

技术栈上, 主体是 TypeScript monorepo(pnpm workspace, 两百余个包), 另附 Python SDK(`python/sdk-runtime`), 并通过 JSON-RPC 与 ACP(Agent Client Protocol)暴露给外部工具链与自动化.

== 怎么跑起来

前提是装好 Node.js, 然后一行命令:

```sh
npx @deepseek-ai/dsh web
```

这会启动 Web UI, 默认地址 `http://127.0.0.1:3080`. 从源码跑则是:

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

`dsh` 命令行本身也很有"一切皆插件"的味道: `dsh --profile <name>` 启动指定 profile, `dsh --profile headless "job"` 跑一次性任务并打印答案退出, `dsh plugin --profile <name> <pnpm args>` 在 profile 目录里管理插件. 运行命令时的所在目录, 就是默认 workspace 根目录.

= 它是怎么工作的

== 底座: Cordis

DeepSeek Harness 底层的插件框架是 #link("https://github.com/cordiverse/cordis")[Cordis], 一个以 vendor 方式引入的插件框架; 其设计对应论文 _A Programming Paradigm for Spatiotemporal Composability_ — "时空可组合性": 插件可以按时间(生命周期)与空间(上下文/作用域)自由组装. 按官方入门文档, 它围绕五个核心概念:

- *插件是实现 Service 的对象*: 函数插件(可选 `inject` + `apply(ctx)`)或 `Service` 子类, 生命周期由 Cordis 挂载进上下文;
- *上下文是服务的容器*: 一个服务占据稳定的 `ctx.<key>`(如 `ctx.tools`、`ctx.llm`、`ctx.sessions`), 其他插件通过 key 查找服务, 而不是 import 具体实现 — 这是"可替换"的第一步;
- *用 `inject` 声明依赖*: 插件声明需要的服务, 就绪后才启动, 加载顺序由依赖图决定, 而非手动编排启动序列;
- *类型化事件用于通信*: 事件用 TypeScript 声明合并注册, 按四种模式分发 — `emit`(监听者观察)、`waterfall`(瀑布式, 即环绕中间件)、`parallel`(并行扇出)、`serial`(按序执行);
- *注册是可逆的副作用*: 提示词片段、工具 schema、适配器、提供方、监听器都通过 `ctx.effect()` / `ctx.on()` 安装, reload 与 teardown 时自动撤销.

#details([Cordis waterfall 语义: 为什么"事件"能当中间件用])[
`ctx.waterfall` 是环绕中间件: 监听器收到 `(...args, next)`, 调用 `next()` 才执行下游; 下游返回值从 `next()` 传回当前层, 可以包装后再往外传. 不调用 `next()` 直接返回就是短路. 所以策略监听器在拥有决策权时可以不委托, 而只做标注或观察的监听器则必须委托.
]

== 没有特权内核

dsh 里没有任何"需要打补丁的特权内核": *模型适配器、工具注册表、会话日志、甚至 agent loop 本身, 全部是插件*. 官方架构文档的原话:

#block-quote[
产品的每一部分都是插件, 包括模型适配器、工具注册表、会话日志, 以及 agent loop(智能体循环)本身, 因此每一部分都可以从配置替换.
]

扩展 dsh 的方式, 就是把插件挂载到其他插件旁边; 所有注册都是副作用, 插件卸载时一并撤销. 这也是它和"框架 + 插件 API"式设计最根本的区别.

== Profile 与组合包: 插件树怎么长出来

运行中的 `dsh` 是一棵插件树, 由启动时按序叠加的若干"层"组合而成:

- *profile*: 放在 Harness home 里的具名组装 — 列出自己要叠放的组合包, 存放自己安装的树外插件, 以及用户自己的 `cordis.patch.yml`;
- *组合包(bundle)*: Cordis 配置项与挂载代码的分发格式 — 它插入的内容永远可以被其上各层 patch.

随发行版交付两个模板: `web`(浏览器应用)与 `headless`(不带服务器的一次性运行器). 而 `dsh-base` 是每个 profile 的第一层 — 模型适配器、工具、持久化、沙箱与审批策略、设置、凭据、遥测都在这里; `dsh-web-app` 在此基础上增加浏览器应用.

patch 按此顺序叠加在空条目列表之上:

```text
profile 列出的组合包(按序)
  → profile 的 cordis.patch.yml
  → home 级的 cordis.patch.yml
  → 任意 --patch overlay
```

一条 patch 按 id 定位某个条目并替换其整个 config, 或插入新条目. 想看你机器上真实启动的配置树:

```sh
dsh --profile web --dump-config
```

它打印出的任何条目, 都可以由你自己的 patch 替换 — 这就是"配置层自由组合"的物理实现.

== 核心包: 主干

以下包向插件树贡献核心能力:

- `core/session`: 仅追加的 `SessionEvent` 日志与内存存储(`ctx.sessions`);
- `core/system-prompt`: 提示词片段与工具 schema 的组装(`ctx.systemPrompt`);
- `core/tools`: 作用域化的工具注册表 + 带把关的执行流水线(`ctx.tools`);
- `core/agent`: `Agent` 接口、活跃 agent 注册表与 `agent/*` 事件(`ctx.agents`);
- `core/agent-loop`: 实现该接口的默认驱动器(`ctx.agentLoop`);
- `llm/llm`: 消息与流式词汇表, 以及适配器 seam(`ctx.llm`).

注意 `core/agent-loop` 只是"默认"驱动器 — 它是插件, 所以整个循环本身也是可替换的.

== 事件即扩展点

事件分三个域, 选对事件域是大多数改动的第一个决定:

- *会话事件*: 追加到日志、通过 `session/event` 广播的*持久事实* — 需要在重载后依然存在的事实用它;
- *Agent 事件*(`agent/*`): 携带活跃 `Agent` — inbox、步骤、状态、请求、验证、续跑 — 要观察或拦截进行中的工作用它;
- *能力事件*: 无需 import 循环即可向某个 seam(`fs/*`、`tools/*`、`telemetry/*`)附加策略与适配器.

== 轮次与步骤: 一次对话怎么流动

两个基本单位:

- *步骤(step)*: 一次模型请求加上它调用的工具;
- *轮次(turn)*: 零到多个步骤 — 在领取首条输入时打开, 在不再欠下任何工作时关闭.

官方时序(简化):

```text
turn/start
  claim 下一条输入 + 一条排队消息
  组装提示词片段 + 工具 schema
  → agent/pre-step          拒绝 或 enter(messages)
     step/start
     把 enter 的消息记为 user/message
     从日志派生模型历史(deriveMessages)
     agent/request → llm/stream → assistant/chunk* → assistant/message
     tool/call* → tools/pre-execute → tools/execute → tools/post-execute → tool/result*
     step/end
     工具还欠请求 / 新输入到达 → claim → 下一个 step
  → agent/turn-stopping
turn/end
```

`turn/*`、`step/*`、`user/message`、`assistant/*`、`tool/*` 是持久会话事件; 其余是分属三个事件域的实时扩展点. `agent/pre-step`、`agent/request`、`llm/stream` 与三个 `tools/*` 事件是 waterfall — 监听器必须调用 `next()` 才能委托下去; `agent/turn-stopping` 是 serial 事件, 没有 `next()`.

`agent/pre-step` 决定模型看到什么: 监听器可以改写已领取的消息, 也可以直接拒绝它们. 每个 step 都会读取插件注册的提示词片段与工具 schema — 这就是"工具与技能以插件形式进入模型视野"的机制.

== 会话日志即上下文: 模型可见即已记录

这是 dsh 最值得玩味的运行时不变量: *会话日志是模型所见上下文的唯一来源*. `deriveMessages()` 从日志投影出模型历史, 原始 `assistant/chunk` 事件保证回放与 UI 保真; fork、恢复、transcript、遥测、持久化全部派生自这条事件流. 官方文档的原话:

#block-quote[
**模型可见即已记录。** 抵达模型请求的一切都必须能从日志重建, 并由一项运行时不变量断言这一点。因此, 新增一项模型可见输入就需要新增一个会话事件.
]

这条不变量带来两个直接后果: 一是*可回放* — 任何 UI 状态都是日志的投影, 任何历史都能重建; 二是*强制诚实* — 想给模型加一点新输入, 就得同时定义它对应的持久事件, 没有"偷偷塞进上下文"的捷径.

== 能力 seam: 换一个提供方, 换整个产品

一个 *seam* 是一项可替换能力, 由三个角色组成:

- *Service Definition*: 声明接口;
- *Service Provider*: 实现它;
- *Consumer*: 使用它 — 通常是面向模型的工具.

一个包可以兼任多个角色. 关键在于: *替换一个提供方, 就能改变整个产品的行为*. 官方文档的例子很漂亮 — 文件系统与进程提供方共享同一个执行世界, 因此把它们的提供方指向远程沙箱, 也就把 Bash、PTY 与 LSP 一并搬了过去, 无需为每个提供方写专门的远程分支.

subagent 提供方也一样: 同一个接口背后, 既可以是"新建一个子 agent", 也可以是把一个轮次委派给另一个产品(如 Claude Code / Codex — `hooks` 包桥接了共享的线协议).

== 工具执行流水线: 一个工具调用要过几道关

模型说"我要调用工具 X"之后, 调用不会直接执行, 而是穿过一条流水线:

```text
tools/pre-execute   waterfall: 钩子、权限、沙箱
→ 单调守卫(deny or abstain, 身份保护)
→ ctx.approval 一次性询问(缺席或不可答 = 拒绝)
→ tools/execute     waterfall: 超时、重试、指标(环绕分发)
→ 工具体执行
→ fs/write-intent / fs/edit-intent 文件写入门(tool-fs 专属)
→ tools/post-execute waterfall: 接受、阻断、替换、附加上下文
→ 结果规范化 → finalizeContent(仅内容不变式)
→ tools/result(同步通知, 冻结的权威结果)
→ 记录为 tool/result 会话事件
```

钩子由此可以横跨不同的工具系列, 而工具本身不需要与任何策略服务耦合 — 策略都挂在事件上. 这也是 `guard` 包(循环卫生守卫: 重复调用提醒 + 执行截止时间)、审批策略、沙箱能各自独立演进的原因.

== 四种 agent 预设

dsh 的 agent 由 *preset* 组装 — 一份 `agent.cordis.yml` 决定这个会话拥有哪些工具、哪些提示词片段. 随附四个预设:

- *标准模式*: 完整工具组合;
- *代码模式* — 又称 Code Mode, 即 PTC(Programmatic Tool Calling, 程序化工具调用): 一个 `run_code` 工具 + 一份按运行时生成的 SDK, 模型写一段程序, 用代码组合多轮工具调用, 而不是一串来回;
- *极简模式*: 仅持久 `bash` + `str_replace_editor` 两个工具, 系统提示词固定为 _You are a helpful software engineer assistant._ — 用于最小环境下的模型基准测试;
- *创造模式*: 检查当前运行时、在内存中试验 Cordis 插件, 并据此组合出新的模式.

preset 的创作就是复制: 把既有 preset 整目录复制到用户根目录, 改它的组装文件. 会话创建后工具集被冻结(仅空白会话可切换), 这也是"模型可见即已记录"规则的延伸 — 重放历史时要用它实际运行过的组装.

== 省 token 的组合拳

- *Compaction(压缩)*: `dsh-compaction-basic` 在 `agent/pre-step` 处理上下文压力 — 触发条件满足时先做工具结果剪枝, 再选摘要;
- *Spill*: 工具结果溢出到存储, 模型只见引用;
- *代码模式*: 一段程序替代一串工具调用, 减少往返与中间结果.

== Agent 能改装自己

`extensions` 包实现了 agent 运行时的自修改: 实时插件/服务检查, 以及*模型所写插件*的挂载/卸载 — agent 在干活的过程中可以给自己换工具、加能力. 设计笔记的标题就叫 _self-referential cordis toolset_ — 自指的 Cordis 工具集. "一切皆插件"在这里走向了极致: 插件系统连自己都不放过.

= 关键点: 它做对了什么

== 1. 字面意义的一切皆插件

没有特权内核 = 每一层都可以被 patch, 扩展就是挂载, 卸载自动撤销. 对比"框架 + 插件 API"的传统设计, dsh 把"可替换"做成了架构的公理, 而不是某个预留的扩展点. 代价是学习曲线: 动手写第一个插件之前, 你得先理解 Cordis 的上下文与事件模型.

== 2. 事件即扩展点, 日志即真相

三件事互为表里: 事件驱动(waterfall 中间件语义)、日志即上下文(`deriveMessages()` 投影)、模型可见即已记录(可回放不变量). 合起来, 系统天然*可审计、可恢复、可 fork* — 这正是 agent 产品最需要、也最容易被忽视的三个属性.

== 3. 换提供方 = 换产品

seam 三件套(定义/提供方/消费者)让"本地执行"与"远程沙箱执行"只是配置差异. 对产品团队来说, 安全边界、执行环境、模型供应商、甚至 agent 循环本身都可以独立演进、独立替换.

== 4. 模型可见性是一等公民

工具 schema 进系统提示词、模型可见输入必有会话事件 — dsh 把"模型会看到什么"当作架构的第一性问题来设计, 而不是事后补丁. 这条原则贯穿了系统提示词组装、预设冻结、spill 策略等几乎所有机制.

== 5. 开源即生态

MIT 协议 + `dsh-plugin` GitHub 话题 + npm scope `@deepseek-ai/dsh-*` + 模型所写插件 — 官方想走的是插件生态路线: 让第三方能力像 npm 包一样即插即用. 与 V4-Pro-0813 的权重同日开源,"模型 + 框架"组合拳的意味很明显.

== 代价与泼冷水

当然也要冷静: v0.1 开发者预览, 官方 README 明说"未来将出现破坏兼容性的变更"; 插件 API 仍在快速迭代; 一切皆插件意味着心智负担不低; 而 9 万 star 里有多少是热度、多少是留存, 要等生态真正长出来才知道.

但对想认真研究"agent 执行环境到底该长什么样"的人来说, 这个仓库是目前最值得读的开源样本之一: 它把架构决策写成了文档, 把扩展点写成了事件, 把真相写进了日志 — 并且它真的在跑, 包括正在写这篇文章的我.

#html.align(center)[#html.text(fill: color.olive, size: 150%)[*Model + Harness = Agent*]]

= 参考资料

- #link("https://github.com/deepseek-ai/deepseek-harness")[deepseek-ai/deepseek-harness — 仓库]
- 仓库内文档: #link("https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/architecture.zh.md")[架构], #link("https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/agent-lifecycle.zh.md")[轮次与步骤生命周期], #link("https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/tool-execution-pipeline.zh.md")[工具执行流水线], #link("https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/cordis-primer.zh.md")[Cordis 入门], #link("https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/preset/agent-presets/README.zh.md")[agent presets]
- #link("https://github.com/cordiverse/cordis")[Cordis] 与 #link("https://github.com/cordiverse/paper")[设计论文]
- #link("https://www.ithome.com/0/989/446.htm")[IT之家: 对标 Claude Cowork: DeepSeek Harness 公测, 同步开放插件生态]
- #link("https://www.infoq.cn/article/de9AljWc4ejW2KAyW8dD")[InfoQ: DeepSeek 把 Harness 开源了: 模型、工具、Agent Loop 全是插件]
- #link("https://www.zhidx.com/p/584897.html")[智东西: 实测 DeepSeek Harness]
- #link("https://www.jiemian.com/article/14922169.html")[界面新闻: 像玩乐高一样拼插件, DeepSeek Harness 能带来哪些改变]
- #link("https://github.com/topics/dsh-plugin")[GitHub topic: dsh-plugin]
