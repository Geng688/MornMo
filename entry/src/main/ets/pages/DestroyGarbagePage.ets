@Component
export struct DestroyGarbagePage {
  pageStack: NavPathStack = new NavPathStack();

  @State garbageText: string = ""; // 用户输入的情绪垃圾
  @State isDestroyed: boolean = false; // 是否已消灭垃圾

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 处理垃圾消灭
  private handleDestroyGarbage() {
    // 这里可以添加垃圾处理逻辑，如保存到本地或发送到服务器
    console.log("消灭的情绪垃圾:", this.garbageText);

    // 标记为已消灭
    this.isDestroyed = true;
  }

  // 构建输入区域
  @Builder
  private buildInputArea() {
    Column() {
      // 垃圾桶图标
      Image($r('app.media.ic_destroy_garbage'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 20, top: 30 })
        .opacity(0.8)

      TextArea({
        text: this.garbageText,
        placeholder: "如果有情绪垃圾，请输入它并消灭它！"
      })
        .height(300)
        .width('90%')
        .fontSize(18)
        .fontColor($r('app.color.destroy_text_primary'))
        .placeholderColor($r('app.color.destroy_text_placeholder'))
        .backgroundColor($r('app.color.destroy_input_background'))
        .border({ width: 1, color: $r('app.color.destroy_input_border') })
        .borderRadius(10)
        .padding(15)
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.garbageText = value;
        })
        .margin({ bottom: 20 })

      Button('消灭垃圾')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.destroy_button_destroy'))
        .fontColor($r('app.color.destroy_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.handleDestroyGarbage())
        .shadow({ radius: 5, color: '#40000000', offsetX: 2, offsetY: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建消灭成功区域
  @Builder
  private buildSuccessArea() {
    Column() {
      // 成功图标
      Image($r('app.media.ic_breath'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 30 })
        .animation({ duration: 1000, curve: Curve.EaseInOut })

      Text("成功消灭情绪垃圾！")
        .fontSize(30)
        .fontColor($r('app.color.destroy_success_text'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 15 })
        .animation({ duration: 500, curve: Curve.EaseInOut })

      Text("你已经清理了负面情绪，释放了心理空间")
        .fontSize(18)
        .fontColor($r('app.color.destroy_text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 30 })
        .width('80%')
        .animation({ duration: 700, curve: Curve.EaseInOut })

      Button('再消灭一些')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.destroy_button_success'))
        .fontColor($r('app.color.destroy_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => {
          this.isDestroyed = false;
          this.garbageText = "";
        })
        .shadow({ radius: 5, color: '#40000000', offsetX: 2, offsetY: 2 })
    }
    .width('100%')
    .height('100%')
    .margin({top:150})
    .justifyContent(FlexAlign.Start)
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

          Text('消灭情绪垃圾')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.destroy_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(60)
        .backgroundColor($r('app.color.destroy_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.destroy_nav_border') })
        .margin({ top: 0 })

        // 根据状态显示不同内容
        if (this.isDestroyed) {
          this.buildSuccessArea()
        } else {
          this.buildInputArea()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.destroy_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function DestroyGarbagePageBuilder(param: object) {
  DestroyGarbagePage()
}