import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navigation_app/app_state.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:navigation_app/ui/cart.dart';
import 'package:navigation_app/ui/checkout.dart';
import 'package:navigation_app/ui/create_account.dart';
import 'package:navigation_app/ui/list_items.dart';
import 'package:navigation_app/ui/login.dart';
import 'package:navigation_app/ui/settings.dart';
import 'package:navigation_app/ui/splash.dart';

class ShoppingRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  final List<Page> _pages = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppState appState;

  ShoppingRouterDelegate(this.appState) : navigatorKey = GlobalKey() {
    appState.addListener(() {
      notifyListeners();
    });
  }

  List<MaterialPage> get pages => List.unmodifiable(_pages);

  int numPages() => _pages.length;

  /// called by Router when it detects route information may have changed
  @override
  PageConfiguration get currentConfiguration =>
      _pages.last.arguments as PageConfiguration;

  /// called by RouterDelegate to obtain the widget tree that represents the current state
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: buildPages(),
    );
  }

  bool _onPopPage(Route<dynamic> route, result) {
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    if (canPop()) {
      pop();
      return true;
    } else {
      return false;
    }
  }

  void _removePage(MaterialPage? page) {
    if (page != null) {
      _pages.remove(page);
    }
  }

  void pop() {
    if (canPop()) {
      _removePage(pages.last);
    }
  }

  bool canPop() => pages.length > 1;

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(pages.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(Widget child, PageConfiguration pageConfig) {
    return MaterialPage(
        child: child,
        key: ValueKey(pageConfig.key),
        name: pageConfig.path,
        arguments: pageConfig
    );
  }

  void _addPageData(Widget child, PageConfiguration pageConfig) {
    _pages.add(_createPage(child, pageConfig));
  }

  void addPage(PageConfiguration pageConfig) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            pageConfig.uiPage;

    if (shouldAddPage) {
      switch (pageConfig.uiPage) {
        case Pages.Splash:
          _addPageData(const Splash(), SplashPageConfig);
          break;
        case Pages.Login:
          _addPageData(const Login(), LoginPageConfig);
          break;
        case Pages.CreateAccount:
          _addPageData(const CreateAccount(), CreateAccountPageConfig);
          break;
        case Pages.List:
          _addPageData(const ListItems(), ListItemsPageConfig);
          break;
        case Pages.Cart:
          _addPageData(const Cart(), CartPageConfig);
          break;
        case Pages.Checkout:
          _addPageData(const Checkout(), CheckoutPageConfig);
          break;
        case Pages.Settings:
          _addPageData(const Settings(), SettingsPageConfig);
          break;
        case Pages.Details:
          if (pageConfig.currentPageAction?.widget != null) {
            _addPageData(pageConfig.currentPageAction!.widget!, pageConfig);
          }
          break;
        default:
          break;
      }
    }
  }

  /// replaces top-most page
  void replace(PageConfiguration newRoute) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    addPage(newRoute);
  }

  /// replaces all pages with new list
  void setPath(List<MaterialPage> path) {
    _pages.clear();
    _pages.addAll(path);
  }

  /// replaces all pages with one page
  void replaceAll(PageConfiguration newRoute) {
    setNewRoutePath(newRoute);
  }

  void push(PageConfiguration newRoute) {
    addPage(newRoute);
  }

  void pushWidget(Widget child, PageConfiguration newRoute) {
    _addPageData(child, newRoute);
  }

  void addAll(List<PageConfiguration> routes) {
    _pages.clear();
    routes.forEach((route) {
      addPage(route);
    });
  }

  /// replaces all pages with one page
  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            configuration.uiPage;
    if (shouldAddPage) {
      _pages.clear();
      addPage(configuration);
    }
    return SynchronousFuture(null);
  }

  void _setPageAction(PageAction action) {
    if (action.page == null) return;

    switch (action.page!.uiPage) {
      case Pages.Splash:
        SplashPageConfig.currentPageAction = action;
        break;
      case Pages.Login:
        LoginPageConfig.currentPageAction = action;
        break;
      case Pages.CreateAccount:
        CreateAccountPageConfig.currentPageAction = action;
        break;
      case Pages.List:
        ListItemsPageConfig.currentPageAction = action;
        break;
      case Pages.Cart:
        CartPageConfig.currentPageAction = action;
        break;
      case Pages.Checkout:
        CheckoutPageConfig.currentPageAction = action;
        break;
      case Pages.Settings:
        SettingsPageConfig.currentPageAction = action;
        break;
      case Pages.Details:
        DetailsPageConfig.currentPageAction = action;
        break;
    }
  }

  List<Page> buildPages() {
    if (!appState.splashFinished) {
      replaceAll(SplashPageConfig);
    } else {
      switch (appState.currentAction.state) {
        case PageState.none:
          break;
        case PageState.addPage:
          _setPageAction(appState.currentAction);
          addPage(appState.currentAction.page!);
          break;
        case PageState.pop:
          pop();
          break;
        case PageState.replace:
          _setPageAction(appState.currentAction);
          replace(appState.currentAction.page!);
          break;
        case PageState.replaceAll:
          _setPageAction(appState.currentAction);
          replaceAll(appState.currentAction.page!);
          break;
        case PageState.addWidget:
          _setPageAction(appState.currentAction);
          pushWidget(appState.currentAction.widget!, appState.currentAction.page!);
          break;
        case PageState.addAll:
          addAll(appState.currentAction.pages!);
          break;
      }
    }

    appState.resetCurrentAction();
    return List.of(_pages);
  }
}
