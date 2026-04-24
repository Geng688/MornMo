// 创建LocalStorage实例
let storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct PsySuggestionWidgetCard {
  // 接收从EntryFormAbility传递过来的随机心理暗示
  @LocalStorageProp('randomContent') randomContent: string = '加载中...';
  @LocalStorageProp('updateTime') updateTime: string = '';
  @State isRefreshing: boolean = false; // 添加刷新状态

  // 现有属性
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  readonly message: string = 'add detail';
  readonly fullWidthPercent: string = '100%';
  readonly fullHeightPercent: string = '100%';

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        message: this.message
      }
    }) {
      Row() {
        Column() {
          // 显示随机心理暗示
          Text(this.randomContent)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .textAlign(TextAlign.Start)
            .maxLines(5)
            .maxFontSize(20)
            .minFontSize(12)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })
            .padding({left:10,right:10})

          // 显示更新时间（可选）
          Text(this.updateTime ? `更新于: ${this.updateTime}` : '')
          //Text('(每早6:00自动更新 心理暗示 ~)')
            .fontSize(11)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
        }
        .width(this.fullWidthPercent)
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .height(this.fullHeightPercent)
      .linearGradient({
        direction: GradientDirection.Left, // 渐变方向
        repeating: true, // 渐变颜色是否重复
        colors: [['#fc5f3a', 0.0], ['#ebc360', 1.0]] // 数组末尾元素占比小于1时满足重复着色效果
      })
      .onClick(() => {
        // 点击卡片可以刷新随机内容
        this.refreshCard();
      })
    }
  }

  // 刷新卡片内容
  private refreshCard() {
    console.info('用户点击卡片请求刷新');
  }
}