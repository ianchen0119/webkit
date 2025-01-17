/*
 *  Copyright 2017 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCDefaultVideoDecoderFactory.h"

#import "RTCH264ProfileLevelId.h"
#import "RTCVideoDecoderH264.h"
#import "api/video_codec/RTCVideoCodecConstants.h"
#import "api/video_codec/RTCVideoDecoderVP8.h"
#import "base/RTCVideoCodecInfo.h"
#if defined(RTC_ENABLE_VP9)
#import "api/video_codec/RTCVideoDecoderVP9.h"
#endif
#if !defined(RTC_DISABLE_H265)
#import "RTCH265ProfileLevelId.h"
#import "RTCVideoDecoderH265.h"
#endif

@implementation RTCDefaultVideoDecoderFactory {
  bool _supportH265;
}

- (id)initWithH265:(bool)supportH265
{
  self = [super init];
  if (self) {
      _supportH265 = supportH265;
  }
  return self;
}

- (NSArray<RTCVideoCodecInfo *> *)supportedCodecs {
  NSDictionary<NSString *, NSString *> *constrainedHighParams = @{
    @"profile-level-id" : kRTCMaxSupportedH264ProfileLevelConstrainedHigh,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  RTCVideoCodecInfo *constrainedHighInfo =
      [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecH264Name
                                   parameters:constrainedHighParams];

  NSDictionary<NSString *, NSString *> *constrainedBaselineParams = @{
    @"profile-level-id" : kRTCMaxSupportedH264ProfileLevelConstrainedBaseline,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  RTCVideoCodecInfo *constrainedBaselineInfo =
      [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecH264Name
                                   parameters:constrainedBaselineParams];

  RTCVideoCodecInfo *vp8Info = [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecVp8Name];

#if !defined(RTC_DISABLE_H265)
  RTCVideoCodecInfo *h265Info = [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecH265Name];
#endif
 
#if defined(RTC_ENABLE_VP9)
  RTCVideoCodecInfo *vp9Info = [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecVp9Name];
#endif

  if (!_supportH265) {
    return @[
      constrainedHighInfo,
      constrainedBaselineInfo,
      vp8Info,
#if defined(RTC_ENABLE_VP9)
      vp9Info,
#endif
    ];
  }
  return @[
    constrainedHighInfo,
    constrainedBaselineInfo,
#if !defined(RTC_DISABLE_H265)
    h265Info,
#endif
    vp8Info,
#if defined(RTC_ENABLE_VP9)
    vp9Info,
#endif
  ];
}

- (id<RTCVideoDecoder>)createDecoder:(RTCVideoCodecInfo *)info {
  if ([info.name isEqualToString:kRTCVideoCodecH264Name]) {
    return [[RTCVideoDecoderH264 alloc] init];
  } else if ([info.name isEqualToString:kRTCVideoCodecVp8Name]) {
    return [RTCVideoDecoderVP8 vp8Decoder];
#if !defined(RTC_DISABLE_H265)
  } else if ([info.name isEqualToString:kRTCVideoCodecH265Name]) {
    return [[RTCVideoDecoderH265 alloc] init];
#endif
#if defined(RTC_ENABLE_VP9)
  } else if ([info.name isEqualToString:kRTCVideoCodecVp9Name]) {
    return [RTCVideoDecoderVP9 vp9Decoder];
#endif
  }

  return nil;
}

@end
