//
//  QMFriendsDetailsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsController.h"
#import "UIImageView+ImageWithBlobID.h"
#import "QMVideoCallController.h"
#import "QMContactList.h"
#import "QMUtilities.h"

@interface QMFriendsDetailsController ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;

@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation QMFriendsDetailsController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureUserAvatarView];
    
    [self.userAvatar loadImageWithBlobID:self.currentFriend.blobID];
    self.fullName.text = self.currentFriend.fullName;
    
    // online status
    // activity
    NSDate *currentDate = [NSDate date];
    double timeInterval = [currentDate timeIntervalSinceDate:self.currentFriend.lastRequestAt];
    if (timeInterval <300) {
        self.status.text = kStatusOnlineString;
        self.onlineCircle.hidden = NO;
    } else {
        self.status.text = kStatusOfflineString;
        self.onlineCircle.hidden = YES;
    }
}

- (void)configureUserAvatarView
{
    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.width / 2;
    self.userAvatar.layer.borderWidth = 2.0f;
    self.userAvatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userAvatar.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1 || indexPath.row == 2) {
        [self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *currentPath = (NSIndexPath *)sender;
    if (currentPath.row == 1) {
        ((QMVideoCallController *)segue.destinationViewController).videoEnabled = YES;
    } else if (currentPath.row == 2) {
        ((QMVideoCallController *)segue.destinationViewController).videoEnabled = NO;
    }
    ((QMVideoCallController *)segue.destinationViewController).opponent = self.currentFriend;
    ((QMVideoCallController *)segue.destinationViewController).userImage = self.userAvatar.image;
}


#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)removeFromFriends:(id)sender
{
    [QMUtilities createIndicatorView];
    [[QMContactList shared] removeUserFromFriendList:self.currentFriend completion:^(BOOL success) {
        [QMUtilities removeIndicatorView];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.currentFriend = nil;
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleInProgressString message:message delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
    [alert show];
}

@end