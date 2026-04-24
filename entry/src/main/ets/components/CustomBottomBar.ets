// components/CustomBottomBar.ets
@Component
export struct CustomBottomBar {
  @Link activeMenu: string;

  // 使用公共属性存储回调函数
  navigateToFunctionPage: () => void = () => {};
  navigateToHomePage: () => void = () => {};
  navigateToRecordPage: () => void = () => {};

  build() {
    Column() {
      Row({ space: 0 }) {
        // 调节区域
        Column({ space: 5 }) {
          Image($r('app.media.ic_adjust'))
            .width(this.activeMenu === 'function' ? 42 : 35)
            .height(this.activeMenu === 'function' ? 30 : 25)
            .animation({ duration: 200, curve: Curve.EaseInOut })

          Text('调节')
            .fontSize(18)
            .fontColor('#666666')
        }
        .width('33%')
        .height(50)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.navigateToFunctionPage())

        // 主页区域
        Column({ space: 3 }) {
          Image($r('app.media.app_logo'))
            .width(50)
            .height(50)
            .borderRadius(15)
        }
        .width('34%')
        .height(50)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.navigateToHomePage())

        // 记录区域
        Column({ space: 3 }) {
          Image($r('app.media.ic_record'))
            .width(this.activeMenu === 'record' ? 42 : 35)
            .height(this.activeMenu === 'record' ? 30 : 25)
            .animation({ duration: 200, curve: Curve.EaseInOut })

          Text('记录')
            .fontSize(18)
            .fontColor('#666666')
        }
        .width('33%')
        .height(50)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.navigateToRecordPage())
      }
      .width('100%')
      .height(60)
      .backgroundColor('#FFFF52')
      .border({ width: 1, color: '#EEEEEE' })
    }
    .width('100%')
    .height(50)
    .position({bottom:0})
  }
}