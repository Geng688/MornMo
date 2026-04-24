@Component
export struct MoodFace {
  @Prop moodValue: number; // 0-100的开心值

  // 根据开心值选择合适的表情图片
  private getFaceImage(): Resource {
    if (this.moodValue > 70) {
      return $r('app.media.happy'); // 开心表情
    } else if (this.moodValue > 30) {
      return $r('app.media.bland'); // 中性表情
    } else {
      return $r('app.media.unhappy'); // 不开心表情
    }
  }

  // 计算面部颜色
  private getFaceColor(): string {
    // 起始颜色
    const startRed = 92;
    const startGreen = 255;
    const startBlue = 92;

    // 结束颜色
    const endRed = 255;
    const endGreen = 92;
    const endBlue = 92;

    // 计算当前颜色分量
    const red = Math.floor(startRed + (endRed - startRed) * (this.moodValue / 100));
    const green = Math.floor(startGreen + (endGreen - startGreen) * (this.moodValue / 100));
    const blue = Math.floor(startBlue + (endBlue - startBlue) * (this.moodValue / 100));

    return `rgb(${red}, ${green}, ${blue})`;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 面部背景圆形
      Circle()
        .width(180)
        .height(180)
        .fill(this.getFaceColor())

      // 表情图片（居中显示）
      Image(this.getFaceImage())
        .width(140)
        .height(140)
        .objectFit(ImageFit.Contain)
    }
    .clickEffect({level:ClickEffectLevel.HEAVY, scale: 0.5})
    .width(200)
    .height(200)
  }
}