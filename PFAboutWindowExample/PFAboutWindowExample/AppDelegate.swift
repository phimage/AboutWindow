//
//  AppDelegate.m
//  PFAboutWindowExample
//
//  Created by Perceval FARAMAZ on 09/04/15.
//  Copyright (c) 2015 faramaz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSColor* bgColor = [NSColor colorWithWhite:0.2 alpha:1];
    //Sets About window color theme to dark
	self.aboutWindowController = [[PFAboutWindowController alloc] initWithBackgroundColor:bgColor titleColor:[NSColor whiteColor] textColor:[NSColor lightGrayColor]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction)showAboutWindow:(id)sender {
	[self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"http://app.faramaz.com"]];
	[self.aboutWindowController setAppName:@"PFAbout"];
	[self.aboutWindowController setAppCopyright:[[NSAttributedString alloc] initWithString:@"Copyright (c) 2015 Perceval F"
																				attributes:@{
														   NSForegroundColorAttributeName : [NSColor tertiaryLabelColor],
																	 NSFontAttributeName  : [NSFont fontWithName:@"HelveticaNeue" size:11]}]];
	[self.aboutWindowController setWindowShouldHaveShadow:YES];
    //Example of giving your own string, instead of using the content of the default Credits.rtf file
    [self.aboutWindowController setAppCredits:[NSAttributedString.alloc initWithString:@"Credits where credit's due"]];
	[self.aboutWindowController showWindow:nil];
}

@end
