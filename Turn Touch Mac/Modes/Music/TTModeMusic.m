//
//  TTModeMusic.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMusic.h"
#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "Music.h"

@interface TTModeMusic ()

@property (nonatomic, readonly) BOOL isITunes;
@property (nonatomic, strong, readonly) iTunesApplication *musicApp;
@property (nonatomic, readonly) BOOL isPlaying;

@end

@implementation TTModeMusic

const NSInteger ITUNES_VOLUME_PCT_CHANGE = 6;
NSString *const kMusicVolumeJump = @"musicVolumeJump";
NSString *const kMusicPlaylistSingle = @"musicPlaylistSingle";
NSString *const kMusicPlaylistShuffleSingle = @"musicPlaylistShuffleSingle";
NSString *const kMusicPlaylistDouble = @"musicPlaylistDouble";
NSString *const kMusicPlaylistShuffleDouble = @"musicPlaylistShuffleDouble";

+ (BOOL)isITunes {
    if (@available(macOS 10.15, *)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isITunes {
    return [self.class isITunes];
}

+ (iTunesApplication *)musicApp {
    if ([self isITunes]) {
        return [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    } else {
        return [SBApplication applicationWithBundleIdentifier:@"com.apple.Music"];
    }
}

- (iTunesApplication *)musicApp {
    return [self.class musicApp];
}

- (BOOL)isPlaying {
    iTunesApplication *music = self.musicApp;
    return music.playerState == iTunesEPlSPlaying;
    
    return NO;
}

#pragma mark - Mode

+ (NSString *)title {
    return @"Music";
}

+ (NSString *)description {
    if ([self isITunes]) {
        return @"Control iTunes";
    } else {
        return @"Control Music";
    }
}

+ (NSString *)imageName {
    return @"mode_music.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeMusicVolumeUp",
             @"TTModeMusicVolumeDown",
             @"TTModeMusicPause",
             @"TTModeMusicPlay",
             @"TTModeMusicPlayPause",
             @"TTModeMusicNextTrack",
             @"TTModeMusicPreviousTrack",
             @"TTModeMusicPlaylist",
             @"TTModeMusicSleep",
             @"TTModeMusicVolumeJump"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeMusicVolumeUp {
    return self.isITunes ? @"iTunes Volume up" : @"Music volume up";
}
- (NSString *)titleTTModeMusicVolumeDown {
    return self.isITunes ? @"iTunes Volume down" : @"Music volume down";
}
- (NSString *)titleTTModeMusicPause {
    return @"Pause";
}
- (NSString *)titleTTModeMusicPlay {
    return @"Play";
}
- (NSString *)titleTTModeMusicPlayPause {
    return @"Play/pause";
}
- (NSString *)doubleTitleTTModeMusicPause {
    return @"Previous track";
}
- (NSString *)actionTitleTTModeMusicPause {
    return @"Pause";
}
- (NSString *)actionTitleTTModeMusicPlay {
    return @"Play";
}
- (NSString *)actionTitleTTModeMusicPlayPause {
    return self.isPlaying ? @"Play" : @"Pause";
}
- (NSString *)titleTTModeMusicNextTrack {
    return @"Next track";
}
- (NSString *)doubleTitleTTModeMusicNextTrack {
    return @"Next album";
}
- (NSString *)titleTTModeMusicPreviousTrack {
    return @"Previous track";
}
- (NSString *)titleTTModeMusicPlaylist {
    return @"Playlist";
}
- (NSString *)actionTitleTTModeMusicPlaylist {
    iTunesApplication *music = self.musicApp;
    NSString *selectedPlaylist = [self.action optionValue:kMusicPlaylistSingle];
    
    if (![music respondsToSelector:@selector(sources)]) {
        return @"Playlist";
    }
    
    for (MusicSource *source in [music sources]) {
        if ([source kind] == iTunesESrcLibrary) {
            for (iTunesPlaylist *playlist in [source userPlaylists]) {
                if ([playlist.persistentID isEqualToString:selectedPlaylist] || !selectedPlaylist) {
                    return playlist.name;
                }
            }
        }
    }
    
    return @"Playlist";
}

- (NSString *)doubleActionTitleTTModeMusicPlaylist {
    iTunesApplication *music = self.musicApp;
    NSString *selectedPlaylist = [self.action optionValue:kMusicPlaylistDouble];
    
    if (![music respondsToSelector:@selector(sources)]) {
        return @"Playlist";
    }
    
    for (MusicSource *source in [music sources]) {
        if ([source kind] == iTunesESrcLibrary) {
            for (iTunesPlaylist *playlist in [source userPlaylists]) {
                if ([playlist.persistentID isEqualToString:selectedPlaylist] || !selectedPlaylist) {
                    return playlist.name;
                }
            }
        }
    }
    
    return @"Playlist";
}

- (NSString *)titleTTModeMusicVolumeJump {
    return @"Volume jump";
}
- (NSString *)titleTTModeMusicSleep {
    return @"Fade out";
}

#pragma mark - Action Images

- (NSString *)imageTTModeMusicVolumeUp {
    return @"music_volume_up.png";
}
- (NSString *)imageTTModeMusicVolumeDown {
    return @"music_volume_down.png";
}
- (NSString *)imageTTModeMusicPause {
    return @"music_pause.png";
}
- (NSString *)imageTTModeMusicPlay {
    return @"music_play.png";
}
- (NSString *)imageTTModeMusicPlayPause {
    return @"music_play_pause.png";
}
- (NSString *)imageTTModeMusicNextTrack {
    return @"music_ff.png";
}
- (NSString *)imageTTModeMusicPreviousTrack {
    return @"music_rewind.png";
}
- (NSString *)imageTTModeMusicPlaylist {
    return @"menu.png";
}
- (NSString *)imageTTModeMusicVolumeJump {
    return @"music_volume.png";
}
- (NSString *)imageTTModeMusicSleep {
    return @"hue_sleep.png";
}
- (NSString *)imageActionHudTTModeMusicPlayPause {
    return self.isPlaying ? @"music_play.png" : @"music_pause.png";
}

#pragma mark - Progress

- (NSInteger)progressVolume {
    iTunesApplication *music = self.musicApp;
    return music.soundVolume;
}

- (NSInteger)progressTTModeMusicVolumeUp {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeDown {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeMute {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeJump {
    return [self progressVolume];
}

#pragma mark - Layout

- (ActionLayout)layoutTTModeMusicPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeMusicPlay {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeMusicPlayPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeMusicVolumeUp {
    return ACTION_LAYOUT_PROGRESSBAR;
}
- (ActionLayout)layoutTTModeMusicVolumeDown {
    return ACTION_LAYOUT_PROGRESSBAR;
}

- (NSView *)viewForLayoutTTModeMusicPause:(NSRect)rect {
    iTunesApplication * iTunes = self.musicApp;
    iTunesTrack *current = [iTunes currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}
- (NSView *)viewForLayoutTTModeMusicPlay:(NSRect)rect {
    return [self viewForLayoutTTModeMusicPause:rect];
}
- (NSView *)viewForLayoutTTModeMusicPlayPause:(NSRect)rect {
    return [self viewForLayoutTTModeMusicPause:rect];
}

- (ActionLayout)layoutTTModeMusicNextTrack {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeMusicNextTrack:(NSRect)rect {
    iTunesApplication * iTunes = self.musicApp;
    iTunesTrack *current = [iTunes currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}

//- (ActionLayout)layoutTTModeMusicVolumeUp {
//    return ACTION_LAYOUT_IMAGE_TITLE;
//}
//
//- (NSView *)viewForLayoutTTModeMusicVolumeUp:(NSRect)rect {
//    return [self songInfoView:rect];
//}
//
//- (ActionLayout)layoutTTModeMusicVolumeDown {
//    return ACTION_LAYOUT_IMAGE_TITLE;
//}
//
//- (NSView *)viewForLayoutTTModeMusicVolumeDown:(NSRect)rect {
//    return [self songInfoView:rect];
//}

+ (NSView *)songInfoView:(NSRect)rect withTrack:(iTunesTrack *)currentTrack {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 128);
    NSColor *textColor = NSColorFromRGB(0x604050);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSSize textSize = [(currentTrack.name ? currentTrack.name : @"Music") sizeWithAttributes:labelAttributes];
    rect.size.height = textSize.height * 3;
    rect.size.width *= 1.25;
    rect.origin.x -= NSWidth(rect)*0.25/2;
    rect.origin.y -= rect.size.height + 16;
    NSView *view = [[NSView alloc] initWithFrame:rect];
    NSRect hudFrame = rect;
    
    // Album art
    NSImage *songArtwork;
    iTunesArtwork *artwork = (iTunesArtwork *)[[[currentTrack artworks] get] lastObject];
    NSImage *image = artwork.data;
    NSData *data = artwork.rawData;
    
    // Not working reliably in Catalina; see: https://forums.developer.apple.com/thread/124557
    if ([image isKindOfClass:[NSImage class]]) {
        songArtwork = image;
    } else if ([data isKindOfClass:[NSData class]]) {
        songArtwork = [[NSImage alloc] initWithData:data];
    } else {
        songArtwork = [NSImage imageNamed:@"icon_music.png"];
    }
    NSInteger imageMargin = NSWidth(screen.frame)/512;
    NSInteger imageSize = rect.size.height - imageMargin*2;
    NSInteger infoX = imageMargin*2 + imageSize + imageMargin;
    NSInteger infoWidth = NSWidth(hudFrame) - infoX - imageMargin;
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(imageMargin, imageMargin, imageSize, imageSize)];
    [imageView setImage:songArtwork];
    [view addSubview:imageView];
    
    // Check if song playing
    if (!currentTrack.name) {
        NSTextView *songTitleView = [[NSTextView alloc] initWithFrame:NSMakeRect(infoX, textSize.height, infoWidth, textSize.height)];
        [songTitleView setString:self.isITunes ? @"iTunes isn't playing anything" : @"Music isn't playing anything"];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [view addSubview:songTitleView];
    } else {
        // Song title
        NSTextField *songTitleView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*2, infoWidth, textSize.height)];
        [songTitleView setStringValue:currentTrack.name];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [songTitleView setLineBreakMode:NSLineBreakByTruncatingTail];
        [songTitleView setBezeled:NO];
        [songTitleView setEditable:NO];
        [songTitleView setSelectable:NO];
        [songTitleView setDrawsBackground:NO];
        [view addSubview:songTitleView];
        
        // Artist
        NSTextField *artistView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*1, infoWidth, textSize.height)];
        [artistView setStringValue:currentTrack.artist];
        [artistView setTextColor:NSColorFromRGB(0x9080A0)];
        [artistView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [artistView setBackgroundColor:[NSColor clearColor]];
        [artistView setLineBreakMode:NSLineBreakByTruncatingTail];
        [artistView setBezeled:NO];
        [artistView setEditable:NO];
        [artistView setSelectable:NO];
        [artistView setDrawsBackground:NO];
        [view addSubview:artistView];
        
        // Album
        NSTextField *albumView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*0, infoWidth, textSize.height)];
        [albumView setStringValue:currentTrack.album];
        [albumView setTextColor:NSColorFromRGB(0x9080A0)];
        [albumView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [albumView setBackgroundColor:[NSColor clearColor]];
        [albumView setLineBreakMode:NSLineBreakByTruncatingTail];
        [albumView setBezeled:NO];
        [albumView setEditable:NO];
        [albumView setSelectable:NO];
        [albumView setDrawsBackground:NO];
        [view addSubview:albumView];
    }
    
    return view;
}

#pragma mark - Action methods

- (void)runTTModeMusicVolumeUp {
    iTunesApplication *iTunes = self.musicApp;
    NSInteger volume = iTunes.soundVolume;
    [iTunes setSoundVolume:MIN(100, volume+ITUNES_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeMusicVolumeDown {
    iTunesApplication *iTunes = self.musicApp;
    
    NSInteger volume = iTunes.soundVolume;
    [iTunes setSoundVolume:MAX(0, volume-ITUNES_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeMusicPause {
    iTunesApplication *iTunes = self.musicApp;
    
    if (iTunes.playerState == iTunesEPlSPlaying) {
        [iTunes playpause];
    }
}
- (void)doubleRunTTModeMusicPause {
    iTunesApplication *iTunes = self.musicApp;
    
    if (iTunes.playerState == iTunesEPlSPlaying) {
        [iTunes playpause];
    }
}

- (void)runTTModeMusicPlay {
    iTunesApplication *iTunes = self.musicApp;
    
    if (iTunes.playerState != iTunesEPlSPlaying) {
        [iTunes playpause];
    }
}
- (void)doubleRunTTModeMusicPlay {
    iTunesApplication *iTunes = self.musicApp;
    
    if (iTunes.playerState != iTunesEPlSPlaying) {
        [iTunes playpause];
    }
}

- (void)runTTModeMusicPlayPause {
    iTunesApplication *iTunes = self.musicApp;
    
    [iTunes playpause];
}
- (void)doubleRunTTModeMusicPlayPause {
    iTunesApplication *iTunes = self.musicApp;
    
    [iTunes previousTrack];
    if (iTunes.playerState != iTunesEPlSPlaying) {
        [iTunes playpause];
    }
}

- (void)runTTModeMusicNextTrack {
    iTunesApplication *iTunes = self.musicApp;
    
    [iTunes nextTrack];
}
- (void)doubleRunTTModeMusicNextTrack {
    iTunesApplication *iTunes = self.musicApp;
    NSString *original = [[iTunes currentTrack] album];
    iTunesTrack *current;
    int tries = 30;
    
    while (tries--) {
        [iTunes nextTrack];
        current = [iTunes currentTrack];
        if (![original isEqualToString:current.album]) {
            break;
        }
    }
}

- (void)runTTModeMusicPreviousTrack {
    iTunesApplication *iTunes = self.musicApp;
    
    [iTunes previousTrack];
}

- (void)runTTModeMusicVolumeJump:(TTModeDirection)direction {
    iTunesApplication *iTunes = self.musicApp;
    NSInteger volume = iTunes.soundVolume;
    NSInteger volumeJump = [[self.action optionValue:kMusicVolumeJump inDirection:direction] integerValue];
    if (volume != volumeJump) originalVolume = volume;

    [iTunes setSoundVolume:(volume == volumeJump ? originalVolume : volumeJump)];
}

- (void)runTTModeMusicSleep:(TTModeDirection)direction {
    volumeFadeMultiplier = 100;
    
    [self fadeVolumeDown];
}

- (void)fadeVolumeDown {
    iTunesApplication *iTunes = self.musicApp;
    volumeFadeMultiplier -= 1;
    
    [iTunes setSoundVolume:volumeFadeMultiplier];
    
    if (volumeFadeTimer) {
        [volumeFadeTimer invalidate];
    }
    
    if (volumeFadeMultiplier <= 0.f) {
        NSLog(@"Done fading out volume.");
        if (iTunes.playerState == iTunesEPlSPlaying) {
            [iTunes playpause];
        }
        [iTunes setSoundVolume:originalVolume];
        return;
    }
    
    NSDate *volumeBumpDate = [[NSDate date] dateByAddingTimeInterval:(10)/100.f];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    volumeFadeTimer = [[NSTimer alloc] initWithFireDate:volumeBumpDate
                                               interval:0.f
                                                 target:self
                                               selector:@selector(fadeVolumeDown)
                                               userInfo:nil repeats:NO];
    [runner addTimer:volumeFadeTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Bumping volume: %f", volumeFadeMultiplier);
}

- (void)runTTModeMusicPlaylist:(TTModeDirection)direction {
    NSString *selectedPlaylist = [self.action optionValue:kMusicPlaylistSingle];
    [self playPlaylist:selectedPlaylist];
}

- (void)doubleRunTTModeMusicPlaylist:(TTModeDirection)direction {
    NSString *selectedPlaylist = [self.action optionValue:kMusicPlaylistDouble];
    [self playPlaylist:selectedPlaylist];
}

- (void)playPlaylist:(NSString *)selectedPlaylist {
    iTunesApplication *iTunes = self.musicApp;
//    BOOL playlistShuffle = [[self.action optionValue:kMusicPlaylistShuffle] boolValue];
    iTunesPlaylist *itunesPl;

    if (![iTunes respondsToSelector:@selector(sources)]) {
        return;
    }
    
    for (iTunesSource *source in [iTunes sources]) {
        if ([source kind] == iTunesESrcLibrary) {
            for (iTunesPlaylist *playlist in [source userPlaylists]) {
                if ([playlist.persistentID isEqualToString:selectedPlaylist] || !selectedPlaylist) {
                    itunesPl = playlist;
                    break;
                }
            }
        }
    }
    
    if (itunesPl) {
//        itunesPl.shuffle = playlistShuffle;
        [itunesPl playOnce:YES];
    }
}

+ (SBElementArray *)userPlaylists {
    iTunesApplication *iTunes = self.musicApp;
    iTunesSource *librarySource = nil;
    
    for (iTunesSource *source in iTunes.sources) {
        if ([source kind] == iTunesESrcLibrary) {
            librarySource = source;
            break;
        }
    }
    
    SBElementArray *playlists = [librarySource userPlaylists];
    
    return playlists;
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeMusicVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeMusicNextTrack";
}
- (NSString *)defaultWest {
    return @"TTModeMusicPlayPause";
}
- (NSString *)defaultSouth {
    return @"TTModeMusicVolumeDown";
}

@end
