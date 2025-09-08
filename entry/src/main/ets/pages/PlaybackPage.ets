import { MediaController } from '../audio/MediaController';
import { MusicModel } from '../common/model/MusicModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CustomAudioManager } from '../audio/CustomAudioManager';
import { CustomDialogVolume } from '../common/util/CustomDialogVolume';

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
}

@Component
export struct PlaybackPage {
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('musicList') musicList: MusicModel[] = [];
  @StorageLink('currentTime') currentTime: string = '00:00';
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageLink('progress') value: number = 0;
  @StorageLink('progressMax') max: number = 0;
  @State cumulativeDegree: number = 0;
  @State threshold: number = 10;
  @State volume: number = 50;
  @State progressValue: number = 0;
  @State totalValue: number = 0;
  @State minValue: number = 0;

  async aboutToAppear() {
    await CustomAudioManager.getInstance().initAudioVolumeGroupManager()
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogVolume({ progressValue: this.progressValue, totalValue: this.totalValue, minValue: this.minValue }),
    backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
    cornerRadius: 600
  })

  build() {
    Stack() {
      Progress({
        value: this.value,
        total: this.max,
        type: ProgressType.Ring
      })
        .aspectRatio(1)
        .value(this.value)
        .width('100%')
        .color(Color.Pink)
        .style({ strokeWidth: 8 })
        .backgroundColor(Color.Gray)

      Column() {
        Column() {
          Text(this.currentTime)
            .fontColor('#ffff71ab')
            .fontSize(14)
          Text(this.musicList[this.selectIndex].title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Pink)
            .margin({ top: 4 })
          Text(this.musicList[this.selectIndex].artist)
            .fontSize(14)
            .fontColor(Color.Pink)
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })

        Row() {
          Image($r('app.media.ic_prev'))
            .controlImageBuilder()
            .width(40)
            .onClick(() => {
              MediaController.getInstance().playPrevious();
            })

          // Play & Pause
          Image(this.isPlay ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
            .controlImageBuilder()
            .width(45)
            .onClick(() => {
              hilog.error(0xFF00, 'MusicPlay', `onClick play pause ${this.isPlay}`);

              if (this.isPlay) {
                MediaController.getInstance().pause();
              } else {
                if (MediaController.getInstance().getFirst()) {
                  MediaController.getInstance().startByIndex();
                } else {
                  MediaController.getInstance().resume();
                }
              }
            })

          Image($r('app.media.ic_next'))
            .controlImageBuilder()
            .width(40)
            .onClick(() => {
              MediaController.getInstance().playNext();
            })
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .layoutWeight(1)
        .padding({
          left: 4,
          right: 4,
          top: 8,
          bottom: 4
        })
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
        .onDigitalCrown((event: CrownEvent) => {
          event.stopPropagation();
          console.debug('action:%d, angularVelocity:%f, degree:%f, timestamp:%f',
            event.action, event.angularVelocity, event.degree, event.timestamp);
          this.cumulativeDegree += event.degree;

          if (Math.abs(this.cumulativeDegree) >= this.threshold) {
            if (this.cumulativeDegree > 0) {
              console.info('crown - Prev')
              MediaController.getInstance().playPrevious();
            } else {
              console.info('crown - Next')
              MediaController.getInstance().playNext();
            }
            this.cumulativeDegree = 0;
          }
        })

        Image($r('app.media.ic_volume'))
          .controlImageBuilder()
          .width(40)
          .onClick(async () => {
            await CustomAudioManager.getInstance().getVolume().then((result) => {
              this.progressValue = result
            })
            await CustomAudioManager.getInstance().getMaxVolume().then((result) => {
              this.totalValue = result
            })
            await CustomAudioManager.getInstance().getMinVolume().then((result) => {
              this.minValue = result
            })
            this.dialogController.open()
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding(30)

    }
    .width('100%')
    .height('100%')
  }
}