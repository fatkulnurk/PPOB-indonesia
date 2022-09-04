import 'package:flutter/material.dart';
import 'package:kerupiah_lite_app/screens/dashboard/order_screen.dart';

import '../screens/dashboard/transactions/show_screen.dart';

class ActionItem extends StatelessWidget {
  const ActionItem(
      {Key? key, required this.id, required this.title, required this.imageUrl})
      : super(key: key);

  final String id;
  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.deepPurple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: InkWell(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(
                id: id.toString(),
                categoryName: title,
              ),
            ),
          )
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: Image.network(
                imageUrl ?? '',
                width: 45,
                height: 45,
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: RichText(
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        strutStyle: const StrutStyle(fontSize: 12.0),
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          text: title,
                        ),
                      ),
                    ),
                  ],
                ),
                // subtitle: Text('Location 1'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
