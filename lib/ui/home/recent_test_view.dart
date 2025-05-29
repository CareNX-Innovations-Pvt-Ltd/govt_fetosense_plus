import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/services/firestore_database.dart';
import 'package:l8fe/ui/widgets/all_test_card.dart';
import 'package:provider/provider.dart';

class RecentTestsView extends StatefulWidget {
  const RecentTestsView({super.key});

  String get screenName => "RecentTestScreen";

  @override
  State createState() => _RecentTestListViewState();
}

class _RecentTestListViewState extends State<RecentTestsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Recent Tests",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
                color: Colors.white),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 8, 8),
              child: StreamBuilder(
                stream: FirestoreDatabase(
                        uid: context
                            .read<SessionCubit>()
                            .currentUser
                            .value!
                            .documentId)
                    .allTestsStream(context
                        .read<SessionCubit>()
                        .currentUser
                        .value!
                        .organizationId),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    final tests = snapshot.data!.map((doc) {
                      debugPrint(
                          "autoInterpretations : ${doc['autoInterpretations']}");
                      return CtgTest.fromMap(doc, doc["documentId"]);
                    }).toList();

                    return tests.isEmpty
                        ? const Center(
                            child: Text(
                              'No test yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tests.length,
                            shrinkWrap: true, // use this
                            itemBuilder: (buildContext, index) => AllTestCard(
                              testDetails: tests[index],
                              margin: EdgeInsets.all(16.w),
                            ),
                          );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
