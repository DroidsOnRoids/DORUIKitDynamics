//
//  FirstViewController.swift
//  DoRDynamics
//
//  Created by AppStarter on 10.01.2016.
//  Copyright © 2016 AppStarter. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    let numberOfItemsInSubmenus = [9, 5, 3]
    
    @IBOutlet var mainMenuButtons: [UIButton]!
    var submenuButtons = [[UIButton]]()
    
    //------------------------------------------------------------------
    var mainAnimator: UIDynamicAnimator!
    var subAnimator: UIDynamicAnimator!
    
    var isSubmenuPresented: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainMenu()
    }
    
    func setupMainMenu() {
        isSubmenuPresented = false
        
        var i = 0
        
        for button in mainMenuButtons {
            button.layer.cornerRadius = CGRectGetWidth(button.frame)/2
            i += 1
        }
        
        for submenuNumber in 1...numberOfItemsInSubmenus.count {
            var buttons = [UIButton]()
            for itemNumber in 1...numberOfItemsInSubmenus[submenuNumber - 1] {
                let button = UIButton(type: UIButtonType.Custom)
                button.tag = submenuNumber * 10 + itemNumber
                button.setTitle(String(button.tag), forState: UIControlState.Normal)
                button.frame = CGRectMake(500.0, 0.0, 50.0, 50.0)
                button.addTarget(self, action: "submenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                button.layer.cornerRadius = CGRectGetWidth(button.frame)/2
                button.backgroundColor = UIColor.brownColor()
                
                view.addSubview(button)
                buttons.append(button)
            }
            submenuButtons.append(buttons)
        }
        
        //------------------------------------------------------------------
        mainAnimator = UIDynamicAnimator(referenceView: view)
        subAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    @IBAction func mainButtonPressed(button: UIButton) {
        print("Pressed button with tag: " + "\(button.tag)")
        isSubmenuPresented == true ? dismissSubmenu(button.tag - 1) : presentSubmenuFromButton(button)
    }
    
    func presentSubmenuFromButton(buttonPressed: UIButton) {
        isSubmenuPresented = true

        startTransitionFromButton(buttonPressed)
        presentSubmenuButtons(submenuButtons[buttonPressed.tag - 1])
    }
    
    func startTransitionFromButton(buttonPressed: UIButton) {
        //------------------------------------------------------------------
        mainAnimator.removeAllBehaviors()
        
        //---------------------------
        let mainGravity = UIGravityBehavior()
        mainGravity.setAngle(CGFloat(-M_PI), magnitude: 10)

        //---------------------------
        let outScreenCollision = UICollisionBehavior()
        outScreenCollision.addBoundaryWithIdentifier("verticalOffScreenStopper",
            fromPoint: CGPointMake(-150, 0),
            toPoint: CGPointMake(-150, CGRectGetHeight(self.view.frame)))
        
        //---------------------------
        let buttonStopCollision = UICollisionBehavior()
        buttonStopCollision.translatesReferenceBoundsIntoBoundary = true
        
        for button in self.mainMenuButtons {
            mainGravity.addItem(button)

            if button != buttonPressed {
                outScreenCollision.addItem(button)
            } else {
                buttonStopCollision.addItem(button)
            }
        }
        
        //---------------------------
        let pushButton = UIPushBehavior(items: [buttonPressed], mode: UIPushBehaviorMode.Instantaneous)
        pushButton.angle = 0
        pushButton.magnitude = 5
        
        mainAnimator.addBehavior(mainGravity)
        mainAnimator.addBehavior(outScreenCollision)
        mainAnimator.addBehavior(buttonStopCollision)
        mainAnimator.addBehavior(pushButton)
    }
    
    func presentSubmenuButtons(buttonsArray: [UIButton]) {
        //------------------------------------------------------------------
        subAnimator.removeAllBehaviors()
        
        var i = 0
        for button in buttonsArray {
            let yPosition = calculateYPositionForNumberOfItems(buttonsArray.count, position: i)
            let xPosition = CGRectGetWidth(view.frame) + CGRectGetWidth(button.frame) + CGFloat(100 * i)
            button.center = CGPointMake(xPosition, yPosition);

            i += 1
        }
        
        //---------------------------
        let subGravity = UIGravityBehavior(items: buttonsArray)
        subGravity.angle = CGFloat(-M_PI)
        subGravity.magnitude = 3
        
        let buttonWidth = buttonsArray.last?.frame.width
        let xValue = view.bounds.width / 2 - (buttonWidth ?? 0) / 2
        
        //---------------------------
        let subCollision = UICollisionBehavior(items: buttonsArray)
        subCollision.addBoundaryWithIdentifier("varticalStopper",
            fromPoint: CGPointMake(xValue, 0),
            toPoint: CGPointMake(xValue, CGRectGetHeight(view.frame)))
        
        subAnimator.addBehavior(subGravity)
        subAnimator.addBehavior(subCollision)
    }
    
    func dismissSubmenu(subMenu: Int) {
        //------------------------------------------------------------------
        isSubmenuPresented = false
        subAnimator.removeAllBehaviors()
        
        for button in submenuButtons[subMenu] {
            //---------------------------
            let push = UIPushBehavior(items: [button], mode: UIPushBehaviorMode.Instantaneous)
            push.angle = CGFloat(-0.7 * M_PI) + CGFloat(arc4random_uniform(25) / 10)
            push.magnitude = 1
            
            subAnimator.addBehavior(push)
        }
        
        //---------------------------
        let subGravity = UIGravityBehavior(items: submenuButtons[subMenu])
        subGravity.angle = CGFloat(0.5 * M_PI)
        subGravity.magnitude = 5
        
        subAnimator.addBehavior(subGravity)
        
        snapMainButtonsToStartPosition()
    }

    func snapMainButtonsToStartPosition() {
        //------------------------------------------------------------------
        for button in mainMenuButtons {
            //---------------------------
            let yPosition = calculateYPositionForNumberOfItems(mainMenuButtons.count, position: button.tag - 1)
            let startPoint = CGPointMake(CGRectGetWidth(view.frame)/2, yPosition)
            let snap = UISnapBehavior(item: button, snapToPoint: startPoint)
            
            subAnimator.addBehavior(snap)
        }
        
        //---------------------------
        let dynamicBehavior = UIDynamicItemBehavior(items: mainMenuButtons)
        dynamicBehavior.resistance = 70
        
        subAnimator.addBehavior(dynamicBehavior)
    }

    func calculateYPositionForNumberOfItems(itemNumber: Int, position: Int) -> CGFloat {
        let buttonNumber = CGFloat(itemNumber - position)
        let yOffset = CGRectGetHeight(view.frame) / CGFloat(itemNumber + 1)
        return CGRectGetHeight(view.frame) - (yOffset * buttonNumber)
    }
    
    func submenuButtonPressed(button: UIButton) {
        NSLog("Pressed button with tag: %i", button.tag);
    }
}
