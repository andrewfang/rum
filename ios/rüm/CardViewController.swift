//
//  CardViewController.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/12/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

protocol CardViewControllerDelegate: class {
    func userDidCloseCardView(cardView: CardViewController)
}

class CardViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var currentPage = 0
    var pages: [CardContent] = []
    var pageViewController: UIPageViewController?
    var delegate: CardViewControllerDelegate?
    var closeable = true {
        didSet {
            if self.closeButton != nil {
                self.closeButton.hidden = !closeable
            }
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!
    
    // NOTE: - the pages variable needs to be set *before* load. This likely won't be an issue, since
    // the cards should be loaded via an embed segue
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        self.pageViewController?.dataSource = self
        
        let firstController = self.viewControllerAtIndex(self.currentPage)
        self.pageViewController?.setViewControllers([firstController!], direction: .Forward, animated: false, completion: nil)
        self.pageViewController?.delegate = self
        
        self.pageNumberLabel.text = "\(self.currentPage + 1) of \(self.pages.count)"
        self.pageControl.currentPage = self.currentPage
        self.pageControl.numberOfPages = self.pages.count
        if self.currentPage == 0 {
            self.previousButton.alpha = 0
        }
        
        // leave space for page dots and prev/next buttons (40pt) and
        // close button at top (40pt)
        let pageViewTop: CGFloat = 40
        let pageViewBottom: CGFloat = 40
        
        if self.pages.count <= 1 {
            self.previousButton.hidden = true
            self.nextButton.hidden = true
            self.pageControl.hidden = true
        }
        
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.rgb(109, 135, 172).CGColor
        self.view.layer.shadowOffset = CGSizeMake(0.0, 4.0)
        self.view.layer.shadowOpacity = 0.13
        
        self.pageViewController?.view.frame = CGRectMake(0, pageViewTop, self.view.frame.size.width, self.view.frame.size.height - (pageViewTop + pageViewBottom))
        
        // set it to itself after the view loads
        // so we can run the setter again
        self.closeable = self.closeable ? true : false
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)
        
        self.view.bounceSlideUpIn(0.6, delay: 0.8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Close button
    @IBAction func handleClose(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.userDidCloseCardView(self)
        }
    }
    
    // MARK: - Next button
    @IBAction func handleNext(sender: AnyObject) {
        if let vc = self.viewControllerAtIndex(self.currentPage + 1) {
            self.pageViewController?.setViewControllers([vc], direction: .Forward, animated: true, completion: nil)
            updatePage(vc)
        }
    }
    
    // MARK: - Previous button
    @IBAction func handlePrevious(sender: AnyObject) {
        if let vc = self.viewControllerAtIndex(self.currentPage - 1) {
            self.pageViewController?.setViewControllers([vc], direction: .Reverse, animated: true, completion: nil)
            updatePage(vc)
        }
    }
    
    // MARK: - Page data
    // before
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! CardContentViewController
        let i = contentVC.pageIndex
        if i == 0 {
            return nil
        } else {
            return self.viewControllerAtIndex(i! - 1)
        }
    }
    
    // after
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! CardContentViewController
        let i = contentVC.pageIndex
        if i == (self.pages.count - 1) {
            return nil
        } else {
            return self.viewControllerAtIndex(i! + 1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let p = self.pageViewController!.viewControllers!.first as! CardContentViewController
            updatePage(p)
        }
    }
    
    private func updatePage(contentVC: CardContentViewController) {
        let index = contentVC.pageIndex!
        pageControl.currentPage = index
        self.currentPage = index
        
        // page buttons are hidden if there's only one page, so we don't need
        // to worry about that case
        let nextAlpha: CGFloat = index == pages.count - 1 ? 0.0 : 1.0
        let prevAlpha: CGFloat = index == 0 ? 0.0 : 1.0
        
        UIView.animateWithDuration(0.6,
            animations: {
                self.previousButton.alpha = prevAlpha
                self.nextButton.alpha = nextAlpha
        })
        
        self.pageNumberLabel.text = "\(index + 1) of \(pages.count)"
    }

    func viewControllerAtIndex(index: Int) -> CardContentViewController? {
        if self.pages.count == 0 || index >= self.pages.count {
            return nil
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CardContentViewController") as! CardContentViewController
        vc.load(pages[index])
        vc.pageIndex = index
        vc.pageCount = self.pages.count
        return vc
    }
    
    func runCloseAnimation(completion: ((Bool) -> Void)?) {
        self.view.fallOut(0.8, delay: 0.0, completion: completion)
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

class CardContent {
    var headerText: String?
    var contentText: String?
    
    init(header: String, content: String) {
        self.headerText = header
        self.contentText = content
    }
}

class CardContentViewController: UIViewController {
    
    var content: CardContent?
    var pageIndex: Int?
    var pageCount: Int?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        if content != nil {
            self.headerLabel.text = self.content!.headerText?.uppercaseString
            self.contentLabel.text = self.content!.contentText
        }
    }
    
    func load(content: CardContent) {
        self.content = content
    }
    
    
}