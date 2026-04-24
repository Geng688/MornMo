import { promptAction } from "@kit.ArkUI";

@Component
export struct RandomActionPage {
  pageStack: NavPathStack = new NavPathStack();

  // 行动建议数据 - 保持不变
  @State actions: string[] = [
    "深呼吸三次，感受空气在体内的流动",
    "站起来伸展一下身体，活动肩颈",
    "喝一杯温水，慢慢品尝",
    "看向窗外的绿色植物或远方",
    "给自己一个微笑，哪怕只是微微扬起嘴角",
    "听一首喜欢的轻音乐或自然声音",
    "用温水洗一把脸，感受清爽瞬间",
    "整理桌面的一小个角落",
    "写下此刻的一个小感受",
    "慢慢转动脖子和手腕，缓解紧张",
    "闭上眼睛，静坐一分钟",
    "告诉自己：我已经做得很好了",
    "做几个简单的颈部拉伸动作",
    "泡一杯茶或咖啡，享受冲泡过程",
    "轻轻按摩太阳穴和眼眶",
    "回想一件最近让你开心的小事",
    "做5次深呼吸，每次吸气数4秒，呼气数6秒",
    "站起来走动一下，哪怕只是在房间内",
    "喝一口水，感受水流过喉咙的感觉",
    "观察周围的5种颜色并说出它们的名字",
    "轻轻哼唱一段喜欢的旋律",
    "用手指轻轻敲打桌面，创造简单节奏",
    "回想一个让你感到平静的地方",
    "对自己说一句鼓励的话",
    "转动脚踝和手腕，促进血液循环",
    "闻一闻身边令人愉悦的气味",
    "做几个简单的伸展运动",
    "静静地数10个呼吸",
    "想象一个让你放松的场景",
    "轻轻按摩双手的每个手指",
    "站起来踮起脚尖再放下，重复几次",
    "告诉自己：这个时刻属于我",
    "观察周围的细节，发现一个平时没注意的东西",
    "慢慢咀嚼一小块食物，感受味道",
    "做几个深呼吸，感受腹部的起伏",
    "轻轻转动肩膀，画圈运动",
    "闭上眼睛，聆听周围的声音",
    "对自己微笑，即使没有理由",
    "轻轻摆动身体，像随风摇摆的树叶",
    "回想一个让你感到温暖的时刻",
    "慢慢眨眼10次，缓解眼睛疲劳",
    "用手指轻轻梳理头发",
    "静静地感受心跳的节奏",
    "想象压力随着每次呼气离开身体",
    "轻轻拍打四肢，促进血液循环",
    "告诉自己：我可以慢慢来",
    "感受脚底与地面的接触",
    "做几个深蹲，激活身体能量",
    "想象自己在一个安全舒适的地方",
    "撕一张纸，感受纸张撕裂的声音和触感",
    "晒一晒阳光，感受温暖洒在皮肤上",
    "列出三件今天做得好的小事",
    "用冷水洗手，感受清凉的刺激",
    "做一个鬼脸，让自己笑出来",
    "观察一朵花的细节，欣赏它的美丽",
    "轻轻按摩耳垂，缓解压力",
    "哼一段童年时喜欢的儿歌",
    "把双手搓热，然后轻轻覆盖在眼睛上",
    "说一句感谢自己的话",
    "做几个简单的腰部扭转动作",
    "找一个柔软的东西（如抱枕）抱一抱",
    "回忆一个有趣的笑话或段子",
    "用指尖轻轻敲击头皮，放松头部",
    "告诉自己：没关系，一切都会好起来",
    "做3次开合跳，活动身体",
    "观察云的形状，想象它们像什么",
    "轻轻揉捏耳垂，促进放松",
    "写下一个小愿望或期待",
    "做几个扩胸运动，打开胸腔",
    "闻一闻新鲜的水果香味",
    "回忆一次愉快的旅行经历",
    "用手轻轻抚摸手臂，感受触觉",
    "对镜子里的自己做个鬼脸",
    "做5次简单的弯腰触脚动作",
    "听一段搞笑的音频或短视频",
    "轻轻拍打自己的脸颊，唤醒精神",
    "列出一件今天让你感激的事",
    "做几个简单的手腕绕环动作",
    "品尝一小块巧克力，慢慢感受它的味道",
    "回想一个让你敬佩的人及其品质",
    "用手指轻轻按压手掌心",
    "对自己说：我值得被善待",
    "做几个高抬腿动作，活动下肢",
    "观察雨滴（如果下雨）落在窗户上的样子",
    "轻轻按摩膝盖周围",
    "写下一个小小的成就",
    "做几个简单的体侧伸展",
    "闻一闻刚煮好的米饭香味",
    "回忆一次收到的善意",
    "用手轻轻拍打自己的后背",
    "对着天空或天花板发呆一分钟",
    "做3次简单的跳跃动作",
    "观察夜晚的星星或月亮",
    "轻轻按摩小腿肌肉",
    "列出一个你擅长的事情",
    "做几个简单的手臂绕环动作",
    "品尝一口喜欢的饮品，慢慢吞咽",
    "回想一个让你感到自豪的时刻",
    "用手指轻轻点按太阳穴",
    "告诉自己：我的感受很重要",
    "做几个简单的弓步动作",
    "观察风中摇曳的树叶",
    "轻轻按摩肩部肌肉",
    "写下一句鼓励自己的话贴在显眼处",
    "做几个简单的颈部左右转动",
    "闻一闻新鲜的蔬菜或香草",
    "回忆一次成功解决问题的经历",
    "用手轻轻抚摸头发，感受其质感",
    "给自己一个虚拟的拥抱",
    "做几个简单的原地踏步动作",
    "观察小动物的活动（如果有的话）",
    "轻轻按摩大腿肌肉",
    "列出一件你今天学到的新东西",
    "做几个简单的手臂上举动作",
    "品尝一小块水果，感受其清甜",
    "回想一个让你感到平静的时刻",
    "用手指轻轻敲击桌面，创造节奏",
    "告诉自己：我有能力应对挑战",
    "做几个简单的踢腿动作",
    "观察城市或乡村的风景",
    "轻轻按摩脚踝",
    "写下一个你喜欢的自己的特质",
    "做几个简单的转体动作",
    "闻一闻刚泡好的茶或咖啡香",
    "回忆一次与朋友的愉快相处",
    "用手轻轻拍打大腿外侧",
    "闭上眼睛，想象自己在海边",
    "做几个简单的下蹲动作",
    "观察日出或日落的色彩变化",
    "轻轻按摩手指关节",
    "列出一件期待发生的小事",
    "做几个简单的扩胸运动",
    "品尝一小口酸奶或甜点",
    "回想一个让你感到安心的地方",
    "用手指轻轻划过桌面，感受其质感",
    "告诉自己：休息是必要的",
    "做几个简单的腰部弯曲动作",
    "观察水面的波纹或反光",
    "轻轻按摩颈部后方",
    "写下一个今天想做的轻松小事",
    "做几个简单的手臂交叉动作",
    "闻一闻干净的床单或衣物味道",
    "回忆一次收到的赞美",
    "用手轻轻揉搓手臂",
    "想象自己被温暖的光芒包围",
    "做几个简单的踮脚动作",
    "观察夜晚城市的灯光",
    "轻轻按摩足底",
    "列出一个你克服过的困难",
    "做几个简单的肩部提升动作",
    "品尝一口汤或热饮",
    "回想一个让你感到快乐的活动",
    "用手指轻轻敲击键盘或桌面创作简单节奏",
    "告诉自己：我接纳现在的自己",
    "做几个简单的转身动作",
    "观察季节变化的迹象",
    "轻轻按摩手肘内侧",
    "写下一个你想去的地方",
    "做几个简单的手臂摆动动作",
    "闻一闻雨后的清新空气",
    "回忆一次帮助别人的经历",
    "用手轻轻拍打腹部",
    "闭上眼睛，想象自己在森林中",
    "做几个简单的跳跃动作",
    "观察建筑物的细节",
    "轻轻按摩锁骨周围",
    "列出三件你拥有的美好事物",
    "做几个简单的侧弯动作",
    "品尝一小块坚果或种子",
    "回想一个让你感到惊喜的瞬间",
    "用手指轻轻梳理眉毛",
    "告诉自己：我有进步的空间",
    "做几个简单的抬腿动作",
    "观察路人的穿着或行为（不打扰的情况下）",
    "轻轻按摩耳后",
    "写下一句你喜欢的名言",
    "做几个简单的手臂环绕动作",
    "闻一闻香料的气味",
    "回忆一次学到新东西的兴奋",
    "用手轻轻抚摸脸颊",
    "想象自己在山顶俯瞰风景",
    "做几个简单的踏步动作",
    "观察书中的插图或照片",
    "轻轻按摩手背",
    "列出一个你想培养的小习惯",
    "做几个简单的扩胸后展动作",
    "品尝一口咸菜或开胃小菜",
    "回想一个让你感到舒适的时刻",
    "用手指轻轻敲击膝盖",
    "告诉自己：我的努力有价值",
    "做几个简单的转身动作",
    "观察火焰（如蜡烛或壁炉）的跳动",
    "轻轻按摩小腿",
    "写下一个今天的小目标",
    "做几个简单的手臂伸展动作",
    "闻一闻面包的香气",
    "回忆一次与家人的温馨时刻",
    "用手轻轻拍打臀部",
    "闭上眼睛，想象自己在草地上",
    "做几个简单的跳跃动作",
    "观察工艺品的细节",
    "轻轻按摩大腿",
    "列出一件你今天完成的事",
    "做几个简单的弯腰动作",
    "品尝一口自己喜欢的酱料",
    "回想一个让你感到好奇的事物",
    "用手指轻轻按压太阳穴",
    "告诉自己：我可以表达自己的感受",
    "做几个简单的踢腿动作",
    "观察乐器的构造（如果身边有的话）",
    "轻轻按摩肩膀",
    "写下一个你喜欢的季节及其原因",
    "做几个简单的手臂上举动作",
    "闻一闻身边有的香味（如果有的话）",
    "回忆一次成功的经历",
    "用手轻轻抚摸头发",
    "想象自己在平静的湖边"
  ];

  // 表扬语句数组
  @State praises: string[] = [
    "太棒了！你完成了一次自我调节！",
    "做得好！继续保持哦！",
    "恭喜你完成行动！你正在变得更好！",
    "真厉害！又完成了一个小目标！",
    "坚持就是胜利！你做得很好！",
    "了不起！每一次行动都是进步！",
    "优秀！你正在培养好习惯！",
    "完美！自我关爱很重要！",
    "赞！你值得为自己骄傲！",
    "太优秀了！继续保持这个节奏！",
    "做得好！小小的行动带来大大的改变！",
    "恭喜！你正在创造积极的改变！",
    "真棒！自律让你更自由！",
    "优秀！每一天都在变得更好！",
    "太赞了！坚持就是力量！",
    "做得好！你正在投资自己的幸福！",
    "了不起！小小的坚持成就大大的梦想！",
    "完美！自我照顾是最重要的投资！",
    "太棒了！你正在建立健康的生活习惯！",
    "优秀！每一次行动都在塑造更好的你！"
  ];

  @State currentAction: string = "";
  @State textSize: number = 22;
  @State isActive: boolean = false;

  aboutToAppear() {
    this.showRandomAction();
  }

  // 显示随机行动建议
  private showRandomAction() {
    const randomIndex = Math.floor(Math.random() * this.actions.length);
    this.currentAction = this.actions[randomIndex];
    this.textSize = 22;
    this.isActive = false;
  }

  // 返回功能汇总页面并显示表扬
  private completeAction() {
    // 随机选择一条表扬语句
    const randomIndex = Math.floor(Math.random() * this.praises.length);
    const praiseMessage = this.praises[randomIndex];

    // 显示表扬提示
    promptAction.showToast({
      message: praiseMessage,
      duration: 2000,
      bottom: 200
    });
    this.backToAdjustPage();

    // 延迟返回，让用户看到表扬信息
    /*setTimeout(() => {
      this.backToAdjustPage();
    }, 500);*/
  }

  // 返回功能汇总页面
  private backToAdjustPage() {
    this.pageStack.pop();
  }

  // 构建行动建议显示区域
  @Builder
  private buildActionArea() {
    Column() {
      // 行动图标
      Image($r('app.media.ic_randomAction'))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 20 })
        .opacity(this.isActive ? 1 : 0.7)

      // 行动内容卡片
      Text(this.currentAction)
        .fontSize(this.textSize)
        .fontColor($r('app.color.random_action_text'))
        .textAlign(TextAlign.Center)
        .lineHeight(35)
        .padding(25)
        .backgroundColor($r('app.color.random_action_card_background'))
        .borderRadius(15)
        .border({ width: 1, color: $r('app.color.random_action_card_border') })
        .shadow({ radius: 8, color: '#40000000', offsetX: 2, offsetY: 4 })
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      // 点击文字放大效果和图标动画
      this.textSize = this.textSize === 22 ? 26 : 22;
      this.isActive = !this.isActive;
    })
  }

  // 构建控制面板
  @Builder
  private buildControlPanel() {
    Column() {
      // 刷新按钮
      Button('换一个行动')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.random_action_button_refresh'))
        .fontColor($r('app.color.random_action_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.showRandomAction())
        .margin({ bottom: 15 })

      // 完成行动按钮
      Button('完成行动')
        .width(200)
        .height(50)
        .backgroundColor($r('app.color.random_action_button_complete'))
        .fontColor($r('app.color.random_action_button_text'))
        .fontSize(20)
        .borderRadius(25)
        .onClick(() => this.completeAction())
        .shadow({ radius: 5, color: '#40000000', offsetX: 2, offsetY: 2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .margin({ left: 15 })
            .onClick(() => this.backToAdjustPage())

          Text('随机行动建议')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.random_action_nav_title'))
            .margin({ left: 20 })

          Blank()
        }
        .width('100%')
        .height(90)
        .backgroundColor($r('app.color.random_action_nav_background'))
        .border({ width: { bottom: 1 }, color: $r('app.color.random_action_nav_border') })
        .margin({ top: -20 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 行动建议显示区域
        this.buildActionArea()

        // 控制面板
        this.buildControlPanel()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.random_action_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}

@Builder
export function RandomActionPageBuilder(param: object) {
  RandomActionPage()
}