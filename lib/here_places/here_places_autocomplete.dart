import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Geocoder/geocoder.dart';
import 'package:pocket_bus/Models/here_map/here_geocode.dart';
import 'package:pocket_bus/Models/here_map/here_places_suggestions.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HerePlacesDialog extends StatefulWidget {
  const HerePlacesDialog({
    Key key,
    @required this.appId,
    @required this.appCode,
    this.hintText,
    this.language,
    this.position,
    this.country,
    this.maxResults,
  }) : super(key: key);

  final String appId;
  final String appCode;
  final String hintText;
  final String language;
  final Position position;
  final String country;
  final int maxResults;

  @override
  _HerePlacesDialogState createState() => _HerePlacesDialogState();
}

class _HerePlacesDialogState extends State<HerePlacesDialog> {
  final TextEditingController _queryTextController = TextEditingController();
  final PublishSubject<String> _queryBehavior = PublishSubject<String>();
  final PublishSubject<List<Suggestion>> _suggestions =
      PublishSubject<List<Suggestion>>();
  final PublishSubject<bool> _loading = PublishSubject<bool>();

  @override
  void initState() {
    super.initState();
    _queryTextController.addListener(_onQueryChange);
    _queryBehavior.stream
        .distinct()
        .skip(1)
        .debounceTime(const Duration(milliseconds: 300))
        .listen(doSearch);
  }

  @override
  void dispose() {
    _queryBehavior?.close();
    _suggestions?.close();
    _loading?.close();
    _queryTextController?.removeListener(_onQueryChange);
    _queryTextController?.dispose();
    super.dispose();
  }

  void _onQueryChange() {
    _queryBehavior.add(_queryTextController.text);
  }

  Future<void> doSearch(String value) async {
    if (mounted) {
      if (value.isNotEmpty) {
        _loading.sink.add(true);
        final HerePlacesSuggestions suggestions = await fetchSuggestionsData(
            appCode: widget.appCode,
            appId: widget.appId,
            country: widget.country,
            language: widget.language,
            maxResults: widget.maxResults,
            position: widget.position,
            searchQuery: value);

        _handleResponse(suggestions);
      } else {
        _suggestions.sink.add([]);
      }
    }
  }

  void _handleResponse(HerePlacesSuggestions herePlacesSuggestions) {
    if (!mounted) {
      return;
    }

    _loading.sink.add(false);
    _suggestions.sink.add(herePlacesSuggestions.suggestions);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Material(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0)),
      color: Theme.of(context).primaryColor,
      child: Container(
        width: size.width * 0.95,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const BackArrow(),
                Expanded(
                    child: SearchBox(
                  loadingStream: _loading.stream,
                  queryTextController: _queryTextController,
                )),
              ],
            ),
            StreamBuilder<List<Suggestion>>(
                stream: _suggestions.stream.distinct(listEquals),
                initialData: const [],
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const EmptyBox();
                  }

                  return ResultBuilder(
                      appCode: widget.appCode,
                      appId: widget.appId,
                      loaderSubject: _loading,
                      suggestions: snapshot.data);
                }),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox(
      {Key key,
      @required this.queryTextController,
      @required this.loadingStream})
      : super(key: key);

  final TextEditingController queryTextController;
  final Stream loadingStream;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            cursorColor: Theme.of(context).accentColor,
            controller: queryTextController,
            autofocus: true,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Theme.of(context).accentColor),
              hintText: Localization.of(context).miscSearch,
              border: InputBorder.none,
            ),
          ),
        ),
        Loader(loadingStream: loadingStream)
      ],
    );
  }
}

class ResultBuilder extends StatefulWidget {
  const ResultBuilder(
      {Key key,
      @required this.suggestions,
      @required this.appId,
      @required this.appCode,
      @required this.loaderSubject})
      : super(key: key);

  final List<Suggestion> suggestions;
  final String appId;
  final String appCode;
  final PublishSubject<bool> loaderSubject;

  @override
  _ResultBuilderState createState() => _ResultBuilderState();
}

class _ResultBuilderState extends State<ResultBuilder>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    _scaleAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> resultList = widget.suggestions.map((suggestion) {
      final String addressLabel = (suggestion.address?.street == null
              ? ''
              : suggestion.address.street + ', ') +
          (suggestion.address?.city == null
              ? ''
              : suggestion.address.city + ', ') +
          (suggestion.address?.country == null
              ? ''
              : suggestion.address.country);

      return ListTile(
        leading: Icon(
          Icons.location_on,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          addressLabel,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          if (mounted) {
            widget.loaderSubject.add(true);
            final Position position = await Geocoder(
                    suggestion, widget.appId, widget.appCode, addressLabel)
                .geocode();
            widget.loaderSubject.add(false);
            Navigator.pop(context, position);
          }
        },
      );
    }).toList();

    _controller.forward(from: 0.0);

    return AnimatedBuilder(
        animation: _controller,
        child: Column(mainAxisSize: MainAxisSize.min, children: resultList),
        builder: (BuildContext context, Widget child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        });
  }
}

class Loader extends StatelessWidget {
  const Loader({Key key, @required this.loadingStream}) : super(key: key);
  final Stream loadingStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: loadingStream,
        initialData: false,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: !snapshot.data ? const EmptyBox() : const MiniLoader(),
          );
        });
  }
}

class BackArrow extends StatelessWidget {
  const BackArrow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)));
  }
}

class HerePlacesAutocomplete {
  static Future<Position> show({
    @required BuildContext context,
    @required String appId,
    @required String appCode,
    String hintText = 'Search',
    Position position,
    String language,
    String country,
    int maxResults,
  }) {
    assert(appId?.isNotEmpty ?? false, 'HereMapID Missing');
    assert(appCode?.isNotEmpty ?? false, 'HereMapAppCode Missing');

    final Widget herePlacesDialog = HerePlacesDialog(
      appCode: appCode,
      appId: appId,
      position: position,
      maxResults: maxResults,
      language: language,
      country: country,
      hintText: hintText,
    );

    return showCustomDialog<Position>(context, herePlacesDialog,
        startOffset: const Offset(0.0, -1.0),
        endOffset: const Offset(0.0, -1.0));
  }
}
