#import "CDVOpenEars.h"

@implementation CDVOpenEars

-(void)initialize:(CDVInvokedUrlCommand*)command{
    NSLog(@"OpenEars initialize called");
    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    self.slt = [[Slt alloc] init];
    
    [self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
}

-(void)startListening:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called start listening");

    NSArray *firstLanguageArray = @[@"BACKWARD",
                                    @"CHANGE",
                                    @"FORWARD",
                                    @"GO",
                                    @"LEFT",
                                    @"MODEL",
                                    @"RIGHT",
                                    @"TURN"];
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init]; 

    NSError *error = [languageModelGenerator generateLanguageModelFromArray:firstLanguageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);    
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
}

-(void)stopListening:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called stop listening");
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        NSError *error = nil;
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
}

- (void)suspendRecognition:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called suspend recognition");
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
}

- (void)resumeRecognition:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called resume recognition");
    [[OEPocketsphinxController sharedInstance] resumeRecognition];
}

- (void)changeLanguageModel:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called change language model to file");

    // NSString *languageName = [command.arguments objectAtIndex:0];
    // NSString *languageCSV = [command.arguments objectAtIndex:1];
    // NSArray *languageArray = [languageCSV componentsSeparatedByString:@","];


    NSArray *languageArray = @[@"Test"];
    error = [languageModelGenerator generateLanguageModelFromArray:languageArray withFilesNamed:@"TestLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; 

    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);    
    }   else {
        self.pathToSecondDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"TestLanguageModel"]; // We'll set our new .languagemodel file to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        self.pathToSecondDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"TestLanguageModel"];; // We'll set our new dictionary to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:self.pathToSecondDynamicallyGeneratedLanguageModel withDictionary:self.pathToSecondDynamicallyGeneratedDictionary]; 
    }
}

- (void)say:(CDVInvokedUrlCommand*)command{
    NSLog(@"Called say");
    [self.fliteController say:[NSString stringWithFormat:@"Oh hello there"] withVoice:self.slt];
}




/*
 *  Events
 */
- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Pocketsphinx audio session interruption");
    [self.commandDelegate evalJs:@"OpenEars.events.audioSessionInterruptionDidBegin()"];
}

- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Pocketsphinx audio session interruption ended");
    [self.commandDelegate evalJs:@"OpenEars.events.audioSessionInterruptionDidEnd()"];
}

- (void) audioInputDidBecomeUnavailable {
    NSLog(@"Pocketsphinx audio input became unavailable");
    [self.commandDelegate evalJs:@"OpenEars.events.audioInputDidBecomeUnavailable()"];
}

- (void) audioInputDidBecomeAvailable {
    NSLog(@"Pocketsphinx audio input became available");
    [self.commandDelegate evalJs:@"OpenEars.events.audioInputDidBecomeAvailable()"];
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
    NSLog(@"Pocketsphinx audio route changed and is now %@", newRoute);
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.audioRouteDidChangeToRoute(\"%@\");",newRoute];
    [self.commandDelegate evalJs:jsString];
}

- (void) pocketsphinxRecognitionLoopDidStart {
    NSLog(@"Pocketsphinx started recognition loop");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxRecognitionLoopDidStart()"];
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx started listening");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidStartListening()"];
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx speech detected");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidDetectSpeech()"];
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx detected finished speech");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidDetectFinishedSpeech()"];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"Pocketsphinx received a hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.pocketsphinxDidReceiveHypothesis(\"%@\",%@,%@);",hypothesis,recognitionScore,utteranceID];
    [self.commandDelegate evalJs:jsString];
}

- (void) pocketsphinxDidReceiveNBestHypothesisArray {
    NSLog(@"Pocketsphinx received best hypothesis array");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidReceiveNBestHypothesisArray()"];
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx stopped listening");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidStopListening()"];
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx suspended recognition");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidSuspendRecognition()"];
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx resumed recognition");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxDidResumeRecognition()"];
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx changed language model to file: %@ and dictionary %@", newLanguageModelPathAsString, newDictionaryPathAsString);
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.pocketsphinxDidChangeLanguageModelToFile(\"%@\",\"%@\");",newLanguageModelPathAsString,newDictionaryPathAsString];
    [self.commandDelegate evalJs:jsString];
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Pocketsphinx continuous setup failed because %@", reasonForFailure);
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.pocketSphinxContinuousSetupDidFailWithReason(\"%@\");",reasonForFailure];
    [self.commandDelegate evalJs:jsString];
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Pocketsphinx continuous teardown failed because %@", reasonForFailure);
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.pocketSphinxContinuousTeardownDidFailWithReason(\"%@\");",reasonForFailure];
    [self.commandDelegate evalJs:jsString];
}

- (void) pocketsphinxTestRecognitionCompleted {
    NSLog(@"Pocketsphinx test recognition completed");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxTestRecognitionCompleted()"];
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"Pocketsphinx doesnt have mic permissions");
    [self.commandDelegate evalJs:@"OpenEars.events.pocketsphinxFailedNoMicPermissions()"];
}

- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result) {
        NSLog(@"Pocketsphinx completed mic check 1, 2, mic check 1, 2 with a result of true");
    } else {
        NSLog(@"Pocketsphinx completed mic check 1, 2, mic check 1, 2 with a result of false");
    }
    NSString* jsString = [[NSString alloc] initWithFormat:@"OpenEars.events.micPermissionCheckCompleted(%@);",result?@"True":@"False"];
    [self.commandDelegate evalJs:jsString];
}

- (void) fliteDidStartSpeaking {
    NSLog(@"Pocketsphinx speaking started");
    [self.commandDelegate evalJs:@"OpenEars.events.fliteDidStartSpeaking()"];
}

- (void) fliteDidFinishSpeaking {
    NSLog(@"Pocketsphinx speaking finished");
    [self.commandDelegate evalJs:@"OpenEars.events.fliteDidFinishSpeaking()"];
}



/*
 *  Cleanup
 */
-(void) dealloc {
    self.openEarsEventsObserver.delegate = nil;
}

@end