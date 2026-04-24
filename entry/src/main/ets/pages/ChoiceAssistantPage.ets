import promptAction from '@ohos.promptAction';
import { AppStorageV2 } from "@kit.ArkUI";

// 定义选项接口
interface ChoiceOption {
  id: number;
  name: string;
  description: string;
}

@Component
export struct ChoiceAssistantPage {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'nacStack', () => new NavPathStack())!;

  // 选项列表
  @State options: ChoiceOption[] = [
    { id: 1, name: "选项1", description: "描述1" },
    { id: 2, name: "选项2", description: "描述2" },
    { id: 3, name: "选项3", description: "描述3" }
  ];

  // 新增：强制渲染的状态变量
  @State isEdited: boolean = false;
  @State renderKey: number = 0;

  // 当前选中的选项ID（用于编辑）
  @State selectedOptionId: number = -1;

  // 随机选择状态
  @State isSelecting: boolean = false;
  @State selectedResult: ChoiceOption | null = null;
  @State selectionIntervalId: number = -1;
  @State selectionIndex: number = 0;

  // 添加/编辑模式
  @State showAddEditModal: boolean = false;
  @State newOptionName: string = '';
  @State newOptionDescription: string = '';
  @State isEditMode: boolean = false;

  aboutToAppear() {
    this.loadOptions();
  }

  // 加载选项（模拟从存储加载）
  private loadOptions(): void {
    console.log('加载选项数据');
  }

  // 保存选项（模拟保存到存储）
  private saveOptions(): void {
    console.log('保存选项数据');
  }

  // 强制重新渲染
  private forceRerender(): void {
    this.isEdited = !this.isEdited; // 切换状态强制更新
    this.renderKey++; // 增加key值强制重新创建组件
  }

  // 开始随机选择
  private startSelection(): void {
    if (this.options.length < 2) {
      promptAction.showToast({
        message: '至少需要2个选项才能开始选择',
        duration: 2000
      });
      return;
    }

    this.isSelecting = true;
    this.selectedResult = null;

    // 随机选择动画
    this.selectionIntervalId = setInterval(() => {
      this.selectionIndex = Math.floor(Math.random() * this.options.length);
    }, 100);

    // 3秒后停止并显示结果
    setTimeout(() => {
      this.stopSelection();
      this.showResult();
    }, 3000);
  }

  // 停止选择
  private stopSelection(): void {
    if (this.selectionIntervalId !== -1) {
      clearInterval(this.selectionIntervalId);
      this.selectionIntervalId = -1;
    }
    this.isSelecting = false;
  }

  // 显示结果
  private showResult(): void {
    if (this.selectionIndex >= 0 && this.selectionIndex < this.options.length) {
      this.selectedResult = this.options[this.selectionIndex];
      promptAction.showToast({
        message: `已选择: ${this.selectedResult.name}`,
        duration: 2000
      });
    }
  }

  // 添加新选项 - 修复：使用强制渲染
  private addOption(): void {
    if (this.newOptionName.trim().length === 0) {
      promptAction.showToast({
        message: '请输入选项名称',
        duration: 2000
      });
      return;
    }

    const newOption: ChoiceOption = {
      id: Date.now(),
      name: this.newOptionName.trim(),
      description: this.newOptionDescription.trim()
    };

    // 修复：创建新数组并强制渲染
    const newOptions = [...this.options];
    newOptions.push(newOption);
    this.options = newOptions;

    this.saveOptions();
    this.showAddEditModal = false;
    this.newOptionName = '';
    this.newOptionDescription = '';

    // 强制重新渲染
    this.forceRerender();

    promptAction.showToast({
      message: '选项添加成功',
      duration: 1000
    });
  }

  // 编辑选项 - 修复：使用强制渲染
  private editOption(): void {
    if (this.selectedOptionId === -1) return;

    const index = this.options.findIndex(option => option.id === this.selectedOptionId);
    if (index !== -1) {
      // 修复：手动复制属性避免展开运算符错误
      const updatedOption: ChoiceOption = {
        id: this.options[index].id,
        name: this.newOptionName.trim(),
        description: this.newOptionDescription.trim()
      };

      // 修复：创建新数组并强制渲染
      const newOptions = [...this.options];
      newOptions[index] = updatedOption;
      this.options = newOptions;

      this.saveOptions();
      this.showAddEditModal = false;
      this.newOptionName = '';
      this.newOptionDescription = '';
      this.selectedOptionId = -1;

      // 强制重新渲染
      this.forceRerender();

      promptAction.showToast({
        message: '选项更新成功',
        duration: 1000
      });
    }
  }

  // 删除选项 - 修复：使用强制渲染
  private deleteOption(optionId: number): void {
    const index = this.options.findIndex(option => option.id === optionId);
    if (index !== -1) {
      // 修复：创建新数组并强制渲染
      const newOptions = this.options.filter(option => option.id !== optionId);
      this.options = newOptions;

      this.saveOptions();

      // 强制重新渲染
      this.forceRerender();

      promptAction.showToast({
        message: '选项已删除',
        duration: 1000
      });
    }
  }

  // 打开编辑模态框
  private openEditModal(option: ChoiceOption): void {
    this.selectedOptionId = option.id;
    this.newOptionName = option.name;
    this.newOptionDescription = option.description;
    this.isEditMode = true;
    this.showAddEditModal = true;
  }

  // 返回上一页
  private backToPrevious(): void {
    this.pageStack.pop();
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    NavDestination() {
      Column(){
        Stack() {
          Column() {
            // 顶部导航栏
            Row() {
              Image($r('app.media.ic_back'))
                .width(30)
                .height(30)
                .margin({ left: 15 })
                .onClick(() => this.backToPrevious())

              Text('选择助手')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.choice_nav_title'))
                .margin({ left: 20 })

              Blank()

              // 添加选项按钮
              Button() {
                Text(' ＋')
                  .width(24)
                  .height(24)
              }
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.choice_add_button_bg'))
              .borderRadius(20)
              .onClick(() => {
                this.newOptionName = '';
                this.newOptionDescription = '';
                this.isEditMode = false;
                this.showAddEditModal = true;
              })
              .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .backgroundColor($r('app.color.choice_nav_background'))
            .border({ width: { bottom: 1 }, color: $r('app.color.choice_nav_border') })

            // 选项列表区域 - 使用条件渲染强制更新
            Scroll() {
              Column() {
                // 选项列表 - 使用isEdited状态强制重新渲染
                if (this.isEdited) {
                  ForEach(this.options, (option: ChoiceOption) => {
                    this.buildOptionItem(option, true);
                  }, (option: ChoiceOption) => `${option.id}_edited_${this.renderKey}`)
                } else {
                  ForEach(this.options, (option: ChoiceOption) => {
                    this.buildOptionItem(option, false);
                  }, (option: ChoiceOption) => `${option.id}_normal_${this.renderKey}`)
                }
              }
              .width('100%')
              .padding(15)
            }
            .layoutWeight(1)

            // 选择结果区域
            if (this.selectedResult) {
              Column() {
                Text('选择结果')
                  .fontSize(18)
                  .fontColor($r('app.color.choice_result_title'))
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 })

                Text(this.selectedResult.name)
                  .fontSize(24)
                  .fontColor($r('app.color.choice_result_text'))
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)

                if (this.selectedResult.description) {
                  Text(this.selectedResult.description)
                    .fontSize(16)
                    .fontColor($r('app.color.text_secondary'))
                    .textAlign(TextAlign.Center)
                    .margin({ top: 10 })
                }

                // 添加提示文字
                Text('选择为随机选择，仅供参考')
                  .fontSize(14)
                  .fontColor($r('app.color.choice_hint_text'))
                  .textAlign(TextAlign.Center)
                  .margin({ top: 15 })
                  .opacity(0.8)
              }
              .width('90%')
              .padding(20)
              .backgroundColor($r('app.color.choice_result_bg'))
              .borderRadius(15)
              .border({ width: 1, color: $r('app.color.choice_result_border') })
              .margin({ bottom: 20 })
            }

            // 选择按钮
            Button(this.isSelecting ? '选择中...' : '开始选择')
              .width('90%')
              .height(60)
              .backgroundColor(this.isSelecting ? $r('app.color.choice_button_selecting') : $r('app.color.choice_button_primary'))
              .fontColor($r('app.color.button_primary_text'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .borderRadius(30)
              .onClick(() => this.startSelection())
              .margin({ bottom: 30 })
              .shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 5 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.choice_background'))


          // 添加/编辑选项模态框
          if (this.showAddEditModal) {
            // 半透明背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0,0,0,0.5)')
              .position({ x: 0, y: 0 })
              .zIndex(99)
              .onClick(() => this.showAddEditModal = false)

            // 模态框内容
            Column() {
              Text(this.isEditMode ? '编辑选项' : '添加选项')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.choice_modal_title'))
                .margin({ bottom: 20 })

              // 选项名称输入
              TextInput({ placeholder: '请输入选项名称', text: this.newOptionName })
                .width('90%')
                .height(50)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .backgroundColor($r('app.color.input_background'))
                .borderRadius(8)
                .border({ width: 1, color: $r('app.color.choice_input_border') })
                .padding(10)
                .margin({ bottom: 15 })
                .onChange((value: string) => {
                  this.newOptionName = value;
                })

              // 选项描述输入
              TextInput({ placeholder: '请输入选项描述（可选）', text: this.newOptionDescription })
                .width('90%')
                .height(100)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .backgroundColor($r('app.color.input_background'))
                .borderRadius(8)
                .border({ width: 1, color: $r('app.color.choice_input_border') })
                .padding(10)
                .margin({ bottom: 20 })
                .onChange((value: string) => {
                  this.newOptionDescription = value;
                })

              Row({ space: 20 }) {
                Button('取消')
                  .width(120)
                  .height(45)
                  .backgroundColor($r('app.color.button_secondary'))
                  .fontColor($r('app.color.text_primary'))
                  .borderRadius(8)
                  .onClick(() => {
                    this.showAddEditModal = false;
                    this.newOptionName = '';
                    this.newOptionDescription = '';
                  })

                Button(this.isEditMode ? '保存' : '添加')
                  .width(120)
                  .height(45)
                  .backgroundColor($r('app.color.choice_button_primary'))
                  .fontColor($r('app.color.button_primary_text'))
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.isEditMode) {
                      this.editOption();
                    } else {
                      this.addOption();
                    }
                  })
              }
            }
            .width('80%')
            .padding(30)
            .backgroundColor($r('app.color.modal_background'))
            .borderRadius(15)
            .border({ width: 2, color: $r('app.color.choice_modal_border') })
            .shadow({ radius: 20, color: '#40000000', offsetX: 0, offsetY: 10 })
            .position({})
            .zIndex(100)
          }

          // 随机选择动画
          if (this.isSelecting) {
            // 半透明背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(255,255,255,0.8)')
              .position({ x: 0, y: 0 })
              .zIndex(101)
              .onClick(() => this.stopSelection())

            // 选择动画
            Column() {
              Text('选择中...')
                .fontSize(24)
                .fontColor($r('app.color.choice_selection_title'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 30 })

              Text(this.options[this.selectionIndex]?.name || '')
                .fontSize(36)
                .fontColor($r('app.color.choice_selection_text'))
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .animation({ duration: 100, curve: Curve.EaseIn })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .position({})
            .zIndex(102)
          }
        }
      }
      .backgroundColor($r('app.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }

  // 构建选项项组件 - 使用@Builder避免重复代码
  @Builder
  private buildOptionItem(option: ChoiceOption, isEditedVersion: boolean) {
    Column() {
      Row() {
        Text(option.name)
          .fontSize(18)
          .fontColor($r('app.color.choice_option_title'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        // 编辑按钮
        Button() {
          Text('  🖊')
            .width(40)
            .height(20)
        }
        .width(36)
        .height(36)
        .backgroundColor($r('app.color.choice_edit_button_bg'))
        .borderRadius(18)
        .margin({ right: 10 })
        .onClick(() => this.openEditModal(option))

        // 删除按钮
        Button() {
          Text('  ❎')
            .width(40)
            .height(20)
        }
        .width(36)
        .height(36)
        .backgroundColor($r('app.color.choice_delete_button_bg'))
        .borderRadius(18)
        .onClick(() => this.deleteOption(option.id))
      }
      .width('100%')
      .padding({ left: 15, right: 15 })

      // 选项描述
      if (option.description) {
        Text(option.description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 5, left: 15, right: 15 })
      }
    }
    .padding(15)
    .margin({ top: 10 })
    .backgroundColor($r('app.color.choice_option_bg'))
    .borderRadius(10)
    .border({ width: 1, color: $r('app.color.choice_option_border') })
    .shadow({ radius: 5, color: '#10000000', offsetX: 0, offsetY: 2 })
    .key(`${option.id}_${isEditedVersion ? 'edited' : 'normal'}_${this.renderKey}`)
  }
}

@Builder
export function ChoiceAssistantPageBuilder(param: object) {
  ChoiceAssistantPage()
}