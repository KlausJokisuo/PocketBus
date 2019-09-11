import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Forked from https://github.com/Rahiche/stepper_touch
/// the concept of the widget inspired
/// from [Nikolay Kuchkarov](https://dribbble.com/shots/3368130-Stepper-Touch).
/// i extended  the functionality to be more useful in real world applications
class StepperTouch extends StatefulWidget {
  const StepperTouch({
    Key key,
    @required this.initialValue,
    this.onChanged,
    @required this.plusValue,
    @required this.minusValue,
    @required this.minValue,
    @required this.maxValue,
    this.withSpring = true,
  }) : super(key: key);

  final int plusValue;
  final int minusValue;
  final int maxValue;
  final int minValue;

  /// the initial value of the stepper
  final int initialValue;

  /// called whenever the value of the stepper changed
  final ValueChanged<int> onChanged;

  /// if you want a springSimulation to happens the the user let go the stepper
  /// defaults to true
  final bool withSpring;

  @override
  _StepperState createState() => _StepperState();
}

class _StepperState extends State<StepperTouch>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  int _value;
  double _startAnimationPosX;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? 0;
    _controller =
        AnimationController(vsync: this, lowerBound: -0.5, upperBound: 0.5);
    _controller.value = 0.0;
    _controller.addListener(() {});

    _animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: const Offset(1.5, 0.0))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    _animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: const Offset(1.5, 0.0))
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: 235.0,
        height: 120.0,
        child: Material(
          type: MaterialType.canvas,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey.withOpacity(0.2),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: 10.0,
                child: Icon(Icons.remove,
                    size: 40.0,
                    color: _value != widget.minValue
                        ? Theme.of(context).accentColor
                        : Colors.grey),
              ),
              Positioned(
                right: 10.0,
                child: Icon(Icons.add,
                    size: 40.0,
                    color: _value != widget.maxValue
                        ? Theme.of(context).accentColor
                        : Colors.grey),
              ),
              GestureDetector(
                onHorizontalDragStart: _onPanStart,
                onHorizontalDragUpdate: _onPanUpdate,
                onHorizontalDragEnd: _onPanEnd,
                child: SlideTransition(
                  position: _animation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 5.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    child: child, scale: animation);
                              },
                              child: Text(
                                '$_value',
                                key: ValueKey<int>(_value),
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 56.0),
                              ),
                            ),
                          ),
                          Text(
                            'min',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double offsetFromGlobalPos(Offset globalPosition) {
    final RenderBox box = context.findRenderObject();
    final Offset local = box.globalToLocal(globalPosition);
    _startAnimationPosX = ((local.dx * 0.75) / box.size.width) - 0.4;
    return ((local.dx * 0.75) / box.size.width) - 0.4;
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.stop();
    bool changed = false;
    int _tempValue;
    if (_controller.value <= -0.20) {
      _tempValue = max(_value - widget.minusValue, widget.minValue);
      while (_tempValue % 5 != 0) {
        _tempValue--;
      }
      setState(() {
        _value = _tempValue;
      });
      changed = true;
    } else if (_controller.value >= 0.20) {
      setState(() {
        _value = min(_value + widget.plusValue, widget.maxValue);
      });
      changed = true;
    }
    if (widget.withSpring) {
      final SpringDescription _kDefaultSpring =
          SpringDescription.withDampingRatio(
        mass: 0.9,
        stiffness: 250.0,
        ratio: 0.6,
      );
      _controller.animateWith(
          SpringSimulation(_kDefaultSpring, _startAnimationPosX, 0.0, 0.0));
    } else {
      _controller.animateTo(0.0,
          curve: Curves.bounceOut, duration: const Duration(milliseconds: 500));
    }

    if (changed && widget.onChanged != null) {
      widget.onChanged(_value);
    }
  }
}
