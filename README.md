# Coffee-Locator
Coffee Locator app that locates data based on a 3 mile radius from user location using four square and realm.

On application start up, the user's location is extracted.  A restful API call is made to foursquare using the das quadraft swift API wrapper to retrieve nearby coffee shops.  If coffee shops (venues) are found, they are saved locally to realm, so that subsequent requests can check realm as a local cache before making another API call to four square.

The app consists of a map and a list of coffee shops as detailed in the image below.  The app uses pins as clickable annotations that give basic information about the coffee shop.

![alt text](https://github.com/Marquis103/Coffee-Locator/blob/master/coffeescreenshot.png)

##How to Install
`git clone https://github.com/Marquis103/Coffee-Locator.git`

##Things To Note
The search radius of the map is dictated by the distanceSpan variable in ViewController.swift.
`let distanceSpan:Double = 8046 //5 mile radius`

##License
Code released under the [MIT license](https://github.com/Marquis103/Coffee-Locator/blob/master/LICENSE.md)
