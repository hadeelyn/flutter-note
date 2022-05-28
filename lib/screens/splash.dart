import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:zeheronote/main.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:zeheronote/screens/home.dart';

class Splash extends StatelessWidget {
  // const Splash({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 180),
                    width: 200,
                    //  height: 200,
                    child: GradientText(
                      'up',
                      style: const TextStyle(
                        fontFamily: 'cursive',
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                      ),
                      colors: const [
                        Colors.blue,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    width: 180,
                    height: 100,
                    child: GradientText(
                      'Notes',
                      style: const TextStyle(
                        fontFamily: 'Lobster',
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                      ),
                      colors: const [
                        Colors.blue,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(80),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.blue)
                              )
                              )
                              ),
                  onPressed: () => {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                       return  Home();
                    })),
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
