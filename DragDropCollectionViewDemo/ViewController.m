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
@property (nonatomic) NSMutableArray *numbers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theCollectionView.dataSource = self;
    self.theCollectionView.delegate = self;
    
    self.numbers = [[NSMutableArray alloc] init];
    for (int i=0; i< 20; i++) {
        [self.numbers addObject:@(i)];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)longPressed:(UILongPressGestureRecognizer*)sender {
    CGPoint loc = [sender locationInView:self.theCollectionView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startIndex = [self.theCollectionView indexPathForItemAtPoint:loc];
        
        if (self.startIndex) {
            SSDraggingCell *cell = (SSDraggingCell*)[self.theCollectionView cellForItemAtIndexPath:self.startIndex];
            self.draggingView = [[UIImageView alloc] initWithImage:[cell getRasterizedImageCopy]];
            
            [cell.contentView setAlpha:0.f];
            [self.view addSubview:self.draggingView];
            self.draggingView.center = loc;
            self.dragViewStartLocation = self.draggingView.center;
            [self.view bringSubviewToFront:self.draggingView];
            
            [UIView animateWithDuration:.4f animations:^{
                CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                self.draggingView.transform = transform;
            }];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        self.draggingView.center = loc;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.draggingView) {
            NSIndexPath *moveToIndexPath = [self.theCollectionView indexPathForItemAtPoint:loc];
            
            [UIView animateWithDuration:.4f animations:^{
                self.draggingView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {

                //update date source
                NSNumber *thisNumber = [self.numbers objectAtIndex:self.startIndex.row];
                NSLog(@"%@",self.numbers);
                [self.numbers removeObjectAtIndex:self.startIndex.row];
                 
                if (moveToIndexPath.row < self.startIndex.row) {
                    [self.numbers insertObject:thisNumber atIndex:moveToIndexPath.row];
                } else {
                    [self.numbers insertObject:thisNumber atIndex:moveToIndexPath.row];
                }
                
                NSLog(@"%@",self.numbers);

                //change items
                __weak typeof(self) weakSelf = self;
                [self.theCollectionView performBatchUpdates:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        
                        [strongSelf.theCollectionView deleteItemsAtIndexPaths:@[ self.startIndex ]];
                        [strongSelf.theCollectionView insertItemsAtIndexPaths:@[ moveToIndexPath ]];
                    }
                } completion:nil];

                [self.draggingView removeFromSuperview];
                self.draggingView = nil;
                self.startIndex = nil;
            }];
            
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
    return cell;
}

@end
