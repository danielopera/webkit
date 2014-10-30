/*
 * Copyright (C) 2012 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "config.h"

#if WK_HAVE_C_SPI

#import "Test.h"

#import "PlatformUtilities.h"
#import "TestBrowsingContextLoadDelegate.h"
#import "TestProtocol.h"
#import <WebKit/WebKit2.h>
#import <wtf/RetainPtr.h>
#import "WTFStringUtilities.h"

#if WK_API_ENABLED

static bool testFinished = false;


@interface WebKit2CustomProtocolsTest_FormPostBodyExistsProtocol : TestProtocol
@end

@implementation WebKit2CustomProtocolsTest_FormPostBodyExistsProtocol

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    NSData *bodyData = request.HTTPBody;
    EXPECT_NOT_NULL(bodyData);
    EXPECT_NULL(request.HTTPBodyStream);
    if (bodyData != nil) {
        RetainPtr<NSString> body = adoptNS([[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
        EXPECT_EQ(String("login=john"), String(body.get()));
    }

    testFinished = true;

    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

@end


namespace TestWebKitAPI {

TEST(WebKit2CustomProtocolsTest, MainResource)
{
    testFinished = false;
    [NSURLProtocol registerClass:[TestProtocol class]];
    [WKBrowsingContextController registerSchemeForCustomProtocol:[TestProtocol scheme]];

    RetainPtr<WKProcessGroup> processGroup = adoptNS([[WKProcessGroup alloc] init]);
    RetainPtr<WKBrowsingContextGroup> browsingContextGroup = adoptNS([[WKBrowsingContextGroup alloc] initWithIdentifier:@"TestIdentifier"]);
    RetainPtr<WKView> wkView = adoptNS([[WKView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600) processGroup:processGroup.get() browsingContextGroup:browsingContextGroup.get()]);
    wkView.get().browsingContextController.loadDelegate = [[TestBrowsingContextLoadDelegate alloc] initWithBlockToRunOnLoad:^(WKBrowsingContextController *sender) {
        testFinished = true;
    }];
    [wkView.get().browsingContextController loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://test", [TestProtocol scheme]]]]];

    Util::run(&testFinished);
}

TEST(WebKit2CustomProtocolsTest, FormPostBodyExists)
{
    testFinished = false;
    [NSURLProtocol registerClass:[WebKit2CustomProtocolsTest_FormPostBodyExistsProtocol class]];
    [WKBrowsingContextController registerSchemeForCustomProtocol:[TestProtocol scheme]];

    RetainPtr<WKProcessGroup> processGroup = adoptNS([[WKProcessGroup alloc] init]);
    RetainPtr<WKBrowsingContextGroup> browsingContextGroup = adoptNS([[WKBrowsingContextGroup alloc] initWithIdentifier:@"TestIdentifier"]);
    RetainPtr<WKView> wkView = adoptNS([[WKView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600) processGroup:processGroup.get() browsingContextGroup:browsingContextGroup.get()]);

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://FormPostBodyExists", [TestProtocol scheme]]];
    NSString *html = [NSString stringWithFormat:@"<html><body onload=\"document.getElementById('f').submit()\"><form id=\"f\" action=\"%@\" method=\"post\"><input name=\"login\" value=\"john\" /></form></body></html>", url.absoluteString];
    [wkView.get().browsingContextController loadHTMLString:html baseURL:nil];

    Util::run(&testFinished);
    [NSURLProtocol unregisterClass:[WebKit2CustomProtocolsTest_FormPostBodyExistsProtocol class]];
    [WKBrowsingContextController unregisterSchemeForCustomProtocol:[TestProtocol scheme]];
}

} // namespace TestWebKitAPI

#endif // WK_API_ENABLED

#endif
