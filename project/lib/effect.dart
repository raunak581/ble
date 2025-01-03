import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Effects"),
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 120.0, // Further reduced height for a sleeker look
              enableInfiniteScroll: true,
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
              autoPlay: true, // Added autoplay for dynamic effect
              autoPlayInterval: Duration(seconds: 1),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
            items: List.generate(5, (i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color.fromARGB(255, 187, 183, 173), Colors.orangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          'Text ${i + 1}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ));
                },
              );
            }).toList(),
          )
        ],
      ))
    );
  }
}
