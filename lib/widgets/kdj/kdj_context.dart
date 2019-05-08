import 'package:candlesticks/widgets/kdj/kdj_view.dart';
import 'package:flutter/material.dart';

class KdjContext extends InheritedWidget {
  final Function(KDJ period,double dkj) onKdjChange;

  KdjContext({
    Key key,
    @required Widget child,
    @required this.onKdjChange,
  }) : super(key: key, child: child);

  static KdjContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(KdjContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(KdjContext oldWidget) {
    return onKdjChange != oldWidget.onKdjChange;
  }
}
