//src/main/ets/pages/RecordCalendarPage.ets
import { RecordData } from '../models/RecordData';
import { AppStorageV2 } from '@kit.ArkUI';
import { GlobalDate } from '../models/GlobalDate';
import { RecordDatabase } from '../database/RecordDatabase';

// 颜色算法（保持不变）
function getFaceColor(moodValue: number): string {
  const startRed = 92, startGreen = 255, startBlue = 92;
  const endRed = 255, endGreen = 92, endBlue = 92;
  const red = Math.floor(startRed + (endRed - startRed) * (moodValue / 100));
  const green = Math.floor(startGreen + (endGreen - startGreen) * (moodValue / 100));
  const blue = Math.floor(startBlue + (endBlue - startBlue) * (moodValue / 100));
  return `rgb(${red}, ${green}, ${blue})`;
}

interface DateData {
  year: number;
  month: number;
  day: number | null;
  avgHappiness?: number;
  hasRecord?: boolean;
  dateKey?: string;
  dayOfWeek?: number; // 0=周日,6=周六
}

@ComponentV2
export struct RecordCalendarPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!
  globalDate: GlobalDate = AppStorageV2.connect(GlobalDate, 'DATE_KEY', () => new GlobalDate())!

  @Local currentYear: number = new Date().getFullYear();
  @Local currentMonth: number = new Date().getMonth() + 1;
  @Local calendarData: Array<DateData> = [];
  @Local dayAvgMap: Map<string, number> = new Map();
  // 星期标题顺序：周日 -> 周六
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  private recordDb: RecordDatabase = RecordDatabase.getInstance();

  // 修改 aboutToAppear 方法
  async aboutToAppear(): Promise<void> {
    console.log("开始初始化数据库");

    try {
      // 等待数据库初始化完成
      await this.recordDb.initialize(getContext(this));
      console.log("数据库初始化成功");

      // 初始化完成后再加载数据
      await this.loadRecordsAndUpdateCalendar();
    } catch (error) {
      console.error('数据库初始化失败:', error);
      // 可以在这里添加用户提示
    }
  }

  // 修改为使用数据库加载记录
  private async loadRecordsAndUpdateCalendar(): Promise<void> {
    console.log('[RecordCalendarPage] 开始从数据库加载记录数据');

    try {
      // 从数据库查询所有记录
      const allRecords = await this.recordDb.queryAllRecords();
      console.log(`[RecordCalendarPage] 从数据库获取的记录数量: ${allRecords.length}`);

      const dayMap = new Map<string, number[]>();

      // 处理记录数据
      allRecords.forEach((record: RecordData) => {
        const moodValue = record.moodValue;

        if (isNaN(moodValue)) {
          console.error('[RecordCalendarPage] 无效的moodValue:', record.moodValue);
          return;
        }

        // 使用数据库中的日期格式（已经是 yyyy-MM-dd）
        const dateKey = record.date.substring(0, 10);

        if (!dayMap.has(dateKey)) {
          dayMap.set(dateKey, []);
        }
        dayMap.get(dateKey)!.push(moodValue);
      });

      // 计算每日平均开心值
      const avgMap = new Map<string, number>();
      dayMap.forEach((values, date) => {
        const sum = values.reduce((acc, val) => acc + val, 0);
        const avg = sum / values.length;
        avgMap.set(date, Math.round(avg));
      });

      this.dayAvgMap = avgMap;
      this.calendarData = this.generateCalendar(this.currentYear, this.currentMonth);

    } catch (error) {
      console.error('[RecordCalendarPage] 从数据库加载记录失败:', error);
      this.dayAvgMap = new Map();
      this.calendarData = this.generateCalendar(this.currentYear, this.currentMonth);
    }
  }

  // 生成日历数据
  private generateCalendar(year: number, month: number): DateData[] {
    const firstDayObj = new Date(Date.UTC(year, month - 1, 1));
    const firstDayOfWeek = firstDayObj.getUTCDay();
    const daysInMonth = new Date(Date.UTC(year, month, 0)).getUTCDate();

    const calendar: DateData[] = [];

    // 添加空白天数
    for (let i = 0; i < firstDayOfWeek; i++) {
      calendar.push({ year, month, day: null });
    }

    // 添加当月所有日期
    for (let i = 1; i <= daysInMonth; i++) {
      const dateKey = `${year}-${month.toString().padStart(2, '0')}-${i.toString().padStart(2, '0')}`;
      const avg = this.dayAvgMap.get(dateKey);

      calendar.push({
        year,
        month,
        day: i,
        dateKey,
        hasRecord: avg !== undefined,
        avgHappiness: avg,
        dayOfWeek: (firstDayOfWeek + i - 1) % 7
      });
    }

    // 确保日历是完整的6行（42个单元格）
    const totalCells = 42;
    const remainingCells = totalCells - calendar.length;
    for (let i = 1; i <= remainingCells; i++) {
      calendar.push({ year, month, day: null });
    }

    return calendar;
  }

  private prevMonth(): void {
    if (this.currentMonth === 1) {
      this.currentYear -= 1;
      this.currentMonth = 12;
    } else {
      this.currentMonth -= 1;
    }
    this.calendarData = this.generateCalendar(this.currentYear, this.currentMonth);
  }

  private nextMonth(): void {
    if (this.currentMonth === 12) {
      this.currentYear += 1;
      this.currentMonth = 1;
    } else {
      this.currentMonth += 1;
    }
    this.calendarData = this.generateCalendar(this.currentYear, this.currentMonth);
  }

  private getDateBgColor(avgHappiness: number | undefined): string {
    if (avgHappiness === undefined) return 'transparent';
    return getFaceColor(avgHappiness);
  }

  private onDateClick(dateData: DateData): void {
    if (dateData.day === null) return;

    this.globalDate.selectedYear = dateData.year;
    this.globalDate.selectedMonth = dateData.month;
    this.globalDate.selectedDay = dateData.day;
    this.pageStack.pushPathByName('DailyQueryPage', false, null);
  }

  private gotoStatsPage(): void {
    this.pageStack.pushPathByName('StatsPage', false, null);
  }

  build() {
    Column() {
      // 添加标题
      Text('我的情绪日历')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.calendar_title')) // 使用颜色资源
        .margin({ top: 30, bottom: 20 })

      // 整合所有日历元素到一个大卡片中
      Column() {
        // 月份导航行 - 顶部
        Row() {
          Button('<')
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.calendar_nav_button')) // 使用颜色资源
            .fontColor($r('app.color.calendar_nav_button_text')) // 使用颜色资源
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .borderRadius(20)
            .onClick(() => this.prevMonth())

          Text(`${this.currentYear}年${this.currentMonth}月`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.calendar_month_text')) // 使用颜色资源
            .margin({ left: 20, right: 20 })

          Button('>')
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.calendar_nav_button')) // 使用颜色资源
            .fontColor($r('app.color.calendar_nav_button_text')) // 使用颜色资源
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .borderRadius(20)
            .onClick(() => this.nextMonth())
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10, bottom: 20 })

        // 星期标题行 - 中间
        Row() {
          ForEach(this.weekDays, (day: string, index: number) => {
            Text(day)
              .width('14%') // 7列，每列约14%宽度
              .fontColor($r('app.color.calendar_weekday_text')) // 使用颜色资源
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .padding(5)
          }, (day: string) => day)
        }
        .margin({ bottom: 10 })

        // 日历网格 - 底部
        Grid() {
          ForEach(this.calendarData, (dateItem: DateData, index: number) => {
            GridItem() {
              if (dateItem.day === null) {
                Text('')
                  .width('100%')
                  .height(60)
              } else {
                // 增加日期卡片宽度
                Column() {
                  // 日期数字 - 加大字号并加粗
                  Text(dateItem.day.toString())
                    .fontSize(20) // 增大字号
                    .fontWeight(FontWeight.Bold) // 加粗
                    .fontColor(dateItem.hasRecord ? $r('app.color.calendar_date_has_record') : $r('app.color.calendar_date_no_record')) // 使用颜色资源
                    .margin({ bottom: dateItem.hasRecord ? 2 : 0 })

                  // 如果有记录，显示心情值 - 使用较小字号
                  if (dateItem.hasRecord) {
                    Text(`${dateItem.avgHappiness}`) // 添加心形符号
                      .fontSize(12) // 较小字号
                      .fontColor($r('app.color.calendar_mood_text')) // 使用颜色资源
                      .opacity(0.9) // 稍微降低透明度
                      .textOverflow({ overflow: TextOverflow.Ellipsis }) // 防止溢出
                      .maxLines(1) // 确保单行显示
                  }
                }
                .width('100%')
                .height(60)
                .justifyContent(FlexAlign.Center)
                .borderRadius(8)
                .backgroundColor(dateItem.hasRecord ? this.getDateBgColor(dateItem.avgHappiness) : 'transparent')
                .border({
                  width: dateItem.hasRecord ? 0 : 1,
                  color: $r('app.color.calendar_date_border'), // 使用颜色资源
                  radius: 8
                })
                .onClick(() => this.onDateClick(dateItem))
                .shadow(dateItem.hasRecord ? { radius: 3, color: '#40000000', offsetX: 1, offsetY: 2 } : null)
              }
            }
          }, (dateItem: DateData) => JSON.stringify(dateItem))
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr') // 7列，与星期标题对应
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .height(350) // 减小高度
      }
      .width('98%') // 增加宽度（原为95%）
      .padding(20)
      .backgroundColor($r('app.color.calendar_card_background')) // 使用颜色资源
      .borderRadius(20)
      .shadow({ radius: 10, color: '#30000000', offsetX: 0, offsetY: 5 })
      .margin({ bottom: 10 }) // 减小底部边距

      // 查询按钮
      Button('查询能量曲线')
        .onClick(() => this.gotoStatsPage())
        .width('70%')
        .height(50)
        .margin(20) // 减小边距
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.calendar_button_text')) // 使用颜色资源
        .backgroundColor($r('app.color.calendar_button_background')) // 使用颜色资源
        .borderRadius(25)
        .shadow({ radius: 5, color: '#40000000', offsetX: 0, offsetY: 3 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor($r('app.color.calendar_background')) // 使用颜色资源
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center) // 居中显示
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@Builder
export function RecordCalendarPageBuilder() {
  RecordCalendarPage()
}