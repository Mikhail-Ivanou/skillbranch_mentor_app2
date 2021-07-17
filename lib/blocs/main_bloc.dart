import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoritesSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded('');

  Stream<MainPageState> observeMainPageState() => stateSubject;
  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  MainBloc() {
    stateSubject.sink.add(MainPageState.noFavorites);
    textSubscription = Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
      currentTextSubject.distinct().debounceTime(Duration(milliseconds: 500)),
      favoritesSuperheroesSubject,
      (searchedText, favorites) => MainPageStateInfo(searchedText, favorites.isNotEmpty),
    ).listen(
      (value) {
        searchSubscription?.cancel();
        if (value.searchText.isEmpty) {
          if (value.haveFavorites) {
            stateSubject.add(MainPageState.favorites);
          } else {
            stateSubject.add(MainPageState.noFavorites);
          }
        } else if (value.searchText.length < minSymbols) {
          stateSubject.add(MainPageState.minSymbols);
        } else {
          searchForSuperheroes(value.searchText);
        }
      },
    );
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() => favoritesSuperheroesSubject;
  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() => searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(Duration(seconds: 1));
    return SuperheroInfo.mocked.where((element) => element.name.toLowerCase().contains(text.toLowerCase())).toList();
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchedSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? '');
  }

  void dispose() {
    stateSubject.close();
    favoritesSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
    searchSubscription?.cancel();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'SuperheroInfo{name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
        name: 'Batman',
        realName: 'Bruce Wayne',
        imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg'),
    SuperheroInfo(
        name: 'Ironman',
        realName: 'Tony Stark',
        imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg'),
    SuperheroInfo(
        name: 'Venom',
        realName: 'Eddie Brock',
        imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg'),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  const MainPageStateInfo(this.searchText, this.haveFavorites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          haveFavorites == other.haveFavorites;

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;
}
