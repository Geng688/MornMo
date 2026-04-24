// src/main/ets/pages/DailyQueryPage.ets
import promptAction from '@ohos.promptAction';
import { RecordData } from '../models/RecordData';
import { GlobalDate } from '../models/GlobalDate';
import { AppStorageV2 } from '@kit.ArkUI';
import { GlobalRecord } from '../models/GlobalRecord';
import { PopToCalendar } from '../models/PopToCalendar';
import { RecordDatabase } from '../database/RecordDatabase';

@ComponentV2
export struct DailyQueryPage {
  pageStack: NavPathStack = new NavPathStack();
  hasPopToCalendar: PopToCalendar = AppStorageV2.connect(PopToCalendar, 'HASPOP_KEY', () => new PopToCalendar())!

  //获取被点击的日期数据
  @Local selectedDate: GlobalDate = AppStorageV2.connect(GlobalDate, 'DATE_KEY', () => new GlobalDate())!
  @Local hasPopFromEdit: number = 0

  //共享被编辑的记录数据
  globalRecord: GlobalRecord = AppStorageV2.connect(GlobalRecord, 'RECORD_KEY', () => new GlobalRecord())!

  @Local selectedYear: number = this.selectedDate.selectedYear || new Date().getFullYear();
  @Local selectedMonth: number = this.selectedDate.selectedMonth || new Date().getMonth() + 1;
  @Local selectedDay: number = this.selectedDate.selectedDay || new Date().getDate();

  // 当天所有记录
  @Local records: RecordData[] = [];

  // 当天平均开心值
  @Local avgHappiness: number = 0;
  @Local backStatu: number = 0;

  @Local showDeleteModal: boolean = false;
  @Local prepareToDeleteId: number = -1;

  // 数据库实例
  private recordDb: RecordDatabase = RecordDatabase.getInstance();

  async aboutToAppear() {
    // 等待数据库初始化完成
    await this.recordDb.initialize(getContext(this));
    console.log('Database initialized successfully');

    // 数据库初始化完成后再加载数据
    await this.loadRecords();
  }

  private async popFromEdit() {
    console.log('[DailyQueryPage] onPageShow, 重新加载数据');
    this.hasPopFromEdit = (this.hasPopFromEdit === 0 ? 1 : 0);
    await this.loadRecords();
  }

  // 加载当天的记录 - 修改为使用数据库
  private async loadRecords() {
    try {
      console.log(`[DailyQueryPage] 开始从数据库加载记录，日期: ${this.selectedYear}-${this.selectedMonth}-${this.selectedDay}`);

      // 格式化目标日期字符串
      const targetDateStr = this.formatDateToLocalString(
        new Date(this.selectedYear, this.selectedMonth - 1, this.selectedDay)
      ).substring(0, 10);

      // 从数据库查询当天的记录
      const dayRecords = await this.recordDb.queryRecordsByDate(targetDateStr);
      this.records = dayRecords;
      console.log(`[DailyQueryPage] 从数据库获取的记录数量: ${this.records.length}`);

      // 计算平均开心值
      if (this.records.length > 0) {
        const sum = this.records.reduce((acc, record) => {
          const value = Number(record.moodValue);
          return isNaN(value) ? acc : acc + value;
        }, 0);
        this.avgHappiness = Math.round(sum / this.records.length);
      } else {
        this.avgHappiness = 0;
      }

      console.log(`[QueryPage] 平均开心值: ${this.avgHappiness}`);
    } catch (error) {
      console.error('[DailyQueryPage] 从数据库加载记录失败:', error);
      this.records = [];
      this.avgHappiness = 0;
      promptAction.showToast({ message: '加载记录失败', duration: 2000 });
    }
  }

  // 将日期格式化为本地时区的 yyyy-MM-dd 字符串
  private formatDateToLocalString(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 删除记录 - 修改为使用数据库
  private async deleteRecord(recordId: number) {
    try {
      await this.recordDb.deleteRecord(recordId);
      promptAction.showToast({ message: '记录已删除', duration: 2000 });

      // 更新本地状态（移除已删除记录）
      this.records = this.records.filter(r => r.id !== recordId);

      // 重新计算平均值
      if (this.records.length > 0) {
        const sum = this.records.reduce((acc, record) => {
          const value = Number(record.moodValue);
          return isNaN(value) ? acc : acc + value;
        }, 0);
        this.avgHappiness = Math.round(sum / this.records.length);
      } else {
        this.avgHappiness = 0;
      }
    } catch (error) {
      console.error('[DailyQueryPage] 删除记录失败:', error);
      promptAction.showToast({ message: '删除失败', duration: 2000 });
    }
  }

  // 跳转到编辑页面
  private navigateToEditPage(record: RecordData): void {
    this.globalRecord.id = record.id
    this.globalRecord.date = record.date
    this.globalRecord.moodValue = record.moodValue
    this.globalRecord.statusEmoji = record.statusEmoji
    this.globalRecord.statusText = record.statusText
    this.globalRecord.content = record.content
    this.pageStack.pushPathByName('EditRecordPage', false, null)
  }

  // 返回日历查询页面
  private backToCalendar() {
    this.hasPopToCalendar.hasPop = (this.hasPopToCalendar.hasPop === 0 ? 1 : 0)
    this.pageStack.pop();
  }

  // 计算面部颜色
  private getFaceColor(happiness: number): string {
    const startRed = 92, startGreen = 255, startBlue = 92;
    const endRed = 255, endGreen = 92, endBlue = 92;

    const red = Math.floor(startRed + (endRed - startRed) * (happiness / 100));
    const green = Math.floor(startGreen + (endGreen - startGreen) * (happiness / 100));
    const blue = Math.floor(startBlue + (endBlue - startBlue) * (happiness / 100));

    return `rgb(${red}, ${green}, ${blue})`;
  }

  // 获取表情图片
  private getFaceImage(happiness: number): Resource {
    if (happiness > 70) {
      return $r('app.media.happy');
    } else if (happiness > 30) {
      return $r('app.media.bland');
    } else {
      return $r('app.media.unhappy');
    }
  }

  // 格式化时间 (HH:MM)
  private formatTime(dateStr: string): string {
    console.log("该记录的时间为：" + dateStr)
    return dateStr.substring(11, 16); // 提取 "HH:mm" 部分
  }

  // 获取正文预览 (前两行)
  private getContentPreview(content: string): string {
    const lines = content.split('\n');
    if (lines.length <= 2) return content;
    return lines.slice(0, 2).join('\n');
  }

  // 删除确认弹窗
  @Builder
  buildDeleteModal() {
    if (this.showDeleteModal) {
      Column() {
        Text('确认删除？')
          .fontSize(20)
          .fontColor($r('app.color.daily_query_modal_title'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('记录将从本地删除')
          .fontSize(16)
          .fontColor($r('app.color.daily_query_modal_text'))
          .margin({ bottom: 30 })

        Row({ space: 30 }) {
          Button('取消')
            .backgroundColor($r('app.color.button_secondary'))
            .fontColor($r('app.color.text_primary'))
            .width(120)
            .onClick(() => {
              this.showDeleteModal = false;
            })

          Button('确认')
            .backgroundColor($r('app.color.daily_query_delete_button'))
            .fontColor($r('app.color.button_primary_text'))
            .width(120)
            .onClick(() => {
              this.deleteRecord(this.prepareToDeleteId);
              this.showDeleteModal = false;
              promptAction.showToast({ message: '删除成功', duration: 2000 });
            })
        }
      }
      .width('80%')
      .padding(20)
      .backgroundColor($r('app.color.modal_background'))
      .borderRadius(20)
      .zIndex(999) // 确保在最顶层
      .position({})
      .align(Alignment.Center)
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 顶部导航栏
          Row() {
            Image($r('app.media.ic_back'))
              .width(30)
              .height(30)
              .margin({ left: 15 })
              .onClick(() => this.backToCalendar())

            Text(`${this.selectedYear}年${this.selectedMonth}月${this.selectedDay}日`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.daily_query_nav_title'))
              .margin({ left: 20 })

            Blank()
          }
          .width('100%')
          .height(90)
          .backgroundColor($r('app.color.daily_query_nav_background'))
          .border({ width: { bottom: 1 }, color: $r('app.color.daily_query_nav_border') })
          .margin({ top: -20 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

          // 当天平均开心值区域 - 只在有记录时显示
          if (this.records.length > 0) {
            Column() {
              Text('当天平均开心值')
                .fontSize(18)
                .fontColor($r('app.color.daily_query_subtitle'))

              Stack({ alignContent: Alignment.Center }) {
                Circle()
                  .width(100)
                  .height(100)
                  .fill(this.getFaceColor(this.avgHappiness))

                Image(this.getFaceImage(this.avgHappiness))
                  .width(80)
                  .height(80)
                  .objectFit(ImageFit.Contain)
              }
              .margin({ top: 10, bottom: 10 })

              Text(`${this.avgHappiness}`)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .height('25%')
            .padding(20)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor($r('app.color.daily_query_average_bg'))
            .borderRadius(10)
            .margin({ top: 20, left: 20, right: 20 })
          }

          // 记录列表 - 只在有记录时显示
          if (this.records.length > 0) {
            List({ space: 10 }) {
              if (this.hasPopFromEdit == 0) {
                ForEach(this.records, (record: RecordData) => {
                  ListItem() {
                    Column() {
                      // 记录头部 - 时间、状态、表情
                      Row() {
                        Text(this.formatTime(record.date))
                          .fontSize(16)
                          .fontColor($r('app.color.daily_query_time_text'))

                        Blank()

                        Text(record.statusEmoji + ' ' + record.statusText)
                          .fontSize(16)
                          .fontColor($r('app.color.text_primary'))

                        Blank()

                        // 小表情
                        Image(this.getFaceImage(record.moodValue))
                          .width(30)
                          .height(30)
                          .objectFit(ImageFit.Contain)

                        Text(record.moodValue.toString())
                          .fontSize(16)
                          .fontColor($r('app.color.text_primary'))
                      }
                      .width('100%')
                      .margin({ bottom: 10 })

                      // 正文预览
                      Text(this.getContentPreview(record.content))
                        .fontSize(16)
                        .fontColor($r('app.color.text_primary'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ bottom: 10 })

                      // 操作按钮
                      Row() {
                        Button('查看')
                          .width(80)
                          .height(30)
                          .fontSize(14)
                          .backgroundColor($r('app.color.daily_query_view_button'))
                          .fontColor($r('app.color.button_primary_text'))
                          .onClick(() => this.navigateToEditPage(record))

                        Button('删除')
                          .width(80)
                          .height(30)
                          .fontSize(14)
                          .backgroundColor($r('app.color.daily_query_delete_button'))
                          .fontColor($r('app.color.button_primary_text'))
                          .margin({ left: 10 })
                          .onClick(() => {
                            this.showDeleteModal = true;
                            console.log("弹窗" + this.showDeleteModal)
                            this.prepareToDeleteId = record.id;
                            console.log("弹窗+" + this.prepareToDeleteId)
                          })
                      }
                      .justifyContent(FlexAlign.End)
                      .width('100%')
                    }
                    .padding(15)
                    .backgroundColor(this.getFaceColor(record.moodValue))
                    .borderRadius(10)
                    .border({ width: 1, color: $r('app.color.daily_query_record_border') })
                  }
                }, (record: RecordData) => record.id.toString())
              } else if (this.hasPopFromEdit == 1) {
                ForEach(this.records, (record: RecordData) => {
                  ListItem() {
                    Column() {
                      // 记录头部 - 时间、状态、表情
                      Row() {
                        Text(this.formatTime(record.date))
                          .fontSize(16)
                          .fontColor($r('app.color.daily_query_time_text'))

                        Blank()

                        Text(record.statusEmoji + ' ' + record.statusText)
                          .fontSize(16)
                          .fontColor($r('app.color.text_primary'))

                        Blank()

                        // 小表情
                        Image(this.getFaceImage(record.moodValue))
                          .width(30)
                          .height(30)
                          .objectFit(ImageFit.Contain)

                        Text(record.moodValue.toString())
                          .fontSize(16)
                          .fontColor($r('app.color.text_primary'))
                      }
                      .width('100%')
                      .margin({ bottom: 10 })

                      // 正文预览
                      Text(this.getContentPreview(record.content))
                        .fontSize(16)
                        .fontColor($r('app.color.text_primary'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ bottom: 10 })

                      // 操作按钮
                      Row() {
                        Button('查看')
                          .width(80)
                          .height(30)
                          .fontSize(14)
                          .backgroundColor($r('app.color.daily_query_view_button'))
                          .fontColor($r('app.color.button_primary_text'))
                          .onClick(() => this.navigateToEditPage(record))

                        Button('删除')
                          .width(80)
                          .height(30)
                          .fontSize(14)
                          .backgroundColor($r('app.color.daily_query_delete_button'))
                          .fontColor($r('app.color.button_primary_text'))
                          .margin({ left: 10 })
                          .onClick(() => {
                            this.showDeleteModal = true;
                            this.prepareToDeleteId = record.id;
                          })
                      }
                      .justifyContent(FlexAlign.End)
                      .width('100%')
                    }
                    .padding(15)
                    .backgroundColor(this.getFaceColor(record.moodValue))
                    .borderRadius(10)
                    .border({ width: 1, color: $r('app.color.daily_query_record_border') })
                  }
                }, (record: RecordData) => record.id.toString())
              }
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .padding(20)
          } else {
            // 没有记录时显示提示信息
            Column() {
              Text('这一天没有记录哟~')
                .fontSize(25)
                .fontColor($r('app.color.daily_query_empty_text'))
                .margin({ bottom: 100 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.daily_query_background'))
        //扩充组件安全区域
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        this.buildDeleteModal()
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.selectedYear = this.selectedDate.selectedYear
      this.selectedMonth = this.selectedDate.selectedMonth
      this.selectedDay = this.selectedDate.selectedDay
    })
    .onResult(() => {
      console.info('准备刷新')
      this.popFromEdit()
      console.info('刷新完毕')
    })
    .hideTitleBar(true)
  }
}

@Builder
export function DailyQueryPageBuilder() {
  DailyQueryPage()
}