// pages/adjust/BreathingExercisePage.ets
import promptAction from '@ohos.promptAction';

// 呼吸节奏预设 - 保持不变
interface BreathingPattern {
  name: string;
  inhale: number; // 吸气时间（秒）
  hold: number;   // 屏息时间（秒）
  exhale: number; // 呼气时间（秒）
}

@Component
export struct BreathingExercisePage {
  pageStack: NavPathStack = new NavPathStack()

  // 呼吸状态 - 保持不变
  @State currentPhase: 'inhale' | 'hold' | 'exhale' = 'inhale';
  @State isPaused: boolean = false;
  @State breathSize: number = 100; // 呼吸球大小（百分比）

  // 呼吸节奏 - 保持不变
  @State breathingPatterns: BreathingPattern[] = [
    { name: '平衡呼吸', inhale: 4, hold: 0, exhale: 4 },
    { name: '放松呼吸', inhale: 4, hold: 2, exhale: 6 },
    { name: '4-7-8呼吸', inhale: 4, hold: 7, exhale: 8 },
    { name: '盒式呼吸', inhale: 4, hold: 4, exhale: 4 }
  ];
  @State selectedPatternIndex: number = 0;

  // 计时器相关 - 保持不变
  private timerId: number | null = null;
  private phaseStartTime: number = 0;

  // 文字提示 - 保持不变
  @State instructionText: string = '吸气...';

  aboutToAppear() {
    this.startBreathingCycle();
  }

  aboutToDisappear() {
    this.stopBreathingCycle();
  }

  // 开始呼吸循环 - 保持不变
  private startBreathingCycle() {
    if (this.timerId !== null) return;

    this.phaseStartTime = new Date().getTime();
    this.timerId = setInterval(() => {
      this.updateBreathingState();
    }, 100);
  }

  // 停止呼吸循环 - 保持不变
  private stopBreathingCycle() {
    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }

  // 更新呼吸状态 - 保持不变
  private updateBreathingState() {
    if (this.isPaused) return;

    const currentTime = new Date().getTime();
    const elapsed = (currentTime - this.phaseStartTime) / 1000; // 转换为秒

    const pattern = this.breathingPatterns[this.selectedPatternIndex];
    let phaseDuration = 0;

    switch (this.currentPhase) {
      case 'inhale':
        phaseDuration = pattern.inhale;
        break;
      case 'hold':
        phaseDuration = pattern.hold;
        break;
      case 'exhale':
        phaseDuration = pattern.exhale;
        break;
    }

    // 计算当前阶段的进度（0-1）
    const progress = Math.min(1, elapsed / phaseDuration);

    // 根据阶段和进度更新呼吸球大小
    switch (this.currentPhase) {
      case 'inhale':
        this.breathSize = 50 + (progress * 50); // 从50%膨胀到100%
        break;
      case 'hold':
        this.breathSize = 100; // 保持最大
        break;
      case 'exhale':
        this.breathSize = 100 - (progress * 50); // 从100%收缩到50%
        break;
    }

    // 检查是否需要切换到下一阶段
    if (elapsed >= phaseDuration) {
      this.switchToNextPhase();
    }
  }

  // 切换到下一呼吸阶段 - 保持不变
  private switchToNextPhase() {
    this.phaseStartTime = new Date().getTime();

    switch (this.currentPhase) {
      case 'inhale':
        this.currentPhase = this.breathingPatterns[this.selectedPatternIndex].hold > 0 ? 'hold' : 'exhale';
        this.instructionText = this.breathingPatterns[this.selectedPatternIndex].hold > 0 ? '屏息...' : '呼气...'
        break;
      case 'hold':
        this.currentPhase = 'exhale';
        this.instructionText = '呼气...';
        break;
      case 'exhale':
        this.currentPhase = 'inhale';
        this.instructionText = '吸气...';
        break;
    }
  }

  // 切换暂停/继续 - 保持不变
  private togglePause() {
    this.isPaused = !this.isPaused;

    if (!this.isPaused) {
      this.phaseStartTime = new Date().getTime();
    }
  }

  // 选择呼吸节奏 - 保持不变
  private selectPattern(index: number) {
    this.selectedPatternIndex = index;
    this.resetBreathingCycle();
    promptAction.showToast({ message: `已切换至${this.breathingPatterns[index].name}`, duration: 2000 });
  }

  // 重置呼吸循环 - 保持不变
  private resetBreathingCycle() {
    this.stopBreathingCycle();
    this.currentPhase = 'inhale';
    this.instructionText = '吸气...';
    this.breathSize = 50;
    this.phaseStartTime = new Date().getTime();
    this.startBreathingCycle();
  }

  // 返回功能汇总页面 - 保持不变
  private backToAdjustPage() {
    this.stopBreathingCycle();
    this.pageStack.pop(); // 使用NavPathStack的pop方法返回
  }

  // 构建呼吸球 - UI优化
  @Builder
  private buildBreathBall() {
    Stack({ alignContent: Alignment.Center }) {
      // 呼吸球背景
      Circle()
        .width('100%')
        .height('100%')
        .fill($r('app.color.breathing_ball_bg'))
        .opacity(0.3)

      // 呼吸球
      Circle()
        .width(`${this.breathSize}%`)
        .height(`${this.breathSize}%`)
        .fill($r('app.color.breathing_ball'))
        .animation({ duration: 300, curve: Curve.EaseInOut })

      // 呼吸提示文字
      Text(this.instructionText)
        .fontSize(24)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('50%')
  }

  // 构建呼吸节奏指示器
  @Builder
  private buildPatternIndicator() {
    Column() {
      // 当前呼吸节奏显示
      Text(`当前节奏: ${this.breathingPatterns[this.selectedPatternIndex].name}`)
        .fontSize(18)
        .fontColor($r('app.color.breathing_text_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      // 呼吸阶段指示器
      Row() {
        // 吸气指示器
        Column() {
          Text('吸气')
            .fontSize(16)
            .fontColor(this.currentPhase === 'inhale' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
          Text(`${this.breathingPatterns[this.selectedPatternIndex].inhale}s`)
            .fontSize(14)
            .fontColor(this.currentPhase === 'inhale' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
        }
        .margin({ right: 20 })

        // 屏息指示器（如果有）
        if (this.breathingPatterns[this.selectedPatternIndex].hold > 0) {
          Column() {
            Text('屏息')
              .fontSize(16)
              .fontColor(this.currentPhase === 'hold' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
            Text(`${this.breathingPatterns[this.selectedPatternIndex].hold}s`)
              .fontSize(14)
              .fontColor(this.currentPhase === 'hold' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
          }
          .margin({ right: 20 })
        }

        // 呼气指示器
        Column() {
          Text('呼气')
            .fontSize(16)
            .fontColor(this.currentPhase === 'exhale' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
          Text(`${this.breathingPatterns[this.selectedPatternIndex].exhale}s`)
            .fontSize(14)
            .fontColor(this.currentPhase === 'exhale' ? $r('app.color.breathing_text_primary') : $r('app.color.breathing_text_secondary'))
        }
      }
      .margin({ bottom: 20 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding(10)
    .backgroundColor($r('app.color.breathing_indicator_bg'))
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  // 构建控制面板 - UI优化
  @Builder
  private buildControlPanel() {
    Column() {
      // 暂停/继续按钮
      Button(this.isPaused ? '继续呼吸' : '暂停呼吸')
        .width(250)
        .height(50)
        .backgroundColor($r('app.color.breathing_button_primary'))
        .fontColor($r('app.color.breathing_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.togglePause())
        .margin({ bottom: 15 })
        .shadow({ radius: 5, color: '#40000000', offsetX: 2, offsetY: 4 })

      // 节奏选择按钮
      Button('选择呼吸节奏')
        .width(250)
        .height(50)
        .backgroundColor($r('app.color.breathing_button_secondary'))
        .fontColor($r('app.color.breathing_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => {
          // 创建按钮对象数组
          let buttons: promptAction.Button[] = this.breathingPatterns.map((pattern): promptAction.Button => {
            return {
              text: pattern.name,
              color: $r('app.color.breathing_button_text')
            };
          });

          // 确保不超过6个按钮
          if (buttons.length > 6) {
            buttons = buttons.slice(0, 6);
          }

          // 显示节奏选择弹窗
          promptAction.showActionMenu({
            title: '选择呼吸节奏',
            buttons: [
              buttons[0],
              buttons[1],
              buttons[2],
              buttons[3],
              buttons[4],
              buttons[5]
            ].filter(Boolean) as [promptAction.Button, promptAction.Button?, promptAction.Button?, promptAction.Button?, promptAction.Button?, promptAction.Button?]
          }).then((value: promptAction.ActionMenuSuccessResponse) => {
            const index = value.index;
            if (index >= 0) {
              this.selectPattern(index);
            }
          }).catch((err: Error) => {
            console.error(`Invoke showActionMenu failed, code is ${err}`);
          });
        })
        .shadow({ radius: 5, color: '#40000000', offsetX: 2, offsetY: 4 })
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

          Text('呼吸练习')
            .fontColor($r('app.color.breathing_nav_title'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.breathing_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.breathing_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 呼吸球区域
        this.buildBreathBall()

        // 呼吸节奏指示器
        this.buildPatternIndicator()

        // 控制面板
        this.buildControlPanel()

        // 提示信息
        Column() {
          Text('建议到空气清新流通的环境练习~')
            .fontSize(15)
            .fontColor($r('app.color.breathing_text_hint'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 10 })
          Text('请根据个体差异，自行把握练习节奏~')
            .fontSize(15)
            .fontColor($r('app.color.breathing_text_hint'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .margin({ top: 5,bottom:30 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.breathing_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function BreathingExercisePageBuilder() {
  BreathingExercisePage()
}