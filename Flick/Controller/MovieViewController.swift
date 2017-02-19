//
//  MovieViewController.swift
//  Flick
//
//  Created by Nguyen Trong Khoi on 2/14/17.
//  Copyright © 2017 Nguyen Trong Khoi. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast_Swift
class MovieViewController: UIViewController  {

    @IBOutlet weak var moviesTableView: UITableView!
    let refeshcontrol = UIRefreshControl()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemsList = [[String : AnyObject]] ()
    var moviceItems = [Int : Movie]()
    var lstTitle: [String] = []
    var seachData = [Int : Movie]()
    
    
    var url: URL?
    var  errorView: UIView?
    var filtered:[String] = []
    
    var searchActive : Bool = false
    
       override open func viewDidLoad(){
        
         url  = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        fetchItemsList()
        
        refeshcontrol.addTarget(self, action: #selector(MovieViewController.fetchItemsList), for: UIControlEvents.valueChanged)
        moviesTableView.addSubview(refeshcontrol)
        createNetworkErrorView()
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moviedetailSegue") {
            let detailVC: MovieDetailViewController = segue.destination as! MovieDetailViewController
            if let indexpath = moviesTableView.indexPathForSelectedRow{
                detailVC.movie = self.moviceItems[indexpath.section]!
            }

        }
     }
    
     func fetchItemsList(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Movie.getMoviesList(link: url! , callback: { (items) -> (Void) in
            self.itemsList += items
            DispatchQueue.main.async(execute: {
                self.moviesTableView?.reloadData()
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
    
      
    
    fileprivate func createNetworkErrorView()
    {
        let errorViewFrame : CGRect = CGRect(x: 0, y: 60, width: 320, height: 50)
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
}


extension MovieViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = moviesTableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MovieCell
        cell.resetCell()
        if(searchActive){
            if let seachItem = seachData[indexPath.section]{
                 cell.setupCell(movieItem: seachItem)
            }
        } else {
            if let movie = moviceItems[indexPath.section]{
                cell.setupCell(movieItem: movie)
            }else{
                Movie.object(at: (indexPath.section), fromList: itemsList, callback: { (movie, index) in
                    self.moviceItems[index] = movie
                    self.lstTitle.append(movie.title)
                    DispatchQueue.main.async(execute: {
                        self.moviesTableView?.reloadData()
                    })
                })
            }
        }
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.gray.cgColor
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(searchActive) {
            return seachData.count
        }
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

extension MovieViewController: UISearchBarDelegate{
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        print("searchText \(searchBar.text)")
        
    }
    
    
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    
        var i: Int = 0
        var j: Int = 0

        seachData.removeAll()
        for item in lstTitle{
            if item.lowercased().range(of:searchText.lowercased()) != nil{
                seachData[j] = moviceItems[i]
                j += 1
            }
            i += 1
        }
        
        if(seachData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.moviesTableView.reloadData()
        
        
        
        
    }

    
}

