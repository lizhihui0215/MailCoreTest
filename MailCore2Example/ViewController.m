//
//  ViewController.m
//  MailCore2Example
//
//  Created by 李智慧 on 12/14/15.
//  Copyright © 2015 PCCW. All rights reserved.
//

#import "ViewController.h"
#import <MailCore/MailCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)getMailButtonPressed:(UIButton *)sender {
    MCOPOPSession *session = [[MCOPOPSession alloc] init];
    session.hostname = @"pop3.live.com";
    session.port = 995;
    session.username = @"lizhihui0215@hotmail.com";
    session.password = @"dsn4cgwy";
    session.connectionType = MCOConnectionTypeTLS;
    session.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    session.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        @synchronized(self) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    MCOPOPOperation *operation = [session checkAccountOperation];
    [operation start:^(NSError *error) {
        NSLog(@"error :%@",error);
    }];
    
    MCOPOPFetchMessagesOperation *messagesOperatiopn = [session fetchMessagesOperation];
    [messagesOperatiopn start:^(NSError *error, NSArray *messages) {
        if (error) {
            NSLog(@"error %@",error);
        }
        NSLog(@"messages %@",messages);
    }];
    
}


- (IBAction)sendMailButtonPressed:(UIButton *)sender {
    MCOSMTPSession *session = [[MCOSMTPSession alloc] init];
    session.hostname = @"smtp-mail.outlook.com";
    session.port = 587;
    session.username = @"lizhihui0215@hotmail.com";
    session.password = @"dsn4cgwy";
    session.connectionType = MCOConnectionTypeStartTLS;
    session.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    session.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        @synchronized(self) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:@"李智慧测试邮箱发送" mailbox:@"lizhihui0215@hotmail.com"]];
     
     NSArray * to = [NSArray arrayWithObject:[MCOAddress addressWithDisplayName:@"某人" mailbox:@"lizhihui0215@hotmail.com"]];
     [[builder header] setTo:to];
     [[builder header] setSubject:@"A nice picture!"];
     [builder setHTMLBody:@"<div>Here's the message I need to send.</div>"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"xxxx" ofType:@"png"];
    
    [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:path]];
    NSData * rfc822Data = [builder data];
    MCOSMTPSendOperation *send = [session sendOperationWithData:rfc822Data];
    
    [send start:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
    
}

@end
