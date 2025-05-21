import 'package:auto_size_text/auto_size_text.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/services/firestore_database.dart';
import 'package:l8fe/ui/test_view.dart';
import 'package:l8fe/ui/widgets/all_test_card.dart';
import 'package:l8fe/ui/widgets/mother_card.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;


class RecentMothersView extends StatefulWidget {
  const RecentMothersView({super.key});

  String get screenName => "RecentTestScreen";

  @override
  State createState() => _RecentTestListViewState();
}

class _RecentTestListViewState extends State<RecentMothersView>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = -1;
  List<Mother> _mothers = [];
  final ScrollController controller = ScrollController();

  bool _isLoading = false;

  String filter = "";

  String _lastFilter = "";

  dynamic _lastDocument;

  @override
  bool get wantKeepAlive => true;
  late Device user;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchEditingController =
      TextEditingController();

  @override
  void initState() {
    user = context.read<SessionCubit>().currentUser.value!;
    _fetchData();
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Text(
            "Recent Tests",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
                color: Colors.white),
          ),*/

          Container(
            width: 0.3.sw,
            padding: EdgeInsets.only(left: 16.w,top: 16.w, bottom: 16.w),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: TextFormField(
                    expands: false,
                    controller: _searchEditingController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.name,
                    onTap: () => setState(() {}),
                    onChanged: (value) {
                      if(value.length>2){
                        filter = value;
                      }else{
                        filter = "";
                      }
                      if(value.isEmpty || filter.isNotEmpty) {
                        _fetchData();
                        debugPrint("_fetchData called $filter");
                      }
                    },
                    onFieldSubmitted: (value) {
                      //todo
                    },
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        hintText: "Search mothers..",
                        hintStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(),
                        alignLabelWithHint: false,
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        suffixIcon: _searchEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                ),
                                onPressed: () {
                                  _searchEditingController.clear();
                                  filter="";
                                  _fetchData();
                                  setState(() {});
                                },
                              )
                            : null),
                  ),
                ),
                CustomMaterialIndicator(
                  onRefresh: ()=>_fetchData(refresh: true), // Your refresh logic
                  backgroundColor: Colors.white,
                  indicatorBuilder: (context, controller) {
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                        value: controller.state.isLoading ? null : math.min(controller.value, 1.0),
                      ),
                    );
                  },
                  child: SizedBox(
                        height: 0.5.sh,
                        child: _mothers.isEmpty
                            ? const Center(
                            child: Text('No mothers yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                    fontSize: 20)))
                            : ListView.builder(
                          key: Key(filter.length>2?filter:"12345"),
                          controller: controller,
                          itemCount: _mothers.length + 1,
                          itemBuilder: (context, index) {
                            debugPrint("list index $index");
                            debugPrint(
                                "list index  lentgh ${_mothers.length}");
                            if (index < _mothers.length) {
                              final item = _mothers[index];

                              debugPrint("inside new code");
                              return MotherCard(
                                key: Key("$index"),
                                motherDetails: item.toJson(),
                                selected: index == _selectedIndex,
                                onClick: onMotherSelected,
                                index: index,
                              );
                            } else {
                              return SizedBox(
                                  height: 0.1.sh,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                        color: _isLoading
                                            ? Colors.white
                                            : Colors.transparent,
                                      )));
                            }
                          },
                      //controller: widget.controller..addListener(_scrollListener),
                    ),
                                   ),
                 )
                /*StreamBuilder(
                    stream: FirestoreDatabase(
                            uid: context
                                .read<SessionCubit>()
                                .currentUser
                                .value!
                                .documentId)
                        .allMothersStream(context
                            .read<SessionCubit>()
                            .currentUser
                            .value!
                            .organizationId),
                    builder: (context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        _mothers = snapshot.data!.map((doc) {
                          debugPrint(
                              "autoInterpretations : ${doc['autoInterpretations']}");
                          return Mother.fromMap(doc, doc["documentId"]);
                        }).toList();


                        *//*ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: _mothers!.length,
                              shrinkWrap: true, // use this
                              itemBuilder: (buildContext, index) =>
                                MotherCard(key: Key("$index"), motherDetails: _mothers![index].toJson(),selected: index == _selectedIndex,onClick:onMotherSelected, index: index,));*//*
                      } else {
                        return const Center(
                            child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ));
                      }
                    }),*/
              ],
            ),
          ),
          Container(
            width: 0.61.sw,
            margin: EdgeInsets.only(right: 16.w,top: 16.w, bottom: 16.w),
            decoration:  BoxDecoration(
              border: Border.all(color: Colors.teal,
                  width: 2.w
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Column(
              children: [
                if (_selectedIndex >= 0 && _mothers != null)
                  SizedBox(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(16.h),
                                color: Colors.teal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                AutoSizeText(
                                  _mothers[_selectedIndex].name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                _mothers[_selectedIndex].doctorName.isNotEmpty?
                                AutoSizeText.rich(
                                  TextSpan(text: "", children: [
                                    TextSpan(text: _mothers[_selectedIndex].doctorName),

                                    TextSpan(
                                        text: "\nDoctor ",
                                        style: TextStyle(
                                            fontSize: 8.sp,
                                            color:
                                            Colors.white54,
                                            fontWeight: FontWeight.w300)),
                                  ]),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.6),
                                      fontWeight: FontWeight.w700),
                                ):const SizedBox(),
                              ],
                            )),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          const TextSpan(text: "AGE"),
                                          const TextSpan(
                                            text: "\nLMP",
                                          ),
                                          const TextSpan(text: "\nEDD"),
                                          const TextSpan(text: "\nG. Age"),
                                          TextSpan(
                                              text: "\nSHORT ",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color:
                                                      Colors.white.withOpacity(0),
                                                  fontWeight: FontWeight.w500)),
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          TextSpan(
                                            text:
                                                " ${_mothers[_selectedIndex].age} years",
                                          ),
                                          TextSpan(
                                            text:
                                                "\n ${DateFormat('dd MMM yyyy').format(_mothers[_selectedIndex].lmp)}",
                                          ),
                                          TextSpan(
                                            text:
                                                "\n ${DateFormat('dd MMM yyyy').format(_mothers[_selectedIndex].edd)}",
                                          ),
                                          TextSpan(
                                            text:
                                                "\n ${_mothers[_selectedIndex].lmp.getGestAge()} weeks",
                                          ),
                                          const TextSpan(
                                            text: "\n ",
                                          )
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                /*Container(
                                  padding: EdgeInsets.all(8.w),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          const TextSpan(text: "Doctor "),

                                          TextSpan(
                                              text: "\nDoctor ",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color:
                                                  Colors.white.withOpacity(0),
                                                  fontWeight: FontWeight.w500)),
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          TextSpan(
                                            text:
                                            " ${_mothers[_selectedIndex].doctorName}",
                                          ),
                                          const TextSpan(
                                            text: "\n ",
                                          )
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),*/
                              ],
                            ),
                          ]),
                      if( BluetoothCTGService.instance.deviceReady.value)
                        Positioned(
                          right: 16.h,
                          bottom: 16.h,
                          child:

                          Container(
                            width: 0.15.sw,
                            //padding: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                            margin: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(30.w)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Theme.of(context).colorScheme.onPrimary,
                                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                                    ])
                            ),
                            child: MaterialButton(
                              //color:   Color(0xFF139DCB) ,
                              height: 80.h,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.w))
                              ),
                              highlightColor: Colors.white.withOpacity(0.5),
                              splashColor: Colors.white.withOpacity(0.5),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_)=> TestView(mom: _mothers[_selectedIndex],)));
                              },
                              child:
                              AutoSizeText(
                                "New test",
                                style: Theme.of(context).textTheme.bodyLarge,),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                    child: (_selectedIndex >= 0 && _mothers != null)
                        ? Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 8, 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1, color: Colors.grey)),
                      ),
                          child: StreamBuilder(
                              stream: FirestoreDatabase(
                                  uid: context
                                      .read<SessionCubit>()
                                      .currentUser
                                      .value!
                                      .documentId)
                                  .allMotherTestsStream(
                                  _mothers[_selectedIndex].documentId),
                              builder: (context,
                                  AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                                if (snapshot.hasData) {
                                  final tests = snapshot.data!.map((doc) {
                                    debugPrint(
                                        "autoInterpretations : ${doc['autoInterpretations']}");
                                    return CtgTest.fromMap(doc, doc["documentId"]);
                                  }).toList();

                                  return tests.isEmpty
                                      ? const Center(
                                      child: Text('No test yet for the mother',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.grey,
                                              fontSize: 20)))
                                      : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tests.length,
                                      shrinkWrap: false, // use this
                                      itemBuilder: (buildContext, index) =>
                                          AllTestCard(width : 0.16.sw, testDetails: tests[index],margin: EdgeInsets.all(8.w),showName: false,));
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.black),
                                      ));
                                }
                              }),
                    )
                        : const Center(
                        child: Text('Select a mother.',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                                fontSize: 20)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onMotherSelected(int index) {
    _selectedIndex = index;
    debugPrint("Mother id : ${_mothers[_selectedIndex].documentId}");
    setState(() {});
  }
  void _scrollListener() {
    if (controller.position.pixels ==
        controller.position.maxScrollExtent) {
      _fetchData();
    }
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (filter.length > 2 && filter == _lastFilter) return;
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    debugPrint("_fetchData called  1 : $filter");

    if(filter.isNotEmpty || refresh){
      _lastDocument = null;
      _mothers.clear();
      _selectedIndex =-1;
    }
    final snapshots = await FirestoreDatabase(uid: user.documentId)
        .allMothersPagination(
            oId: user.organizationId,
            lastDocument: filter.length > 2 ? null : _lastDocument,
            filter: filter);
    if (snapshots.docs.isNotEmpty) {
      debugPrint("Fetched ${snapshots.docs.length} documents");
      debugPrint("Fetched ${snapshots.docs.last.data()} documents");

      final result = snapshots.docs.map((mother) {
        //final m = mother;
        debugPrint("mother  - ${(mother.data() as Map<String, dynamic>)["documentId"]}");
        debugPrint("mother  - ${(mother.data() as Map<String, dynamic>)["name"]}");
        return Mother.fromMap(mother.data() as Map<String, dynamic>, mother.id);
      }).toList();

      if (filter.length > 2 ) {
        _lastFilter = filter;
        controller.animateTo(0,
            duration: const Duration(seconds: 1), curve: Curves.ease);
        _mothers.clear();
      } else if(_lastFilter.isNotEmpty && filter.isEmpty){
        _lastFilter = filter;
        _mothers.clear();
      }

        _mothers.addAll(result);
      if(filter.isEmpty) {
        _lastDocument = snapshots.docs.last;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
