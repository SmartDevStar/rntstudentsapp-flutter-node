import 'package:flutter/material.dart';

class BottomBarItem extends StatelessWidget {
  const BottomBarItem(
    this.icon,
    this.label, {
    super.key,
    this.onTap,
    this.color = Colors.grey,
    this.activeColor = Colors.white,
    this.isActive = false,
    this.isNotified = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color activeColor;
  final bool isNotified;
  final bool isActive;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: _buildItem(),
      ),
    );
  }

  Widget _buildItem() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isNotified ? _buildNotifiedIcon() : _buildIcon(),
        Container(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : color,
              ),
            )),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white.withOpacity(.15) : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 30,
        color: isActive ? activeColor : color,
      ),
    );
  }

  Widget _buildNotifiedIcon() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white.withOpacity(.15) : Colors.transparent,
      ),
      child: Stack(
        children: <Widget>[
          Icon(
            icon,
            size: 30,
            color: isActive ? activeColor : color,
          ),
          const Positioned(
            top: 3.0,
            right: 0,
            left: 0.0,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(
                Icons.brightness_1,
                size: 10.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
