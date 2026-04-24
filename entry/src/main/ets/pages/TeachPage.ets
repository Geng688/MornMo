// src/main/ets/pages/TeachPage.ets
import { AppStorageV2 } from '@kit.ArkUI';

@Component
export struct TeachPage {
  pageStack: NavPathStack = new NavPathStack();

  // 教程章节数据 - 保持不变
  @State tutorialSections: TutorialSection[] = [
    {
      id: 'mood-recording',
      title: '一、心情记录',
      icon: '😊',
      items: [
        {
          id: 'add-mood',
          title: '1. 添加心情',
          content: '滑动首页(即底部导航栏的"心情"页)的滚动条，可以量化选择此刻的心情值，点击"记录下来!"即可进入"添加记录"页面详细记录该条心情。\n\n在"添加记录"页面中，你可以自定义一个此刻的状态、输入此刻想表达的内容、添加图片，点击保存后该条记录将保存在当天。',
          images: [
            $r('app.media.teach_add_mood_1'),
            $r('app.media.teach_add_mood_2'),
          ]
        },
        {
          id: 'query-record',
          title: '2. 查询记录',
          content: '在底部导航栏的"记录"页面，你可以看到你的情绪日历，点击某一天可以查看当天的所有的情绪记录，点击某一条记录可以查看和更新那条记录。',
          images: [
            $r('app.media.teach_query_record_1'),
            $r('app.media.teach_query_record_2'),
            $r('app.media.teach_query_record_3'),
            $r('app.media.teach_query_record_4')
          ]
        },
        {
          id: 'energy-query',
          title: '3. 能量查询',
          content: '在底部导航栏的"记录"页面，你可以点击"查询能量曲线"按钮查询本周或本月的心情值曲线，从而体察情绪变化。',
          images: [
            $r('app.media.teach_energy_query_1')
          ]
        }
      ]
    },
    {
      id: 'adjustment-system',
      title: '二、调节系统',
      icon: '🔄',
      items: [
        {
          id: 'emotion-adjustment',
          title: '1. 情绪调节包',
          content: '点击底部导航栏的"调节"页面，进入调节系统\n\n点击上方的"情绪调节"，你可以看到一个带有丰富功能的情绪调节包，你可以选择里面适合你的调节功能调节情绪。\n\n你可以收藏你喜欢的调节功能，然后在首页(即底部导航栏的"心情"页)的"我的调节包"快捷打开。\n\n特别地,情绪调节包中的"心理暗示"具备卡片展示功能,当你添加心理暗示语句后,可以在手机桌面添加心理暗示语句的卡片，这样打开手机就能看到心理暗示啦~',
          images: [
            $r('app.media.teach_emotion_adjust_1'),
            $r('app.media.teach_emotion_adjust_2'),
            $r('app.media.teach_emotion_adjust_3'),
            $r('app.media.teach_emotion_adjust_4')
          ]
        },
        {
          id: 'knowledge-base',
          title: '2. 心理测评、心理知识、哲学知识、情绪课堂',
          content: '点击上方的"心理测评"，你可以做一些热门的有趣的心理测评量表(比如MBTI、霍兰德职业测试等等)。注意，测评结果仅供参考，并非绝对。\n\n此外，点击上方其他选项，还有心理知识、哲学知识、情绪课堂等诸多有助于调节心情的知识科普。',
          images: [
            $r('app.media.teach_knowledge_base_1')
          ]
        }
      ]
    },
    {
      id: 'time-mail',
      title: '三、时光邮件',
      icon: '✉️',
      items: [
        {
          id: 'time-mail-feature',
          title: '时光邮件功能',
          content: '时光邮件是"心晨"的特色功能之一，用户可以点击"写邮件"按钮写一封邮件给未来的自己，时间到了之后该邮件会在收件箱中出现，从而实现"跨时空对话"。\n\n时光邮件是"心晨"的特色功能之一，用户可以点击"写邮件"按钮写一封邮件给未来的自己，时间到了之后该邮件会在收件箱中出现，从而实现"跨时空对话"~',
          images: [
            $r('app.media.teach_time_mail_1'),
            $r('app.media.teach_time_mail_2'),
            $r('app.media.teach_time_mail_3'),
            $r('app.media.teach_time_mail_4')
          ]
        }
      ]
    },{
    id: 'mood-garden',
    title: '四、心情花园',
    icon: '🌱',
    items: [
      {
        id: 'garden-feature',
        title: '心情花园',
        content: '用户可以通过浇灌开心水来种植开心花。\n\n开心水的获取方式：\n1、每保存一条心情记录，获得1点开心水；\n2、每添加一条心理暗示，获得3点开心水；\n3、每发送一封时光邮件，获得5点开心水；\n\n每消耗1点开心水，开心花的生长值将增加5点，当生长值达到100点，开心花就会盛放。此时可以点击"种新花"重新种一盆新的开心花。',
        images: [
          $r('app.media.teach_garden')
        ]
      }
    ]
  }
  ];

  @State currentSectionIndex: number = 0;
  @State currentItemIndex: number = 0;
  @State showDetailModal: boolean = false;
  @State currentImageIndex: number = 0;

  aboutToAppear() {
    this.currentSectionIndex = 0;
    this.currentItemIndex = 0;
    this.currentImageIndex = 0;
  }

  // 返回功能汇总页面
  private backToMainPage() {
    this.pageStack.pop();
  }

  // 显示教程详情
  private showTutorialDetail(sectionIndex: number, itemIndex: number) {
    this.currentSectionIndex = sectionIndex;
    this.currentItemIndex = itemIndex;
    this.currentImageIndex = 0;
    this.showDetailModal = true;
  }

  // 切换到下一张图片
  private nextImage() {
    const images = this.getCurrentImages();
    if (images.length > 0 && this.currentImageIndex < images.length - 1) {
      this.currentImageIndex++;
    }
  }

  // 切换到上一张图片
  private prevImage() {
    if (this.currentImageIndex > 0) {
      this.currentImageIndex--;
    }
  }

  // 获取当前章节
  private getCurrentSection(): TutorialSection {
    return this.tutorialSections[this.currentSectionIndex];
  }

  // 获取当前项目
  private getCurrentItem(): TutorialItem {
    return this.getCurrentSection().items[this.currentItemIndex];
  }

  // 获取当前图片数组
  private getCurrentImages(): Resource[] {
    const currentItem = this.getCurrentItem();
    return currentItem.images || [];
  }

  // 检查是否有图片
  private hasImages(): boolean {
    return this.getCurrentImages().length > 0;
  }

  // 获取当前图片数量
  private getCurrentImagesCount(): number {
    return this.getCurrentImages().length;
  }

  // 构建教程章节列表
  @Builder
  private buildTutorialList() {
    Scroll() {
      Column() {
        ForEach(this.tutorialSections, (section: TutorialSection, sectionIndex: number) => {
          // 章节标题
          Row() {
            Text(section.icon)
              .fontSize(24)
              .margin({ right: 12 })

            Text(section.title)
              .fontSize(18)
              .fontColor($r('app.color.teach_section_title'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 16, bottom: 12 })
          .border({ width: { bottom: 1 }, color: $r('app.color.teach_section_border') })

          // 章节内容项
          Column() {
            ForEach(section.items, (item: TutorialItem, itemIndex: number) => {
              Row() {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(16)
                    .fontColor($r('app.color.teach_item_title'))
                    .fontWeight(FontWeight.Medium)

                  Text(item.content.substring(0, 60) + '...')
                    .fontSize(14)
                    .fontColor($r('app.color.teach_item_content'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 显示图片数量提示
                  if (item.images && item.images.length > 0) {
                    Text(`包含 ${item.images.length} 张图片`)
                      .fontSize(12)
                      .fontColor($r('app.color.teach_image_count'))
                  }
                }
                .layoutWeight(1)
                .margin({ right: 12 })

                Text('→')
                  .width(20)
                  .height(20)
                  .fontColor($r('app.color.teach_arrow'))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.teach_item_background'))
              .borderRadius(8)
              .border({ width: 1, color: $r('app.color.teach_item_border') })
              .margin({ bottom: 8 })
              .onClick(() => {
                this.showTutorialDetail(sectionIndex, itemIndex);
              })
            })
          }
          .margin({ bottom: 20 })
        })
      }
      .padding(20)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .width('100%')
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)
  }

  // 构建教程详情弹窗
  @Builder
  private buildTutorialDetailModal() {
    if (this.showDetailModal) {
      Stack() {
        // 半透明背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.teach_modal_mask'))
          .onClick(() => {
            this.showDetailModal = false;
          })

        // 教程详情容器
        Column() {
          // 顶部标题栏
          Row() {
            Text(`${this.getCurrentSection().icon} ${this.getCurrentSection().title}`)
              .fontSize(20)
              .fontColor($r('app.color.teach_modal_title'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button('×')
              .fontSize(16)
              .fontColor($r('app.color.teach_modal_close'))
              .backgroundColor('transparent')
              .width(40)
              .height(40)
              .borderRadius(20)
              .onClick(() => {
                this.showDetailModal = false;
              })
          }
          .width('100%')
          .padding({ bottom: 16 })
          .border({ width: { bottom: 1 }, color: $r('app.color.teach_modal_divider') })

          // 教程内容区域
          Scroll() {
            Column() {
              // 教程标题
              Text(this.getCurrentItem().title)
                .fontSize(18)
                .fontColor($r('app.color.teach_modal_subtitle'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 })
                .textAlign(TextAlign.Center)

              // 教程内容文本
              Text(this.getCurrentItem().content)
                .fontSize(16)
                .fontColor($r('app.color.teach_modal_content'))
                .lineHeight(24)
                .margin({ bottom: 16 })
                .textAlign(TextAlign.Start)

              // 多张图片显示区域
              if (this.hasImages()) {
                Column() {
                  // 图片显示区域
                  Stack({ alignContent: Alignment.Center }) {
                    // 当前图片
                    Image(this.getCurrentImages()[this.currentImageIndex])
                      .width('100%')
                      .height('100%')
                      .objectFit(ImageFit.Contain)
                      .borderRadius(8)
                      .margin({ bottom: 8 })

                    // 图片导航按钮（多张图片时显示）
                    if (this.getCurrentImagesCount() > 1) {
                      Row() {
                        // 上一张按钮
                        Button('<')
                          .fontSize(16)
                          .fontColor($r('app.color.teach_image_nav_text'))
                          .backgroundColor($r('app.color.teach_image_nav_bg'))
                          .width(40)
                          .height(40)
                          .borderRadius(20)
                          .enabled(this.currentImageIndex > 0)
                          .onClick(() => {
                            this.prevImage();
                          })

                        Blank()

                        // 下一张按钮
                        Button('>')
                          .fontSize(16)
                          .fontColor($r('app.color.teach_image_nav_text'))
                          .backgroundColor($r('app.color.teach_image_nav_bg'))
                          .width(40)
                          .height(40)
                          .borderRadius(20)
                          .enabled(this.currentImageIndex < this.getCurrentImagesCount() - 1)
                          .onClick(() => {
                            this.nextImage();
                          })
                      }
                      .width('100%')
                      .padding({ left: 16, right: 16 })
                    }

                    // 图片指示器（多张图片时显示）
                    if (this.getCurrentImagesCount() > 1) {
                      Row() {
                        ForEach(Array.from({ length: this.getCurrentImagesCount() }), (item: undefined, index: number) => {
                          Circle()
                            .width(6)
                            .height(6)
                            .fill(index === this.currentImageIndex ?
                            $r('app.color.teach_image_indicator_active') :
                            $r('app.color.teach_image_indicator_inactive'))
                            .margin({ right: 4 })
                        })
                      }
                      .margin({ top: 180 })
                    }
                  }
                  .height('100%')
                  .width('100%')

                  // 图片计数
                  Text(`图片 ${this.currentImageIndex + 1}/${this.getCurrentImagesCount()}`)
                    .fontSize(12)
                    .fontColor($r('app.color.teach_image_count'))
                    .margin({ bottom: 16 })
                }
                .width('100%')
                .margin({ bottom: 16 })
              }
            }
            .padding(16)
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .layoutWeight(1)

          // 底部导航
          Row({ space: 12 }) {
            // 上一项按钮
            Button('上一项')
              .fontSize(14)
              .fontColor($r('app.color.teach_button_prev_text'))
              .backgroundColor($r('app.color.teach_button_prev_bg'))
              .border({ width: 1, color: $r('app.color.teach_button_prev_border') })
              .borderRadius(6)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .enabled(this.currentItemIndex > 0)
              .onClick(() => {
                if (this.currentItemIndex > 0) {
                  this.currentItemIndex--;
                  this.currentImageIndex = 0;
                }
              })

            Blank()

            // 下一项按钮
            Button('下一项')
              .fontSize(14)
              .fontColor($r('app.color.teach_button_next_text'))
              .backgroundColor($r('app.color.teach_button_next_bg'))
              .borderRadius(6)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .enabled(this.currentItemIndex < this.getCurrentSection().items.length - 1)
              .onClick(() => {
                if (this.currentItemIndex < this.getCurrentSection().items.length - 1) {
                  this.currentItemIndex++;
                  this.currentImageIndex = 0;
                }
              })
          }
          .width('100%')
          .padding({ top: 16 })
        }
        .width('85%')
        .height('70%')
        .backgroundColor($r('app.color.teach_modal_bg'))
        .borderRadius(16)
        .padding(20)
        .shadow({
          radius: 20,
          color: $r('app.color.teach_modal_shadow'),
          offsetX: 0,
          offsetY: 5
        })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
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
            .onClick(() => this.backToMainPage())
            .fillColor($r('app.color.teach_nav_icon'))

          Text('应用使用教程')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.teach_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.teach_nav_bg'))
        .border({ width: { bottom: 1 }, color: $r('app.color.teach_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 教程内容区域
        this.buildTutorialList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.teach_background'))

      // 教程详情弹窗
      this.buildTutorialDetailModal()
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

// 教程数据结构定义
interface TutorialSection {
  id: string;
  title: string;
  icon: string;
  items: TutorialItem[];
}

interface TutorialItem {
  id: string;
  title: string;
  content: string;
  images?: Resource[];
}

@Builder
export function TeachPageBuilder() {
  TeachPage()
}