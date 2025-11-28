//
//  BrightnessShim.m
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// Private DisplayServices APIs (MonitorControl-style)
extern CGError DisplayServicesGetBrightness(CGDirectDisplayID display,
                                            float *brightness);
extern CGError DisplayServicesSetBrightness(CGDirectDisplayID display,
                                            float brightness);

double BrightnessShim_Get(CGDirectDisplayID display) {
    float value = 0.0f;
    CGError err = DisplayServicesGetBrightness(display, &value);
    if (err != kCGErrorSuccess) {
        NSLog(@"[BrightnessShim] Get error: %d", (int)err);
        return -1.0;
    }
    return (double)value; // 0.0 ... 1.0
}

void BrightnessShim_Set(CGDirectDisplayID display, double level) {
    float clamped = (float)fmax(0.0, fmin(1.0, level));
    CGError err = DisplayServicesSetBrightness(display, clamped);
    if (err != kCGErrorSuccess) {
        NSLog(@"[BrightnessShim] Set error: %d", (int)err);
    }
}
