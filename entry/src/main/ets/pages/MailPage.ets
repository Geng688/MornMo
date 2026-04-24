// src/main/ets/pages/MailPage.ets
import { AppStorageV2 } from "@kit.ArkUI";
import prompt from '@ohos.promptAction';
import { MailDatabase, MailItem } from '../database/MailDatabase';
import { PopToMail } from "../models/PopToMail";

// 页面模式枚举
enum MailMode {
  INBOX = 0,    // 收件箱
  SENT = 1      // 已发送
}

@Component
export struct MailPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!

  @State currentMode: MailMode = MailMode.INBOX;
  @State showUnreadOnly: boolean = false;
  @State hasBackFromDetail: boolean = false;

  // 邮件数据
  @State allMails: MailItem[] = [];
  @State inboxMails: MailItem[] = [];
  @State unreadInboxMails: MailItem[] = [];
  @State filteredMails: MailItem[] = [];

  @State selectedMail: MailItem | null = null;
  @State showMailDetail: boolean = false;
  @State newMailCount: number = 0;
  @State lastCheckTime: number = 0;
  @State isRefreshing: boolean = false;

  // 数据库实例
  private mailDb: MailDatabase = MailDatabase.getInstance();

  aboutToAppear() {
    this.initializeDatabase();
  }

  // 修正初始化数据库调用
  private async initializeDatabase() {
    try {
      // 确保传入正确的context参数
      await this.mailDb.initialize(getContext(this));
      await this.loadAllMails();
    } catch (error) {
      console.error('初始化失败:', error);
      this.showToast('初始化失败，请重启应用');
    }
  }

  // 加载邮件数据
  private async loadAllMails() {
    if (this.isRefreshing) return;

    this.isRefreshing = true;
    try {
      // 分别加载三种数据
      const allMails = await this.mailDb.getAllMails();
      const inboxMails = await this.mailDb.getInboxMails();
      const unreadInboxMails = await this.mailDb.getUnreadInboxMails();

      this.allMails = allMails;
      this.inboxMails = inboxMails;
      this.unreadInboxMails = unreadInboxMails;

      this.updateFilteredMails();
      this.newMailCount = unreadInboxMails.length;
      this.lastCheckTime = Date.now();
    } catch (error) {
      console.error('加载邮件失败:', error);
      this.showToast('加载邮件失败');
    } finally {
      this.isRefreshing = false;
    }
  }

  // 更新过滤后的邮件列表
  private updateFilteredMails() {
    let mails: MailItem[] = [];

    if (this.currentMode === MailMode.INBOX) {
      mails = this.showUnreadOnly ? this.unreadInboxMails : this.inboxMails;
    } else {
      mails = this.allMails;
    }

    this.filteredMails = mails;
  }

  // 切换模式
  private switchMode(mode: MailMode) {
    this.currentMode = mode;
    if (mode === MailMode.SENT) {
      this.showUnreadOnly = false;
    }
    this.updateFilteredMails();
  }

  // 切换未读过滤
  private toggleUnreadFilter() {
    if (this.currentMode === MailMode.SENT) {
      this.showToast('已发送邮件不支持未读过滤');
      return;
    }
    this.showUnreadOnly = !this.showUnreadOnly;
    this.updateFilteredMails();
  }

  // 打开写邮件页面
  private openSendMailPage() {
    this.pageStack.pushPathByName('SendMailPage', false, null);
  }

  // 打开邮件详情
  private async openMailDetail(mail: MailItem) {
    console.log('打开邮件详情:', mail.subject);
    this.selectedMail = mail;
    this.showMailDetail = true;

    if (!mail.isRead && mail.id && this.currentMode === MailMode.INBOX && mail.sendTime <= Date.now()) {
      await this.markAsRead(mail.id);
      await this.loadAllMails();
    }
  }

  // 关闭邮件详情
  private closeMailDetail() {
    console.log('关闭邮件详情');
    this.showMailDetail = false;
    this.selectedMail = null;
    this.hasBackFromDetail = this.hasBackFromDetail === true ? false : true;
  }

  // 标记邮件为已读
  private async markAsRead(mailId: number) {
    try {
      await this.mailDb.markAsRead(mailId);
    } catch (error) {
      console.error('标记邮件为已读失败:', error);
    }
  }

  // 在 MailPage.ets 中修复 deleteMail 方法
  private async deleteMail(mailId: number) {
    try {
      console.log('开始删除邮件，ID:', mailId);
      // 显示确认对话框
      this.showConfirmDialog(mailId);
    } catch (error) {
      console.error('删除邮件失败:', error);
      this.showToast('删除失败，请重试');
    }
  }

  // 新增：显示确认对话框
  private showConfirmDialog(mailId: number) {
    // 使用系统对话框确认删除
    try {
      prompt.showDialog({
        title: '确认删除',
        message: '确定要删除这封邮件吗？此操作不可撤销。',
        buttons: [
          {
            text: '取消',
            color: '#666666'
          },
          {
            text: '删除',
            color: '#D32F2F'
          }
        ]
      }).then((result) => {
        if (result.index === 1) { // 用户点击了"删除"
          this.executeDeleteMail(mailId);
        }
      });
    } catch (error) {
      // 如果对话框失败，直接执行删除
      console.warn('显示确认对话框失败，直接执行删除:', error);
      this.executeDeleteMail(mailId);
    }
  }

  // 新增：执行删除操作
  private async executeDeleteMail(mailId: number) {
    try {
      await this.mailDb.deleteMail(mailId);
      console.log('邮件删除成功，ID:', mailId);

      // 重新加载邮件列表
      await this.loadAllMails();

      // 关闭详情弹窗
      this.showMailDetail = false;
      this.selectedMail = null;

      this.showToast('邮件已删除');

    } catch (error) {
      console.error('执行删除操作失败:', error);
      this.showToast('删除失败: ' + (error instanceof Error ? error.message : '未知错误'));
    } finally {
      this.isRefreshing = false;
    }
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const isToday = date.toDateString() === now.toDateString();

    if (isToday) {
      return `今天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else {
      return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
  }

  // 格式化详细时间
  private formatDetailTime(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  // 显示Toast
  private showToast(message: string) {
    prompt.showToast({
      message: message,
      duration: 2000
    });
  }

  // 构建顶部工具栏 - 类似QQ邮箱的简洁风格
  @Builder
  private buildToolBar() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('时光邮箱')
          .fontSize(20)
          .fontColor($r('app.color.mail_title')) // 使用颜色资源
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // 写邮件按钮
        Button('写邮件')
          .fontSize(14)
          .fontColor($r('app.color.mail_button_text')) // 使用颜色资源
          .backgroundColor($r('app.color.mail_button_primary')) // 使用颜色资源
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(4)
          .onClick(() => {
            this.openSendMailPage();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // 模式切换和过滤栏
      Row() {
        // 模式切换
        Row() {
          Button('收件箱')
            .fontSize(15)
            .fontColor(this.currentMode === MailMode.INBOX ? $r('app.color.mail_tab_active') : $r('app.color.mail_tab_inactive')) // 使用颜色资源
            .backgroundColor('transparent')
            .borderWidth(0)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .onClick(() => {
              this.switchMode(MailMode.INBOX);
            })

          Button('已发送')
            .fontSize(15)
            .fontColor(this.currentMode === MailMode.SENT ? $r('app.color.mail_tab_active') : $r('app.color.mail_tab_inactive')) // 使用颜色资源
            .backgroundColor('transparent')
            .borderWidth(0)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .onClick(() => {
              this.switchMode(MailMode.SENT);
            })
        }

        Blank()

        // 未读过滤（仅在收件箱模式下显示）
        if (this.currentMode === MailMode.INBOX) {
          Row() {
            Text('未读')
              .fontSize(13)
              .fontColor(this.showUnreadOnly ? $r('app.color.mail_tab_active') : $r('app.color.mail_tab_inactive')) // 使用颜色资源

            Toggle({ type: ToggleType.Checkbox, isOn: this.showUnreadOnly })
              .selectedColor($r('app.color.mail_tab_active')) // 使用颜色资源
              .switchPointColor($r('app.color.mail_toggle_thumb')) // 使用颜色资源
              .onChange((isOn: boolean) => {
                this.showUnreadOnly = isOn;
                this.updateFilteredMails();
              })
              .margin({ left: 8 })
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(4)
          .border({ width: 1, color: $r('app.color.mail_toggle_border') }) // 使用颜色资源
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 8 })
      .border({ width: { bottom: 1 }, color: $r('app.color.mail_divider') }) // 使用颜色资源
    }
    .backgroundColor($r('app.color.mail_toolbar_background')) // 使用颜色资源
  }

  // 构建邮件列表项 - 修改版本
  @Builder
  private buildMailListItem(mail: MailItem, index: number) {
    Column() {
      Row() {
        // 左侧：圆形图标，显示邮件主题的第一个字
        Column() {
          Text(this.getFirstCharacter(mail.subject))
            .fontSize(16)
            .fontColor($r('app.color.mail_icon_text')) // 使用颜色资源
            .fontWeight(FontWeight.Medium)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.getMailColor(mail))
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 12 })

        // 中间：邮件内容区域
        Column() {
          // 第一行：发件人/收件人和时间
          Row() {
            // 发件人/收件人信息
            Text(this.getSenderRecipientText(mail))
              .fontSize(15)
              .fontColor($r('app.color.mail_sender_text')) // 使用颜色资源
              .fontWeight(mail.isRead ? FontWeight.Normal : FontWeight.Medium)
              .maxLines(1)
              .layoutWeight(1)

            // 时间
            Text(this.formatTime(this.currentMode === MailMode.INBOX ? mail.sendTime : mail.createTime))
              .fontSize(12)
              .fontColor($r('app.color.mail_time_text')) // 使用颜色资源
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 第二行：主题
          Text(mail.subject)
            .fontSize(14)
            .fontColor(mail.isRead ? $r('app.color.mail_subject_read') : $r('app.color.mail_subject_unread')) // 使用颜色资源
            .fontWeight(mail.isRead ? FontWeight.Normal : FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 2 })

          // 第三行：内容预览
          Text(mail.content.length > 40 ? mail.content.substring(0, 40) + '...' : mail.content)
            .fontSize(13)
            .fontColor($r('app.color.mail_preview_text')) // 使用颜色资源
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)

        // 右侧：状态指示器
        Column() {
          // 未读指示器
          if (!mail.isRead && this.currentMode === MailMode.INBOX && mail.sendTime <= Date.now()) {
            Circle()
              .width(8)
              .height(8)
              .fill($r('app.color.mail_unread_indicator')) // 使用颜色资源
          }

          // 未来邮件标记
          if (mail.sendTime > Date.now()) {
            Text('未送达')
              .fontSize(10)
              .fontColor($r('app.color.mail_future_text')) // 使用颜色资源
              .backgroundColor($r('app.color.mail_future_background')) // 使用颜色资源
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              .borderRadius(2)
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.End)
        .width(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 分隔线（不是最后一个项目时显示）
      if (index < this.filteredMails.length - 1) {
        Divider()
          .color($r('app.color.mail_divider')) // 使用颜色资源
          .margin({ left: 68, right: 16 }) // 调整缩进
      }
    }
    .width('100%')
    .backgroundColor(mail.isRead ? $r('app.color.mail_item_read_background') : $r('app.color.mail_item_unread_background')) // 使用颜色资源
    .onClick(() => {
      this.openMailDetail(mail);
    })
  }

  // 获取邮件主题的第一个字符
  private getFirstCharacter(subject: string): string {
    if (!subject || subject.length === 0) {
      return '邮';
    }
    return subject.charAt(0);
  }

  // 获取发件人/收件人文本
  private getSenderRecipientText(mail: MailItem): string {
    if (this.currentMode === MailMode.INBOX) {
      // 收件箱模式：发件人是"XXXX年XX月XX日的自己"
      return '来自：' + this.formatDateChinese(mail.createTime);
    } else {
      // 已发送模式：收件人是"XXXX年XX月XX日的自己"
      return this.formatDateChinese(mail.sendTime) + ' · 收';
    }
  }

  // 格式化日期为中文格式：XXXX年XX月XX日
  private formatDateChinese(timestamp: number): string {
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return '未知时间';

    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');

    return `${year}年${month}月${day}日`;
  }

  // 获取邮件颜色（根据主题首字符生成）
  private getMailColor(mail: MailItem): string {
    const colors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57',
      '#FF9FF3', '#54A0FF', '#5F27CD', '#00D2D3', '#FF9F43'
    ];
    const firstChar = this.getFirstCharacter(mail.subject);
    const charCode = firstChar.charCodeAt(0);
    return colors[charCode % colors.length];
  }

  // 在邮件详情弹窗中添加图片显示
  @Builder
  private buildMailDetailModal(): void {
    if (this.showMailDetail && this.selectedMail) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mail_modal_backdrop')) // 使用颜色资源
          .onClick(() => {
            this.closeMailDetail();
          })

        // 邮件详情内容 - 修改布局和定位
        Column() {
          // 标题栏
          Row() {
            Text('邮件详情')
              .fontSize(20)
              .fontColor($r('app.color.mail_modal_title')) // 使用颜色资源
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(20)
              .fontColor($r('app.color.mail_modal_title')) // 使用颜色资源
              .backgroundColor('transparent')
              .onClick(() => {
                this.closeMailDetail();
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 邮件信息区域 - 使用Scroll确保内容可滚动
          Scroll() {
            Column() {
              // 邮件主题
              Text(this.selectedMail.subject)
                .fontSize(18)
                .fontColor($r('app.color.mail_modal_title')) // 使用颜色资源
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })

              // 时间信息
              Row() {
                Text(this.currentMode === MailMode.INBOX ? '发件人:' : '收件人:')
                  .fontSize(14)
                  .fontColor($r('app.color.mail_modal_subtitle')) // 使用颜色资源

                Text(this.formatDetailTime(this.currentMode === MailMode.INBOX ?
                this.selectedMail.createTime : this.selectedMail.sendTime) + '的自己')
                  .fontSize(14)
                  .fontColor($r('app.color.mail_modal_text')) // 使用颜色资源
                  .margin({ left: 4 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ bottom: 10 })

              Row() {
                Text(this.currentMode === MailMode.INBOX ? '收件时间:' : '发送时间:')
                  .fontSize(14)
                  .fontColor($r('app.color.mail_modal_subtitle')) // 使用颜色资源

                Text(this.formatDetailTime(this.currentMode === MailMode.INBOX ?
                this.selectedMail.sendTime : this.selectedMail.createTime))
                  .fontSize(14)
                  .fontColor($r('app.color.mail_modal_text')) // 使用颜色资源
                  .margin({ left: 4 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ bottom: 20 })

              Divider()
                .margin({ bottom: 20 })

              // 邮件正文
              Text(this.selectedMail.content)
                .fontSize(16)
                .fontColor($r('app.color.mail_modal_content')) // 使用颜色资源
                .lineHeight(24)
                .width('100%')
                .textAlign(TextAlign.Start)

              // 图片显示区域
              if (this.selectedMail.imageUris && this.selectedMail.imageUris.length > 0) {
                Column() {
                  Divider()
                    .margin({ top: 20, bottom: 20 })

                  this.buildMailImages(this.selectedMail.imageUris)
                }
              }
            }
            .width('100%')
          }
          .layoutWeight(1) // 重要：确保Scroll占据剩余空间
          .margin({ bottom: 20 })

          // 操作按钮区域 - 固定在底部
          Column() {
            Button('删除邮件')
              .fontSize(16)
              .fontColor($r('app.color.mail_delete_button_text')) // 使用颜色资源
              .backgroundColor($r('app.color.mail_delete_button_background')) // 使用颜色资源
              .width('100%')
              .height(40)
              .borderRadius(20)
              .onClick(() => {
                if (this.selectedMail?.id) {
                  this.deleteMail(this.selectedMail.id);
                }
              })
          }
          .width('100%')
        }
        .width('90%')
        .height('70%') // 调整高度，确保距离底部50px
        .padding(20)
        .backgroundColor($r('app.color.mail_modal_background')) // 使用颜色资源
        .borderRadius(15)
        .shadow({ radius: 20, color: $r('app.color.mail_modal_shadow'), offsetX: 0, offsetY: 10 }) // 使用颜色资源
        .position({
          x: '5%',
          y: '15%' // 调整垂直位置，确保底部有50px空间
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(999)
    }
  }

  // 修正图片构建器
  @Builder
  private buildMailImages(imageUris: string[]): void {
    Column() {
      Text('📎️附件图片')
        .fontSize(16)
        .fontColor($r('app.color.mail_modal_title')) // 使用颜色资源
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })
        .alignSelf(ItemAlign.Start)

      // 图片网格布局
      Grid() {
        ForEach(imageUris, (imageUri: string, index: number) => {
          GridItem() {
            Column() {
              Image(imageUri)
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
                .onClick(() => {
                  this.previewMailImage(imageUri, index);
                })
            }
          }
        }, (imageUri: string) => imageUri)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
    }
    .width('100%')
  }

  // 新增：预览邮件图片
  private previewMailImage(imageUri: string, index: number): void {
    // 这里可以实现图片预览功能
    console.log('预览邮件图片:', imageUri, '索引:', index);
    this.showToast(`查看图片 ${index + 1}/${this.selectedMail?.imageUris?.length}`);
  }

  // 构建空状态
  @Builder
  private buildEmptyState() {
    Column() {
      Text('📮')
        .fontSize(60)
        .margin({ bottom: 24 })

      Text(this.getEmptyStateText())
        .fontSize(16)
        .fontColor($r('app.color.mail_empty_text')) // 使用颜色资源
        .margin({ bottom: 8 })

      Text(this.getEmptyStateSubText())
        .fontSize(14)
        .fontColor($r('app.color.mail_empty_subtext')) // 使用颜色资源
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 获取空状态文本
  private getEmptyStateText(): string {
    if (this.currentMode === MailMode.INBOX) {
      return this.showUnreadOnly ? '没有未读邮件' : '收件箱为空';
    } else {
      return '已发送邮件为空';
    }
  }

  // 获取空状态副文本
  private getEmptyStateSubText(): string {
    if (this.currentMode === MailMode.INBOX) {
      return this.showUnreadOnly ? '所有邮件都已阅读' : '过去写过来的邮件将会在这里出现';
    } else {
      return '还没有发送过邮件';
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 工具栏
        this.buildToolBar()

        // 邮件列表区域
        Column() {
          if (this.filteredMails.length === 0) {
            this.buildEmptyState()
          } else {
            List({ space: 0 }) { // 去除项间距，使用分隔线
              if (this.hasBackFromDetail) {
                ForEach(this.filteredMails, (mail: MailItem, index: number) => {
                  ListItem() {
                    this.buildMailListItem(mail, index)
                  }
                }, (mail: MailItem) => mail.id?.toString() ?? mail.subject)
              } else if (!this.hasBackFromDetail) {
                ForEach(this.filteredMails, (mail: MailItem, index: number) => {
                  ListItem() {
                    this.buildMailListItem(mail, index)
                  }
                }, (mail: MailItem) => mail.id?.toString() ?? mail.subject)
              }
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor($r('app.color.mail_list_background')) // 使用颜色资源

        // 邮件详情弹窗
        this.buildMailDetailModal()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.mail_background')) // 使用颜色资源
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }.onResult(() => {
      console.log("回来了")
      this.loadAllMails();
    })
  }
}

@Builder
export function MailPageBuilder(param: object) {
  MailPage()
}