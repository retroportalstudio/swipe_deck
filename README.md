# Swipe Deck

A simple Flutter Package to Mimic iMessage Image Picker for Flutter

## Current Features

* Add List of Widgets to present them in a Swipable Deck
* Basic Widget Customizations

## Demo
![](https://github.com/retroportalstudio/swipe_deck/blob/master/swipe_deck.gif)

## Usage
To Use, simply Wrap the Widget you want to add Focused Menu to, with FocusedMenuHolder:
```dart
      body: Container(
            child: SwipeDeck(
              startIndex: 3,
              emptyIndicator: Container(
                child: Center(
                  child: Text("Nothing Here"),
                ),
              ),
              cardSpreadInDegrees: 5, // Change the Spread of Background Cards
              onSwipeLeft: (){
                print("USER SWIPED LEFT -> GOING TO NEXT WIDGET");
              },
              onSwipeRight: (){
                print("USER SWIPED RIGHT -> GOING TO PREVIOUS WIDGET");
              },
              onChange: (index){
                print(IMAGES[index]);
              },
              widgets: IMAGES
                  .map((e) => GestureDetector(
                        onTap: () {
                          print(e);
                        },
                        child: ClipRRect(
                            borderRadius: borderRadius,
                            child: Image.asset(
                              "assets/images/$e.jpg",
                              fit: BoxFit.cover,
                            )),
                      ))
                  .toList(),
            ),
      ),
```
## Social Handles 🎯
[Twitter](https://twitter.com/theretroportal)
[Instagram](https://www.instagram.com/retroportalstudio)
[Youtube](https://www.youtube.com/retroportalstudio)
[LinkedIn](https://www.linkedin.com/in/parasjainrps/)

## Found this useful? 💙👨‍💻
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/theretroportal)

## Roadmap
Plans to add more customizations.

## License
[MIT](https://choosealicense.com/licenses/mit/)
