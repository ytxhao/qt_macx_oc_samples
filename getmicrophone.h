#ifndef GETMICROPHONE_H
#define GETMICROPHONE_H

typedef void(*comannHander)(bool granted);

int isMicrophoneAuthorization(comannHander comandhander);

#endif // GETMICROPHONE_H
