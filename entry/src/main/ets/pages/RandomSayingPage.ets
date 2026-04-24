interface saying {
  content: string,
  author: string
}

@Component
export struct RandomSayingPage {
  pageStack: NavPathStack = new NavPathStack();

  // 乐语数据 - 保持不变
  @State sayings: saying[] = [
    { content: "生活就像一盒巧克力，你永远不知道下一颗是什么味道。", author: "" },
    { content: "每一次跌倒都是为了更好地站起来。", author: "" },
    { content: "阳光总在风雨后，请相信有彩虹。", author: "" },
    { content: "微笑面对生活，生活也会对你微笑。", author: "" },
    { content: "今天的努力是明天的收获。", author: "" },
    { content: "心若向阳，无畏悲伤。", author: "" },
    { content: "做最好的自己，比什么都重要。", author: "" },
    { content: "生命中最美好的事情，往往发生在意料之外。", author: "" },
    { content: "相信自己，你能做到比你想象的更多。", author: "" },
    { content: "快乐不是因为拥有的多，而是计较的少。", author: "" },
    { content: "每一天都是新的开始，充满无限可能。", author: "" },
    { content: "困难只是暂时的，坚持就是胜利。", author: "" },
    { content: "爱自己，是终身浪漫的开始。", author: "" },
    { content: "你的存在本身就是一种奇迹。", author: "" },
    { content: "小小的进步也是进步，值得庆祝。", author: "" },
    { content: "保持热爱，奔赴山海。", author: "" },
    { content: "温柔待人，世界也会温柔待你。", author: "" },
    { content: "放下过去，珍惜当下，期待未来。", author: "" },
    { content: "每一次呼吸都是新的开始。", author: "" },
    { content: "你是独一无二的，没有人能取代你。", author: "" },
    { content: "感恩生活中的每一个小确幸。", author: "" },
    { content: "内心强大的人，从不惧怕任何挑战。", author: "" },
    { content: "微笑是最美的语言。", author: "" },
    { content: "生活不会辜负努力的人。", author: "" },
    { content: "做自己的太阳，无需凭借谁的光。", author: "" },
    { content: "勇敢追求梦想，即使道路漫长。", author: "" },
    { content: "幸福不在于目的地，而在于旅途本身。", author: "" },
    { content: "你的价值不取决于别人的评价。", author: "" },
    { content: "保持好奇心，世界充满惊喜。", author: "" },
    { content: "每一天都是改变生活的机会。", author: "" },
    { content: "善待他人，就是善待自己。", author: "" },
    { content: "坚持做正确的事，时间会给你答案。", author: "" },
    { content: "别让昨天的雨淋湿今天的阳光。", author: "" },
    { content: "内心的平静是最大的财富。", author: "" },
    { content: "你的笑容能照亮整个世界。", author: "" },
    { content: "小小的善意能改变别人的一天。", author: "" },
    { content: "成长比成功更重要。", author: "" },
    { content: "允许自己休息，允许自己犯错。", author: "" },
    { content: "你比自己想象的更坚强。", author: "" },
    { content: "生活不是等待风暴过去，而是学会在雨中跳舞。", author: "" },
    { content: "每一个结束都是新的开始。", author: "" },
    { content: "梦想不会逃跑，逃跑的永远是自己。", author: "" },
    { content: "做自己喜欢的事，让时间变得有意义。", author: "" },
    { content: "快乐是一种选择，而不是结果。", author: "" },
    { content: "真正的力量来自内心的平静。", author: "" },
    { content: "今天的努力是为了明天的自由。", author: "" },
    { content: "你值得拥有美好的事物。", author: "" },
    { content: "爱是世界上最强大的力量。", author: "" },
    { content: "感恩的心是快乐的源泉。", author: "" },
    { content: "每一次挑战都是成长的机会。", author: "" },
    { content: "做自己的英雄，无需他人认可。", author: "" },
    { content: "简单的生活带来最大的幸福。", author: "" },
    { content: "你的存在让世界更美好。", author: "" },
    { content: "向前看，未来充满希望。", author: "" },
    { content: "原谅别人就是释放自己。", author: "" },
    { content: "小小的进步也是胜利。", author: "" },
    { content: "每一天都是新的礼物。", author: "" },
    { content: "保持积极，好事自然会发生。", author: "" },
    { content: "你的潜力超乎你的想象。", author: "" },
    { content: "善良是最美的品质。", author: "" },
    { content: "享受过程，结果自然会来。", author: "" },
    { content: "你是自己人生的作者。", author: "" },
    { content: "微笑是免费的良药。", author: "" },
    { content: "相信自己，你能行。", author: "" },
    { content: "每一次尝试都值得骄傲。", author: "" },
    { content: "活在当下，珍惜此刻。", author: "" },
    { content: "你的努力终将开花结果。", author: "" },
    { content: "爱自己，才能更好地爱别人。", author: "" },
    { content: "困难是成长的催化剂。", author: "" },
    { content: "保持希望，光明就在前方。", author: "" },
    { content: "你的独特是最大的财富。", author: "" },
    { content: "感恩每一个日出日落。", author: "" },
    { content: "小小的改变带来大的不同。", author: "" },
    { content: "坚持做自己，不必迎合他人。", author: "" },
    { content: "快乐源于内心的满足。", author: "" },
    { content: "每一天都是新的冒险。", author: "" },
    { content: "你的勇气鼓舞他人。", author: "" },
    { content: "善待自己，你是值得的。", author: "" },
    { content: "梦想需要行动来实现。", author: "" },
    { content: "微笑面对挑战，你会更强大。", author: "" },
    { content: "你的存在本身就是礼物。", author: "" },
    { content: "保持学习的心态，永远年轻。", author: "" },
    { content: "感恩生活中的小确幸。", author: "" },
    { content: "你的故事正在书写中。", author: "" },
    { content: "坚持信念，终会成功。", author: "" },
    { content: "快乐是一种能力，可以培养。", author: "" },
    { content: "你的内心有无限的力量。", author: "" },
    { content: "每一次呼吸都是新的机会。", author: "" },
    { content: "善待他人，收获快乐。", author: "" },
    { content: "做真实的自己最快乐。", author: "" },
    { content: "生活因你而精彩。", author: "" },
    { content: "保持好奇心，探索世界。", author: "" },
    { content: "你的笑容能治愈他人。", author: "" },
    { content: "坚持梦想，永不放弃。", author: "" },
    { content: "感恩当下，珍惜拥有。", author: "" },
    { content: "你是自己命运的主宰。", author: "" },
    { content: "每一次努力都不会白费。", author: "" },
    { content: "快乐源于内心的选择。", author: "" },
    { content: "你的价值无法用金钱衡量。", author: "" },
    { content: "保持善良，世界更美好。", author: "" },
    { content: "每一天都是新的开始。", author: "" },
    { content: "你的坚持终将改变世界。", author: "" },
    { content: "微笑面对生活，生活回报微笑。", author: "" },
    { content: "你是独一无二的存在。", author: "" },
    // 有作者的语句：仅需在author字段填写作者信息，无需加破折号（代码中自动添加）
    { content: "希望是坚韧的拐杖，忍耐是旅行袋，携带它们，人可以登上永恒之旅。", author: "伯特兰・罗素" },
    { content: "千里之行，始于足下。", author: "《道德经》（老子）" },
    { content: "只要一息尚存，一个人就不应当放弃希望。", author: "佚名" },
    { content: "风可以吹起一张大白纸，却无法吹走一只蝴蝶，因为生命的力量在于不顺从。", author: "冯骥才" },
    { content: "勇气是尽管你感觉害怕，但仍能迎难而上；尽管你感觉痛苦，但仍能直接面对。", author: "佚名" },
    { content: "一个人只要强烈地坚持不懈地追求，他就能到达目的。", author: "司汤达" },
    { content: "天行健，君子以自强不息；地势坤，君子以厚德载物。", author: "《周易》" },
    { content: "生活不止眼前的苟且，还有诗和远方。", author: "高晓松" },
    { content: "真正的富有，是你脸上的微笑。", author: "佚名" },
    { content: "人生没有白走的路，每一步都算数。", author: "李宗盛" },
    { content: "每一个不曾起舞的日子，都是对生命的辜负。", author: "弗里德里希・尼采" },
    { content: "真正的自由是独立，不依附，不恐惧。", author: "克里希那穆提" },
    { content: "生命如同寓言，其价值不在长短，而在内容。", author: "塞涅卡" },
    { content: "笑一笑，十年少。", author: "中国民间谚语" },
    { content: "生活就像一面镜子，你对它笑，它也会对你笑。", author: "佚名" },
    { content: "不要害怕你的生活将要结束，应该担心你的生活永远不会真正开始。", author: "爱德华・摩根・福斯特" },
    { content: "快乐不是因为拥有的多，而是计较的少。", author: "佚名" },
    { content: "世界以痛吻我，要我报之以歌。", author: "拉宾德拉纳特・泰戈尔" },
    { content: "己所不欲，勿施于人。", author: "《论语》（孔子）" },
    { content: "满招损，谦受益。", author: "《尚书》" },
    { content: "粗茶淡饭就是福。", author: "中国民间谚语" },
    { content: "世界上最宽阔的是海洋，比海洋更宽阔的是天空，比天空更宽阔的是人的胸怀。", author: "维克多・雨果" },
    { content: "如果你因错过太阳而流泪，那么你也将错过群星。", author: "拉宾德拉纳特・泰戈尔" },
    { content: "你改变不了一座山的轮廓，改变不了一只鸟的飞翔轨迹，改变不了河水流淌的速度，所以只是观察它，发现它的美就够了。", author: "克里希那穆提" },
    { content: "时光对于人，其实就是生命的过程。当生命走到终点，不一定消失得没有痕迹，有时它还会转化为另一种形态存在或再生。", author: "冯骥才" },
    { content: "Stay hungry, stay foolish.（求知若饥，虚心若愚。）", author: "史蒂夫・乔布斯" },
    { content: "我宁愿靠自己的力量打开我的前途，而不求权势者垂青。", author: "维克多・雨果" },
    { content: "如果你足够坚强，你就是史无前例的。", author: "弗朗西斯・斯科特・菲茨杰拉德" },
    { content: "一个人可以默默无闻地活在世界上，完全不被人知道，没有名气、野心和残酷。如果一个人不认为自己有多么重要，他可以活得非常快乐。", author: "克里希那穆提" },
    { content: "只要持续地努力，不懈地奋斗，就没有征服不了的东西。", author: "卢修斯・安奈乌斯・塞内卡" },
    { content: "真正能给你撑腰的，是丰富的知识储备，足够的经济基础，持续的情绪稳定，可控的生活节奏，和那个打不败的自己。", author: "佚名" },
    { content: "忍耐虽然痛苦，果实却最香甜。", author: "穆罕默德・萨迪" },
    { content: "当你做成功一件事，千万不要等待着享受荣誉，应该再做那些需要的事。", author: "路易・巴斯德" },
    { content: "友谊是灵魂的结合，这个结合是可以离异的，这是两个敏感、正直的人之间心照不宣的契约。", author: "伏尔泰" },
    { content: "周围都有好朋友的人，比四面楚歌的人不知幸福多少。", author: "多萝西・卡内基" },
    { content: "朋友间保持一定的距离，而使友谊永存。", author: "查尔斯・兰姆" },
    { content: "与其用华丽的外衣装饰自己，不如用知识武装自己。", author: "卡尔・马克思" },
    { content: "没有人不爱惜他的生命，但很少人珍视他的时间。", author: "佚名" },
    { content: "抛弃时间的人，时间也抛弃他。", author: "威廉・莎士比亚" },
    { content: "时间对生命用减法，对生命创造的却用加法。", author: "冯骥才" },
    { content: "存在即合理。", author: "格奥尔格・威廉・弗里德里希・黑格尔" },
    { content: "我思故我在。", author: "勒内・笛卡尔" },
    { content: "世界上只有一种真正的英雄主义，那就是在认清生活的真相后依然热爱生活。", author: "罗曼・罗兰" },
    { content: "一个人知道自己为什么而活，就可以忍受任何一种生活。", author: "弗里德里希・尼采" },
    { content: "过去属于死神，未来属于你自己。", author: "珀西・比希・雪莱" },
    { content: "未经省察的人生不值得过。", author: "苏格拉底" },
    { content: "认识你自己。", author: "德尔斐神庙铭文" },
    { content: "人生在世，还不是有时笑笑人家，有时给人家笑笑。", author: "林语堂" },
    { content: "生命的意义在于给予，而不在于接受。", author: "阿尔伯特・爱因斯坦" },
    { content: "生活在前进，它之所以前进，是因为有希望在；没有了希望，绝望就会把生命毁掉。", author: "佚名" },
    { content: "你最大的冒险，就是成为你本来的样子。", author: "奥普拉・温弗瑞" },
    { content: "永远没有人力可以击退一个坚决强毅的希望。", author: "佚名" },
    { content: "希望至少是穷人易于得到的快乐。", author: "佚名" },
    { content: "希望似阳光，驱散迷雾，照亮前进的道路。", author: "佚名" },
    { content: "拥抱希望是穷人的粮食。", author: "佚名" },
    { content: "只有能够实现的希望才能产生爱，只有希望才能保持爱。", author: "普布留斯・奥维德" },
    { content: "如果你想走得快，就一个人走；如果你想走得远，就一起走。", author: "非洲民间谚语" },
    { content: "人生的力量全是对手给的，那就是要把对手的压力吸入自己的骨头里。强者之力最主要的是承受力。", author: "冯骥才" },
    { content: "没有伟大的意志力，便没有雄才大略。", author: "奥诺雷・德・巴尔扎克" },
    { content: "耐心和恒心总会得到报酬的。", author: "阿尔伯特・爱因斯坦" },
    { content: "人要有毅力，否则将一事无成。", author: "玛丽・居里" },
    { content: "强者创造事变，弱者受制于命运。", author: "阿尔封斯・德・维尼" },
    { content: "生活于愿望之中而没有希望，是人生最大的悲哀。", author: "阿利盖利・但丁" },
    { content: "希望本身是一种幸福，也许是这个世界能够提供的主要幸福。", author: "佚名" },
    { content: "当你不在乎，你就得到。", author: "佚名" },
    { content: "真正的快乐，是对生活的乐观，对工作的愉快，对事业的热心。", author: "阿尔伯特・爱因斯坦" },
    { content: "生活的目标，是值得寻找的财富。", author: "罗伯特・路易斯・史蒂文森" },
    { content: "天空是永远宁静的湖水，湖水是永难平静的天空。", author: "冯骥才" },
    { content: "冬天与春天的界限是瓦解。", author: "冯骥才" },
    { content: "永恒的核是绝对的孤独。孤独是一种富有，一种自足，一种随心所欲。", author: "冯骥才" },
  ];

  @State currentSaying: saying = { content: "", author: "" };
  @State textSize: number = 22;
  @State isHeartGlowing: boolean = false;

  aboutToAppear() {
    this.showRandomSaying();
  }

  // 显示随机乐语
  private showRandomSaying() {
    const randomIndex = Math.floor(Math.random() * this.sayings.length);
    this.currentSaying = this.sayings[randomIndex];
    this.textSize = 22;
    this.isHeartGlowing = false;
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 构建乐语显示区域
  @Builder
  private buildSayingArea() {
    Column() {
      // 心形图标
      Image($r('app.media.ic_saying'))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 20 })
        .opacity(this.isHeartGlowing ? 1 : 0.7)

      // 乐语内容卡片
      Column() {
        // 主内容部分
        Text(this.currentSaying.content)
          .fontSize(this.textSize)
          .fontColor($r('app.color.saying_content_text'))
          .textAlign(TextAlign.Center)
          .lineHeight(35)
          .margin({ bottom: this.currentSaying.author ? 15 : 0 })

        // 作者部分（如果存在）
        if (this.currentSaying.author) {
          Text(`—— ${this.currentSaying.author}`)
            .fontSize(this.textSize * 0.7)
            .fontColor($r('app.color.saying_author_text'))
            .textAlign(TextAlign.End)
            .width('100%')
            .fontStyle(FontStyle.Italic)
        }
      }
      .padding(25)
      .backgroundColor($r('app.color.saying_card_background'))
      .borderRadius(15)
      .border({ width: 1, color: $r('app.color.saying_card_border') })
      .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      // 点击文字放大效果和心形动画
      this.textSize = this.textSize === 22 ? 26 : 22;
      this.isHeartGlowing = !this.isHeartGlowing;
    })
  }

  // 构建控制面板
  @Builder
  private buildControlPanel() {
    Column() {
      // 刷新按钮
      Button('换一句心语')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.saying_button_primary'))
        .fontColor($r('app.color.saying_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.showRandomSaying())
        .margin({ bottom: 15 })

      // 收藏按钮（注释掉的部分保持原样）
      /*Button('收藏心语')
        .width(200)
        .height(50)
        .backgroundColor('#9C27B0')
        .fontColor(Color.White)
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.saveSaying())*/
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 收藏心语功能
  private saveSaying() {
    console.log('收藏心语：' + this.currentSaying.content.substring(0, 20) + '...');
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .margin({ left: 15 })
            .onClick(() => this.backToAdjustPage())

          Text('随机心语')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.saying_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.saying_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.saying_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 乐语显示区域
        this.buildSayingArea()

        // 控制面板
        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.saying_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function RandomSayingPageBuilder(param: object) {
  RandomSayingPage()
}