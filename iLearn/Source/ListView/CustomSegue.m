//
//  CustomSegue.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "CustomSegue.h"
#import "FXBlurView.h"

@implementation CustomSegue

-(void)perform {

    UIViewController* destViewController = (UIViewController*)[self destinationViewController];
    destViewController.view.backgroundColor = [UIColor clearColor];
    [destViewController setTransitioningDelegate:self];
    destViewController.modalPresentationStyle = UIModalPresentationCustom;
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:YES completion:nil];
}


//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIView *inView = [transitionContext containerView];
    UIViewController* toVC = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:fromVC.view.bounds];
    blurView.underlyingView = fromVC.view;
    blurView.tintColor = [UIColor clearColor];
    blurView.updateInterval = 1;
    blurView.blurRadius = 10.f;
    blurView.alpha = 0.f;
    blurView.frame = fromVC.view.bounds;

    [inView addSubview:blurView];
    [inView addSubview:toVC.view];

    [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    toVC.view.alpha = 0.0;

    [UIView animateWithDuration:0.25f
                     animations:^{
                         blurView.alpha = 1.0;
                         toVC.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //I will fix it later.
    //    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    //    controller.isPresenting = NO;
    //    return controller;
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end
