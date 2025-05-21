import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/constants/my_color_scheme.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/my_user.dart';
import 'package:l8fe/ui/widgets/mother_card.dart';
import 'package:woozy_search/woozy_search.dart';

import '../../services/firestore_database.dart';

import "package:collection/collection.dart";

class MothersListPage extends StatefulWidget {
  final String filter;
  final ScrollController controller;
  final void Function(int index) onMotherSelected;

  const MothersListPage({
    super.key,
    required this.filter,
    required this.controller,
    required this.onMotherSelected,
  });

  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<MothersListPage> {
  late Device user;

  bool _isLoading = false;
  var _lastDocument;
  String _lastFilter = "";

  final List<Mother> _mothers = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    user = context.read<SessionCubit>().currentUser.value!;
    widget.controller.addListener(_scrollListener);
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      //Wakelock.disable();
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _mothers.length + 1,
        itemBuilder: (context, index) {
          debugPrint("list index $index");
          debugPrint("list index  lentgh ${_mothers.length}");
          if (index < _mothers.length) {
            final item = _mothers[index];

            debugPrint("inside new code");
            return MotherCard(
              key: Key("$index"),
              motherDetails: _mothers[index].toJson(),
              selected: index == _selectedIndex,
              onClick: widget.onMotherSelected,
              index: index,
            );
          } else {
            return SizedBox(
              height: 0.1.sh,
              child: Center(
                child: CircularProgressIndicator(
                  color: _isLoading ? null : Colors.transparent,
                ),
              ),
            );
          }
        },
        //controller: widget.controller..addListener(_scrollListener),
      ),
    );
  }

  Future<void> _fetchData() async {
    if (widget.filter.length > 2 && widget.filter == _lastFilter) return;
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final snapshots = await FirestoreDatabase(uid: user.documentId)
        .allMothersPagination(
            oId: user.organizationId,
            lastDocument: widget.filter.length > 2 ? null : _lastDocument,
            filter: widget.filter);
    if (snapshots.docs.isNotEmpty) {
      final result = snapshots.docs.map((mother) {
        return Mother.fromMap(mother.data() as Map<String, dynamic>, mother.id);
      }).toList();

      if (widget.filter.length > 2) {
        _lastFilter = widget.filter;
        widget.controller.animateTo(0,
            duration: const Duration(seconds: 1), curve: Curves.ease);
        _mothers.clear();
      }
      setState(() {
        _mothers.addAll(result);
        _lastDocument = snapshots.docs.last;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (widget.controller.position.pixels ==
        widget.controller.position.maxScrollExtent) {
      _fetchData();
    }
  }
}
