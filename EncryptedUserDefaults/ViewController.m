//
//  ViewController.m
//  EncryptedUserDefaults
//
//  Created by shubham on 14/05/17.
//  Copyright © 2017 Sort. All rights reserved.
//

#import "ViewController.h"
#import "EncryptedUserDefaults.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    EncryptedUserDefaults *ecd = [[EncryptedUserDefaults alloc] initWithName:@"my_wave" andProtectionKey:@"320ijeakdlakda23"];
    
    NSObject *object = [ecd objectForKey:@"Hello"];
   
    if(object == nil){
        [ecd setObject:@"World" forKey:@"Hello"];
        [ecd forceStore];
        NSLog(@"Storing Object: \"World\" for key \"Hello\"");
    }else{
        NSLog(@"Got Stored Object: %@",object);
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
