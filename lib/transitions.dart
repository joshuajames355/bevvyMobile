import 'package:flutter/material.dart';

typedef Widget PageBuilderFunc(BuildContext context);

class SlideLeftRoute extends PageRouteBuilder {
  final PageBuilderFunc page;

  SlideLeftRoute({this.page})
      : super(
          pageBuilder: 
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page(context),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) => SlideTransition
            (
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
        );
}

class SlideUpRoute extends PageRouteBuilder {
  final PageBuilderFunc page;

  SlideUpRoute({this.page})
      : super(
          pageBuilder: 
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page(context),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) => SlideTransition
            (
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
        );
}

class ExpandRoute extends PageRouteBuilder {
  final PageBuilderFunc page;

  ExpandRoute({this.page})
      : super(
          pageBuilder: 
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page(context),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) => ScaleTransition
            (
              scale: Tween<double>
              (
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation
                (
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            ),
        );
}