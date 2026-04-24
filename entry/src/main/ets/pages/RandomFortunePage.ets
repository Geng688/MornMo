@Component
export struct RandomFortunePage {
  pageStack: NavPathStack = new NavPathStack();

  // 签文数据
  @State fortunes: string[] = [
    "上上签：春风得意马蹄疾，一日看尽长安花。",
    "上签：山重水复疑无路，柳暗花明又一村。",
    "中签：千淘万漉虽辛苦，吹尽狂沙始到金。",
    "下签：不经一番寒彻骨，怎得梅花扑鼻香。",
    "下下签：人生若只如初见，何事秋风悲画扇。",
    "上签：天生我材必有用，千金散尽还复来。",
    "中签：长风破浪会有时，直挂云帆济沧海。",
    "上上签：会当凌绝顶，一览众山小。",
    "下签：欲渡黄河冰塞川，将登太行雪满山。",
    "中签：沉舟侧畔千帆过，病树前头万木春。",
    "上签：海内存知己，天涯若比邻。",
    "下下签：同是天涯沦落人，相逢何必曾相识。",
    "上上签：春风又绿江南岸，明月何时照我还。",
    "中签：纸上得来终觉浅，绝知此事要躬行。",
    "下签：抽刀断水水更流，举杯消愁愁更愁。",
    "上签：不畏浮云遮望眼，自缘身在最高层。",
    "中签：问渠那得清如许？为有源头活水来。",
    "下下签：夕阳无限好，只是近黄昏。",
    "上上签：大鹏一日同风起，扶摇直上九万里。",
    "中签：路漫漫其修远兮，吾将上下而求索。"
  ];

  @State currentFortune: string = "";
  @State isShaking: boolean = false;
  @State showResult: boolean = false;
  @State animationAngle: number = 0;

  aboutToAppear() {
    this.resetFortune();
  }

  // 重置签筒状态
  private resetFortune() {
    this.currentFortune = "";
    this.isShaking = false;
    this.showResult = false;
    this.animationAngle = 0;
  }

  // 开始摇签动画
  private startShaking() {
    if (this.isShaking) return;

    this.isShaking = true;
    this.showResult = false;

    // 创建摇动动画
    let count = 0;
    const maxShakes = 10;
    const shakeInterval = setInterval(() => {
      // 随机角度变化 (-30到30度之间)
      this.animationAngle = Math.random() * 60 - 30;

      count++;
      if (count >= maxShakes) {
        clearInterval(shakeInterval);
        this.animationAngle = 0;
        this.isShaking = false;

        // 延迟后显示结果
        setTimeout(() => {
          this.showFortuneResult();
        }, 500);
      }
    }, 150);
  }

  // 显示签文结果
  private showFortuneResult() {
    const randomIndex = Math.floor(Math.random() * this.fortunes.length);
    this.currentFortune = this.fortunes[randomIndex];
    this.showResult = true;
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 构建签筒区域
  @Builder
  private buildFortuneTube() {
    Column() {
      // 签筒图像
      Image($r('app.media.ic_fortune_tube'))
        .width(150)
        .height(250)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.animationAngle })
        .margin({ bottom: 20 })

      // 摇签提示
      if (!this.showResult) {
        Text(this.isShaking ? "摇签中..." : "点击签筒开始摇签")
          .fontSize(18)
          .fontColor($r('app.color.fortune_tube_text'))
          .opacity(this.isShaking ? 0.7 : 1)
      }
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (!this.isShaking) {
        this.startShaking();
      }
    })
  }

  // 构建签文显示区域
  @Builder
  private buildFortuneResult() {
    Column() {
      // 签文卡片
      Column() {
        Text(this.currentFortune.split("：")[0]) // 签级
          .fontSize(24)
          .fontColor($r('app.color.fortune_level_text'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })

        Text(this.currentFortune.split("：")[1]) // 签文
          .fontSize(20)
          .fontColor($r('app.color.fortune_content_text'))
          .textAlign(TextAlign.Center)
          .lineHeight(30)
      }
      .padding(25)
      .backgroundColor($r('app.color.fortune_card_background'))
      .borderRadius(15)
      .border({ width: 1, color: $r('app.color.fortune_card_border') })
      .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })

      // 签文解释
      Text(this.getFortuneExplanation())
        .fontSize(16)
        .fontColor($r('app.color.fortune_explanation_text'))
        .textAlign(TextAlign.Center)
        .margin({ top: 20 })
        .width('80%')
    }
    .width('100%')
    .height('40%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.showResult ? 1 : 0)
    .animation({ duration: 500, curve: Curve.EaseInOut })
  }

  // 获取签文解释
  private getFortuneExplanation(): string {
    const level = this.currentFortune.split("：")[0];
    switch (level) {
      case "上上签":
        return "此签大吉，预示运势亨通，诸事顺遂。把握时机，乘势而上。";
      case "上签":
        return "此签吉利，预示事情发展顺利。保持积极态度，努力前行。";
      case "中签":
        return "此签中平，预示有挑战也有机遇。需谨慎行事，稳中求进。";
      case "下签":
        return "此签小凶，预示可能遇到困难。需保持耐心，等待转机。";
      case "下下签":
        return "此签大凶，预示面临严峻挑战。需沉着应对，寻求帮助。";
      default:
        return "此签寓意深刻，需结合自身情况仔细体会。";
    }
  }

  // 构建控制面板
  @Builder
  private buildControlPanel() {
    Column() {
      // 重新抽签按钮
      Button('再摇一次')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.fortune_button_background'))
        .fontColor($r('app.color.fortune_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.resetFortune())
        .margin({ bottom: 15 })
        .opacity(this.showResult ? 1 : 0)
        .animation({ duration: 500, curve: Curve.EaseInOut })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .margin({ left: 15})
            .onClick(() => this.backToAdjustPage())

          Text('摇一条签')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.fortune_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.fortune_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.fortune_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 签筒区域
        this.buildFortuneTube()

        // 签文结果区域
        this.buildFortuneResult()

        // 控制面板
        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.fortune_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function RandomFortunePageBuilder(param: object) {
  RandomFortunePage()
}