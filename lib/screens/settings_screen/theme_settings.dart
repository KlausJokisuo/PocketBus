import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/settingsData.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/Theme/themes.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final Map<ThemeToUse, String> themOptionsMap = {
      ThemeToUse.LIGHT: Localization.of(context).themeOptionLight,
      ThemeToUse.DARK: Localization.of(context).themeOptionDark,
      ThemeToUse.BLACK: Localization.of(context).themeOptionBlack
    };

    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.themeToUse == nextValue.themeToUse),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }

          TapDownDetails tapDetails;
          return InkWell(
            onTapDown: (TapDownDetails details) => tapDetails = details,
            onTap: () {
              final Offset startOffset = offsetFromCoordinates(
                  tapDetails.globalPosition.dx,
                  tapDetails.globalPosition.dy,
                  context);
              return genericDialog(context, child: const ThemeOptions());
            },
            child: GenericTile(
              title: Localization.of(context).themeSettingsTitle,
              subtitle: '${themOptionsMap[snapshot.data.themeToUse]}',
              leadingWidget: const Icon(Icons.color_lens),
            ),
          );
        });
  }
}

class ThemeOptions extends StatelessWidget {
  const ThemeOptions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.themeToUse == nextValue.themeToUse),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.65,
              child: Column(
                children: <Widget>[
                  GenericDialogTitle(
                    title: Localization.of(context).themeSettingsTitle,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LightCircle(
                            currentTheme: snapshot.data.themeToUse,
                          ),
                          DarkCircle(
                            currentTheme: snapshot.data.themeToUse,
                          ),
                          BlackCircle(
                            currentTheme: snapshot.data.themeToUse,
                          )
                        ]),
                  ),
                ],
              ));
        });
  }
}

class LightCircle extends StatelessWidget {
  const LightCircle({Key key, @required this.currentTheme}) : super(key: key);
  final ThemeToUse currentTheme;

  @override
  Widget build(BuildContext context) {
    final GlobalKey _rectGetterKey = RectGetter.createGlobalKey();
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    const Duration _duration = Duration(milliseconds: 750);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
      child: RawMaterialButton(
        key: _rectGetterKey,
        splashColor: Colors.transparent,
        child: currentTheme == ThemeToUse.LIGHT
            ? const BouncyWidget(
                child: Icon(
                  Icons.check,
                  size: 25,
                ),
                tweenBegin: 1.0,
                tweenEnd: 1.3,
                duration: Duration(milliseconds: 400),
              )
            : const EmptyBox(),
        shape: CircleBorder(
          side: BorderSide(
              color: Theme.of(context).accentColor,
              style: currentTheme == ThemeToUse.LIGHT
                  ? BorderStyle.solid
                  : BorderStyle.none),
        ),
        elevation: 2.0,
        fillColor: lightTheme.primaryColor,
        padding: const EdgeInsets.all(5.0),
        onPressed: () async {
          final Rect _rect = RectGetter.getRectFromKey(_rectGetterKey);
          final Widget _rippleEffect = RippleEffect(
            color: lightTheme.primaryColor,
            rect: _rect,
            duration: _duration,
            middleAnimationCallback: () {
              _settingsBloc.changeSetting(themeToUse: ThemeToUse.LIGHT);
            },
          );
          final OverlayEntry _overlayEntry =
              OverlayEntry(builder: (context) => _rippleEffect);
          Overlay.of(context).insert(_overlayEntry);
          await Future.delayed(_duration);
          _overlayEntry.remove();
        },
      ),
    );
  }
}

class DarkCircle extends StatelessWidget {
  const DarkCircle({Key key, @required this.currentTheme}) : super(key: key);
  final ThemeToUse currentTheme;

  @override
  Widget build(BuildContext context) {
    final GlobalKey _rectGetterKey = RectGetter.createGlobalKey();
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    const Duration _duration = Duration(milliseconds: 750);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
      child: RawMaterialButton(
        key: _rectGetterKey,
        splashColor: Colors.transparent,
        child: currentTheme == ThemeToUse.DARK
            ? const BouncyWidget(
                child: Icon(
                  Icons.check,
                  size: 35,
                ),
                tweenBegin: 1.0,
                tweenEnd: 1.3,
                duration: Duration(milliseconds: 400),
              )
            : const EmptyBox(),
        shape: CircleBorder(
          side: BorderSide(
              color: Theme.of(context).accentColor,
              style: currentTheme == ThemeToUse.DARK
                  ? BorderStyle.solid
                  : BorderStyle.none),
        ),
        elevation: 2.0,
        fillColor: darkTheme.primaryColor,
        padding: const EdgeInsets.all(5.0),
        onPressed: () async {
          final Rect _rect = RectGetter.getRectFromKey(_rectGetterKey);
          final Widget _rippleEffect = RippleEffect(
            color: darkTheme.primaryColor,
            rect: _rect,
            duration: _duration,
            middleAnimationCallback: () {
              _settingsBloc.changeSetting(themeToUse: ThemeToUse.DARK);
            },
          );
          final OverlayEntry _overlayEntry =
              OverlayEntry(builder: (context) => _rippleEffect);
          Overlay.of(context).insert(_overlayEntry);
          await Future.delayed(_duration);
          _overlayEntry.remove();
        },
      ),
    );
  }
}

class BlackCircle extends StatelessWidget {
  const BlackCircle({Key key, @required this.currentTheme}) : super(key: key);
  final ThemeToUse currentTheme;

  @override
  Widget build(BuildContext context) {
    final GlobalKey _rectGetterKey = RectGetter.createGlobalKey();
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    const Duration _duration = Duration(milliseconds: 750);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
      child: RawMaterialButton(
        key: _rectGetterKey,
        splashColor: Colors.transparent,
        child: currentTheme == ThemeToUse.BLACK
            ? const BouncyWidget(
                child: Icon(
                  Icons.check,
                  size: 35,
                ),
                tweenBegin: 1.0,
                tweenEnd: 1.3,
                duration: Duration(milliseconds: 400),
              )
            : const EmptyBox(),
        shape: CircleBorder(
          side: BorderSide(
              color: Theme.of(context).accentColor,
              style: currentTheme == ThemeToUse.BLACK
                  ? BorderStyle.solid
                  : BorderStyle.none),
        ),
        elevation: 2.0,
        fillColor: blackTheme.primaryColor,
        padding: const EdgeInsets.all(5.0),
        onPressed: () async {
          final Rect _rect = RectGetter.getRectFromKey(_rectGetterKey);
          final Widget _rippleEffect = RippleEffect(
            color: blackTheme.primaryColor,
            rect: _rect,
            duration: _duration,
            middleAnimationCallback: () {
              _settingsBloc.changeSetting(themeToUse: ThemeToUse.BLACK);
            },
          );
          final OverlayEntry _overlayEntry =
              OverlayEntry(builder: (context) => _rippleEffect);
          Overlay.of(context).insert(_overlayEntry);
          await Future.delayed(_duration);
          _overlayEntry.remove();
        },
      ),
    );
  }
}

class RippleEffect extends StatefulWidget {
  const RippleEffect(
      {Key key,
      @required this.rect,
      @required this.color,
      @required this.duration,
      @required this.middleAnimationCallback})
      : super(key: key);

  final Duration duration;
  final Rect rect;
  final Color color;
  final Function middleAnimationCallback;

  @override
  _RippleEffectState createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _opacityAnimation;
  Size _contextSize;
  double _multiplier;

  bool _callBackTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contextSize = MediaQuery.of(context).size;

    _multiplier = (_contextSize.height / widget.rect.size.width) +
        (_contextSize.width / widget.rect.size.height);

    _opacityAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );

    _scaleAnimation = Tween(begin: 0.0, end: _multiplier * 1.30)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_contextSize.width / 2.0);
    print(widget.rect.center.dx);
    print((widget.rect.center.dx / (_contextSize.width / 2.0)) - 1.0);

    print(_contextSize.height / 2.0);
    print(widget.rect.center.dy);
    print((widget.rect.center.dy / (_contextSize.height / 2.0)) - 1.0);

    return Positioned(
      left: widget.rect.left,
      right: _contextSize.width - widget.rect.right,
      top: widget.rect.top,
      bottom: _contextSize.height - widget.rect.bottom,
      child: AnimatedBuilder(
          animation: _controller,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
          builder: (BuildContext context, Widget child) {
            if (_controller.value >= 0.45 && !_callBackTriggered) {
              widget.middleAnimationCallback();
            }
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          }),
    );
  }
}
