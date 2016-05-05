//
//  YCCalendarView.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "YCCalendarView.h"
#import "CalendarMonthView.h"

#define ChangeViewFrameX(view, X) (view.frame = CGRectMake(X, view.frame.origin.y, view.frame.size.width, view.frame.size.height))

@interface YCCalendarView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isScrolling;//是否正在滑动
@property (nonatomic, assign) BOOL hasPage;//是否已翻页

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) CalendarMonthView *preCalendarView;
@property (nonatomic, strong) CalendarMonthView *curCalendarView;
@property (nonatomic, strong) CalendarMonthView *nextCalendarView;

//@property (nonatomic, copy) NSString *currentMonth;//当前月份id
@property (nonatomic, copy) NSString *nextMonth;//下一月id
@property (nonatomic, copy) NSString *prevMonth;//上一月id

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDate *nextDate;
@property (nonatomic, strong) NSDate *preDate;

@end

@implementation YCCalendarView

#pragma mark - life cycle
- (void)dealloc {
    self.scrollView.delegate = nil;
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"frame"];
    self.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitialValue];
        [self customTopView];
        [self customScrollView];
        [self customCalendarView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInitialValue];
    [self customTopView];
    [self customScrollView];
    [self customCalendarView];
    
}

#pragma mark - Private Method
- (void)customInitialValue {
    self.isScrolling = NO;
    self.hasPage = NO;
    self.currentMonth = @"";
    self.nextMonth = @"";
    self.prevMonth = @"";
}

- (void)customTopView {
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 15)];
    self.topView.autoresizingMask = ViewAutoresizingFlexibleAll;
    self.topView.backgroundColor = [UIColor colorWithRed:0.9373 green:0.9373 blue:0.9373 alpha:1.0];
    for (int i = 0; i < 7; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        CGFloat width = self.topView.frame.size.width / 7;
        label.frame = CGRectMake(i * width, 0, width, CGRectGetHeight(self.topView.frame));
        label.autoresizingMask = ViewAutoresizingFlexibleAll;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = (i == 0 || i == 6)?[UIColor colorWithRed:0.9922 green:0.5255 blue:0.0353 alpha:1.0]:[UIColor colorWithRed:0.5451 green:0.5451 blue:0.5451 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            label.text = @"日";
        }else if (i == 1){
            label.text = @"一";
        }else if (i == 2){
            label.text = @"二";
        }else if (i == 3){
            label.text = @"三";
        }else if (i == 4){
            label.text = @"四";
        }else if (i == 5){
            label.text = @"五";
        }else if (i == 6){
            label.text = @"六";
        }
        [self.topView addSubview:label];
    }
    [self addSubview:self.topView];
}

- (void)customScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetHeight(self.topView.frame))];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = ViewAutoresizingFlexibleAll;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.scrollsToTop = NO;
    [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
    [self addSubview:self.scrollView];
    [self bringSubviewToFront:self.scrollView];
    [self addObserverForScrollViewContentOffset];
    [self addObserverForSelfViewFrame];
}

- (void)customCalendarView {
    for (int i = 0; i < 3; i++) {
        CalendarMonthView *calendarView = [[CalendarMonthView alloc]initWithFrame:CGRectMake(i * self.scrollView.frame.size.width, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
        calendarView.autoresizingMask = ViewAutoresizingFlexibleAll;
        __weak typeof(self) wSelf = self;
        calendarView.selectDateBlock = ^(NSDate *date){
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(YCCalendarViewSelectCalendarDate:)]) {
                [wSelf.delegate YCCalendarViewSelectCalendarDate:date];
            }
        };
        [self.scrollView addSubview:calendarView];
        switch (i) {
            case 0:
                self.preCalendarView = calendarView;
                break;
            case 1:
                self.curCalendarView = calendarView;
                break;
            case 2:
                self.nextCalendarView = calendarView;
                break;
            default:
                break;
        }
    }
}

- (void)changeCurMonthToLastMonth:(BOOL)toLast {
    //先计算当前月份信息
    NSString *temp = self.currentMonth;
    if (toLast) {
        self.currentMonth = self.prevMonth;
//        self.prevMonth = @"";
        self.prevMonth = [NSString stringWithFormat:@"%ld",[self.prevMonth integerValue]-1];
        self.nextMonth = temp;
        
        self.currentDate = self.preDate;
        self.preDate = [self.preCalendarView lastMonth:self.currentDate];
        self.nextDate = [self.nextCalendarView nextMonth:self.currentDate];
    }else{
        self.currentMonth = self.nextMonth;
        self.prevMonth = temp;
//        self.nextMonth = @"";
        self.nextMonth = [NSString stringWithFormat:@"%ld",[self.nextMonth integerValue]+1];
        
        self.currentDate = self.nextDate;
        self.preDate = [self.preCalendarView lastMonth:self.currentDate];
        self.nextDate = [self.nextCalendarView nextMonth:self.currentDate];
    }
}

#pragma mark - Public Method
- (void)loadingInitialData:(NSDate *)date today:(NSDate *)today {
    self.curCalendarView.today =
    self.preCalendarView.today =
    self.nextCalendarView.today = today;
    
    self.currentDate = date;
    self.preDate = [self.preCalendarView lastMonth:date];
    self.nextDate = [self.nextCalendarView nextMonth:date];
    
    [self.curCalendarView loadData:self.currentDate];
    [self.preCalendarView loadData:self.preDate];
    [self.nextCalendarView loadData:self.nextDate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
        [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
    }
}

- (void)refreshData {
    [self.curCalendarView loadData:self.currentDate];
    [self.preCalendarView loadData:self.preDate];
    [self.nextCalendarView loadData:self.nextDate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
        [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
    }
}

- (void)scrollToLastMonth {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollToNextMonth {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    CGFloat viewSize = self.scrollView.contentSize.width/CGRectGetWidth(self.scrollView.frame);
    [self.scrollView setContentOffset:CGPointMake((viewSize-1) * CGRectGetWidth(self.scrollView.frame), 0) animated:YES];
}

- (void)scrollToToday {
    NSDate *today = [NSDate date];
    self.curCalendarView.today =
    self.preCalendarView.today =
    self.nextCalendarView.today = today;
    
    self.currentDate = today;
    self.preDate = [self.preCalendarView lastMonth:today];
    self.nextDate = [self.nextCalendarView nextMonth:today];
    
    [self.curCalendarView loadData:self.currentDate];
    [self.preCalendarView loadData:self.preDate];
    [self.nextCalendarView loadData:self.nextDate];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.6];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"fade"];
    [animation setSubtype:kCATransitionFromTop];
    [self.curCalendarView.layer addAnimation:animation forKey:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
        [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
    }
}

#pragma mark - ObserverContentOffset
static void *ScrollViewContentOffsetObservationContext = &ScrollViewContentOffsetObservationContext;
- (void)addObserverForScrollViewContentOffset {
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:ScrollViewContentOffsetObservationContext];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /**
     *  若父视图使用了autolayout或autoresizing，初始化时无法准确设置contentSize，所以在这里通过kvo监测重新设置
     */
    if (context == SelfViewFrameSetObservationContext && [path isEqual:@"frame"]){
        NSString *newContentStr = [[change objectForKey:@"new"] description];
        CGRect newFrame = CGRectFromString(newContentStr);
        self.scrollView.contentSize = CGSizeMake(newFrame.size.width * 3, 0);
        [self.scrollView setContentOffset:CGPointMake(newFrame.size.width, 0) animated:NO];
    }
    
    if (context == ScrollViewContentOffsetObservationContext && [path isEqual:@"contentOffset"]){
        NSString *newContentStr = [[change objectForKey:@"new"] description];
        NSString *oldContentStr = [[change objectForKey:@"old"] description];
        
        UIScrollView *scrollView = (UIScrollView *)object;
        if (![newContentStr isEqualToString:oldContentStr] && self.isScrolling )
        {
            CGFloat viewSize = self.scrollView.contentSize.width/CGRectGetWidth(self.scrollView.frame);
            CGFloat x = self.curCalendarView.frame.origin.x;
            
            if (scrollView.contentOffset.x == x)
            {
                self.isScrolling = NO;
                if (self.hasPage) {
                    [self refreshData];
                }
                self.hasPage = NO;
            }else{
                if (scrollView.contentOffset.x == 0 ) {//上一页
                    [self changeCurMonthToLastMonth:YES];
                    self.hasPage = YES;
                    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
                }
                else if(scrollView.contentOffset.x == (viewSize-1) * CGRectGetWidth(self.scrollView.frame)) {//下一页
                    [self changeCurMonthToLastMonth:NO];
                    self.hasPage = YES;
                    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
                }
            }
        }
    }
}

static void *SelfViewFrameSetObservationContext = &SelfViewFrameSetObservationContext;
- (void)addObserverForSelfViewFrame {
    [self.scrollView addObserver:self
           forKeyPath:@"frame"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:SelfViewFrameSetObservationContext];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        if (self.isScrolling) {
            return;
        }
        self.isScrolling = YES;
    }
}
@end
