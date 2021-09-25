import 'package:flutter/foundation.dart';

class TransformData extends ChangeNotifier {
  bool _leftDrag = false;
  double _tDelta = 0;

  get isLeftDrag => this._leftDrag;

  get transformDelta => this._tDelta;

  setTransformDelta(double newDelta) {
    this._tDelta = newDelta;
    notifyListeners();
  }

  setLeftDrag(bool isLeftDrag) {
    this._leftDrag = isLeftDrag;
  }
}
