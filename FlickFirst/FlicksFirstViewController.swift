//
//  FlicksFirstViewController.swift
//  FlickFirst
//
//  Created by Saul Soto on 1/11/16.
//  Copyright © 2016 CodePath - Saul Soto. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksFirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{
    
    //var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        /*func refreshControlAction(refreshControl: UIRefreshControl)
        {
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }*/
        
        var scrollView: UIScrollView!
        
        /*refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        scrollView?.insertSubview(refreshControl, atIndex: 0)
        */
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler:
            {
                (dataOrNil, response, error) in
                if let data = dataOrNil
                {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary
                    {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.tableView.reloadData()
                        
                            
                    }
                }
            });
        
        task.resume()
    
        /*func loadDataFromNetwork() /*---x*/
        {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler:
                {
                    (data, response, error) in
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                });
            
            task.resume()
        }*/
        
        loadDataFromNetwork(session, request: request) /*---*/
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        /*func loadMoreData()
        {
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            
            self.data = data
            self.tableView.reloadData()
        }*/
    
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let movies = movies
        {
            return movies.count
        }
            
        else
        {
            return 0
        }
        
        //return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlicksFirstCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        //let posterPath = movie["poster_path"] as! String
        if let posterPath = movie["poster_path"] as? String
        {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string:baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        else
        {
            cell.posterView.image = nil
        }
        
        //let baseUrl = "http://image.tmdb.org/t/p/w500"
        //let imageUrl = NSURL(string:baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        //cell.posterView.setImageWithURL(imageUrl!)
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func loadDataFromNetwork(session: NSURLSession!, request: NSURLRequest!) /*---*/
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = Session.dataTaskWithRequest(request, completionHandler:
            { (data, response, error) in
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        });
        
        task.resume()
    }
    
    /*func loadMoreData()
    {
        self.isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        
        self.data = data
        self.tableView.reloadData()
    }*/
    
    /*func loadDataFromNetwork()
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = mySession.dataTaskWithRequest(request, completionHandler:
            { (data, response, error) in
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        });
        
        task.resume()
    }*/
    
    //var isMoreDataLoading = false
    //var loadingMoreView:InfiniteScrollActivityView?
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if (!isMoreDataLoading)
        {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight; -tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging)
            {
                isMoreDataLoading = true
                
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                //loadMoreData()
            }
            
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        //let language = "Swift"
        //print("Learning\(language)")
    }
    
    /*let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.hidden = true
    tableView.addSubview(loadingMoreView!)
    
    var insets = tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    tableView.contentInset = insets*/
    
    //var isMoreDataLoading = false
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class InfiniteScrollActivityView: UIView
{
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect)
    {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator()
    {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating()
    {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating()
    {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}
