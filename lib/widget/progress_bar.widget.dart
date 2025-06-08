import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';


class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key,required this.width,required this.height,required this.progress});
  final double width;
  final double height;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height:height,
      decoration: BoxDecoration(
        color: bgDarkerGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child:Stack(
        children: [
          Container(
            width:width*progress,
            height:height,
            decoration:BoxDecoration(
              color: textGreen,
              borderRadius: BorderRadius.circular(10)
            ),
          ),
        ]
      )
    );
  }


}