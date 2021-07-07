import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: _MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class _MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return Stack(
      children: [
        MainPageStateWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 36,
            width: 125,
            child: ActionButton(
              onTap: () => bloc.nextState(),
              text: 'Next state',
            ),
          ),
        )
      ],
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (BuildContext context, AsyncSnapshot<MainPageState> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.noFavorites:
            return NoFavorites();
          case MainPageState.minSymbols:
            return MinSymbols();
          case MainPageState.favorites:
            return Favorite();
          case MainPageState.nothingFound:
            return NothingFound();
          case MainPageState.loadingError:
            return LoadingError();
          case MainPageState.searchResults:
            return SearchResult();
        }
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SuperheroesColors.blue),
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class MinSymbols extends StatelessWidget {
  const MinSymbols({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          'Enter at least 3 symbols',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
    );
  }
}

class NoFavorites extends StatelessWidget {
  const NoFavorites({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: InfoWithButton(
        title: 'No favorites yet',
        subtitle: 'Search and add',
        buttonText: 'Search',
        assetImage: SuperheroesImages.ironman,
        imageWidth: 108,
        imageHeight: 119,
        imageTopPadding: 9,
      ),
    );
  }
}

class NothingFound extends StatelessWidget {
  const NothingFound({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: InfoWithButton(
        title: 'Nothing found',
        subtitle: 'Search for something else',
        buttonText: 'Search',
        assetImage: SuperheroesImages.hulk,
        imageWidth: 84,
        imageHeight: 112,
        imageTopPadding: 16,
      ),
    );
  }
}

class LoadingError extends StatelessWidget {
  const LoadingError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: InfoWithButton(
        title: 'Error happened',
        subtitle: 'Please, try again',
        buttonText: 'Retry',
        assetImage: SuperheroesImages.superman,
        imageWidth: 126,
        imageHeight: 106,
        imageTopPadding: 22,
      ),
    );
  }
}

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 90,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your favorites',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(name: 'Batman'),
                    ));
              },
              name: 'Batman',
              realName: 'Bruce Wayne',
              imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg'),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(name: 'Ironman'),
                    ));
              },
              name: 'Ironman',
              realName: 'Tony Stark',
              imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg'),
        ),
      ],
    );
  }
}

class SearchResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 90,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Search results',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(name: 'Batman'),
                    ));
              },
              name: 'Batman',
              realName: 'Bruce Wayne',
              imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg'),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(name: 'Venom'),
                    ));
              },
              name: 'Venom',
              realName: 'Eddie Brock',
              imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg'),
        ),
      ],
    );
  }
}
