//AddRecordPage.ets
import promptAction from '@ohos.promptAction';
import { RecordDatabase } from '../database/RecordDatabase';
import { RecordDataForCreation } from '../models/RecordDataForCreation';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { preferences } from '@kit.ArkData';

@Builder
export function AddRecordPageBuilder() {
  AddRecordPage()
}

// 图片选择器接口
interface PhotoSelectOptions {
  MIMEType: photoAccessHelper.PhotoViewMIMETypes;
  maxSelectNumber: number;
}


// 表情选项接口
interface EmojiOption {
  value: string;
  label: string;
}

interface SelectOption {
  value: string;
  label: string;
}

// 修改 MoodValueParam 接口，使属性可选
interface MoodValueParam {
  moodValue?: number;
}

@ComponentV2
export struct AddRecordPage {
  pageStack: NavPathStack = new NavPathStack()
  @Local moodValue: number = 100;
  @Local showStatusModal: boolean = false; // 是否显示状态设置弹窗
  @Local contentText: string = ""; // 正文内容
  @Local showSaveModal: boolean = false; // 是否显示保存确认弹窗
  @Local selectedImages: string[] = []; // 新增：选择的图片
  @Local isSelectingImages: boolean = false;
  // 新增状态变量
  @Local showImagePreview: boolean = false;
  @Local previewImageUrl: string = '';
  @Local previewImageIndex: number = 0;
  private recordDb: RecordDatabase = RecordDatabase.getInstance();
  // 表情选项数组
  private emojiOptions: EmojiOption[] = [
    { value: '😊', label: '开心' },
    { value: '😂', label: '大笑' },
    { value: '😍', label: '喜爱' },
    { value: '😭', label: '哭泣' },
    { value: '😡', label: '生气' },
    { value: '🥺', label: '恳求' },
    { value: '🥰', label: '幸福' },
    { value: '🤔', label: '思考' },
    { value: '😴', label: '困倦' },
    { value: '😇', label: '天真' },
    { value: '🤩', label: '兴奋' },
    { value: '😱', label: '惊讶' },
    { value: '🤗', label: '拥抱' },
    { value: '🤑', label: '富有' },
    { value: '🤒', label: '生病' },
    { value: '🤠', label: '牛仔' },
    { value: '😈', label: '调皮' },
    { value: '👻', label: '鬼魂' },
    { value: '💩', label: '便便' },
    { value: '🤖', label: '机器人' }
  ];
  // 当前选中的表情索引
  @Local selectedEmojiIndex: number = -1;
  @Local statusText: string = '状态';
  @Local statusEmoji: string = '+';

  // 定义preferences的key
  private WATER_KEY: string = 'water_value';
  private PREFERENCES_NAME: string = 'mood_garden_data';

  aboutToAppear() {
    this.recordDb.initialize(getContext(this));

    // 使用定义的接口类型
    const param: MoodValueParam = this.pageStack.getParamByName('AddRecordPage') as MoodValueParam;
    if (param && param.moodValue !== undefined) {
      this.moodValue = param.moodValue;
    }
  }

  // 根据开心值选择合适的表情图片
  private getFaceImage(): Resource {
    if (this.moodValue > 70) {
      return $r('app.media.happy');
    } else if (this.moodValue > 30) {
      return $r('app.media.bland');
    } else {
      return $r('app.media.unhappy');
    }
  }

  // 图片选择方法
  private async selectImages(): Promise<void> {
    if (this.isSelectingImages) {
      return;
    }

    this.isSelectingImages = true;
    try {
      const photoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 5
      };

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedImages = photoSelectResult.photoUris;
        promptAction.showToast({
          message: `已选择 ${photoSelectResult.photoUris.length} 张图片`,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      promptAction.showToast({ message: '选择图片失败', duration: 2000 });
    } finally {
      this.isSelectingImages = false;
    }
  }

  // 清空已选图片
  private clearSelectedImages(): void {
    this.selectedImages = [];
    // 如果正在预览图片，关闭预览
    if (this.showImagePreview) {
      this.showImagePreview = false;
    }
    promptAction.showToast({ message: '已清空图片', duration: 2000 });
  }

  // 删除单张图片
  private removeImage(index: number): void {
    if (index >= 0 && index < this.selectedImages.length) {
      const newImages = [...this.selectedImages];
      newImages.splice(index, 1);
      this.selectedImages = newImages;
      // 如果删除的是当前预览的图片，关闭预览
      if (this.showImagePreview) {
        if (this.previewImageIndex === index) {
          // 如果删除的是当前预览的图片
          if (newImages.length === 0) {
            // 没有图片了，关闭预览
            this.showImagePreview = false;
          } else if (this.previewImageIndex >= newImages.length) {
            // 删除的是最后一张，显示前一张
            this.previewImageIndex = newImages.length - 1;
            this.previewImageUrl = newImages[this.previewImageIndex];
          } else {
            // 显示同一位置的图片（索引自动前移）
            this.previewImageUrl = newImages[this.previewImageIndex];
          }
        } else if (this.previewImageIndex > index) {
          // 删除的是当前预览图片之前的图片，调整索引
          this.previewImageIndex--;
        }
      }

      promptAction.showToast({
        message: '图片已删除',
        duration: 1500
      });
    }
  }

  // 计算面部颜色
  private getFaceColor(): string {
    const startRed = 92, startGreen = 255, startBlue = 92;
    const endRed = 255, endGreen = 92, endBlue = 92;

    const red = Math.floor(startRed + (endRed - startRed) * (this.moodValue / 100));
    const green = Math.floor(startGreen + (endGreen - startGreen) * (this.moodValue / 100));
    const blue = Math.floor(startBlue + (endBlue - startBlue) * (this.moodValue / 100));

    return `rgb(${red}, ${green}, ${blue})`;
  }

  // 新增：增加water值
  private async incrementWaterValue(): Promise<void> {
    try {
      const context = getContext(this) as Context;

      // 获取Preferences实例
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      // 读取当前water值，默认为0
      let currentWater = await pref.get(this.WATER_KEY, 0) as number;

      // 增加1
      currentWater += 1;

      // 保存新的water值
      await pref.put(this.WATER_KEY, currentWater);
      await pref.flush();

      console.log(`Water值已增加，当前值: ${currentWater}`);
    } catch (error) {
      console.error('增加water值失败:', error);
      // 这里可以选择静默失败，不影响主流程
    }
  }

  // 修改保存方法，支持图片
  private async saveRecord(): Promise<void> {
    try {
      const now = new Date();
      const dateStr = this.formatDateToLocalString(now);

      const record: RecordDataForCreation = {
        date: dateStr,
        moodValue: this.moodValue,
        statusEmoji: this.statusEmoji,
        statusText: this.statusText,
        content: this.contentText
      };

      // 传递图片URI列表
      await this.recordDb.insertRecord(record,
        this.selectedImages.length > 0 ? this.selectedImages : undefined);

      console.log('记录已保存到数据库');

      // 新增：增加water值
      await this.incrementWaterValue();

      this.pageStack.pop();
      promptAction.showToast({ message: '保存成功', duration: 2000 });
    } catch (error) {
      console.error('保存记录失败:', error);
      promptAction.showToast({ message: '保存失败', duration: 2000 });
    }
  }


  // 日期格式化方法
  private formatDateToLocalString(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = (date.getDate()).toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  // 构建图片选择区域 - UI优化
  @Builder
  private buildImageSelection(): void {
    Column() {
      // 图片选择标题
      Row() {
        Text('添加图片')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.selectedImages.length > 0) {
          Button('清空')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor('transparent')
            .border({ width: 1, color: $r('app.color.border_color') })// 浅棕色边框
            .borderRadius(4)
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .onClick(() => {
              this.clearSelectedImages();
            })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 图片预览区域
      if (this.selectedImages.length > 0) {
        Column() {
          Text(`已选择 ${this.selectedImages.length} 张图片`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })

          Scroll() {
            Row() {
              ForEach(this.selectedImages, (imageUri: string, index: number) => {
                Stack({ alignContent: Alignment.TopEnd }) {
                  // 图片预览
                  Image(imageUri)
                    .width(80)
                    .height(80)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                    .border({ width: 1, color:  $r('app.color.border_color') })// 浅棕色边框
                    .onClick(() => {
                      this.previewImage(imageUri, index);
                    })

                  // 删除按钮
                  Column() {
                    Text('×')
                      .fontSize(15)  // 设置字体大小而不是宽高
                      .fontColor('#FFFFFF')
                      .textAlign(TextAlign.Center)  // 文本水平居中
                  }
                    .width(18)
                    .height(18)
                    .backgroundColor('#FF6B6B')
                    .borderRadius(20)
                    .justifyContent(FlexAlign.Center)  // 垂直居中
                    .alignItems(HorizontalAlign.Center)  // 水平居中
                    .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
                    .margin({ top: 4, right: 4 })
                    .onClick(() => {
                      this.removeImage(index);
                    })
                }
                .margin({ right: 12 })
              }, (imageUri: string) => imageUri)
            }
            .padding(8)
          }
          .height(100)
          .scrollable(ScrollDirection.Horizontal) // 横向滚动
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.image_selection_bg'))
        .borderRadius(12)
        .border({ width: 1, color: $r('app.color.border_color') })
        .margin({ bottom: 12 })
      }

      // 选择图片按钮 - 统一风格
      Button('选择图片')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor(this.selectedImages.length > 0 ? $r('app.color.button_secondary') : $r('app.color.image_selection_bg'))
        .width('100%')
        .height(42)
        .border({
          width: 1,
          color: this.selectedImages.length > 0 ? $r('app.color.border_color') : $r('app.color.primary_color'),
          style: BorderStyle.Dashed
        })
        .borderRadius(8)
        .onClick(() => {
          this.selectImages();
        })
        .shadow(this.selectedImages.length === 0 ? {
          radius: 3,
          color: '#20000000',
          offsetX: 0,
          offsetY: 2
        } : null)
    }
    .width('90%')
    .padding(16)
    .backgroundColor($r('app.color.image_selection_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_color') })
    .margin({ bottom: 16 })
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 图片预览
  private previewImage(imageUri: string, index: number): void {
    this.previewImageUrl = imageUri;
    this.previewImageIndex = index;
    this.showImagePreview = true;
  }

  // 构建图片预览弹窗
  @Builder
  private buildImagePreviewModal(): void {
    if (this.showImagePreview && this.selectedImages.length > 0) {
      // 使用 Stack 替代 Column 实现层叠布局
      Stack() {
        // 半透明背景遮罩 - 放在底层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#A0000000') // 加深透明度，提高可读性
          .onClick(() => {
            this.showImagePreview = false;
          })

        // 图片预览容器 - 放在上层，居中显示
        Column() {
          // 顶部工具栏
          Row() {
            Text(`图片 ${this.previewImageIndex + 1}/${this.selectedImages.length}`)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button('×')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#60000000')
              .width(40)
              .height(40)
              .borderRadius(20)
              .onClick(() => {
                this.showImagePreview = false;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })

          // 图片显示区域
          Stack({ alignContent: Alignment.Center }) {
            Image(this.previewImageUrl)
              .width('100%') // 调整为100%宽度，适应容器
              .height('100%') // 调整为100%高度，适应容器
              .objectFit(ImageFit.Contain)
              .backgroundColor('#20000000')
              .borderRadius(8)
              .onClick(() => {
                // 点击图片可以切换显示模式或关闭
              })

            // 导航按钮（多张图片时显示）
            if (this.selectedImages.length > 1) {
              Row() {
                // 上一张按钮
                Button('<')
                  .fontSize(24)
                  .fontColor(Color.White)
                  .backgroundColor('#60000000')
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .enabled(this.previewImageIndex > 0)
                  .onClick(() => {
                    if (this.previewImageIndex > 0) {
                      this.previewImageIndex--;
                      this.previewImageUrl = this.selectedImages[this.previewImageIndex];
                    }
                  })

                Blank()

                // 下一张按钮
                Button('>')
                  .fontSize(24)
                  .fontColor(Color.White)
                  .backgroundColor('#60000000')
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .enabled(this.previewImageIndex < this.selectedImages.length - 1)
                  .onClick(() => {
                    if (this.previewImageIndex < this.selectedImages.length - 1) {
                      this.previewImageIndex++;
                      this.previewImageUrl = this.selectedImages[this.previewImageIndex];
                    }
                  })
              }
              .width('100%')
              .margin({ top: '80%' }) // 使用百分比定位，适应不同屏幕
            }
          }
          .layoutWeight(1) // 占据剩余空间
          .width('100%')
          .margin({ bottom: 20 })

          // 底部指示器
          if (this.selectedImages.length > 1) {
            Row() {
              ForEach(Array.from({ length: this.selectedImages.length }), (item: undefined, index: number) => {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(index === this.previewImageIndex ? Color.White : '#80FFFFFF')
                  .margin({ right: 4 })
              })
            }
            .margin({ bottom: 20 })
          }
        }
        .width('85%') // 调整为85%宽度，留出边距
        .height('75%') // 调整为75%高度，适应不同屏幕
        .backgroundColor('#40000000')
        .backdropBlur(10)
        .borderRadius(16)
        .align(Alignment.Center) // 在Stack中居中
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000) // 提高zIndex确保在最顶层
    }
  }


  // 状态选择弹窗 - UI优化
  @Builder
  buildStatusModal() {
    if (this.showStatusModal) {
      Column() {
        Row() {
          Text('设置状态')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
            .fontColor($r('app.color.text_primary'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')

        Divider()
          .color($r('app.color.border_color'))
          .margin({ bottom: 20 })

        // 选择表情区域
        Row() {
          Text('选择表情:')
            .fontSize(16)
            .margin({ right: 10 })
            .fontColor($r('app.color.text_primary'))


          // 缩小下拉框尺寸
          Select(
            this.emojiOptions.map((option): SelectOption => ({
              value: `${option.value} ${option.label}`,
              label: `${option.value} ${option.label}`
            }))
          )
            .selected(this.selectedEmojiIndex)
            .onSelect((index: number) => {
              this.selectedEmojiIndex = index;
              this.statusEmoji = this.emojiOptions[index].value;
              this.statusText = this.emojiOptions[index].label;
            })
            .value(this.emojiOptions[this.selectedEmojiIndex]?.value)
            .width(60)// 缩小宽度
            .height(40)
            .backgroundColor($r('app.color.primary_color'))
            .borderRadius(8)
            .border({ width: 1, color: $r('app.color.border_color') })
            .fontColor($r('app.color.button_text'))
        }
        .width('90%')
        .margin({ bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 文字输入区
        TextInput({ placeholder: '输入状态描述...', text: this.statusText })
          .placeholderColor($r('app.color.text_secondary'))
          .width('90%')
          .height(100)
          .borderRadius(10)
          .fontColor($r('app.color.text_primary'))
          .border({ width: 1, color: $r('app.color.border_color') })
          .padding(10)
          .backgroundColor($r('app.color.input_background'))
          .onChange((text: string) => {
            this.statusText = text;
          })
          .gesture(
            LongPressGesture({ repeat: true, duration: 400 })
              .onAction((event: GestureEvent) => {
                return true
              })
              .onActionEnd((event: GestureEvent) => {
              })
          )

        Button('确定')
          .margin({ top: 20 })
          .width('80%')
          .backgroundColor($r('app.color.primary_color'))
          .fontColor($r('app.color.button_text'))
          .onClick(() => {
            this.showStatusModal = false;
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor($r('app.color.modal_background'))
      .border({ width: 6, color: $r('app.color.modal_border') })
      .borderRadius(20)
      .position({})
      .zIndex(999) // 确保在最顶层
      .align(Alignment.Center)
      .shadow({
        radius: 15,
        color: '#20000000',
        offsetX: 0,
        offsetY: 5
      })
    }
  }

  // 保存确认弹窗 - UI优化
  @Builder
  buildSaveModal() {
    if (this.showSaveModal) {
      Column() {
        Text('确认保存？')
          .fontSize(20)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('记录将保存在当天')
          .fontColor($r('app.color.text_secondary'))
          .fontSize(16)
          .margin({ bottom: 30 })

        Row({ space: 30 }) {
          Button('取消')
            .backgroundColor($r('app.color.button_secondary'))
            .fontColor($r('app.color.text_primary'))
            .width('30%')
            .borderRadius(8)
            .onClick(() => {
              this.showSaveModal = false;
            })

          Button('确认')
            .backgroundColor($r('app.color.primary_color'))
            .fontColor($r('app.color.button_text'))
            .width('30%')
            .borderRadius(8)
            .onClick(() => {
              this.saveRecord();
              promptAction.showToast({ message: '保存成功', duration: 2000 });
            })
        }
      }
      .width('80%')
      .padding(20)
      .backgroundColor($r('app.color.modal_background'))
      .border({ width: 6, color: $r('app.color.modal_border') })
      .borderRadius(20)
      .zIndex(999) // 确保在最顶层
      .position({})
      .align(Alignment.Center)
      .shadow({
        radius: 15,
        color: '#20000000',
        offsetX: 0,
        offsetY: 5
      })
    }
  }

  build() {
    NavDestination() {
      Stack() {
        // 1. 固定导航栏（扩展安全区域）
        Column() {
          // 顶部安全区域填充
          Blank()
            .height(30)// 安全区域高度
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .backgroundColor($r('app.color.nav_background'))


          // 导航栏内容
          Row() {
            Image($r('app.media.ic_back'))
              .width(30)
              .height(30)
              .margin({ left: 15 })
              .onClick(() => {
                this.pageStack.pop();
              })

            Text('添加记录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 20 })
              .fontColor($r('app.color.text_primary'))

            Blank()

            Button('保存')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .margin({ right: 20 })
              .border({ width: 1, color: $r('app.color.border_color') })
              .backgroundColor($r('app.color.nav_background'))
              .onClick(() => {
                this.showSaveModal = true;
              })
          }
          .width('100%')
          .height(70)
          .backgroundColor($r('app.color.nav_background'))
          .border({ width: { bottom: 1 }, color: $r('app.color.border_color') })
        }
        .width('100%')
        .backgroundColor($r('app.color.nav_background'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]) // 扩展顶部安全区域
        .position({ x: 0, y: -40 })
        .zIndex(100)

        // 2. 可滚动的内容区域（放在底层）
        Scroll() {
          Column() {
            // 添加顶部空白，避免内容被导航栏遮挡
            Blank()
              .height(60) // 导航栏高度 + 安全区域高度

            // 表情和时间区域 - UI优化
            Row() {
              // 表情区域
              Stack({ alignContent: Alignment.Center }) {
                Circle()
                  .width(80)
                  .height(80)
                  .fill(this.getFaceColor())

                Image(this.getFaceImage())
                  .width(60)
                  .height(60)
                  .objectFit(ImageFit.Contain)
              }
              .width(80)
              .height(80)

              // 时间和状态区域
              Column({ space: 5 }) {
                // 点击状态区域可以打开模态框
                Text(this.statusEmoji + ' ' + this.statusText)
                  .fontSize(18)
                  .onClick(() => {
                    this.showStatusModal = true;
                  })
                  .border({ width: 1, color: $r('app.color.border_color'), radius: 10 })
                  .padding(8)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor($r('app.color.input_background'))

                Text(new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString())
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))

                Text(`开心值: ${this.moodValue}`)
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .margin({ left: 10 })
            }
            .margin({
              top: 20,
              left: 20,
              right: 20,
              bottom: 20
            })

            // 正文输入区域 - UI优化
            TextArea({ placeholder: '记录今天的想法和感受...' })
              .placeholderColor($r('app.color.text_secondary'))
              .width('90%')
              .height(400)// 改为固定高度，避免过度拉伸
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .borderRadius(10)
              .border({ width: 1, color: $r('app.color.border_color') })
              .padding(15)
              .backgroundColor($r('app.color.input_background'))
              .onChange((text: string) => {
                this.contentText = text;
              })
              .textAlign(TextAlign.Start)// 文本左对齐
              .placeholderFont({ size: 20 })// 占位符左对齐
              .margin({ bottom: 20 })

            // 在正文输入区域前添加图片选择
            this.buildImageSelection()

            // 添加底部空白，确保内容可以完全滚动
            Blank()
              .height(100)
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')

        // 3. 弹窗区域（放在上层，覆盖在滚动内容之上）
        this.buildStatusModal()
        this.buildSaveModal()
        this.buildImagePreviewModal() // 新增：图片预览弹窗
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.moodValue = context.pathInfo.param as number;
    })
    .hideTitleBar(true)
  }
}