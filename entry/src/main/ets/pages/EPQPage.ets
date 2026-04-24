import { promptAction } from "@kit.ArkUI";

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  dimension: string;
  reverseScoring: boolean;
}

// 定义维度描述
interface EPQDimension {
  title: string;
  description: string;
}

// 定义结果描述
interface EPQResult {
  dimension: string;
  score: number;
  level: string;
  description: string;
}

@Component
export struct EPQPage {
  pageStack: NavPathStack = new NavPathStack();

  // EPQ测试问题
  @State questions: QuestionItem[] = [
  // 内外向（E）维度
    { id: 1, text: "我喜欢主动结识新朋友。", dimension: "E", reverseScoring: false },
    { id: 2, text: "我常因小事感到兴奋或激动。", dimension: "E", reverseScoring: false },
    { id: 3, text: "我更愿意独自安静地看书，而非参加聚会。", dimension: "E", reverseScoring: true },
    { id: 4, text: "我在社交场合中能快速融入并活跃气氛。", dimension: "E", reverseScoring: false },
    { id: 5, text: "我喜欢尝试刺激的活动（如过山车、冒险运动）。", dimension: "E", reverseScoring: false },
    { id: 6, text: "我更倾向于通过独处恢复精力。", dimension: "E", reverseScoring: true },

    // 神经质（N）维度
    { id: 7, text: "我容易因压力而失眠或做噩梦。", dimension: "N", reverseScoring: false },
    { id: 8, text: "我常因他人的评价而感到焦虑。", dimension: "N", reverseScoring: false },
    { id: 9, text: "我情绪波动较大，可能突然开心或低落。", dimension: "N", reverseScoring: false },
    { id: 10, text: "我对批评非常敏感，容易受伤。", dimension: "N", reverseScoring: false },
    { id: 11, text: "我常担心未来会发生不好的事情。", dimension: "N", reverseScoring: false },
    { id: 12, text: "我能很快从负面情绪中恢复。", dimension: "N", reverseScoring: true },
    { id: 13, text: "我在面对困难时容易感到无助。", dimension: "N", reverseScoring: false },

    // 精神质（P）维度
    { id: 14, text: "我有时会对他人的痛苦缺乏同情心。", dimension: "P", reverseScoring: false },
    { id: 15, text: "我喜欢挑战权威或打破常规。", dimension: "P", reverseScoring: false },
    { id: 16, text: "我常觉得自己与周围人格格不入。", dimension: "P", reverseScoring: false },
    { id: 17, text: "我会为达到目标而不择手段。", dimension: "P", reverseScoring: false },
    { id: 18, text: "我对动物的痛苦比对人的痛苦更敏感。", dimension: "P", reverseScoring: true },
    { id: 19, text: "我享受独处，甚至觉得社交是负担。", dimension: "P", reverseScoring: false },
    { id: 20, text: "我常因冲动而做出让自己后悔的事。", dimension: "P", reverseScoring: false }
  ] as QuestionItem[];

  // 维度描述
  @State dimensionDescriptions: Record<string, EPQDimension> = {
    "E": { title: "内外向（E）", description: "高分 = 外向活跃，低分 = 内向沉静" } as EPQDimension,
    "N": { title: "神经质（N）", description: "高分 = 情绪不稳定，低分 = 情绪稳定" } as EPQDimension,
    "P": { title: "精神质（P）", description: "高分 = 独立固执，低分 = 温和适应" } as EPQDimension
  };

  // 结果描述
  @State resultDescriptions: Record<string, string[]> = {
    "E": [
      "内向倾向：安静、内省、社交谨慎，偏好独处和深度思考",
      "中间型：灵活适应不同社交情境，既享受独处也能参与社交",
      "外向倾向：活跃、社交积极、追求刺激，喜欢与人互动"
    ],
    "N": [
      "情绪稳定：冷静、抗压能力强，不易受外界影响",
      "中间型：偶有情绪波动但可控，能自我调节",
      "情绪不稳定：敏感、焦虑、易受压力影响，情绪波动大"
    ],
    "P": [
      "低精神质：温和、富有同情心、适应社会规则",
      "中间型：在规则与自我之间保持平衡",
      "高精神质：独立、固执、可能表现出反社会倾向"
    ]
  };

  @State currentQuestionIndex: number = 0;
  @State userScores: number[] = new Array(20).fill(0);
  @State showResult: boolean = false;
  @State epqResults: EPQResult[] = [];

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userScores = new Array(20).fill(0);
    this.showResult = false;
    this.epqResults = [];
  }

  // 选择分数
  private selectScore(score: number) {
    this.userScores[this.currentQuestionIndex] = score;

    if (this.currentQuestionIndex < this.questions.length - 1) {
      this.currentQuestionIndex++;
    } else {
      this.calculateResult();
    }
  }

  // 上一题
  private previousQuestion() {
    if (this.currentQuestionIndex > 0) {
      this.currentQuestionIndex--;
    }
  }

  // 计算EPQ结果
  private calculateResult() {
    const dimensionScores: Record<string, number> = {
      "E": 0,
      "N": 0,
      "P": 0
    };

    // 反向计分题索引（3,6,12,18）
    const reverseScoringIndices: number[] = [2, 5, 11, 17]; // 数组索引从0开始

    this.questions.forEach((question: QuestionItem, index: number) => {
      let score = this.userScores[index];

      // 如果是反向计分题，转换分数
      if (reverseScoringIndices.includes(index)) {
        score = 5 - score; // 1→4，2→3，3→2，4→1
      }

      dimensionScores[question.dimension] += score;
    });

    // 生成结果
    this.epqResults = Object.keys(dimensionScores).map((dimension: string) => {
      const score = dimensionScores[dimension];
      let level = "";
      let description = "";

      if (dimension === "E") {
        if (score <= 12) {
          level = "内向倾向";
          description = this.resultDescriptions[dimension][0];
        } else if (score <= 18) {
          level = "中间型";
          description = this.resultDescriptions[dimension][1];
        } else {
          level = "外向倾向";
          description = this.resultDescriptions[dimension][2];
        }
      } else if (dimension === "N") {
        if (score <= 12) {
          level = "情绪稳定";
          description = this.resultDescriptions[dimension][0];
        } else if (score <= 18) {
          level = "中间型";
          description = this.resultDescriptions[dimension][1];
        } else {
          level = "情绪不稳定";
          description = this.resultDescriptions[dimension][2];
        }
      } else if (dimension === "P") {
        if (score <= 12) {
          level = "低精神质";
          description = this.resultDescriptions[dimension][0];
        } else if (score <= 18) {
          level = "中间型";
          description = this.resultDescriptions[dimension][1];
        } else {
          level = "高精神质";
          description = this.resultDescriptions[dimension][2];
        }
      }

      return {
        dimension,
        score,
        level,
        description
      } as EPQResult;
    });

    this.showResult = true;

    promptAction.showToast({
      message: "测试完成！您的EPQ结果已生成",
      duration: 3000,
      bottom: 200
    });
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 构建进度指示器
  @Builder
  private buildProgressIndicator() {
    Row() {
      Text(`进度：${this.currentQuestionIndex + 1}/${this.questions.length}`)
        .fontSize(16)
        .fontColor($r('app.color.epq_progress_text'))

      Blank()

      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.epq_progress_background'))
        .color($r('app.color.epq_progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.epq_progress_container'))
  }

  // 构建问题显示区域
  @Builder
  private buildQuestionArea() {
    if (this.showResult) {
      this.buildResultArea();
    } else {
      this.buildTestArea();
    }
  }

  // 构建测试区域
  @Builder
  private buildTestArea() {
    Column() {
      // 维度标题
      Text(this.dimensionDescriptions[this.questions[this.currentQuestionIndex].dimension].title)
        .fontSize(18)
        .fontColor($r('app.color.epq_dimension_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      // 维度描述
      Text(this.dimensionDescriptions[this.questions[this.currentQuestionIndex].dimension].description)
        .fontSize(16)
        .fontColor($r('app.color.epq_dimension_description'))
        .margin({ bottom: 20 })
        .textAlign(TextAlign.Center)

      // 问题卡片
      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.epq_question_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.epq_question_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.epq_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      // 评分说明
      Text("评分标准：")
        .fontSize(16)
        .fontColor($r('app.color.epq_instruction_text'))
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      Text("1 = 完全不符合，2 = 不太符合，3 = 比较符合，4 = 完全符合")
        .fontSize(14)
        .fontColor($r('app.color.epq_instruction_text'))
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      // 评分区域
      Row() {
        ForEach([1, 2, 3, 4], (score: number) => {
          Button(score.toString())
            .width(70)
            .height(70)
            .backgroundColor(this.userScores[this.currentQuestionIndex] === score ? $r('app.color.epq_score_selected') : $r('app.color.epq_score_unselected'))
            .fontColor(this.userScores[this.currentQuestionIndex] === score ? $r('app.color.epq_score_selected_text') : $r('app.color.epq_score_text'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .borderRadius(35)
            .border({ width: 2, color: $r('app.color.epq_score_border') })
            .onClick(() => this.selectScore(score))
            .margin({ right: 10 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 评分标签
      Row() {
        Text("完全不符合")
          .fontSize(14)
          .fontColor($r('app.color.epq_instruction_text'))
          .margin({ right: 30 })

        Text("完全符合")
          .fontSize(14)
          .fontColor($r('app.color.epq_instruction_text'))
          .margin({ left: 30 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('70%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
  }

  // 构建结果区域
  @Builder
  private buildResultArea() {
    Column() {
      Text("艾森克人格问卷（EPQ）结果")
        .fontSize(24)
        .fontColor($r('app.color.epq_result_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })

      // 免责声明
      Text("注意：此为精简版测试，结果仅供参考。人格会随生活经历、环境变化而动态调整。")
        .fontSize(14)
        .fontColor($r('app.color.epq_disclaimer_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(20)
        .margin({ bottom: 20 })
        .padding(10)

      // 结果列表
      List({ space: 12 }) {
        ForEach(this.epqResults, (result: EPQResult) => {
          ListItem() {
            Column() {
              Row() {
                Text(this.dimensionDescriptions[result.dimension].title)
                  .fontSize(18)
                  .fontColor($r('app.color.epq_result_dimension'))
                  .fontWeight(FontWeight.Bold)

                Blank()

                Text(`得分: ${result.score} (${result.level})`)
                  .fontSize(16)
                  .fontColor($r('app.color.epq_result_score'))
              }
              .width('100%')
              .margin({ bottom: 10 })

              Text(result.description)
                .fontSize(16)
                .fontColor($r('app.color.epq_result_description'))
                .lineHeight(24)
                .padding(15)
                .backgroundColor($r('app.color.epq_result_item_background'))
                .borderRadius(10)
                .border({ width: 1, color: $r('app.color.epq_result_item_border') })
            }
            .width('100%')
            .padding(10)
          }
        })
      }
      .width('100%')
      .height('60%')
      .divider({ strokeWidth: 1, color: $r('app.color.epq_divider') })

      // 重要说明
      Text("重要说明")
        .fontSize(18)
        .fontColor($r('app.color.epq_important_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      Text("• 量表局限性：精简版侧重核心维度，可能无法完全反映人格复杂性")
        .fontSize(14)
        .fontColor($r('app.color.epq_important_text'))
        .margin({ bottom: 3 })
        .textAlign(TextAlign.Start)

      Text("• 专业建议：若精神质（P）得分显著偏高，或神经质（N）得分长期处于高位，建议寻求专业评估")
        .fontSize(14)
        .fontColor($r('app.color.epq_important_text'))
        .margin({ bottom: 3 })
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height('70%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
  }

  // 构建控制面板
  @Builder
  private buildControlPanel() {
    Column() {
      if (!this.showResult) {
        Row() {
          Button('上一题')
            .width(120)
            .height(45)
            .backgroundColor(this.currentQuestionIndex > 0 ? $r('app.color.epq_button_previous') : $r('app.color.button_disabled'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.epq_button_skip'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => {
              if (this.currentQuestionIndex < this.questions.length - 1) {
                this.currentQuestionIndex++;
              } else {
                this.calculateResult();
              }
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      } else {
        Row() {
          Button('重新测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.epq_button_retest'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.epq_button_finish'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.backToAdjustPage())
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({top:20})
      }
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
            .margin({ left: 15 })
            .onClick(() => this.backToAdjustPage())

          Text('艾森克人格问卷（EPQ）')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.epq_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.epq_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.epq_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 进度指示器
        this.buildProgressIndicator()

        // 问题/结果显示区域
        this.buildQuestionArea()

        // 控制面板
        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.epq_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function EPQPageBuilder(param:object) {
  EPQPage()
}