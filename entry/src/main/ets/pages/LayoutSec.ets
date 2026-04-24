import { AdjustPage } from "./AdjustPage";
import { AppStorageV2 } from "@kit.ArkUI";
import { PsySuggestionPage } from "./PsySuggestionPage";
import { RandomSayingPage } from "./RandomSayingPage";
import { PsyTestPage } from "./PsyTestPage";
import { PsyKnowledgePage } from "./PsyKnowledgePage";
import { PhilosophyPage } from "./PhilosophyPage";
import { EmotionClassPage } from "./EmotionClassPage";

@Builder
export function LayoutSecBuilder(){
  LayoutSec()
}

@ComponentV2
export struct LayoutSec {
  @Local currentIndex: number = 0
  tabData: string[] = ['情绪调节', '心理测评', '心理知识', '哲学知识', '情绪课堂'] // 增加两个选项

  @Builder
  tabBuilder(item: string, index: number) {
    Column() {
      Text(item)
        .fontSize(16)
        .fontColor(this.currentIndex === index ? $r('app.color.layout_tab_active_text') : $r('app.color.layout_tab_inactive_text'))
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .margin({ bottom: 8 })

      // 底部指示条
      if (this.currentIndex === index) {
        Divider()
          .width(40)
          .height(3)
          .color($r('app.color.layout_tab_indicator'))
          .margin({ top: 4 })
      }
    }
    .padding(10)
    .onClick(() => {
      this.currentIndex = index;
    })
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Tabs({ index: this.currentIndex, barPosition: BarPosition.Start }) {
          TabContent() {
            if (this.currentIndex === 0) {
              AdjustPage()
            }
          }.tabBar(this.tabBuilder(this.tabData[0], 0))

          TabContent() {
            if (this.currentIndex === 1) {
              PsyTestPage()
            }
          }.tabBar(this.tabBuilder(this.tabData[1], 1))

          TabContent() {
            if (this.currentIndex === 2) {
              PsyKnowledgePage()
            }
          }.tabBar(this.tabBuilder(this.tabData[2], 2))

          // 新增哲学知识页面
          TabContent() {
            if (this.currentIndex === 3) {
              PhilosophyPage()
            }
          }.tabBar(this.tabBuilder(this.tabData[3], 3))

          // 新增情绪课堂页面
          TabContent() {
            if (this.currentIndex === 4) {
              EmotionClassPage()
            }
          }.tabBar(this.tabBuilder(this.tabData[4], 4))
        }
        .scrollable(true)
        .barMode(BarMode.Scrollable)
        .animationDuration(0)
        .backgroundColor($r('app.color.layout_tab_background'))
        .edgeEffect(EdgeEffect.Spring)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.layout_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
  }
}