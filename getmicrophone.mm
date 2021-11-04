#include "getmicrophone.h"
#include <QDebug>
#import <CoreAudio/CoreAudio.h>
#import <foundation/foundation.h>
#include <string>

int isMicrophoneAuthorization(comannHander comandhander)
{
    int flag = 0;
    qDebug()<<"isMicrophoneAuthorization--start";
//    int flag = [PrivacyAuthorizer authorMicphone];
//    if(flag == 3)
//    {
//        [PrivacyAuthorizer requestAuthorMicphone:^(BOOL granted) {
//                comandhander(granted);
//            }];
//    }

    AudioDeviceID inID = kAudioDeviceUnknown;
    AudioDeviceID outID = kAudioDeviceUnknown;

    UInt32 propertySize0 = sizeof(inID);
    UInt32 propertySize1 = sizeof(outID);

    AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &propertySize0, &inID);
    AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice , &propertySize1, &outID);

    NSLog(@"outID : %d",outID);
    comandhander(1);
    qDebug()<<"isMicrophoneAuthorization--flag--"<<flag;

    return flag;

}
