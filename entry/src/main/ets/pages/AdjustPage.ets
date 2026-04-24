// pages/adjust/AdjustPage.ets
import { AppStorageV2 } from "@kit.ArkUI";
import preference from '@ohos.data.preferences';

interface FunctionCard {
  id: number;
  icon: Resource;
  title: string;
  description: string;
  colors: string[];
  onClick: () => void;
}

@Component
export struct AdjustPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!

  // 当前页码
  @State currentPage: number = 0;
  // 收藏的功能ID列表
  @State favoriteIds: number[] = [];
  // Preferences实例
  private prefs: preference.Preferences | null = null;

  // 每页卡片数量
  private readonly cardsPerPage: number = 6;
  // Preferences键名
  private readonly FAVORITE_KEY: string = 'favorite_functions';

  aboutToAppear() {
    this.loadFavorites();
  }
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

  // 加载收藏列表
  private async loadFavorites() {
    try {
      // 使用正确的上下文获取方式
      this.prefs = await preference.getPreferences(getContext(this), 'adjust_page_data');
      // 读取收藏列表
      const favorites = await this.prefs.get(this.FAVORITE_KEY, '[]');
      console.log('从preference读取的收藏数据:', favorites);
      this.favoriteIds = JSON.parse(favorites as string);
      console.log('解析后的收藏ID列表:', this.favoriteIds);
    } catch (error) {
      console.error('加载收藏列表失败:', error);
      this.favoriteIds = [];
    }
  }

  // 切换收藏状态
  private async toggleFavorite(id: number) {
    try {
      const index = this.favoriteIds.indexOf(id);

      if (index > -1) {
        // 取消收藏
        this.favoriteIds.splice(index, 1);
        console.log('取消收藏功能ID:', id);
      } else {
        // 添加收藏
        this.favoriteIds.push(id);
        console.log('添加收藏功能ID:', id);
      }

      // 保存到Preferences
      if (this.prefs) {
        const idsString = JSON.stringify(this.favoriteIds);
        console.log('保存到preference的数据:', idsString);
        await this.prefs.put(this.FAVORITE_KEY, idsString);
        await this.prefs.flush();
        console.log('收藏状态已保存');
      }

      // 更新状态
      this.favoriteIds = [...this.favoriteIds];
    } catch (error) {
      console.error('更新收藏状态失败:', error);
    }
  }

  // 检查是否已收藏
  private isFavorite(id: number): boolean {
    const isFav = this.favoriteIds.includes(id);
    console.log(`检查功能ID ${id} 是否已收藏:`, isFav);
    return isFav;
  }

  // 其他方法保持不变...
  // [这里保留所有原有的导航方法和其他方法]

  // 获取所有功能卡片数据
  private getFunctionCards(): FunctionCard[] {
    return [
      {
        id: 1,
        icon: $r('app.media.ic_suggestion'),
        title: '心理暗示',
        description: '通过积极暗示调整心态，增强自信心',
        colors: ['#F3E5F5', '#E1BEE7'],
        onClick: (): void => this.navigateToPsySugestion()
      },
      {
        id: 2,
        icon: $r('app.media.ic_breath'),
        title: '呼吸练习',
        description: '通过呼吸调节情绪，缓解焦虑压力',
        colors: ['#E0F7FA', '#B2EBF2'],
        onClick: (): void => this.navigateToBreathingExercise()
      },
      {
        id: 3,
        icon: $r('app.media.ic_saying'),
        title: '随机心语',
        description: '获取暖心语录，点亮你的心情',
        colors: ['#F1F8E9', '#DCEDC8'],
        onClick: (): void => this.showRandomSaying()
      },
      {
        id: 4,
        icon: $r('app.media.ic_randomAction'),
        title: '随机行动',
        description: '获取有趣的小任务，丰富你的生活',
        colors: ['#FFF3E0', '#FFE0B2'],
        onClick: (): void => this.navigateToRandomAction()
      },
      {
        id: 5,
        icon: $r('app.media.ic_soul_question'),
        title: '灵魂拷问',
        description: '深度思考问题，探索内心世界',
        colors: ['#E8F5E9', '#C8E6C9'],
        onClick: (): void => this.navigateToSoulQuestion()
      },
      {
        id: 6,
        icon: $r('app.media.ic_destroy_garbage'),
        title: '消灭垃圾',
        description: '清理负面情绪，释放心理空间',
        colors: ['#F5F5F5', '#E0E0E0'],
        onClick: (): void => this.navigateToDestroyGarbage()
      },
      {
        id: 7,
        icon: $r('app.media.ic_fortune'),
        title: '每日一签',
        description: '随机签文，指引方向',
        colors: ['#F3E5F5', '#E1BEE7'],
        onClick: (): void => this.navigateToRandomFortune()
      },
      {
        id: 8,
        icon: $r('app.media.ic_joke'),
        title: '来条笑话',
        description: '轻松一笑，缓解压力',
        colors: ['#FFF8E1', '#FFECB3'],
        onClick: (): void => this.navigateToRandomJoke()
      },
      {
        id: 9,
        icon: $r('app.media.ic_pen'),
        title: '名人名言',
        description: '智慧箴言，启迪心灵',
        colors: ['#E3F2FD', '#BBDEFB'],
        onClick: (): void => this.navigateToRandomQuote()
      },
      {
        id: 10,
        icon: $r('app.media.ic_book'),
        title: '暖心故事',
        description: '聆听小故事，放松心情',
        colors: ['#E8F5E9', '#C8E6C9'],
        onClick: (): void => this.navigateToRandomStory()
      },
      {
        id: 11,
        icon: $r('app.media.ic_flow'),
        title: '心流时刻',
        description: '进入专注状态，提升工作效率',
        colors: ['#E1F5FE', '#B3E5FC'],
        onClick: (): void => this.navigateToFlowMoment()
      },
      {
        id: 12,
        icon: $r('app.media.ic_count'),
        title: '专注计数',
        description: '番茄工作法，提升专注力',
        colors: ['#F1F8E9', '#DCEDC8'],
        onClick: (): void => this.navigateToFocusCounter()
      },
      {
        id: 13,
        icon: $r('app.media.ic_button'),
        title: '解压按钮',
        description: '释放压力，放松身心',
        colors: ['#FFF3E0', '#FFE0B2'],
        onClick: (): void => this.navigateToStressRelief()
      },
      {
        id: 14,
        icon: $r('app.media.ic_choose'),
        title: '选择助手',
        description: '帮助决策，减少选择困难',
        colors: ['#F3E5F5', '#E1BEE7'],
        onClick: (): void => this.navigateToChoiceAssistant()
      }
    ];
  }

  // 获取当前页的卡片
  private getCurrentPageCards(): FunctionCard[] {
    const allCards = this.getFunctionCards();
    const startIndex = this.currentPage * this.cardsPerPage;
    return allCards.slice(startIndex, startIndex + this.cardsPerPage);
  }

  // 获取总页数
  private getTotalPages(): number {
    const allCards = this.getFunctionCards();
    return Math.ceil(allCards.length / this.cardsPerPage);
  }

  // 上一页
  private prevPage(): void {
    if (this.currentPage > 0) {
      this.currentPage--;
    }
  }

  // 下一页
  private nextPage(): void {
    if (this.currentPage < this.getTotalPages() - 1) {
      this.currentPage++;
    }
  }

  // 构建功能卡片
  @Builder
  private buildFunctionCard(
    id: number,
    icon: Resource,
    title: string,
    description: string,
    colors: string[],
    onClick: () => void
  ): void {
    Stack({ alignContent: Alignment.TopStart }) {
      // 卡片内容
      Column() {
        Row({ space: 8 }) { // 减少间距
          // 图标区域 - 缩小尺寸
          Column() {
            Image(icon)
              .width(28) // 缩小图标尺寸
              .height(28)
              .objectFit(ImageFit.Contain)
          }
          .width(32) // 固定图标容器宽度
          .height(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 4 })

          // 文字区域 - 增加权重
          Column({ space: 4 }) { // 减少内部间距
            Text(title)
              .fontSize(15) // 稍微缩小字体，保持清晰度
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(description)
              .fontSize(13) // 缩小描述字体
              .fontColor('#555555')
              .maxLines(5) // 限制行数，避免占用过多空间
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(16) // 调整行高
          }
          .layoutWeight(1) // 文字区域占据剩余空间
          .margin({ left: 4, top: 4 }) // 调整边距
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 }) // 调整内边距
      }
      .width('100%')
      .height('100%')

      // 收藏按钮 - 调整位置和大小
      Row() {
        Text(this.isFavorite(id) ? '⭐' : '☆')
          .fontSize(18) // 缩小收藏图标
          .fontColor(this.isFavorite(id) ? $r('app.color.favorite_active') : $r('app.color.favorite_inactive'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            console.log('点击收藏按钮，功能ID:', id);
            this.toggleFavorite(id);
          })
      }
      .position({ x: '10%', y: '70%' }) // 调整位置到右下角
      .width(26) // 缩小按钮容器
      .height(26)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(130) // 稍微降低卡片高度
    .borderRadius(15)
    .linearGradient({
      direction: GradientDirection.Left,
      repeating: true,
      colors: [
        [colors[0], 0.0],
        [colors[1], 1.0]
      ]
    })
    .onClick(onClick)
    .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
  }

  build() {
    Column() {
      // 顶部标题
      Text('情绪调节包')
        .fontSize(30)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 20 })

      // 卡片区域
      Column() {
        // 当前页卡片
        Grid() {
          ForEach(this.getCurrentPageCards(), (card: FunctionCard) => {
            GridItem() {
              this.buildFunctionCard(
                card.id,
                card.icon,
                card.title,
                card.description,
                card.colors,
                card.onClick
              )
            }
            .margin(5)
          }, (card: FunctionCard) => card.title)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(5)
        .rowsGap(15)
        .width('100%')
        .padding(15)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // 分页控制
        Row({ space: 20 }) {
          Button('上一页')
            .width(100)
            .height(40)
            .backgroundColor(this.currentPage > 0 ? $r('app.color.button_primary') : $r('app.color.button_disabled'))
            .fontColor(this.currentPage > 0 ? $r('app.color.button_primary_text') : $r('app.color.button_disabled_text'))
            .borderRadius(20)
            .onClick(() => this.prevPage())
            .enabled(this.currentPage > 0)

          Text(`${this.currentPage + 1}/${this.getTotalPages()}`)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))

          Button('下一页')
            .width(100)
            .height(40)
            .backgroundColor(this.currentPage < this.getTotalPages() - 1 ? $r('app.color.button_primary') : $r('app.color.button_disabled'))
            .fontColor(this.currentPage < this.getTotalPages() - 1 ? $r('app.color.button_primary_text') : $r('app.color.button_disabled_text'))
            .borderRadius(20)
            .onClick(() => this.nextPage())
            .enabled(this.currentPage < this.getTotalPages() - 1)
        }
        .width('100%')
        .padding(15)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('80%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(20)
      .shadow({ radius: 10, color: '#20000000', offsetX: 0, offsetY: 5 })
      .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.background_primary'))
    .padding(20)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@Builder
export function AdjustPageBuilder(param: object) {
  AdjustPage()
}