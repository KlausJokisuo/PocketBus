import 'dart:math';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/follari_bloc.dart';
import 'package:pocket_bus/BloC/stops_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/custom_expansion_tile.dart';
import 'package:pocket_bus/Models/favorite_rack.dart';
import 'package:pocket_bus/Models/favorite_stop.dart';
import 'package:pocket_bus/Models/Foli/follari_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';

import 'package:pocket_bus/Screens/Sheets/follari_screen.dart';

import 'package:pocket_bus/Screens/Sheets/main_schedule_screen.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

// https://medium.com/@diegoveloper/flutter-lets-know-the-scrollcontroller-and-scrollnotification-652b2685a4ac
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double _scrollOffset;

  StopsBloc _stopsBloc;
  FollariBloc _follariBloc;

  Key _key;
  int _expanded;
  ScrollPhysics _scrollPhysics = const BouncingScrollPhysics();
  final ScrollController _scrollController = ScrollController();
  final double _indexHeight =
      68.0; //ListTile Height - Padding Look at list_tile.dart source

  //https://www.didierboelens.com/2018/04/internationalization---language-selector-widget-with-auto-collapse/
//  https://github.com/flutter/flutter/issues/12319

  void _collapse() {
    final String oldKeyValue = _key.toString();
    do {
      _key = Key(Random().nextInt(10000).toString());
    } while (oldKeyValue == _key.toString());
  }

  @override
  void initState() {
    super.initState();
    _stopsBloc ??= BlocProvider.of<StopsBloc>(context);
    _follariBloc ??= BlocProvider.of<FollariBloc>(context);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _collapse();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _contextSize = MediaQuery.of(context).size;
    final int favoriteCount = _stopsBloc.favoriteBusStops.length +
        _follariBloc.favoriteRackStops.length;

    _controller.forward();
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          )),
      height: _contextSize.height / 2.0,
      child: Column(
        children: <Widget>[
          const FavoriteTitle(),
          Expanded(
            child: _stopsBloc.favoriteBusStops.isEmpty &&
                    _follariBloc.favoriteRackStops.isEmpty
                ? const NoFavorites()
                : ListView.builder(
                    controller: _scrollController,
                    physics: _scrollPhysics,
                    itemCount: favoriteCount,
                    itemBuilder: (BuildContext context, int busTileIndex) {
                      final bool showBusTile =
                          busTileIndex < _stopsBloc.favoriteBusStops.length;

                      final int follariTileIndex =
                          busTileIndex - _stopsBloc.favoriteBusStops.length;

                      return FadeTransition(
                        opacity: _animation,
                        child: Card(
                          margin: const EdgeInsets.all(5.0),
                          child: CustomExpansionTile(
                            key: _key,
                            onExpansionChanged: (expanded) {
                              _scrollOffset = busTileIndex * _indexHeight;
                              _scrollController.animateTo(_scrollOffset,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.ease);

                              setState(() {
                                _scrollPhysics ==
                                        const NeverScrollableScrollPhysics()
                                    ? _scrollPhysics =
                                        const BouncingScrollPhysics()
                                    : _scrollPhysics =
                                        const NeverScrollableScrollPhysics();
                                _expanded = _expanded == busTileIndex
                                    ? null
                                    : busTileIndex;
                                _collapse();
                              });
                            },
                            initiallyExpanded: _expanded == busTileIndex,
                            title: showBusTile
                                ? FavoriteBusTitleBar(
                                    currentStop: _stopsBloc
                                        .favoriteBusStops[busTileIndex],
                                  )
                                : FavoriteRackTitleBar(
                                    currentRack: _follariBloc
                                        .favoriteRackStops[follariTileIndex],
                                  ),
                            children: <Widget>[
                              showBusTile
                                  ? MainScheduleScreen(
                                      currentStop: _stopsBloc
                                          .favoriteBusStops[busTileIndex],
                                      showTopBar: false,
                                    )
                                  : FollariScreen(
                                      rackIdentifier: _follariBloc
                                          .favoriteRackStops[follariTileIndex],
                                      showTopBar: false,
                                    )
                            ],
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}

class FavoriteTitle extends StatelessWidget {
  const FavoriteTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(Localization.of(context).favoriteSheetTitle,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.subhead.fontSize)),
      ),
    );
  }
}

class FavoriteBusTitleBar extends StatefulWidget {
  const FavoriteBusTitleBar({Key key, @required this.currentStop})
      : super(key: key);

  final BusStop currentStop;

  @override
  _FavoriteBusTitleBarState createState() => _FavoriteBusTitleBarState();
}

class _FavoriteBusTitleBarState extends State<FavoriteBusTitleBar> {
  StopsBloc _stopsBloc;
  final TextEditingController _controller = TextEditingController();

  void _handleFavorite(DialogAction favoriteDialogAction) {
    switch (favoriteDialogAction) {
      case DialogAction.APPLY:
        _stopsBloc.editFavoriteName(
            FavoriteStop(stopCode: widget.currentStop.busStopCode),
            _controller.text);
        break;
      case DialogAction.REMOVE:
        _stopsBloc.removeFavorite(
            FavoriteStop(stopCode: widget.currentStop.busStopCode));
        break;
      case DialogAction.DISCARD:
        break;
      case DialogAction.RESET:
        _stopsBloc.resetFavoriteName(
            FavoriteStop(stopCode: widget.currentStop.busStopCode));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _stopsBloc ??= BlocProvider.of<StopsBloc>(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const BusIcon(height: 25),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: StopDetails(
                centerStopDetailsText: false,
                currentStop: widget.currentStop,
              ),
            ),
            IconButton(
              onPressed: () {
                favoriteEditDialog(context, _controller).then(_handleFavorite);
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
          ]),
    );
  }
}

class FavoriteRackTitleBar extends StatefulWidget {
  const FavoriteRackTitleBar({Key key, @required this.currentRack})
      : super(key: key);

  final Rack currentRack;

  @override
  _FavoriteRackTitleBarState createState() => _FavoriteRackTitleBarState();
}

class _FavoriteRackTitleBarState extends State<FavoriteRackTitleBar> {
  final TextEditingController _controller = TextEditingController();
  FollariBloc _follariBloc;

  void _handleFavorite(DialogAction favoriteDialogAction) {
    switch (favoriteDialogAction) {
      case DialogAction.APPLY:
        _follariBloc.editFavoriteName(
            FavoriteRack(rackId: widget.currentRack.id), _controller.text);
        break;
      case DialogAction.REMOVE:
        _follariBloc
            .removeFavorite(FavoriteRack(rackId: widget.currentRack.id));
        break;
      case DialogAction.DISCARD:
        break;
      case DialogAction.RESET:
        _follariBloc
            .resetFavoriteName(FavoriteRack(rackId: widget.currentRack.id));
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _follariBloc ??= BlocProvider.of<FollariBloc>(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const BikeIcon(
              height: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: RackDetails(
                    currentRack: widget.currentRack,
                    centerRackDetailsText: false)),
            InkWell(
              onTap: () {
                favoriteEditDialog(context, _controller).then(_handleFavorite);
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.edit,
                ),
              ),
            )
          ]),
    );
  }
}

class NoFavorites extends StatelessWidget {
  const NoFavorites({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).cardColor.withOpacity(.9),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Space(height: 10),
              const Center(
                child: Text(
                  '💔',
                  style: TextStyle(fontSize: 50),
                ),
              ),
              const Space(height: 10),
              Text(
                Localization.of(context).noFavoritesTitle,
                textAlign: TextAlign.center,
              ),
              const Space(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    '${Localization.of(context).noFavoritesSubtitle} ',
                  ),
                  const FavoriteHearth(isFavorite: true, showAnimations: true)
                ],
              ),
            ],
          ),
        ));
  }
}
