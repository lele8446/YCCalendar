//
//  YCCalendarView.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "YCCalendarView.h"
#import "CalendarMonthView.h"
#import "CalendarDataServer.h"

#define ChangeViewFrameX(view, X) (view.frame = CGRectMake(X, view.frame.origin.y, view.frame.size.width, view.frame.size.height))
#define ChangeViewFrameY(view, Y) (view.frame = CGRectMake(view.frame.origin.x, Y, view.frame.size.width, view.frame.size.height))

@interface YCCalendarView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isScrolling;//是否正在滑动
@property (nonatomic, assign) BOOL isInitial;//是否初始化
@property (nonatomic, assign) BOOL hasPage;//是否已翻页

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) CalendarMonthView *preCalendarView;
@property (nonatomic, strong) CalendarMonthView *curCalendarView;
@property (nonatomic, strong) CalendarMonthView *nextCalendarView;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDate *nextDate;
@property (nonatomic, strong) NSDate *preDate;
@property (nonatomic, strong) NSDate *selectDate;

@property (nonatomic, assign) CGSize frameSize;

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
//        self.topView = [self customTopView];
//        [self addSubview:self.topView];
        [self customScrollView];
        [self customCalendarView];
        self.frameSize = frame.size;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInitialValue];
//    self.topView = [self customTopView];
//    [self addSubview:self.topView];
    [self customScrollView];
    [self customCalendarView];
    self.frameSize = self.frame.size;
}

- (void)setSelectDate:(NSDate *)selectDate {
    _selectDate = selectDate;
    self.curCalendarView.selectDate = selectDate;
}

#pragma mark - Private Method
- (void)customInitialValue {
    self.isScrolling = NO;
    self.hasPage = NO;
    self.isInitial = YES;
    self.isExpand = YES;
}

- (UIView *)customTopView {
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 15)];
    topView.autoresizingMask = ViewAutoresizingFlexibleAll;
    topView.backgroundColor = [UIColor colorWithRed:0.9373 green:0.9373 blue:0.9373 alpha:1.0];
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
        [topView addSubview:label];
    }
    return topView;
}

- (void)customScrollView {
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetHeight(self.topView.frame))];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
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
        [self.scrollView addSubview:calendarView];
        switch (i) {
            case 0:
                self.preCalendarView = calendarView;
                break;
            case 1:
            {
                self.curCalendarView = calendarView;
                __weak typeof(self) wSelf = self;
                self.curCalendarView.selectDateBlock = ^(NSDate *date, BOOL isThisMonth){
                    wSelf.selectDate = date;
                    wSelf.currentDate = date;
                    if (!isThisMonth && self.isExpand) {
                        [wSelf scrollToDay:date isToday:NO];
                    }
                    if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(YCCalendarViewSelectCalendarDate:)]) {
                        [wSelf.delegate YCCalendarViewSelectCalendarDate:date];
                    }
                };
            }
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
    if (toLast) {
        self.currentDate = self.preDate;
        self.preDate = self.isExpand?[CalendarDataServer lastMonth:self.currentDate]:[CalendarDataServer lastWeek:self.currentDate];
        self.nextDate = self.isExpand?[CalendarDataServer nextMonth:self.currentDate]:[CalendarDataServer nextWeek:self.currentDate];
        self.nextCalendarView.selectDate = self.curCalendarView.selectDate;
    }else{
        self.currentDate = self.nextDate;
        self.preDate = self.isExpand?[CalendarDataServer lastMonth:self.currentDate]:[CalendarDataServer lastWeek:self.currentDate];
        self.nextDate = self.isExpand?[CalendarDataServer nextMonth:self.currentDate]:[CalendarDataServer nextWeek:self.currentDate];
        self.preCalendarView.selectDate = self.curCalendarView.selectDate;
    }
}

#pragma mark - Public Method
- (void)loadingInitialData:(NSDate *)date selectDay:(NSDate *)selectDay {
    self.curCalendarView.selectDate = selectDay;
    self.preCalendarView.selectDate = nil;
    self.nextCalendarView.selectDate = nil;
    self.selectDate = selectDay;
    
    self.currentDate = date;
    self.preDate = self.isExpand?[CalendarDataServer lastMonth:date]:[CalendarDataServer lastWeek:date];
    self.nextDate = self.isExpand?[CalendarDataServer nextMonth:date]:[CalendarDataServer nextWeek:date];
    
    [self.curCalendarView loadData:self.currentDate isExpand:self.isExpand];
    [self.preCalendarView loadData:self.preDate isExpand:self.isExpand];
    [self.nextCalendarView loadData:self.nextDate isExpand:self.isExpand];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
        [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
    }
    self.isInitial = NO;
}

- (void)refreshData {
    [self.curCalendarView loadData:self.currentDate isExpand:self.isExpand];
    [self.preCalendarView loadData:self.preDate isExpand:self.isExpand];
    [self.nextCalendarView loadData:self.nextDate isExpand:self.isExpand];
    
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
//    NSDateFormatter *format=[[NSDateFormatter alloc]init];
//    [format setDateFormat:@"yyyy-MM-dd"];
//    if ([[format stringFromDate:today] isEqualToString:[format stringFromDate:self.curCalendarView.selectDate]]) {
//        return;
//    }
    self.selectDate = today;
    [self scrollToDay:today isToday:YES];
    self.preCalendarView.selectDate = nil;
    self.nextCalendarView.selectDate = nil;
}

- (void)scrollToDay:(NSDate *)date isToday:(BOOL)isToday {
    self.curCalendarView.selectDate = date;
    
    self.currentDate = date;
    self.preDate = [CalendarDataServer lastMonth:date];
    self.nextDate = [CalendarDataServer nextMonth:date];
    
    [self.curCalendarView loadData:self.currentDate isExpand:self.isExpand];
    [self.preCalendarView loadData:self.preDate isExpand:self.isExpand];
    [self.nextCalendarView loadData:self.nextDate isExpand:self.isExpand];
    
    if (isToday) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setFillMode:kCAFillModeForwards];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [animation setType:@"fade"];
        [animation setSubtype:kCATransitionFromTop];
        [self.curCalendarView.layer addAnimation:animation forKey:nil];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
        [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
    }
}

- (void)YCCalendarViewNarrowCompletion:(void(^)(void))completion {
    if (!self.isExpand) {
        return;
    }
    self.isExpand = NO;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.8];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"fade"];
    [animation setSubtype:kCATransitionFromTop];
    [self.layer addAnimation:animation forKey:nil];
    
    self.currentDate = self.selectDate;
    self.preDate = [CalendarDataServer lastWeek:self.currentDate];
    self.nextDate = [CalendarDataServer nextWeek:self.currentDate];
    [self.curCalendarView loadData:self.currentDate isExpand:self.isExpand];
    [self.preCalendarView loadData:self.preDate isExpand:self.isExpand];
    [self.nextCalendarView loadData:self.nextDate isExpand:self.isExpand];
    
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         CGFloat oneRowHeight = self.frameSize.height / 6;
                         self.frame = CGRectMake(0, 0, self.frameSize.width, oneRowHeight);
                         completion();
                     }completion:^(BOOL finished){
                         if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
                             [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
                         }
                     }];
}

- (void)YCCalendarViewExpandCompletion:(void(^)(void))completion {
    if (self.isExpand) {
        return;
    }
    self.isExpand = YES;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.8];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"fade"];
    [animation setSubtype:kCATransitionFromTop];
    [self.layer addAnimation:animation forKey:nil];
    
    self.currentDate = self.selectDate;
    self.preDate = [CalendarDataServer lastMonth:self.currentDate];
    self.nextDate = [CalendarDataServer nextMonth:self.currentDate];
    [self.curCalendarView loadData:self.currentDate isExpand:self.isExpand];
    [self.preCalendarView loadData:self.preDate isExpand:self.isExpand];
    [self.nextCalendarView loadData:self.nextDate isExpand:self.isExpand];
    
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         self.frame = CGRectMake(0, 0, self.frameSize.width, self.frameSize.height);
                     }completion:^(BOOL finished){
                         completion();
                         if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarViewdidEndScrollToDate:)]) {
                             [self.delegate YCCalendarViewdidEndScrollToDate:self.currentDate];
                         }
                     }];
}

#pragma mark - ObserverContentOffset && ObserverFrame

static void *SelfViewFrameSetObservationContext = &SelfViewFrameSetObservationContext;
- (void)addObserverForSelfViewFrame {
    [self.scrollView addObserver:self
                      forKeyPath:@"frame"
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:SelfViewFrameSetObservationContext];
}

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
    if (context == SelfViewFrameSetObservationContext && [path isEqual:@"frame"] && self.isInitial){
        NSString *newContentStr = [[change objectForKey:@"new"] description];
        CGRect newFrame = CGRectFromString(newContentStr);
        self.scrollView.contentSize = CGSizeMake(newFrame.size.width * 3, 0);
        [self.scrollView setContentOffset:CGPointMake(newFrame.size.width, 0) animated:NO];
        self.frameSize = newFrame.size;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView && !self.isInitial) {
        if (self.isScrolling) {
            return;
        }
        self.isScrolling = YES;
    }
}
@end
