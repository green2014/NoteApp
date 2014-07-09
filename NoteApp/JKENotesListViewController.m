//
//  JKENotesListViewController.m
//  NoteApp
//
// All rights reserved..
//

#import "JKENotesListViewController.h"
#import "JKENotesViewController.h"
#import <Parse/Parse.h>

@interface JKENotesListViewController ()

@end

@implementation JKENotesListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Post"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Post";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [object createdAt];
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:@"title"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    cell.imageView.image = [UIImage imageNamed:@"note"];
    
    return cell;
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
    // Create a query
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // Follow relationship
    if ([PFUser currentUser]) {
        [query whereKey:@"author" equalTo:[PFUser currentUser]];
    }
    else {
        // I added this so that when there is no currentUser, the query will not return any data
        // Without this, when a user signs up and is logged in automatically, they briefly see a table with data
        // before loadObjects is called and the table is refreshed.
        // There are other ways to get an empty query, of course. With the below, I know that there
        // is no such column with the value in the database.
        [query whereKey:@"nonexistent" equalTo:@"doesn't exist"];
    }
    
    return query;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showNote"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        JKENotesViewController *note = (JKENotesViewController *)segue.destinationViewController;
        note.note = object;
    }
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 
 // Remove the row from data model
 PFObject *object = [self.objects objectAtIndex:indexPath.row];
 [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
 [self refreshControl];
 [tableView reloadData];
 
 
 
 }];
 }
 }
 */

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 2. Update client model
        [self.objects removeObjectAtIndex:indexPath.row];
        
        // 3. Animate cells
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        // 1. Update backend model
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                // If the backend reports an error, you'd need to readd the cell or
                // display an error message to the user
            }
        }];
    }
}

@end

