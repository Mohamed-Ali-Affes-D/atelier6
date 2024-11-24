import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GallerieDetails extends StatefulWidget {
  final String keyword;
  const GallerieDetails(this.keyword, {super.key});

  @override
  State<GallerieDetails> createState() => _GallerieDetailsState();
}

class _GallerieDetailsState extends State<GallerieDetails> {
  int currentPage = 1;
  int size = 10;
  int totalpages = 0;
  ScrollController _scrollController = ScrollController();
  List<dynamic> hits = [];
  var galleryData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getGalleryData(widget.keyword);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (currentPage < totalpages && !isLoading) {
          currentPage++;
          getGalleryData(widget.keyword);
        }
      } else if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        if (currentPage > 1 && !isLoading) {
          currentPage--;
          getGalleryData(widget.keyword, isPrevious: true);
        }
      }
    });
  }

  void getGalleryData(String keyword, {bool isPrevious = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    String url =
        "https://pixabay.com/api/?key=15646595-375eb91b3408e352760ee72c8&q=${keyword}&page=${currentPage}&per_page=${size}";
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      setState(() {
        this.galleryData = json.decode(resp.body);
        if (isPrevious) {
          hits.insertAll(0, galleryData['hits']);
        } else {
          hits.addAll(galleryData['hits']);
        }
        totalpages = (galleryData['totalHits'] / size).ceil();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: totalpages == 0
            ? Text('Pas de résultats')
            : Text("${widget.keyword}, page ${currentPage} / ${totalpages}"),
      ),
      body: galleryData == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: hits.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == hits.length && isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Card(
                        color: Colors.teal[300],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            hits[index]['tags'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 1, right: 1),
                      child: Card(
                        child: Image.network(
                          hits[index]['webformatURL'] ?? '',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }
}
