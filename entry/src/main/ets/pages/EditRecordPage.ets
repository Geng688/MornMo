// src/main/ets/pages/EditRecordPage.ets
import promptAction from '@ohos.promptAction';
import { RecordData } from '../models/RecordData';
import { GlobalRecord } from '../models/GlobalRecord';
import { AppStorageV2 } from '@kit.ArkUI';
import { RecordDatabase } from '../database/RecordDatabase';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

// 表情选项接口
interface EmojiOption {
  value: string;
  label: string;
}

interface SelectOption {
  value: string;
  label: string;
}

@ComponentV2
struct EditRecordPage {
  pageStack: NavPathStack = new NavPathStack();

  // 共享记录数据 - 从DailyQueryPage传递过来的待编辑记录
  @Local globalRecord: GlobalRecord = AppStorageV2.connect(GlobalRecord, 'RECORD_KEY', () => new GlobalRecord())!

  // 本地状态
  @Local moodValue: number = this.globalRecord.moodValue || 100;
  @Local showStatusModal: boolean = false;
  @Local contentText: string = this.globalRecord.content || "";
  @Local selectedEmojiIndex: number = -1;
  @Local statusText: string = this.globalRecord.statusText || '状态';
  @Local statusEmoji: string = this.globalRecord.statusEmoji || '➕';
  @Local showSaveModal: boolean = false;
  @Local selectedImages: string[] = []; // 当前选择的图片
  @Local originalImages: string[] = []; // 原始图片
  @Local isSelectingImages: boolean = false;
  // 新增：图片预览相关状态
  @Local showImagePreview: boolean = false;
  @Local previewImageUrl: string = '';
  @Local previewImageIndex: number = 0;

  // 数据库实例
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

  aboutToAppear() {
    // 初始化数据库
    this.recordDb.initialize(getContext(this));

    // 设置选中的表情索引
    this.setSelectedEmojiIndex();

    // 新增：加载记录图片
    this.loadRecordImages();
  }

  // 根据当前状态表情设置选中的表情索引
  private setSelectedEmojiIndex(): void {
    if (this.globalRecord.statusEmoji) {
      const index = this.emojiOptions.findIndex(option => option.value === this.globalRecord.statusEmoji);
      if (index !== -1) {
        this.selectedEmojiIndex = index;
      }
    }
  }

  // 加载记录图片
  private async loadRecordImages(): Promise<void> {
    if (this.globalRecord.id) {
      try {
        const images = await this.recordDb.getRecordImages(this.globalRecord.id);
        this.selectedImages = images;
        this.originalImages = [...images]; // 保存原始图片用于比较
      } catch (error) {
        console.error('加载记录图片失败:', error);
      }
    }
  }

  // 图片选择方法（同AddRecordPage）
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

  // 计算面部颜色
  private getFaceColor(): string {
    const startRed = 92, startGreen = 255, startBlue = 92;
    const endRed = 255, endGreen = 92, endBlue = 92;

    const red = Math.floor(startRed + (endRed - startRed) * (this.moodValue / 100));
    const green = Math.floor(startGreen + (endGreen - startGreen) * (this.moodValue / 100));
    const blue = Math.floor(startBlue + (endBlue - startBlue) * (this.moodValue / 100));

    return `rgb(${red}, ${green}, ${blue})`;
  }

  // 修改更新方法，支持图片
  private async updateRecord(): Promise<void> {
    try {
      if (!this.globalRecord.id) {
        promptAction.showToast({ message: '记录ID缺失', duration: 2000 });
        return;
      }

      const updatedRecord: RecordData = {
        id: this.globalRecord.id,
        date: this.globalRecord.date,
        moodValue: this.moodValue,
        statusEmoji: this.statusEmoji,
        statusText: this.statusText,
        content: this.contentText
      };

      // 只有图片有变化时才传递图片参数
      const imagesChanged = this.hasImagesChanged();
      await this.recordDb.updateRecord(
        updatedRecord,
        imagesChanged ? this.selectedImages : undefined
      );

      promptAction.showToast({ message: '记录已更新', duration: 2000 });
      this.pageStack.pop();
    } catch (error) {
      console.error('更新记录失败:', error);
      promptAction.showToast({ message: '更新失败', duration: 2000 });
    }
  }

  // 检查图片是否有变化
  private hasImagesChanged(): boolean {
    if (this.selectedImages.length !== this.originalImages.length) {
      return true;
    }

    return this.selectedImages.some((uri, index) =>
    uri !== this.originalImages[index]
    );
  }

  // 新增：预览图片方法
  private previewImage(imageUri: string, index: number): void {
    try {
      // 显示图片预览信息
      this.previewImageUrl = imageUri;
      this.previewImageIndex = index;
      this.showImagePreview = true;

      // 这里可以添加更复杂的图片预览逻辑
      // 比如打开全屏图片查看器
      console.info('预览图片:', imageUri, '索引:', index);

    } catch (error) {
      console.error('预览图片失败:', error);
      promptAction.showToast({ message: '预览图片失败', duration: 2000 });
    }
  }

  // 新增：删除图片方法
  private removeImage(index: number): void {
    try {
      if (index >= 0 && index < this.selectedImages.length) {
        // 创建新的数组（避免直接修改原数组）
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

        console.info(`删除图片成功，剩余 ${this.selectedImages.length} 张图片`);
      } else {
        console.warn('删除图片索引无效:', index);
      }
    } catch (error) {
      console.error('删除图片失败:', error);
      promptAction.showToast({ message: '删除图片失败', duration: 2000 });
    }
  }

  // 构建图片显示区域 - UI优化
  @Builder
  private buildImageDisplay(): void {
    Column() {
      // 图片区域标题
      Row() {
        Text(this.selectedImages.length > 0 ? `记录图片 (${this.selectedImages.length}张)` : '添加图片')
          .fontSize(16)
          .fontColor($r('app.color.edit_image_title'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.selectedImages.length > 0) {
          Button('重新选择')
            .fontSize(12)
            .fontColor($r('app.color.edit_image_button_text'))
            .backgroundColor('transparent')
            .border({ width: 1, color: $r('app.color.edit_image_border') })
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.selectImages();
            })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 图片显示区域
      if (this.selectedImages.length > 0) {
        Column() {
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
                    .border({ width: 1, color: $r('app.color.edit_image_border') })
                    .onClick(() => {
                      this.previewImage(imageUri, index);
                    })

                  // 删除按钮
                  Column() {
                    Text('×')
                      .fontSize(15)
                      .fontColor($r('app.color.button_primary_text'))
                      .textAlign(TextAlign.Center)
                  }
                  .width(18)
                  .height(18)
                  .backgroundColor($r('app.color.edit_delete_button'))
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
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
          .scrollable(ScrollDirection.Horizontal)
          .height(100)
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.edit_image_container_bg'))
        .borderRadius(12)
        .border({ width: 1, color: $r('app.color.edit_image_border') })
        .margin({ bottom: 12 })
      } else {
        // 没有图片时显示选择按钮
        Button('选择图片')
          .fontSize(14)
          .fontColor($r('app.color.edit_image_button_text'))
          .backgroundColor($r('app.color.edit_image_container_bg'))
          .width('100%')
          .height(42)
          .border({
            width: 1,
            color: $r('app.color.edit_image_border'),
            style: BorderStyle.Dashed
          })
          .borderRadius(8)
          .onClick(() => {
            this.selectImages();
          })
          .shadow({ radius: 3, color: '#20000000', offsetX: 0, offsetY: 2 })
      }
    }
    .width('90%')
    .padding(16)
    .backgroundColor($r('app.color.edit_image_section_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.edit_image_border') })
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: 2 })
  }

  // 构建图片预览弹窗
  @Builder
  private buildImagePreviewModal(): void {
    if (this.showImagePreview && this.selectedImages.length > 0) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#A0000000')
          .onClick(() => {
            this.showImagePreview = false;
          })

        Column() {
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

          Stack({ alignContent: Alignment.Center }) {
            Image(this.previewImageUrl)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .backgroundColor('#20000000')
              .borderRadius(8)

            if (this.selectedImages.length > 1) {
              Row() {
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
              .margin({ top: '80%' })
            }
          }
          .layoutWeight(1)
          .width('100%')
          .margin({ bottom: 20 })

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
        .width('85%')
        .height('75%')
        .backgroundColor('#40000000')
        .backdropBlur(10)
        .borderRadius(16)
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 状态选择弹窗
  @Builder
  buildStatusModal() {
    if (this.showStatusModal) {
      Column() {
        Row() {
          Text('设置状态')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.edit_modal_title'))
            .margin({ bottom: 20 })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')

        Divider()
          .color($r('app.color.edit_divider'))
          .margin({ bottom: 20 })

        Row() {
          Text('选择表情:')
            .fontSize(16)
            .fontColor($r('app.color.edit_modal_text'))
            .margin({ right: 10 })

          Select(
            this.emojiOptions.map((option): SelectOption => ({
              value: `${option.value} ${option.label}`,
              label: `${option.value} ${option.label}`
            }))
          )
            .selected(this.selectedEmojiIndex)
            .backgroundColor($r('app.color.edit_select_background'))
            .onSelect((index: number) => {
              this.selectedEmojiIndex = index;
              this.statusEmoji = this.emojiOptions[index].value;
              this.statusText = this.emojiOptions[index].label;
            })
            .value(this.emojiOptions[this.selectedEmojiIndex]?.value || this.statusEmoji)
            .width(60)
            .height(40)
            .borderRadius(8)
            .border({ width: 1, color: $r('app.color.edit_select_border') })
        }
        .width('90%')
        .margin({ bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)

        TextInput({ placeholder: '输入状态描述...', text: this.statusText })
          .width('90%')
          .height(100)
          .borderRadius(10)
          .fontColor($r('app.color.edit_modal_text'))
          .border({ width: 1, color: $r('app.color.edit_input_border') })
          .placeholderColor($r('app.color.edit_placeholder'))
          .padding(10)
          .backgroundColor($r('app.color.edit_input_background'))
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
          .backgroundColor($r('app.color.edit_button_primary'))
          .fontColor($r('app.color.edit_button_text'))
          .width('80%')
          .onClick(() => {
            this.showStatusModal = false;
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor($r('app.color.edit_modal_background'))
      .border({ width: 6, color: $r('app.color.edit_modal_border') })
      .borderRadius(20)
      .position({})
      .zIndex(999)
      .align(Alignment.Center)
    }
  }

  // 保存确认弹窗
  @Builder
  buildSaveModal() {
    if (this.showSaveModal) {
      Column() {
        Text('确认更新？')
          .fontSize(20)
          .fontColor($r('app.color.edit_modal_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('记录将被更新')
          .fontColor($r('app.color.edit_modal_text'))
          .fontSize(16)
          .margin({ bottom: 30 })

        Row({ space: 30 }) {
          Button('取消')
            .backgroundColor($r('app.color.edit_button_secondary'))
            .fontColor($r('app.color.edit_button_secondary_text'))
            .width(120)
            .onClick(() => {
              this.showSaveModal = false;
            })

          Button('确认')
            .backgroundColor($r('app.color.edit_button_primary'))
            .fontColor($r('app.color.edit_button_text'))
            .width(120)
            .onClick(() => {
              this.updateRecord();
            })
        }
      }
      .width('80%')
      .padding(20)
      .backgroundColor($r('app.color.edit_modal_background'))
      .border({ width: 6, color: $r('app.color.edit_modal_border') })
      .borderRadius(20)
      .zIndex(999)
      .position({})
      .align(Alignment.Center)
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Blank()
            .height(30)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .backgroundColor($r('app.color.edit_nav_background'))

          Row() {
            Image($r('app.media.ic_back'))
              .width(30)
              .height(30)
              .margin({ left: 15 })
              .onClick(() => {
                this.pageStack.pop();
              })

            Text('查看记录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 20 })
              .fontColor($r('app.color.edit_nav_title'))

            Blank()

            Button('更新')
              .fontSize(16)
              .fontColor($r('app.color.edit_nav_button_text'))
              .margin({ right: 20 })
              .border({ width: 1, color: $r('app.color.edit_nav_border') })
              .backgroundColor($r('app.color.edit_nav_background'))
              .onClick(() => {
                this.showSaveModal = true;
              })
          }
          .width('100%')
          .height(70)
          .backgroundColor($r('app.color.edit_nav_background'))
          .border({ width: { bottom: 1 }, color: $r('app.color.edit_nav_border') })
        }
        .width('100%')
        .backgroundColor($r('app.color.edit_nav_background'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .position({ x: 0, y: -40 })
        .zIndex(100)

        Scroll() {
          Column() {
            Blank()
              .height(90)

            Row() {
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

              Column({ space: 5 }) {
                Text(this.statusEmoji + ' ' + this.statusText)
                  .fontSize(18)
                  .fontColor($r('app.color.text_primary'))
                  .onClick(() => {
                    this.showStatusModal = true;
                  })
                  .border({ width: 1, color: $r('app.color.edit_status_border'), radius: 10 })
                  .padding(8)
                  .fontColor($r('app.color.edit_status_text'))
                  .backgroundColor($r('app.color.edit_status_background'))

                Text(new Date(this.globalRecord.date).toLocaleDateString() + ' ' +
                new Date(this.globalRecord.date).toLocaleTimeString())
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))

                Text(`开心值: ${this.moodValue}`)
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .margin({ left: 10 })
            }
            .margin({ top: 20, left: 20, right: 20, bottom: 20 })

            TextArea({ text: this.contentText })
              .placeholderColor($r('app.color.text_secondary'))
              .fontColor($r('app.color.text_primary'))
              .width('90%')
              .height(450)
              .fontSize(20)
              .borderRadius(10)
              .border({ width: 1, color: $r('app.color.edit_textarea_border') })
              .backgroundColor($r('app.color.edit_textarea_background'))
              .padding(15)
              .onChange((text: string) => {
                this.contentText = text;
              })
              .textAlign(TextAlign.Start)
              .placeholderFont({ size: 20 })
              .margin({ bottom: 20 })

            this.buildImageDisplay()

            Blank()
              .height(100)
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')

        this.buildStatusModal()
        this.buildSaveModal()
        this.buildImagePreviewModal()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.edit_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function EditRecordPageBuilder() {
  EditRecordPage()
}