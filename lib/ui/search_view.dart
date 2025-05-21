import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:l8fe/models/doctor_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:l8fe/ui/widgets/mother_card.dart';
import 'package:l8fe/view_models/crud_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';

class SearchView extends StatefulWidget {
  final Doctor? doctor;
  final Organization? organization;
  //HomeView(@required this.doctor);

  const SearchView({super.key, this.doctor, this.organization}) ;
  @override
  // TODO: implement screenName
  String get screenName => "SearchScreen";

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Mother>? mothers;

  final databaseReference = FirebaseFirestore.instance;

  final FocusNode _focus = FocusNode();
  final searchController = TextEditingController();

  String query = "*";

  bool isReplay = false;

  int? count;
  Stream<List<Mother>>? stream;

  StreamController? _postsController;

  Future<dynamic> fetchMother(String query) async {
    debugPrint("fetchMother");
    try {

      if(query.trim().length > 2){


      //var body;

      /*final body = json.encode( {
        "searchDocumentId": widget.doctor!.documentId,
        "orgDocumentId": widget.doctor!.organizationId ?? "NANANANANNANA",
        "searchString": query,
        "apiKey": "ay7px0rjojzbtz0ym0"
      });
      final response = await http
          .post(Uri.parse('https://caremother.co:3006/api/search/searchMother'), headers: {
        "Content-Type": "application/json"
      }, body:body);
      debugPrint("dasdasdddd $body");
      if (response.statusCode == 200) {
        // debugPrint(response.body.toLowerCase());
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load post');
      }*/
      }
    } catch (error) {
      debugPrint(error.toString());
      throw error;
    }
  }

  Stream<dynamic> fetchMothers(String query) async* {
    while (true) {
      yield await fetchMother(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    stream = Provider.of<CRUDModel>(context)
        .fetchMothersAsStreamSearchMothers(widget.doctor!.organizationId, "A");

    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
        ),
        child: ListTile(
            title: const Text(
              "fetosense",
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            ),
            subtitle: TextField(
              autofocus: false,
              style: const TextStyle(fontSize: 18.0, color: Color(0xFFbdc6cf)),
              textCapitalization: TextCapitalization.words,
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search mothers...',
                contentPadding:
                    const EdgeInsets.only(left: 16, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 35),
              onPressed: () {
                setState(() {
                  searchController.clear();
                  query = '*';
                });
              },
            )
            /*Container(
                      margin: EdgeInsets.only(top: 12),
                      child :Icon(Icons.close, size: 35),)*/
            ),
      ),
      Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: FutureBuilder(
                  future: fetchMother(query.toLowerCase()),
                  builder: (context,AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) return Center(child: new Text('No Data Found'));

                    // final results = snapshot.data.docs.where(
                    //     (DocumentSnapshot a) => a
                    //         .data()['name']
                    //         .toString()
                    //         .toLowerCase()
                    //         .contains(query.toLowerCase()));
// debugPrint("Snapshot " + snapshot.data['data'].toString());
                    final mothers = snapshot.data!['data']
                        .map((doc) => doc)
                        .toList();
                    // debugPrint(widget.doctor.organizationId);
                    //return Text("data");

                    return ListView.builder(
                      itemCount: mothers.length,
                      itemBuilder: (buildContext, index) =>SizedBox()
                          //MotherCard(motherDetails: mothers[index],selected: false,),
                    );
                    /*return ListView(
              children: results.map<Widget>((a) => Text(a.data['name'].toString())).toList()
          );*/
                  })))
    ])));
  }

  @override
  void initState() {
    super.initState();
    //_focus.addListener(_onFocusChange);
    searchController.addListener(() {
      debugPrint("${searchController.text}");
      setState(() {
        query = searchController.text.isEmpty ? "*" : searchController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _focus.dispose();
  }

  /* void getDoctor() async {

    final userProvider = Provider.of<CRUDModel>(context);
    await userProvider.getDoctorById("").then((Mother mother) {
      if(mother!=null)
      setState(() {
        doctor = mother;
      });
    });

  }*/

  /* void _handleSearch(String value) {
    if (value.length < 3) {
      setState(() {
        filter = "";
      });
      return;
    } else {
      setState(() {
        filter = value;
      });
    }
  }
*/
  /*Future<List<Mother>> getAllMothers(String text) async {
    Stream<QuerySnapshot> snapshot = Provider.of<CRUDModel>(context)
        .fetchMothersAsStreamSearch(widget.doctor!.organizationId, query);
    snapshot.map((qShot) {
      return qShot.docs
          .map((doc) => Mother.fromMap(doc.data() as Map<String,dynamic>, doc.id))
          .toList();
    });
  }*/
}

/*class MotherSearch extends SearchDelegate {
  final Doctor doctor;
  Stream<List<Mother>> stream;
  MotherSearch(this.doctor, this.stream);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        //close(context, null);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return StreamBuilder(
        stream: FirebaseFirestore.instance;
            .collection('users')
            .where("type", isEqualTo: "mother")
            .where("organizationId", isEqualTo: doctor.organizationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');

          final results = snapshot.data.documents.where((DocumentSnapshot a) =>
              a.data['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()));

          final mothers = results
              .map((doc) => Mother.fromMap(doc.data, doc.documentID))
              .toList();

          return ListView.builder(
            itemCount: mothers.length,
            itemBuilder: (buildContext, index) =>
                MotherCard(motherDetails: mothers[index]),
          );
          */ /*return ListView(
              children: results.map<Widget>((a) => Text(a.data['name'].toString())).toList()
          );*/ /*
        });
  }

  @override
  String get searchFieldLabel => 'Search mothers..';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25.7),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25.7),
          ),
        ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    if (query.length >= 1)
      return StreamBuilder(
          stream: FirebaseFirestore.instance;
              .collection('users')
              .where("type", isEqualTo: "mother")
              .where("organizationId", isEqualTo: doctor.organizationId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');

            final results = snapshot.data.documents.where(
                (DocumentSnapshot a) => a.data['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()));

            final mothers = results
                .map((doc) => Mother.fromMap(doc.data, doc.documentID))
                .toList();

            return ListView.builder(
              itemCount: mothers.length,
              itemBuilder: (buildContext, index) =>
                  MotherCard(motherDetails: mothers[index]),
            );
            */ /*return ListView(
              children: results
                  .map<Widget>((a) => ListTile(
                        title: Text(a.data['name'].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(fontSize: 12)),
                        onTap: () {
                          query = a.data["name"];
                          showResults(context);
                        },
                      ))
                  .toList());*/ /*
          });
    else
      return ListTile(
        title: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Align(
                alignment: Alignment.topCenter,
                child: Text(("Search for registered mothers"),
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontSize: 18)))),
      );
  }
}*/
