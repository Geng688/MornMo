/*
@Component
export struct BreathingBall {
  @State private scale: number = 1.0;
  @State private text: string = '吸气...';
  private animation: any = null;
  private breathPattern: number[] = [4, 7, 8]; // 4秒吸气，7秒屏息，8秒呼气

  aboutToDisappear() {
    this.stopAnimation();
  }

  private startAnimation(pattern: number[]) {
    let step = 0;
    let index = 0;

    this.animation = setInterval(() => {
      if (step === 0) {
        this.text = '吸气...';
        animateTo({ duration: pattern[0] * 1000 }, () => {
          this.scale = 1.5;
        });
      } else if (step === 1) {
        this.text = '屏息...';
      } else {
        this.text = '呼气...';
        animateTo({ duration: pattern[2] * 1000 }, () => {
          this.scale = 1.0;
        });
      }

      step = (step + 1) % 3;
      if (step === 0) index = (index + 1) % this.breathPattern.length;
    }, (pattern[0] + pattern[1] + pattern[2]) * 1000);
  }

  private stopAnimation() {
    if (this.animation) {
      clearInterval(this.animation);
      this.animation = null;
      this.scale = 1.0;
      this.text = '已暂停';
    }
  }

  build() {
    Column({ space: 20 }) {
      Circle()
        .width(150)
        .height(150)
        .fill(Color.Blue)
        .scale({ x: this.scale, y: this.scale })
        .animation({ duration: 1000, curve: Curve.EaseInOut })

      Text(this.text)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row({ space: 30 }) {
        Button('暂停').onClick(() => this.stopAnimation())
        Button('继续').onClick(() => this.startAnimation(this.breathPattern))
      }
    }
    .onAppear(() => this.startAnimation(this.breathPattern))
  }
}
*/
