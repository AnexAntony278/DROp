import 'package:flutter/material.dart';

class FontStylesDemo extends StatelessWidget {
  const FontStylesDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montserrat Font Styles Demo'),
        backgroundColor: Colors.amberAccent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regular',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 10),
            Text(
              'Italic',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text(
              'Bold',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Thin',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.w100),
            ),
            SizedBox(height: 10),
            Text(
              'Black',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Text(
              'Medium',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'Medium Italic',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
