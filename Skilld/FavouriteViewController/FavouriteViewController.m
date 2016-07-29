//
//  FavouriteViewController.m
//  Skilld
//
//  Created by TianHang on 3/13/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "FavouriteViewController.h"
#import "CommonUtils.h"

@interface FavouriteViewController () {
    NSString *mStrSearchText;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;

@end

@implementation FavouriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnAll:(id)sender {
    // clear category selection
    CommonUtils *util = [CommonUtils sharedObject];
    [util setCategory:nil];
    
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - Collection

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.mSearchBar resignFirstResponder];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CommonUtils *utils = [CommonUtils sharedObject];
    
    int nCount = 0;
    
    for (BlogCategory *cate in utils.mCategoryList) {
        if (mStrSearchText.length > 0)
        {
            NSRange range = [cate.strName rangeOfString:mStrSearchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                nCount++;
            }
        }
        else
        {
            nCount++;
        }
    }
    
    return nCount;
}

- (BlogCategory *)getCategoryWithRowNum:(int)nRow {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogCategory *category;
    
    if (mStrSearchText.length > 0) {
        int nIndex = 0;
        
        for (BlogCategory *cate in utils.mCategoryList) {
            
            NSRange range = [cate.strName rangeOfString:mStrSearchText options:NSCaseInsensitiveSearch];
            if (range.location == NSNotFound) {
                continue;
            }
            
            if (nIndex == nRow) {
                category = cate;
                break;
            }
            
            nIndex++;
        }
    }
    else {
        category = [utils.mCategoryList objectAtIndex:nRow];
    }
    
    return category;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FavouriteCollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
    [iconView setAlpha:1];
    
    BlogCategory *category = [self getCategoryWithRowNum:indexPath.row];
    
    if (category) {
        NSString *strImageName = [NSString stringWithFormat:@"%@.png", category.strName];
        iconView.image = [UIImage imageNamed:strImageName];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    int nControllerIndex = 0;
//    
//    // Get views. controllerIndex is passed in as the controller we want to go to.
//    UIView * fromView = self.view;
//    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:nControllerIndex] view];
//    
//    // Transition using a page curl.
//    [UIView transitionFromView:fromView
//                        toView:toView
//                      duration:0.5
//                       options:(nControllerIndex > self.tabBarController.selectedIndex ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionCurveEaseInOut)
//                    completion:^(BOOL finished) {
//                        if (finished) {
//                            self.tabBarController.selectedIndex = nControllerIndex;
//                        }
//                    }];
    
    CommonUtils *util = [CommonUtils sharedObject];
    BlogCategory *category = [self getCategoryWithRowNum:indexPath.row];
    [util setCategory:category];
    
    self.tabBarController.selectedIndex = 0;
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
    [iconView setAlpha:1];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
    [iconView setAlpha:0.5];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
    [iconView setAlpha:1];
}

# pragma mark - UISearchDisplayDelegate

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    mStrSearchText = @"";
    [self.mCollectionView reloadData];
}

# pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    mStrSearchText = searchText;
    [self.mCollectionView reloadData];
}



@end
