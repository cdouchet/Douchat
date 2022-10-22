import 'package:emojis/emoji.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';

class EmojiSelector extends StatefulWidget {
  const EmojiSelector({super.key});

  @override
  State<EmojiSelector> createState() => _EmojiSelectorState();
}

class _EmojiSelectorState extends State<EmojiSelector> {
  EmojiGroup currentGroup = EmojiGroup.smileysEmotion;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Iterable<Emoji> emojis = Emoji.byGroup(currentGroup);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, left: 12, top: 12),
            child: GridView.builder(
                controller: scrollController,
                itemCount: emojis.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 12),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context, emojis.elementAt(index).char);
                    },
                    child: Text(emojis.elementAt(index).char,
                        style: TextStyle(fontSize: 30)),
                  );
                }),
          )),
      Container(
          color: Colors.white.withOpacity(0.7),
          width: double.maxFinite,
          height: 1,
          margin: EdgeInsets.only(bottom: 12)),
      Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(width: 12),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: EmojiGroup.values.length,
                itemBuilder: (BuildContext context, int index) {
                  switch (EmojiGroup.values[index]) {
                    case (EmojiGroup.smileysEmotion):
                      return _buildCategory(
                          group: EmojiGroup.smileysEmotion,
                          emoji: Emojis.grinningFaceWithBigEyes);
                    case (EmojiGroup.animalsNature):
                      return _buildCategory(
                          group: EmojiGroup.animalsNature,
                          emoji: Emojis.mapleLeaf);
                    case (EmojiGroup.foodDrink):
                      return _buildCategory(
                          group: EmojiGroup.foodDrink,
                          emoji: Emojis.cocktailGlass);
                    case (EmojiGroup.activities):
                      return _buildCategory(
                          group: EmojiGroup.activities,
                          emoji: Emojis.controlKnobs);
                    case (EmojiGroup.travelPlaces):
                      return _buildCategory(
                          group: EmojiGroup.travelPlaces, emoji: Emojis.taxi);
                    case (EmojiGroup.objects):
                      return _buildCategory(
                          group: EmojiGroup.objects, emoji: Emojis.screwdriver);
                    case (EmojiGroup.symbols):
                      return _buildCategory(
                          group: EmojiGroup.symbols, emoji: Emojis.redHeart);
                    case (EmojiGroup.flags):
                      return _buildCategory(
                          group: EmojiGroup.flags, emoji: Emojis.whiteFlag);
                    case (EmojiGroup.peopleBody):
                      return _buildCategory(
                          group: EmojiGroup.peopleBody, emoji: Emojis.man);
                    case (EmojiGroup.component):
                      return _buildCategory(
                          group: EmojiGroup.component, emoji: "?");
                  }
                }),
          ))
    ]);
  }

  GestureDetector _buildCategory(
          {required String emoji, required EmojiGroup group}) =>
      GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            currentGroup = group;
            setState(() {});
            scrollController.jumpTo(0);
          },
          child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: currentGroup == group
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent),
              child: Text(emoji, style: TextStyle(fontSize: 24))));
}
