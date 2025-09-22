#import "/lib/lib.typ": *

#show: schema.with("page")

#title[前言]
#date[2025-09-22 20:17]
#author[Glomzzz]

最近迷上了小时候玩过的 #link("https://picroma.com/")[Cube World] 和 #link("https://minestom.net/")[Minestom]。

Minestom 有着优异的性能，较 #link("https://dev.bukkit.org/")[Bukkit] 系列相比，它有着原生多线程的支持，且 API 设计的也非常现代化，适合用来开发较为复杂的且遵循*一致性（Consistency）* Minecraft 服务器。

Minestom 贯彻了*抽象化*的设计理念，提供了*最小化*的功能集，允许开发者根据自己的需求来进行扩展，相比于*臃肿不堪*的 Bukkit 来说，这更加轻量级和高效，也允许我们应用更加先进且符合人体工学的范式。

对于 Bukkit 到 Minestom，我的编程理念所进行的转变，我已经放到了 #cite-title("../minestom/bukkit.typ") 中进行讨论。

而 Cube World 则是我童年时光的美好回忆，虽然它的游戏内容可以说非常简单并不复杂，但它的核心玩法和机制非常有趣。

于是我决定用 Minestom 来重现 Cube World 的玩法和机制，打造一个名为 *Skillw* 的 Minecraft 服务器。

我会在此系列文章中记录我的计划与开发过程。

