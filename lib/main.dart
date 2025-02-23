import 'dart:async';

import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkoutScreen(),
      theme: new ThemeData(scaffoldBackgroundColor: const Color.fromARGB(255, 38, 38, 38)),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<String, dynamic> workoutSchedule = {};
  String selectedDay = DateFormat('EEEE').format(DateTime.now()); // Start with today's day
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWorkoutData();
  }

  Future<void> loadWorkoutData() async {
    try {
      String data = await rootBundle.loadString('assets/jsontest.json');
      setState(() {
        workoutSchedule = jsonDecode(data);
        isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  // Function to switch to the next or previous day
  void switchDay(int direction) {
    List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    int currentIndex = days.indexOf(selectedDay);

    if (currentIndex != -1) {
      int newIndex = (currentIndex + direction) % days.length;
      if (newIndex < 0) newIndex = days.length - 1;

      setState(() {
        selectedDay = days[newIndex];
      });
    }
  }

  int lastTime=DateTime.now().millisecondsSinceEpoch;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDay),
        backgroundColor: Color.fromARGB(255, 178, 0, 163),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx > 0) {
                  if (DateTime.now().millisecondsSinceEpoch-lastTime>300){switchDay(-1); lastTime=DateTime.now().millisecondsSinceEpoch;}
                   // swipe right to previous day; 0.3 seconds cooldown
                } else if (details.delta.dx < 0) {
                  if (DateTime.now().millisecondsSinceEpoch-lastTime>300){switchDay(1); lastTime=DateTime.now().millisecondsSinceEpoch;}
                   // swipe left to next day; 0.3 seconds cooldown
                }
              },
              child: Column(
                children: [
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: workoutSchedule[selectedDay].length,
                      itemBuilder: (context, index) {
                        var exercise = workoutSchedule[selectedDay][index];

                        if (exercise.containsKey("reps")) {
                          return Card(
                            color: Color.fromARGB(255, 59, 59, 59),
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(exercise["name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 224, 224, 224),)),
                              subtitle: Text(
                                "${exercise["sets"]} sets x ${exercise["reps"]} reps using ${exercise["machine"]}",
                                style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 224, 224, 224)),
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("Rest Day", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 178, 0, 163))),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
