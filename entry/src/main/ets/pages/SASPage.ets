import { promptAction } from "@kit.ArkUI";

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  category: string;
  reverseScoring: boolean;
}

// 定义结果描述
interface SASResult {
  score: number;
  level: string;
  description: string;
  recommendation: string;
}

@Component
export struct SASPage {
  pageStack: NavPathStack = new NavPathStack();

  // SAS测试问题
  @State questions: QuestionItem[] = [
  // 心理焦虑（6题）
    { id: 1, text: "我感到比平时更容易紧张或着急。", category: "心理焦虑", reverseScoring: false },
    { id: 2, text: "我无缘无故感到害怕。", category: "心理焦虑", reverseScoring: false },
    { id: 3, text: "我容易心里烦乱或觉得惊恐。", category: "心理焦虑", reverseScoring: false },
    { id: 4, text: "我对未来有过多的担忧（比如担心工作、健康或家人）。", category: "心理焦虑", reverseScoring: false },
    { id: 5, text: "我很难让自己放松下来。", category: "心理焦虑", reverseScoring: false },
    { id: 6, text: "我容易因为小事变得烦躁或易怒。", category: "心理焦虑", reverseScoring: false },

    // 生理反应（8题）
    { id: 7, text: "我感到心跳得很快。", category: "生理反应", reverseScoring: false },
    { id: 8, text: "我因为一阵阵头晕而苦恼。", category: "生理反应", reverseScoring: false },
    { id: 9, text: "我有晕倒或觉得要晕倒的感觉。", category: "生理反应", reverseScoring: false },
    { id: 10, text: "我觉得一阵阵发冷或发热。", category: "生理反应", reverseScoring: false },
    { id: 11, text: "我感到呼吸变得急促（比如胸闷、气短）。", category: "生理反应", reverseScoring: false },
    { id: 12, text: "我觉得肌肉紧绷（比如脖子、肩膀酸痛）。", category: "生理反应", reverseScoring: false },
    { id: 13, text: "我经常感到口干。", category: "生理反应", reverseScoring: false },
    { id: 14, text: "我会出现胃部不适（比如恶心、腹胀）。", category: "生理反应", reverseScoring: false },

    // 认知与行为（6题）
    { id: 15, text: "我因为睡眠有困难（如入睡难、早醒、多梦）而苦恼。", category: "认知与行为", reverseScoring: false },
    { id: 16, text: "我觉得自己能应付日常生活的各种压力。", category: "认知与行为", reverseScoring: true },
    { id: 17, text: "我很难集中注意力做一件事（比如看书、工作）。", category: "认知与行为", reverseScoring: false },
    { id: 18, text: "我觉得自己能控制住自己的想法和情绪。", category: "认知与行为", reverseScoring: true },
    { id: 19, text: "我容易受到突然的声音或动静惊吓。", category: "认知与行为", reverseScoring: false },
    { id: 20, text: "我对日常喜欢的事（如追剧、运动）仍有兴趣。", category: "认知与行为", reverseScoring: true }
  ] as QuestionItem[];

  @State currentQuestionIndex: number = 0;
  @State userScores: number[] = new Array(20).fill(0);
  @State showResult: boolean = false;
  @State sasResult: SASResult = { score: 0, level: "", description: "", recommendation: "" };

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userScores = new Array(20).fill(0);
    this.showResult = false;
    this.sasResult = { score: 0, level: "", description: "", recommendation: "" };
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

  // 计算SAS结果
  private calculateResult() {
    let totalScore = 0;

    // 反向计分题索引（16、18、20题）
    const reverseScoringIndices: number[] = [15, 17, 19]; // 数组索引从0开始

    this.questions.forEach((question: QuestionItem, index: number) => {
      let score = this.userScores[index];

      // 如果是反向计分题，转换分数
      if (reverseScoringIndices.includes(index)) {
        score = 5 - score; // 1→4，2→3，3→2，4→1
      }

      totalScore += score;
    });

    // 确定焦虑级别
    let level = "";
    let description = "";
    let recommendation = "";

    if (totalScore <= 35) {
      level = "轻微焦虑";
      description = "焦虑症状轻微，处于正常范围，多为短期压力或情绪波动导致";
      recommendation = "通过休息、散步等方式可自行缓解";
    } else if (totalScore <= 50) {
      level = "轻度焦虑";
      description = "症状偶尔影响状态（如偶尔失眠、注意力分散）";
      recommendation = "尝试深呼吸、冥想等自我调节，或向家人朋友倾诉";
    } else if (totalScore <= 65) {
      level = "中度焦虑";
      description = "症状频繁出现（如持续紧张、躯体不适），已干扰工作、社交或睡眠";
      recommendation = "建议寻求专业心理疏导（如心理咨询师）";
    } else {
      level = "重度焦虑";
      description = "症状持续且严重（如无法正常作息、难以应对日常事务）";
      recommendation = "需及时联系心理医生或精神科医生，进行进一步评估与干预";
    }

    this.sasResult = {
      score: totalScore,
      level,
      description,
      recommendation
    };

    this.showResult = true;

    promptAction.showToast({
      message: `测试完成！您的SAS总分为：${totalScore}`,
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
        .fontColor($r('app.color.sas_progress_text'))

      Blank()

      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.sas_progress_background'))
        .color($r('app.color.sas_progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.sas_progress_container'))
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
      // 类别标题
      Text(this.questions[this.currentQuestionIndex].category)
        .fontSize(18)
        .fontColor($r('app.color.sas_category_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      // 问题卡片
      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.sas_question_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.sas_question_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.sas_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      // 评分说明
      Text("评分标准：")
        .fontSize(16)
        .fontColor($r('app.color.sas_instruction_title'))
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      Text("1 = 无或很少时间（＜1天），2 = 少部分时间（1-2天）")
        .fontSize(14)
        .fontColor($r('app.color.sas_instruction_text'))
        .margin({ bottom: 2 })
        .textAlign(TextAlign.Center)

      Text("3 = 相当多时间（3-4天），4 = 绝大部分或全部时间（5-7天）")
        .fontSize(14)
        .fontColor($r('app.color.sas_instruction_text'))
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      // 评分区域
      Row() {
        ForEach([1, 2, 3, 4], (score: number) => {
          Button(score.toString())
            .width(70)
            .height(70)
            .backgroundColor(this.userScores[this.currentQuestionIndex] === score ?
            $r('app.color.sas_score_selected') : $r('app.color.sas_score_unselected'))
            .fontColor(this.userScores[this.currentQuestionIndex] === score ?
            $r('app.color.sas_score_selected_text') : $r('app.color.sas_score_unselected_text'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .borderRadius(35)
            .border({ width: 2, color: $r('app.color.sas_score_border') })
            .onClick(() => this.selectScore(score))
            .margin({ right: 10 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 评分标签
      Row() {
        Text("无或很少时间")
          .fontSize(14)
          .fontColor($r('app.color.sas_score_label'))
          .margin({ right: 30 })

        Text("绝大部分时间")
          .fontSize(14)
          .fontColor($r('app.color.sas_score_label'))
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
    Scroll(){
      Column() {
        Text("焦虑自评量表（SAS）结果")
          .fontSize(24)
          .fontColor($r('app.color.sas_result_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })

        // 总分显示
        Text(`总分：${this.sasResult.score}`)
          .fontSize(32)
          .fontColor($r('app.color.sas_result_score'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        // 焦虑级别
        Text(`焦虑级别：${this.sasResult.level}`)
          .fontSize(20)
          .fontColor($r('app.color.sas_result_level'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 5 })

        // 描述
        Text(this.sasResult.description)
          .fontSize(18)
          .fontColor($r('app.color.sas_result_description'))
          .textAlign(TextAlign.Center)
          .lineHeight(28)
          .margin({ bottom: 20 })
          .padding(15)
          .backgroundColor($r('app.color.sas_result_desc_background'))
          .borderRadius(15)
          .border({ width: 1, color: $r('app.color.sas_result_desc_border') })

        // 建议
        Text("建议：")
          .fontSize(18)
          .fontColor($r('app.color.sas_result_suggestion_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 5 })

        Text(this.sasResult.recommendation)
          .fontSize(18)
          .fontColor($r('app.color.sas_result_suggestion_text'))
          .textAlign(TextAlign.Center)
          .lineHeight(28)
          .padding(15)
          .backgroundColor($r('app.color.sas_result_suggestion_background'))
          .borderRadius(15)
          .border({ width: 1, color: $r('app.color.sas_result_suggestion_border') })

        // 免责声明
        Text("重要注意事项：")
          .fontSize(16)
          .fontColor($r('app.color.sas_disclaimer_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 5 })

        Text("• 该量表仅为自我评估工具，不能作为焦虑症、惊恐障碍等疾病的诊断依据")
          .fontSize(14)
          .fontColor($r('app.color.sas_disclaimer_text'))
          .margin({ bottom: 3 })
          .textAlign(TextAlign.Start)

        Text("• 评分受近期睡眠、压力事件、环境变化等因素影响，具有时效性")
          .fontSize(14)
          .fontColor($r('app.color.sas_disclaimer_text'))
          .margin({ bottom: 3 })
          .textAlign(TextAlign.Start)

        Text("• 偶尔的焦虑情绪是正常的，无需过度恐慌；关键是区分'短期情绪'和'持续症状'")
          .fontSize(14)
          .fontColor($r('app.color.sas_disclaimer_text'))
          .margin({ bottom: 3 })
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .height('70%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding(20)
    }.scrollable(ScrollDirection.Vertical)
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
            .backgroundColor(this.currentQuestionIndex > 0 ?
            $r('app.color.sas_button_previous') : $r('app.color.sas_button_disabled'))
            .fontColor($r('app.color.sas_button_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.sas_button_skip'))
            .fontColor($r('app.color.sas_button_text'))
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
            .backgroundColor($r('app.color.sas_button_retest'))
            .fontColor($r('app.color.sas_button_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.sas_button_finish'))
            .fontColor($r('app.color.sas_button_text'))
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
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .margin({ left: 15 })
            .onClick(() => this.backToAdjustPage())

          Text('焦虑自评量表（SAS）')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.sas_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.sas_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.sas_nav_border') })
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
      .backgroundColor($r('app.color.sas_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function SASPageBuilder(param: object) {
  SASPage()
}