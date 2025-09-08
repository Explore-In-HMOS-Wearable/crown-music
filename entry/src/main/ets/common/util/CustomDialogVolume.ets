import { AVVolumePanel } from "@kit.AudioKit";

@CustomDialog
export struct CustomDialogVolume {
  @Prop progressValue: number = 0
  @Prop totalValue: number = 0
  @Prop minValue: number = 0
  @State cumulativeDegree: number = 0;
  @State threshold: number = 10;
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomDialogVolume()
  })

  build() {
    Stack() {
      AVVolumePanel({
        volumeLevel: this.progressValue,
        volumeParameter: {
          position: { x: -9999, y: -9999 } // invisible
        }
      })
      Row() {
        Image($r('app.media.ic_volume'))
          .width(30)
          .onClick(() => {
            this.progressValue -= 1
            this.checkProgressValue();
          })
        Progress({ value: this.progressValue, total: this.totalValue, type: ProgressType.Capsule })
          .width(100)
          .height(40)
          .color(Color.Pink)
          .margin(4)
          .focusable(true)
          .focusOnTouch(true)
          .defaultFocus(true)
          .onDigitalCrown((event: CrownEvent) => {
            event.stopPropagation();
            console.debug('action:%d, angularVelocity:%f, degree:%f, timestamp:%f',
              event.action, event.angularVelocity, event.degree, event.timestamp);
            this.cumulativeDegree += event.degree;

            if (Math.abs(this.cumulativeDegree) >= this.threshold) {
              if (this.cumulativeDegree > 0) {
                console.info('crown - Prev')
                this.progressValue -= 1
              } else {
                console.info('crown - Next')
                this.progressValue += 1
              }
              this.cumulativeDegree = 0;
            }

            this.checkProgressValue();
          })

        Image($r('app.media.ic_volume_medium'))
          .width(27)
          .onClick(() => {
            this.progressValue += 1
            this.checkProgressValue();
          })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Image($r('app.media.ic_cross'))
        .width(30)
        .margin({ top: 10 })
        .onClick(() => {
          this.controller.close()
        })

    }.height(200)
    .alignContent(Alignment.Top)
  }

  private checkProgressValue() {
    if (this.progressValue < this.minValue) {
      this.progressValue = this.minValue;
    } else if (this.progressValue > this.totalValue) {
      this.progressValue = this.totalValue;
    }
  }
}