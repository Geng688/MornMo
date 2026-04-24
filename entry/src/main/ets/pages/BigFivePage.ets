import { promptAction } from "@kit.ArkUI";

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  dimension: string;
  reverseScoring: boolean;
}

// 定义大五人格维度描述
interface BigFiveDimension {
  title: string;
  description: string;
}

// 定义大五人格结果描述
interface BigFiveResult {
  dimension: string;
  score: number;
  level: string;
  description: string;
}

@Component
export struct BigFivePage {
  pageStack: NavPathStack = new NavPathStack();

  // 大五人格测试问题 - 修复对象字面量类型
  @State questions: QuestionItem[] = [
    { id: 1, text: "遇到压力时，我容易感到焦虑或紧张。", dimension: "神经质", reverseScoring: false },
    { id: 2, text: "我常常会因为小事而情绪低落。", dimension: "神经质", reverseScoring: false },
    { id: 3, text: "面对意外情况，我很难保持冷静。", dimension: "神经质", reverseScoring: false },
    { id: 4, text: "我的情绪状态通常比较平稳，很少大起大落。", dimension: "神经质", reverseScoring: true },

    { id: 5, text: "我喜欢参加热闹的社交活动，与他人互动让我精力充沛。", dimension: "外向性", reverseScoring: false },
    { id: 6, text: "在团队中，我倾向于主动发言并带动氛围。", dimension: "外向性", reverseScoring: false },
    { id: 7, text: "我更享受独处，避免过多的社交场合。", dimension: "外向性", reverseScoring: true },
    { id: 8, text: "与陌生人交流时，我通常能轻松打开话题。", dimension: "外向性", reverseScoring: false },

    { id: 9, text: "我对新事物、新观点充满好奇，愿意尝试不同的生活方式。", dimension: "开放性", reverseScoring: false },
    { id: 10, text: "我喜欢欣赏艺术、音乐或文学作品，能感受到其中的深层内涵。", dimension: "开放性", reverseScoring: false },
    { id: 11, text: "我更倾向于遵循传统经验，对新奇理念持谨慎态度。", dimension: "开放性", reverseScoring: true },
    { id: 12, text: "解决问题时，我会尝试从多个角度思考，不局限于固定方法。", dimension: "开放性", reverseScoring: false },

    { id: 13, text: "我善于理解他人的感受，愿意在他人需要时提供帮助。", dimension: "宜人性", reverseScoring: false },
    { id: 14, text: "与他人意见不合时，我会优先坚持自己的观点，不太愿意妥协。", dimension: "宜人性", reverseScoring: true },
    { id: 15, text: "我重视人际关系的和谐，避免与他人发生冲突。", dimension: "宜人性", reverseScoring: false },
    { id: 16, text: "面对他人的请求，我通常会尽力满足，不轻易拒绝。", dimension: "宜人性", reverseScoring: false },

    { id: 17, text: "我会提前制定计划，并严格按照计划完成任务。", dimension: "尽责性", reverseScoring: false },
    { id: 18, text: "我做事比较随意，很少为未来的事情做详细安排。", dimension: "尽责性", reverseScoring: true },
    { id: 19, text: "对待工作或学习，我会认真负责，尽量避免粗心失误。", dimension: "尽责性", reverseScoring: false },
    { id: 20, text: "我能很好地管理自己的时间，很少出现拖延的情况。", dimension: "尽责性", reverseScoring: false }
  ] as QuestionItem[]; // 添加类型断言

  // 维度描述 - 修复对象字面量类型
  @State dimensionDescriptions: Record<string, BigFiveDimension> = {
    "神经质": { title: "神经质（情绪稳定性）", description: "高分 = 情绪易波动，低分 = 情绪稳定" } as BigFiveDimension,
    "外向性": { title: "外向性（社交倾向）", description: "高分 = 外向活跃，低分 = 内向沉静" } as BigFiveDimension,
    "开放性": { title: "开放性（创新与体验）", description: "高分 = 开放好奇，低分 = 务实传统" } as BigFiveDimension,
    "宜人性": { title: "宜人性（人际合作）", description: "高分 = 友善合作，低分 = 独立果断" } as BigFiveDimension,
    "尽责性": { title: "尽责性（自律与可靠）", description: "高分 = 严谨自律，低分 = 灵活随性" } as BigFiveDimension
  };

  // 结果描述 - 修复对象字面量类型
  @State resultDescriptions: Record<string, string[]> = {
    "神经质": [
      "情绪稳定，面对压力不易焦虑；心态平和，很少因小事低落；能冷静应对意外情况。",
      "情绪状态适中，偶尔有波动但能快速调整；面对压力时，既有紧张感也能自我疏导。",
      "情绪敏感度高，易因压力感到焦虑；可能频繁出现低落情绪；面对意外易慌乱、难冷静。"
    ],
    "外向性": [
      "偏好独处，避免过多社交；在团队中倾向倾听，不主动带动氛围；与陌生人交流较拘谨。",
      "社交意愿适中，既享受独处也能参与热闹活动；在团队中可主动发言，也能配合他人。",
      "喜欢社交，与他人互动能恢复精力；团队中常主动发言、带动氛围；与陌生人交流轻松。"
    ],
    "开放性": [
      "偏好传统经验，对新事物、新观点较谨慎；不太关注艺术/文学的深层内涵；解决问题倾向固定方法。",
      "对新事物有一定好奇，也重视传统；能欣赏艺术但不深入；解决问题会兼顾固定方法与新角度。",
      "对新事物、新观点充满好奇，愿意尝试不同生活方式；喜欢艺术/文学，能感知深层内涵；解决问题擅长多角度思考。"
    ],
    "宜人性": [
      "更坚持自身观点，不轻易妥协；不太主动关注他人感受，优先考虑自身需求；避免不必要的人际帮助。",
      "能理解他人感受，但也会坚持合理观点；重视人际和谐，也会拒绝过度请求；平衡自身与他人需求。",
      "善于共情，主动帮助他人；优先维护人际和谐，避免冲突；愿意妥协，很少拒绝他人合理请求。"
    ],
    "尽责性": [
      "做事随性，很少制定计划；时间管理较松散，易出现拖延；对待任务可能不够细致，偶有粗心。",
      "会制定基础计划，偶尔调整；时间管理适中，多数时候能按时完成任务；对待任务认真，但允许少量灵活空间。",
      "习惯提前制定详细计划并严格执行；时间管理高效，几乎不拖延；对待任务严谨负责，注重细节、避免失误。"
    ]
  };

  @State currentQuestionIndex: number = 0;
  @State userScores: number[] = new Array(20).fill(0);
  @State showResult: boolean = false;
  @State bigFiveResults: BigFiveResult[] = [];

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userScores = new Array(20).fill(0);
    this.showResult = false;
    this.bigFiveResults = [];
  }

  // 选择分数 - 修复参数类型
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

  // 计算大五人格结果 - 修复any类型
  private calculateResult() {
    const dimensionScores: Record<string, number> = {
      "神经质": 0,
      "外向性": 0,
      "开放性": 0,
      "宜人性": 0,
      "尽责性": 0
    };

    const reverseScoringIndices: number[] = [3, 6, 10, 13, 17];

    this.questions.forEach((question: QuestionItem, index: number) => {
      let score = this.userScores[index];

      if (reverseScoringIndices.includes(index)) {
        score = 6 - score;
      }

      dimensionScores[question.dimension] += score;
    });

    this.bigFiveResults = Object.keys(dimensionScores).map((dimension: string) => {
      const score = dimensionScores[dimension];
      let level = "";
      let description = "";

      if (score <= 8) {
        level = "低";
        description = this.resultDescriptions[dimension][0];
      } else if (score <= 13) {
        level = "中";
        description = this.resultDescriptions[dimension][1];
      } else {
        level = "高";
        description = this.resultDescriptions[dimension][2];
      }

      return {
        dimension,
        score,
        level,
        description
      } as BigFiveResult;
    });

    this.showResult = true;

    promptAction.showToast({
      message: "测试完成！您的大五人格结果已生成",
      duration: 3000,
      bottom: 200
    });
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 构建进度指示器 - 修复UI组件语法
  @Builder
  private buildProgressIndicator() {
    Row() {
      Text(`进度：${this.currentQuestionIndex + 1}/${this.questions.length}`)
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.progress_background'))
        .color($r('app.color.progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.progress_container_bg'))
  }

  // 构建问题显示区域 - 修复UI组件语法
  @Builder
  private buildQuestionArea() {
    if (this.showResult) {
      this.buildResultArea();
    } else {
      this.buildTestArea();
    }
  }

  // 构建测试区域 - 修复UI组件语法
  @Builder
  private buildTestArea() {
    // 移除变量声明，直接在组件中使用
    Column() {
      Text(this.questions[this.currentQuestionIndex].dimension)
        .fontSize(18)
        .fontColor($r('app.color.test_dimension_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      Text(this.dimensionDescriptions[this.questions[this.currentQuestionIndex].dimension].description)
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 20 })
        .textAlign(TextAlign.Center)

      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.text_primary'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.test_question_bg'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.test_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      Text("评分标准：1 = 非常不符合，2 = 比较不符合，3 = 不确定，4 = 比较符合，5 = 非常符合")
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      Row() {
        ForEach([1, 2, 3, 4, 5], (score: number) => {
          Button(score.toString())
            .width(60)
            .height(60)
            .backgroundColor(this.userScores[this.currentQuestionIndex] === score ? $r('app.color.test_score_selected') : $r('app.color.test_score_unselected'))
            .fontColor(this.userScores[this.currentQuestionIndex] === score ? $r('app.color.test_score_selected_text') : $r('app.color.test_score_unselected_text'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .borderRadius(30)
            .border({ width: 2, color: $r('app.color.test_score_border') })
            .onClick(() => this.selectScore(score))
            .margin({ right: 10 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      Row() {
        Text("非常不符合")
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ right: 45 })

        Text("非常符合")
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ left: 45 })
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

  // 构建结果区域 - 修复UI组件语法
  @Builder
  private buildResultArea() {
    Column() {
      Text("大五人格测试结果")
        .fontSize(24)
        .fontColor($r('app.color.test_result_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text("注意：此为精简版测试，结果仅供参考。人格会随生活经历、环境变化而动态调整。")
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
        .textAlign(TextAlign.Center)
        .lineHeight(20)
        .margin({ bottom: 20 })
        .padding(10)

      List({ space: 15 }) {
        ForEach(this.bigFiveResults, (result: BigFiveResult) => {
          ListItem() {
            Column() {
              Row() {
                Text(result.dimension)
                  .fontSize(18)
                  .fontColor($r('app.color.test_dimension_text'))
                  .fontWeight(FontWeight.Bold)

                Blank()

                Text(`得分: ${result.score} (${result.level})`)
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ bottom: 10 })

              Text(result.description)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(24)
                .padding(15)
                .backgroundColor($r('app.color.test_result_item_bg'))
                .borderRadius(10)
                .border({ width: 1, color: $r('app.color.test_result_item_border') })
            }
            .width('100%')
            .padding(10)
          }
        })
      }
      .width('100%')
      .height('70%')
      .divider({ strokeWidth: 1, color: $r('app.color.border_color') })
    }
    .width('100%')
    .height('70%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
  }

  // 构建控制面板 - 修复UI组件语法
  @Builder
  private buildControlPanel() {
    Column() {
      if (!this.showResult) {
        Row() {
          Button('上一题')
            .width(120)
            .height(45)
            .backgroundColor(this.currentQuestionIndex > 0 ? $r('app.color.test_button_previous') : $r('app.color.button_disabled'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.test_button_skip'))
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
            .backgroundColor($r('app.color.test_button_retest'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.test_button_finish'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.backToAdjustPage())
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .margin({ left: 15 })
            .onClick(() => this.backToAdjustPage())

          Text('大五人格测试')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.test_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.test_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.test_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        this.buildProgressIndicator()

        this.buildQuestionArea()

        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.test_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function BigFivePageBuilder(param:object) { // 修复any类型
  BigFivePage()
}