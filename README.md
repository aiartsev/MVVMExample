# iOS-Test

## Obective
We would like to have you complete the following code test so we can evaluate your iOS skills.  Please place your code in a public Github repository and commit each step of your process so we can review it.

Your assignment is to create a simple Reddit client that shows the top 50 entries fromwww.reddit.com/top .

## Forking Procedures

1.  Fork the repo to your own github account
2.  When you have code ready to be review submit a pull request

## Guidelines
To do this please follow these guidelines:

- Assume the latest platform and use Swift
- Use UITableView / UICollectionView to arrange the data.
- Please refrain from using AFNetworking, instead, use NSURLSession 
- Support Landscape
- Use Storyboards

## What to show
The app should be able to show data from each entry such as:

- Title (at its full length, so take this into account when sizing your cells)
- Author
- entry date, following a format like “x hours ago” 
- A thumbnail for those who have a picture.
- Number of comments

In addition, for those having a picture (besides the thumbnail), please allow the user to tap on the thumbnail to be sent to the full sized picture. You don’t have to implement the IMGUR API, so just opening the URL would be OK.

## What to Include

- Pagination support
- Saving pictures in the picture gallery
- App state-preservation/restoration
- Support iPhone 6/ 6+ screen size

Note:
Please refrain from using external libraries (by way of using CocoaPods and similar), as we want to see your coding skills as much as possible :)

## Resources

Reddit API : http://www.reddit.com/dev/api
Apigee :https://apigee.com/console/reddit
A sample JSON file is attached
