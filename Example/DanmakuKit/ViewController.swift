//
//  ViewController.swift
//  DanmakuKit
//
//  Created by qyz777 on 08/16/2020.
//  Copyright (c) 2020 qyz777. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Function demo"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Function demo of player"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = FunctionDemoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
