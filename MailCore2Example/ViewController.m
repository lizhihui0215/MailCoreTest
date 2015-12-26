//
//  ViewController.m
//  MailCore2Example
//
//  Created by 李智慧 on 12/14/15.
//  Copyright © 2015 PCCW. All rights reserved.
//

#import "ViewController.h"
#import <MailCore/MailCore.h>

@interface ViewController ()<MCOHTMLRendererDelegate>

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
    session.hostname = @"mail.xdz.gov.cn";
    session.port = 110;
    session.username = @"zwsw@xdz.gov.cn";
    session.password = @"zwsw0129";
    session.connectionType = MCOConnectionTypeClear;
//    session.authType = MCOAuthTypeSASLLogin;
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
        for (MCOPOPMessageInfo *info  in messages) {
           MCOPOPFetchMessageOperation *messageOperation = [session fetchMessageOperationWithIndex:info.index];
            [messageOperation start:^(NSError *error, NSData *messageData) {
                MCOMessageParser *paser = [MCOMessageParser messageParserWithData:messageData];
                
                NSString *htmlBodyRender = [paser htmlBodyRendering];
                
                NSLog(@"\n -----------htmlBodyRender--------\n %@ \n---------end----------\n",htmlBodyRender);
                
                NSString *htmlRenderResult = [paser htmlRenderingWithDelegate:self];
                NSLog(@"\n -----------htmlRenderResult--------\n %@ \n---------end----------\n",htmlRenderResult);

                NSString *bodyText = [paser plainTextBodyRendering];
                NSLog(@"\n -----------bodyText--------\n %@ \n---------end----------\n",bodyText);
                NSString *bodyTextWitespace = [paser plainTextBodyRenderingAndStripWhitespace:YES];
                NSLog(@"\n -----------bodyTextWitespace--------\n %@ \n---------end----------\n",bodyTextWitespace);
                

                NSString *text = [paser plainTextRendering];
                NSLog(@"\n -----------text--------\n %@ \n---------end----------\n",text);

                
            }];
        }
        
        if (error) {
            NSLog(@"error %@",error);
        }
        NSLog(@"messages %@",messages);
    }];
    
}



/** This delegate method should return YES if it can render a preview of the attachment as an image.
 part is always a single part.
 
 If the attachment can be previewed, it will be rendered using the image template.
 If not, the attachment template will be used.*/
- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg canPreviewPart:(MCOAbstractPart *)part;
{
    return YES;
}
/** This delegate method should return YES if the part should be rendered.*/
- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg shouldShowPart:(MCOAbstractPart *)part;
{
    return YES;
}
/** This delegate method returns the values to be applied to the template for the given header.
 See the content of MCHTMLRendererCallback.cpp for the default values of the header.*/
- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForHeader:(MCOMessageHeader *)header;
{
    return @{};
}

/** This delegate method returns the values to be applied to the template for the given attachment.
 See the content of MCHTMLRendererCallback.cpp for the default values of the attachment.*/
- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForPart:(MCOAbstractPart *)part;
{
    return @{};
}

/** @name Template Methods
 The following methods returns templates. They will match the syntax of ctemplate.
 See https://code.google.com/p/ctemplate/ */

/** This delegate method returns the template for the main header of the message.
 See the content of MCHTMLRendererCallback.cpp for the default values of the template.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header;
{
    return @"";
}

/** This delegate method returns the template an image attachment.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForImage:(MCOAbstractPart *)header;
{
    return @"";
}
/** This delegate method returns the template attachment other than images.
 See the content of MCHTMLRendererCallback.cpp for the default values of the template.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForAttachment:(MCOAbstractPart *)part;
{
    return @"";
}
/** This delegate method returns the template of the main message.
 It should include HEADER and a BODY values.
 See the content of MCHTMLRendererCallback.cpp for the default values of the template.*/
- (NSString *) MCOAbstractMessage_templateForMessage:(MCOAbstractMessage *)msg;
{
    return @"";
}
/** This delegate method returns the template of an embedded message (included as attachment).
 It should include HEADER and a BODY values.
 See the content of MCHTMLRendererCallback.cpp for the default values of the template.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessage:(MCOAbstractMessagePart *)part;
{
    return @"";
}
/** This delegate method returns the template for the header of an embedded message.
 See the content of MCHTMLRendererCallback.cpp for the default values of the template.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessageHeader:(MCOMessageHeader *)header;
{
    return @"";
}
/** This delegate method returns the separator between the text of the message and the attachments.
 This delegate method returns the template for the header of an embedded message.*/
- (NSString *) MCOAbstractMessage_templateForAttachmentSeparator:(MCOAbstractMessage *)msg;
{
    return @"";
}
/** This delegate method cleans HTML content.
 For example, it could fix broken tags, add missing <html>, <body> tags.
 Default implementation uses HTMLCleaner::cleanHTML to clean HTML content. */
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg cleanHTMLForPart:(NSString *)html;
{
    return @"";
}
/** @name Filters
 
 The following methods will filter the HTML content and may apply some filters to
 change how to display the message.*/

/** This delegate method will apply the filter to HTML rendered content of a given text part.
 For example, it could filter the CSS content.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForPart:(NSString *)html;
{
    return @"";
}
/** This delegate method will apply a filter to the whole HTML content.
 For example, it could collapse the quoted messages.*/
- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForMessage:(NSString *)html;
{
    return @"";
}




- (IBAction)sendMailButtonPressed:(UIButton *)sender {
    MCOSMTPSession *session = [[MCOSMTPSession alloc] init];
    session.hostname = @"mail.xdz.gov.cn";
    session.port = 25;
    session.username = @"zwsw@xdz.gov.cn";
    session.password = @"zwsw0129";
    session.connectionType = MCOConnectionTypeStartTLS;
    session.checkCertificateEnabled = NO;
    session.useHeloIPEnabled = YES;
    session.authType =  MCOAuthTypeSASLNone;
    session.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        @synchronized(self) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:@"李智慧测试邮箱发送" mailbox:@"zwsw@xdz.gov.cn"]];
     
     NSArray * to = [NSArray arrayWithObject:[MCOAddress addressWithDisplayName:@"某人" mailbox:@"zwsw@xdz.gov.cn"]];
     [[builder header] setTo:to];
     [[builder header] setSubject:@"A nice picture!"];
     [builder setHTMLBody:@"<div>Here's the message I need to send.</div>"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"xxxx" ofType:@"png"];
    
    [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:path]];
    NSData * rfc822Data = [builder data];
//    MCOSMTPOperation *operation = [session checkAccountOperationWithFrom:[MCOAddress addressWithDisplayName:@"李智慧测试邮箱发送" mailbox:@"zwsw@xdz.gov.cn"]];
    
//    [operation start:^(NSError *error) {
//        NSLog(@"error %@",error);
//    }];
    
    MCOSMTPSendOperation *send = [session sendOperationWithData:rfc822Data];
    
    [send start:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
    
}

@end
