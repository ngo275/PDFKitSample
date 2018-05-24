//
//  ViewController.swift
//  PDFKitSample
//
//  Created by ShuichiNagao on 2018/05/25.
//  Copyright © 2018 Shuichi Nagao. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView?.document = getDocument()
        pdfView?.backgroundColor = .lightGray
        pdfView?.autoScales = true
        pdfView?.displayMode = .singlePageContinuous
        
        pdfView.usePageViewController(true)
        pdfView.displaysAsBook = true
        createMenu()
        
        NotificationCenter.default.addObserver(forName: .PDFViewAnnotationHit, object: nil, queue: nil, using: notified)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func notified(notification: Notification) {
        print("called: \(notification.userInfo)")
    }

    private func getDocument() -> PDFDocument? {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else {
            print("failed to get path.")
            return nil
        }
        let pdfURL = URL(fileURLWithPath: path)
        let document = PDFDocument(url: pdfURL)
        return document
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(highlight(_:)) {
            return true
        }
        return false
    }

    private func find(text: String) {
        let selections = pdfView.document?.findString(text, withOptions: .caseInsensitive)
        guard let page = selections?.first?.pages.first else { return }
        selections?.forEach { selection in
            let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
    }
    
    private func createMenu() {
        let highlightItem = UIMenuItem(title: "Highlight", action: #selector(highlight(_:)))
        UIMenuController.shared.menuItems = [highlightItem]
    }
    
    @objc private func highlight(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        let selections = currentSelection.selectionsByLine()
        guard let page = selections.first?.pages.first else { return }
        
        guard let pageNumber = pdfView.document?.index(for: page) else { return }
        print("現在のページ数: \(pageNumber + 1)")
        print(currentSelection.string)
        
        selections.forEach { selection in
            let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)

            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
        
        pdfView.clearSelection()
    }
}

