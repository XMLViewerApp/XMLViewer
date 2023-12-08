//
//  SidebarViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UniformTypeIdentifiers

protocol SidebarViewControllerDelegate: AnyObject {}

class SidebarViewController: NSViewController {
    weak var delegate: SidebarViewControllerDelegate?
    
    
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
    }
}
