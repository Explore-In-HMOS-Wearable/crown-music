import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class CustomAudioManager {
  private groupId: number = audio.DEFAULT_VOLUME_GROUP_ID;
  private audioManager: audio.AudioManager | undefined = undefined;
  private audioVolumeManager: audio.AudioVolumeManager | undefined = undefined;
  private audioVolumeGroupManager: audio.AudioVolumeGroupManager | undefined = undefined;

  public static getInstance(): CustomAudioManager {
    let customAudioManager: CustomAudioManager | undefined = AppStorage.get('customAudioManager');
    if (!customAudioManager) {
      hilog.debug(0, 'audioPrefix', `customAudioManager is undefined in getInstance()`)
      customAudioManager = new CustomAudioManager();
      AppStorage.setOrCreate<CustomAudioManager>('customAudioManager', customAudioManager);
    }
    hilog.debug(0, 'audioPrefix', `customAudioManager is ${customAudioManager}`)
    return customAudioManager;
  }

  public async initAudioVolumeGroupManager(): Promise<void> {
    try {
      this.audioManager = audio.getAudioManager();
      this.audioVolumeManager = this.audioManager.getVolumeManager();
      this.audioVolumeGroupManager = await this.audioVolumeManager.getVolumeGroupManager(this.groupId);
      console.info('AudioVolumeGroupManager was taken successfully.');
    } catch (err) {
      console.error('VolumeGroupManager error:', err);
    }
  }

  public async getVolume(): Promise<number> {
    return new Promise((resolve) => {
      if (this.audioVolumeGroupManager) {
        this.audioVolumeGroupManager.getVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
          if (err) {
            console.error(`Failed to obtain the volume. ${err}`);
            resolve(-1);
          } else {
            resolve(value);
          }
        });
      } else {
        resolve(-1);
      }
    });
  }

  public async getMinVolume(): Promise<number> {
    return new Promise((resolve) => {
      if (this.audioVolumeGroupManager) {
        this.audioVolumeGroupManager.getMinVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
          if (err) {
            console.error(`Failed to obtain the minimum volume. ${err}`);
            resolve(-1);
          }
          console.info(`Callback invoked to indicate that the minimum volume is obtained. ${value}`);
          resolve(value);
        });
      } else {
        resolve(-1);
      }
    });
  }

  public async getMaxVolume(): Promise<number> {
    return new Promise((resolve) => {
      if (this.audioVolumeGroupManager) {
        this.audioVolumeGroupManager.getMaxVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
          if (err) {
            console.error(`Failed to obtain the maximum volume. ${err}`);
            resolve(-1);
          }
          console.info(`Callback invoked to indicate that the maximum volume is obtained. ${value}`);
          resolve(value);
        });
      } else {
        resolve(-1);
      }
    });
  }
}