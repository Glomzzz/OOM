#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Past Skillw]
#date[2025-09-22 21:23]
#author[Glomzzz]

== 朝花夕拾 - Bukkit

我之前已经基于 Bukkit 开发过许多 Minecraft 服务器插件，它们主要都是为了 RPG 服务器而设计的，主要追求模块化和自由度。

见：#link("https://www.skillw.com/")[Skillw]

现在回看当初设计这些插件时的理念：

- 模块化：每个*功能*（而非插件）都应该是一个独立的模块，可以与其他模块组合使用
  - 一致性：每个模块都应该有一个*核心功能*，并且这个核心功能应该是*一致的*且是*抽象的*(并非具体功能，而是实现此类功能的框架)
  - 可扩展性：应该提供*统一的接口*，让用户可以通过编程/脚本的方式来实现对模块的功能扩展
- 自由度：插件的设计应该尽可能地*通用*，让用户可以根据自己的需求来进行配置和使用
  - 配置化：插件的功能应该尽可能地通过配置文件来实现，而不是通过代码写死
  - 脚本化：插件应该提供脚本化的能力，让用户可以通过脚本来实现对插件的功能扩展

所以首先要有一个#link("https://github.com/Skillw/Pouvoir/tree/master/src/main/kotlin/com/skillw/pouvoir/api/manager/sub/script")[*脚本模块*]，提供预编译脚本与运行脚本的功能；

然后对于每个模块，尽量对其核心功能进行抽象(泛化， generalization)，并且对其的使用(拓展)提供*统一的两套接口*:
- 原生接口 (Java/Kotlin... 面向开发者)
- 配置/脚本接口 (Javascript, Asahi... 面向插件用户)，应该基于原生接口去实现

这两套接口必须是*等价的*，即通过脚本接口实现的功能必须*可以*通过原生接口实现，反之亦然，这样可以降低心智负担。

我认为 #link("https://www.skillw.com/")[Skillw 全家桶] 在 Bukkit 平台上很大程度上实现了上述的设计理念，而目前我想在 Minestom 上再实现一套类似的功能，鉴于 Minestom 与 Bukkit 在架构上的差异，这套理念需要进行一些调整。

== Encore! - Minestom

事实上，我懒得再在 Minestom 上重新搭建一套 *配置-脚本* 的基础设施了，所以我打算只提供*原生接口*。

对于某个功能，先实现一套*抽象的核心框架模块*，然后再基于这个框架模块实现*具体的功能模块*。

例如，对于*物品系统*中的物品生成：

- Bukkit - #link("https://github.com/Skillw/ItemSystem")[ItemSystem]
  - 原生接口：#link("https://github.com/Skillw/ItemSystem/blob/master/src/main/kotlin/com/skillw/itemsystem/api/builder/BaseItemBuilder.kt")[BaseItemBuilder.kt] 与 #link("https://github.com/Skillw/ItemSystem/blob/master/src/main/kotlin/com/skillw/itemsystem/api/manager/ItemBuilderManager.kt")[ItemBuilderManager.kt]
  - 配置/脚本接口: #link("https://github.com/Skillw/ItemSystem/blob/master/src/main/kotlin/com/skillw/itemsystem/internal/core/builder/ItemBuilder.kt")[ItemBuilder.kt]
    - 配置示例: #link("https://github.com/Skillw/ItemSystem/blob/master/src/main/resources/items/example.yml")[example.yml] \
      是的，这个物品的配置文件过分复杂，你需要在yaml中*无语法提示*地写 JavaScript, Asahi, 并在字符串中*无检查地*调用变量名 \
      这是我原理念里最大的弊病，我感觉用户先学习 Javascript/Asahi，再熟悉"配置-脚本"的框架，甚至不如直接学习 Java/Kotlin 来得更快更容易... \
        - 当然，无论如何，用户们在学习过程中总会培养起来一种品性，这有助于他们在未来的编程学习中受益。
      这也是我不想再在 Minestom 上重新搭建一套 "配置-脚本" 基础设施的原因，我不想重蹈覆辙 \
      配置文件系统可以*热重载*固然是一个优势，也许我未来会开发一套仅用作调试的*模块热重载系统*...

- Minestom - Item 模块
  - 原生接口：仅提供基本的 ItemBuilder 接口 与 ItemBuilderManager 接口
    - 具体的物品功能模块由开发者通过实现ItemBuilder接口，自行实现具体逻辑 \
      你可以拥有完整的语法提示&检查，相比于配置文件，无论是自由度还是安全性都更高

== 新的根基

我需要再建一些*基础设施*，这是必然的，我们留到 #cite-title("./basic.typ") 讨论。