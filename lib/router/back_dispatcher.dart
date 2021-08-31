import 'package:flutter/material.dart';
import 'package:navigation_app/router/router_delegate.dart';

class ShoppingBackButtonDispatcher extends RootBackButtonDispatcher {
  final ShoppingRouterDelegate _routerDelegate;

  ShoppingBackButtonDispatcher(this._routerDelegate) : super();

  @override
  Future<bool> didPopRoute() {
    /// If you need to do some custom back button handling, add your code here
    return _routerDelegate.popRoute();
  }
}
