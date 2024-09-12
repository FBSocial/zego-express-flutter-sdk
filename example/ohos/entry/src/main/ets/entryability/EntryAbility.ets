/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import window from '@ohos.window';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage)
    let applicationContext: Context = this.context.getApplicationContext()
    let atManager = abilityAccessCtrl.createAtManager()
    const permissionList: Array<Permissions> = [
      'ohos.permission.INTERNET',
      'ohos.permission.CAMERA',
      'ohos.permission.MEDIA_LOCATION',
      'ohos.permission.MICROPHONE',
      'ohos.permission.READ_MEDIA',
      'ohos.permission.WRITE_MEDIA',
      'ohos.permission.READ_IMAGEVIDEO',
      'ohos.permission.WRITE_IMAGEVIDEO',
      'ohos.permission.GET_NETWORK_INFO',
      'ohos.permission.GET_NETWORK_STATS',
      'ohos.permission.ENTERPRISE_GET_NETWORK_INFO',
      'ohos.permission.ENTERPRISE_MANAGE_NETWORK',
      'ohos.permission.KEEP_BACKGROUND_RUNNING'
    ]
    atManager.requestPermissionsFromUser(this.context, permissionList).then((data) => {
      console.info('data:' + JSON.stringify(data))
      console.info('data permissions:' + data.permissions)
      console.info('data authResults:' + data.authResults)
    }).catch((err: BusinessError) => {
      console.log(`NormalCapturer:createAudioCapturer err code:` + err.code + 'err msg:' + err.message);
      console.log(`NormalCapturer:createAudioCapturer err=${JSON.stringify(err)}`);
    })

  }
}
