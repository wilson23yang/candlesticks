import 'package:candlesticks/widgets/boll/boll_view.dart';
import 'package:flutter/material.dart';

class RsiContext extends InheritedWidget {
  final Function(int period,double rsi) onRsiChange;

  RsiContext({
    Key key,
    @required Widget child,
    @required this.onRsiChange,
  }) : super(key: key, child: child);

  static RsiContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RsiContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(RsiContext oldWidget) {
    return onRsiChange != oldWidget.onRsiChange;
  }
}
