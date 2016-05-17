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
@property (nonatomic, assign) BOOL isScrolling;//是否正在滑动
@property (nonatomic, assign) BOOL isInitial;//是否初始化
@property (nonatomic, assign) BOOL hasPage;//是否已翻页

@property (nonatomic, strong) CalendarMonthView *preCalendarView;
@property (nonatomic, strong) CalendarMonthView *curCalendarView;
@property (nonatomic, strong) CalendarMonthView *nextCalendarView;

@property (nonatomic, strong) NSDate *nextDate;
@property (nonatomic, strong) NSDate *preDate;
@property (nonatomic, strong) NSDate *selectDate;

@end

@implementation YCCalendarView

#pragma mark - life cycle
- (void)dealloc {
    self.calendarViewDelegate = nil;
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"frame"];
    self.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitialValue];
        [self customScrollView];
        [self customCalendarView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInitialValue];
    [self customScrollView];
    [self customCalendarView];
}

- (void)setHeightAdjust:(BOOL)heightAdjust {
    _heightAdjust = heightAdjust;
    if (heightAdjust) {
        self.preCalendarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        self.curCalendarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        self.nextCalendarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    }else{
        self.preCalendarView.autoresizingMask = ViewAutoresizingFlexibleAll;
        self.curCalendarView.autoresizingMask = ViewAutoresizingFlexibleAll;
        self.nextCalendarView.autoresizingMask = ViewAutoresizingFlexibleAll;
    }
}

#pragma mark - Private Method
- (void)customInitialValue {
    self.isScrolling = NO;
    self.hasPage = NO;
    self.isInitial = YES;
    self.viewType = CalendarMonth;
    self.heightAdjust = NO;
}

- (void)customScrollView {
    self.showsHorizontalScrollIndicator = NO;
    self.contentSize = CGSizeMake(self.bounds.size.width * 3, 0);
    self.pagingEnabled = YES;
    self.bounces = NO;
    self.delegate = self;
    self.backgroundColor = [UIColor whiteColor];
    self.scrollsToTop = NO;
    [self setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
    [self addObserverForScrollViewContentOffset];
    [self addObserverForSelfViewFrame];
}

- (void)customCalendarView {
    for (int i = 0; i < 3; i++) {
        CalendarMonthView *calendarView = [[CalendarMonthView alloc]initWithFrame:CGRectMake(i * self.frame.size.width, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        if (self.heightAdjust) {
            calendarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        }else{
            calendarView.autoresizingMask = ViewAutoresizingFlexibleAll;
        }
        [self addSubview:calendarView];
        __weak typeof(self) wSelf = self;
        switch (i) {
            case 0:
            {
                self.preCalendarView = calendarView;
            }
                break;
            case 1:
            {
                self.curCalendarView = calendarView;
                self.curCalendarView.selectDateBlock = ^(NSDate *date, BOOL isThisMonth){
                    wSelf.selectDate = date;
                    //点击的不是本月数据，则滑动至上\下一月的那一天
                    if (!isThisMonth && self.viewType == CalendarMonth) {
                        [wSelf scrollToDay:date isToday:NO];
                    }else{
                        if (wSelf.calendarViewDelegate && [wSelf.calendarViewDelegate respondsToSelector:@selector(YCCalendarView:selectCalendarDate:selectDateRow:)]) {
                            [wSelf.calendarViewDelegate YCCalendarView:wSelf selectCalendarDate:date selectDateRow:wSelf.curCalendarView.selectDateRow];
                        }
                    }
                };
            }
                break;
            case 2:
            {
                self.nextCalendarView = calendarView;
            }
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
    if ([CalendarDataServer year:date] == [CalendarDataServer year:today]) {
        if ([CalendarDataServer month:date] == [CalendarDataServer month:today] && self.viewType == CalendarMonth) {
            newDate = today;
        }else if ([CalendarDataServer weekOfYear:date] == [CalendarDataServer weekOfYear:today] && self.viewType == CalendarWeek) {
            newDate = today;
        }
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
    [self YCCalendarViewRefreshDataHeightAdjust:self.heightAdjust];
}

- (void)YCCalendarViewRefreshDataHeightAdjust:(BOOL)heightAdjust {
    __weak typeof(self) wSelf = self;
    self.curCalendarView.changeFrameBlock = ^(NSInteger weekNum){
        if (heightAdjust) {
            if (wSelf.isInitial) {
                ChangeViewFrameHeight(wSelf, weekNum * DefaultCalendarWeekViewHeight);
                [wSelf layoutIfNeeded];
            }else{
                [wSelf.layer removeAllAnimations];
                [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
                    ChangeViewFrameHeight(wSelf, weekNum * DefaultCalendarWeekViewHeight);
                    [wSelf layoutIfNeeded];
                } completion:^(BOOL finished){
                    
                }];
                if (wSelf.calendarViewDelegate && [wSelf.calendarViewDelegate respondsToSelector:@selector(YCCalendarView:adjustFrameWithWeekNumber:)]) {
                    [wSelf.calendarViewDelegate YCCalendarView:wSelf adjustFrameWithWeekNumber:weekNum];
                }
            }
        }
    };
    
    [self.curCalendarView loadDataSelectDate:self.selectDate withType:self.viewType heightAdjust:heightAdjust];
    [self.preCalendarView loadDataSelectDate:self.preDate withType:self.viewType heightAdjust:heightAdjust];
    [self.nextCalendarView loadDataSelectDate:self.nextDate withType:self.viewType heightAdjust:heightAdjust];
    
    if (self.calendarViewDelegate && [self.calendarViewDelegate respondsToSelector:@selector(YCCalendarView:didEndScrollToDate:selectDateRow:)]) {
        [self.calendarViewDelegate YCCalendarView:self didEndScrollToDate:self.selectDate selectDateRow:self.curCalendarView.selectDateRow];
    }
}

#pragma mark - Public Method
- (void)YCCalendarViewLoadInitialDataWithSelectDay:(NSDate *)selectDay {
    
    //初次加载数据前，重绘UI，防止autolayout下frame值错误
    [self layoutIfNeeded];
    self.selectDate = selectDay;
    [self handlePreAndNextDate];
    [self YCCalendarViewRefreshDataHeightAdjust:self.heightAdjust];
    
    self.isInitial = NO;
}

- (void)YCCalendarViewScrollToLastPage {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)YCCalendarViewScrollToNextPage {
    if (self.isScrolling) {
        return;
    }
    self.isScrolling = YES;
    CGFloat viewSize = self.contentSize.width/CGRectGetWidth(self.frame);
    [self setContentOffset:CGPointMake((viewSize-1) * CGRectGetWidth(self.frame), 0) animated:YES];
}

- (void)YCCalendarViewScrollToLastDay {
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([self.selectDate timeIntervalSinceReferenceDate] - 24*3600)];
    self.selectDate = newDate;
    [self handlePreAndNextDate];
    [self YCCalendarViewRefreshDataHeightAdjust:self.heightAdjust];
}

- (void)YCCalendarViewScrollToNextDay {
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([self.selectDate timeIntervalSinceReferenceDate] + 24*3600)];
    self.selectDate = newDate;
    [self handlePreAndNextDate];
    [self YCCalendarViewRefreshDataHeightAdjust:self.heightAdjust];
}

- (void)YCCalendarViewScrollToToday {
    NSDate *today = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    if ([[format stringFromDate:self.selectDate] isEqualToString:[format stringFromDate:today]]) {
        return;
    }
    [self scrollToDay:today isToday:YES];
}

#pragma mark - ObserverContentOffset && ObserverFrame
static void *SelfViewFrameSetObservationContext = &SelfViewFrameSetObservationContext;
- (void)addObserverForSelfViewFrame {
    [self addObserver:self
           forKeyPath:@"frame"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:SelfViewFrameSetObservationContext];
}

static void *ScrollViewContentOffsetObservationContext = &ScrollViewContentOffsetObservationContext;
- (void)addObserverForScrollViewContentOffset {
    [self addObserver:self
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
        self.contentSize = CGSizeMake(newFrame.size.width * 3, 0);
        [self setContentOffset:CGPointMake(newFrame.size.width, 0) animated:NO];
    }
    
    if (context == ScrollViewContentOffsetObservationContext && [path isEqual:@"contentOffset"]){
        NSString *newContentStr = [[change objectForKey:@"new"] description];
        NSString *oldContentStr = [[change objectForKey:@"old"] description];
        
        UIScrollView *scrollView = (UIScrollView *)object;
        if (![newContentStr isEqualToString:oldContentStr] && self.isScrolling )
        {
            CGFloat viewSize = self.contentSize.width/CGRectGetWidth(self.frame);
            CGFloat x = self.curCalendarView.frame.origin.x;
            
            if (scrollView.contentOffset.x == x)
            {
                self.isScrolling = NO;
                if (self.hasPage) {
                    [self YCCalendarViewRefreshDataHeightAdjust:self.heightAdjust];
                }
                self.hasPage = NO;
            }else{
                if (scrollView.contentOffset.x == 0 ) {//上一页
                    [self changeCurDataToLast:YES];
                    self.hasPage = YES;
                    [self setContentOffset:CGPointMake(x, 0) animated:NO];
                }
                else if(scrollView.contentOffset.x == (viewSize-1) * CGRectGetWidth(self.frame)) {//下一页
                    [self changeCurDataToLast:NO];
                    self.hasPage = YES;
                    [self setContentOffset:CGPointMake(x, 0) animated:NO];
                }
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self && !self.isInitial) {
        if (self.isScrolling) {
            return;
        }
        self.isScrolling = YES;
    }
}
@end
