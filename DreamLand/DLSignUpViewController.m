//
//  DLSignUpViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-24.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignUpViewController.h"

@interface DLSignUpViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) IBOutlet UIButton *photoButton;
@end

@implementation DLSignUpViewController

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
	// Do any additional setup after loading the view.
    self.photoButton.layer.borderColor = [UIColor colorWithRed:54.0/255
                                                         green:56.0/255
                                                          blue:67.0/255
                                                         alpha:1.0].CGColor;
    [self.photoButton setImage:[UIImage imageNamed:@"photo.png"]
                      forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (IBAction)onJoin:(id)sender
{
    
}

- (IBAction)onPhoto:(id)sender
{
    [[[[UIActionSheet alloc] initWithTitle:@"How would you like to set your photo? "
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Take Photo", @"Choose From Library", nil] autorelease] showInView:self.view];
}

#pragma mark - UIAction Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                imagePicker.allowsEditing = YES;
                imagePicker.delegate = self;
                [self presentViewController:imagePicker
                                   animated:YES
                                 completion:^{
                                     
                                 }];
                [imagePicker release];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Your device doesn't have a Front camera!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
            break;
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing = YES;
                imagePicker.delegate = self;
                [self presentViewController:imagePicker
                                   animated:YES
                                 completion:^{
                                     
                                 }];
                [imagePicker release];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Your device doesn't support Photo Library!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImage Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.photoButton setImage:image
                      forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES
                               completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:NULL];
}

@end
