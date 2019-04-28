import 'package:candlesticks/widgets/boll/boll_view.dart';
import 'package:flutter/material.dart';

class BollContext extends InheritedWidget {
  final Function(BollLine type,double boll, double currentValue) onBollChange;

  BollContext({
    Key key,
    @required Widget child,
    @required this.onBollChange,
  }) : super(key: key, child: child);

  static BollContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BollContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(BollContext oldWidget) {
    return onBollChange != oldWidget.onBollChange;
  }
}
