//
//  TWTwitterAccount.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTwitterAccount.h"

@implementation TWTwitterAccount

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"Username : %@ HandlerName : %@",self.username,self.handlerName];
}

@end
