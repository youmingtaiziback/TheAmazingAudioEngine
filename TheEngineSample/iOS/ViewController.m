//
//  ViewController.m
//  Audio Controller Test Suite
//
//  Created by Michael Tyson on 13/02/2012.
//  Copyright (c) 2012 A Tasty Pixel. All rights reserved.
//

#import "ViewController.h"
#import "TheAmazingAudioEngine.h"
#import "TPOscilloscopeLayer.h"
#import "AEPlaythroughChannel.h"
#import "AEExpanderFilter.h"
#import "AELowPassFilter.h"
#import "AEHighPassFilter.h"
#import "AERecorder.h"
#import "AEReverbFilter.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () {
    // 低通过滤
    UILabel     *_lowPassCutoffFrequencyLabel;
    UISlider    *_lowPassCutoffFrequencySlider;
    UILabel     *_lowPassResonanceLabel;
    UISlider    *_lowPassResonanceSlider;

    // 高通过滤
    UILabel     *_highPassCutoffFrequencyLabel;
    UISlider    *_highPassCutoffFrequencySlider;
    UILabel     *_highPassResonanceLabel;
    UISlider    *_highPassResonanceSlider;
}
@property (nonatomic, strong) AELowPassFilter   *lowPassFilter;
@property (nonatomic, strong) AEHighPassFilter  *highPassFilter;
@property (nonatomic, strong) TPOscilloscopeLayer *inputOscilloscope;
@end

@implementation ViewController

#pragma mark - Life Cycle

- (id)initWithAudioController:(AEAudioController*)audioController {
    if ( !(self = [super initWithStyle:UITableViewStyleGrouped]) )
        return nil;
    self.audioController = audioController;
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

#pragma mark - Private Methods

- (void)setupSubviews {
    // 输出显示
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.inputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioDescription:_audioController.audioDescription];
    _inputOscilloscope.frame = CGRectMake(0, 0, headerView.bounds.size.width, 80);
    _inputOscilloscope.lineColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [headerView.layer addSublayer:_inputOscilloscope];
    [_audioController addInputReceiver:_inputOscilloscope];
    [_inputOscilloscope start];
    [self.view addSubview:headerView];

    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat originY = 160;
    CGFloat height = 40;
    // 低通过滤：开关
    UISwitch *lowPassSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, originY, 50, height)];
    lowPassSwitch.tag = 0;
    [lowPassSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:lowPassSwitch];
    originY += height;
    // 低通过滤：频率
    _lowPassCutoffFrequencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                              originY,
                                                                              screenWidth,
                                                                              height)];
    _lowPassCutoffFrequencyLabel.text = @"低通过率频率: 6900.0";
    [self.view addSubview:_lowPassCutoffFrequencyLabel];
    originY += height;
    _lowPassCutoffFrequencySlider = [[UISlider alloc] initWithFrame:CGRectMake(0,
                                                                                originY,
                                                                                screenWidth,
                                                                                height)];
    _lowPassCutoffFrequencySlider.minimumValue = 10;
    _lowPassCutoffFrequencySlider.maximumValue = 22050;
    _lowPassCutoffFrequencySlider.value = 6900;
    _lowPassCutoffFrequencySlider.tag = 1;
    [_lowPassCutoffFrequencySlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_lowPassCutoffFrequencySlider];
    originY += height;
    // 低通过滤：共鸣
    _lowPassResonanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        originY,
                                                                        screenWidth,
                                                                        height)];
    _lowPassResonanceLabel.text = @"低通过率共鸣: 0.0";
    [self.view addSubview:_lowPassResonanceLabel];
    originY += height;
    _lowPassResonanceSlider = [[UISlider alloc] initWithFrame:CGRectMake(0,
                                                                          originY,
                                                                          screenWidth,
                                                                          height)];
    _lowPassResonanceSlider.minimumValue = -20;
    _lowPassResonanceSlider.maximumValue = 40;
    _lowPassResonanceSlider.value = 0;
    _lowPassResonanceSlider.tag = 2;
    [_lowPassResonanceSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_lowPassResonanceSlider];
    originY += height;

    // 高通过滤：开关
    UISwitch *highPassSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, originY, 50, height)];
    highPassSwitch.tag = 3;
    [highPassSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:highPassSwitch];
    originY += height;
    // 高通过滤：频率
    _highPassCutoffFrequencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                              originY,
                                                                              screenWidth,
                                                                              height)];
    _highPassCutoffFrequencyLabel.text = @"高通过率频率: 6900.0";
    [self.view addSubview:_highPassCutoffFrequencyLabel];
    originY += height;
    _highPassCutoffFrequencySlider = [[UISlider alloc] initWithFrame:CGRectMake(0,
                                                                          originY,
                                                                          screenWidth,
                                                                          height)];
    _highPassCutoffFrequencySlider.tag = 4;
    _highPassCutoffFrequencySlider.minimumValue = 10;
    _highPassCutoffFrequencySlider.maximumValue = 22050;
    _highPassCutoffFrequencySlider.value = 6900;
    [_highPassCutoffFrequencySlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_highPassCutoffFrequencySlider];
    originY += height;
    // 高通过滤：共鸣
    _highPassResonanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                              originY,
                                                                              screenWidth,
                                                                              height)];
    _highPassResonanceLabel.text = @"高通过率共鸣: 0.0";
    [self.view addSubview:_highPassResonanceLabel];
    originY += height;
    _highPassResonanceSlider = [[UISlider alloc] initWithFrame:CGRectMake(0,
                                                                          originY,
                                                                          screenWidth,
                                                                          height)];
    _highPassResonanceSlider.tag = 5;
    _highPassResonanceSlider.minimumValue = -20;
    _highPassResonanceSlider.maximumValue = 40;
    _highPassResonanceSlider.value = 0;
    [_highPassResonanceSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_highPassResonanceSlider];
    originY += height;
}

#pragma mark - Action Methods

- (void)valueChanged:(UISlider *)slider {
    if (slider.tag == 0) {
        if ([(UISwitch *)slider isOn]) {
            self.lowPassFilter = [[AELowPassFilter alloc] init];
            self.lowPassFilter.cutoffFrequency = _lowPassCutoffFrequencySlider.value;
            self.lowPassFilter.resonance = _lowPassResonanceSlider.value;
            [_audioController addInputFilter:_lowPassFilter];
        } else {
            [_audioController removeInputFilter:_lowPassFilter];
            self.lowPassFilter = nil;
        }
    } else if (slider.tag == 1) {
        _lowPassCutoffFrequencyLabel.text = [NSString stringWithFormat:@"低通过率频率: %.1f", slider.value];
        self.lowPassFilter.cutoffFrequency = _lowPassCutoffFrequencySlider.value;
    } else if (slider.tag == 2) {
        _lowPassResonanceLabel.text = [NSString stringWithFormat:@"低通过率共鸣: %.1f", slider.value];
        self.lowPassFilter.resonance = _lowPassResonanceSlider.value;
    } else if (slider.tag == 3) {
        if ([(UISwitch *)slider isOn]) {
            self.highPassFilter = [[AEHighPassFilter alloc] init];
            self.highPassFilter.cutoffFrequency = _highPassCutoffFrequencySlider.value;
            self.highPassFilter.resonance = _highPassResonanceSlider.value;
            [_audioController addInputFilter:_highPassFilter];
        } else {
            [_audioController removeInputFilter:_highPassFilter];
            self.highPassFilter = nil;
        }
    } else if (slider.tag == 4) {
        _highPassCutoffFrequencyLabel.text = [NSString stringWithFormat:@"高通过率频率: %.1f", slider.value];
        self.highPassFilter.cutoffFrequency = _highPassCutoffFrequencySlider.value;
    } else if (slider.tag == 5) {
        _highPassResonanceLabel.text = [NSString stringWithFormat:@"高通过率共鸣: %.1f", slider.value];
        self.highPassFilter.resonance = _highPassResonanceSlider.value;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
