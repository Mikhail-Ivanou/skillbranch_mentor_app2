import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoritesSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded('');

  Stream<MainPageState> observeMainPageState() => stateSubject;
  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  http.Client? client;
  FocusNode? focusNode;

  MainBloc({this.client}) {
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
    final token = dotenv.env['SUPERHERO_TOKEN'];
    final response =
        await (client ??= http.Client()).get(Uri.parse('https://superheroapi.com/api/$token/search/$text'));
    final decoded = json.decode(response.body);

    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superheroes = results.map((e) => Superhero.fromJson(e)).toList();
      final List<SuperheroInfo> found = superheroes
          .map((rawSuperHero) => SuperheroInfo(
                name: rawSuperHero.name,
                realName: rawSuperHero.biography.fullName,
                imageUrl: rawSuperHero.image.url,
              ))
          .toList();
      return found;
    } else if (decoded['response'] == 'error') {
      if (decoded['error'] == 'character with given name not found') {
        return [];
      }
      throw ApiException('Client error happened');
    }
    if (400 >= response.statusCode && response.statusCode <= 499) {
      throw ApiException('Client error happened');
    }
    if (500 >= response.statusCode && response.statusCode <= 599) {
      throw ApiException('Server error happened');
    }
    throw Exception('Unknown error happened');
  }

  void retry() {
    final currentSearchInput = currentTextSubject.value;
    searchForSuperheroes(currentSearchInput);
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

  void removeFavorite() {
    final current = favoritesSuperheroesSubject.value;
    favoritesSuperheroesSubject.add(current.isEmpty ? SuperheroInfo.mocked : current.sublist(0, current.length - 1));
  }

  void dispose() {
    stateSubject.close();
    favoritesSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
    searchSubscription?.cancel();
    client?.close();
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
