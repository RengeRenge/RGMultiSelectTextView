//
//  ViewController.m
//  RGMultiSelectTextViewDemo
//
//  Created by juphoon on 2018/4/2.
//  Copyright © 2018年 ld. All rights reserved.
//

#import "ViewController.h"
#import "RGMultiSelectTextView.h"

@interface ViewController () <RGMultiSelectTextViewDelegate>

@property (nonatomic, strong) RGMultiSelectTextView *multiSelectTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _multiSelectTextView = [[RGMultiSelectTextView alloc] init];
    
    _multiSelectTextView.minimumTitleWidth = 50.0f;
    _multiSelectTextView.titleInterItmeSpacing = 4.0f;
    _multiSelectTextView.titleLineSpacing = 5.0f;
    _multiSelectTextView.edgeInsets = UIEdgeInsetsMake(12, 15, 12, 15);
    
    _multiSelectTextView.returnKeyType = UIReturnKeySearch;
    
    _multiSelectTextView.placeHoderOnTextField = NO;
    _multiSelectTextView.titleNormalColor = [UIColor blackColor];
    _multiSelectTextView.titleSelectedColor = [UIColor whiteColor];
    _multiSelectTextView.titleNormalBackgroudColor = [UIColor lightGrayColor];
    _multiSelectTextView.titleSelectedBackgroudColor = [UIColor blackColor];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@" にゃんぱすー" attributes:@{NSFontAttributeName : _multiSelectTextView.font, NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    NSTextAttachment *icon = [[NSTextAttachment alloc] init];
    icon.image = [UIImage imageNamed:@"Renge"];
    
    if (_multiSelectTextView.placeHoderOnTextField) {
        icon.bounds = CGRectMake(0, 0, 30.f, 30.f);
    } else {
        icon.bounds = CGRectMake(0, 0, 25.f, 25.f);
    }
    [att replaceCharactersInRange:NSMakeRange(0, 0) withAttributedString:[NSAttributedString attributedStringWithAttachment:icon]];
    
    _multiSelectTextView.attributePlaceHoder = att;
    _multiSelectTextView.delegate = self;
    [self.view addSubview:_multiSelectTextView];
}

#pragma mark - RGMultiSelectTextViewDelegate

- (void)multiSelectTextViewDidBeginEditing:(RGMultiSelectTextView *)multiSelectTextView {
    
}

- (void)multiSelectTextViewTextDidChange:(RGMultiSelectTextView *)multiSelectTextView {
    
}

- (void)multiSelectTextViewDidReturn:(RGMultiSelectTextView *)multiSelectTextView {
    RGMultiSelectedObject *obj = [RGMultiSelectedObject objectwithTitle:multiSelectTextView.text identifier:multiSelectTextView.text];
    [multiSelectTextView insertTitles:@[obj]];
    
    multiSelectTextView.text = nil;
}

- (void)multiSelectTextViewDidEndEditing:(RGMultiSelectTextView *)multiSelectTextView {
    
}

- (BOOL)multiSelectTextView:(RGMultiSelectTextView *)multiSelectTextView shouldRemoveObejct:(NSArray <RGMultiSelectedObject *> *)object {
    return YES;
}

- (void)multiSelectTextView:(RGMultiSelectTextView *)multiSelectTextView didRemoveObejct:(NSArray <RGMultiSelectedObject *> *)object {
    
}

- (void)multiSelectTextViewContentSizeWillChange:(RGMultiSelectTextView *)multiSelectTextView contentSize:(CGSize)contentSize {
    NSLog(@"%f", contentSize.height);
    CGRect frame = self.view.bounds;
    frame.origin.y = 44.f;
    frame.size.height = MIN(contentSize.height, 180);
    multiSelectTextView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
