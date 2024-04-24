import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingHolder extends StatefulWidget {
  const LoadingHolder({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  final bool isLoading;
  final Widget child;

  @override
  State<LoadingHolder> createState() => _LoadingHolderState();
}

class _LoadingHolderState extends State<LoadingHolder> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: const CupertinoActivityIndicator(
              radius: 12,
            ),
          ),
      ],
    );
  }
}
