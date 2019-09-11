import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:flutter/material.dart';

class BlocProviderTree extends StatelessWidget {
  const BlocProviderTree({
    Key key,
    @required this.blocProviders,
    @required this.child,
  })  : assert(blocProviders != null),
        assert(child != null),
        super(key: key);

  final List<BlocProvider> blocProviders;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocProvider in blocProviders.reversed) {
      tree = blocProvider.copyWith(tree);
    }
    return tree;
  }
}
