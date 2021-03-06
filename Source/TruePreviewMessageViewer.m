/*
 * Copyright (c) 2009-2011, Jim Riggs, Christian Serving, L.L.C.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of Christian Serving, L.L.C. nor the names of
 *       its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "TruePreviewMessageViewer.h"

@implementation TruePreviewMessageViewer

#pragma mark Class methods

+ (NSMutableDictionary*)truePreviewTimers {
  TRUEPREVIEW_LOG();
  
  static NSMutableDictionary* sTimers = nil;
  
  if (sTimers == nil) {
    sTimers = [[NSMutableDictionary alloc] initWithCapacity:1];
  }
  
  return sTimers;
}

#pragma mark Swizzled instance methods

- (void)truePreviewDealloc {
  TRUEPREVIEW_LOG();
  
  [self truePreviewReset];
  [[[self class] truePreviewTimers]
    removeObjectForKey:[NSNumber numberWithUnsignedLongLong:(unsigned long long)self]
  ];
  [self truePreviewDealloc];
}

- (void)truePreviewForwardAsAttachment:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  id theMessage = [self currentDisplayedMessage];
  
  if ([theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    NSDictionary* theSettings = [theMessage truePreviewSettings];
    
    if ([[theSettings objectForKey:@"forward"] boolValue]) {
      [self truePreviewReset];
      [self truePreviewMarkMessagesAsViewed:[NSArray arrayWithObject:theMessage]];
    }
  }
  
  [self truePreviewForwardAsAttachment:inSender];
}

- (void)truePreviewForwardMessage:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  id theMessage = [self currentDisplayedMessage];
  
  if ([theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    NSDictionary* theSettings = [theMessage truePreviewSettings];
    
    if ([[theSettings objectForKey:@"forward"] boolValue]) {
      [self truePreviewReset];
      [self truePreviewMarkMessagesAsViewed:[NSArray arrayWithObject:theMessage]];
    }
  }
  
  [self truePreviewForwardMessage:inSender];
}

- (void)truePreviewMarkAsRead:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  [self truePreviewReset];
  [self truePreviewMarkAsRead:inSender];
}

- (void)truePreviewMarkAsUnread:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  [self truePreviewReset];
  [self truePreviewMarkAsUnread:inSender];
}

- (void)truePreviewMarkMessageAsViewed:(id)inMessage {
  TRUEPREVIEW_LOG(@"%@", inMessage);
  
  [self truePreviewCreateTimer:inMessage];
}

- (void)truePreviewMarkMessagesAsViewed:(NSArray*)inMessages  {
  TRUEPREVIEW_LOG(@"%@", inMessages);

  [self truePreviewCreateTimer:inMessages];
}

- (void)truePreviewMessageWasDisplayedInTextView:(NSNotification*)inNotification {
  TRUEPREVIEW_LOG(@"%@", inNotification);
  
  [self truePreviewMessageWasDisplayedInTextView:inNotification];  
  [self truePreviewReset];
/* TODO: IN PROGRESS
  // we receive notifications from all MessageContentControllers
  if ([inNotification object] != object_getIvar(self, class_getInstanceVariable([self class], "_contentController"))) {
    return;
  }
  
  id theMessage = [[inNotification userInfo] objectForKey:@"MessageKey"];
  
  if ([theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    NSDictionary* theSettings = [theMessage truePreviewSettings];
    
    if (
      ([[theSettings objectForKey:@"delay"] floatValue] == TRUEPREVIEW_DELAY_IMMEDIATE)
      || (
        [[theSettings objectForKey:@"window"] boolValue]
        && [self isKindOfClass:NSClassFromString(@"SingleMessageViewer")]
      )        
    ) {
      [self truePreviewReset];
      [self truePreviewMarkMessagesAsViewed:[NSArray arrayWithObject:theMessage]];
      
      return;
    }

    float theDelay = [[theSettings objectForKey:@"delay"] floatValue];
    
    if (theDelay > TRUEPREVIEW_DELAY_IMMEDIATE) {
      [self truePreviewReset];
      [self
        truePreviewSetTimer:[NSTimer
          scheduledTimerWithTimeInterval:theDelay
          target:self
          selector:@selector(truePreviewTimerFired:)
          userInfo:nil
          repeats:NO
        ]
      ];
    }
    
    if (
      ![self isKindOfClass:NSClassFromString(@"SingleMessageViewer")]
      && [[theSettings objectForKey:@"scroll"] boolValue]
    ) {
      // listen for selection change (mouse down) on message content view
      [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(truePreviewMessageClickedOrScrolled:)
        name:@"WebViewDidChangeSelectionNotification"
        object:[[object_getIvar(self, class_getInstanceVariable([self class], "_contentController")) currentDisplay] contentView]
      ];
      
      // listen for bounds change notification on the message's clip view
      [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(truePreviewMessageClickedOrScrolled:)
        name:NSViewBoundsDidChangeNotification
        object:[[[[object_getIvar(self, class_getInstanceVariable([self class], "_contentController")) currentDisplay] contentView] enclosingScrollView] contentView]
      ];
    }    
  }
*/
}

- (void)truePreviewReplyAllMessage:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  id theMessage = [self currentDisplayedMessage];
  
  if ([theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    NSDictionary* theSettings = [theMessage truePreviewSettings];
    
    if ([[theSettings objectForKey:@"reply"] boolValue]) {
      [self truePreviewReset];
      [self truePreviewMarkMessagesAsViewed:[NSArray arrayWithObject:theMessage]];
    }
  }
  
  [self truePreviewReplyAllMessage:inSender];
}

- (void)truePreviewReplyMessage:(id)inSender {
  TRUEPREVIEW_LOG(@"%@", inSender);
  
  id theMessage = [self currentDisplayedMessage];
  
  if ([theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    NSDictionary* theSettings = [theMessage truePreviewSettings];

    if ([[theSettings objectForKey:@"reply"] boolValue]) {
      [self truePreviewReset];
      [self truePreviewMarkMessagesAsViewed:[NSArray arrayWithObject:theMessage]];
    }
  }
  
  [self truePreviewReplyMessage:inSender];
}

- (void)truePreviewSelectedMessagesDidChangeInMessageList {
  TRUEPREVIEW_LOG();
  
  [self truePreviewReset];
  [self truePreviewSelectedMessagesDidChangeInMessageList];
}

#pragma mark Accessors

- (NSTimer*)truePreviewTimer {
  TRUEPREVIEW_LOG();
  
  return [[[self class] truePreviewTimers]
    objectForKey:[NSNumber numberWithUnsignedLongLong:(unsigned long long)self]
  ];
}

- (void)truePreviewSetTimer:(NSTimer*)inTimer {
  TRUEPREVIEW_LOG(@"%@ (userInfo: %@)", inTimer, [inTimer userInfo]);
  
  [[[self class] truePreviewTimers]
    setObject:inTimer
    forKey:[NSNumber numberWithUnsignedLongLong:(unsigned long long)self]
  ];
}

#pragma mark Instance methods

- (void)truePreviewCreateTimer:(id)inMessages {
  TRUEPREVIEW_LOG(@"%@", inMessages);
  
  if (![inMessages isKindOfClass:[NSArray class]]) {
    inMessages = [NSArray arrayWithObject:inMessages];
  }
  else {
    inMessages = [[inMessages copy] autorelease];
  }
  
  id theMessage = [inMessages objectAtIndex:0];

  if (
    ![theMessage isKindOfClass:NSClassFromString(@"LibraryMessage")]
    || ![[self currentDisplayedMessage] isKindOfClass:NSClassFromString(@"LibraryMessage")]
  ) {
    return;
  }

  NSDictionary* theSettings = [theMessage truePreviewSettings];
  
  if (
    ([[theSettings objectForKey:@"delay"] floatValue] == TRUEPREVIEW_DELAY_IMMEDIATE)
    || (
      [[theSettings objectForKey:@"window"] boolValue]
      && [self isKindOfClass:NSClassFromString(@"SingleMessageViewer")]
    )        
  ) {
    [self truePreviewReset];
    [self truePreviewMarkMessagesAsViewed:inMessages];
    
    return;
  }

  float theDelay = [[theSettings objectForKey:@"delay"] floatValue];
  
  if (theDelay > TRUEPREVIEW_DELAY_IMMEDIATE) {
    [self truePreviewReset];
    [self
      truePreviewSetTimer:[NSTimer
        scheduledTimerWithTimeInterval:theDelay
        target:self
        selector:@selector(truePreviewTimerFired:)
        userInfo:inMessages
        repeats:NO
      ]
    ];
  }
}

- (void)truePreviewReset {
  TRUEPREVIEW_LOG();
  
  NSTimer* theTimer = [self truePreviewTimer];

  if ((theTimer != nil) && [theTimer isValid]) {
    [theTimer invalidate];
  }
  
  // stop observing when changed
  [[NSNotificationCenter defaultCenter]
    removeObserver:self
    name:@"WebViewDidChangeSelectionNotification"
    object:[[object_getIvar(self, class_getInstanceVariable([self class], "_contentController")) currentDisplay] contentView]
  ];
  [[NSNotificationCenter defaultCenter]
    removeObserver:self
    name:NSViewBoundsDidChangeNotification
    object:[[[[object_getIvar(self, class_getInstanceVariable([self class], "_contentController")) currentDisplay] contentView] enclosingScrollView] contentView]
  ];
}

- (void)truePreviewTimerFired:(NSTimer*)inTimer {
  TRUEPREVIEW_LOG(@"%@ (userInfo: %@)", inTimer, [inTimer userInfo]);
  
  id theMessages = [inTimer userInfo];
  
  [self truePreviewReset];
  [self truePreviewMarkMessagesAsViewed:theMessages];
}

- (void)truePreviewMessageClickedOrScrolled:(NSNotification*)inNotification {
  TRUEPREVIEW_LOG(@"%@", inNotification);
  
  // ignore the first time we get the notification; it may be an initial scroll
  // to the origin after changing messages
  static BOOL sIsFirstTime = YES;
  
  if ([NSViewBoundsDidChangeNotification isEqualToString:[inNotification name]] && sIsFirstTime) {
    sIsFirstTime = NO;
    
    return;
  }
  
  sIsFirstTime = YES;
  
  [self truePreviewReset];
  
  if ([[self currentDisplayedMessage] isKindOfClass:NSClassFromString(@"LibraryMessage")]) {
    [[self currentDisplayedMessage] truePreviewMarkAsViewed];
  }
}

@end
