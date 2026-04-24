// pages/home/HomePage.ets
import { MoodFace } from '../components/business/MoodFace';
import { AppStorageV2 } from '@kit.ArkUI';
import preference from '@ohos.data.preferences';

@Builder
export function HomePageBuilder() {
  HomePage()
}

// 功能项接口
interface FunctionItem {
  id: number;
  icon: Resource;
  title: string;
  pageName: string;
}

@Component
export struct HomePage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!;
  name: String = '';

  @State moodValue: number = 100;
  @State activeMenu: string = ''; // 记录当前激活的菜单项
  @State showFunctionPanel: boolean = false; // 是否显示功能面板
  @State favoriteFunctions: FunctionItem[] = []; // 收藏的功能列表
  private prefs: preference.Preferences | null = null;
  private readonly FAVORITE_KEY: string = 'favorite_functions';

  // 所有功能映射表
  private allFunctions: FunctionItem[] = [
    { id: 1, icon: $r('app.media.ic_suggestion'), title: '心理暗示', pageName: 'PsySuggestionPage' },
    { id: 2, icon: $r('app.media.ic_breath'), title: '呼吸练习', pageName: 'BreathingExercisePage' },
    { id: 3, icon: $r('app.media.ic_saying'), title: '随机心语', pageName: 'RandomSayingPage' },
    { id: 4, icon: $r('app.media.ic_randomAction'), title: '随机行动', pageName: 'RandomActionPage' },
    { id: 5, icon: $r('app.media.ic_soul_question'), title: '灵魂拷问', pageName: 'SoulQuestionPage' },
    { id: 6, icon: $r('app.media.ic_destroy_garbage'), title: '消灭垃圾', pageName: 'DestroyGarbagePage' },
    { id: 7, icon: $r('app.media.ic_fortune'), title: '每日一签', pageName: 'RandomFortunePage' },
    { id: 8, icon: $r('app.media.ic_joke'), title: '来条笑话', pageName: 'RandomJokePage' },
    { id: 9, icon: $r('app.media.ic_pen'), title: '名人名言', pageName: 'RandomQuotePage' },
    { id: 10, icon: $r('app.media.ic_book'), title: '暖心故事', pageName: 'RandomStoryPage' },
    { id: 11, icon: $r('app.media.ic_flow'), title: '心流时刻', pageName: 'FlowMomentPage' },
    { id: 12, icon: $r('app.media.ic_count'), title: '专注计数', pageName: 'FocusCounterPage' },
    { id: 13, icon: $r('app.media.ic_button'), title: '解压按钮', pageName: 'StressReliefPage' },
    { id: 14, icon: $r('app.media.ic_choose'), title: '选择助手', pageName: 'ChoiceAssistantPage' }
  ];

  aboutToAppear() {
    this.loadFavoriteFunctions();
  }

  // 加载收藏的功能列表
  private async loadFavoriteFunctions() {
    try {
      this.prefs = await preference.getPreferences(getContext(this), 'adjust_page_data');
      const favorites = await this.prefs.get(this.FAVORITE_KEY, '[]');
      const favoriteIds: number[] = JSON.parse(favorites as string);

      // 根据收藏的ID过滤功能列表
      this.favoriteFunctions = this.allFunctions.filter(func =>
      favoriteIds.includes(func.id)
      );
    } catch (error) {
      console.error('加载收藏功能失败:', error);
      this.favoriteFunctions = [];
    }
  }

  // 从AdjustPage拷贝的导航函数
  private navigateToPsySugestion(): void {
    this.pageStack.pushPathByName('PsySuggestionPage', false, null)
  }

  private navigateToBreathingExercise(): void {
    this.pageStack.pushPathByName('BreathingExercisePage', false, null)
  }

  private showRandomSaying(): void {
    this.pageStack.pushPathByName('RandomSayingPage', false, null)
  }

  private navigateToSoulQuestion(): void {
    this.pageStack.pushPathByName('SoulQuestionPage', false, null)
  }

  private navigateToRandomAction(): void {
    this.pageStack.pushPathByName('RandomActionPage', false, null)
  }

  private navigateToDestroyGarbage(): void {
    this.pageStack.pushPathByName('DestroyGarbagePage', false, null)
  }

  private navigateToRandomJoke(): void {
    this.pageStack.pushPathByName('RandomJokePage', false, null)
  }

  private navigateToRandomQuote(): void {
    this.pageStack.pushPathByName('RandomQuotePage', false, null)
  }

  private navigateToRandomStory(): void {
    this.pageStack.pushPathByName('RandomStoryPage', false, null)
  }

  private navigateToRandomFortune(): void {
    this.pageStack.pushPathByName('RandomFortunePage', false, null)
  }

  private navigateToFlowMoment(): void {
    this.pageStack.pushPathByName('FlowMomentPage', false, null)
  }

  private navigateToFocusCounter(): void {
    this.pageStack.pushPathByName('FocusCounterPage', false, null)
  }

  private navigateToStressRelief(): void {
    this.pageStack.pushPathByName('StressReliefPage', false, null)
  }

  private navigateToChoiceAssistant(): void {
    this.pageStack.pushPathByName('ChoiceAssistantPage', false, null)
  }

  // 导航到功能页面
  private navigateToFunction(pageName: string) {
    this.showFunctionPanel = false; // 关闭面板

    switch (pageName) {
      case 'PsySuggestionPage':
        this.navigateToPsySugestion();
        break;
      case 'BreathingExercisePage':
        this.navigateToBreathingExercise();
        break;
      case 'RandomSayingPage':
        this.showRandomSaying();
        break;
      case 'SoulQuestionPage':
        this.navigateToSoulQuestion();
        break;
      case 'RandomActionPage':
        this.navigateToRandomAction();
        break;
      case 'DestroyGarbagePage':
        this.navigateToDestroyGarbage();
        break;
      case 'RandomFortunePage':
        this.navigateToRandomFortune();
        break;
      case 'RandomJokePage':
        this.navigateToRandomJoke();
        break;
      case 'RandomQuotePage':
        this.navigateToRandomQuote();
        break;
      case 'RandomStoryPage':
        this.navigateToRandomStory();
        break;
      case 'FlowMomentPage':
        this.navigateToFlowMoment();
        break;
      case 'FocusCounterPage':
        this.navigateToFocusCounter();
        break;
      case 'StressReliefPage':
        this.navigateToStressRelief();
        break;
      case 'ChoiceAssistantPage':
        this.navigateToChoiceAssistant();
        break;
    }
  }

  // 构建悬浮球和标题
  @Builder
  private buildFloatingBall() {
    Column() {

      Column() {
        Text('📘')
          .fontSize(20)  // 设置字体大小而不是宽高
          .textAlign(TextAlign.Center)  // 文本水平居中
      }
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.primary_color'))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)  // 垂直居中
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
      .onClick(() => {
        this.pageStack.pushPathByName('TeachPage', false, null)
      })

      // 悬浮球标题 - 在悬浮球下方
      Text('使用教程')
        .fontSize(12)
        .fontColor($r('app.color.primary_color'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 ,bottom:6})
        .textAlign(TextAlign.Center)

      // 悬浮球按钮
      Column() {
        Text('⭐')
          .fontSize(20)  // 设置字体大小而不是宽高
          .textAlign(TextAlign.Center)  // 文本水平居中
      }
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.primary_color'))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)  // 垂直居中
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
      .onClick(() => {
        this.showFunctionPanel = !this.showFunctionPanel;
      })

      // 悬浮球标题 - 在悬浮球下方
      Text('我的调节包')
        .fontSize(12)
        .fontColor($r('app.color.primary_color'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })
        .textAlign(TextAlign.Center)


    }
    .position({ x: 20, y: '7%' })  // 调整到左上方
    .alignItems(HorizontalAlign.Center)
  }

  // 构建功能面板
  @Builder
  private buildFunctionPanel() {
    if (this.showFunctionPanel) {
      Column() {
        // 功能列表
        Scroll() {
          Column({ space: 8 }) {
            if (this.favoriteFunctions.length > 0) {
              ForEach(this.favoriteFunctions, (func: FunctionItem) => {
                // 每个功能项：图标在上，标题在下
                Column() {
                  Image(func.icon)
                    .width(24)
                    .height(24)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: 4 })

                  Text(func.title)
                    .fontSize(10)
                    .fontColor($r('app.color.text_secondary'))
                    .textAlign(TextAlign.Center)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width(60)  // 宽度比图标大一点
                .height(60)
                .padding(8)
                .backgroundColor($r('app.color.function_item_bg'))  // 浅灰色背景
                .borderRadius(8)
                .onClick(() => {
                  this.navigateToFunction(func.pageName);
                })
              }, (func: FunctionItem) => func.id.toString())
            } else {
              Column() {
                Text('暂无收藏')
                  .fontSize(15)
                  .fontColor($r('app.color.text_hint'))
                  .textAlign(TextAlign.Center)
                Text('可以去调节页面哟~')
                  .fontSize(12)
                  .fontColor($r('app.color.text_hint'))
                  .margin({ top: 4 })
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding(20)
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding(8)

        // 管理按钮
        /*Button('管理')
          .width('80%')
          .height(28)
          .backgroundColor('#8B4513')
          .fontColor('#FFFFFF')
          .fontSize(12)
          .borderRadius(6)
          .margin({ top: 8, bottom: 8 })
          .onClick(() => {
            this.showFunctionPanel = false;
            this.pageStack.pushPathByName('AdjustPage', false, null);
          })*/
      }
      .width(100)  // 面板宽度调小
      .height(280)
      .backgroundColor($r('app.color.panel_background'))  // 浅灰色背景
      .border({ width: 1, color: '#E0E0E0' })
      .borderRadius(10)
      .shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 5 })
      .position({ x: 20, y: '25%' })  // 在悬浮球下方
    }
  }

  // 构建遮罩层
  @Builder
  private buildOverlay() {
    if (this.showFunctionPanel) {
      Blank()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .onClick(() => {
          this.showFunctionPanel = false;
        })
    }
  }

  build() {
    Stack() {
      // 主内容区域
      Column({ space: 20 }) {
        // 顶部欢迎语 - 调整上边距为悬浮球留出空间
        Column() {
          Text('   此刻心情如何？')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary')) // 深棕色
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 30, bottom: 20 })  // 增加上边距为悬浮球留空间

        // 表情区域
        Column() {
          // 心情标签
          Text(this.getMoodLabel())
            .fontSize(20)
            .fontColor($r('app.color.text_primary')) // 深棕色
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 15 })

          // 心情表情组件 - 确保居中
          MoodFace({ moodValue: this.moodValue })
            .margin({ top: 0 })

          // 心情数值
          Text(`${this.moodValue}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary')) // 深棕色
            .margin({ top: 10 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding(20)
        .backgroundColor($r('app.color.card_background')) // 浅米色
        .borderRadius(20)
        .margin({ top: 10, bottom: 20 })
        .shadow({ radius: 15, color: '#20000000', offsetX: 0, offsetY: 5 })

        // 滑动条区域
        Column() {
          Text('调整心情值')
            .fontSize(18)
            .fontColor($r('app.color.text_primary')) // 深棕色
            .margin({ bottom: 15 })

          Slider({
            value: this.moodValue,
            min: 0,
            max: 100,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('90%')
            .height(40)
            .blockColor($r('app.color.primary_color')) // 深棕色
            .selectedColor($r('app.color.accent_color')) // 中棕色
            .trackThickness(10)
            .onChange((value: number) => {
              this.moodValue = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding(20)
        .backgroundColor($r('app.color.card_background')) // 浅米色
        .borderRadius(16)
        .margin({ bottom: 10 })

        // 按钮区域 - 确保在屏幕底部可见
        Column() {
          Button('记录下来！', { type: ButtonType.Capsule })
            .width(140)
            .height(50)
            .backgroundColor($r('app.color.primary_color')) // 深棕色
            .fontColor($r('app.color.button_text')) // 浅黄色
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.pageStack.pushPathByName('AddRecordPage', this.moodValue, true);
            })
        }
        .width('100%')
        .margin({ top: 10, bottom: 30 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .justifyContent(FlexAlign.SpaceBetween)

      // 遮罩层（点击关闭面板）
      this.buildOverlay()

      // 悬浮球
      this.buildFloatingBall()

      // 功能面板
      this.buildFunctionPanel()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary')) // 背景色改为#FFFFCC
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // 根据心情值获取心情标签
  private getMoodLabel(): string {
    if (this.moodValue >= 80) return '非常开心';
    if (this.moodValue >= 60) return '心情愉快';
    if (this.moodValue >= 40) return '平静稳定';
    if (this.moodValue >= 20) return '有些低落';
    return '非常难过';
  }
}