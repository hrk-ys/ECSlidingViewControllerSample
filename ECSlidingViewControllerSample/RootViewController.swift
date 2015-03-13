//
//  ViewController.swift
//  ECSlidingViewControllerSample
//
//  Created by Hiroki Yoshifuji on 2015/03/12.
//  Copyright (c) 2015年 Hiroki Yoshifuji. All rights reserved.
//

import UIKit

class RootViewController: ECSlidingViewController {

    var animationController = AnimationController()
    
    var panGesture2: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        panGesture2 = UIPanGestureRecognizer(target: self, action: "panGesture:")
        
        self.topViewController.view.addGestureRecognizer(panGesture2!)
       
        self.delegate = animationController
        
//        self.topViewAnchoredGesture = .Tapping | .Custom
        self.topViewAnchoredGesture = .Tapping | .Panning
//        self.customAnchoredGestures = [panGesture]
    }
    
    
    override func viewDidAppear(animated: Bool) {
        println("Root viewDidAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func setupShadow(vc: UIViewController) {
        let layer = vc.view.layer;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.80
        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {

        println("panGesture : \(recognizer)")
        var location = recognizer.translationInView(recognizer.view!)
        var velocity = recognizer.velocityInView(recognizer.view!)
        
        // どれくらい遷移したかを 0 〜 1で数値化
        var progress = fabs(max(0, location.x) / (recognizer.view!.bounds.size.width * 1.0));
        progress = min(1.0, max(0.0, progress));
        var progress2 = fabs(velocity.x / (recognizer.view!.bounds.size.width * 1.0));
        progress2 = min(1.0, max(0.0, progress2));
        
        // 次の画面が設定してなければ処理は継続しない
        
        if (recognizer.state == .Began) {
            // 左へのスワイプのみ
            
            var isMovingRight:Bool = velocity.x > 0;
            
            if (self.currentTopViewPosition == .Centered && isMovingRight) {
                self.anchorTopViewToRightAnimated(true)
            } else if (self.currentTopViewPosition == .Centered && !isMovingRight) {
                self.anchorTopViewToLeftAnimated(true)
            } else if (self.currentTopViewPosition == .AnchoredLeft) {
                self.resetTopViewAnimated(true)
            } else if (self.currentTopViewPosition == .AnchoredRight) {
                self.resetTopViewAnimated(true)
            }
            
        }
        else if (recognizer.state == .Changed) {
            
            // 変化量を通知させる
            self.animationController.interactiveTransition.updateInteractiveTransition(progress)
        }
        else if (recognizer.state == .Ended || recognizer.state == .Cancelled) {
            // 終了かキャンセルか
                if (progress > 0.5 || progress2 == 1) {
                    self.animationController.interactiveTransition.finishInteractiveTransition()
                }
                else {
                    self.animationController.interactiveTransition.cancelInteractiveTransition()
                }
        }
    }
}


class AnimationController: NSObject, ECSlidingViewControllerDelegate  {
    
    var operation:ECSlidingViewControllerOperation = .None
    var slidingViewController:ECSlidingViewController?
    var interactiveTransition:UIPercentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
    
    func slidingViewController(slidingViewController: ECSlidingViewController!, animationControllerForOperation operation: ECSlidingViewControllerOperation, topViewController: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        
        self.operation = operation
        self.slidingViewController = slidingViewController
        return self
    }
    
    func slidingViewController(slidingViewController: ECSlidingViewController!, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning!) -> UIViewControllerInteractiveTransitioning! {
        return nil //self
    }
    
    func slidingViewController(slidingViewController: ECSlidingViewController!, layoutControllerForTopViewPosition topViewPosition: ECSlidingViewControllerTopViewPosition) -> ECSlidingViewControllerLayout! {
        
        return self
    }
    
}

extension AnimationController: ECSlidingViewControllerLayout {
    
    func slidingViewController(slidingViewController: ECSlidingViewController!, frameForViewController viewController: UIViewController!, topViewPosition: ECSlidingViewControllerTopViewPosition) -> CGRect {
       
        let frame = slidingViewController.view.frame
        let width = CGRectGetWidth(frame)
        
        switch viewController {
        case slidingViewController.topViewController:
            
            switch topViewPosition {
            case .Centered:      return CGRectInfinite
            case .AnchoredLeft:  return CGRectOffset(frame, -width / 2, 0)
            case .AnchoredRight: return CGRectOffset(frame, width * 3 / 4, 0)
            default: return CGRectInfinite
            }
            
        case slidingViewController.underLeftViewController:
            switch topViewPosition {
            case .Centered:      return CGRectOffset(frame, -width / 3, 0)
            default: return CGRectInfinite
            }
            
        case slidingViewController.underRightViewController:
            switch topViewPosition {
            case .Centered:      return CGRectOffset(frame, width, 0)
            default: return CGRectInfinite
            }
            
        default: return CGRectInfinite
        }
       
    }
}


extension AnimationController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController  = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView     = transitionContext.containerView()
        
        
        let fromViewInitialFrame = transitionContext.initialFrameForViewController(fromViewController)
        var fromViewFinalFrame   = transitionContext.finalFrameForViewController(fromViewController)
        
        var toViewInitialFrame = transitionContext.initialFrameForViewController(toViewController)
        let toViewFinalFrame   = transitionContext.finalFrameForViewController(toViewController)
        
       
        switch (self.operation) {
        case .AnchorRight: // 右へスワイプする
            println("animateTransition Right")
            toViewInitialFrame = self.slidingViewController(self.slidingViewController, frameForViewController: toViewController, topViewPosition: .Centered)
            containerView.insertSubview(toViewController.view, belowSubview:fromViewController.view)
            
        case .AnchorLeft: // 左へスワイプする
            println("animateTransition Left")
            toViewInitialFrame = self.slidingViewController(self.slidingViewController, frameForViewController: toViewController, topViewPosition: .Centered)
            containerView.addSubview(toViewController.view)
            
        case .ResetFromRight: // 右にスワイプ状態から戻る
            println("animateTransition Right Back")
            fromViewFinalFrame = self.slidingViewController(self.slidingViewController, frameForViewController: fromViewController, topViewPosition: .Centered)
            containerView.addSubview(toViewController.view)
            
        case .ResetFromLeft: // 左にスワイプ状態から戻る
            println("animateTransition Left Back")
            fromViewFinalFrame = self.slidingViewController(self.slidingViewController, frameForViewController: fromViewController, topViewPosition: .Centered)
            containerView.insertSubview(toViewController.view, belowSubview:fromViewController.view)
            
        default: containerView.insertSubview(toViewController.view, belowSubview:fromViewController.view)
        }
        
        fromViewController.view.frame = fromViewInitialFrame
        toViewController.view.frame = toViewInitialFrame
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration,
            animations: { () -> Void in
                
                UIView.setAnimationCurve(.Linear)
                
                fromViewController.view.frame = fromViewFinalFrame;
                toViewController.view.frame   = toViewFinalFrame;
                
            }, completion: { (finished:Bool) -> Void in
                
                if transitionContext.transitionWasCancelled() {
                    fromViewController.view.frame = fromViewInitialFrame
                    toViewController.view.frame   = toViewInitialFrame
                    
                } else {
                    fromViewController.view.frame = fromViewFinalFrame;
                    toViewController.view.frame   = toViewFinalFrame;
                    
                }
                
                transitionContext.completeTransition(transitionContext.transitionWasCancelled())
        })
    }

}

class InteractiveController : ECPercentDrivenInteractiveTransition {

    /*
    - (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    topViewController.view.userInteractionEnabled = NO;
    
    if (_isInteractive) {
    UIViewController *underViewController = [transitionContext viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
    CGRect underViewInitialFrame = [transitionContext initialFrameForViewController:underViewController];
    CGRect underViewFinalFrame   = [transitionContext finalFrameForViewController:underViewController];
    UIView *containerView = [transitionContext containerView];
    CGFloat finalLeftEdge = CGRectGetMinX([transitionContext finalFrameForViewController:topViewController]);
    CGFloat initialLeftEdge = CGRectGetMinX([transitionContext initialFrameForViewController:topViewController]);
    CGFloat fullWidth = fabsf(finalLeftEdge - initialLeftEdge);
    
    CGRect underViewFrame;
    if (CGRectIsEmpty(underViewInitialFrame)) {
    underViewFrame = underViewFinalFrame;
    } else {
    underViewFrame = underViewInitialFrame;
    }
    
    underViewController.view.frame = underViewFrame;
    
    [containerView insertSubview:underViewController.view belowSubview:topViewController.view];
    
    self.positiveLeftToRight = initialLeftEdge < finalLeftEdge;
    self.fullWidth           = fullWidth;
    } else {
    [self.defaultAnimationController animateTransition:transitionContext];
    }
    }
*/
}