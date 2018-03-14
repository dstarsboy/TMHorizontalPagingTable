//
//  HorizontalPagingTableView.swift
//  HorizontalPagingTableViewDemo
//
//  Created by Travis Ma on 3/8/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

protocol HorizontalPagingTableViewDelegate {
    func horizontalPagingTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, dataIndex: Int) -> UITableViewCell
    
}

class HorizontalPagingTableView: UIView {
    let container = UIView()
    let pageControl = UIPageControl()
    let pageControlHeight: CGFloat = 37
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pages = [UIViewController]()
    var currentIndex = 0
    var pendingIndex: Int?
    var delegate: HorizontalPagingTableViewDelegate?
    var itemHeight: CGFloat = 0
    var itemsPerPage = 0
    var pageCount = 0
    var totalItemCount = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(container)
        self.addSubview(pageControl)
        container.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        pageControl.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: pageControlHeight).isActive = true
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .darkGray
        container.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        pageControl.addTarget(self, action: #selector(self.pageControlValueChanged), for: .valueChanged)
        self.layoutIfNeeded()
    }
    
    func setup(viewController: UIViewController, totalItemCount: Int, itemHeight: CGFloat, delegate: HorizontalPagingTableViewDelegate) {
        self.delegate = delegate
        self.itemHeight = itemHeight
        self.totalItemCount = totalItemCount
        viewController.addChildViewController(pageViewController)
        container.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        pageViewController.view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        pageViewController.delegate = self
        pageViewController.dataSource = self
        self.layoutIfNeeded()
        itemsPerPage = Int(floor(container.frame.height / itemHeight))
        pageCount = Int(ceil(Double(totalItemCount) / Double(itemsPerPage)))
        for i in 0 ..< pageCount {
            let vc = UITableViewController()
            vc.tableView.delegate = self
            vc.tableView.dataSource = self
            vc.tableView.isScrollEnabled = false
            vc.tableView.tag = i
            vc.tableView.separatorStyle = .none
            vc.tableView.allowsSelection = false
            pages.append(vc)
        }
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        pageControl.numberOfPages = pageCount
    }
    
    @objc func pageControlValueChanged() {
        if pageControl.currentPage > currentIndex {
            pageViewController.setViewControllers([pages[pageControl.currentPage]], direction: .forward, animated: true, completion: nil)
        } else {
            pageViewController.setViewControllers([pages[pageControl.currentPage]], direction: .reverse, animated: true, completion: nil)
        }
        currentIndex = pageControl.currentPage
    }
    
}

extension HorizontalPagingTableView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count - 1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.index(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let pendingIndex = pendingIndex {
                currentIndex = pendingIndex
                pageControl.currentPage = currentIndex
            }
        }
    }
    
}

extension HorizontalPagingTableView: UITableViewDelegate, UITableViewDataSource {
    
    func calculateItemCount(forTableIndex tableIndex: Int) -> Int {
        if tableIndex == pageCount - 1 {
            return Int(Float(totalItemCount).truncatingRemainder(dividingBy: Float(itemsPerPage)))
        } else {
            return itemsPerPage
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculateItemCount(forTableIndex: tableView.tag)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = delegate else {
            preconditionFailure()
        }
        var dataIndex = indexPath.row
        if tableView.tag > 0 {
            dataIndex += (tableView.tag * itemsPerPage)
        }
        return delegate.horizontalPagingTableView(tableView, cellForRowAt: indexPath, dataIndex: dataIndex)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
}
