Drag Drop Collection View Demo
-----------------------------

A demonstration explaining the feature of drag and drop for a collection view. Here we use a UILongGestureRecognizer to locate points of the collection view and ultimately the cell at that point. It then creates a rasterized image of that cell to represent the dragging aspect of the cell. We then update the data (array) of the collection view prior to inserting and deleting that dragged cell.

The main emphasis I explained was in the long gesture recognizer IBAction, displayed below:

```
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
                [self.numbers removeObjectAtIndex:self.startIndex.row];
                 
                if (moveToIndexPath.row < self.startIndex.row) {
                    [self.numbers insertObject:thisNumber atIndex:moveToIndexPath.row];
                } else {
                    [self.numbers insertObject:thisNumber atIndex:moveToIndexPath.row];
                }

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

```

####Images:
