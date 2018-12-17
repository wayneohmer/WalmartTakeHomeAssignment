# WalmartTakeHomeAssingment

**Data**

I used a simple URLSession to fetch the JSON and Swift Decodable to consume it. I used asynchronous URLSessions to fetch the images and populate the image views in the table as the images come in. 

My main table view loads pages of 15 products at a time and uses prefetching to get the next page when the user scrolls to the bottom of the page.  

**Layout**

I decided to use a UISplitViewController instead of a plain UITableViewController because the implementation of the intitial tableView is mostly the same and we get a lot of rotation and iPad functionality for free. I left out the suggested swipe gestures for next and previous products in favor of up and down buttons in the the nav bar. They are much more compatible with the split view controller, and are similar to the mail app's up/down buttons.  

**Extras**

It supports dynamic type, all device sizes, and rotation. It's not pretty when you set your font to maximum size, but it all works.  

**Test**

I used a unit test to verify the JSON decoding. Writing the test first really helped in this case.    

My data fetching class has 75% test coverage. I focused on testing error paths to make sure error handling is being executed in the appropriate situations.

I did not take the time to write tests for the views or image fetching.  

**Image Caching**

I utilized the .cachesDirectory that Apple provides. I only store images on disk in this directory. Only visbile images are in RAM. I have found that reading an image from disk is not noticeably slower than accessing it in RAM. If the OS throws an image away, the next request will trigger a fetch from the server.

My current implemention assumes that the server image will never change. Of course that's not how things work in real life. This problem could be be solved with an age out policy that looks a time stamps. I did not take the time to implement this. I did implement such a system when I was at Spoken if you are interested in hearing about it.  

**Dependency Injection**

I implemented a very simple version of this in my logging class. It helped me use my unit test to verifty that log messages were correct.  

**Caveats** 

It's always difficult to decide how thorough to be on coding tests. I took a lot of shortcuts that I would not take in a production app. Static strings are sprinkled through the app and not localized. I note in comments where things are incomplete or could be expanded.  


