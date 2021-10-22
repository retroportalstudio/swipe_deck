import 'package:flutter/foundation.dart';
import 'constants.dart';

class TransformData extends ChangeNotifier {
  bool _leftDrag = false;
  double _tDelta = 0;
  double spreadRadians = DEFAULT_SPREAD; // 5 Degrees

  TransformData({required double spreadRadians}) {
    this.spreadRadians = spreadRadians;
  }

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
