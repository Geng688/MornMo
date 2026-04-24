import { promptAction } from "@kit.ArkUI";

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  part: string;
  optionA: string;
  optionB: string;
  dimension: string;
}

// 定义MBTI描述项的接口
interface MBTIDescription {
  title: string;
  description: string;
}

@Component
export struct MBTIPage {
  pageStack: NavPathStack = new NavPathStack();

  // MBTI 测试问题
  @State questions: QuestionItem[]
    = [
    {
      id: 1,
      text: "周末休息时，你更喜欢：",
      part: "第一部分：精力来源（E - 外向 / I - 内向）",
      optionA: "参加聚会、社交活动或与朋友见面",
      optionB: "在家看书、独处或做自己喜欢的事",
      dimension: "EI"
    },
    {
      id: 2,
      text: "当你有了一个新想法，你会：",
      part: "第一部分：精力来源（E - 外向 / I - 内向）",
      optionA: "立即与他人分享并讨论",
      optionB: "先在脑海中反复思考，再选择性分享",
      dimension: "EI"
    },
    {
      id: 3,
      text: "在社交场合中，你通常：",
      part: "第一部分：精力来源（E - 外向 / I - 内向）",
      optionA: "主动发起话题，成为焦点",
      optionB: "倾听他人，等待合适的时机发言",
      dimension: "EI"
    },
    {
      id: 4,
      text: "你更倾向于通过哪种方式放松：",
      part: "第一部分：精力来源（E - 外向 / I - 内向）",
      optionA: "和朋友聊天、参加集体活动",
      optionB: "独自散步、冥想或从事个人爱好",
      dimension: "EI"
    },
    {
      id: 5,
      text: "面对新环境，你会：",
      part: "第一部分：精力来源（E - 外向 / I - 内向）",
      optionA: "迅速适应并探索",
      optionB: "需要时间观察和熟悉",
      dimension: "EI"
    },
    {
      id: 6,
      text: "当你阅读一本小说时，你更关注：",
      part: "第二部分：信息获取（S - 实感 / N - 直觉）",
      optionA: "故事的具体情节、细节和人物对话",
      optionB: "故事背后的隐喻、主题或未来发展的可能性",
      dimension: "SN"
    },
    {
      id: 7,
      text: "解决问题时，你：",
      part: "第二部分：信息获取（S - 实感 / N - 直觉）",
      optionA: "遵循已有经验或方法",
      optionB: "尝试创新思路或寻找潜在规律",
      dimension: "SN"
    },
    {
      id: 8,
      text: "你在回忆一件事情时，脑海中首先浮现的是：",
      part: "第二部分：信息获取（S - 实感 / N - 直觉）",
      optionA: "具体的场景、画面或声音",
      optionB: "抽象的感受、印象或概念",
      dimension: "SN"
    },
    {
      id: 9,
      text: "对于未来，你：",
      part: "第二部分：信息获取（S - 实感 / N - 直觉）",
      optionA: "更关注现实的目标和规划",
      optionB: "更期待未知的可能性和变化",
      dimension: "SN"
    },
    {
      id: 10,
      text: "当你学习新知识时，你更喜欢：",
      part: "第二部分：信息获取（S - 实感 / N - 直觉）",
      optionA: "通过实际案例、步骤或操作学习",
      optionB: "先理解整体框架和原理，再深入细节",
      dimension: "SN"
    },
    {
      id: 11,
      text: "做决定时，你更看重：",
      part: "第三部分：决策方式（T - 思考 / F - 情感）",
      optionA: "逻辑、事实和客观分析",
      optionB: "他人的感受、价值观和和谐氛围",
      dimension: "TF"
    },
    {
      id: 12,
      text: "评价一件事时，你通常：",
      part: "第三部分：决策方式（T - 思考 / F - 情感）",
      optionA: "基于理性判断，指出优点和不足",
      optionB: "考虑情感因素，避免伤害他人",
      dimension: "TF"
    },
    {
      id: 13,
      text: "当朋友遇到困难，你更可能：",
      part: "第三部分：决策方式（T - 思考 / F - 情感）",
      optionA: "给出具体的解决建议",
      optionB: "先倾听和安慰，再提供支持",
      dimension: "TF"
    },
    {
      id: 14,
      text: "面对冲突，你倾向于：",
      part: "第三部分：决策方式（T - 思考 / F - 情感）",
      optionA: "直接指出问题所在，寻求解决方案",
      optionB: "妥协或回避，以维护关系",
      dimension: "TF"
    },
    {
      id: 15,
      text: "你认为自己更理性还是更感性：",
      part: "第三部分：决策方式（T - 思考 / F - 情感）",
      optionA: "理性，注重逻辑",
      optionB: "感性，注重情感",
      dimension: "TF"
    },
    {
      id: 16,
      text: "你更喜欢的生活状态是：",
      part: "第四部分：生活态度（J - 判断 / P - 感知）",
      optionA: "有计划、有条理，提前安排好日程",
      optionB: "灵活、随性，适应变化",
      dimension: "JP"
    },
    {
      id: 17,
      text: "完成任务时，你通常：",
      part: "第四部分：生活态度（J - 判断 / P - 感知）",
      optionA: "尽早开始，严格按计划执行",
      optionB: "临近截止日期时效率更高，喜欢灵活调整",
      dimension: "JP"
    },
    {
      id: 18,
      text: "对于约会，你更倾向于：",
      part: "第四部分：生活态度（J - 判断 / P - 感知）",
      optionA: "提前确定时间、地点和活动内容",
      optionB: "当天决定或根据心情调整",
      dimension: "JP"
    },
    {
      id: 19,
      text: "你认为自己更擅长：",
      part: "第四部分：生活态度（J - 判断 / P - 感知）",
      optionA: "组织和管理事务",
      optionB: "适应突发情况和灵活应对",
      dimension: "JP"
    },
    {
      id: 20,
      text: "周末计划，你通常：",
      part: "第四部分：生活态度（J - 判断 / P - 感知）",
      optionA: "提前制定详细安排",
      optionB: "顺其自然，随机选择活动",
      dimension: "JP"
    }
  ];

  // MBTI 类型描述
  @State mbtiDescriptions: Record<string, MBTIDescription> = {
    "ISTJ": { title: "物流师型人格", description: "务实、有条理、注重细节，可靠且负责任。" },
    "ISFJ": { title: "守护者型人格", description: "体贴、有责任心、注重和谐，善于照顾他人。" },
    "INFJ": { title: "提倡者型人格", description: "富有想象力、有原则、有激情，追求深层次意义。" },
    "INTJ": { title: "建筑师型人格", description: "战略思维、独立、有远见，善于制定长远计划。" },
    "ISTP": { title: "鉴赏家型人格", description: "灵活、务实、善于分析，喜欢动手解决问题。" },
    "ISFP": { title: "探险家型人格", description: "温和、敏感、有艺术气质，享受当下时刻。" },
    "INFP": { title: "调停者型人格", description: "理想主义、有同情心、好奇心强，重视个人价值观。" },
    "INTP": { title: "逻辑学家型人格", description: "创新、逻辑性强、好奇心重，喜欢理论思考。" },
    "ESTP": { title: "企业家型人格", description: "精力充沛、务实、适应力强，喜欢即时行动。" },
    "ESFP": { title: "表演者型人格", description: "热情、社交能力强、活泼，享受与人互动。" },
    "ENFP": { title: "竞选者型人格", description: "热情、有创造力、社交能力强，充满可能性。" },
    "ENTP": { title: "辩论家型人格", description: "聪明、好奇、思维敏捷，喜欢智力挑战。" },
    "ESTJ": { title: "总经理型人格", description: "高效、务实、有组织能力，注重效率和秩序。" },
    "ESFJ": { title: "执政官型人格", description: "关心他人、社交活跃、尽责，重视和谐关系。" },
    "ENFJ": { title: "主人公型人格", description: "有魅力、有同情心、有领导力，善于激励他人。" },
    "ENTJ": { title: "指挥官型人格", description: "果断、战略思维、有领导力，善于组织和管理。" }
  };

  @State currentQuestionIndex: number = 0;
  @State userAnswers: string[] = new Array(20).fill('');
  @State showResult: boolean = false;
  @State mbtiResult: string = '';
  @State resultDescription: string = '';

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userAnswers = new Array(20).fill('');
    this.showResult = false;
    this.mbtiResult = '';
    this.resultDescription = '';
  }

  // 选择答案
  private selectAnswer(answer: string) {
    this.userAnswers[this.currentQuestionIndex] = answer;

    // 自动进入下一题或显示结果
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

  // 计算MBTI结果
  private calculateResult() {
    let eCount = 0, iCount = 0;
    let sCount = 0, nCount = 0;
    let tCount = 0, fCount = 0;
    let jCount = 0, pCount = 0;

    this.questions.forEach((question, index) => {
      const answer = this.userAnswers[index];
      if (answer === 'A') {
        switch(question.dimension) {
          case 'EI': eCount++; break;
          case 'SN': sCount++; break;
          case 'TF': tCount++; break;
          case 'JP': jCount++; break;
        }
      } else if (answer === 'B') {
        switch(question.dimension) {
          case 'EI': iCount++; break;
          case 'SN': nCount++; break;
          case 'TF': fCount++; break;
          case 'JP': pCount++; break;
        }
      }
    });

    const ei = eCount > iCount ? 'E' : 'I';
    const sn = sCount > nCount ? 'S' : 'N';
    const tf = tCount > fCount ? 'T' : 'F';
    const jp = jCount > pCount ? 'J' : 'P';

    this.mbtiResult = ei + sn + tf + jp;
    const description = this.mbtiDescriptions[this.mbtiResult];

    if (description) {
      this.resultDescription = `${description.title}\n\n${description.description}`;
    } else {
      this.resultDescription = "无法确定具体的性格类型，请重新测试。";
    }

    this.showResult = true;

    // 显示结果提示
    promptAction.showToast({
      message: `测试完成！您的MBTI类型是：${this.mbtiResult}`,
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
        .fontColor($r('app.color.mbti_progress_text'))

      Blank()

      // 使用 Progress 组件实现从左向右的进度条
      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.mbti_progress_background'))
        .color($r('app.color.mbti_progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.mbti_progress_container'))
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
      // 部分标题
      Text(this.questions[this.currentQuestionIndex].part)
        .fontSize(18)
        .fontColor($r('app.color.mbti_part_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
        .textAlign(TextAlign.Center)

      // 问题卡片
      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.mbti_question_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.mbti_question_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.mbti_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      // 选项区域
      Column() {
        // 选项A
        Row() {
          Text(`A. ${this.questions[this.currentQuestionIndex].optionA}`)
            .fontSize(18)
            .fontColor(this.userAnswers[this.currentQuestionIndex] === 'A' ?
            $r('app.color.mbti_option_selected_text') :
            $r('app.color.mbti_option_text'))
            .textAlign(TextAlign.Center)
            .lineHeight(24)
        }
        .width('90%')
        .padding(15)
        .backgroundColor(this.userAnswers[this.currentQuestionIndex] === 'A' ?
        $r('app.color.mbti_option_selected_background') :
        $r('app.color.mbti_option_background'))
        .borderRadius(10)
        .border({ width: 2, color: $r('app.color.mbti_option_border') })
        .onClick(() => this.selectAnswer('A'))
        .margin({ bottom: 15 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // 选项B
        Row() {
          Text(`B. ${this.questions[this.currentQuestionIndex].optionB}`)
            .fontSize(18)
            .fontColor(this.userAnswers[this.currentQuestionIndex] === 'B' ?
            $r('app.color.mbti_option_selected_text') :
            $r('app.color.mbti_option_text'))
            .textAlign(TextAlign.Center)
            .lineHeight(24)
        }
        .width('90%')
        .padding(15)
        .backgroundColor(this.userAnswers[this.currentQuestionIndex] === 'B' ?
        $r('app.color.mbti_option_selected_background') :
        $r('app.color.mbti_option_background'))
        .borderRadius(10)
        .border({ width: 2, color: $r('app.color.mbti_option_border') })
        .onClick(() => this.selectAnswer('B'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
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
      // MBTI 类型
      Text(this.mbtiResult)
        .fontSize(36)
        .fontColor($r('app.color.mbti_result_type'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 类型描述
      Text(this.resultDescription)
        .fontSize(18)
        .fontColor($r('app.color.mbti_result_description'))
        .textAlign(TextAlign.Center)
        .lineHeight(28)
        .padding(20)
        .backgroundColor($r('app.color.mbti_result_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.mbti_result_border') })

      // 免责声明
      Text("注意：此为精简版测试，结果仅供参考。性格的复杂性无法仅用四个字母完全概括。")
        .fontSize(14)
        .fontColor($r('app.color.mbti_disclaimer'))
        .textAlign(TextAlign.Center)
        .lineHeight(20)
        .margin({ top: 20 })
        .padding(10)
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
        // 测试中的控制按钮
        Row() {
          Button('上一题')
            .width(120)
            .height(45)
            .backgroundColor(this.currentQuestionIndex > 0 ?
            $r('app.color.mbti_button_previous') :
            $r('app.color.button_disabled'))
            .fontColor($r('app.color.mbti_button_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.mbti_button_skip'))
            .fontColor($r('app.color.mbti_button_text'))
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
        // 结果页面的控制按钮
        Row() {
          Button('重新测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.mbti_button_retest'))
            .fontColor($r('app.color.mbti_button_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.mbti_button_finish'))
            .fontColor($r('app.color.mbti_button_text'))
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

          Text('MBTI 性格测试')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.mbti_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.mbti_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.mbti_nav_border') })
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
      .backgroundColor($r('app.color.mbti_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function MBTIPageBuilder(param: object) {
  MBTIPage()
}