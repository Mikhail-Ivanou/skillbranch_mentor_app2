import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

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
              Container(
                color: Colors.white24,
                height: 70,
                width: 70,
                child: CachedNetworkImage(
                  imageUrl: superheroInfo.imageUrl,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(SuperheroesColors.blue),
                          strokeWidth: 4,
                          value: progress.progress,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) => Center(
                    child: Image.asset(
                      SuperheroesImages.unknown,
                      height: 62,
                      width: 20,
                    ),
                  ),
                ),
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
