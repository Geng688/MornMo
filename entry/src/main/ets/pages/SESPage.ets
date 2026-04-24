import { promptAction } from "@kit.ArkUI";

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  category: string;
  reverseScoring: boolean;
}

// 定义结果描述
interface SESResult {
  score: number;
  level: string;
  description: string;
  recommendation: string;
}

@Component
export struct SESPage {
  pageStack: NavPathStack = new NavPathStack();

  // SES测试问题
  @State questions: QuestionItem[] = [
  // 自我价值与接纳（5题）
    { id: 1, text: "我认为自己存在独特的价值，不是可有可无的。", category: "自我价值与接纳", reverseScoring: false },
    { id: 2, text: "即使知道自己有缺点，我也能接纳这样的自己。", category: "自我价值与接纳", reverseScoring: false },
    { id: 3, text: "我常常觉得自己配不上好的机会或赞美。", category: "自我价值与接纳", reverseScoring: true },
    { id: 4, text: "我对自己的性格、外貌等外在与内在特质基本满意。", category: "自我价值与接纳", reverseScoring: false },
    { id: 5, text: "我觉得自己值得被他人尊重和关心。", category: "自我价值与接纳", reverseScoring: false },

    // 能力认同与挫折应对（5题）
    { id: 6, text: "面对不熟悉的任务，我相信自己能通过学习做好。", category: "能力认同与挫折应对", reverseScoring: false },
    { id: 7, text: "就算在某件事上失败了，我也不会否定自己的整体能力。", category: "能力认同与挫折应对", reverseScoring: false },
    { id: 8, text: "我总觉得自己做不好需要承担责任的事。", category: "能力认同与挫折应对", reverseScoring: true },
    { id: 9, text: "遇到困难时，我会先想 '我能试试'，而不是 '我肯定不行'。", category: "能力认同与挫折应对", reverseScoring: false },
    { id: 10, text: "别人指出我的不足时，我会觉得自己很没用。", category: "能力认同与挫折应对", reverseScoring: true },

    // 社交自信与表达（5题）
    { id: 11, text: "在社交场合中，我能自然表达自己的想法，不怕被否定。", category: "社交自信与表达", reverseScoring: false },
    { id: 12, text: "我觉得自己和他人相处时，能给对方带来积极的感受。", category: "社交自信与表达", reverseScoring: false },
    { id: 13, text: "和优秀的人在一起时，我会忍不住觉得自己不如他们。", category: "社交自信与表达", reverseScoring: true },
    { id: 14, text: "面对他人的误解，我会主动解释，而不是默默自我怀疑。", category: "社交自信与表达", reverseScoring: false },
    { id: 15, text: "我敢在需要的时候拒绝别人，不会因为怕得罪人而勉强自己。", category: "社交自信与表达", reverseScoring: false },

    // 目标与自我成长（5题）
    { id: 16, text: "我会为自己设定小目标，完成后会肯定自己的努力。", category: "目标与自我成长", reverseScoring: false },
    { id: 17, text: "我觉得自己有能力不断进步，成为更想成为的人。", category: "目标与自我成长", reverseScoring: false },
    { id: 18, text: "我总担心自己无法实现想要的目标，所以很少尝试。", category: "目标与自我成长", reverseScoring: true },
    { id: 19, text: "即使别人不认可我的选择，我也会坚持自己认为对的事。", category: "目标与自我成长", reverseScoring: false },
    { id: 20, text: "回顾过去的经历，我能看到自己的成长，而不是只关注遗憾。", category: "目标与自我成长", reverseScoring: false }
  ] as QuestionItem[];

  @State currentQuestionIndex: number = 0;
  @State userScores: number[] = new Array(20).fill(0);
  @State showResult: boolean = false;
  @State sesResult: SESResult = { score: 0, level: "", description: "", recommendation: "" };

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userScores = new Array(20).fill(0);
    this.showResult = false;
    this.sesResult = { score: 0, level: "", description: "", recommendation: "" };
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

  // 计算SES结果
  private calculateResult() {
    let totalScore = 0;

    // 反向计分题索引（3,8,10,13,18题）
    const reverseScoringIndices: number[] = [2, 7, 9, 12, 17]; // 数组索引从0开始

    this.questions.forEach((question: QuestionItem, index: number) => {
      let score = this.userScores[index];

      // 如果是反向计分题，转换分数
      if (reverseScoringIndices.includes(index)) {
        score = 5 - score; // 1→4，2→3，3→2，4→1
      }

      totalScore += score;
    });

    // 确定自尊级别
    let level = "";
    let description = "";
    let recommendation = "";

    if (totalScore <= 38) {
      level = "低自尊水平";
      description = "自尊水平较低。容易自我否定、怀疑自身价值，面对挫折或他人评价时易动摇，可能回避挑战或过度在意他人看法。";
      recommendation = "可从'记录每日小成就'（如完成工作任务、帮助他人）开始，逐步积累自我认可。";
    } else if (totalScore <= 60) {
      level = "中等自尊水平";
      description = "自尊水平中等。对自己有基本认可，但在压力大、失败或面对强势评价时，可能出现短暂的自我怀疑。";
      recommendation = "可通过'强化优势认知'（列出3个自身优点并举例）巩固自我价值感，减少过度比较。";
    } else {
      level = "高自尊水平";
      description = "自尊水平较高。能清晰认识自身价值、接纳不完美，面对困难时更有信心，敢于表达和坚持自我。";
      recommendation = "建议保持'客观反思'的态度，既肯定自己，也理性看待不足，避免过度自我中心。";
    }

    this.sesResult = {
      score: totalScore,
      level,
      description,
      recommendation
    };

    this.showResult = true;

    promptAction.showToast({
      message: `测试完成！您的SES总分为：${totalScore}`,
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
        .fontColor($r('app.color.ses_progress_text'))

      Blank()

      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.ses_progress_background'))
        .color($r('app.color.ses_progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.ses_progress_container'))
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
        .fontColor($r('app.color.ses_category_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      // 问题卡片
      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.ses_question_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.ses_question_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.ses_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      // 评分说明
      Text("评分标准：1 = 完全不符合，2 = 不太符合，3 = 比较符合，4 = 完全符合")
        .fontSize(14)
        .fontColor($r('app.color.ses_instruction_text'))
        .margin({ bottom: 15 })
        .textAlign(TextAlign.Center)

      // 评分区域
      Row() {
        ForEach([1, 2, 3, 4], (score: number) => {
          Button(score.toString())
            .width(70)
            .height(70)
            .backgroundColor(this.userScores[this.currentQuestionIndex] === score ?
            $r('app.color.ses_score_selected') : $r('app.color.ses_score_unselected'))
            .fontColor(this.userScores[this.currentQuestionIndex] === score ?
            $r('app.color.ses_score_selected_text') : $r('app.color.ses_score_unselected_text'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .borderRadius(35)
            .border({ width: 2, color: $r('app.color.ses_score_border') })
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
          .fontColor($r('app.color.ses_score_label'))
          .margin({ right: 45 })

        Text("完全符合")
          .fontSize(14)
          .fontColor($r('app.color.ses_score_label'))
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

  // 构建结果区域
  @Builder
  private buildResultArea() {
    Column() {
      Scroll() {
        Column() {
          // 结果标题
          Text("自尊量表（SES）结果")
            .fontSize(24)
            .fontColor($r('app.color.ses_result_title'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })

          // 总分显示
          Text(`总分：${this.sesResult.score}`)
            .fontSize(32)
            .fontColor($r('app.color.ses_result_score'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

          // 自尊级别
          Text(`自尊级别：${this.sesResult.level}`)
            .fontSize(20)
            .fontColor($r('app.color.ses_result_level'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 5 })

          // 描述
          Text(this.sesResult.description)
            .fontSize(18)
            .fontColor($r('app.color.ses_result_description'))
            .textAlign(TextAlign.Center)
            .lineHeight(28)
            .margin({ bottom: 20 })
            .padding(15)
            .backgroundColor($r('app.color.ses_result_desc_background'))
            .borderRadius(15)
            .border({ width: 1, color: $r('app.color.ses_result_desc_border') })

          // 建议
          Text("建议：")
            .fontSize(18)
            .fontColor($r('app.color.ses_result_suggestion_title'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 5 })

          Text(this.sesResult.recommendation)
            .fontSize(18)
            .fontColor($r('app.color.ses_result_suggestion_text'))
            .textAlign(TextAlign.Center)
            .lineHeight(28)
            .padding(15)
            .backgroundColor($r('app.color.ses_result_suggestion_background'))
            .borderRadius(15)
            .border({ width: 1, color: $r('app.color.ses_result_suggestion_border') })

          // 分级提升方案
          Text("分级提升方案")
            .fontSize(20)
            .fontColor($r('app.color.ses_result_title'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 10 })

          if (this.sesResult.score <= 38) {
            // 低自尊水平提升方案
            Column() {
              Text("低自尊水平（20-38分）：从'微小认可'建立基础自信")
                .fontSize(18)
                .fontColor($r('app.color.ses_result_title'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })

              Text("核心目标：打破'自我否定循环'，通过高频、易达成的行动，积累对自身的正向认知。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 10 })

              Text("• 每日成就记录法：准备一个小本子，每天睡前记录1-2件'自己做到的小事'，并在每件事后面加一句肯定。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• 负面想法反驳术：当出现'我肯定做不好'等想法时，立刻问自己：'有证据支持这个想法吗？有没有相反的例子？'")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• 低压力社交练习：从'低难度互动'开始建立社交自信，比如每天和便利店店员说一句'谢谢'。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })
            }
            .width('100%')
            .padding(15)
            .backgroundColor($r('app.color.ses_result_desc_background'))
            .borderRadius(15)
            .border({ width: 1, color: $r('app.color.ses_result_desc_border') })
          } else if (this.sesResult.score <= 60) {
            // 中等自尊水平提升方案
            Column() {
              Text("中等自尊水平（39-60分）：巩固'自我认可'，减少波动")
                .fontSize(18)
                .fontColor($r('app.color.ses_result_title'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })

              Text("核心目标：应对'压力下的自我怀疑'，让自尊感从'依赖外部评价'转向'内在稳定认可'。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 10 })

              Text("• 优势具象化练习：列出3个自己的核心优势，每个优势配1个具体例子，每周翻看1次。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• 可控目标设定法：避免因'目标太大没实现'动摇自信，每次只设定'踮脚能完成'的小目标。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• '合理比较'提醒：当忍不住和他人比较时，告诉自己：'我有我的节奏，比如我擅长XX，这也是别人没有的'。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })
            }
            .width('100%')
            .padding(15)
            .backgroundColor($r('app.color.ses_result_desc_background'))
            .borderRadius(15)
            .border({ width: 1, color: $r('app.color.ses_result_desc_border') })
          } else {
            // 高自尊水平提升方案
            Column() {
              Text("高自尊水平（61-80分）：保持'平衡自信'，避免盲目")
                .fontSize(18)
                .fontColor($r('app.color.ses_result_title'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })

              Text("核心目标：在肯定自我的同时，保持客观反思，让自尊感更成熟、可持续。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 10 })

              Text("• '成长型'不足看待：面对自己的不足时，用'我现在还没做好，通过练习可以提升'的成长思维。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• 共情式自我关怀：当犯错或失败时，像安慰朋友一样安慰自己。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })

              Text("• 适度'求助'练习：尝试主动向他人请教小事，让自尊感更灵活。")
                .fontSize(16)
                .fontColor($r('app.color.ses_result_description'))
                .margin({ bottom: 5 })
            }
            .width('100%')
            .padding(15)
            .backgroundColor($r('app.color.ses_result_desc_background'))
            .borderRadius(15)
            .border({ width: 1, color: $r('app.color.ses_result_desc_border') })
          }

          // 免责声明
          Text("重要注意事项")
            .fontSize(18)
            .fontColor($r('app.color.ses_disclaimer_title'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 10 })

          Text("• 该量表仅为自我评估工具，结果反映的是当前阶段的自我态度，而非固定标签。")
            .fontSize(14)
            .fontColor($r('app.color.ses_disclaimer_text'))
            .margin({ bottom: 3 })
            .textAlign(TextAlign.Start)

          Text("• 偶尔的自我怀疑是正常的，关键在于'是否能快速调整'。")
            .fontSize(14)
            .fontColor($r('app.color.ses_disclaimer_text'))
            .margin({ bottom: 3 })
            .textAlign(TextAlign.Start)

          Text("• 避免用'非黑即白'思维解读结果，中等自尊水平是多数人的常态。")
            .fontSize(14)
            .fontColor($r('app.color.ses_disclaimer_text'))
            .margin({ bottom: 3 })
            .textAlign(TextAlign.Start)
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .width('100%')
      .height('70%')
    }
    .width('100%')
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
            $r('app.color.ses_button_previous') : $r('app.color.ses_button_disabled'))
            .fontColor($r('app.color.ses_button_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.ses_button_skip'))
            .fontColor($r('app.color.ses_button_text'))
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
            .backgroundColor($r('app.color.ses_button_retest'))
            .fontColor($r('app.color.ses_button_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.ses_button_finish'))
            .fontColor($r('app.color.ses_button_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.backToAdjustPage())
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({top:15})
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

          Text('自尊量表（SES）')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ses_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.ses_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.ses_nav_border') })
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
      .backgroundColor($r('app.color.ses_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function SESPageBuilder(param: object) {
  SESPage()
}