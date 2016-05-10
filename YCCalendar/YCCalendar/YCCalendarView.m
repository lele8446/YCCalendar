//
//  YCCalendarView.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "YCCalendarView.h"
#import "CalendarDataServer.h"

@interface YCCalendarView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isScrolling;//是否正在滑动
@property (nonatomic, assign) BOOL isInitial;//是否初始化
@property (nonatomic, assign) BOOL hasPage;//是否已翻页

@property (nonatomic, strong) CalendarMonthView *preCalendarView;
@property (nonatomic, strong) CalendarMonthView *curCalendarView;
@property (nonatomic, strong) CalendarMonthView *nextCalendarView;

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
        [self customScrollView];
        [self customCalendarView];
        self.frameSize = frame.size;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInitialValue];
    [self customScrollView];
    [self customCalendarView];
    self.frameSize = self.frame.size;
}

#pragma mark - Private Method
- (void)customInitialValue {
    self.isScrolling = NO;
    self.hasPage = NO;
    self.isInitial = YES;
    self.viewType = CalendarMonth;
}

- (void)customScrollView {
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
                    if (!isThisMonth && self.viewType == CalendarMonth) {
                        //点击跳至上\下一月某一天
                        [wSelf scrollToDay:date isToday:NO];
                    }
                    if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(YCCalendarView:selectCalendarDate:)]) {
                        [wSelf.delegate YCCalendarView:wSelf selectCalendarDate:date];
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

- (void)changeCurDataToLast:(BOOL)toLast {
    if (toLast) {
        self.selectDate = [self handleIncludeTodayDate:self.preDate];
    }else{
        self.selectDate = [self handleIncludeTodayDate:self.nextDate];
    }
    [self handlePreAndNextDate];
}

/**
 *  判断该月\周数据是否包含当天，是的话取当天
 *
 *  @param date
 *
 *  @return
 */
- (NSDate *)handleIncludeTodayDate:(NSDate *)date {
    NSDate *newDate = date;
    NSDate *today = [NSDate date];
    if ([CalendarDataServer month:date] == [CalendarDataServer month:today] && self.viewType == CalendarMonth) {
        newDate = today;
    }else if ([CalendarDataServer weekOfYear:date] == [CalendarDataServer weekOfYear:today] && self.viewType == CalendarWeek) {
        newDate = today;
    }
    return newDate;
}

//计算上一页与下一页的date
- (void)handlePreAndNextDate {
    if (self.viewType == CalendarMonth) {
        self.preDate = [self handleIncludeTodayDate:[CalendarDataServer lastMonth:self.selectDate]];
        self.nextDate = [self handleIncludeTodayDate:[CalendarDataServer nextMonth:self.selectDate]];
    }else if (self.viewType == CalendarWeek){
        self.preDate = [self handleIncludeTodayDate:[CalendarDataServer lastWeek:self.selectDate]];
        self.nextDate = [self handleIncludeTodayDate:[CalendarDataServer nextWeek:self.selectDate]];
    }
}

#pragma mark - Public Method
- (void)loadingInitialDataSelectDay:(NSDate *)selectDay {
    
    //初次加载数据前，重绘UI，防止autolayout下frame值错误
    [self layoutIfNeeded];
    self.selectDate = selectDay;
    [self handlePreAndNextDate];
    [self refreshData];
    
    self.isInitial = NO;
}

- (void)refreshData {
    [self.curCalendarView loadDataSelectDate:self.selectDate withType:self.viewType];
    [self.preCalendarView loadDataSelectDate:self.preDate withType:self.viewType];
    [self.nextCalendarView loadDataSelectDate:self.nextDate withType:self.viewType];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(YCCalendarView:didEndScrollToDate:)]) {
        [self.delegate YCCalendarView:self didEndScrollToDate:self.selectDate];
    }
}

- (void)scrollToLastPage {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollToNextPage {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    CGFloat viewSize = self.scrollView.contentSize.width/CGRectGetWidth(self.scrollView.frame);
    [self.scrollView setContentOffset:CGPointMake((viewSize-1) * CGRectGetWidth(self.scrollView.frame), 0) animated:YES];
}

- (void)scrollToLastDay {
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([self.selectDate timeIntervalSinceReferenceDate] - 24*3600)];
    self.selectDate = newDate;
    [self handlePreAndNextDate];
    [self refreshData];
}

- (void)scrollToNextDay {
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([self.selectDate timeIntervalSinceReferenceDate] + 24*3600)];
    self.selectDate = newDate;
    [self handlePreAndNextDate];
    [self refreshData];
}

//点击跳至今天
- (void)scrollToToday {
    NSDate *today = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    if ([[format stringFromDate:self.selectDate] isEqualToString:[format stringFromDate:today]]) {
        return;
    }
    [self scrollToDay:today isToday:YES];
}

- (void)scrollToDay:(NSDate *)date isToday:(BOOL)isToday {
    self.selectDate = date;
    [self handlePreAndNextDate];
    
    if (isToday) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setFillMode:kCAFillModeForwards];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [animation setType:@"fade"];
        [animation setSubtype:kCATransitionFromTop];
        [self.curCalendarView.layer addAnimation:animation forKey:nil];
    }
    
    [self refreshData];
    
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
                    [self changeCurDataToLast:YES];
                    self.hasPage = YES;
                    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
                }
                else if(scrollView.contentOffset.x == (viewSize-1) * CGRectGetWidth(self.scrollView.frame)) {//下一页
                    [self changeCurDataToLast:NO];
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
