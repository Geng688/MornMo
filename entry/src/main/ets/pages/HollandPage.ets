import { promptAction } from "@kit.ArkUI";

// 定义选项项的接口
interface OptionItem {
  text: string;
  dimension: string;
  value: string;
}

// 定义问题项的接口
interface QuestionItem {
  id: number;
  text: string;
  part: string;
  options: OptionItem[];
}

// 定义霍兰德类型描述
interface HollandDescription {
  title: string;
  traits: string;
  careers: string;
}

interface HollandResult {
  dimension: string;
  score: number;
}

@Component
export struct HollandPage {
  pageStack: NavPathStack = new NavPathStack();

  // 霍兰德职业测试问题
  @State questions: QuestionItem[] = [
    {
      id: 1,
      text: "空闲时，你更愿意：",
      part: "一、现实型（R）vs 研究型（I）",
      options: [
        { text: "修理家电、组装家具或做手工活", dimension: "R", value: "A" },
        { text: "阅读科普文章、研究新软件功能或观察自然现象", dimension: "I", value: "B" }
      ]
    },
    {
      id: 2,
      text: "面对问题，你更倾向：",
      part: "一、现实型（R）vs 研究型（I）",
      options: [
        { text: "动手尝试解决，比如修理损坏的物品", dimension: "R", value: "A" },
        { text: "先分析原理，再通过数据或实验验证方案", dimension: "I", value: "B" }
      ]
    },
    {
      id: 3,
      text: "选择爱好时，你更偏好：",
      part: "一、现实型（R）vs 研究型（I）",
      options: [
        { text: "户外运动（如登山、骑行）、机械模型制作", dimension: "R", value: "A" },
        { text: "科学实验、数据分析、阅读学术书籍", dimension: "I", value: "B" }
      ]
    },
    {
      id: 4,
      text: "你更享受哪种活动：",
      part: "二、研究型（I）vs 艺术型（A）",
      options: [
        { text: "探索未知领域，比如研究新的科学理论", dimension: "I", value: "A" },
        { text: "创作原创内容，比如写短文、画画或编曲", dimension: "A", value: "B" }
      ]
    },
    {
      id: 5,
      text: "完成任务时，你更关注：",
      part: "二、研究型（I）vs 艺术型（A）",
      options: [
        { text: "逻辑是否严谨、结论是否有依据", dimension: "I", value: "A" },
        { text: "表达是否独特、形式是否有创意", dimension: "A", value: "B" }
      ]
    },
    {
      id: 6,
      text: "你对以下哪类话题更感兴趣：",
      part: "二、研究型（I）vs 艺术型（A）",
      options: [
        { text: "人工智能的发展原理、宇宙探索新发现", dimension: "I", value: "A" },
        { text: "电影的艺术手法、诗歌的情感表达", dimension: "A", value: "B" }
      ]
    },
    {
      id: 7,
      text: "周末安排，你更倾向：",
      part: "三、艺术型（A）vs 社会型（S）",
      options: [
        { text: "参观艺术展、写日记或创作短视频", dimension: "A", value: "A" },
        { text: "参加志愿者活动、和朋友谈心或帮他人解决困扰", dimension: "S", value: "B" }
      ]
    },
    {
      id: 8,
      text: "你更擅长：",
      part: "三、艺术型（A）vs 社会型（S）",
      options: [
        { text: "用文字、图像或音乐表达想法", dimension: "A", value: "A" },
        { text: "理解他人情绪、协调人际关系", dimension: "S", value: "B" }
      ]
    },
    {
      id: 9,
      text: "你更愿意参与哪种项目：",
      part: "三、艺术型（A）vs 社会型（S）",
      options: [
        { text: "策划一场文艺演出、设计宣传海报", dimension: "A", value: "A" },
        { text: "组织社区公益活动、帮助新人适应环境", dimension: "S", value: "B" }
      ]
    },
    {
      id: 10,
      text: "团队合作中，你更倾向：",
      part: "四、社会型（S）vs 企业型（E）",
      options: [
        { text: "关心成员需求，确保大家沟通顺畅", dimension: "S", value: "A" },
        { text: "制定目标和策略，带动团队达成结果", dimension: "E", value: "B" }
      ]
    },
    {
      id: 11,
      text: "你对'成功'的理解更接近：",
      part: "四、社会型（S）vs 企业型（E）",
      options: [
        { text: "帮助他人成长、获得他人信任", dimension: "S", value: "A" },
        { text: "实现事业目标、拥有管理或决策权力", dimension: "E", value: "B" }
      ]
    },
    {
      id: 12,
      text: "你更愿意尝试哪种工作：",
      part: "四、社会型（S）vs 企业型（E）",
      options: [
        { text: "教师、心理咨询师、社区工作者", dimension: "S", value: "A" },
        { text: "项目经理、销售主管、创业者", dimension: "E", value: "B" }
      ]
    },
    {
      id: 13,
      text: "处理事务时，你更习惯：",
      part: "五、企业型（E）vs 常规型（C）",
      options: [
        { text: "灵活调整计划，抓住机会达成目标", dimension: "E", value: "A" },
        { text: "按规则和流程执行，确保细节准确", dimension: "C", value: "B" }
      ]
    },
    {
      id: 14,
      text: "你更擅长：",
      part: "五、企业型（E）vs 常规型（C）",
      options: [
        { text: "说服他人、谈判合作、整合资源", dimension: "E", value: "A" },
        { text: "整理数据、记录文档、维护秩序", dimension: "C", value: "B" }
      ]
    },
    {
      id: 15,
      text: "你对以下哪类工作更感兴趣：",
      part: "五、企业型（E）vs 常规型（C）",
      options: [
        { text: "开拓新市场、组织商业活动", dimension: "E", value: "A" },
        { text: "财务记账、档案管理、流程优化", dimension: "C", value: "B" }
      ]
    },
    {
      id: 16,
      text: "你更享受哪种任务完成后的成就感：",
      part: "六、常规型（C）vs 现实型（R）",
      options: [
        { text: "把杂乱的文件整理得井井有条、数据核对无误", dimension: "C", value: "A" },
        { text: "亲手做出一件物品（如家具、手工艺品）、修好故障设备", dimension: "R", value: "B" }
      ]
    },
    {
      id: 17,
      text: "你更倾向选择哪种环境工作：",
      part: "六、常规型（C）vs 现实型（R）",
      options: [
        { text: "安静、规则清晰、注重细节的办公室", dimension: "C", value: "A" },
        { text: "有工具、能动手操作的车间或户外场地", dimension: "R", value: "B" }
      ]
    },
    {
      id: 18,
      text: "你更擅长：",
      part: "六、常规型（C）vs 现实型（R）",
      options: [
        { text: "熟练使用办公软件、按模板完成报表", dimension: "C", value: "A" },
        { text: "操作工具、维修设备、搭建简单装置", dimension: "R", value: "B" }
      ]
    },
    {
      id: 19,
      text: "你更愿意学习哪种技能：",
      part: "七、综合补充题（覆盖全维度）",
      options: [
        { text: "编程、数据分析", dimension: "I", value: "A" },
        { text: "绘画、视频剪辑", dimension: "A", value: "B" },
        { text: "演讲、团队管理", dimension: "E", value: "C" }
      ]
    },
    {
      id: 20,
      text: "选择职业时，你更看重：",
      part: "七、综合补充题（覆盖全维度）",
      options: [
        { text: "能帮助他人、促进社会互动", dimension: "S", value: "A" },
        { text: "能动手实践、解决实际问题", dimension: "R", value: "B" },
        { text: "能按流程执行、保证准确高效", dimension: "C", value: "C" }
      ]
    },
    {
      id: 21,
      text: "你对以下哪类活动更有热情：",
      part: "七、综合补充题（覆盖全维度）",
      options: [
        { text: "研究新课题、发表观点", dimension: "I", value: "A" },
        { text: "策划活动、带动氛围", dimension: "E", value: "B" },
        { text: "创作作品、表达创意", dimension: "A", value: "C" }
      ]
    }
  ] as QuestionItem[];

  // 霍兰德类型描述
  @State hollandDescriptions: Record<string, HollandDescription> = {
    "R": {
      title: "现实型（Realistic）",
      traits: "喜欢动手、务实、偏好具体操作，注重实际结果",
      careers: "机械工程师、电工、厨师、园艺师、汽修师、木匠、建筑师"
    } as HollandDescription,
    "I": {
      title: "研究型（Investigative）",
      traits: "热爱探索、理性、擅长分析思考，追求知识和真理",
      careers: "数据分析师、科研人员、程序员、医生、大学教师、工程师、科学家"
    } as HollandDescription,
    "A": {
      title: "艺术型（Artistic）",
      traits: "追求创意、感性、善于表达想象，注重美感和独特性",
      careers: "设计师、作家、音乐人、摄影师、广告创意师、演员、导演、艺术家"
    } as HollandDescription,
    "S": {
      title: "社会型（Social）",
      traits: "乐于助人、热情、擅长人际互动，注重服务和关怀",
      careers: "教师、心理咨询师、社工、护士、人力资源专员、医生、顾问"
    } as HollandDescription,
    "E": {
      title: "企业型（Enterprising）",
      traits: "目标导向、果断、擅长领导决策，注重影响和成就",
      careers: "销售经理、创业者、项目经理、公务员（管理岗）、律师、企业高管"
    } as HollandDescription,
    "C": {
      title: "常规型（Conventional）",
      traits: "注重秩序、细致、擅长按规执行，注重准确和稳定",
      careers: "会计、档案管理员、行政专员、财务助理、数据录入员、银行职员"
    } as HollandDescription
  };

  @State currentQuestionIndex: number = 0;
  @State userAnswers: string[] = new Array(21).fill('');
  @State showResult: boolean = false;
  @State hollandResults: HollandResult[] = [];
  @State topDimensions: string[] = [];
  @State resultDescription: string = '';

  aboutToAppear() {
    this.resetTest();
  }

  // 重置测试
  private resetTest() {
    this.currentQuestionIndex = 0;
    this.userAnswers = new Array(21).fill('');
    this.showResult = false;
    this.hollandResults = [];
    this.topDimensions = [];
    this.resultDescription = '';
  }

  // 选择答案
  private selectAnswer(dimension: string) {
    this.userAnswers[this.currentQuestionIndex] = dimension;

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

  // 计算霍兰德结果
  private calculateResult() {
    const dimensionScores: Record<string, number> = {
      "R": 0, "I": 0, "A": 0, "S": 0, "E": 0, "C": 0
    };

    this.userAnswers.forEach((dimension: string) => {
      if (dimension && dimensionScores[dimension] !== undefined) {
        dimensionScores[dimension]++;
      }
    });

    this.hollandResults = Object.keys(dimensionScores).map(dimension => ({
      dimension,
      score: dimensionScores[dimension]
    } as HollandResult)).sort((a, b) => b.score - a.score);

    const maxScore = this.hollandResults[0].score;
    this.topDimensions = this.hollandResults
      .filter(result => result.score === maxScore)
      .map(result => result.dimension);

    this.generateResultDescription();
    this.showResult = true;

    promptAction.showToast({
      message: `测试完成！您的霍兰德代码是：${this.topDimensions.join('-')}`,
      duration: 3000,
      bottom: 200
    });
  }

  // 生成结果描述
  private generateResultDescription() {
    if (this.topDimensions.length === 0) return;

    let description = `您的霍兰德职业兴趣代码是：${this.topDimensions.join('-')}\n\n`;

    this.topDimensions.forEach(dimension => {
      const desc = this.hollandDescriptions[dimension];
      if (desc) {
        description += `【${desc.title}】\n`;
        description += `核心特质：${desc.traits}\n`;
        description += `典型职业：${desc.careers}\n\n`;
      }
    });

    if (this.topDimensions.length > 1) {
      description += "💡 复合型兴趣类型更常见，意味着您适合结合多种特质的职业路径。\n\n";
    }

    description += "📝 注意事项：\n";
    description += "• 测试结果反映的是'兴趣倾向'，而非'能力匹配'\n";
    description += "• 职业选择还需结合自身技能、教育背景和行业机会\n";
    description += "• 若需更精准匹配，可参考完整版霍兰德测试\n";

    this.resultDescription = description;
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
        .fontColor($r('app.color.holland_progress_text'))

      Blank()

      // 使用 Progress 组件
      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.questions.length,
        type: ProgressType.Linear
      })
        .width('60%')
        .height(6)
        .backgroundColor($r('app.color.holland_progress_background'))
        .color($r('app.color.holland_progress_foreground'))
        .borderRadius(3)
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.holland_progress_container'))
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
      Text(this.questions[this.currentQuestionIndex].part)
        .fontSize(18)
        .fontColor($r('app.color.holland_part_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })
        .textAlign(TextAlign.Center)

      Text(this.questions[this.currentQuestionIndex].text)
        .fontSize(22)
        .fontColor($r('app.color.holland_question_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.holland_question_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.holland_question_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
        .margin({ bottom: 30 })

      Column() {
        ForEach(this.questions[this.currentQuestionIndex].options, (option: OptionItem) => {
          Row() {
            Text(`${option.value}. ${option.text}`)
              .fontSize(18)
              .fontColor(this.userAnswers[this.currentQuestionIndex] === option.dimension ?
              $r('app.color.holland_option_selected_text') :
              $r('app.color.holland_option_text'))
              .textAlign(TextAlign.Center)
              .lineHeight(24)
          }
          .width('90%')
          .height(80)
          .padding(15)
          .backgroundColor(this.userAnswers[this.currentQuestionIndex] === option.dimension ?
          $r('app.color.holland_option_selected_background') :
          $r('app.color.holland_option_background'))
          .borderRadius(10)
          .border({ width: 2, color: $r('app.color.holland_option_border') })
          .onClick(() => this.selectAnswer(option.dimension))
          .margin({ bottom: 15 })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        })
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
      Text("霍兰德职业测试结果")
        .fontSize(24)
        .fontColor($r('app.color.holland_result_title'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 })

      Text(this.topDimensions.join('-'))
        .fontSize(32)
        .fontColor($r('app.color.holland_result_code'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Scroll() {
        Text(this.resultDescription)
          .fontSize(16)
          .fontColor($r('app.color.holland_result_description'))
          .lineHeight(24)
          .padding(20)
          .backgroundColor($r('app.color.holland_result_background'))
          .borderRadius(15)
          .border({ width: 1, color: $r('app.color.holland_result_border') })
      }
      .width('100%')
      .height('60%')

      Text("注意：此为精简版测试，结果仅供参考。职业选择需结合实际情况综合考虑。")
        .fontSize(14)
        .fontColor($r('app.color.holland_result_hint'))
        .textAlign(TextAlign.Center)
        .lineHeight(20)
        .margin({ top: 10 })
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
        Row() {
          Button('上一题')
            .width(120)
            .height(45)
            .backgroundColor(this.currentQuestionIndex > 0 ?
            $r('app.color.holland_button_previous') :
            $r('app.color.button_disabled'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => this.previousQuestion())
            .enabled(this.currentQuestionIndex > 0)

          Blank()

          Button('跳过此题')
            .width(120)
            .height(45)
            .backgroundColor($r('app.color.holland_button_skip'))
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
            .backgroundColor($r('app.color.holland_button_retest'))
            .fontColor($r('app.color.button_primary_text'))
            .fontSize(18)
            .borderRadius(25)
            .onClick(() => this.resetTest())

          Blank()

          Button('完成测试')
            .width(150)
            .height(50)
            .backgroundColor($r('app.color.holland_button_finish'))
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

          Text('霍兰德职业测试')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.holland_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.holland_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.holland_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        this.buildProgressIndicator()

        this.buildQuestionArea()

        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.holland_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function HollandPageBuilder(param: object) {
  HollandPage()
}