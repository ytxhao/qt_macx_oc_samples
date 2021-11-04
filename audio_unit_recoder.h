#ifndef AUDIO_UNIT_RECODER_H
#define AUDIO_UNIT_RECODER_H
#include <string>


class AudioUnitRecoder
{
public:
    AudioUnitRecoder();

//    (NSInteger)sampleRate fileURL:(NSURL *)fileURL bgmFileURL:(NSURL *)bgmFileURL
   int InitRecoder(int sample_rate,const std::string& fileURL, const std::string& bgmFileURL);
};

#endif // AUDIO_UNIT_RECODER_H
