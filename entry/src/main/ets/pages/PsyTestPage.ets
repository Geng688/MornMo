import { AppStorageV2 } from "@kit.ArkUI";

interface TestCard {
  title: string;
  description: string;
  colors: Resource[];
  onClick: () => void;
}

@Component
export struct PsyTestPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!

  // 导航到各测试页面（逻辑不变）
  private navigateToMBTI() {
    this.pageStack.pushPathByName('MBTIPage', false, null)
  }

  private navigateToBigFive() {
    this.pageStack.pushPathByName('BigFivePage', false, null)
  }

  private navigateToHolland() {
    this.pageStack.pushPathByName('HollandPage', false, null)
  }

  private navigateToSCL90() {
    this.pageStack.pushPathByName('RandomActionPage', false, null)
  }

  private navigateToSDS() {
    this.pageStack.pushPathByName('RandomActionPage', false, null)
  }

  private navigateToSAS() {
    this.pageStack.pushPathByName('SASPage', false, null)
  }

  private navigateToEPQ() {
    this.pageStack.pushPathByName('EPQPage', false, null)
  }

  private navigateToSelfEsteem() {
    this.pageStack.pushPathByName('SESPage', false, null)
  }

  // 测评卡片数据（内容不变）
  private getTestCards(): TestCard[] {
    return [
      {
        title: 'MBTI性格测试',
        description: '帮你精准识别自身性格类型，明确思维模式、决策偏好和社交风格。无论学生选专业、职场人做职业规划，还是改善人际关系，都能提供清晰的自我认知参考。',
        colors: [$r('app.color.psy_test_card1_color1'), $r('app.color.psy_test_card1_color2')],
        onClick: (): void => this.navigateToMBTI()
      },
      {
        title: '大五人格测试',
        description: '从五个核心维度全面评估人格特质，不仅能帮你看清自身优势与短板，还能预测在职业表现、婚恋关系中的潜在倾向，助力更科学的人生决策。',
        colors: [$r('app.color.psy_test_card2_color1'), $r('app.color.psy_test_card2_color2')],
        onClick: (): void => this.navigateToBigFive()
      },
      {
        title: '霍兰德职业测试',
        description: '通过匹配兴趣与职业类型，帮你发现潜在的职业方向。尤其适合学生选专业、职场人转型，减少职业试错成本，让工作更贴合自身天赋与热情。',
        colors: [$r('app.color.psy_test_card3_color1'), $r('app.color.psy_test_card3_color2')],
        onClick: (): void => this.navigateToHolland()
      },
      {
        title: '焦虑自评量表(SAS)',
        description: '聚焦紧张、恐惧、心悸等焦虑症状，科学评估焦虑程度。无论是日常压力管理，还是识别潜在焦虑问题，都能提供清晰的自我认知。',
        colors: [$r('app.color.psy_test_card4_color1'), $r('app.color.psy_test_card4_color2')],
        onClick: (): void => this.navigateToSAS()
      },
      {
        title: '艾森克人格问卷(EPQ)',
        description: '聚焦内外向、情绪稳定性等核心人格特质，帮你把握深层行为倾向。适合想了解自身性格根源、改善情绪管理和社交模式的人群。',
        colors: [$r('app.color.psy_test_card5_color1'), $r('app.color.psy_test_card5_color2')],
        onClick: (): void => this.navigateToEPQ()
      },
      {
        title: '自尊量表',
        description: '评估自我价值感与接纳度，反映自尊水平的健康状态。能帮你发现自我认知中的偏差，为提升自信、改善人际关系提供针对性方向。',
        colors: [$r('app.color.psy_test_card6_color1'), $r('app.color.psy_test_card6_color2')],
        onClick: (): void => this.navigateToSelfEsteem()
      }
    ];
  }

  // 卡片样式（保持不变）
  @Builder
  private buildTestCard(
    title: string,
    description: string,
    colors: Resource[],
    onClick: () => void
  ): void {
    Column() {
      Column() {
        Text(title)
          .fontSize(18)
          .fontColor($r('app.color.psy_test_card_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        Text(description)
          .fontSize(13)
          .fontColor($r('app.color.psy_test_card_description'))
          .maxLines(5)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(20)
      }
      .padding(18)
      .layoutWeight(1)
    }
    .width('100%')
    .height(130)
    .borderRadius(15)
    .linearGradient({
      direction: GradientDirection.Left,
      repeating: true,
      colors: [
        [colors[0], 0.0],
        [colors[1], 1.0]
      ]
    })
    .onClick(onClick)
    .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
  }

  build() {
    Column() {
      // 顶部标题
      Text('心理测评')
        .fontSize(30)
        .fontColor($r('app.color.psy_test_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 20 })

      // 卡片区域
      Grid() {
        ForEach(this.getTestCards(), (card: TestCard) => {
          GridItem() {
            this.buildTestCard(
              card.title,
              card.description,
              card.colors,
              card.onClick
            )
          }
          .margin(5)
        }, (card: TestCard) => card.title)
      }
      .columnsTemplate('1fr')
      .rowsGap(15)
      .width('100%')
      .padding(15)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      // 新增：免责声明区域
      Column() {
        /*Text('免责声明')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 5 })*/

        Text('本页面提供的心理测评（含 MBTI、大五人格、焦虑自评等）均为自我认知参考工具，仅用于辅助个人了解自身心理特质、兴趣倾向或情绪状态，不构成专业心理诊断、医疗建议或治疗方案。')
          .fontSize(12)
          .fontColor($r('app.color.psy_test_disclaimer_text'))
          .textAlign(TextAlign.Start)
          .lineHeight(18)
      }
      .width('100%')
      .padding({ left: 15, right: 15, bottom: 20, top: 10 })
      .margin({top:20})
      .backgroundColor($r('app.color.psy_test_disclaimer_background'))
      .borderRadius(10)
      .shadow({ radius: 4, color: '#20000000', offsetX: 0, offsetY: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.psy_test_background'))
    .padding(20)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@Builder
export function PsyTestPageBuilder(param: object) {
  PsyTestPage()
}