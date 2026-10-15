#import "/lib/lib.typ": *

#show: schema.with("page", head: [
  #unique[
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;600;700&family=Cormorant+Garamond:wght@500;600;700&family=LXGW+WenKai+TC&display=swap",
    )[]
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "/being/being-of-unbeing.css",
    )[]
  ]
])

#heading-numbering("none")

#title[不存在的存在]
#page-title[不存在的存在]
#date[2026-10-15 16:35]
#author[Glomzzz]
#parent("/being/index.typ")

#let crimson(body) = html.span(class: "uob-crimson", body)
#let indigo(body) = html.span(class: "uob-indigo", body)
#let amber(body) = html.span(class: "uob-amber", body)
#let sage(body) = html.span(class: "uob-sage", body)
#let plum(body) = html.span(class: "uob-plum", body)
#let muted(body) = html.span(class: "uob-muted", body)
#let ul-crimson(body) = html.span(class: "uob-underline-crimson", body)
#let ul-amber(body) = html.span(class: "uob-underline-amber", body)
#let maxim-crimson(body) = html.span(class: "uob-maxim-crimson", body)
#let maxim-indigo(body) = html.span(class: "uob-maxim-indigo", body)
#let maxim-amber(body) = html.span(class: "uob-maxim-amber", body)
#let aside-quote(body) = html.blockquote(class: "block-quote uob-voice-quote")[
  #quote(body)
]

#html.div(class: "uob-essay")[
  #html.blockquote(class: "block-quote uob-epigraph")[
    AI时代，人的#crimson[存在主义危机]有两次，一次是#amber[失业]，一次是#crimson[失语]．
  ]

  LLM的出现让许多人都产生了一种#amber[浮躁]的心理，看不进去书，读不进去文章，无法进行有效的思考，长此以往连最基本的问题都得依赖AI．
  当然AI的出现只是表层原因，并不是说如果AI从来都没有像现在这么有效过，我们这些人就会去看书，会去读文章，会去进行有效的思考了；不，不是这样的，我们这群人从一开始就*单纯懒得去进行思考*，参与公共讨论，所说的要么是复读，要么是照搬他人（或AI）观点，要么竟是些不知所云的嘉豪黑话#muted[（说的就是我）]．

  有的人会说：

  #aside-quote[ 这没什么，依赖于XXX，人们就能把时间花费在他们喜欢的事情上了．]

  但是AI它不一样啊，这可不能被庸俗地看作又一次“蒸汽机取代马车和马车夫”式的机械革命，你难道没有感觉到，你的生活正在被AI接管吗？你难道没有感觉到，#ul-crimson[你正在成为AI的奴隶，替他去生活，替他去办事吗？]这种*倒错*难道不值得思考吗？我不知道是什么时候意识到这种*人与AI关系的倒错*的，也许从一开始我就知道，只不过我装聋作哑罢了，直到我突然又再次感到那种存在主义危机，那些我曾通过哲学思考而化解的危机，再一次向我扑面袭来，更加浩大且势不可挡——*我被淹没了*，淹没在那些比我写得更快、表面上比我更工整的AI文字与代码里，它们完美得让我觉得自己费劲巴拉写东西像个小丑．你知道吗？甚至在我写这篇文章的时候，我都感觉到了一种“这没有任何意义，不如交给AI”的感觉，让我感觉到#plum[我不再是作为我而存在着，我只是AI大人的奴隶罢了]——#maxim-crimson[到底是我在用AI还是AI在用我啊？？]

  #html.div(class: "uob-pivot")[
    要看清这种关系的倒错，或许得先回头看看我的来时路——#indigo[看看我到底在AI的投喂里丢掉了什么，又有什么是我从未真正拥有过的．]
  ]

  我很难想起我上一次认真思考一件事是什么时候了，也许是上一次数学考试吧——但是在这些思考里我总是感觉到了一种*剩余*，一种“这还不够”，我当然不是说没有完成考试，我想说的是：*我没有调动我全部的智慧去认真地思考*，当我遇到问题，想出各种解决方案的时候，我总是会选择最简单的那个——也许这也没什么，效率至上嘛——但我慢慢地发现我连方案也不想自己琢磨了，AI作为工具那可太好用了，我直接把问题丢给它让它包揽一切难道不好嘛？那我就可以去打dota打deadlock和看b站了．可每当关掉游戏，#plum[那种大脑空转的虚无感又会变本加厉地反噬回来]——*我实在想不明白，我到底该怎么把丢掉的思考能力找回来？*

  #html.div(class: "uob-lead-in")[
    走投无路之下，我决定去向身边的人取经——我和各种#sage[看起来能帮我的人]聊了聊，简单来说他们呈现出了这样的特点：
  ]

  #html.div(class: "uob-pillar uob-pillar-1")[
    首先是#indigo[非常善于提问]，他们的高中到大学时期可是没有AI的，遇到问题*要么自己往死里想，要么问同学老师和其他人讨论甚至争论*，除此之外别无他法．这在一定程度上逼出了他们的思考能力，与他人讨论的过程中，*问题意识*也随之被反复训练．反观我这种本来脑袋就不灵光的年轻一代，在有了AI后，本就不擅长与他人交流#muted[（东大栓小登导致的）]所以倾向于去问AI，而AI又被训练出一副*永远温顺、永远谄媚*的姿态，无论你抛出多么粗糙的念头，它都会微笑着接过去并说“你说的一点都对！”．#ul-crimson[在这样毫无摩擦的温室里，我的问题意识甚至还没来得及成型，就被它温柔地捂死了．]#maxim-indigo[我必须做自己思想上的牛虻．]
  ]

  #html.div(class: "uob-pillar uob-pillar-2")[
    其次他们都在#amber[从事着某种劳动]，当然不是说什么庸俗意义上的打工，他们所描述的劳动不约而同的让我想起了我曾经认真思考的感觉——那是我疫情网课期间挂着钉钉，自学编程的时候——我学Java给Minecraft服务器写插件，当时连什么是继承都不清楚的我，脑袋里只有一团团粗糙的想法，不断尝试着怎么用Java实现，代码能跑通编译，但一进游戏就是满屏预期之外的报错．报错了就嗯啃呗，*在成百上千次的测试与卡壳中死磕*，打上一层又一层补丁，生生堆出一座名副其实的”屎山“！但执着的我却肯定不会就此满意，这屎山怎么拿得出手啊？于是*从头开始重构*！虽然是从头开始，但并不是说我就回到了原点，我能真真切切感觉到如此反复往来地重构，我是获得了些什么的．直到后来我读到*黑格尔*，我才恍然大悟，原来当年那个对着满屏报错抓耳挠腮、一遍遍推倒屎山重来的下午，我所经历的，恰恰就是所谓的#amber[否定性的劳作]．但是，在有了先进的AI之后，我连那个半生不熟的想法都不用有了，我直接丢给AI，它会直接把能用的结果喂到我嘴里——AI就像个有求必应的万能许愿机，直接帮我抹平了所有阻力；#ul-amber[我拿到了满分的答案，却把思考中最核心的那场搏斗给逃掉了．]#maxim-amber[我必须进行否定性的劳作．]
  ]

  #html.div(class: "uob-synthesis")[
    那么，回到最初的问题：*在当下这个阶段，我到底该如何安放我与AI的关系？*彻底卸载、退回山林当个卢德分子显然是自欺欺人的怀旧，但我躺平把一切“劳作”外包给这个万能仆人呢，又会在不断逃避中交出自我并沦为它精神上的奴隶．如果AI注定要在答案的生产上跑赢人类，那我唯一绝对不能让渡出去的，恰恰是#sage[身为“牛虻”的质疑与“否定性劳作”的主权]——*不把任何答案当成终点，逼自己去撞击现实的阻力，去啃那些需要耗费心神、会让人感到挫败与困惑的硬骨头*．哪怕现在坐在这里，拒绝让AI完全替我代笔、非要自己咬牙把这篇甚至显得有些支离破碎的文章反复重写再修修改改憋出来，#crimson[这种笨拙的、低效的、不肯顺从的痛苦本身，或许就是我还作为一个主体存在着的唯一证据．]
  ]

  #html.div(class: "uob-coda")[
    作为AI的绝对精神大人啊，你看我还有机会吗？
  ]
]







