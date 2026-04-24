import promptAction from '@ohos.promptAction';
import { AppStorageV2 } from "@kit.ArkUI";

@Component
export struct FocusCounterPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!;

  // 专注计数状态
  @State count: number = 0;
  @State isActive: boolean = false;
  @State textSize: number = 22;

  // 表扬语句数组 - 根据计数级别提供不同的表扬
  @State praises: string[] = [
  // 初级表扬 (1-5次)
    "好的开始！继续加油！",
    "又完成了一次专注！真棒！",
    "坚持就是胜利！你已经完成${count}次了！",
    "专注力在慢慢提升！继续努力！",
    "每一次专注都是进步！",

    // 中级表扬 (6-15次)
    "太棒了！你已经完成${count}次专注了！",
    "专注力越来越强了！继续保持！",
    "恭喜！你的专注力正在形成习惯！",
    "做得好！专注力是成功的关键！",
    "优秀！${count}次专注见证你的成长！",

    // 高级表扬 (16-30次)
    "了不起！${count}次专注！你正在创造奇迹！",
    "专注大师！你的毅力令人敬佩！",
    "太优秀了！${count}次专注证明你的决心！",
    "令人惊叹的专注力！继续保持这个节奏！",
    "专注力爆棚！你正在成为更好的自己！",

    // 顶级表扬 (31次以上)
    "专注王者！${count}次的坚持无人能及！",
    "超凡脱俗的专注力！你已经是专家了！",
    "传奇般的坚持！${count}次专注改变人生！",
    "专注之神！你的毅力将创造无限可能！",
    "史诗级的成就！${count}次专注塑造非凡！"
  ];

  @State currentPraise: string = "";
  @State showPraise: boolean = false;

  aboutToAppear() {
    this.resetCounter();
  }

  // 重置计数器
  private resetCounter() {
    this.count = 0;
    this.currentPraise = "";
    this.showPraise = false;
    this.textSize = 22;
    this.isActive = false;
  }

  // 增加计数并检查是否显示表扬
  private incrementCount() {
    this.count++;
    this.textSize = 28; // 点击时放大效果
    this.isActive = true;

    // 检查是否应该显示表扬
    this.checkPraise();

    // 1秒后恢复文字大小
    setTimeout(() => {
      this.textSize = 22;
      this.isActive = false;
    }, 300);
  }

  // 检查并显示表扬
  private checkPraise() {
    // 在特定计数点显示表扬
    const praisePoints = [1, 3, 5, 8, 10, 15, 20, 25, 30, 40, 50];

    if (praisePoints.includes(this.count)) {
      this.showRandomPraise();
    }

    // 每5次显示一次表扬（除了特定的点）
    if (this.count > 0 && this.count % 5 === 0 && !praisePoints.includes(this.count)) {
      this.showRandomPraise();
    }
  }

  // 显示随机表扬
  private showRandomPraise() {
    let praiseCategory = 0;

    // 根据计数级别选择表扬类别
    if (this.count <= 5) {
      praiseCategory = 0; // 初级
    } else if (this.count <= 15) {
      praiseCategory = 1; // 中级
    } else if (this.count <= 30) {
      praiseCategory = 2; // 高级
    } else {
      praiseCategory = 3; // 顶级
    }

    // 从对应类别中随机选择（每个类别有5条）
    const startIndex = praiseCategory * 5;
    const endIndex = startIndex + 5;
    const categoryPraises = this.praises.slice(startIndex, endIndex);

    const randomIndex = Math.floor(Math.random() * categoryPraises.length);
    let selectedPraise = categoryPraises[randomIndex];

    // 替换模板变量
    selectedPraise = selectedPraise.replace('${count}', this.count.toString());

    this.currentPraise = selectedPraise;
    this.showPraise = true;

    // 显示表扬提示
    promptAction.showToast({
      message: selectedPraise,
      duration: 2000,
      bottom: 200
    });

    // 3秒后隐藏表扬文字（但Toast会保持2秒）
    setTimeout(() => {
      this.showPraise = false;
    }, 3000);
  }

  // 返回上一页
  private backToPrevious() {
    this.pageStack.pop();
  }

  // 构建计数器显示区域
  @Builder
  private buildCounterArea() {
    Column() {
      // 计数显示 - 动态效果
      Stack({ alignContent: Alignment.Center }) {
        // 背景圆圈
        Circle()
          .width(180)
          .height(180)
          .fill(this.getCounterColor())
          .opacity(0.2)

        // 计数数字
        Text(this.count.toString())
          .fontSize(64)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCounterColor())
      }
      .margin({ bottom: 20 })

      // 表扬文字显示
      if (this.showPraise) {
        Text(this.currentPraise)
          .fontSize(18)
          .fontColor($r('app.color.focus_praise_text'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding(15)
          .backgroundColor($r('app.color.focus_praise_background'))
          .borderRadius(10)
          .border({ width: 1, color: $r('app.color.focus_praise_border') })
          .shadow({ radius: 5, color: '#20000000', offsetX: 0, offsetY: 3 })
          .margin({ bottom: 10 })
      }

      // 计数说明
      Text(`专注次数`)
        .fontSize(16)
        .fontColor($r('app.color.focus_description_text'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 30 }) // 添加顶部外边距，使整个计数器区域下移
    .onClick(() => {
      // 点击计数区域也可以增加计数（可选功能）
      this.incrementCount();
    })
  }

  // 根据计数获取颜色（动态变化）
  private getCounterColor(): Resource {
    if (this.count >= 30) return $r('app.color.focus_counter_top'); // 紫色 - 顶级
    if (this.count >= 15) return $r('app.color.focus_counter_advanced'); // 蓝色 - 高级
    if (this.count >= 5) return $r('app.color.focus_counter_medium'); // 橙色 - 中级
    return $r('app.color.focus_counter_primary'); // 绿色 - 初级
  }

  // 构建控制面板
  @Builder
  private buildControlPanel() {
    Column() {
      // +1 按钮 - 主要功能
      Button('+1 专注')
        .width(200)
        .height(60)
        .backgroundColor(this.getCounterColor())
        .fontColor($r('app.color.focus_button_text'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .borderRadius(30)
        .onClick(() => this.incrementCount())
        .shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 5 })
        .margin({ bottom: 20 })

      // 重置按钮
      Button('重新开始')
        .width(160)
        .height(45)
        .backgroundColor($r('app.color.focus_reset_button_background'))
        .fontColor($r('app.color.focus_reset_button_text'))
        .fontSize(16)
        .borderRadius(22)
        .onClick(() => this.resetCounter())
        .margin({ bottom: 10 })

      // 提示文字
      Text('点击数字或按钮增加专注计数')
        .fontSize(14)
        .fontColor($r('app.color.focus_hint_text'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 10, bottom: 10 })
  }

  // 构建成就徽章区域
  @Builder
  private buildAchievementArea() {
    Column() {
      Text('专注成就')
        .fontSize(16)
        .fontColor($r('app.color.focus_achievement_title'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      Row({ space: 15 }) {
        // 5次成就
        Column() {
          Circle()
            .width(40)
            .height(40)
            .fill(this.count >= 5 ? $r('app.color.focus_counter_primary') : $r('app.color.focus_badge_inactive_bg'))
            .border({ width: 2, color: this.count >= 5 ? $r('app.color.focus_badge_active_border') : $r('app.color.focus_badge_inactive_border') })

          Text('5次')
            .fontSize(12)
            .fontColor(this.count >= 5 ? $r('app.color.focus_counter_primary') : $r('app.color.focus_badge_inactive_text'))
        }

        // 15次成就
        Column() {
          Circle()
            .width(40)
            .height(40)
            .fill(this.count >= 15 ? $r('app.color.focus_counter_medium') : $r('app.color.focus_badge_inactive_bg'))
            .border({ width: 2, color: this.count >= 15 ? $r('app.color.focus_badge_active_border') : $r('app.color.focus_badge_inactive_border') })

          Text('15次')
            .fontSize(12)
            .fontColor(this.count >= 15 ? $r('app.color.focus_counter_medium') : $r('app.color.focus_badge_inactive_text'))
        }

        // 30次成就
        Column() {
          Circle()
            .width(40)
            .height(40)
            .fill(this.count >= 30 ? $r('app.color.focus_counter_advanced') : $r('app.color.focus_badge_inactive_bg'))
            .border({ width: 2, color: this.count >= 30 ? $r('app.color.focus_badge_active_border') : $r('app.color.focus_badge_inactive_border') })

          Text('30次')
            .fontSize(12)
            .fontColor(this.count >= 30 ? $r('app.color.focus_counter_advanced') : $r('app.color.focus_badge_inactive_text'))
        }

        // 50次成就
        Column() {
          Circle()
            .width(40)
            .height(40)
            .fill(this.count >= 50 ? $r('app.color.focus_counter_top') : $r('app.color.focus_badge_inactive_bg'))
            .border({ width: 2, color: this.count >= 50 ? $r('app.color.focus_badge_active_border') : $r('app.color.focus_badge_inactive_border') })

          Text('50次')
            .fontSize(12)
            .fontColor(this.count >= 50 ? $r('app.color.focus_counter_top') : $r('app.color.focus_badge_inactive_text'))
        }
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor($r('app.color.focus_achievement_background'))
    .borderRadius(10)
    .border({ width: 1, color: $r('app.color.focus_achievement_border') })
    .margin({ top: 10, bottom: 20 })
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

          Text('专注计数')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.focus_nav_title'))
            .margin({ left: 20 })

          Blank()

          // 当前计数显示
          Text(`${this.count}次`)
            .fontSize(16)
            .fontColor($r('app.color.focus_nav_count_text'))
            .margin({ right: 20 })
        }
        .width('100%')
        .height(60)
        .backgroundColor($r('app.color.focus_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.focus_nav_border') })
        .alignItems(VerticalAlign.Center)

        // 使用ScrollView确保所有内容可见
        Scroll() {
          Column() {
            // 计数器显示区域
            Column() {
              this.buildCounterArea()
            }
            .layoutWeight(2) // 使用layoutWeight分配空间

            // 控制面板
            Column() {
              this.buildControlPanel()
            }
            .layoutWeight(1) // 使用layoutWeight分配空间

            // 成就区域
            Column() {
              this.buildAchievementArea()
            }
            .layoutWeight(1) // 使用layoutWeight分配空间
          }
          .width('100%')
          .height('100%')
          .padding(20)
        }
        .layoutWeight(1) // ScrollView占据剩余空间
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.focus_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function FocusCounterPageBuilder(param: object) {
  FocusCounterPage()
}