import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/Models/favorite_stop.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/preferences.dart';
import 'package:rxdart/rxdart.dart';

class StopsBloc implements BlocBase {
  //Used in GoogleMap
  List<BusStop> _busStops = [];

  //Used in favoritesSheet (Generated from _busStops + injected _favoriteBusStopData (customName)
  List<BusStop> favoriteBusStops = [];

  //_favoriteBusStopData that are stored in SharedPreferences
  List<FavoriteStop> _favoriteBusStopData = [];

  final BehaviorSubject<List<BusStop>> _stopsController =
      BehaviorSubject<List<BusStop>>();
  Sink<List<BusStop>> get _inStops => _stopsController.sink;
  Stream<List<BusStop>> get outStops => _stopsController.stream;

  final BehaviorSubject<List<FavoriteStop>> _favoritesController =
      BehaviorSubject<List<FavoriteStop>>();
  Sink<List<FavoriteStop>> get _inFavorites => _favoritesController.sink;
  Stream<List<FavoriteStop>> get outFavorites => _favoritesController.stream;

  @override
  void dispose() {
    _favoritesController?.close();
    _stopsController?.close();
  }

  Future<void> getStops() async {
    _busStops = await fetchStopData();
    injectBusFavorites();
    _inStops.add(_busStops);
  }

  Future<void> loadFavorites() async {
    try {
      _favoriteBusStopData =
          favoriteStopFromJson(await preferences.loadData('_favoriteBusData'));
    } on NoSuchMethodError catch (e) {
      print('loadFavorites: Invalid Favorite Data');
      print(e.toString());
    }
    _inFavorites.add(_favoriteBusStopData);
  }

  Future<bool> _saveFavorites() async {
    print('saveFavorites()');
    return preferences.saveData(
        '_favoriteBusData', favoriteStopToJson(_favoriteBusStopData));
  }

  void addFavorite(FavoriteStop favoriteStop) {
    print('addFavorite');
    _favoriteBusStopData.add(favoriteStop);
    injectBusFavorites();
    _inFavorites.add([favoriteStop]);
    _saveFavorites();
  }

  void removeFavorite(FavoriteStop favoriteStop) {
    print('removeFavorite');
    resetFavoriteName(favoriteStop);
    _favoriteBusStopData.remove(favoriteStop);

    injectBusFavorites();
    _inFavorites.add([favoriteStop]);
    _saveFavorites();
  }

  void editFavoriteName(FavoriteStop favoriteStop, String customName) {
    print('editFavorite');
    final int favoriteStopIndex = _favoriteBusStopData.indexOf(favoriteStop);
    _favoriteBusStopData[favoriteStopIndex].customName = customName;
    injectBusFavorites();
    _inFavorites.add([_favoriteBusStopData[favoriteStopIndex]]);
    _saveFavorites();
  }

  void resetFavoriteName(FavoriteStop favoriteStop) {
    print('resetFavoriteName');
    final int favoriteStopIndex = _favoriteBusStopData.indexOf(favoriteStop);
    _favoriteBusStopData[favoriteStopIndex].customName = null;
    injectBusFavorites();
    _inFavorites.add([_favoriteBusStopData[favoriteStopIndex]]);
    _saveFavorites();
  }

  bool isFavorite(BusStop busStop) {
    return _favoriteBusStopData.any(
        (favoriteBusStop) => favoriteBusStop.stopCode == busStop.busStopCode);
  }

  void injectBusFavorites() {
    favoriteBusStops.clear();

    //Used to speed up processing favorites
    final Map<String, BusStop> _busStopsMap = Map.fromIterable(_busStops,
        key: (item) => item.busStopCode, value: (item) => item);

    for (final favoriteBusStop in _favoriteBusStopData) {
      _busStopsMap[favoriteBusStop.stopCode].customName =
          favoriteBusStop.customName;
      favoriteBusStops.add(_busStopsMap[favoriteBusStop.stopCode]);
    }

    _busStops = _busStopsMap.values.toList();
  }

  void handleFavoriteTap(BusStop currentStop) {
    isFavorite(currentStop)
        ? removeFavorite(FavoriteStop(stopCode: currentStop.busStopCode))
        : addFavorite(FavoriteStop(stopCode: currentStop.busStopCode));
  }
}
