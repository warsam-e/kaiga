import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:pull_down_button/pull_down_button.dart';

class KaigaFilter extends StatefulWidget {
  const KaigaFilter({super.key});

  @override
  KaigaFilterState createState() => KaigaFilterState();
}

class KaigaFilterState extends State<KaigaFilter> {
  final manager = KaigaManager();

  @override
  Widget build(BuildContext context) => PullDownButton(
      itemBuilder: itemBuilder,
      buttonBuilder: (_, showMenu) => filterButton(showMenu));

  Widget filterButton(VoidCallback onPressed) => ButtonView(
        const Icon(
          CupertinoIcons.line_horizontal_3_decrease,
          color: CupertinoColors.white,
          size: 35,
        ),
        onPressed: () {},
        // onPressed: onPressed,
      );

  List<PullDownMenuEntry> itemBuilder(BuildContext context) => [
        const PullDownMenuTitle(title: Text('Filter by')),
        PullDownMenuItem.selectable(
            onTap: () {}, title: 'Images', selected: true),
        PullDownMenuItem.selectable(
            onTap: () {}, title: 'Videos', selected: true),
      ];
}
