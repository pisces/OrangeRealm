//
//  ViewController.swift
//  OrangeRealm
//
//  Created by hh963103@gmail.com on 04/23/2017.
//  Copyright (c) 2017 hh963103@gmail.com. All rights reserved.
//

import UIKit
import OrangeRealm

class ViewController: UITableViewController {
    
    // MARK: - Constants
    
    private let titles: [String] = ["Add New SampleObject"]
    
    // MARK: - Properties
    
    private var result: RealmQueryResult<SampleObject>?
    
    // MARK: - Overridden: UITableViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        result = SampleRealmManager.shared.query("id > 0", sortProperty: "id", ascending: false)
            .set(section: 1)
            .changed({ [weak self] (section, deletions, insertions, modifications) in
                guard let weakSelf = self else {return}
                
                weakSelf.tableView.beginUpdates()
                weakSelf.tableView.deleteRows(at: deletions, with: .none)
                weakSelf.tableView.insertRows(at: insertions, with: .none)
                weakSelf.tableView.reloadRows(at: modifications, with: .none)
                weakSelf.tableView.endUpdates()
            })
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else {return titles.count}
        guard let objects = result?.objects else {return 0}
        return objects.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else {
            cell.textLabel?.text = titles[indexPath.row]
            return
        }
        guard let object = result?.objects[indexPath.row] else {return}
        
        cell.textLabel?.text = object.name
    }
    
    // MARK: - UITableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            add()
        case 1:
            guard let object = result?.objects[indexPath.row] else {return}
            delete(object: object)
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func add() {
        let objects: [SampleObject] = SampleRealmManager.shared.objects("id > 0", sortProperty: "id", ascending: false)
        let id = objects.first == nil ? 1 : objects.first!.id + 1
        
        try? SampleRealmManager.shared.transaction { (realm) in
            realm.add(SampleObject(id: id, name: "SampleObject \(id)"))
        }
    }
    
    private func delete(object: SampleObject) {
        try? SampleRealmManager.shared.transaction { (realm) in
            realm.delete(object)
        }
    }
}

