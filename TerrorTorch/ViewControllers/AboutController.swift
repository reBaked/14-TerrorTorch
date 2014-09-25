//
//  AboutController.swift
//  TerrorTorch
//
//  Created by Eric Walker on 9/24/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class AboutController: UIViewController {

    @IBOutlet var aboutTitle :UILabel!
    @IBOutlet var copyright :UILabel!
    @IBOutlet var contributors :UILabel!
    @IBOutlet var disclaimer :UILabel!
    @IBOutlet var footer :UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.view.setTranslatesAutoresizingMaskIntoConstraints(false)

        aboutTitle.attributedText = self.getNavTitle("Terror", second: "Torch")

        var attrString = NSMutableAttributedString(attributedString: copyright.attributedText)
        var range:NSRange = NSMakeRange(0, attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSFontAttributeName, value:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), range:range)
        attrString.endEditing()
        copyright.attributedText = attrString

        attrString = NSMutableAttributedString(string: "Mike Herrera\nAlfred Cepetta  Ben Johnson\nBobby Ren  Stephanie Methana")
        range = NSMakeRange(0, attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSFontAttributeName, value:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), range:range)
        attrString.endEditing()
        contributors.attributedText = attrString


        attrString = NSMutableAttributedString(attributedString: disclaimer.attributedText)
        range = NSMakeRange(0, attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSFontAttributeName, value:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), range:range)
        attrString.endEditing()
        disclaimer.attributedText = attrString

        attrString = NSMutableAttributedString(attributedString: footer.attributedText)
        range = NSMakeRange(0, attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSFontAttributeName, value:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), range:range)
        attrString.addAttribute(NSForegroundColorAttributeName, value:COLOR_RED, range:range)
        attrString.endEditing()
        footer.attributedText = attrString

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismiss(sender: UITapGestureRecognizer) {

        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            dismissViewControllerAnimated(true, completion: { //Dismiss motion detector
            });
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
