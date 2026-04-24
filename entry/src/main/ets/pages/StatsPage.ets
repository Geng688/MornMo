import { RecordData } from '../models/RecordData';
import { CurveChart } from '../components/CurveChart';
import { RecordDatabase } from '../database/RecordDatabase';

// 定义接口和类型
interface DataItem {
  date: string;
  value: number;
}

interface ProcessedData {
  data: DataItem[];
  assessment: string;
}

interface EnergyDistributionItem {
  range: string; // 区间范围
  count: number; // 天数
  color: Resource; // 对应的颜色
}

// 能量水平评估函数
function getEnergyLevel(daysInRange: Map<string, number>): string {
  let tooLow = 0, low = 0, normal = 0, high = 0, tooHigh = 0;

  daysInRange.forEach((value: number) => {
    if (value >= 0 && value < 20) tooLow++;
    else if (value >= 20 && value < 40) low++;
    else if (value >= 40 && value < 60) normal++;
    else if (value >= 60 && value < 80) high++;
    else if (value >= 80 && value <= 100) tooHigh++;
  });

  const totalDays = tooLow + low + normal + high + tooHigh;
  if (totalDays === 0) return "暂无数据";

  if (tooLow >= totalDays * 0.6) return "能量太低";
  if (low >= totalDays * 0.6) return "能量偏低";
  if (normal >= totalDays * 0.6) return "能量平稳";
  if (high >= totalDays * 0.6) return "能量较高";
  if (tooHigh >= totalDays * 0.6) return "能量很高";

  return "能量波动较大";
}

@Component
struct StatsPage {
  pageStack: NavPathStack = new NavPathStack();
  @State currentTab: string = 'week'; // 'week' 或 'month'
  @State weekData: DataItem[] = [];
  @State monthData: DataItem[] = [];
  @State energyAssessment: string = '';
  @State selectedDateRange: string = '';
  @State selectedDateRangeWeek: string = '';
  @State selectedDateRangeMonth: string = '';
  @State energyDistribution: EnergyDistributionItem[] = [];
  @State maxCount: number = 0; // 用于计算能量条最大长度

  // 数据库实例
  private recordDb: RecordDatabase = RecordDatabase.getInstance();

  aboutToAppear(): void {
    // 初始化数据库
    this.recordDb.initialize(getContext(this));
    this.loadStatsData();
  }

  // 加载统计数据 - 修改为使用数据库
  private async loadStatsData(): Promise<void> {
    try {
      // 从数据库查询所有记录
      const allRecords = await this.recordDb.queryAllRecords();
      console.log(`[StatsPage] 从数据库获取的记录数量: ${allRecords.length}`);

      // 分别处理周和月数据
      const weekData = this.processDataForPeriod(allRecords, 'week');
      this.weekData = weekData.data;
      console.log(`[StatsPage] 本周数据量: ${this.weekData.length}`);

      const monthData = this.processDataForPeriod(allRecords, 'month');
      this.monthData = monthData.data;
      console.log(`[StatsPage] 本月数据量: ${this.monthData.length}`);

      this.onTabChange('week');
      this.calculateEnergyDistribution();
    } catch (error) {
      console.error('[StatsPage] 从数据库加载记录失败:', error);
      this.weekData = [];
      this.monthData = [];
      this.energyAssessment = "暂无数据";
    }
  }

  // 处理特定时间段的数据 - 重点修复月份逻辑
  private processDataForPeriod(records: RecordData[], period: string): ProcessedData {
    const now = new Date();
    const currentYear = now.getFullYear(); // 提升到函数作用域，确保全局可访问
    const currentMonth = now.getMonth();   // 提升到函数作用域，确保全局可访问
    let startDate: Date;
    let endDate: Date = new Date();

    if (period === 'week') {
      // 本周逻辑（周日到周六）
      startDate = new Date(now);
      startDate.setDate(now.getDate() - now.getDay());
      startDate.setHours(0, 0, 0, 0);

      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6);
      endDate.setHours(23, 59, 59, 999);

      this.selectedDateRangeWeek = `${startDate.getMonth() + 1}月${startDate.getDate()}日-${endDate.getMonth() + 1}月${endDate.getDate()}日`;
      console.info('日期范围'+this.selectedDateRange)
    } else {
      // 本月逻辑（当月1号到当前日期）
      startDate = new Date(currentYear, currentMonth, 1); // 当月1号 00:00:00
      startDate.setHours(0, 0, 0, 0);

      endDate = new Date(currentYear, currentMonth + 1, 0); // 当月最后一天
      endDate.setHours(23, 59, 59, 999);

      // 如果今天早于当月最后一天，结束日期设为今天
      if (now.getTime() < endDate.getTime()) {
        endDate = new Date(now);
        endDate.setHours(23, 59, 59, 999);
      }

      this.selectedDateRangeMonth = `${currentMonth + 1}月1日-${currentMonth + 1}月${endDate.getDate()}日`;
      console.info('日期范围'+this.selectedDateRange)
    }

    // 筛选指定日期范围内的记录
    const periodRecords = records.filter((record: RecordData) => {
      const recordDate = new Date(record.date);
      const isInRange = recordDate >= startDate && recordDate <= endDate;
      if (period === 'month') {
        // 额外验证年份和月份，确保只包含当前月数据
        return isInRange &&
          recordDate.getFullYear() === currentYear &&
          recordDate.getMonth() === currentMonth;
      }
      return isInRange;
    });

    const dayMap = new Map<string, number[]>();
    periodRecords.forEach((record: RecordData) => {
      const recordDate = new Date(record.date);
      let dateKey = '';

      if (period === 'week') {
        // 周模式：显示"周X"（如"周一"）
        dateKey = `周${['日', '一', '二', '三', '四', '五', '六'][recordDate.getDay()]}`;
      } else {
        // 月模式：显示"*月*日"（如"9月3日"）
        dateKey = `${recordDate.getMonth() + 1}月${recordDate.getDate()}日`;
      }

      const moodValue = typeof record.moodValue === 'string'
        ? parseInt(record.moodValue)
        : record.moodValue;

      if (!isNaN(moodValue)) {
        if (!dayMap.has(dateKey)) {
          dayMap.set(dateKey, []);
        }
        dayMap.get(dateKey)!.push(moodValue);
      }
    });

    // 处理结果数据并排序
    const resultData: DataItem[] = [];
    const assessmentMap = new Map<string, number>();

    dayMap.forEach((values: number[], date: string) => {
      const avg = Math.round(values.reduce((sum, val) => sum + val, 0) / values.length);
      resultData.push({ date, value: avg });
      assessmentMap.set(date, avg);
    });

    resultData.sort((a, b) => {
      if (period === 'week') {
        const weekOrder: Record<string, number> = { '周日': 0, '周一': 1, '周二': 2, '周三': 3, '周四': 4, '周五': 5, '周六': 6 };
        return (weekOrder[a.date] || 0) - (weekOrder[b.date] || 0);
      } else {
        // 月模式：按日期（如"9月3日"提取3）排序
        const aDay = parseInt(a.date.match(/\d+日/)?.[0] || '0');
        const bDay = parseInt(b.date.match(/\d+日/)?.[0] || '0');
        return aDay - bDay;
      }
    });

    return {
      data: resultData,
      assessment: getEnergyLevel(assessmentMap)
    };
  }

  // 选项卡切换 - 确保数据正确切换
  private onTabChange(tab: string): void {
    this.currentTab = tab;
    const data = tab === 'week' ? this.weekData : this.monthData;
    if(tab === 'week'){
      this.selectedDateRange=this.selectedDateRangeWeek;
    }else{
      this.selectedDateRange=this.selectedDateRangeMonth;
    }
    console.log(`[StatsPage] 切换到${tab === 'week' ? '本周' : '本月'}，数据量: ${data.length}`);

    const assessmentMap = new Map<string, number>();
    data.forEach(item => assessmentMap.set(item.date, item.value));
    this.energyAssessment = getEnergyLevel(assessmentMap);

    this.calculateEnergyDistribution();
  }

  private calculateEnergyDistribution(): void {
    const data = this.currentTab === 'week' ? this.weekData : this.monthData;

    // 初始化分布数组
    const distribution: EnergyDistributionItem[] = [
      { range: "0-20", count: 0, color: $r('app.color.stats_energy_low') },
      { range: "20-40", count: 0, color: $r('app.color.stats_energy_low_medium') },
      { range: "40-60", count: 0, color: $r('app.color.stats_energy_medium') },
      { range: "60-80", count: 0, color: $r('app.color.stats_energy_high_medium') },
      { range: "80-100", count: 0, color: $r('app.color.stats_energy_high') }
    ];

    // 统计各区间天数
    data.forEach(item => {
      const value = item.value;
      if (value >= 0 && value < 20) distribution[0].count++;
      else if (value >= 20 && value < 40) distribution[1].count++;
      else if (value >= 40 && value < 60) distribution[2].count++;
      else if (value >= 60 && value < 80) distribution[3].count++;
      else if (value >= 80 && value <= 100) distribution[4].count++;
    });

    // 计算最大天数（用于能量条比例）
    this.maxCount = Math.max(...distribution.map(item => item.count), 1);

    // 更新状态
    this.energyDistribution = distribution;
  }

  // 返回日历页面
  private backToCalendar(): void {
    this.pageStack.pop();
  }

  // 根据能量评估结果获取颜色
  private getEnergyColor(assessment: string): Resource {
    switch (assessment) {
      case '能量太低': return $r('app.color.stats_assessment_low');
      case '能量偏低': return $r('app.color.stats_assessment_low_medium');
      case '能量平稳': return $r('app.color.stats_assessment_medium');
      case '能量较高': return $r('app.color.stats_assessment_high_medium');
      case '能量很高': return $r('app.color.stats_assessment_high');
      case '能量波动较大': return $r('app.color.stats_assessment_fluctuate');
      default: return $r('app.color.stats_assessment_default');
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => this.backToCalendar())
            .fillColor($r('app.color.stats_nav_icon'))

          Text('能量曲线分析')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
            .fontColor($r('app.color.stats_nav_title'))

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.stats_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.stats_nav_border') })
        .alignItems(VerticalAlign.Center)
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 选项卡
        Row() {
          Text('本周')
            .fontSize(16)
            .fontColor(this.currentTab === 'week' ?
            $r('app.color.stats_tab_active_text') : $r('app.color.stats_tab_inactive_text'))
            .padding(12)
            .backgroundColor(this.currentTab === 'week' ?
            $r('app.color.stats_tab_active_background') : $r('app.color.stats_tab_inactive_background'))
            .borderRadius(8)
            .onClick(() => this.onTabChange('week'))

          Text('本月')
            .fontSize(16)
            .fontColor(this.currentTab === 'month' ?
            $r('app.color.stats_tab_active_text') : $r('app.color.stats_tab_inactive_text'))
            .padding(12)
            .margin({ left: 16 })
            .backgroundColor(this.currentTab === 'month' ?
            $r('app.color.stats_tab_active_background') : $r('app.color.stats_tab_inactive_background'))
            .borderRadius(8)
            .onClick(() => this.onTabChange('month'))
        }
        .margin({ top: 10 })
        .justifyContent(FlexAlign.Center)

        // 日期范围显示
        if (this.currentTab === 'week' ){
          Text(this.selectedDateRange)
            .fontSize(14)
            .fontColor($r('app.color.stats_date_range'))
            .margin({ top: 8 })
        }else if(this.currentTab === 'month'){
          Text(this.selectedDateRange)
            .fontSize(14)
            .fontColor($r('app.color.stats_date_range'))
            .margin({ top: 8 })
        }


        // 曲线图表区域
        Column() {
          if (this.currentTab === 'week' && this.weekData.length > 0) {
            Scroll() {
              CurveChart({
                data: this.currentTab === 'week' ? this.weekData : this.monthData,
                itemWidth: this.currentTab === 'week' ? 20 : 60,
                chartHeight: 260 // 减小高度
              })
            }
            .scrollable(ScrollDirection.Horizontal)
            .width('100%')
          } else if (this.currentTab === 'month' && this.monthData.length > 0) {
            Scroll() {
              CurveChart({
                data: this.currentTab === 'month' ? this.monthData : this.weekData,
                itemWidth: this.currentTab === 'month' ? 60 : 20,
                chartHeight: 260 // 减小高度
              })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.On)
            .scrollBarColor(Color.Gray)
            .scrollBarWidth(6)
            .padding({ left: 20, right: 20 })
          } else {
            Text('暂无数据')
              .fontSize(16)
              .fontColor($r('app.color.stats_empty_text'))
              .margin({ top: 60 })
          }
        }
        .width('100%')
        .height(280) // 减小高度（原为300）
        .margin({ top: 16})

        // 能量分布统计卡片 - 高度减小
        Scroll() {
          Column() {
            if (this.currentTab === 'week' && this.weekData.length > 0) {
              // 能量分布统计卡片
              Column() {
                Text('能量评估')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.stats_card_title'))
                  .margin({ bottom: 5, top: 0 })

                Text(this.energyAssessment)
                  .fontSize(24)
                  .fontColor(this.getEnergyColor(this.energyAssessment))
                  .margin({ top: 5 })

                // 显示能量区间分布
                ForEach(this.energyDistribution, (item: EnergyDistributionItem) => {
                  Column({ space: 5 }) {
                    // 区间标签和天数
                    Row() {
                      Text(`${item.range}:`)
                        .fontSize(16)
                        .fontColor($r('app.color.stats_range_label'))
                        .layoutWeight(1)

                      Text(`${item.count}天`)
                        .fontSize(16)
                        .fontColor($r('app.color.stats_range_count'))
                        .fontWeight(FontWeight.Bold)
                    }
                    .width('100%')

                    // 能量条
                    Row() {
                      // 能量条主体
                      Row()
                        .width(`${(item.count / this.maxCount) * 100}%`)
                        .height(10)
                        .backgroundColor(item.color)
                        .borderRadius(5)

                      // 空白填充
                      Blank()
                    }
                    .width('100%')
                    .height(10)
                    .backgroundColor($r('app.color.stats_bar_background'))
                    .borderRadius(5)
                  }
                  .width('100%')
                  .margin({ bottom: 5 })
                }, (item: EnergyDistributionItem) => item.range)
              }
              .padding(15)
              .backgroundColor($r('app.color.stats_card_background'))
              .borderRadius(15)
              .margin({ top: 15 })
              .shadow({
                radius: 5,
                color: '#20000000',
                offsetX: 0,
                offsetY: 3
              })
            } else if (this.currentTab === 'month' && this.monthData.length > 0) {
              // 能量分布统计卡片
              Column() {
                Text('能量评估')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.stats_card_title'))
                  .margin({ bottom: 5, top: 0 })

                Text(this.energyAssessment)
                  .fontSize(24)
                  .fontColor(this.getEnergyColor(this.energyAssessment))
                  .margin({ top: 5 })

                // 显示能量区间分布
                ForEach(this.energyDistribution, (item: EnergyDistributionItem) => {
                  Column({ space: 5 }) {
                    // 区间标签和天数
                    Row() {
                      Text(`${item.range}:`)
                        .fontSize(16)
                        .fontColor($r('app.color.stats_range_label'))
                        .layoutWeight(1)

                      Text(`${item.count}天`)
                        .fontSize(16)
                        .fontColor($r('app.color.stats_range_count'))
                        .fontWeight(FontWeight.Bold)
                    }
                    .width('100%')

                    // 能量条
                    Row() {
                      // 能量条主体
                      Row()
                        .width(`${(item.count / this.maxCount) * 100}%`)
                        .height(10)
                        .backgroundColor(item.color)
                        .borderRadius(5)

                      // 空白填充
                      Blank()
                    }
                    .width('100%')
                    .height(10)
                    .backgroundColor($r('app.color.stats_bar_background'))
                    .borderRadius(5)
                  }
                  .width('100%')
                  .margin({ bottom: 5 })
                }, (item: EnergyDistributionItem) => item.range)
              }
              .padding(15)
              .backgroundColor($r('app.color.stats_card_background'))
              .borderRadius(15)
              .margin({ top: 15 })
              .shadow({
                radius: 5,
                color: '#20000000',
                offsetX: 0,
                offsetY: 3
              })
            } else {
              Text('暂无数据')
                .fontSize(16)
                .fontColor($r('app.color.stats_empty_text'))
                .margin({ top: 60 })
            }
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .height('40%') // 设置适当的高度
        .margin({ top: 0 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.stats_background'))
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function StatsPageBuilder() {
  StatsPage()
}