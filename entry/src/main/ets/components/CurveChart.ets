interface DataItem {
  date: string;
  value: number;
}

@Component
export struct CurveChart {
  @Prop @Watch('onDataChange') data: DataItem[];
  @Prop itemWidth: number = 10; // 每个数据点的宽度
  @Prop chartHeight: number = 260; // 适当增加图表高度，为更大字体留出空间
  private chartPadding: number = 40; // 增加边距，为更大字体留出空间
  @Prop chartWidth: number = Math.max(this.data.length > 0 ? this.data.length * this.itemWidth : 300, 300) + 2 * this.chartPadding; // 适当增加图表高度，为更大字体留出空间
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private xAxisLength: number = 0;
  private yAxisLength: number = 0;

  // @Watch 回调函数：当 data 变化时重新绘制
  onDataChange() {
    console.log('CurveChart data changed, redrawing...');
    this.calculateDimensions();
    this.drawChart();
  }

  aboutToAppear() {
    console.log(`CurveChart aboutToAppear - data length: ${this.data.length}`);
    this.calculateDimensions();
  }

  private calculateDimensions() {
    this.canvasWidth = this.chartWidth;
    this.canvasHeight = this.chartHeight;
    this.xAxisLength = this.canvasWidth - 2 * this.chartPadding;
    this.yAxisLength = this.canvasHeight - 2 * this.chartPadding;

    console.log(`Canvas dimensions: ${this.canvasWidth}x${this.canvasHeight}`);
  }

  // 绘制坐标轴
  private drawAxes() {
    // 清除画布
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 设置线条样式
    this.canvasContext.strokeStyle = '#CCCCCC';
    this.canvasContext.lineWidth = 1;

    // X轴
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(this.chartPadding, this.canvasHeight - this.chartPadding);
    this.canvasContext.lineTo(this.canvasWidth - this.chartPadding, this.canvasHeight - this.chartPadding);
    this.canvasContext.stroke();

    // Y轴
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(this.chartPadding, this.chartPadding);
    this.canvasContext.lineTo(this.chartPadding, this.canvasHeight - this.chartPadding);
    this.canvasContext.stroke();

    // Y轴刻度/网格线
    for (let i = 0; i <= 100; i += 20) {
      const y = this.canvasHeight - this.chartPadding - (i / 100) * this.yAxisLength;

      // 刻度线
      this.canvasContext.beginPath();
      this.canvasContext.moveTo(this.chartPadding - 8, y);
      this.canvasContext.lineTo(this.chartPadding, y);
      this.canvasContext.stroke();

      // 网格线
      this.canvasContext.beginPath();
      this.canvasContext.setLineDash([2, 2]);
      this.canvasContext.moveTo(this.chartPadding, y);
      this.canvasContext.lineTo(this.canvasWidth - this.chartPadding, y);
      this.canvasContext.stroke();
      this.canvasContext.setLineDash([]);

      // 刻度值 - 增大字体
      this.canvasContext.fillStyle = '#666666';
      this.canvasContext.font = 'bold 50px sans-serif'; // 增大到14px并加粗
      this.canvasContext.textAlign = 'right';
      this.canvasContext.fillText(i.toString(), this.chartPadding - 12, y + 5);
    }
  }

  // 绘制数据曲线
  private drawCurve() {
    if (this.data.length === 0) {
      console.log("No data to draw curve");
      return;
    }

    console.log(`Drawing curve with ${this.data.length} data points`);

    const pointCount = this.data.length;
    const xStep = pointCount > 1 ? this.xAxisLength / (pointCount - 1) : 0;

    // 绘制曲线
    this.canvasContext.beginPath();

    this.data.forEach((item, index) => {
      const x = this.chartPadding + index * xStep;
      const y = this.canvasHeight - this.chartPadding - (item.value / 100) * this.yAxisLength;

      if (index === 0) {
        this.canvasContext.moveTo(x, y);
      } else {
        this.canvasContext.lineTo(x, y);
      }
    });

    // 设置曲线样式并绘制
    this.canvasContext.strokeStyle = '#4A90E2';
    this.canvasContext.lineWidth = 2;
    this.canvasContext.stroke();

    // 填充曲线下方区域
    if (pointCount > 1) {
      this.canvasContext.lineTo(this.chartPadding + (pointCount - 1) * xStep, this.canvasHeight - this.chartPadding);
      this.canvasContext.lineTo(this.chartPadding, this.canvasHeight - this.chartPadding);
      this.canvasContext.closePath();

      const gradient = this.canvasContext.createLinearGradient(
        this.chartPadding, this.chartPadding,
        this.chartPadding, this.canvasHeight - this.chartPadding
      );
      gradient.addColorStop(0, 'rgba(74, 144, 226, 0.3)');
      gradient.addColorStop(1, 'rgba(74, 144, 226, 0)');
      this.canvasContext.fillStyle = gradient;
      this.canvasContext.fill();
    }

    // 绘制数据点
    this.data.forEach((item, index) => {
      const x = this.chartPadding + index * xStep;
      const y = this.canvasHeight - this.chartPadding - (item.value / 100) * this.yAxisLength;

      // 数据点
      this.canvasContext.fillStyle = getFaceColor(item.value);
      this.canvasContext.beginPath();
      this.canvasContext.arc(x, y, 5, 0, 2 * Math.PI);
      this.canvasContext.fill();

      // 日期标签 - 增大字体
      this.canvasContext.fillStyle = '#666666';
      this.canvasContext.font = 'bold 50px sans-serif'; // 增大到14px并加粗
      this.canvasContext.textAlign = 'center';
      this.canvasContext.fillText(item.date, x, this.canvasHeight - this.chartPadding + 22);

      // 数值标签 - 增大字体
      this.canvasContext.fillStyle = '#333333';
      this.canvasContext.font = 'bold 50px sans-serif'; // 增大到14px并加粗
      this.canvasContext.fillText(item.value.toString(), x, y - 12);
    });
  }

   drawChart() {
    console.log("Drawing chart");
     this.drawAxes();
    this.drawCurve();
  }

  build() {
    Column() {
      Canvas(this.canvasContext)
        .width(this.chartWidth)
        .height(this.chartHeight)
        .backgroundColor('#FFCC99')
/*        .onReady(() => {
          console.log("Canvas is ready");
          this.calculateDimensions();
          this.drawChart();
        })*/
        .onSizeChange((oldSize: SizeOptions, newSize: SizeOptions) => {
          console.log(`Canvas size changed: ${oldSize.width}x${oldSize.height} -> ${newSize.width}x${newSize.height}`);
          this.canvasWidth = lengthToNumber(newSize.width);
          this.canvasHeight = lengthToNumber(newSize.height);
          this.xAxisLength = this.canvasWidth - 2 * this.chartPadding;
          this.yAxisLength = this.canvasHeight - 2 * this.chartPadding;
          this.drawChart();
        })
    }
    .width(this.canvasWidth)
    .height(this.chartHeight)
    .shadow({
      radius: 10,
      color: Color.Gray,
      offsetX: 20,
      offsetY: 20
    })
  }
}

// 类型转换辅助函数
function lengthToNumber(length: Length | undefined): number {
  if (length === undefined) {
    return 0;
  }
  if (typeof length === 'number') {
    return length;
  } else if (typeof length === 'string') {
    const match = length.match(/^(\d+)(px)?$/);
    return match && match[1] ? parseInt(match[1], 10) : 0;
  }
  return 0;
}

// 颜色算法
function getFaceColor(moodValue: number): string {
  const startRed = 92, startGreen = 255, startBlue = 92;
  const endRed = 255, endGreen = 92, endBlue = 92;
  const red = Math.floor(startRed + (endRed - startRed) * (moodValue / 100));
  const green = Math.floor(startGreen + (endGreen - startGreen) * (moodValue / 100));
  const blue = Math.floor(startBlue + (endBlue - startBlue) * (moodValue / 100));
  return `rgb(${red}, ${green}, ${blue})`;
}
