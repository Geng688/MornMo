import { preferences } from "@kit.ArkData";

// 定义心理暗示数据结构
interface SuggestionData {
  content: string;
  createdTime: number;
}

@Builder
export function BeginningPageBuilder() {
  BeginningPage()
}

@ComponentV2
struct BeginningPage {
  pageStack: NavPathStack = new NavPathStack();
  @Local primaryContent: string = '心晨一下，即刻放晴'; // 用于显示的文本
  private timerId: number = -1; // 存储定时器ID
  private prefs: preferences.Preferences | null = null; // Preferences实例
  private readonly prefsOptions: preferences.Options = { name: 'PsySuggestionsPrefs' }; // Preferences配置

  aboutToAppear(): void {
    // 初始化Preferences并加载随机心理暗示
    this.initPreferences();

    // 设置定时器，3秒后跳转到主页面
    this.timerId = setTimeout(() => {
      this.pageStack.replacePathByName("Layout", null, false);
      this.timerId = -1; // 执行后重置ID
    }, 3000);
  }

  // 初始化Preferences
  private initPreferences() {
    try {
      const context = getContext(this);
      // 获取Preferences实例
      this.prefs = preferences.getPreferencesSync(context, this.prefsOptions);

      // 加载随机心理暗示
      this.loadRandomSuggestion();
    } catch (error) {
      console.error('Preferences初始化失败:', error);
      this.primaryContent = '保持积极心态！';
    }
  }

  // 加载随机心理暗示
  private loadRandomSuggestion() {
    if (!this.prefs) {
      this.primaryContent = '积极思考，乐观面对！';
      return;
    }

    try {
      // 获取所有数据
      const allData = this.prefs.getAllSync();
      const suggestions: string[] = [];

      // 收集所有心理暗示语句
      Object.entries(allData).forEach((entry: [string, preferences.ValueType]) => {
        const key = entry[0];
        const value = entry[1];

        if (key.startsWith('suggestion_')) {
          try {
            const parsedData = JSON.parse(value as string) as SuggestionData;
            suggestions.push(parsedData.content);
          } catch (e) {
            console.warn(`解析心理暗示数据失败: ${key}`, e);
          }
        }
      });

      // 随机选择一条语句
      if (suggestions.length > 0) {
        const randomIndex = Math.floor(Math.random() * suggestions.length);
        this.primaryContent = suggestions[randomIndex];
      } else {
        this.primaryContent = '心晨一下，即刻放晴';
      }
    } catch (error) {
      console.error('读取心理暗示失败:', error);
      this.primaryContent = '保持积极心态！';
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          Text(this.primaryContent)
            .fontSize(30) // 增大字体大小
            .fontWeight(FontWeight.Bold) // 加粗
            .fontColor($r('app.color.splash_text'))
            .textAlign(TextAlign.Center)
            .margin({ top: 20, left: 20, right: 20 })
            .width('100%')
            .maxLines(5) // 最多显示5行
            .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超出部分显示省略号
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .linearGradient({
          direction: GradientDirection.Left,
          repeating: true,
          colors: [[$r('app.color.splash_gradient_start'), 0.0], [$r('app.color.splash_gradient_end'), 1.0]]
        })

        // "跳过"按钮
        Button('跳过')
          .backgroundColor($r('app.color.splash_button_background'))
          .fontColor($r('app.color.splash_button_text'))
          .fontSize(16)
          .width(80)
          .height(40)
          .margin(15)
          .onClick(() => {
            // 清除定时器（如果存在）
            if (this.timerId !== -1) {
              clearTimeout(this.timerId);
              this.timerId = -1;
            }
            this.pageStack.replacePathByName("Layout", null, false);
          })
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}