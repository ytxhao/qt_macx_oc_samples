#include "audio_unit_recoder.h"
#include <QDebug>
#import <foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include "macro/IMSMacro.h"

const AudioUnitElement inputBus = 1;
const AudioUnitElement outputBus = 0;

@class SGAudioEngine;
@protocol AudioRecorderDelegate <NSObject>
- (void)audioRecorder:(SGAudioEngine *)audioEngine
          inTimeStamp:(const AudioTimeStamp *)inTimeStamp
       inNumberFrames:(UInt32)inNumberFrames
               ioData:(AudioBufferList *)ioData;
@optional

@end

@interface SGAudioEngine : NSObject
@property (nonatomic, strong, nullable) NSString * filePath;
@property (nonatomic, assign) BOOL isStartRecord;
@property (nonatomic, assign) AUGraph            auGraph;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign,readonly) AudioStreamBasicDescription asbd;
@property (nonatomic, assign) AudioUnit _Nullable       audioUnit;
@property (nonatomic, assign) AudioComponentDescription ioUnitDesc;

@property (nonatomic, assign) NSInteger sampleRate;
@property (nonatomic, strong)NSURL *bgmFileURL;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) AudioUnit _Nullable       mixerUnit;
@property (nonatomic, assign) AUNode                    mixerNode;
@property (nonatomic, assign) AUNode                    ioNode;
@property (nonatomic, assign) AudioUnit _Nullable       ioUnit;
@property (nonatomic, assign) AUNode                    convertNode;
@property (nonatomic, assign) AudioUnit _Nullable       convertUnit;

@property (nonatomic, assign) AUNode                    filePlayerNode;
@property (nonatomic, assign) AudioUnit _Nullable       filePlayerUnit;
@property (nonatomic, assign) ExtAudioFileRef audioFile;
@property (nonatomic, weak, nullable) id<AudioRecorderDelegate> audioRecorderDelegate;
@end

@implementation SGAudioEngine
{
//    NSMutableArray <SMEasyAudioNode *>*_nodes;
    BOOL    _isGraphOpen;
}

- (instancetype)initWithSampleRate:(NSInteger)sampleRate fileURL:(NSURL *)fileURL bgmFileURL:(NSURL *)bgmFileURL{
    self = [super init];
    if (self) {
        self.sampleRate = sampleRate;
        self.fileURL = fileURL;
        self.bgmFileURL = bgmFileURL;
        [self createAudioUnitGraph];
        [self setupFilePlayer];
    }
    return self;
}

- (void)startRecording {
    [self prepareAudioFile];
    OSStatus statusCode = AUGraphStart(_auGraph);
    if (statusCode != noErr) {
        qDebug()<<"Could not start AUGraph error:"<<statusCode;
        exit(1);
    }
    qDebug()<<"AUGraph: start audio recording";
}

- (void)stopRecording {
    OSStatus statusCode = AUGraphStop(_auGraph);
    if (statusCode != noErr) {
        qDebug()<<"Could not stop AUGraph error:"<<statusCode;
        exit(1);
    }
    if (_audioFile != nil) {
        ExtAudioFileDispose(_audioFile);
    }
    qDebug()<<"AUGraph: stops audio recording";
}

- (void)prepareAudioFile {
    if (_fileURL == nil) {
        return ;
    }
    UInt32 bytesPerSample = 2;
    AudioStreamBasicDescription destinationFormat;
    memset(&destinationFormat, 0, sizeof(destinationFormat));
    destinationFormat.mSampleRate = Float64(_sampleRate);
    destinationFormat.mFormatID = kAudioFormatLinearPCM;
    destinationFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    destinationFormat.mBitsPerChannel = 8 * bytesPerSample;
    destinationFormat.mChannelsPerFrame = 2;
    destinationFormat.mBytesPerFrame = bytesPerSample * 2;
    destinationFormat.mFramesPerPacket = 1;
    destinationFormat.mBytesPerPacket = bytesPerSample * 2;

    UInt32 size = sizeof(destinationFormat);
    OSStatus statusCode = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                            0,
                                            nil,
                                            &size,
                                            &destinationFormat);
    if (statusCode != noErr) {
        qDebug()<<"AudioFormatGetProperty failed error:"<<statusCode;
        exit(1);
    }

    statusCode = ExtAudioFileCreateWithURL((__bridge CFURLRef)_fileURL,
                                           kAudioFileCAFType,
                                           &destinationFormat,
                                           nil,
                                           kAudioFileFlags_EraseFile,
                                           &_audioFile);
    if (statusCode != noErr) {
        qDebug()<<"ExtAudioFileCreateWithURL failed error:"<<statusCode;
        exit(1);
    }

//    UInt32 codec = kAppleHardwareAudioCodecManufacturer;
//    statusCode = ExtAudioFileSetProperty(audioFile,
//                                         kExtAudioFileProperty_CodecManufacturer,
//                                         sizeof(codec),
//                                         &codec);
     statusCode = ExtAudioFileWriteAsync(_audioFile, 0, nil);
     if (statusCode != noErr) {
         qDebug()<<"ExtAudioFileWriteAsync failed error:"<<statusCode;
         exit(1);
     }
}

- (void)setupFilePlayer {
    if (_bgmFileURL == nil) {
        return;
    }

    AudioFileID fileId;
    OSStatus statusCode = AudioFileOpenURL((__bridge CFURLRef)_bgmFileURL, kAudioFileReadPermission, 0, &fileId);
    if (statusCode != noErr) {
        qDebug()<<"Could not open audio file error:"<<statusCode;
        exit(1);
    }
    statusCode = AudioUnitSetProperty(_filePlayerUnit,
                                      kAudioUnitProperty_ScheduledFileIDs,
                                      kAudioUnitScope_Global,
                                      0,
                                      &fileId,
                                      sizeof(fileId));
    if (statusCode != noErr) {
        qDebug()<<"Could not tell file player unit load which file error:"<<statusCode;
        exit(1);
    }

    AudioStreamBasicDescription fileAudioStreamFormat;
    UInt32 propSize = sizeof(fileAudioStreamFormat);
    statusCode = AudioFileGetProperty(fileId,
                                         kAudioFilePropertyDataFormat,
                                         &propSize,
                                         &fileAudioStreamFormat);
    if (statusCode != noErr) {
        qDebug()<<"Could not get the audio data format from the file error:"<<statusCode;
        exit(1);
    }

    UInt64 numberOfPackets;
    propSize = sizeof(numberOfPackets);
    statusCode = AudioFileGetProperty(fileId,
                                      kAudioFilePropertyAudioDataPacketCount,
                                      &propSize,
                                      &numberOfPackets);
    if (statusCode != noErr) {
        qDebug()<<"Could not get number of packets from the file error:"<<statusCode;
        exit(1);
    }

//    ScheduledAudioFileRegion rgn = ScheduledAudioFileRegion(mTimeStamp: .init(),
//                                       mCompletionProc: nil,
//                                       mCompletionProcUserData: nil,
//                                       mAudioFile: fileId,
//                                       mLoopCount: 0,
//                                       mStartFrame: 0,
//                                       mFramesToPlay: UInt32(numberOfPackets) * fileAudioStreamFormat.mFramesPerPacket);

    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = fileId;    //要播放的文件
    rgn.mLoopCount = 0;             //  0 不循环
    rgn.mStartFrame = 0;            //  播放起始位置
    rgn.mFramesToPlay = UInt32(numberOfPackets) * fileAudioStreamFormat.mFramesPerPacket;
    statusCode = AudioUnitSetProperty(_filePlayerUnit,
                                       kAudioUnitProperty_ScheduledFileRegion,
                                       kAudioUnitScope_Global,
                                       0,
                                       &rgn,
                                       sizeof(rgn));
    if (statusCode != noErr) {
        qDebug()<<"Could not set file player unit`s region error:"<<statusCode;
        exit(1);
    }

    UInt32 defaultValue = 0;
    statusCode = AudioUnitSetProperty(_filePlayerUnit,
                                      kAudioUnitProperty_ScheduledFilePrime,
                                      kAudioUnitScope_Global,
                                      0,
                                      &defaultValue,
                                      sizeof(defaultValue));

    if (statusCode != noErr) {
        qDebug()<<"Could not set file player unit`s prime error:"<<statusCode;
        exit(1);
    }

    // tell the file player AU when to start playing (-1 sample time means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    statusCode = AudioUnitSetProperty(_filePlayerUnit,
                                  kAudioUnitProperty_ScheduleStartTimeStamp,
                                  kAudioUnitScope_Global,
                                  0,
                                  &startTime,
                                  sizeof(startTime));
    if (statusCode != noErr) {
        qDebug()<<"Could not set file player unit`s start time error:"<<statusCode;
        exit(1);
    }

}

- (void)createAudioUnitGraph {
    OSStatus statusCode = NewAUGraph(&_auGraph);
    if (statusCode != noErr) {
        qDebug()<<"Could not create a new AUGraph error:"<<statusCode;
        exit(1);
    }

    [self addAudioUnitNodes];

    statusCode = AUGraphOpen(_auGraph);
    if (statusCode != noErr) {
       qDebug()<<"Could not open AUGraph error:"<<statusCode;
       exit(1);
    }

    [self getUnitsFromNodes];

    [self setAudioUnitsProperties];

    [self makeNodesConnection];

    statusCode = AUGraphInitialize(_auGraph);
    if (statusCode != noErr) {
        qDebug()<<"Could not initialize AUGraph error:"<<statusCode;
        exit(1);
    }
}

- (void)makeNodesConnection {
    OSStatus statusCode = AUGraphConnectNodeInput(_auGraph, _ioNode, inputBus, _convertNode, 0);
    if (statusCode != noErr) {
        qDebug()<<"I/O node element 1 connect to convert node element 0 error:"<<statusCode;
        exit(1);
    }
    statusCode = AUGraphConnectNodeInput(_auGraph, _convertNode, 0, _mixerNode, 0);
    if (statusCode != noErr) {
        qDebug()<<"convert node element 0 connect to mixer node element 0 error:"<<statusCode;
        exit(1);
    }
    if (_bgmFileURL == nil) {
        statusCode = AUGraphConnectNodeInput(_auGraph, _filePlayerNode, 0, _mixerNode, 1);
        if (statusCode != noErr) {
            qDebug()<<"file player node element 0 connect to mixer node element 1 error:"<<statusCode;
            exit(1);
        }
    }
    AURenderCallbackStruct inputCallback;
    inputCallback.inputProc = renderCallback;
    inputCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    statusCode = AUGraphSetNodeInputCallback(_auGraph, _ioNode, outputBus, &inputCallback);
    if (statusCode != noErr) {
        qDebug()<<"Could not set input callback for I/O node error:"<<statusCode;
        exit(1);
    }
}

- (void)setAudioUnitsProperties {
    UInt32 enableIO = 1;
    OSStatus statusCode = AudioUnitSetProperty(_ioUnit,
                                          kAudioOutputUnitProperty_EnableIO,
                                          kAudioUnitScope_Input,
                                          inputBus,
                                          &enableIO,
                                          sizeof(enableIO));
    if (statusCode != noErr) {
       qDebug()<<"Could not enable I/O for I/O unit input element 1 error:"<<statusCode;
       exit(1);
    }

    UInt32 bytesPerSample = 2;
    AudioStreamBasicDescription stereoStreamFormat;
    bzero(&stereoStreamFormat, sizeof(stereoStreamFormat));
    stereoStreamFormat.mSampleRate = Float64(_sampleRate);
    stereoStreamFormat.mFormatID = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    stereoStreamFormat.mBitsPerChannel = 8 * bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame = 2;
    stereoStreamFormat.mBytesPerFrame = bytesPerSample * 2;
    stereoStreamFormat.mFramesPerPacket = 1;
    stereoStreamFormat.mBytesPerPacket = stereoStreamFormat.mBytesPerFrame;

    statusCode = AudioUnitSetProperty(_ioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      inputBus,
                                      &stereoStreamFormat,
                                      sizeof(stereoStreamFormat));

    if (statusCode != noErr) {
       qDebug()<<"Could not set stream format for I/O unit output element 1 error:"<<statusCode;
       exit(1);
    }

    statusCode = AudioUnitSetProperty(_convertUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      0,
                                      &stereoStreamFormat,
                                      sizeof(stereoStreamFormat));
    if (statusCode != noErr) {
       qDebug()<<"Could not set stream format for convert unit output element 0 error:"<<statusCode;
       exit(1);
    }

    statusCode = AudioUnitSetProperty(_mixerUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      0,
                                      &stereoStreamFormat,
                                      sizeof(stereoStreamFormat));
    if (statusCode != noErr) {
       qDebug()<<"Could not set stream format for mixer unit output element 0 error:"<<statusCode;
       exit(1);
    }

    UInt32 mixerElementCount = _bgmFileURL == nil ? 1 : 2;
    statusCode = AudioUnitSetProperty(_mixerUnit,
                                      kAudioUnitProperty_ElementCount,
                                      kAudioUnitScope_Input,
                                      0,
                                      &mixerElementCount,
                                      sizeof(mixerElementCount));
    if (statusCode != noErr) {
       qDebug()<<"Could not set element count for mixer unit input element 0 error:"<<statusCode;
       exit(1);
    }

    statusCode = AudioUnitSetProperty(_ioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Input,
                                      outputBus,
                                      &stereoStreamFormat,
                                      sizeof(stereoStreamFormat));

    if (statusCode != noErr) {
       qDebug()<<"Could not set stream format for I/O unit output element 0 error:"<<statusCode;
       exit(1);
    }
}

- (void)getUnitsFromNodes {
    OSStatus statusCode = AUGraphNodeInfo(_auGraph, _ioNode, nil, &_ioUnit);
    if (statusCode != noErr) {
       qDebug()<<"Could not retrieve node info for I/O node error:"<<statusCode;
       exit(1);
    }
    statusCode = AUGraphNodeInfo(_auGraph, _convertNode, nil, &_convertUnit);
    if (statusCode != noErr) {
       qDebug()<<"Could not retrieve node info for convert node error:"<<statusCode;
       exit(1);
    }

    if (_bgmFileURL != nil) {
        statusCode = AUGraphNodeInfo(_auGraph, _filePlayerNode, nil, &_filePlayerUnit);
        if (statusCode != noErr) {
           qDebug()<<"Could not retrieve node info for file player node error:"<<statusCode;
           exit(1);
        }
    }

    statusCode = AUGraphNodeInfo(_auGraph, _mixerNode, nil, &_mixerUnit);
    if (statusCode != noErr) {
       qDebug()<<"Could not retrieve node info for mixer node error:"<<statusCode;
       exit(1);
    }
}

- (void)addAudioUnitNodes {
    AudioComponentDescription ioDescription;
    bzero(&ioDescription, sizeof(ioDescription));
    ioDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioDescription.componentType = kAudioUnitType_Output;
    ioDescription.componentSubType = kAudioUnitSubType_HALOutput;
//    ioDescription.componentSubType = kAudioUnitSubType_RemoteIO;

    OSStatus status = AUGraphAddNode(_auGraph, &ioDescription, &_ioNode);
    if (status != noErr) {
        qDebug()<<"Could not add I/O node to AUGraph error:"<<status;
        exit(1);
    }

    AudioComponentDescription converterDescription;
    bzero(&converterDescription, sizeof(converterDescription));
    converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    converterDescription.componentType = kAudioUnitType_FormatConverter;
    converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
    OSStatus statusCode = AUGraphAddNode(_auGraph, &converterDescription, &_convertNode);
    if (statusCode != noErr) {
        qDebug()<<"Could not add converter node to AUGraph  error:"<<status;
        exit(1);
    }

    if (_bgmFileURL != nil) {
        AudioComponentDescription filePlayerDescription;
        bzero(&filePlayerDescription, sizeof(filePlayerDescription));
        filePlayerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        filePlayerDescription.componentType = kAudioUnitType_Generator;
        filePlayerDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
        statusCode = AUGraphAddNode(_auGraph, &filePlayerDescription, &_filePlayerNode);

        if (statusCode != noErr) {
            qDebug()<<"Could not add file player node to AUGraph error:"<<status;
            exit(1);
        }
    }

    AudioComponentDescription mixerDescription;
    bzero(&mixerDescription, sizeof(mixerDescription));
    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerDescription.componentType = kAudioUnitType_Mixer;
    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    statusCode = AUGraphAddNode(_auGraph, &mixerDescription, &_mixerNode);
    if (statusCode != noErr) {
        qDebug()<<"Could not add mixer node to AUGraph error:"<<status;
        exit(1);
    }


}

- (void)addAUNode {
//    AudioComponentDescription mixerDescription;
//    bzero(&mixerDescription, sizeof(mixerDescription));
//    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
//    mixerDescription.componentType = kAudioUnitType_Mixer;
//    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
//    statusCode = AUGraphAddNode(self.auGraph, &mixerDescription, &mixerNode);
//    if statusCode != noErr {
//        DDLogError("Could not add mixer node to AUGraph \(statusCode)")
//        exit(1)
//    }
}

static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    __unsafe_unretained SGAudioEngine *audioEngine = (__bridge SGAudioEngine *)inRefCon;
    OSStatus statusCode = AudioUnitRender(audioEngine.mixerUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    if (statusCode == noErr) {
        if (audioEngine.audioFile != nil) {
            statusCode = ExtAudioFileWriteAsync(audioEngine.audioFile, inNumberFrames, ioData);
            if (statusCode != noErr) {
                qDebug()<<"ExtAudioFileWriteAsync failed error:"<<statusCode;
                exit(1);
            }
        }
        if (audioEngine && [audioEngine.audioRecorderDelegate respondsToSelector:@selector(audioRecorder:inTimeStamp:inNumberFrames:ioData:)]) {
            [audioEngine.audioRecorderDelegate audioRecorder:audioEngine inTimeStamp:inTimeStamp inNumberFrames:inNumberFrames ioData:ioData];
        }
    }
    return statusCode;
}

@end

AudioUnitRecoder::AudioUnitRecoder()
{

}




int AudioUnitRecoder::InitRecoder(int sample_rate,const std::string& fileURL, const std::string& bgmFileURL) {
    return 0;
}


