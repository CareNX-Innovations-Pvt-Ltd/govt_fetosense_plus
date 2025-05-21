// ignore_for_file: avoid_function_literals_in_foreach_calls, unnecessary_null_comparison

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:woozy_search/woozy_search.dart';

import '../../../services/firestore_database.dart';
import "package:collection/collection.dart";

class HistoryPage extends StatefulWidget {
  static const routeName = '/history_page';
  final UserModel user;

  const HistoryPage({Key? key, required this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<HistoryPage> {
  // final TabController _tabController = TabController(length: length, vsync: vsync)
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
          stream: FirestoreDatabase(uid: widget.user.documentId).allTestsStream(widget.user.organizationId),
          builder: (_, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            List<Map<String, dynamic>> data;
            if (snapshot.hasData) {

              if ((snapshot.data!.isEmpty)) {
                return const SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          "No Tests yet",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                );
              }
              String filter = _searchEditingController.text;
              if (filter != null && filter.isNotEmpty) {
                Woozy<Map<String, dynamic>> woozy = Woozy(limit: 5);
                (snapshot.data!).forEach((Map<String, dynamic> e) =>
                    woozy.addEntry(e["name"], value: e));
                final output = woozy.search(filter);
                data = output
                    .map(
                      (e) => e.value!,
                    )
                    .toList();
              } else {
                data = (snapshot.data!)
                    .where(
                      (Map<String, dynamic> e) =>
                          e["name"].toString().toLowerCase().contains(filter),
                    )
                    .toList();
              }
              final tests = snapshot.data
                  ?.map((doc) => CtgTest.fromMap(doc, doc["documentId"]))
                  .toList();

              return getHomeView(data, size);
            } else if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget getHomeView(List<Map<String, dynamic>> data, size) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text('History',
                        //     style: TextStyle(
                        //         color: AppColors.primaryColor,
                        //         fontSize: 22,
                        //         fontWeight: FontWeight.w600)),
                        TextFormField(
                          expands: false,
                          controller: _searchEditingController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.name,
                          onTap: () => setState(() {}),
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              isDense: true,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide( width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              hintText: 'Search by Organization Name',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      ),
                              alignLabelWithHint: false,
                              prefixIcon: const Icon(
                                Icons.search,

                              ),
                              suffixIcon:
                                  _searchEditingController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close,

                                          ),
                                          onPressed: () {
                                            _searchEditingController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null),
                        ),
                        const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /*Icon(
                            Icons
                                .email_outlined,
                            //Icons.access_time_sharp,
                            size: 24,
                            color:
                            kPrimaryColor,
                          ),*/
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "",
                                overflow: TextOverflow.fade,
                                style: TextStyle(

                                    fontSize: 12),
                              ),
                            ]),
                      ],
                    )),
              ),
            ],
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(size.height * 0.01),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.white),
            clipBehavior: Clip.hardEdge,
            child: ListView(
              children: buildDateWiseResults(data),
            ),
          )),
        ],
      ),
    );
  }

  List<Widget> buildDateWiseResults(data) {
    List<Widget> widgets = [];
    var groupByDate = groupBy(
        data,
        (Map<String, dynamic> obj) =>
            ((obj['createdAt']?.toDate() ?? DateTime.now()) as DateTime)
                .getDate("EEEE, dd MMM"));
    groupByDate.forEach((key, value) {
      widgets.add(getGroupHeader(key));
      for (var org in value) {
        widgets.add(Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
            child: InkWell(
              onTap: () {

              },
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(org["name"]),
                    //Text((org["createdAt"].toDate()as DateTime).getDate("hh:mm a")),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${org["test_count"].toString()} tests",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code,

                      ),
                      onPressed: () {

                      },
                    )
                  ],
                ),
              ),
            )));
      }
    });
    return widgets;
  }

  Widget getGroupHeader(String dateTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        dateTime,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary),
        textAlign: TextAlign.start,
      ),
    );
  }
}
