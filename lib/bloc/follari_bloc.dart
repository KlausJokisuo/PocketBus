import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/Models/favorite_rack.dart';
import 'package:pocket_bus/Models/Foli/follari_data.dart';
import 'package:pocket_bus/preferences.dart';

import 'package:rxdart/rxdart.dart';

class FollariBloc implements BlocBase {
  //Used in GoogleMap
  List<Rack> _rackStops = [];

  //Used in favoritesSheet (Generated from _rackStops + injected _favoriteRackStopData (customName)
  List<Rack> favoriteRackStops = [];

  ///_favoriteRackStopData that are stored in SharedPreferences
  List<FavoriteRack> _favoriteRackStopData = [];

  ///Used to load initial Racks
  final BehaviorSubject<List<Rack>> _racksController =
      BehaviorSubject<List<Rack>>();
  Sink<List<Rack>> get _inRacks => _racksController.sink;
  Stream<List<Rack>> get outRacks => _racksController.stream;

  ///Used to load specific Rack
  final PublishSubject<Rack> _rackController = PublishSubject<Rack>();
  Sink<Rack> get _inRack => _rackController.sink;
  Stream<Rack> get outRack => _rackController.stream;

  final BehaviorSubject<List<FavoriteRack>> _favoritesController =
      BehaviorSubject<List<FavoriteRack>>();
  Sink<List<FavoriteRack>> get _inFavorites => _favoritesController.sink;
  Stream<List<FavoriteRack>> get outFavorites => _favoritesController.stream;

  @override
  void dispose() {
    _rackController?.close();
    _racksController?.close();
    _favoritesController?.close();
  }

  ///Option to disable feeding _inRacks.
  ///Disabled in [getRack]
  Future<void> getAllRacks([bool refreshAllRacks = true]) async {
    _rackStops = await fetchRackData();
    injectRackFavorites();
    if (refreshAllRacks) {
      _inRacks.add(_rackStops);
    }
  }

  Future<void> getRack(Rack currentRack) async {
    await getAllRacks(false);
    final int rackIndex = _rackStops.indexOf(currentRack);
    _inRack.add(_rackStops[rackIndex]);
  }

  Future<void> loadFavorites() async {
    try {
      _favoriteRackStopData = favoriteRackFromJson(
          await preferences.loadData('_favoriteRackStopData'));
      _inFavorites.add(_favoriteRackStopData);
    } on NoSuchMethodError catch (e) {
      print('loadSettings: Invalid Settings Data');
      print(e.toString());
    }
  }

  Future<bool> _saveFavorites() async {
    print('saveFavorites()');
    return preferences.saveData(
        '_favoriteRackStopData', favoriteRackToJson(_favoriteRackStopData));
  }

  void addFavorite(FavoriteRack favoriteRack) {
    print('addFavorite');
    _favoriteRackStopData.add(favoriteRack);
    injectRackFavorites();
    _inFavorites.add([favoriteRack]);
    _saveFavorites();
  }

  void removeFavorite(FavoriteRack favoriteRack) {
    print('removeFavorite');
    resetFavoriteName(favoriteRack);
    _favoriteRackStopData.remove(favoriteRack);

    injectRackFavorites();
    _inFavorites.add([favoriteRack]);
    _saveFavorites();
  }

  void editFavoriteName(FavoriteRack favoriteRack, String customName) {
    print('editFavorite');
    final int favoriteRackIndex = _favoriteRackStopData.indexOf(favoriteRack);
    _favoriteRackStopData[favoriteRackIndex].customName = customName;
    injectRackFavorites();
    _inFavorites.add([_favoriteRackStopData[favoriteRackIndex]]);
    _saveFavorites();
  }

  void resetFavoriteName(FavoriteRack favoriteRack) {
    print('resetFavoriteName');
    final int favoriteRackIndex = _favoriteRackStopData.indexOf(favoriteRack);
    _favoriteRackStopData[favoriteRackIndex].customName = null;
    injectRackFavorites();
    _inFavorites.add([_favoriteRackStopData[favoriteRackIndex]]);
    _saveFavorites();
  }

  bool isFavorite(Rack rack) {
    return _favoriteRackStopData
        .any((favoriteRackStopData) => favoriteRackStopData.rackId == rack.id);
  }

  ///Injects saved [_favoriteRackStopData] into actual [_rackStops]
  void injectRackFavorites() {
    favoriteRackStops.clear();

    //Used to speed up processing favorites
    final Map<String, Rack> _rackStopsMap = Map.fromIterable(_rackStops,
        key: (item) => item.id, value: (item) => item);

    for (final favoriteRackStop in _favoriteRackStopData) {
      _rackStopsMap[favoriteRackStop.rackId].customName =
          favoriteRackStop.customName;
      favoriteRackStops.add(_rackStopsMap[favoriteRackStop.rackId]);
    }
    _rackStops = _rackStopsMap.values.toList();
  }

  void handleFavoriteTap(Rack selectedRack) {
    isFavorite(selectedRack)
        ? removeFavorite(FavoriteRack(rackId: selectedRack.id))
        : addFavorite(FavoriteRack(rackId: selectedRack.id));
  }
}
