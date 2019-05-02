//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MicrosoftCognitiveServicesSpeech/SPXSpeechApi.h>

@interface ViewController () {
    NSString *speechKey;
    NSString *serviceRegion;
}

@property (strong, nonatomic) IBOutlet UIButton *recognizeFromFileButton;
@property (strong, nonatomic) IBOutlet UIButton *recognizeFromMicButton;
@property (strong, nonatomic) IBOutlet UIButton *recognizeWithPhraseHintButton;
@property (strong, nonatomic) IBOutlet UIButton *recognizeWithPushStreamButton;
@property (strong, nonatomic) IBOutlet UIButton *recognizeWithPullStreamButton;

@property (strong, nonatomic) IBOutlet UILabel *recognitionResultLabel;

- (IBAction)recognizeFromFileButtonTapped:(UIButton *)sender;
- (IBAction)recognizeFromMicButtonTapped:(UIButton *)sender;
- (IBAction)recognizeWithPhraseHintButtonTapped:(UIButton *)sender;
- (IBAction)recognizeWithPushStreamButtonTapped:(UIButton *)sender;
- (IBAction)recognizeWithPullStreamButtonTapped:(UIButton *)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    speechKey = @"YourSubscriptionKey";
    serviceRegion = @"YourServiceRegion";

    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.recognizeFromMicButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recognizeFromMicButton addTarget:self action:@selector(recognizeFromMicButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.recognizeFromMicButton setTitle:@"Start rec from mic" forState:UIControlStateNormal];
    [self.recognizeFromMicButton setFrame:CGRectMake(50.0, 100.0, 300.0, 50.0)];
    self.recognizeFromMicButton.accessibilityIdentifier = @"recognize_mic_button";
    [self.view addSubview:self.recognizeFromMicButton];

    self.recognizeFromFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recognizeFromFileButton addTarget:self action:@selector(recognizeFromFileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.recognizeFromFileButton setTitle:@"Start rec from file" forState:UIControlStateNormal];
    [self.recognizeFromFileButton setFrame:CGRectMake(50.0, 150.0, 300.0, 50.0)];
    self.recognizeFromFileButton.accessibilityIdentifier = @"recognize_file_button";
    [self.view addSubview:self.recognizeFromFileButton];

    self.recognizeWithPhraseHintButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recognizeWithPhraseHintButton addTarget:self action:@selector(recognizeWithPhraseHintButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.recognizeWithPhraseHintButton setTitle:@"Start rec from file with PhraseHint" forState:UIControlStateNormal];
    [self.recognizeWithPhraseHintButton setFrame:CGRectMake(50.0, 200.0, 300.0, 50.0)];
    self.recognizeWithPhraseHintButton.accessibilityIdentifier = @"recognize_phrase_hint_button";
    [self.view addSubview:self.recognizeWithPhraseHintButton];

    self.recognizeWithPushStreamButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recognizeWithPushStreamButton addTarget:self action:@selector(recognizeWithPushStreamButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.recognizeWithPushStreamButton setTitle:@"Start rec from file with push stream" forState:UIControlStateNormal];
    [self.recognizeWithPushStreamButton setFrame:CGRectMake(50.0, 250.0, 300.0, 50.0)];
    self.recognizeWithPushStreamButton.accessibilityIdentifier = @"recognize_push_stream_button";
    [self.view addSubview:self.recognizeWithPushStreamButton];

    self.recognizeWithPullStreamButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recognizeWithPullStreamButton addTarget:self action:@selector(recognizeWithPullStreamButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.recognizeWithPullStreamButton setTitle:@"Start rec from file with pull stream" forState:UIControlStateNormal];
    [self.recognizeWithPullStreamButton setFrame:CGRectMake(50.0, 300.0, 300.0, 50.0)];
    self.recognizeWithPullStreamButton.accessibilityIdentifier = @"recognize_pull_stream_button";
    [self.view addSubview:self.recognizeWithPullStreamButton];

    self.recognitionResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 350.0, 300.0, 400.0)];
    self.recognitionResultLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.recognitionResultLabel.numberOfLines = 0;
    self.recognitionResultLabel.accessibilityIdentifier = @"result_label";
    [self.recognitionResultLabel setText:@"Press a button!"];

    [self.view addSubview:self.recognitionResultLabel];
}

- (IBAction)recognizeFromFileButtonTapped:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self recognizeFromFile];
    });
}

- (IBAction)recognizeFromMicButtonTapped:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self recognizeFromMicrophone];
    });
}

- (IBAction)recognizeWithPhraseHintButtonTapped:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self recognizeWithPhraseHint];
    });
}

- (IBAction)recognizeWithPushStreamButtonTapped:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self recognizeWithPushStream];
    });
}

- (IBAction)recognizeWithPullStreamButtonTapped:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self recognizeWithPullStream];
    });
}

/*
 * Performs speech recognition from a RIFF wav file.
 */
- (void)recognizeFromFile {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *weatherFile = [mainBundle pathForResource: @"whatstheweatherlike" ofType:@"wav"];
    NSLog(@"weatherFile path: %@", weatherFile);
    if (!weatherFile) {
        NSLog(@"Cannot find audio file!");
        [self updateRecognitionErrorText:(@"Cannot find audio file")];
        return;
    }

    SPXAudioConfiguration* weatherAudioSource = [[SPXAudioConfiguration alloc] initWithWavFileInput:weatherFile];
    if (!weatherAudioSource) {
        NSLog(@"Loading audio file failed!");
        [self updateRecognitionErrorText:(@"Audio Error")];
        return;
    }

    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        [self updateRecognitionErrorText:(@"Speech Config Error")];
        return;
    }

    [self updateRecognitionStatusText:(@"Recognizing...")];

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] initWithSpeechConfiguration:speechConfig audioConfiguration:weatherAudioSource];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }

    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
    if (SPXResultReason_Canceled == speechResult.reason) {
        SPXCancellationDetails *details = [[SPXCancellationDetails alloc] initFromCanceledRecognitionResult:speechResult];
        NSLog(@"Speech recognition was canceled: %@. Did you pass the correct key/region combination?", details.errorDetails);
        [self updateRecognitionErrorText:([NSString stringWithFormat:@"Canceled: %@", details.errorDetails ])];
    } else if (SPXResultReason_RecognizedSpeech == speechResult.reason) {
        NSLog(@"Speech recognition result received: %@", speechResult.text);
        [self updateRecognitionResultText:(speechResult.text)];
    } else {
        NSLog(@"There was an error.");
        [self updateRecognitionErrorText:(@"Speech Recognition Error")];
    }
}

/*
 * Performs speech recognition on audio data from the default microphone.
 */
- (void)recognizeFromMicrophone {
    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        [self updateRecognitionErrorText:(@"Speech Config Error")];
        return;
    }

    [self updateRecognitionStatusText:(@"Recognizing...")];

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] init:speechConfig];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }

    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
    if (SPXResultReason_Canceled == speechResult.reason) {
        SPXCancellationDetails *details = [[SPXCancellationDetails alloc] initFromCanceledRecognitionResult:speechResult];
        NSLog(@"Speech recognition was canceled: %@. Did you pass the correct key/region combination?", details.errorDetails);
        [self updateRecognitionErrorText:([NSString stringWithFormat:@"Canceled: %@", details.errorDetails ])];
    } else if (SPXResultReason_RecognizedSpeech == speechResult.reason) {
        NSLog(@"Speech recognition result received: %@", speechResult.text);
        [self updateRecognitionResultText:(speechResult.text)];
    } else {
        NSLog(@"There was an error.");
        [self updateRecognitionErrorText:(@"Speech Recognition Error")];
    }
}

/*
 * Performs speech recognition on audio data from a wav file, with recognition hints in the form of a text phrase.
 */
- (void)recognizeWithPhraseHint {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *beachFile = [mainBundle pathForResource: @"wreck-a-nice-beach" ofType:@"wav"];
    if (!beachFile) {
        NSLog(@"Cannot find audio file!");
        [self updateRecognitionErrorText:(@"Cannot find audio file")];
        return;
    }

    SPXAudioConfiguration* weatherAudioSource = [[SPXAudioConfiguration alloc] initWithWavFileInput:beachFile];
    if (!weatherAudioSource) {
        NSLog(@"Loading audio file failed!");
        [self updateRecognitionErrorText:(@"Audio Error")];
        return;
    }

    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        [self updateRecognitionErrorText:(@"Speech Config Error")];
        return;
    }

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] initWithSpeechConfiguration:speechConfig audioConfiguration:weatherAudioSource];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }

    // add a phrase hint to the recognizer's grammar
    SPXPhraseListGrammar * phraseListGrammar = [[SPXPhraseListGrammar alloc] initWithRecognizer:speechRecognizer];
    [phraseListGrammar addPhrase:@"Wreck a nice beach"];

    [self updateRecognitionStatusText:(@"Recognizing...")];

    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
    if (SPXResultReason_Canceled == speechResult.reason) {
        SPXCancellationDetails *details = [[SPXCancellationDetails alloc] initFromCanceledRecognitionResult:speechResult];
        NSLog(@"Speech recognition was canceled: %@. Did you pass the correct key/region combination?", details.errorDetails);
        [self updateRecognitionErrorText:([NSString stringWithFormat:@"Canceled: %@", details.errorDetails ])];
    } else if (SPXResultReason_RecognizedSpeech == speechResult.reason) {
        NSLog(@"Speech recognition result received: %@", speechResult.text);
        [self updateRecognitionResultText:(speechResult.text)];
    } else {
        NSLog(@"There was an error.");
        [self updateRecognitionErrorText:(@"Speech Recognition Error")];
    }
}

/*
 * Performs continuous speech recognition using a push stream for audio data.
 */
- (void)recognizeWithPushStream {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *weatherFile = [mainBundle pathForResource: @"whatstheweatherlike" ofType:@"wav"];
    NSLog(@"weatherFile path: %@", weatherFile);
    if (!weatherFile) {
        NSLog(@"Cannot find audio file!");
        [self updateRecognitionErrorText:(@"Cannot find audio file")];
        return;
    }

    NSURL *targetUrl = [NSURL URLWithString:weatherFile];
    NSError *error = nil;

    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:targetUrl commonFormat:AVAudioPCMFormatInt16 interleaved:NO error:&error];
    if (error)
    {
        NSLog(@"Error while opening file: %@", error);
        [self updateRecognitionErrorText:(@"Error opening audio file")];
        return;
    }

    // check the format of the file
    NSAssert(1 == audioFile.fileFormat.channelCount, @"Bad channel count");
    NSAssert(16000 == audioFile.fileFormat.sampleRate, @"Unexpected sample rate");

    // set up the stream
    SPXAudioStreamFormat *audioFormat = [[SPXAudioStreamFormat alloc] initUsingPCMWithSampleRate:audioFile.fileFormat.sampleRate bitsPerSample:16 channels:1];
    SPXPushAudioInputStream* stream;
    stream = [[SPXPushAudioInputStream alloc] initWithAudioFormat:audioFormat];

    SPXAudioConfiguration* audioConfig = [[SPXAudioConfiguration alloc] initWithStreamInput:stream];
    if (!audioConfig) {
        NSLog(@"Error creating stream!");
        [self updateRecognitionErrorText:(@"Error creating stream!")];
        return;
    }

    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        [self updateRecognitionErrorText:(@"Speech Config Error")];
        return;
    }

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] initWithSpeechConfiguration:speechConfig audioConfiguration:audioConfig];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }

    // connect callbacks
    [speechRecognizer addRecognizingEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
        NSLog(@"Received intermediate result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
        [self updateRecognitionStatusText:eventArgs.result.text];
    }];


    [speechRecognizer addRecognizedEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
        NSLog(@"Received final result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
        [self updateRecognitionResultText:eventArgs.result.text];
    }];

    // start recognizing
    [self updateRecognitionStatusText:(@"Recognizing from push stream...")];
    [speechRecognizer startContinuousRecognition];

    // set up the buffer fo push data into the stream
    const AVAudioFrameCount nBytesToRead = 5000;
    const NSInteger bytesPerFrame = audioFile.fileFormat.streamDescription->mBytesPerFrame;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFile.fileFormat frameCapacity:nBytesToRead / bytesPerFrame];

    NSAssert(1 == buffer.stride, @"only one channel allowed");
    NSAssert(nil != buffer.int16ChannelData, @"assure correct format");

    // push data to stream
    while (1)
    {
        NSError *bufferError = nil;
        bool success = [audioFile readIntoBuffer:buffer error:&bufferError];
        if (!success) {
            NSLog(@"Read error on stream: %@", bufferError);
            [stream close];
            break;
        }
        else
        {
            NSInteger nBytesRead = [buffer frameLength] * bytesPerFrame;
            if (0 == nBytesRead)
            {
                [stream close];
                break;
            }

            NSLog(@"Read %d bytes from file", (int)nBytesRead);

            NSData *data = [NSData dataWithBytesNoCopy:buffer.int16ChannelData[0] length:nBytesRead freeWhenDone:NO];
            NSLog(@"%d bytes data returned", (int)[data length]);

            [stream write:data];
            NSLog(@"Wrote %d bytes to stream", (int)[data length]);
        }

        [NSThread sleepForTimeInterval:0.05f];
    }

    [speechRecognizer stopContinuousRecognition];
}

/*
 * Performs continuous speech recognition using a pull stream for audio data.
 */
- (void)recognizeWithPullStream {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *weatherFile = [mainBundle pathForResource: @"whatstheweatherlike" ofType:@"wav"];
    NSLog(@"weatherFile path: %@", weatherFile);
    if (!weatherFile) {
        NSLog(@"Cannot find audio file!");
        [self updateRecognitionErrorText:(@"Cannot find audio file")];
        return;
    }

    NSURL *targetUrl = [NSURL URLWithString:weatherFile];
    NSError *error = nil;

    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:targetUrl commonFormat:AVAudioPCMFormatInt16 interleaved:NO error:&error];
    if (error)
    {
        NSLog(@"Error while opening file: %@", error);
        [self updateRecognitionErrorText:(@"Error opening audio file")];
        return;
    }

    const NSInteger bytesPerFrame = audioFile.fileFormat.streamDescription->mBytesPerFrame;

    // check the format of the file
    NSAssert(1 == audioFile.fileFormat.channelCount, @"Bad channel count");
    NSAssert(16000 == audioFile.fileFormat.sampleRate, @"Unexpected sample rate");

    // set up the stream with the pull callback
    SPXPullAudioInputStream* stream = [[SPXPullAudioInputStream alloc]
                    initWithReadHandler:
                    ^NSInteger(NSMutableData *data, NSUInteger size) {
                        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFile.fileFormat frameCapacity:(AVAudioFrameCount) size / bytesPerFrame];
                        NSError *bufferError = nil;
                        bool success = [audioFile readIntoBuffer:buffer error:&bufferError];

                        NSInteger nBytes = 0;
                        if (!success) {
                            // returns 0 to close the stream on read error.
                            NSLog(@"Read error on stream: %@", bufferError);
                        }
                        else
                        {
                            // number of bytes in the buffer
                            nBytes = [buffer frameLength] * bytesPerFrame;

                            NSRange range;
                            range.location = 0;
                            range.length = nBytes;

                            NSAssert(1 == buffer.stride, @"only one channel allowed");
                            NSAssert(nil != buffer.int16ChannelData, @"assure correct format");

                            [data replaceBytesInRange:range withBytes:buffer.int16ChannelData[0]];
                            NSLog(@"%d bytes data returned", (int)[data length]);
                        }
                        // returns the number of bytes that have been read, 0 closes the stream.
                        return nBytes;
                    }
                    closeHandler:
                    ^(void) {
                    }];

    SPXAudioConfiguration* audioConfig = [[SPXAudioConfiguration alloc] initWithStreamInput:stream];
    if (!audioConfig) {
        NSLog(@"Error creating stream!");
        [self updateRecognitionErrorText:(@"Error creating stream!")];
        return;
    }

    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        [self updateRecognitionErrorText:(@"Speech Config Error")];
        return;
    }

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] initWithSpeechConfiguration:speechConfig audioConfiguration:audioConfig];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }

    // connect callbacks
    [speechRecognizer addRecognizingEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
        NSLog(@"Received intermediate result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
        [self updateRecognitionStatusText:eventArgs.result.text];
    }];

    [speechRecognizer addRecognizedEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
        NSLog(@"Received final result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
        [self updateRecognitionResultText:eventArgs.result.text];
    }];

    // session stopped callback to recognize stream has ended
    __block bool end = false;
    [speechRecognizer addSessionStoppedEventHandler: ^ (SPXRecognizer *recognizer, SPXSessionEventArgs *eventArgs) {
        NSLog(@"Received session stopped event. SessionId: %@", eventArgs.sessionId);
        end = true;
    }];

    // start recognizing
    [self updateRecognitionStatusText:(@"Recognizing from pull stream...")];
    [speechRecognizer startContinuousRecognition];

    // wait until a session stopped event has been received
    while (end == false)
        [NSThread sleepForTimeInterval:1.0f];
    [speechRecognizer stopContinuousRecognition];
}

- (void)updateRecognitionResultText:(NSString *) resultText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recognitionResultLabel.textColor = UIColor.blackColor;
        self.recognitionResultLabel.text = resultText;
    });
}

- (void)updateRecognitionErrorText:(NSString *) errorText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recognitionResultLabel.textColor = UIColor.redColor;
        self.recognitionResultLabel.text = errorText;
    });
}

- (void)updateRecognitionStatusText:(NSString *) statusText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recognitionResultLabel.textColor = UIColor.grayColor;
        self.recognitionResultLabel.text = statusText;
    });
}

@end

