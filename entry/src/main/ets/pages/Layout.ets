import { AdjustPage } from "./AdjustPage";
import { HomePage } from "./HomePage";
import { RecordCalendarPage} from "./RecordCalendarPage";
import { AppStorageV2 } from "@kit.ArkUI";
import { PopToCalendar } from "../models/PopToCalendar";
import { LayoutSec } from "./LayoutSec";
import { MailPage } from "./MailPage";
import { PopToMail } from "../models/PopToMail";
import { MoodGardenPage } from "./MoodGardenPage";


@Builder
export function LayoutBuilder(){
  Layout()
}

interface TabClass {
  text: string
  icon: ResourceStr
}


@ComponentV2
export struct Layout{
  pageStack:NavPathStack=new NavPathStack()
  hasPopToMail:PopToMail=AppStorageV2.connect(PopToMail,'POPTOMAIL_KEY',()=>new PopToMail())!
  @Local hasPopToCalendar:PopToCalendar=AppStorageV2.connect(PopToCalendar,'HASPOP_KEY',()=>new PopToCalendar())!
  @Local currentIndex:number=0
  tabData: TabClass[] = [
    {text: '首页', icon: $r('app.media.ic_home')},
    {text: '邮件', icon: $r('app.media.ic_mail')},
    {text: '心园', icon: $r('app.media.app_logo')},
    {text: '调节', icon: $r('app.media.ic_adjust')},
    {text: '记录', icon: $r('app.media.ic_record')},
  ]

  @Builder tabBuilder(item:TabClass,index:number) {
    Column({space:5}){
      Image(item.icon)
        .width(this.currentIndex===index ? 35 : 25)
        .height(this.currentIndex===index ? 35 : 25)
      Text(item.text)
        .fontSize(15)
        .fontColor($r('app.color.tab_text'))
    }

  }

  build() {
    NavDestination(){
    Column() {
      Tabs({index: this.currentIndex, barPosition: BarPosition.End }) {
        TabContent() {
          if(this.currentIndex==0){//用if重新渲染
            HomePage()
          }
        }.tabBar(this.tabBuilder(this.tabData[0], 0))

        TabContent() {
          if(this.currentIndex==1) {
            if(this.hasPopToMail.hasPop==1)MailPage()//用if重新渲染(跳到日历页面和从当日查询返回都要查询渲染)
            else MailPage()
          }
        }.tabBar(this.tabBuilder(this.tabData[1], 1))

        TabContent() {
          if(this.currentIndex==2) {
            MoodGardenPage()
          }
        }.tabBar(this.tabBuilder(this.tabData[2], 2))

        TabContent() {
          if(this.currentIndex==3) {
            LayoutSec()
          }
        }.tabBar(this.tabBuilder(this.tabData[3], 3))

        TabContent() {
          if(this.currentIndex==4) {
            if(this.hasPopToCalendar.hasPop==1)RecordCalendarPage()//用if重新渲染(跳到日历页面和从当日查询返回都要查询渲染)
            else RecordCalendarPage()
          }
        }.tabBar(this.tabBuilder(this.tabData[4], 4))

      }
      .scrollable(false)
      .animationDuration(0)
      .backgroundColor($r('app.color.tab_bar_background'))
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }.width('100%')
      .backgroundColor($r('app.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}