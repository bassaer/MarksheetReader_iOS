//
//  TabBarController.swift
//  MarksheetReader
//
//  Created by Nakayama on 2016/06/05.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

import UIKit
import FontAwesome_swift

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let colorKey = UIColor.whiteColor()
        let colorBg = ColorManager().mainColor()
        
        UITabBar.appearance().tintColor = colorKey
        UITabBar.appearance().barTintColor = colorBg
        
        tabBar.items![0].image = UIImage.fontAwesomeIconWithName(.PieChart, textColor: UIColor.whiteColor(), size: CGSizeMake(40,40))
        tabBar.items![0].title = "Score"
        tabBar.items![1].image = UIImage.fontAwesomeIconWithName(.PencilSquareO, textColor: UIColor.whiteColor(), size: CGSizeMake(40,40))
        tabBar.items![1].title = "Mark"
        tabBar.items![2].image = UIImage.fontAwesomeIconWithName(.Database, textColor: UIColor.whiteColor(), size: CGSizeMake(40,40))
        tabBar.items![2].title = "Data"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
