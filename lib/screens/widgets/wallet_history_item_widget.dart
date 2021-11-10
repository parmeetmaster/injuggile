import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:service_app/models/wallet_history.dart';

class WalletHistoryItemWidget extends StatelessWidget {
  final WalletHistory item;

  const WalletHistoryItemWidget({
    Key key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: ListTile(
            leading:
            FaIcon(FontAwesomeIcons.rupeeSign, size: 30, color: Theme
                .of(context)
                .accentColor,),


          title: Text(
            item.description,
            style: Theme
                .of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat.yMEd().add_jms().format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(item.createdAt) * 1000)),
            style: Theme
                .of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.grey),
          ),
          trailing: Text('${item.currency}${item.amount}'),
        ),
      ),
    ),);
  }
}
