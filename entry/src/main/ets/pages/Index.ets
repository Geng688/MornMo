// pages/Index.ets
import {AppStorageV2} from '@kit.ArkUI'

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack,'nacStack',()=>new NavPathStack())!

  build() {
    Navigation(this.pageStack) {
      // 初始页面为空，由onAppear中跳转到BeginningPage
    }
    .onAppear(() => {
      // 应用启动时跳转到首页
      this.pageStack.pushPathByName('BeginningPage',null,false);
    })
    .hideNavBar(true)
  }
}