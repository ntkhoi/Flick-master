//
//  TopRatedViewController.swift
//  Flick
//
//  Created by Nguyen Trong Khoi on 2/18/17.
//  Copyright © 2017 Nguyen Trong Khoi. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast_Swift

class TopRatedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    let refeshcontrol = UIRefreshControl()
    
    
    @IBOutlet weak var changetableviewSegmentControl: UISegmentedControl!
    
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            changeVisibletableView(istableViewVisible: true)
        }else{
            changeVisibletableView(istableViewVisible: false)
        }
        
    }
    func changeVisibletableView(istableViewVisible : Bool)-> (Void){
        if istableViewVisible{
            tableView.isHidden = false
            collectionView.isHidden = true
        }else{
            tableView.isHidden = true
            collectionView.isHidden = false

        }
        
    }
    
    
    var itemsList = [[String : AnyObject]] ()
    var moviceItems = [Int : Movie]()
    var url: URL?
    var  errorView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        url  = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchItemsList()
        tableView.addSubview(refeshcontrol)
        
         refeshcontrol.addTarget(self, action: #selector(TopRatedViewController.fetchItemsList), for: UIControlEvents.valueChanged)
//        refeshcontrol2.addTarget(self, action: #selector(TopRatedViewController.fetchItemsList), for: UIControlEvents.valueChanged)
        changeVisibletableView(istableViewVisible: true)
    }
    
    fileprivate func createNetworkErrorView()
    {
        let errorViewFrame : CGRect = CGRect(x: 0, y: 60, width: 320, height: 30)
        errorView = UIView(frame: errorViewFrame)
        errorView?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        let errorMessage = UILabel(frame: CGRect(x: 0, y: 0, width: (errorView?.frame.width)!, height: (errorView?.frame.height)!))
        errorMessage.textColor = UIColor.white
        errorMessage.textAlignment = .center
        errorMessage.text = "network error"
        errorView?.addSubview(errorMessage)
        
        self.view.addSubview(errorView!)
        errorView?.isHidden = true
    }
    
    func fetchItemsList(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Movie.getMoviesList(link: url! , callback: { (items) -> (Void) in
            self.itemsList += items
            DispatchQueue.main.async(execute: {
                self.tableView?.reloadData()
                self.collectionView?.reloadData()
                self.refeshcontrol.endRefreshing()
                MBProgressHUD.hide(for: self.view, animated: true)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.errorView?.isHidden = true
            })
        }, callbackError: {(errorMessage) -> (Void) in
            
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.errorView?.isHidden = false
                self.refeshcontrol.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.view.makeToast(errorMessage, duration: 3.0, position: .center)
            })
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moviedetailSegue") {
            let detailVC: MovieDetailViewController = segue.destination as! MovieDetailViewController
            if let indexpath = tableView.indexPathForSelectedRow{
                detailVC.movie = self.moviceItems[indexpath.section]!
            }
            
        }
    }

    
}


extension TopRatedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MovieCell
        cell.resetCell()
        if let movie = moviceItems[indexPath.section]{
            cell.setupCell(movieItem: movie)
        }else{
            Movie.object(at: (indexPath.section), fromList: itemsList, callback: { (movie, index) in
                self.moviceItems[index] = movie
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
        }
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.gray.cgColor
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let movie = self.moviceItems[indexPath.section]
        performSegue(withIdentifier: "moviedetailSegue", sender: movie)
    }
    
    
}


extension TopRatedViewController: UICollectionViewDataSource ,UICollectionViewDelegate{
   
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
     func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    
     func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell",
                                                      for: indexPath) as! collectionViewCell
        if let movie = moviceItems[indexPath.row]{
            cell.imageView.setImageWith(URL(string: movie.imageUrl)!)
        }else{
            Movie.object(at: (indexPath.row), fromList: itemsList, callback: { (movie, index) in
                self.moviceItems[index] = movie
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            })
        }
        cell.backgroundColor = UIColor.black
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.gray.cgColor
        return cell
    }

}


