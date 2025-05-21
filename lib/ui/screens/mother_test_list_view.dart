import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/ui/widgets/test_card.dart';
import 'package:l8fe/view_models/test_crud_model.dart';
import 'package:provider/provider.dart';


class MotherTestListView extends StatefulWidget {
  final dynamic mother;

  const MotherTestListView({super.key, required this.mother});

  @override
  State createState() => _MotherTestListViewState(mother);
}

class _MotherTestListViewState extends State<MotherTestListView> {
  late List<CtgTest> tests;
  final dynamic mother;

  _MotherTestListViewState(this.mother);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:  Provider.of<TestCRUDModel>(context)
            .fetchTestsAsStream(mother['documentId']),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            tests = snapshot.data!.docs
                .map((doc) => CtgTest.fromMap(doc.data() as Map<dynamic, dynamic>, doc.id))
                .toList();

            return tests.isEmpty
                ? const Center(
                    child: Text('No test yet',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            fontSize: 20)))
                : ListView.builder(
                    itemCount: tests.length,
                    shrinkWrap: true, // use this
                    itemBuilder: (buildContext, index) =>
                        TestCard(testDetails: tests[index]));
          } else {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ));
          }
        });
  }
}
