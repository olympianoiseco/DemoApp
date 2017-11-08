//
//  ViewController.m
//  My Awesome Music App
//
//  Created by Benjamin Kamen on 11/7/17.
//  Copyright © 2017 Olympia Noise Co. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ONCTouchView.h"

@interface ViewController () {
 
    ONCTouchView * _touchView;

    // audio engine
    AVAudioEngine * _engine;
    
    // sampler
    AVAudioUnitSampler * _sampler;
    
    // delay unit
    AVAudioUnitDelay * _delay;
    
    // mixer
    AVAudioMixerNode * _mixerNode;
    
    // timer
    NSTimer * _timer;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _touchView = (ONCTouchView *)[self view];
    
    // create my engine
    _engine = [[AVAudioEngine alloc] init];
    
    // get the mixer node
    _mixerNode = [_engine mainMixerNode];
    
    _sampler = [[AVAudioUnitSampler alloc] init];
    
    NSURL * bankURL = [[NSBundle mainBundle] URLForResource:@"gs_instruments" withExtension:@"dls"];
    
    NSError * error;
    [_sampler loadSoundBankInstrumentAtURL:bankURL
                                   program:25
                                   bankMSB:0x79
                                   bankLSB:0
                                     error:&error];
    if (error != nil) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    [_engine attachNode:_sampler];
    
    AVAudioFormat * stereoFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:2];
    
    [_engine connect:_sampler
                  to:_mixerNode
              format:stereoFormat];
    
    [_engine startAndReturnError:&error];
 
    __block NSInteger counter = 0;
    
    _timer = [NSTimer timerWithTimeInterval:.125 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSArray * notes = [_touchView currentNotes];
        if (notes && notes.count > 0) {
            NSNumber * currentNote = notes[counter % notes.count];
            [self makeNote:currentNote.integerValue
                  velocity:127
                  duration:.5];
            
            counter++;
        }
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
  

}

- (void)makeNote:(Byte)note velocity:(Byte)velocity duration:(NSTimeInterval)durationInSeconds {
    [self noteOn:note velocity:velocity];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durationInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self noteOff:note];
    });
}



- (void)noteOn:(Byte)note velocity:(Byte)velocity {
    NSLog(@"note on");
    Byte status = 144; // note-on status byte
    Byte data1 = note;
    Byte data2 = velocity;
    MusicDeviceMIDIEvent(_sampler.audioUnit, status, data1, data2, 0);
}

- (void)noteOff:(Byte)note {
    NSLog(@"note off");
    Byte status = 144; // note-on status byte
    Byte data1 = note;
    Byte data2 = 0;
    MusicDeviceMIDIEvent(_sampler.audioUnit, status, data1, data2, 0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
