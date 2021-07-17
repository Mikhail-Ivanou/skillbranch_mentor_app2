import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final VoidCallback onTap;
  final SuperheroInfo superheroInfo;

  const SuperheroCard({
    Key? key,
    required this.onTap,
    required this.superheroInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 70,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: SuperheroesColors.indigo,
          ),
          child: Row(
            children: [
              Image.network(
                superheroInfo.imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      superheroInfo.name.toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      superheroInfo.realName,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
