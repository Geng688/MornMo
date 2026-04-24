// src/main/ets/pages/MoodGardenPage.ets
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { AppStorageV2 } from "@kit.ArkUI";

@Component
export struct MoodGardenPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!

  private controller: VideoController = new VideoController()
  private previewUris: Resource = $r('app.media.videopreview')
  private innerResource: Resource = $rawfile('gardenvideo.mp4')

  @State waterValue: number = 0;
  @State growthValue: number = 0;
  @State plantName: string = '我的心情植物';
  @State lastWaterTime: string = '尚未浇水';
  @State isWatering: boolean = false;

  // 控制弹窗显示状态
  @State showGrowthDetail: boolean = false;
  @State showWaterDetail: boolean = false;
  @State showRenameInput: boolean = false;
  @State showInstructions: boolean = false;
  @State showWaterConfirm: boolean = false;
  @State showReplantConfirm: boolean = false;

  // 浇水参数
  private readonly unitWater: number = 1;
  private readonly unitGrow: number = 5;

  @State flowersNum: number = 0; // 新增：已种植花的数量
  @State showFlowersNum: boolean = false; // 新增：控制花朵数量弹窗显示

  // 定义preferences的key
  private WATER_KEY: string = 'water_value';
  private GROWTH_KEY: string = 'growth_value';
  private PLANT_NAME_KEY: string = 'plant_name';
  private LAST_WATER_TIME_KEY: string = 'last_water_time';
  private FLOWERS_NUM_KEY: string = 'flowers_num'; // 新增：花朵数量key
  private PREFERENCES_NAME: string = 'mood_garden_data';

  aboutToAppear() {
    this.loadWaterData();
  }

  // 加载数据
  private async loadWaterData(): Promise<void> {
    try {
      const context = getContext(this) as Context;
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      this.waterValue = await pref.get(this.WATER_KEY, 0) as number;
      this.growthValue = await pref.get(this.GROWTH_KEY, 0) as number;
      this.plantName = await pref.get(this.PLANT_NAME_KEY, '我的心情植物') as string;
      this.lastWaterTime = await pref.get(this.LAST_WATER_TIME_KEY, '尚未浇水') as string;
      this.flowersNum = await pref.get(this.FLOWERS_NUM_KEY, 0) as number; // 新增：加载花朵数量

    } catch (error) {
      console.error('加载数据失败:', error);
      this.waterValue = 0;
      this.growthValue = 0;
      this.plantName = '我的心情植物';
      this.lastWaterTime = '尚未浇水';
      this.flowersNum = 0; // 新增：错误时重置
    }
  }

  // 浇水方法
  private async waterPlant(): Promise<void> {
    if (this.isWatering) return;

    if (this.waterValue < this.unitWater) {
      promptAction.showToast({
        message: `水值不足，无法浇水！(需要${this.unitWater}点)`,
        duration: 2000
      });
      return;
    }

    this.isWatering = true;
    this.showWaterConfirm = false;

    try {
      const context = getContext(this) as Context;
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      this.waterValue -= this.unitWater;
      this.growthValue += this.unitGrow;

      const now = new Date();
      const timeStr = `${now.getMonth() + 1}月${now.getDate()}日 ${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      this.lastWaterTime = timeStr;

      await pref.put(this.WATER_KEY, this.waterValue);
      await pref.put(this.GROWTH_KEY, this.growthValue);
      await pref.put(this.LAST_WATER_TIME_KEY, timeStr);
      await pref.flush();

      promptAction.showToast({
        message: `浇水成功！消耗${this.unitWater}点水值，生长值+${this.unitGrow}`,
        duration: 2000
      });

    } catch (error) {
      console.error('浇水失败:', error);
      promptAction.showToast({
        message: '浇水失败，请重试',
        duration: 2000
      });
    } finally {
      this.isWatering = false;
    }
  }

  // 重新种植方法
  private async replant(): Promise<void> {
    try {
      const context = getContext(this) as Context;
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      // 只有当生长值达到100时，才增加flowersNum
      if (this.growthValue >= 100) {
        this.flowersNum += 1;
        await pref.put(this.FLOWERS_NUM_KEY, this.flowersNum);
      }

      //this.waterValue = 0;
      this.growthValue = 0;

     // await pref.put(this.WATER_KEY, 0);
      await pref.put(this.GROWTH_KEY, 0);
      await pref.flush();

      this.showReplantConfirm = false;
      promptAction.showToast({
        message: '重新种植成功！植物已重置',
        duration: 2000
      });

    } catch (error) {
      console.error('重新种植失败:', error);
      promptAction.showToast({
        message: '重新种植失败，请重试',
        duration: 2000
      });
    }
  }

  // 修改植物名称
  private async changePlantName(): Promise<void> {
    try {
      const context = getContext(this) as Context;
      const pref = await preferences.getPreferences(context, this.PREFERENCES_NAME);

      await pref.put(this.PLANT_NAME_KEY, this.plantName);
      await pref.flush();

      this.showRenameInput = false;
      promptAction.showToast({
        message: '植物名称已更新',
        duration: 2000
      });
    } catch (error) {
      console.error('更新植物名称失败:', error);
    }
  }

  // 获取植物状态
  // private getPlantStatus(): string {
  //   if (this.growthValue >= 200) return '🌳 繁茂生长';
  //   if (this.growthValue >= 100) return '🌱 健康成长';
  //   if (this.growthValue >= 50) return '🌿 正常生长';
  //   if (this.growthValue >= 20) return '🍀 幼苗期';
  //   if (this.growthValue > 0) return '🌱 刚刚发芽';
  //   return '🌱 等待发芽';
  // }

  // 获取植物图片
  private getPlantImage(): Resource {
    if (this.growthValue >= 100) return $r('app.media.plant6'); // 第6阶段：100+生长值
    if (this.growthValue >= 80) return $r('app.media.plant5');  // 第5阶段：80-99生长值
    if (this.growthValue >= 55) return $r('app.media.plant4');  // 第4阶段：60-79生长值
    if (this.growthValue >= 30) return $r('app.media.plant3');  // 第3阶段：40-59生长值
    if (this.growthValue >= 10) return $r('app.media.plant2');  // 第2阶段：20-39生长值
    if (this.growthValue >= 0) return $r('app.media.plant1');    // 第1阶段：1-19生长值
    return $r('app.media.plant1');                              // 第0阶段：0生长值
  }

  // 获取进度条颜色
  private getProgressColor(value: number, thresholds: number[]): Resource {
    if (value >= thresholds[0]) return $r('app.color.primary_color');
    if (value >= thresholds[1]) return $r('app.color.choice_option_bg');
    return $r('app.color.choice_edit_button_bg');
  }

  // 构建悬浮球 - 修复：添加位置参数
  @Builder
  private buildFloatingBall(icon: string, title: string, x: string, y: string, onClick: () => void) {
    // 注意：这里不传递value参数，直接在内部使用状态变量
    Column() {
      // 悬浮球主体
      Column() {
        Text(icon)
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)

        // 根据图标判断显示哪个值
        if (icon === '🌱') {
          Text(this.growthValue.toString())
            .fontSize(12)
            .fontColor(Color.White)
            .margin({ top: 2 })
            .textAlign(TextAlign.Center)
        } else if (icon === '💧') {
          Text(this.waterValue.toString())
            .fontSize(12)
            .fontColor(Color.White)
            .margin({ top: 2 })
            .textAlign(TextAlign.Center)
        }else if (icon === '🌼') { // 新增：花朵数量图标
          Text(this.flowersNum.toString())
            .fontSize(12)
            .fontColor(Color.White)
            .margin({ top: 2 })
            .textAlign(TextAlign.Center)
        }
      }
      .width(50)
      .height(50)
      .backgroundColor('#D2691E')
      .borderRadius(25)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
      .onClick(() => {
        onClick();
      })

      Column(){
        // 小标题
        Text(title)
          .fontSize(11)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)  // 加粗
          .margin({ top: 4 })
          .textAlign(TextAlign.Center)
      }
      .backgroundColor('#80000000')  // 80%透明度的黑色背景
      .borderRadius(8)  // 圆角
      .padding({ left: 3, right: 3, top: 1, bottom: 1 })  // 内边距
      .margin({ top: 2,bottom:4 })
      .shadow({ radius: 2, color: '#40000000', offsetX: 0, offsetY: 1 })  // 添加阴影


    }
    .position({ x: x, y: y })
    .alignItems(HorizontalAlign.Center)
  }

  // 构建花朵数量详情弹窗
  @Builder
  private buildFlowersNumModal() {
    if (this.showFlowersNum) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showFlowersNum = false;
          })

        Column() {
          Row() {
            Text('🌼 开心花数量')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor('transparent')
              .onClick(() => {
                this.showFlowersNum = false;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          Column({ space: 8 }) {
            Row() {
              Text('已种植开心花:')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))

              Text(this.flowersNum.toString())
                .fontSize(24)
                .fontColor($r('app.color.primary_color'))
                .fontWeight(FontWeight.Bold)
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            // 花朵数量说明
            Column({ space: 8 }) {
              Text('🌼 获取规则:')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })

              Row() {
                Text('1.')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ right: 8 })

                Column({ space: 2 }) {
                  Text('将开心花培育到100生长值')
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                  Text('(健康生长状态)')
                    .fontSize(12)
                    .fontColor($r('app.color.mbti_progress_foreground'))
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row() {
                Text('2.')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ right: 8 })

                Column({ space: 2 }) {
                  Text('点击"种新花"按钮')
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                  Text('(种成功的花将被保存下来)')
                    .fontSize(12)
                    .fontColor($r('app.color.mbti_progress_foreground'))
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row() {
                Text('3.')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ right: 8 })

                Column({ space: 2 }) {
                  Text('自动增加1朵已种植开心花')
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                  Text('(永久记录)')
                    .fontSize(12)
                    .fontColor($r('app.color.mbti_progress_foreground'))
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_background') || '#F9F9F9')
            .borderRadius(8)
            .margin({ top: 12 })

            // 鼓励文本
            Text('继续培育更多开心花，记录你的美好心情绽放吧！')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
              .margin({ top: 16 })
          }
        }
        .width('80%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建水值详情弹窗
  @Builder
  private buildWaterDetailModal() {
    if (this.showWaterDetail) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showWaterDetail = false;
          })

        // 弹窗内容
        Column() {
          Row() {
            Text('💧 开心水详情')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor('transparent')
              .onClick(() => {
                this.showWaterDetail = false;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 水值显示
          Column({ space: 8 }) {
            Row() {
              Text('当前拥有的开心水:')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))

              Text(this.waterValue.toString())
                .fontSize(24)
                .fontColor('#4A90E2')
                .fontWeight(FontWeight.Bold)
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            // // 使用 Progress 组件实现水值进度条
            // Row({ space: 12 }) {
            //   Text(`进度：${this.waterValue}/50`)
            //     .fontSize(16)
            //     .fontColor($r('app.color.text_primary'))
            //
            //   Blank()
            //
            //   // 使用 Progress 组件实现从左向右的进度条
            //   Progress({
            //     value: this.waterValue,
            //     total: 50, // 水值最大为50
            //     type: ProgressType.Linear
            //   })
            //     .width('60%')
            //     .height(6)
            //     .backgroundColor($r('app.color.mbti_progress_background') || '#E0E0E0')
            //     .color(this.getProgressColor(this.waterValue, [20, 10]))
            //     .borderRadius(3)
            // }
            // .width('100%')
            // .padding(12)
            // .backgroundColor($r('app.color.modal_background') || '#F5F5F5')
            // .borderRadius(8)
            // .margin({ top: 8, bottom: 8 })

            // 水值获取说明
            Column() {
              Text('💧 开心水获取说明:')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill($r('app.color.primary_color'))
                  .margin({ right: 8 })

                Text('每保存一条心情记录，获得1点开心水')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill($r('app.color.primary_color'))
                  .margin({ right: 8 })

                Text(`每添加一条心理暗示，获得3点开心水`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill($r('app.color.primary_color'))
                  .margin({ right: 8 })

                Text(`每发送一封时光邮件，获得5点开心水`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill($r('app.color.primary_color'))
                  .margin({ right: 8 })

                Text(`浇水消耗${this.unitWater}点水值，增加${this.unitGrow}点生长值`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.card_background') || '#F9F9F9')
            .borderRadius(8)
            .margin({ top: 12 })
          }
        }
        .width('85%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建生长值详情弹窗
  @Builder
  private buildGrowthDetailModal() {
    if (this.showGrowthDetail) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showGrowthDetail = false;
          })

        Column() {
          Row() {
            Text('🌱 生长值详情')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor('transparent')
              .onClick(() => {
                this.showGrowthDetail = false;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          Column({ space: 8 }) {
            Row() {
              Text('当前生长值:')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))

              Text(this.growthValue.toString())
                .fontSize(24)
                .fontColor($r('app.color.primary_color'))
                .fontWeight(FontWeight.Bold)
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            // 使用 Progress 组件实现进度条
            Row({ space: 12 }) {
              Text(`进度：${this.growthValue}/100`)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))

              Blank()

              // 使用 Progress 组件实现从左向右的进度条
              Progress({
                value: this.growthValue,
                total: 100,
                type: ProgressType.Linear
              })
                .width('60%')
                .height(6)
                .backgroundColor($r('app.color.mbti_progress_background'))
                .color($r('app.color.mbti_progress_foreground'))
                .borderRadius(3)
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.modal_background') || '#F5F5F5')
            .borderRadius(8)
            .margin({ top: 8, bottom: 8 })

            // 显示植物状态
            // Row() {
            //   Text('植物状态:')
            //     .fontSize(16)
            //     .fontColor($r('app.color.text_primary'))
            //
            //   Text(this.getPlantStatus())
            //     .fontSize(18)
            //     .fontColor($r('app.color.primary_color'))
            //     .fontWeight(FontWeight.Medium)
            //     .margin({ left: 8 })
            // }
            // .width('100%')
            // .margin({ top: 12 })

            // 显示进度说明
            Column() {
              Text('🌱 生长阶段说明:')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })

              // Row() {
              //   Circle()
              //     .width(8)
              //     .height(8)
              //     .fill(this.growthValue >= 0 ? $r('app.color.primary_color') : '#CCCCCC')
              //     .margin({ right: 8 })
              //
              //   Text('等待发芽 (0)')
              //     .fontSize(12)
              //     .fontColor($r('app.color.text_secondary'))
              // }
              // .width('100%')
              // .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 0 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第1阶段 (0-10)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 10 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第2阶段 (10-30)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 30 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第3阶段 (30-55)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 55 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第4阶段 (55-80)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 80 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第5阶段 (80-100)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.growthValue >= 100 ? $r('app.color.primary_color') : '#CCCCCC')
                  .margin({ right: 8 })

                Text('第6阶段 (100+)')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.card_background') || '#F9F9F9')
            .borderRadius(8)
            .margin({ top: 12 })
          }
        }
        .width('85%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建重命名弹窗
  @Builder
  private buildRenameModal() {
    if (this.showRenameInput) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showRenameInput = false;
          })

        Column() {
          Text('🏷️ 植物命名')
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

          TextInput({ text: this.plantName, placeholder: '输入植物名称' })
            .placeholderColor($r('app.color.text_secondary'))
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.input_background'))
            .border({ width: 1, color: $r('app.color.border_color') })
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => {
              this.plantName = value;
            })
            .margin({ bottom: 20 })

          Row({ space: 20 }) {
            Button('取消')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.button_secondary'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.showRenameInput = false;
              })

            Button('保存')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary_color'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.changePlantName();
              })
          }
          .width('100%')
        }
        .width('70%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建使用说明弹窗
  @Builder
  private buildInstructionsModal() {
    if (this.showInstructions) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showInstructions = false;
          })

        Column() {
          Row() {
            Text('📖 使用说明')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor('transparent')
              .onClick(() => {
                this.showInstructions = false;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          Column({ space: 12 }) {
            Row() {
              Text('💧')
                .fontSize(20)
                .margin({ right: 10 })

              Column({ space: 4 }) {
                Text('开心水获取')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(FontWeight.Medium)
                Text('每保存一条心情记录，获得1点开心水')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                Text('每添加一条心理暗示，获得3点开心水')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                Text('每发送一封时光邮件，获得5点开心水')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
            }

            Row() {
              Text('🌱')
                .fontSize(20)
                .margin({ right: 10 })

              Column({ space: 4 }) {
                Text('浇水成长')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(FontWeight.Medium)
                Text(`浇水消耗${this.unitWater}点开心水，增加${this.unitGrow}生长值`)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
            }

            Row() {
              Text('🔄')
                .fontSize(20)
                .margin({ right: 10 })

              Column({ space: 4 }) {
                Text('重新种植')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(FontWeight.Medium)
                Text('重置生长值，重新开始种植')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
            }
          }
          .width('100%')
          .margin({ bottom: 20 })

          Button('我知道了')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .width('100%')
            .height(45)
            .borderRadius(8)
            .onClick(() => {
              this.showInstructions = false;
            })
        }
        .width('80%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建浇水确认弹窗
  @Builder
  private buildWaterConfirmModal() {
    if (this.showWaterConfirm) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showWaterConfirm = false;
          })

        Column() {
          Text('💧 确认浇水')
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

          Text(`消耗${this.unitWater}点开心水，增加${this.unitGrow}点生长值`)
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })

          Row({ space: 20 }) {
            Button('取消')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.button_secondary'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.showWaterConfirm = false;
              })

            Button('确认浇水')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary_color'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.waterPlant();
              })
          }
          .width('100%')
        }
        .width('70%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建重新种植确认弹窗
  @Builder
  private buildReplantConfirmModal() {
    if (this.showReplantConfirm) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => {
            this.showReplantConfirm = false;
          })

        Column() {
          Text('🔄 种新花')
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

          Text('确定要种一盆新的开心花吗？')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 })

          // 修改：根据当前生长值显示不同的提示信息
          if (this.growthValue >= 100) {
            Text('当前植物已健康生长，可以重新种植1盆新花！')
              .fontSize(14)
              .fontColor($r('app.color.primary_color'))
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 })
          }

          Text('生长值将被重置为0')
            .fontSize(14)
            .fontColor($r('app.color.mbti_progress_foreground'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })

          Row({ space: 20 }) {
            Button('取消')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.button_secondary'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.showReplantConfirm = false;
              })

            Button('确认重置')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.mbti_progress_foreground'))
              .layoutWeight(1)
              .height(45)
              .borderRadius(8)
              .onClick(() => {
                this.replant();
              })
          }
          .width('100%')
        }
        .width('70%')
        .padding(20)
        .backgroundColor($r('app.color.modal_background'))
        .borderRadius(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 构建页面布局
  build() {
    NavDestination() {
      Stack() {
        Column()
        {
          Image(this.previewUris)
            .width(300)
            .height(300)
            .objectFit(ImageFit.Contain)
        }

        // 背景
        Column(){
          Video({
            src: this.innerResource,  // 设置视频源
            previewUri: this.previewUris, // 设置预览图
            controller: this.controller //设置视频控制器，可以控制视频的播放状态
          }).muted(false) // 设置是否静音
            .controls(false) // 设置是否显示默认控制条
            .autoPlay(true) // 设置是否自动播放
            .loop(true) // 设置是否循环播放
           //.objectFit(ImageFit.Contain) // 设置视频填充模式

          // 顶部标题
          Column() {
            Text('🌱 心情花园')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))

            Text('种植你的心情')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .padding({ left: 20, right: 20, top: 10, bottom: 10 }) // 左右内边距大一些
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(25)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 6, color: '#40000000', offsetX: 0, offsetY: 3 })
          .position({ x: '50%', y: '10%' })
          .translate({ x: -85, y: -30 })

          // 植物图片 - 居中偏下，放大显示
          Column() {
            Image(this.getPlantImage())
              .width(250)
              .height(450)
              .objectFit(ImageFit.Contain)
              //.shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 4 })
          }
          .position({ x: '50%', y: '65%' })
          .translate({ x: -125, y: -225 })
          //.margin({top:20,bottom:30})
          //.alignItems(HorizontalAlign.Center)

        }
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.background_primary'))



        // 左侧显示栏 - 三个悬浮球
        // 生长值悬浮球
        this.buildFloatingBall('🌱', '生长值', '6%', '15%', () => {
          this.showGrowthDetail = true;
        })

        // 水值悬浮球
        this.buildFloatingBall('💧', '开心水', '6%', '27%', () => {
          this.showWaterDetail = true;
        })

        // 使用说明悬浮球
        this.buildFloatingBall('📖', '说明', '6%', '39%', () => {
          this.showInstructions = true;
        })

        // 右侧工具栏 - 三个悬浮球
        // 浇水悬浮球
        this.buildFloatingBall('💦', '浇水', '85%', '15%', () => {
          if (this.waterValue >= this.unitWater) {
            this.showWaterConfirm = true;
          } else {
            promptAction.showToast({
              message: `水值不足，无法浇水！(需要${this.unitWater}点)`,
              duration: 2000
            });
          }
        })

        // 重新种植悬浮球
        this.buildFloatingBall('🔄', '种新花', '85%', '27%', () => {
          this.showReplantConfirm = true;
        })

        // 花朵数量悬浮球（新增）- 放在最上面
        this.buildFloatingBall('🌼', '已种', '85%', '39%', () => {
          this.showFlowersNum = true;
        })

        // // 命名悬浮球
        // this.buildFloatingBall('🏷️', '命名', '85%', '35%', () => {
        //   this.showRenameInput = true;
        // })

        // 弹窗区域
        this.buildWaterDetailModal()
        this.buildGrowthDetailModal()
        //this.buildRenameModal()
        this.buildInstructionsModal()
        this.buildWaterConfirmModal()
        this.buildReplantConfirmModal()
        this.buildFlowersNumModal() // 新增：花朵数量弹窗
      }
      .width('100%')
      .height('100%')
    }
  }
}

@Builder
export function MoodGardenPageBuilder(param: object) {
  MoodGardenPage()
}