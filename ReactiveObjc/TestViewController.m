//
//  TestViewController.m
//  ReactiveObjc
//
//  Created by drogan Zheng on 2018/5/18.
//  Copyright © 2018年 ReactiveObjc. All rights reserved.
//

#import "TestViewController.h"
#import <ReactiveObjC.h>

@interface TestViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *testLable;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UITextField *testTextField;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //普通按钮点击事件响应
//    [self normalButton_targetAction];
    
    //RAC按钮点击事件响应
//    [self RACButton_targetAction];
    
    //使用KVO监听属性
//    [self KVO_method];
    
    //RAC替代KVO方法
//    [self RAC_KVO];

    self.testLable.text = @"change1";
    self.testLable.text = @"change0";
    
    //RAC替代delegate使用方法
//    [self RACTextFieldDelegate];
    
    //RAC替代通知使用方法
//    [self RACNotification];
    
    //RAC遍历字典、数组
    [self RACSequence];
    
    //RAC基本使用方法
    [self RACBase];
    // Do any additional setup after loading the view from its nib.
}

- (void)normalButton_targetAction
{
    [self.testButton addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapAction:(UIButton *)sender
{
    NSLog(@"按钮点击了");
    NSLog(@"%@",sender);
}

- (void)RACButton_targetAction
{
    [[self.testButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"RAC按钮点击了");
        NSLog(@"%@",x);
    }];
    
    self.testLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [self.testLable addGestureRecognizer:tap];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        //点击事件响应的逻辑
        NSLog(@"%@",x);
    }];
}

- (void)KVO_method
{
    [self.testLable addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"] && object == self.testLable) {
        NSLog(@"%@",change);
    }
}

- (void)RAC_KVO
{
    [RACObserve(self.testLable, text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

- (void)RACTextFieldDelegate
{
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"textField delegate == %@",x);
    }];
    self.testTextField.delegate = self;
}

- (void)RACNotification
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

- (void)RACTimer
{
    //主线程中每两秒执行一次
    [[RACSignal interval:2.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@",x);
    }];
    //创建一个新线程
    [[RACSignal interval:1 onScheduler:[RACScheduler schedulerWithPriority:(RACSchedulerPriorityHigh) name:@" com.ReactiveCocoa.RACScheduler.mainThreadScheduler"]] subscribeNext:^(NSDate * _Nullable x) {
        
        NSLog(@"%@",[NSThread currentThread]);
    }];
}

- (void)RACSequence
{
    //遍历数组
    NSArray *racAry = @[@"rac1",@"rac2",@"rac3"];
    [racAry.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    //遍历字典
    NSDictionary *dict = @{@"name":@"dragon",@"type":@"fire",@"age":@"1000"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTwoTuple *tuple = (RACTwoTuple *)x;
        NSLog(@"key == %@, value == %@",tuple[0],tuple[1]);
    }];
}

- (void)RACBase
{
    //RAC基本使用方法与流程
    
    //1. 创建signal信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        //subscriber并不是一个对象
        //3. 发送信号
        [subscriber sendNext:@"sendOneMessage"];
        
        //发送error信号
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:1001 userInfo:@{@"errorMsg":@"this is a error message"}];
        [subscriber sendError:error];
        
        //4. 销毁信号
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal已销毁");
        }];
    }];
    
    //2.1 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    //2.2 针对实际中可能出现的逻辑错误，RAC提供了订阅error信号
    [signal subscribeError:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
