/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_app/router/back_dispatcher.dart';
import 'package:navigation_app/router/router_delegate.dart';
import 'package:navigation_app/router/shopping_parser.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appState = AppState();

  late ShoppingRouterDelegate delegate;
  final parser = ShoppingParser();
  late ShoppingBackButtonDispatcher backButtonDispatcher;

  StreamSubscription? _linkSubscription;

  _MyAppState() {
    delegate = ShoppingRouterDelegate(appState);
    delegate.setNewRoutePath(SplashPageConfig);
    backButtonDispatcher = ShoppingBackButtonDispatcher(delegate);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // Attach a listener to the Uri links stream
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      setState(() {
        delegate.parseRoute(uri);
      });
    }, onError: (Object err) {
      print('Got error $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO Add Router
    return ChangeNotifierProvider<AppState>(
      create: (_) => appState,
      // child: MaterialApp(
      child: MaterialApp.router(
        title: 'Navigation App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //   home: const Splash(),
        routerDelegate: delegate,
        routeInformationParser: parser,
        backButtonDispatcher: backButtonDispatcher,
      ),
    );
  }
}
