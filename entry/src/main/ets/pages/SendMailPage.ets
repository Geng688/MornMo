// src/main/ets/pages/SendMailPage.ets
import { AppStorageV2 } from "@kit.ArkUI";
import prompt from '@ohos.promptAction';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { MailDatabase, MailItem } from '../database/MailDatabase';
import { ImageStorageUtil } from '../utils/ImageStorageUtil';
import { PopToMail } from "../models/PopToMail";
import { preferences } from "@kit.ArkData";

@Component
export struct SendMailPage {
  areaController: TextAreaController = new TextAreaController();
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!
  hasPopToMail: PopToMail = AppStorageV2.connect(PopToMail, 'POPTOMAIL_KEY', () => new PopToMail())!

  // 写邮件表单数据
  @State mailSubject: string = '';
  @State mailContent: string = '写给未来的自己...';
  @State selectedDate: Date = new Date(Date.now() + 24 * 60 * 60 * 1000);
  @State selectedImages: string[] = [];
  @State isSelectingImages: boolean = false;

  private WATER_KEY: string = 'water_value';
  private PREFERENCES_NAME: string = 'mood_garden_data';

  // 数据库和工具实例
  private mailDb: MailDatabase = MailDatabase.getInstance();
  private imageUtil: ImageStorageUtil = ImageStorageUtil.getInstance();

  // 修正图片选择方法调用
  private async selectImages(): Promise<void> {
    if (this.isSelectingImages) {
      return;
    }

    this.isSelectingImages = true;
    try {
      const imageUtil = ImageStorageUtil.getInstance();
      const imageUris = await imageUtil.selectImages(5);
      if (imageUris.length > 0) {
        this.selectedImages = imageUris;
        this.showToast(`已选择 ${imageUris.length} 张图片`);
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      this.showToast('选择图片失败');
    } finally {
      this.isSelectingImages = false;
    }
  }

  // 清空已选图片
  private clearSelectedImages(): void {
    this.selectedImages = [];
    this.showToast('已清空图片');
  }

  // 删除单张图片
  private removeImage(index: number): void {
    if (index >= 0 && index < this.selectedImages.length) {
      const newImages = [...this.selectedImages];
      newImages.splice(index, 1);
      this.selectedImages = newImages;
    }
  }

  // 新增：增加water值
  private async incrementWaterValue(): Promise<void> {
    try {
      const context = getContext(this) as Context;

      // 获取Preferences实例
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      // 读取当前water值，默认为0
      let currentWater = await pref.get(this.WATER_KEY, 0) as number;

      // 增加5
      currentWater += 5;

      // 保存新的water值
      await pref.put(this.WATER_KEY, currentWater);
      await pref.flush();

      console.log(`Water值已增加5，当前值: ${currentWater}`);
    } catch (error) {
      console.error('增加water值失败:', error);
      // 这里可以选择静默失败，不影响主流程
    }
  }


  // 修正保存邮件方法调用
  private async saveMail(): Promise<void> {
    if (!this.mailSubject.trim()) {
      this.showToast('请填写邮件主题');
      return;
    }

    if (!this.mailContent.trim()) {
      this.showToast('请填写邮件内容');
      return;
    }

    if (this.selectedDate.getTime() <= Date.now()) {
      this.showToast('请选择未来的时间');
      return;
    }

    try {
      const result = await this.mailDb.insertMail(
        this.mailSubject.trim(),
        this.mailContent.trim(),
        this.selectedDate.getTime(),
        Date.now(),
        this.selectedImages.length > 0 ? this.selectedImages : undefined
      );

      if (result > 0) {
        const imageCount = this.selectedImages.length;
        const imageText = imageCount > 0 ? `，包含 ${imageCount} 张图片` : '';
        this.showToast(`邮件已保存${imageText}，将在指定时间送达，获得5点开心水`);

        await this.incrementWaterValue();
        this.clearForm();
      } else {
        this.showToast('保存失败，请重试');
      }
    } catch (error) {
      console.error('保存邮件失败:', error);
      this.showToast('保存失败，请重试');
    }
  }

  // 清空表单（包括图片）
  private clearForm(): void {
    this.mailSubject = '';
    this.mailContent = '写给未来的自己...';
    this.selectedDate = new Date(Date.now() + 24 * 60 * 60 * 1000);
    this.selectedImages = [];
  }

  // 返回按钮点击事件
  private onBackClick(): void {
    this.hasPopToMail.hasPop = (this.hasPopToMail.hasPop === 0 ? 1 : 0);
    this.pageStack.pop();
  }

  // 格式化时间显示（保持不变）
  private formatDateTime(timestamp: number): string {
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return '日期无效';

    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  // 显示Toast提示
  private showToast(message: string): void {
    prompt.showToast({
      message: message,
      duration: 2000
    });
  }

  // 构建图片选择区域
  @Builder
  private buildImageSelection(): void {
    Column() {
      // 图片选择标题
      Row() {
        Text('添加图片')
          .fontSize(16)
          .fontColor($r('app.color.sendmail_image_title'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.selectedImages.length > 0) {
          Button('清空')
            .fontSize(12)
            .fontColor($r('app.color.sendmail_image_clear'))
            .backgroundColor('transparent')
            .onClick(() => {
              this.clearSelectedImages();
            })
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 图片预览区域
      if (this.selectedImages.length > 0) {
        Scroll() {
          Row() {
            ForEach(this.selectedImages, (imageUri: string, index: number) => {
              Column() {
                // 图片预览
                Image(imageUri)
                  .width(80)
                  .height(80)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                  .onClick(() => {
                    this.previewImage(imageUri);
                  })

                // 删除按钮
                Column() {
                  Text('×')
                    .fontSize(15)
                    .fontColor($r('app.color.sendmail_image_delete_text'))
                    .textAlign(TextAlign.Center)
                }
                .width(18)
                .height(18)
                .backgroundColor($r('app.color.sendmail_image_delete_background'))
                .borderRadius(20)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
                .position({ x: 70, y: -5 })
                .onClick(() => {
                  this.removeImage(index);
                })
              }
              .margin({ right: 8 })
            }, (imageUri: string) => imageUri)
          }
          .padding(8)
        }
        .height(100)
        .margin({ bottom: 8 })
      }

      // 选择图片按钮
      Button('选择图片')
        .fontSize(14)
        .fontColor($r('app.color.sendmail_image_button_text'))
        .backgroundColor($r('app.color.sendmail_image_button_background'))
        .width('100%')
        .height(40)
        .border({ width: 1, color: $r('app.color.sendmail_image_button_border'), style: BorderStyle.Dashed })
        .borderRadius(8)
        .onClick(() => {
          this.selectImages();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.sendmail_image_container'))
    .borderRadius(8)
    .border({ width: 1, color: $r('app.color.sendmail_image_border') })
    .margin({ bottom: 16 })
  }

  // 图片预览功能
  private previewImage(imageUri: string): void {
    console.log('预览图片:', imageUri);
    this.showToast('点击了图片: ' + imageUri.substring(imageUri.lastIndexOf('/') + 1));
  }

  // 构建邮件内容区域
  @Builder
  private buildContentArea(): void {
    Column() {
      // 邮件主题
      Column() {
        Text('主题')
          .fontSize(14)
          .fontColor($r('app.color.sendmail_label'))
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '输入邮件主题...', text: this.mailSubject })
          .placeholderColor($r('app.color.sendmail_placeholder'))
          .fontSize(16)
          .fontColor($r('app.color.sendmail_input_text'))
          .height(48)
          .width('100%')
          .padding(12)
          .backgroundColor($r('app.color.sendmail_input_background'))
          .border({ width: 1, color: $r('app.color.sendmail_input_border') })
          .borderRadius(4)
          .onChange((value: string) => {
            this.mailSubject = value;
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 发送时间选择
      this.buildTimeSelector()

      // 图片选择区域
      this.buildImageSelection()

      // 邮件内容
      Column() {
        Text('内容')
          .fontSize(14)
          .fontColor($r('app.color.sendmail_label'))
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)

        TextArea({ placeholder: this.mailContent, controller: this.areaController })
          .placeholderColor($r('app.color.sendmail_placeholder'))
          .fontSize(15)
          .fontColor($r('app.color.sendmail_input_text'))
          .height(200)
          .width('100%')
          .padding(12)
          .backgroundColor($r('app.color.sendmail_input_background'))
          .border({ width: 1, color: $r('app.color.sendmail_input_border') })
          .borderRadius(4)
          .onChange((value: string) => {
            this.mailContent = value;
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 使用说明
      Column() {
        Row() {
          Image($r('app.media.ic_soul_question'))
            .width(16)
            .height(16)
            .margin({ right: 8 })
            .fillColor($r('app.color.sendmail_icon'))

          Text('使用说明')
            .fontSize(14)
            .fontColor($r('app.color.sendmail_instruction_title'))
            .fontWeight(FontWeight.Medium)
        }
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

        Text('这封邮件将在您选择的未来时间点自动出现在收件箱中。您可以写给未来的自己，记录当下的想法和感受。')
          .fontSize(12)
          .fontColor($r('app.color.sendmail_instruction_text'))
          .lineHeight(18)
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.sendmail_instruction_background'))
      .borderRadius(4)
      .border({ width: 1, color: $r('app.color.sendmail_instruction_border') })
    }
  }

  // 构建时间选择器
  @Builder
  private buildTimeSelector(): void {
    Column() {
      Text('收件人')
        .fontSize(14)
        .fontColor($r('app.color.sendmail_label'))
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Row() {
        // 可点击的时间填空区域
        Row() {
          Text(this.formatDateTime(this.selectedDate.getTime()))
            .fontSize(16)
            .fontColor($r('app.color.sendmail_time_text'))
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .margin({ right: 12 })
        .backgroundColor($r('app.color.sendmail_time_background'))
        .borderRadius(4)
        .border({ width: 1, color: $r('app.color.sendmail_time_border'), style: BorderStyle.Dashed })
        .onClick(() => {
          this.openDateTimePicker();
        })

        Text('的自己')
          .fontSize(16)
          .fontColor($r('app.color.sendmail_time_label'))
      }
      .width('100%')
      .height(60)
      .padding(10)
      .backgroundColor($r('app.color.sendmail_time_container'))
      .borderRadius(10)
      .border({ width: 1, color: $r('app.color.sendmail_time_container_border') })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 打开日期时间选择器
  private openDateTimePicker(): void {
    try {
      this.getUIContext().showDatePickerDialog({
        start: new Date(Date.now() + 60 * 60 * 1000),
        selected: this.selectedDate,
        lunarSwitch: false,
        showTime: true,
        onDateAccept: (value: Date) => {
          if (value.getTime() <= Date.now()) {
            this.showToast('请选择未来的时间');
            return;
          }
          this.selectedDate = value;
          this.showToast(`已选择: ${this.formatDateTime(value.getTime())}`);
        },
      });
    } catch (error) {
      console.error('打开日期选择器失败:', error);
      this.showToast('打开日期选择器失败');
    }
  }

  // 构建导航栏
  @Builder
  private buildNavBar(): void {
    Row() {
      Button('← 返回')
        .fontSize(16)
        .fontColor($r('app.color.sendmail_nav_back'))
        .backgroundColor('transparent')
        .onClick(() => {
          this.onBackClick();
        })

      Text('写时光邮件')
        .fontSize(18)
        .fontColor($r('app.color.sendmail_nav_title'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('发送')
        .fontSize(14)
        .fontColor($r('app.color.sendmail_nav_send_text'))
        .backgroundColor($r('app.color.sendmail_nav_send_background'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .borderRadius(4)
        .onClick(() => {
          this.saveMail();
        })
    }
    .width('100%')
    .padding({ bottom: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        // 导航栏
        this.buildNavBar()

        // 主内容区域
        Scroll() {
          this.buildContentArea()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.sendmail_background'))
      .padding(16)
    }.hideTitleBar(true)
  }
}

@Builder
export function SendMailPageBuilder(param: object) {
  SendMailPage()
}