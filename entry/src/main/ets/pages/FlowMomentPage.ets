import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

@Component
export struct FlowMomentPage {
  pageStack: NavPathStack = new NavPathStack();

  // 状态变量
  @State timerSeconds: number = 0;
  @State isTimerRunning: boolean = false;
  @State showEncouragement: boolean = false;
  @State currentEncouragement: string = "专注当下，成就未来！";
  @State encouragements: string[] = [
    "专注当下，成就未来！",
    "每一次专注都是进步的开始！",
    "心流状态是最佳的工作体验！",
    "保持专注，时间会给你答案！"
  ];
  @State bgImageSrc: string = "";
  @State showInputDialog: boolean = false;
  @State inputText: string = "";
  @State showImagePicker: boolean = false;

  private timerInterval: number = 0;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.showRandomEncouragement();
  }

  aboutToDisappear() {
    this.clearTimer();
  }

  // 显示随机鼓励语句
  private showRandomEncouragement() {
    const randomIndex = Math.floor(Math.random() * this.encouragements.length);
    this.currentEncouragement = this.encouragements[randomIndex];
  }

  // 开始计时
  private startTimer() {
    if (!this.isTimerRunning) {
      this.isTimerRunning = true;
      this.timerInterval = setInterval(() => {
        this.timerSeconds++;
      }, 1000);
    }
  }

  // 暂停计时
  private pauseTimer() {
    this.isTimerRunning = false;
    this.clearTimer();
  }

  // 重置计时
  private resetTimer() {
    this.pauseTimer();
    this.timerSeconds = 0;
  }

  // 清除计时器
  private clearTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = 0;
    }
  }

  // 格式化时间显示 (HH:MM:SS)
  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 添加鼓励语句
  private addEncouragement() {
    this.inputText = "";
    this.showInputDialog = true;
  }

  // 确认添加鼓励语句
  private confirmAddEncouragement() {
    if (this.inputText.trim() !== "") {
      this.encouragements.push(this.inputText);
      this.currentEncouragement = this.inputText;
      this.showEncouragement = true;
    }
    this.showInputDialog = false;
  }

  // 取消添加鼓励语句
  private cancelAddEncouragement() {
    this.showInputDialog = false;
  }

  // 切换显示内容（计时器/鼓励语句）
  private toggleDisplay() {
    this.showEncouragement = !this.showEncouragement;
  }

  // 更换背景
  private async changeBackground() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        await this.handleImageSelected(photoSelectResult.photoUris[0]);
      }
    } catch (err) {
      console.error(`选择图片失败: ${err.code}, 消息: ${err.message}`);
    }
  }

  // 处理选择的图片
  private async handleImageSelected(uri: string) {
    try {
      console.log("选择的图片URI:", uri);
      this.bgImageSrc = uri;
      console.log("背景图片已设置为:", uri);
    } catch (error) {
      console.error("设置背景图片失败:", error);
      this.bgImageSrc = "app.media.background";
    }
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pauseTimer();
    this.pageStack.pop();
  }

  // 构建计时器显示
  @Builder
  private buildTimerDisplay() {
    Column() {
      Text(this.formatTime(this.timerSeconds))
        .fontSize(60)
        .fontColor($r('app.color.flow_timer_text'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 15 })

      Text(this.isTimerRunning ? '专注中...' : '已暂停')
        .fontSize(20)
        .fontColor($r('app.color.flow_timer_status'))
        .opacity(0.9)
    }
    .width('80%')
    .height(250)
    .borderRadius(16)
    .shadow({ radius: 10, color: '#20000000', offsetX: 0, offsetY: 4 })
    .backgroundColor($r('app.color.flow_timer_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建鼓励语句显示
  @Builder
  private buildEncouragementDisplay() {
    Column() {
      Text(this.currentEncouragement)
        .fontSize(25)
        .fontColor($r('app.color.flow_encouragement_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(36)
        .maxLines(3)
        .padding({ left: 10, right: 10 })
    }
    .width('80%')
    .borderRadius(16)
    .shadow({ radius: 10, color: '#20000000', offsetX: 0, offsetY: 4 })
    .height(250)
    .backgroundColor($r('app.color.flow_encouragement_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建控制按钮
  @Builder
  private buildControlButtons() {
    Row() {
      // 开始/暂停按钮
      Button(this.isTimerRunning ? '暂停' : '开始')
        .width(120)
        .height(50)
        .backgroundColor(this.isTimerRunning ? $r('app.color.flow_button_pause') : $r('app.color.flow_button_start'))
        .fontColor($r('app.color.flow_button_text'))
        .fontSize(18)
        .borderRadius(25)
        .onClick(() => {
          if (this.isTimerRunning) {
            this.pauseTimer();
          } else {
            this.startTimer();
          }
        })

      // 重置按钮
      Button('重置')
        .width(80)
        .height(50)
        .backgroundColor($r('app.color.flow_button_reset'))
        .fontColor($r('app.color.flow_button_text'))
        .fontSize(18)
        .borderRadius(25)
        .margin({ left: 15 })
        .onClick(() => this.resetTimer())
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 30, bottom: 20 })
  }

  // 构建功能按钮
  @Builder
  private buildFunctionButtons() {
    Row() {
      // 添加鼓励语句按钮
      Button('添加鼓励')
        .width(100)
        .height(40)
        .backgroundColor($r('app.color.flow_button_add'))
        .fontColor($r('app.color.flow_button_text'))
        .fontSize(14)
        .borderRadius(20)
        .onClick(() => this.addEncouragement())

      // 切换显示按钮
      Button(this.showEncouragement ? '显示计时' : '显示鼓励')
        .width(100)
        .height(40)
        .backgroundColor($r('app.color.flow_button_toggle'))
        .fontColor($r('app.color.flow_button_text'))
        .fontSize(14)
        .borderRadius(20)
        .margin({ left: 10 })
        .onClick(() => this.toggleDisplay())

      // 更换背景按钮
      Button('更换背景')
        .width(100)
        .height(40)
        .backgroundColor($r('app.color.flow_button_background'))
        .fontColor($r('app.color.flow_button_text'))
        .fontSize(14)
        .borderRadius(20)
        .margin({ left: 10 })
        .onClick(() => this.changeBackground())
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 10 })
  }

  // 构建输入对话框
  @Builder
  private buildInputDialog() {
    // 半透明背景遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
      .onClick(() => this.cancelAddEncouragement())

    // 对话框内容
    Column() {
      Text('添加鼓励语句')
        .fontSize(20)
        .fontColor($r('app.color.flow_dialog_title'))
        .margin({ bottom: 20 })

      TextInput({ placeholder: '请输入鼓励语句...', text: this.inputText })
        .width('90%')
        .height(50)
        .fontSize(16)
        .backgroundColor($r('app.color.flow_dialog_input_background'))
        .border({ width: 1, color: $r('app.color.flow_dialog_border') })
        .borderRadius(8)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.inputText = value;
        })

      Row() {
        Button('取消')
          .width(100)
          .height(40)
          .backgroundColor($r('app.color.flow_dialog_cancel'))
          .fontColor($r('app.color.flow_dialog_cancel_text'))
          .onClick(() => this.cancelAddEncouragement())

        Button('确定')
          .width(100)
          .height(40)
          .backgroundColor($r('app.color.flow_dialog_confirm'))
          .fontColor($r('app.color.flow_dialog_confirm_text'))
          .margin({ left: 20 })
          .onClick(() => this.confirmAddEncouragement())
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('80%')
    .padding(20)
    .backgroundColor($r('app.color.flow_dialog_background'))
    .borderRadius(10)
    .position({ x: '10%', y: '30%' })
  }

  // 构建图片选择器
  @Builder
  private buildImagePicker() {
    // 半透明背景遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
      .onClick(() => this.showImagePicker = false)

    // 图片选择器内容
    Column() {
      Text('选择背景图片')
        .fontSize(20)
        .fontColor($r('app.color.flow_picker_title'))
        .margin({ bottom: 20 })

      // 使用系统图片选择器
      ImagePicker({
        controller: new picker.PhotoViewPicker(),
        onSelect: (uri: string) => {
          this.handleImageSelected(uri);
        },
        onCancel: () => {
          this.showImagePicker = false;
        }
      })
        .width('90%')
        .height(300)
        .margin({ bottom: 20 })

      Button('取消')
        .width(200)
        .height(40)
        .backgroundColor($r('app.color.flow_picker_cancel'))
        .fontColor($r('app.color.flow_picker_cancel_text'))
        .onClick(() => this.showImagePicker = false)
    }
    .width('90%')
    .padding(20)
    .backgroundColor($r('app.color.flow_picker_background'))
    .borderRadius(10)
    .position({ x: '5%', y: '20%' })
  }

  build() {
    NavDestination() {
      Stack() {
        // 背景 - 使用纯色背景
        if (this.bgImageSrc) {
          // 如果有背景图片，显示图片
          Image(this.bgImageSrc.startsWith('app.media.') ? $r(this.bgImageSrc) : this.bgImageSrc)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        } else {
          // 默认使用浅蓝色背景
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.flow_default_background'))
        }

        // 半透明遮罩
        Column() {
          // 顶部导航栏
          Row() {
            Image($r('app.media.ic_back'))
              .width(30)
              .height(30)
              .margin({ left: 15 })
              .onClick(() => this.backToAdjustPage())
              .fillColor($r('app.color.flow_nav_icon'))

            Text('心流专注')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.flow_nav_title'))
              .margin({ left: 20 })

            Blank()
          }
          .width('100%')
          .height(90)
          .backgroundColor($r('app.color.flow_nav_background'))
          .border({ width: { bottom: 1 }, color: $r('app.color.flow_nav_border') })
          .margin({ top: -20 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

          // 主要内容区域
          Column() {
            // 增大顶部空间
            Blank()
              .height('20%')

            // 点击切换区域
            Column() {
              if (this.showEncouragement) {
                this.buildEncouragementDisplay()
              } else {
                this.buildTimerDisplay()
              }
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.toggleDisplay())

            // 增大中间空间
            Blank()
              .height('10%')

            // 控制按钮
            this.buildControlButtons()

            // 功能按钮
            this.buildFunctionButtons()

            // 底部空间
            Blank()
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255,255,255,0.2)')

        // 输入对话框（条件渲染）
        if (this.showInputDialog) {
          this.buildInputDialog()
        }

        // 图片选择器（条件渲染）
        if (this.showImagePicker) {
          this.buildImagePicker()
        }
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.flow_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

// 自定义图片选择器组件
@Component
struct ImagePicker {
  controller!: picker.PhotoViewPicker;
  onSelect!: (uri: string) => void;
  onCancel!: () => void;

  build() {
    Column() {
      Button('从相册选择')
        .width('100%')
        .height(60)
        .backgroundColor($r('app.color.flow_picker_select'))
        .fontColor($r('app.color.flow_picker_select_text'))
        .fontSize(22)
        .margin({ bottom: 15 })
        .onClick(async () => {
          try {
            const photoSelectOptions = new picker.PhotoSelectOptions();
            photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;

            const photoSelectResult = await this.controller.select(photoSelectOptions);

            if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
              this.onSelect(photoSelectResult.photoUris[0]);
            }
          } catch (err) {
            console.error(`Invoke photoPicker failed, code is ${err.code}, message is ${err.message}`);
            this.onCancel();
          }
        })

      Button('取消')
        .width('100%')
        .height(60)
        .backgroundColor($r('app.color.flow_picker_cancel'))
        .fontColor($r('app.color.flow_picker_cancel_text'))
        .fontSize(22)
        .onClick(() => this.onCancel())
    }
    .width('100%')
    .padding(15)
  }
}

@Builder
export function FlowMomentPageBuilder(param: object) {
  FlowMomentPage()
}