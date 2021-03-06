//
//  ViewController.m
//  DragDropCollectionViewDemo
//
//  Created by Stevenson on 3/13/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "ViewController.h"
#import "SSDraggingCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *theCollectionView;

///dragged view (over cells)
@property (nonatomic) UIImageView *draggingView;

///the point we first clicked
@property (nonatomic) CGPoint dragViewStartLocation;

///the indexpath for the first item
@property (nonatomic) NSIndexPath *startIndex;
@property (nonatomic) NSIndexPath *moveToIndexPath;
@property (nonatomic) NSMutableArray *numbers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theCollectionView.dataSource = self;
    self.theCollectionView.delegate = self;
    
    self.numbers = [[NSMutableArray alloc] init];
    for (int i=0; i< 40; i++) {
        [self.numbers addObject:@(i)];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)longPressed:(UILongPressGestureRecognizer*)sender {
    CGPoint loc = [sender locationInView:self.theCollectionView];
    
    CGFloat heightInScreen = fmodf((loc.y-self.theCollectionView.contentOffset.y), CGRectGetHeight(self.theCollectionView.frame));
    CGPoint locInScreen = CGPointMake( loc.x-self.theCollectionView.contentOffset.x, heightInScreen );
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startIndex = [self.theCollectionView indexPathForItemAtPoint:loc];
        
        if (self.startIndex) {
            SSDraggingCell *cell = (SSDraggingCell*)[self.theCollectionView cellForItemAtIndexPath:self.startIndex];
            self.draggingView = [[UIImageView alloc] initWithImage:[cell getRasterizedImageCopy]];
            
            [cell.contentView setAlpha:0.f];
            [self.view addSubview:self.draggingView];
            self.draggingView.center = locInScreen;
            self.dragViewStartLocation = self.draggingView.center;
            [self.view bringSubviewToFront:self.draggingView];
            
            [UIView animateWithDuration:.4f animations:^{
                CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                self.draggingView.transform = transform;
            }];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        self.draggingView.center = locInScreen;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.draggingView) {
            self.moveToIndexPath = [self.theCollectionView indexPathForItemAtPoint:loc];
            if (self.moveToIndexPath) {
                //update date source
                NSNumber *thisNumber = [self.numbers objectAtIndex:self.startIndex.row];
                [self.numbers removeObjectAtIndex:self.startIndex.row];
                
                if (self.moveToIndexPath.row < self.startIndex.row) {
                    [self.numbers insertObject:thisNumber atIndex:self.moveToIndexPath.row];
                } else {
                    [self.numbers insertObject:thisNumber atIndex:self.moveToIndexPath.row];
                }
                
                [UIView animateWithDuration:.4f animations:^{
                    self.draggingView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    
                    
                    
                    //change items
                    __weak typeof(self) weakSelf = self;
                    [self.theCollectionView performBatchUpdates:^{
                        __strong typeof(self) strongSelf = weakSelf;
                        if (strongSelf) {
                            
                            [strongSelf.theCollectionView deleteItemsAtIndexPaths:@[ self.startIndex ]];
                            [strongSelf.theCollectionView insertItemsAtIndexPaths:@[ strongSelf.moveToIndexPath ]];
                        }
                    } completion:^(BOOL finished) {
                        SSDraggingCell *movedCell = (SSDraggingCell*)[self.theCollectionView cellForItemAtIndexPath:self.moveToIndexPath];
                        [movedCell.contentView setAlpha:1.f];
                        
                        SSDraggingCell *oldIndexCell = (SSDraggingCell*)[self.theCollectionView cellForItemAtIndexPath:self.startIndex];
                        [oldIndexCell.contentView setAlpha:1.f];
                    }];
                    
                    [self.draggingView removeFromSuperview];
                    self.draggingView = nil;
                    self.startIndex = nil;
                    
                }];
                
            } else {
                [UIView animateWithDuration:.4f animations:^{
                    self.draggingView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    SSDraggingCell *cell = (SSDraggingCell*)[self.theCollectionView cellForItemAtIndexPath:self.startIndex];
                    [cell.contentView setAlpha:1.f];
                    
                    [self.draggingView removeFromSuperview];
                    self.draggingView = nil;
                    self.startIndex = nil;
                }];
            }
            
            loc = CGPointZero;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.numbers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.theCollectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *number = (UILabel*)[cell viewWithTag:1];
    
    NSInteger theInt = [(NSNumber*)[self.numbers objectAtIndex:indexPath.row] integerValue];
    
    number.text = [NSString stringWithFormat:@"%i",(int)theInt];
    cell.contentView.backgroundColor = [UIColor darkGrayColor];
    [cell.contentView setAlpha:1.f];
    return cell;
}

@end
