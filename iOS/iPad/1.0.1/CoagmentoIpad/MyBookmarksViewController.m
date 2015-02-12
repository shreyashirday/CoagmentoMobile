//
//  MyBookmarksViewController.m
//  CoagmentoIOS
//
//  Created by Josue Reyes on 8/23/13.
//  Copyright (c) 2013 Josue Reyes. All rights reserved.
//

#import "MyBookmarksViewController.h"
#import "BookmarkItem.h"
#import "BookmarkObject.h"
#import "VistedObject.h"
#import "VistedItem.h"
#import "VisitedCollection.h"
#import "VisitedCollectionCell.h"
#import "BookmarkedCollection.h"
#import "BookmarkedCollectionCell.h"

@interface MyBookmarksViewController ()

@end

@implementation MyBookmarksViewController
@synthesize ProjID, ProjTitle, detailItem, segment, visitedCollection, bookmarkedCollection;



-(id)getProjTitle{
    [self setProjTitle:[detailItem objectAtIndex:1]];
    return ProjTitle;
}

-(id)getProjID{
    [self setProjID:[detailItem objectAtIndex:0]];
    return ProjID;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchEntries];
    
  
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parser

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@ found a %@ element", self, elementName);
    
    //IN TABLE VIEW
    if(segment.selectedSegmentIndex==0){
        
        if ([elementName isEqual:@"webpageList"]) {
            // When we find an project item, create an instance of projectItem
            visited = [[VistedObject alloc] init];
            
            // Set up its parent as ourselves so we can regain control of the parser
            [visited setParentParserDelegate:self];
            
            // Turn the parser to the RSSItem
            [parser setDelegate:visited];
            
        }
    }
    
    
    
    if(segment.selectedSegmentIndex==1){
  
    if ([elementName isEqual:@"bookmarkList"]) {
        // When we find an project item, create an instance of projectItem
        bookmark = [[BookmarkObject alloc] init];
        
        // Set up its parent as ourselves so we can regain control of the parser
        [bookmark setParentParserDelegate:self];
        
        // Turn the parser to the RSSItem
        [parser setDelegate:bookmark];
        
        }
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
    
    
}

#pragma mark Connection

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the incoming chunk of data to the container we are keeping
    // The data always comes in the correct order
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    
    
    // Create the parser object with the data received from the web service
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    // Give it a delegate
    [parser setDelegate:self];
    
    // Tell it to start parsing - the document will be parsed and
    // the delegate of NSXMLParser will get all of its delegate messages
    // sent to it before this line finishes execution - it is blocking
  //  NSString *string = [[NSString alloc] initWithData:xmlData encoding: NSUTF8StringEncoding];
   // NSLog(string);
    
    [parser parse];
    
    // Get rid of the XML data as we no longer need it
    xmlData = nil;
    
    // Get rid of the connection, no longer need it
    connection = nil;
    
    // Reload the table.. for now, the table will be empty. MUST LOAD TABLE!!
    if(segment.selectedSegmentIndex==0){
    [self.visitedCollection reloadData];
    }
    
    if(segment.selectedSegmentIndex==1){
    [self.bookmarkedCollection reloadData];
    }

    
}

- (void)connection:(NSURLConnection *)conn
  didFailWithError:(NSError *)error
{
    // Release the connection object, we're done with it
    connection = nil;
    
    // Release the xmlData object, we're done with it
    xmlData = nil;
    
    // Grab the description of the error object passed to us
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",
                             [error localizedDescription]];
    
    // Create and show an alert view with this error displayed
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)fetchEntries
{
    // Create a new data container for the stuff that comes back from the service
   
    
    xmlData = [[NSMutableData alloc] init];
    
    // Construct a URL that will ask the service for what you want -
    // note we can concatenate literal strings together on multiple
    // lines in this way - this results in a single NSString instance
    
    
    
    NSString *urlString =[[NSString alloc] initWithFormat:@"http://coagmento.org/mobile/getBookmarks.php?projID=%@",[self getProjID]];
    NSString *urlStringg =[[NSString alloc] initWithFormat:@"http://coagmento.org/mobile/getVisited.php?projID=%@", [self getProjID]];
    
    if(segment.selectedSegmentIndex==0){
        NSURL *url = [NSURL URLWithString:urlStringg];
        
        
        NSLog(@"Fetch Data");
        
        // Put that URL into an NSURLRequest
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        // Create a connection that will exchange this request for data from the URL
        connection = [[NSURLConnection alloc] initWithRequest:req
                                                     delegate:self
                                             startImmediately:YES];
    }

    
    
    if(segment.selectedSegmentIndex==1){
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    NSLog(@"Fetch Data");
    
    // Put that URL into an NSURLRequest
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create a connection that will exchange this request for data from the URL
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
    }
    
    
}


#pragma mark - Collection view data source

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if(segment.selectedSegmentIndex==0){

    
    VisitedCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    
    VistedItem *item = [[visited visitedItems] objectAtIndex:[indexPath row]];
    UIImage* google = [UIImage imageNamed:@"visited.png"];
    [[cell VisitedIcon] setImage:google];
    [[cell title] setText:[item visTitle]];
    [[cell URL] setText:[item visURL]];
    [[cell Date] setText:[item visDate]];
    [[cell Time] setText:[item visTime]];
        
        return cell;
        
    }
    
    
    if(segment.selectedSegmentIndex==1){

        BookmarkedCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        BookmarkItem *item = [[bookmark bookmarkItems] objectAtIndex:[indexPath row]];
        
        UIImage* bing = [UIImage imageNamed:@"bookmarked.png"];
        [[cell BookmarkIcon] setImage:bing];
        [[cell title] setText:[item bmTitle]];
        [[cell URL] setText:[item bmURL]];
        [[cell Date] setText:[item bmDate]];
        [[cell Time] setText:[item bmTime]];
        

        return cell;
        
    } else
    
    /*
     [[cell Query] setText:[item searchQuery]];
     [[cell Date] setText:[item searchDate]];
     
     UIImage* google = [UIImage imageNamed:@"1google.png"];
     UIImage* bing = [UIImage imageNamed:@"2bing.png"];
     UIImage* wiki = [UIImage imageNamed:@"4wikipedia.png"];
     UIImage* yahoo = [UIImage imageNamed:@"3yahoo.png"];
     
     NSString *googleString = @"google";
     NSString *bingString = @"bing";
     NSString *wikiString = @"wikipedia";
     NSString *yahooString = @"yahoo";
     
     
     
     if ([googleString isEqualToString:[item searchSource]]) {
     [[cell SearchIcon] setImage:google];
     }
     
     if ([bingString isEqualToString:[item searchSource]]) {
     [[cell SearchIcon] setImage:bing];
     }
     
     if ([wikiString isEqualToString:[item searchSource]]) {
     [[cell SearchIcon] setImage:wiki];
     }
     
     if ([yahooString isEqualToString:[item searchSource]]) {
     [[cell SearchIcon] setImage:yahoo];
     }
     
     
     
     */
    
    NSLog(@"WRITING SEARCH CELL");
    
    return nil;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
     if(segment.selectedSegmentIndex==0){
        
        return [[visited visitedItems] count];
        
    }
     if(segment.selectedSegmentIndex==1){
         
         return [[bookmark bookmarkItems]count];
     }
    
    else
        return 0;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
       selectedPhotoIndex = [indexPath row];
       [self segue];
    
    
}



#pragma mark - Table view data source
-(void)viewWillAppear:(BOOL)animated{
    
    [self getProjID];
    [super viewDidLoad];
    [self fetchEntries];
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    if (self.segment.selectedSegmentIndex == 0) {
        NSLog(@"SEGMENT EQUALS 0");
       
        [self.visitedCollection reloadData];
        
    }
    if (self.segment.selectedSegmentIndex == 1) {
        NSLog(@"SEGEMENT EQUALS 1");
       
        [self.bookmarkedCollection reloadData];
        
    }
    
    
}




- (IBAction)segmentChanged {
   
    if (self.segment.selectedSegmentIndex == 0) {
        //reload data with PROJECTS
        [self fetchEntries];
        [self.visitedCollection reloadData];
        bookmarkedCollection.hidden = YES;
        visitedCollection.hidden = NO;

        
    }
    
    if (self.segment.selectedSegmentIndex == 1){
        //reload data with COLLABORATORS
        [self fetchEntries];
        [self.bookmarkedCollection reloadData];
        visitedCollection.hidden = YES;
        bookmarkedCollection.hidden = NO;
        
   
    }
    
    
    
    
}

-(void)segue{
    
    [self performSegueWithIdentifier:@"toBookmarkWebView" sender:self];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (segment.selectedSegmentIndex == 0) {
        
       
        
        VistedItem *item = [[visited visitedItems] objectAtIndex:selectedPhotoIndex];
        NSString *url = [item getURL];
        
        [segue.destinationViewController setDetailItem:url];
    }


    if (segment.selectedSegmentIndex == 1) {
    
        BookmarkItem *item = [[bookmark bookmarkItems] objectAtIndex:selectedPhotoIndex];
        NSString *url = [item getURL];
        
        [segue.destinationViewController setDetailItem:url];
    }
    
    
    
    
}





@end