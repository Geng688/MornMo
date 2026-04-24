import promptAction from '@ohos.promptAction';
import { AppStorageV2 } from "@kit.ArkUI";

// 定义按钮状态接口
interface ButtonState {
  id: number;
  isActive: boolean;
  isPressed: boolean;
}

// 定义颜色配置接口
interface ColorConfig {
  normal: string;
  active: string;
  pressed: string;
  text: string;
}

@Component
export struct StressReliefPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!;

  // 游戏状态
  @State isGameActive: boolean = false;
  @State gameLevel: number = 1;
  @State score: number = 0;
  @State remainingRedButtons: number = 0;
  @State gameTimer: number = 0;
  @State timerIntervalId: number = -1;

  // 新增：强制渲染状态变量
  @State isNewLevel: boolean = false;
  @State renderKey: number = 0;

  // 网格配置
  @State gridSize: number = 4;
  @State totalButtons: number = 16;
  @State redButtonCount: number = 3;

  // 按钮状态数组
  @State buttonStates: ButtonState[] = [];

  aboutToAppear() {
    this.initializeGame();
  }

  aboutToDisappear() {
    this.stopTimer();
  }

  // 初始化游戏
  private initializeGame(): void {
    // 创建初始按钮状态数组
    const initialButtonStates: ButtonState[] = [];
    for (let i = 0; i < this.totalButtons; i++) {
      const button: ButtonState = {
        id: i,
        isActive: false,
        isPressed: false
      };
      initialButtonStates.push(button);
    }
    this.buttonStates = initialButtonStates;
    this.resetGame();
  }

  // 重置游戏状态
  private resetGame(): void {
    this.isGameActive = false;
    this.score = 0;
    this.gameLevel = 1;
    this.remainingRedButtons = 0;
    this.gameTimer = 0;
    this.stopTimer();
    this.isNewLevel = false;

    // 创建新的按钮状态数组
    const newButtonStates: ButtonState[] = [];
    for (let i = 0; i < this.buttonStates.length; i++) {
      const newButton: ButtonState = {
        id: this.buttonStates[i].id,
        isActive: false,
        isPressed: false
      };
      newButtonStates.push(newButton);
    }
    this.buttonStates = newButtonStates;

    // 强制重新渲染
    this.forceRerender();
  }

  // 开始游戏
  private startGame(): void {
    if (this.isGameActive) return;

    this.isGameActive = true;
    this.remainingRedButtons = this.redButtonCount;
    this.gameTimer = 0;
    this.isNewLevel = true;

    this.startTimer();
    this.activateRandomButtons();

    promptAction.showToast({
      message: `游戏开始！找到${this.redButtonCount}个红色按钮`,
      duration: 2000
    });

    // 强制重新渲染
    this.forceRerender();
  }

  // 结束游戏
  private endGame(): void {
    if (!this.isGameActive) return;

    this.isGameActive = false;
    this.stopTimer();
    this.isNewLevel = false;

    // 创建新的按钮状态数组
    const newButtonStates: ButtonState[] = [];
    for (let i = 0; i < this.buttonStates.length; i++) {
      const newButton: ButtonState = {
        id: this.buttonStates[i].id,
        isActive: false,
        isPressed: false
      };
      newButtonStates.push(newButton);
    }
    this.buttonStates = newButtonStates;

    promptAction.showToast({
      message: `游戏结束！得分：${this.score}`,
      duration: 2000
    });

    // 强制重新渲染
    this.forceRerender();
  }

  // 启动计时器
  private startTimer(): void {
    this.stopTimer();
    this.timerIntervalId = setInterval(() => {
      this.gameTimer++;
    }, 1000);
  }

  // 停止计时器
  private stopTimer(): void {
    if (this.timerIntervalId !== -1) {
      clearInterval(this.timerIntervalId);
      this.timerIntervalId = -1;
    }
  }

  // 随机激活按钮
  private activateRandomButtons(): void {
    // 创建新的按钮状态数组
    const newButtonStates: ButtonState[] = [];
    for (let i = 0; i < this.buttonStates.length; i++) {
      const newButton: ButtonState = {
        id: this.buttonStates[i].id,
        isActive: false,
        isPressed: false
      };
      newButtonStates.push(newButton);
    }

    // 随机选择指定数量的按钮激活
    const availableIndices: number[] = [];
    for (let i = 0; i < this.totalButtons; i++) {
      availableIndices.push(i);
    }

    for (let i = 0; i < this.redButtonCount; i++) {
      if (availableIndices.length === 0) break;

      const randomIndex = Math.floor(Math.random() * availableIndices.length);
      const buttonIndex = availableIndices[randomIndex];

      // 从数组中移除已选索引
      availableIndices.splice(randomIndex, 1);

      // 激活按钮
      newButtonStates[buttonIndex].isActive = true;
    }

    this.buttonStates = newButtonStates;
    this.isNewLevel = !this.isNewLevel; // 切换状态强制渲染

    // 强制重新渲染
    this.forceRerender();
  }

  // 处理按钮点击
  private handleButtonClick(buttonId: number): void {
    if (!this.isGameActive) return;

    const button = this.buttonStates[buttonId];
    if (!button.isActive || button.isPressed) return;

    // 创建新的按钮状态数组
    const newButtonStates: ButtonState[] = [];
    for (let i = 0; i < this.buttonStates.length; i++) {
      if (i === buttonId) {
        const updatedButton: ButtonState = {
          id: this.buttonStates[i].id,
          isActive: this.buttonStates[i].isActive,
          isPressed: true
        };
        newButtonStates.push(updatedButton);
      } else {
        const unchangedButton: ButtonState = {
          id: this.buttonStates[i].id,
          isActive: this.buttonStates[i].isActive,
          isPressed: this.buttonStates[i].isPressed
        };
        newButtonStates.push(unchangedButton);
      }
    }

    this.buttonStates = newButtonStates;
    this.remainingRedButtons--;

    this.playClickSound();

    // 强制重新渲染
    this.forceRerender();

    if (this.remainingRedButtons === 0) {
      this.completeRound();
    }
  }

  // 完成一轮游戏
  private completeRound(): void {
    this.score += this.gameLevel * 10;
    this.gameLevel++;

    this.redButtonCount = Math.min(
      Math.floor(this.totalButtons / 2),
      this.redButtonCount + 1
    );

    promptAction.showToast({
      message: `第${this.gameLevel - 1}轮完成！得分+${(this.gameLevel - 1) * 10}`,
      duration: 1500
    });

    setTimeout(() => {
      if (this.isGameActive) {
        this.remainingRedButtons = this.redButtonCount;
        this.activateRandomButtons();
      }
    }, 2000);
  }

  // 强制重新渲染
  private forceRerender(): void {
    this.renderKey++; // 改变key值强制重新渲染
  }

  // 播放点击音效
  private playClickSound(): void {
    console.log('播放点击音效');
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 获取按钮颜色
  private getButtonColor(button: ButtonState): Resource {
    if (!this.isGameActive) {
      return $r('app.color.stress_button_normal');
    }
    if (button.isPressed) {
      return $r('app.color.stress_button_pressed');
    }
    if (button.isActive) {
      return $r('app.color.stress_button_active');
    }
    return $r('app.color.stress_button_normal');
  }

  // 获取按钮文字
  private getButtonText(button: ButtonState): string {
    if (!this.isGameActive) {
      return '';
    }
    if (button.isPressed) {
      return '✓';
    }
    if (button.isActive) {
      return '!';
    }
    return '';
  }

  // 返回上一页
  private backToPrevious(): void {
    this.stopTimer();
    this.pageStack.pop();
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
            .onClick(() => this.backToPrevious())
            .fillColor($r('app.color.stress_nav_icon'))

          Text('解压按钮游戏')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.stress_nav_title'))
            .margin({ left: 20 })

          Blank()

          if (this.isGameActive) {
            Text(`Lv.${this.gameLevel}`)
              .fontSize(14)
              .fontColor($r('app.color.stress_level_text'))
              .margin({ right: 10 })

            Text(this.formatTime(this.gameTimer))
              .fontSize(14)
              .fontColor($r('app.color.stress_timer_text'))
              .margin({ right: 20 })
          }
        }
        .width('100%')
        .height(80)
        .backgroundColor($r('app.color.stress_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.stress_nav_border') })

        // 游戏状态显示区域
        Column() {
          if (this.isGameActive) {
            Text(`剩余红色按钮: ${this.remainingRedButtons}`)
              .fontSize(18)
              .fontColor($r('app.color.stress_remaining_text'))
              .fontWeight(FontWeight.Bold)

            Text(`得分: ${this.score}`)
              .fontSize(16)
              .fontColor($r('app.color.stress_score_text'))
              .margin({ top: 5 })

            Text(`级别: ${this.gameLevel}`)
              .fontSize(14)
              .fontColor($r('app.color.stress_level_text'))
          } else {
            Text('点击开始游戏')
              .fontSize(20)
              .fontColor($r('app.color.stress_title_text'))
              .fontWeight(FontWeight.Medium)

            Text('找到所有红色按钮并点击它们')
              .fontSize(14)
              .fontColor($r('app.color.stress_subtitle_text'))
              .margin({ top: 10 })
          }
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.stress_status_background'))
        .alignItems(HorizontalAlign.Center)

        // 网格区域 - 使用key强制重新渲染
        Column() {
          Grid() {
            ForEach(this.buttonStates, (button: ButtonState) => {
              GridItem() {
                // 使用条件渲染和key强制重新渲染
                if (this.isNewLevel) {
                  Button(this.getButtonText(button))
                    .width('90%')
                    .aspectRatio(1)
                    .backgroundColor(this.getButtonColor(button))
                    .fontColor($r('app.color.stress_button_text'))
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .borderRadius(12)
                    .onClick(() => this.handleButtonClick(button.id))
                    .shadow({
                      radius: button.isActive ? 8 : 4,
                      color: button.isActive ? $r('app.color.stress_button_active_shadow') : $r('app.color.stress_button_normal_shadow'),
                      offsetX: 0,
                      offsetY: button.isActive ? 4 : 2
                    })
                    .key(`${button.id}_${this.renderKey}_new`)
                } else {
                  Button(this.getButtonText(button))
                    .width('90%')
                    .aspectRatio(1)
                    .backgroundColor(this.getButtonColor(button))
                    .fontColor($r('app.color.stress_button_text'))
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .borderRadius(12)
                    .onClick(() => this.handleButtonClick(button.id))
                    .shadow({
                      radius: button.isActive ? 8 : 4,
                      color: button.isActive ? $r('app.color.stress_button_active_shadow') : $r('app.color.stress_button_normal_shadow'),
                      offsetX: 0,
                      offsetY: button.isActive ? 4 : 2
                    })
                    .key(`${button.id}_${this.renderKey}`)
                }
              }
              .margin(4)
            }, (button: ButtonState) => `${button.id}_${this.renderKey}`)
          }
          .columnsTemplate(this.getColumnsTemplate())
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .height(400)
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        // 控制按钮区域
        Row({ space: 20 }) {
          if (!this.isGameActive) {
            Button('开始游戏')
              .width(140)
              .height(50)
              .backgroundColor($r('app.color.stress_button_start'))
              .fontColor($r('app.color.stress_button_text'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .onClick(() => this.startGame())
          } else {
            Button('结束游戏')
              .width(140)
              .height(50)
              .backgroundColor($r('app.color.stress_button_end'))
              .fontColor($r('app.color.stress_button_text'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .onClick(() => this.endGame())
          }

          Button('重新开始')
            .width(120)
            .height(50)
            .backgroundColor($r('app.color.stress_button_restart'))
            .fontColor($r('app.color.stress_button_text'))
            .fontSize(16)
            .borderRadius(25)
            .onClick(() => {
              this.resetGame();
              promptAction.showToast({ message: '游戏已重置', duration: 1000 });
            })
        }
        .width('100%')
        .padding(20)
        .justifyContent(FlexAlign.Center)

        // 游戏说明
        Column() {
          Text('游戏说明')
            .fontSize(16)
            .fontColor($r('app.color.stress_instruction_title'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })

          Text('• 点击"开始游戏"后，网格中会出现随机红色按钮')
            .fontSize(12)
            .fontColor($r('app.color.stress_instruction_text'))

          Text('• 点击所有红色按钮使其变绿即可进入下一轮')
            .fontSize(12)
            .fontColor($r('app.color.stress_instruction_text'))

          Text('• 随着级别提升，红色按钮数量会增加')
            .fontSize(12)
            .fontColor($r('app.color.stress_instruction_text'))
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.stress_instruction_background'))
        .borderRadius(10)
        .margin({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.stress_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }

  // 获取网格列模板
  private getColumnsTemplate(): string {
    return '1fr '.repeat(this.gridSize).trim();
  }
}

@Builder
export function StressReliefPageBuilder(param: object) {
  StressReliefPage()
}