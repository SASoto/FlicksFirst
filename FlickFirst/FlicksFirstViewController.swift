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
    @IBOutlet weak var tableView: UITableView!
    
    var selectedBackgroundView: UIView?
    
    var isMoreDataLoading = false
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var filteredData: [String]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let titleLabel = UILabel()
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        shadow.shadowOffset = CGSizeMake(2,2);
        shadow.shadowBlurRadius = 4;
            
        let titleText = NSAttributedString(string: "Flicks", attributes: [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(25),
                NSForegroundColorAttributeName : UIColor(red: 0.97, green: 0.02, blue: 0.27, alpha: 0.8),
                NSShadowAttributeName : shadow
                ])
            
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        self.navigationItem.title = "Back"
        if let navigationBar = navigationController?.navigationBar
        {
            navigationBar.tintColor = UIColor(red: 0.97, green: 0.02, blue: 0.27, alpha: 0.8)
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        var scrollView: UIScrollView!
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
                            
                            //self.tableView.reloadData()
                        
                            
                    }
                }
                
                self.tableView.reloadData()
            });
        
        task.resume()
        
        loadDataFromNetwork(session, request: request) /*---*/
    
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
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        cell.selectedBackgroundView = backgroundView
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String
        {
            let imageUrl = NSURL(string:baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        else
        {
            cell.posterView.image = nil
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        print("row \(indexPath.row)")
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url2 = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let myRequest = NSURLRequest(URL: url2!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
<<<<<<< HEAD
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler:
            {
                (data, response, error) in
                if let data = data
                {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                            refreshControl.endRefreshing()
                    }
                    
                }
                
=======
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler:
            { (data, response, error) in
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
>>>>>>> a29d2b2eb9fc7adda3ff8a748fcd579f4de77d1d
        });
        task.resume()
        
    }

    func loadDataFromNetwork(session: NSURLSession!, request: NSURLRequest!) /*---*/
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler:
            {
                (data, response, error) in
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            });
        task.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

}
