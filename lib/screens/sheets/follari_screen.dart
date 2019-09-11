import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/follari_bloc.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/favorite_rack.dart';
import 'package:pocket_bus/Models/Foli/follari_data.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class FollariScreen extends StatefulWidget {
  const FollariScreen(
      {Key key, @required this.rackIdentifier, this.showTopBar = true})
      : super(key: key);

  final Rack rackIdentifier;
  final bool showTopBar;

  @override
  _FollariScreenState createState() => _FollariScreenState();
}

class _FollariScreenState extends State<FollariScreen> {
  FollariBloc _follariBloc;

  @override
  void initState() {
    super.initState();
    _follariBloc ??= BlocProvider.of<FollariBloc>(context);
    _follariBloc.getRack(widget.rackIdentifier);
  }

  @override
  Widget build(BuildContext context) {
    final Size _contextSize = MediaQuery.of(context).size;
    return ClipPath(
      clipper: NotchClipper(Rect.fromCircle(
          center: Offset(_contextSize.width / 2.0, 0.0),
          radius: widget.showTopBar ? 6.0 : 0.0)),
      clipBehavior: Clip.hardEdge,
      child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              )),
          height: _contextSize.height / 1.965,
          child: Column(
            children: <Widget>[
              if (widget.showTopBar)
                TopBar(
                  selectedRack: widget.rackIdentifier,
                ),
              Expanded(
                child: Container(
                  width: _contextSize.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          style: Theme.of(context).brightness == Brightness.dark
                              ? BorderStyle.none
                              : BorderStyle.solid),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      )),
                  child: StreamBuilder<Rack>(
                      stream: _follariBloc.outRack,
                      builder: (context, snapshot) {
                        Widget buildWidget;

                        if (!snapshot.hasData) {
                          buildWidget = const SizedBox.expand(
                            child: CenterSpinner(),
                          );
                        } else {
                          buildWidget = snapshot.data.bikesAvail != 0
                              ? BikesChip(selectedRack: snapshot.data)
                              : NoBikes(selectedRack: snapshot.data);
                        }

                        return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: buildWidget);
                      }),
                ),
              )
            ],
          )),
    );
  }
}

class BikesChip extends StatelessWidget {
  const BikesChip({Key key, @required this.selectedRack}) : super(key: key);
  final Rack selectedRack;

  @override
  Widget build(BuildContext context) {
    final int bikesAvailable = selectedRack.bikesAvail;
    final int slotsTotal = selectedRack.slotsTotal;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Space(),
        Text(
          Localization.of(context).bikeSheetBikesTitle,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
        const Space(),
        Chip(
            backgroundColor: Theme.of(context).accentColor,
            label: Text(
              '$bikesAvailable/$slotsTotal',
              style: const TextStyle(
                fontSize: 50,
                color: Colors.black,
              ),
            )),
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({Key key, @required this.selectedRack}) : super(key: key);
  final Rack selectedRack;

  @override
  Widget build(BuildContext context) {
    final FollariBloc _follariBloc = BlocProvider.of<FollariBloc>(context);
    bool isFavorite;
    bool showAnimations = false;
    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Stack(children: <Widget>[
        Align(
          alignment: const Alignment(0.86, 1.0),
          child: StreamBuilder<List<FavoriteRack>>(
              stream: _follariBloc.outFavorites,
              builder: (context, snapshot) {
                isFavorite = _follariBloc.isFavorite(selectedRack);
                return GestureDetector(
                  onTap: () {
                    _follariBloc.handleFavoriteTap(selectedRack);
                    showAnimations = true;
                  },
                  child: FavoriteHearth(
                      isFavorite: isFavorite, showAnimations: showAnimations),
                );
              }),
        ),
        Center(child: RackDetails(currentRack: selectedRack)),
      ]),
    );
  }
}

class RackDetails extends StatelessWidget {
  const RackDetails(
      {Key key, @required this.currentRack, this.centerRackDetailsText = true})
      : super(key: key);

  final Rack currentRack;
  final bool centerRackDetailsText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Text('${currentRack.customName ?? currentRack.name}',
          overflow: TextOverflow.ellipsis,
          textAlign: centerRackDetailsText ? TextAlign.center : TextAlign.start,
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.subhead.fontSize)),
    );
  }
}

class NoBikes extends StatelessWidget {
  const NoBikes({Key key, @required this.selectedRack}) : super(key: key);
  final Rack selectedRack;

  @override
  Widget build(BuildContext context) {
    final int slotsTotal = selectedRack.slotsTotal;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Space(),
            const Center(
              child: Text(
                '😴',
                style: TextStyle(fontSize: 50),
              ),
            ),
            const Space(),
            Text(
              Localization.of(context).bikeSheetNoBikesTitle,
            ),
            const Space(),
            Text(
              '${Localization.of(context).bikeSheetNoBikesBodyFirstPart} $slotsTotal ${Localization.of(context).bikeSheetNoBikesBodySecondPart}',
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
