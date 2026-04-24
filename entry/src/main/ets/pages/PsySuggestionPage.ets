// src/main/ets/pages/PsySuggestionPage.ets
import { PsySuggestion } from '../database/PsySuggestionDatabase';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';

// 在文件顶部或合适的地方定义接口
interface SuggestionData {
  content: string;
  createdTime: number;
  isPrimary?: boolean;
}

@Component
export struct PsySuggestionPage {
  pageStack: NavPathStack = new NavPathStack();

  // Preferences相关变量
  private prefs: preferences.Preferences | null = null;
  private readonly prefsOptions: preferences.Options = { name: 'PsySuggestionsPrefs' };

  // 新增：水值相关preferences
  private WATER_KEY: string = 'water_value';
  private PREFERENCES_NAME: string = 'mood_garden_data';

  // 状态管理
  @State suggestions: PsySuggestion[] = [];
  @State showAddModal: boolean = false;
  @State newSuggestionText: string = '';
  @State isLoading: boolean = true;
  @State showDeleteConfirm: boolean = false;
  @State selectedSuggestionId: number = -1;
  @State errorMessage: string = '';
  @State maxSuggestionsReached: boolean = false;

  aboutToAppear() {
    this.initPreferences();
  }

  // 初始化Preferences
  private initPreferences() {
    try {
      const context = getContext(this);
      this.prefs = preferences.getPreferencesSync(context, this.prefsOptions);
      this.loadSuggestions();
    } catch (error) {
      console.error('Preferences初始化失败:', error);
      this.errorMessage = '存储初始化失败，请重启应用';
      promptAction.showToast({ message: this.errorMessage, duration: 2000 });
    } finally {
      this.isLoading = false;
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

      // 增加3
      currentWater += 3;

      // 保存新的water值
      await pref.put(this.WATER_KEY, currentWater);
      await pref.flush();

      console.log(`Water值已增加3，当前值: ${currentWater}`);
    } catch (error) {
      console.error('增加water值失败:', error);
      // 这里可以选择静默失败，不影响主流程
    }
  }

  // 加载所有心理暗示
  private loadSuggestions() {
    if (!this.prefs) return;

    try {
      const allData = this.prefs.getAllSync();
      const loadedSuggestions: PsySuggestion[] = [];

      Object.entries(allData).forEach((entry: [string, preferences.ValueType]) => {
        const key = entry[0];
        const value = entry[1];

        if (key.startsWith('suggestion_')) {
          try {
            const parsedData = JSON.parse(value as string) as SuggestionData;
            loadedSuggestions.push({
              id: parseInt(key.replace('suggestion_', '')),
              content: parsedData.content,
              createdTime: parsedData.createdTime
            });
          } catch (e) {
            console.warn(`解析心理暗示数据失败: ${key}`, e);
          }
        }
      });

      this.suggestions = loadedSuggestions.sort((a, b) =>
      (b.createdTime || 0) - (a.createdTime || 0)
      );

      this.maxSuggestionsReached = this.suggestions.length >= 20;
    } catch (error) {
      console.error('加载数据失败:', error);
      this.errorMessage = '加载数据失败';
    }
  }

  // 添加心理暗示
  private addSuggestion() {
    if (this.maxSuggestionsReached) {
      promptAction.showToast({ message: '最多添加20条心理暗示~', duration: 2000 });
      return;
    }

    if (!this.newSuggestionText.trim()) {
      promptAction.showToast({ message: '请输入心理暗示内容', duration: 2000 });
      return;
    }

    if (this.newSuggestionText.length > 50) {
      promptAction.showToast({ message: '内容不能超过50字', duration: 2000 });
      return;
    }

    if (!this.prefs) {
      promptAction.showToast({ message: '存储未初始化', duration: 2000 });
      return;
    }

    try {
      const newId = Date.now();
      const newSuggestion: PsySuggestion = {
        id: newId,
        content: this.newSuggestionText.trim(),
        createdTime: newId
      };

      this.prefs.putSync(`suggestion_${newId}`, JSON.stringify({
        content: newSuggestion.content,
        createdTime: newSuggestion.createdTime
      }));

      this.prefs.flushSync();
      // 新增：增加water值
      this.incrementWaterValue();

      promptAction.showToast({ message: '添加成功，获得3点开心水', duration: 2000 });

      this.newSuggestionText = '';
      this.showAddModal = false;
      this.loadSuggestions();
    } catch (error) {
      console.error('添加失败:', error);
      promptAction.showToast({ message: '添加失败', duration: 2000 });
    }
  }

  // 删除心理暗示
  private deleteSuggestion() {
    if (this.selectedSuggestionId === -1 || !this.prefs) return;

    try {
      this.prefs.deleteSync(`suggestion_${this.selectedSuggestionId}`);
      this.prefs.flushSync();

      promptAction.showToast({ message: '删除成功', duration: 2000 });
      this.loadSuggestions();
    } catch (error) {
      console.error('删除失败:', error);
      promptAction.showToast({ message: '删除失败', duration: 2000 });
    } finally {
      this.showDeleteConfirm = false;
      this.selectedSuggestionId = -1;
    }
  }

  // 显示删除确认弹窗
  private showDeleteDialog(id: number, content: string) {
    this.selectedSuggestionId = id;

    try {
      promptAction.showDialog({
        title: '删除心理暗示',
        message: `确定要删除"${content.length > 20 ? content.substring(0, 20) + '...' : content}"吗？`,
        buttons: [
          {
            text: '取消',
            color: '#666666'
          },
          {
            text: '删除',
            color: '#FF6B6B'
          }
        ]
      }).then(result => {
        if (result.index === 1) {
          this.deleteSuggestion();
        }
      });
    } catch (error) {
      console.error('显示对话框失败:', error);
    }
  }

  // 格式化时间显示
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  // 返回上一页
  private navigateBack() {
    this.pageStack.pop();
  }

  // 添加心理暗示的弹窗组件
  @Builder
  buildAddModal() {
    if (this.showAddModal) {
      Column() {
        Column() {
          // 标题
          Text('添加心理暗示')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.psy_modal_title'))
            .margin({ bottom: 20 })

          // 输入框
          TextInput({
            placeholder: '请输入积极的心理暗示（最多50字）',
            text: this.newSuggestionText
          })
            .width('100%')
            .height(120)
            .maxLength(50)
            .type(InputType.Normal)
            .fontColor($r('app.color.psy_input_text'))
            .placeholderColor($r('app.color.psy_placeholder'))
            .placeholderFont({ size: 16 })
            .enterKeyType(EnterKeyType.Done)
            .onChange((value: string) => {
              this.newSuggestionText = value;
            })
            .border({ width: 1, color: $r('app.color.psy_input_border'), radius: 10 })
            .padding(10)
            .backgroundColor($r('app.color.psy_input_background'))

          // 字数统计
          Text(`${this.newSuggestionText.length}/50`)
            .fontSize(14)
            .fontColor(this.newSuggestionText.length > 50 ? $r('app.color.psy_text_error') : $r('app.color.psy_text_secondary'))
            .width('100%')
            .textAlign(TextAlign.End)
            .margin({ top: 8, bottom: 20 })

          // 按钮组
          Row({ space: 15 }) {
            Button('取消')
              .width('40%')
              .height(45)
              .backgroundColor($r('app.color.psy_button_cancel'))
              .fontColor($r('app.color.psy_button_cancel_text'))
              .fontSize(18)
              .borderRadius(8)
              .onClick(() => {
                this.showAddModal = false;
                this.newSuggestionText = '';
              })

            Button('确认添加')
              .width('40%')
              .height(45)
              .backgroundColor($r('app.color.psy_button_primary'))
              .fontColor($r('app.color.psy_button_text'))
              .fontSize(18)
              .borderRadius(8)
              .onClick(() => this.addSuggestion())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .padding(24)
        .backgroundColor($r('app.color.psy_modal_background'))
        .borderRadius(16)
        .border({ width: 1, color: $r('app.color.psy_modal_border') })
        .shadow({ radius: 15, color: '#40000000', offsetX: 0, offsetY: 5 })
        .width('85%')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(93,64,55,0.3)')
      .position({ x: 0, y: 0 })
      .zIndex(999)
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 顶部导航栏
          Row() {
            Image($r('app.media.ic_back'))
              .width(28)
              .height(28)
              .margin({ left: 20 })
              .onClick(() => this.navigateBack())

            Text('心理暗示')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.psy_nav_title'))
              .margin({ left: 15 })

            Blank()

            Text(`共 ${this.suggestions.length} 条`)
              .fontSize(16)
              .fontColor($r('app.color.psy_nav_subtitle'))
              .margin({ right: 20 })
          }
          .width('100%')
          .height(90)
          .backgroundColor($r('app.color.psy_nav_background'))
          .border({ width: { bottom: 1 }, color: $r('app.color.psy_nav_border') })
          .margin({ top: -20 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

          // 主要内容区域
          if (this.isLoading) {
            // 加载状态
            Column() {
              LoadingProgress()
                .width(60)
                .height(60)
                .color($r('app.color.psy_loading'))
                .margin({ bottom: 20 })

              Text('加载中...')
                .fontSize(18)
                .fontColor($r('app.color.psy_text_secondary'))
            }
            .width('100%')
            .height('70%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

          } else if (this.errorMessage) {
            // 错误状态
            Column() {
              Text(this.errorMessage)
                .fontSize(18)
                .fontColor($r('app.color.psy_text_error'))
                .margin({ bottom: 20 })

              Button('重试')
                .width(150)
                .height(45)
                .backgroundColor($r('app.color.psy_button_primary'))
                .fontColor($r('app.color.psy_button_text'))
                .fontSize(18)
                .borderRadius(8)
                .onClick(() => {
                  this.isLoading = true;
                  this.errorMessage = '';
                  this.initPreferences();
                })
            }
            .width('100%')
            .height('70%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

          } else if (this.suggestions.length === 0) {
            // 空状态
            Column() {
              Text('暂无心理暗示')
                .fontSize(20)
                .fontColor($r('app.color.psy_text_secondary'))
                .margin({ bottom: 8 })

              Text('点击下方按钮添加第一条心理暗示吧！')
                .fontSize(16)
                .fontColor($r('app.color.psy_text_tertiary'))
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height('70%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

          } else {
            // 心理暗示列表
            List({ space: 15 }) {
              ForEach(this.suggestions, (item: PsySuggestion) => {
                ListItem() {
                  Column() {
                    // 暗示内容
                    Text(item.content)
                      .fontSize(17)
                      .fontColor($r('app.color.psy_item_text'))
                      .textAlign(TextAlign.Start)
                      .width('100%')
                      .margin({ bottom: 12 })
                      .lineHeight(25)

                    // 时间和操作按钮
                    Row() {
                      Text(this.formatTime(item.createdTime!))
                        .fontSize(14)
                        .fontColor($r('app.color.psy_item_time'))

                      Blank()

                      Button('删除')
                        .width(70)
                        .height(32)
                        .fontSize(14)
                        .backgroundColor($r('app.color.psy_button_delete'))
                        .fontColor($r('app.color.psy_button_text'))
                        .borderRadius(6)
                        .onClick(() => this.showDeleteDialog(item.id!, item.content))
                    }
                    .width('100%')
                  }
                  .padding(18)
                  .backgroundColor($r('app.color.psy_item_background'))
                  .borderRadius(12)
                  .border({ width: 1, color: $r('app.color.psy_item_border') })
                  .shadow({ radius: 5, color: '#20000000', offsetX: 2, offsetY: 2 })
                }
                .margin({ left: 16, right: 16, top: 8, bottom: 8 })
              }, (item: PsySuggestion) => item.id?.toString() || '')
            }
            .padding({ top: 10, bottom: 10 })
            .layoutWeight(1)
          }

          // 底部添加按钮
          Button('添加心理暗示')
            .width('85%')
            .height(55)
            .margin({ top: 15, bottom: 25 })
            .backgroundColor(this.maxSuggestionsReached ? $r('app.color.psy_button_disabled') : $r('app.color.psy_button_primary'))
            .fontColor($r('app.color.psy_button_text'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .borderRadius(10)
            .shadow({ radius: 5, color: '#40000000', offsetX: 0, offsetY: 3 })
            .onClick(() => {
              if (this.maxSuggestionsReached) {
                promptAction.showToast({ message: '最多添加20条心理暗示~', duration: 2000 });
                return;
              }

              this.showAddModal = true;
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.psy_background'))

        // 添加心理暗示的弹窗
        this.buildAddModal()
      }
      .backgroundColor($r('app.color.psy_background'))
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function PsySuggestionPageBuilder(param: object) {
  PsySuggestionPage()
}