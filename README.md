# Swipe Deck

A simple Flutter Package to Mimic iMessage Image Picker for Flutter

## Current Features

* Add List of Widgets to present them in a Swipable Deck
* Basic Customizations Widget

## Demo
![](https://github.com/retroportalstudio/swipe_deck/blob/master/swipe_deck.gif)

## Usage
To Use, simply Wrap the Widget you want to add Focused Menu to, with FocusedMenuHolder:
```dart
      body: Container(
        child: SwipeDeck(
          startIndex: 3,
          aspectRatio: 4 / 3,
          emptyIndicator: Container(child: Center(child: Text("Nothing Here"),),),
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

## Roadmap
Plans to add more customizations.

## License
[MIT](https://choosealicense.com/licenses/mit/)
