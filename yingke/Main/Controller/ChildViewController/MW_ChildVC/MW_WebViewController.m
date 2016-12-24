//
//  MW_WebViewController.m
//  yingke
//
//  Created by 夏明伟 on 2016/11/3.
//  Copyright © 2016年 夏明伟. All rights reserved.
//

#import "MW_WebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface MW_WebViewController ()
@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property (strong, nonatomic) NJKWebViewProgressView *progressView;
@end

@implementation MW_WebViewController


+ (instancetype)webVCWithUrlStr:(NSString *)curUrlStr{
    if (!curUrlStr || curUrlStr.length <= 0 || [curUrlStr hasPrefix:kCodingAppScheme]) {
        return nil;
    }
    NSString *proName = [NSString stringWithFormat:@"/%@.app/", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *curUrl;
    if (![curUrlStr hasPrefix:@"/"] || [curUrlStr rangeOfString:proName].location != NSNotFound) {
        curUrl = [NSURL URLWithString:curUrlStr];
    }else{
        curUrl = [NSURL URLWithString:curUrlStr relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]];
    }
    
    if (!curUrl) {
        return nil;
    }else{
        return [[self alloc] initWithURL:curUrl];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加载中...";
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    self.delegate = _progressProxy;
    @weakify(self);
    _progressProxy.progressBlock = ^(float progress) {
        @strongify(self);
        [self.progressView setProgress:progress animated:YES];
    };
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.progressBarView.backgroundColor = [UIColor colorWithHexString:@"0x3abd79"];
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}
#pragma mark UIWebViewDelegate 覆盖

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL shouldStart = ![self canAndGoOutWithLinkStr:request.URL.absoluteString];
    
    if (shouldStart && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        shouldStart = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return shouldStart;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
    
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
    
    if (error) {
        [self handleError:error];
    }
}

#pragma mark VC
- (BOOL)canAndGoOutWithLinkStr:(NSString *)linkStr{
    BOOL canGoOut = NO;
    return canGoOut;
}

#pragma mark Error
- (void)handleError:(NSError *)error{
    NSString *urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    
    if (([error.domain isEqualToString:@"WebKitErrorDomain"] && 101 == error.code) ||
        ([error.domain isEqualToString:NSURLErrorDomain] && (NSURLErrorBadURL == error.code || NSURLErrorUnsupportedURL == error.code))) {
        kTipAlert(@"网址无效：\n%@", urlString);
    }else if ([error.domain isEqualToString:NSURLErrorDomain] && (NSURLErrorTimedOut == error.code ||
                                                                  NSURLErrorCannotFindHost == error.code ||
                                                                  NSURLErrorCannotConnectToHost == error.code ||
                                                                  NSURLErrorNetworkConnectionLost == error.code ||
                                                                  NSURLErrorDNSLookupFailed == error.code ||
                                                                  NSURLErrorNotConnectedToInternet == error.code)) {
        kTipAlert(@"网络连接异常：\n%@", urlString);
    }else if ([error.domain isEqualToString:@"WebKitErrorDomain"] && 102 == error.code){
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            kTipAlert(@"无法打开链接：\n%@", urlString);
        }
    }else if (error.code == -999){
        //加载中断
    }else{
        kTipAlert(@"%@\n%@", urlString, [error.userInfo objectForKey:@"NSLocalizedDescription"]? [error.userInfo objectForKey:@"NSLocalizedDescription"]: error.description);
    }
}

@end