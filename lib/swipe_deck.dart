library swipe_deck;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:swipe_deck/data_holder.dart';
import 'package:provider/provider.dart';

class SwipeDeck extends StatefulWidget {
  final List<Widget> widgets;
  final int startIndex;
  final Widget emptyIndicator;
  final double aspectRatio;

  const SwipeDeck({Key? key, required this.widgets, this.startIndex = 0, this.emptyIndicator = const _NothingHere(), this.aspectRatio = 4 / 3}) : super(key: key);

  @override
  _SwipeDeckState createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck> {
  List<Widget> leftStackRaw = [], rightStackRaw = [];
  List<MapEntry<int, dynamic>> leftStack = [], rightStack = [];
  Widget? currentWidget, contestantImage, removedImage;
  bool draggingLeft = false, onHold = false, beginDrag = false;
  double transformLevel = 0, removeTransformLevel = 0;
  Timer? stackTimer, repositionTimer;

  @override
  void dispose() {
    super.dispose();
    if (stackTimer != null) {
      stackTimer!.cancel();
    }
    if (repositionTimer != null) {
      repositionTimer!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.widgets.isEmpty) {
      return;
    }

    leftStackRaw = widget.widgets.sublist(widget.startIndex);
    rightStackRaw = widget.widgets.sublist(0, widget.startIndex);

    currentWidget = leftStackRaw.first;
    leftStackRaw.removeAt(0);
    contestantImage = leftStackRaw.first;

    leftStack = leftStackRaw.asMap().entries.toList();
    rightStack = rightStackRaw.asMap().entries.toList();
  }

  refreshLHStacks() {
    if (stackTimer != null && stackTimer!.isActive) {
      return;
    }
    leftStack = leftStackRaw.asMap().entries.toList();
    rightStack = rightStackRaw.asMap().entries.toList();
    onHold = true;
    removeTransformLevel = transformLevel;
    transformLevel = 0;
    double part = removeTransformLevel / 50;
    stackTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (removeTransformLevel >= part) {
        removeTransformLevel -= part;
        setState(() {});
      }
    });
    Future.delayed(Duration(milliseconds: 500), () {
      stackTimer!.cancel();
      removedImage = Center();
      removeTransformLevel = max(removeTransformLevel, 0);
      setState(() {
        onHold = false;
      });
    });
  }

  returnToPosition() {
    if (repositionTimer != null && repositionTimer!.isActive) {
      return;
    }
    onHold = true;
    double part = transformLevel / 10;
    repositionTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (transformLevel >= part) {
        transformLevel -= part;
      }
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 200), () {
      repositionTimer!.cancel();
      transformLevel = max(transformLevel, 0);
      setState(() {
        onHold = false;
      });
    });
  }

  wrapWithContainer(Widget widget, width, height) {
    return Container(
      width: width,
      height: height,
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20.0);
    bool dragLimit = transformLevel > 0.8;
    return ChangeNotifierProvider(
      create: (BuildContext context) => TransformData(),
      child: LayoutBuilder(builder: (context, constraints) {
        final imageWidth = constraints.maxWidth / 2;
        final imageHeight = widget.aspectRatio * imageWidth;
        final double centerWidth = constraints.maxWidth / 2;
        if (widget.widgets.isEmpty) {
          return widget.emptyIndicator;
        }
        return GestureDetector(
          onPanDown: (downDetails) {
            if ((centerWidth - downDetails.localPosition.dx).abs() < 50) {
              beginDrag = true;
              setState(() {});
            }
          },
          onPanEnd: (panEnd) {
            beginDrag = false;
            returnToPosition();
          },
          onPanUpdate: (panDetails) {
            if (onHold || currentWidget == null || !beginDrag) {
              return;
            }
            draggingLeft = (centerWidth) > panDetails.localPosition.dx;

            if ((draggingLeft && rightStackRaw.isEmpty) || (!draggingLeft && leftStackRaw.isEmpty)) {
              return;
            }

            transformLevel = (centerWidth - panDetails.localPosition.dx).abs() / centerWidth;
            context.read<TransformData>().setTransformDelta(transformLevel);
            context.read<TransformData>().setLeftDrag(draggingLeft);
            if (draggingLeft) {
              if (rightStack.isEmpty) {
                return;
              }
              contestantImage = rightStack.last.value;
            } else {
              if (leftStack.isEmpty) {
                return;
              }
              contestantImage = leftStack.first.value;
            }
            if (transformLevel > 0.8) {
              removedImage = currentWidget;
              if (draggingLeft) {
                if (rightStackRaw.isEmpty) {
                  return;
                }
                leftStackRaw.insert(0, currentWidget!);
                currentWidget = rightStackRaw.last;
                rightStackRaw.removeLast();
                if (rightStackRaw.isNotEmpty) {
                  contestantImage = rightStackRaw.last;
                }
              } else {
                if (leftStackRaw.isEmpty) {
                  return;
                }
                rightStackRaw.add(currentWidget!);
                currentWidget = leftStackRaw.first;
                leftStackRaw.removeAt(0);
                if (leftStackRaw.isNotEmpty) {
                  contestantImage = leftStackRaw.first;
                }
              }
              refreshLHStacks();
            }
            setState(() {});
          },
          child: Center(
            child: Stack(
              children: [
                ...rightStack
                    .map((e) => _WidgetHolder(
                          width: imageWidth,
                          height: imageHeight,
                          image: e.value,
                          index: e.key,
                          isLeft: false,
                          lastIndex: rightStack.length - 1,
                        ))
                    .toList(),
                ...leftStack
                    .map((e) => _WidgetHolder(
                          width: imageWidth,
                          height: imageHeight,
                          image: e.value,
                          index: e.key,
                          lastIndex: leftStack.length,
                        ))
                    .toList(),
                Transform.translate(
                  offset: Offset(removeTransformLevel * (draggingLeft ? -90 : 90), 0),
                  child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.rotationZ(removeTransformLevel * (draggingLeft ? -0.5 : 0.5)),
                      child: Container(width: imageWidth, height: imageHeight, child: removedImage ?? Center())),
                ),
                if (!dragLimit) ...[
                  Transform.scale(scale: 1.0 + min(transformLevel, 0.02), child: Container(width: imageWidth, height: imageHeight, child: contestantImage ?? Center())),
                ],
                if (currentWidget != null) ...[
                  Transform.translate(
                    offset: Offset(transformLevel * (draggingLeft ? -90 : 90), 0),
                    child: Transform.scale(
                      scale: max(0.8, (1 - transformLevel + 0.2)),
                      alignment: Alignment.center,
                      child: Transform(
                          alignment: Alignment.bottomCenter,
                          transform: Matrix4.rotationZ(transformLevel * (draggingLeft ? -0.5 : 0.5)),
                          child: Container(
                            width: imageWidth,
                            height: imageHeight,
                            decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 1, color: Colors.black.withOpacity(0.2))], borderRadius: borderRadius),
                            child: currentWidget,
                          )),
                    ),
                  ),
                ],
                if (dragLimit) ...[
                  Transform.scale(scale: 1.0 + min(transformLevel, 0.02), child: Container(width: imageWidth, height: imageHeight, child: contestantImage ?? Center())),
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}

const _ROTATION_DIFF = 0.0872665;

class _WidgetHolder extends StatefulWidget {
  final double width, height;
  final Widget image;
  final int index;
  final bool isLeft;
  final int lastIndex;

  const _WidgetHolder({Key? key, required this.width, required this.height, required this.image, required this.index, this.isLeft = true, this.lastIndex = 0}) : super(key: key);

  @override
  _WidgetHolderState createState() => _WidgetHolderState();
}

class _WidgetHolderState extends State<_WidgetHolder> {
  late Widget childImage;

  @override
  void initState() {
    super.initState();
    childImage = Container(width: widget.width, height: widget.height, child: widget.image);
  }

  @override
  void didUpdateWidget(covariant _WidgetHolder oldWidget) {
    if (oldWidget.image != widget.image) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    double finalRotation = (widget.index <= widget.lastIndex - 3) ? (3 * _ROTATION_DIFF) : ((widget.lastIndex - widget.index) * _ROTATION_DIFF);
    bool isLeft = context.read<TransformData>().isLeftDrag;
    double scaleDifferential = 0.05 * context.read<TransformData>().transformDelta;
    return Transform.scale(
      scale: isLeft ? (widget.isLeft ? (1 - scaleDifferential) : 1 + scaleDifferential) : (widget.isLeft ? 1 + scaleDifferential : (1 - scaleDifferential)),
      child: Transform(alignment: Alignment.bottomCenter, transform: Matrix4.rotationZ(widget.isLeft ? -finalRotation : finalRotation), child: childImage),
    );
  }
}

class _NothingHere extends StatefulWidget {
  const _NothingHere({Key? key}) : super(key: key);

  @override
  __NothingHereState createState() => __NothingHereState();
}

class __NothingHereState extends State<_NothingHere> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Nothing Here!"),
      ),
    );
  }
}
