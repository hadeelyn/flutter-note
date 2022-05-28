import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:share/share.dart';

import '../models/note.dart';
import '../database/db_helper.dart';
import '../theme/note_colors.dart';

const light_pink = 0xFFFDFFFC,
    yellow = 0xFFFF595E,
    light_yellow = 0xFF374B4A,
    light_green = 0xFF00B1CC,
    turquoise = 0xFFFFD65C,
    light_cyan = 0xFFB9CACA,
    light_blue = 0x80374B4A,
    plum = 0x3300B1CC,
    misty_rose = 0xCCFF595E,
    light_brown = 0xFFE6C9A9,
    light_gray = 0XFFE9EAEE,
    basic_color = 0xFF1321E0,
    white = 0xFFffffff;

/*
* Read all notes stored in database and sort them based on name 
*/
Future<List<Map<String, dynamic>>> readDatabase() async {
  try {
    NotesDatabase notesDb = NotesDatabase();
    await notesDb.initDatabase();
    List<Map> notesList = await notesDb.getAllNotes();
    //await notesDb.deleteAllNotes();
    await notesDb.closeDatabase();
    List<Map<String, dynamic>> notesData =
        List<Map<String, dynamic>>.from(notesList);
    notesData.sort((a, b) => (a['title']).compareTo(b['title']));
    return notesData;
  } catch (e) {
    return [{}];
  }
}

// Home Screen
class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  // Read Database and get Notes
  List<Map<String, dynamic>> notesData;
  List<int> selectedNoteIds = [];

  // Render the screen and update changes
  void afterNavigatorPop() {
    setState(() {});
  }

  // Long Press handler to display bottom bar
  void handleNoteListLongPress(int id) {
    setState(() {
      if (selectedNoteIds.contains(id) == false) {
        selectedNoteIds.add(id);
      }
    });
  }

  // Remove selection after long press
  void handleNoteListTapAfterSelect(int id) {
    setState(() {
      if (selectedNoteIds.contains(id) == true) {
        selectedNoteIds.remove(id);
      }
    });
  }

  // Delete Note/Notes
  void handleDelete() async {
    try {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      for (int id in selectedNoteIds) {
        int result = await notesDb.deleteNote(id);
      }
      await notesDb.closeDatabase();
    } catch (e) {
    } finally {
      setState(() {
        selectedNoteIds = [];
      });
    }
  }

  // Share Note/Notes
  void handleShare() async {
    String content = '';
    try {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      for (int id in selectedNoteIds) {
        dynamic notes = await notesDb.getNotes(id);
        if (notes != null) {
          content = content + notes['title'] + '\n' + notes['content'] + '\n\n';
        }
      }
      await notesDb.closeDatabase();
    } catch (e) {
    } finally {
      setState(() {
        selectedNoteIds = [];
      });
    }
    await Share.share(content.trim(), subject: content.split('\n')[0]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(basic_color),
        // brightness: Brightness.dark,

        leading: (selectedNoteIds.length > 0
            ? IconButton(
                onPressed: () {
                  setState(() {
                    selectedNoteIds = [];
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: Color(white),
                ),
              )
            :
            //AppBarLeading()
            Container()),

        title: Center(
          child: Text(
            (selectedNoteIds.length > 0
                ? ('Selected ' +
                    selectedNoteIds.length.toString() +
                    '/' +
                    notesData.length.toString())
                : 'My Notes'),
            style: TextStyle(
              color: const Color(white),
            ),
          ),
        ),

        actions: [
          (selectedNoteIds.length == 0
              ? Container()
              : IconButton(
                  onPressed: () {
                    setState(() {
                      selectedNoteIds =
                          notesData.map((item) => item['id'] as int).toList();
                    });
                  },
                  icon: Icon(
                    Icons.done_all,
                    color: Color(turquoise),
                  ),
                ))
        ],
      ),

      //Floating Button
      floatingActionButton: (selectedNoteIds.length == 0
          ? FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: const Color(white),
              ),
              tooltip: 'New Notes',
              backgroundColor: Color(basic_color),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/notes_edit',
                  arguments: [
                    'new',
                    [{}],
                  ],
                ).then((dynamic value) {
                  afterNavigatorPop();
                });
                return;
              },
            )
          : null),

      body: FutureBuilder(
          future: readDatabase(),
          // ignore: missing_return
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              notesData = snapshot.data;
              return Stack(
                children: <Widget>[
                  // Display Notes
                  AllNoteLists(
                    snapshot.data,
                    this.selectedNoteIds,
                    afterNavigatorPop,
                    handleNoteListLongPress,
                    handleNoteListTapAfterSelect,
                  ),

                  // Bottom Action Bar when Long Pressed
                  (selectedNoteIds.length > 0
                      ? BottomActionBar(
                          handleDelete: handleDelete, handleShare: handleShare)
                      : Container()),
                ],
              );
            } else if (snapshot.hasError) {
            } else {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(light_yellow),
                ),
              );
            }
          }),
    );
  }
}

// Display all notes
class AllNoteLists extends StatelessWidget {
  final data;
  final selectedNoteIds;
  final afterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;

  AllNoteLists(
    this.data,
    this.selectedNoteIds,
    this.afterNavigatorPop,
    this.handleNoteListLongPress,
    this.handleNoteListTapAfterSelect,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          dynamic item = data[index];
          return DisplayNotes(
            item,
            selectedNoteIds,
            (selectedNoteIds.contains(item['id']) == false ? false : true),
            afterNavigatorPop,
            handleNoteListLongPress,
            handleNoteListTapAfterSelect,
          );
        });
  }
}

// A Note view showing title, first line of note and color
class DisplayNotes extends StatelessWidget {
  final notesData;
  final selectedNoteIds;
  final selectedNote;
  final callAfterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;

  DisplayNotes(
    this.notesData,
    this.selectedNoteIds,
    this.selectedNote,
    this.callAfterNavigatorPop,
    this.handleNoteListLongPress,
    this.handleNoteListTapAfterSelect,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Material(
        elevation: 1,
        color: (selectedNote == false ? Color(light_pink) : Color(light_blue)),
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            if (selectedNote == false) {
              if (selectedNoteIds.length == 0) {
                Navigator.pushNamed(
                  context,
                  '/notes_edit',
                  arguments: [
                    'update',
                    notesData,
                  ],
                ).then((dynamic value) {
                  callAfterNavigatorPop();
                });
                return;
              } else {
                handleNoteListLongPress(notesData['id']);
              }
            } else {
              handleNoteListTapAfterSelect(notesData['id']);
            }
          },
          onLongPress: () {
            handleNoteListLongPress(notesData['id']);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          color: (selectedNote == false
                              ? Color(NoteColors[notesData['noteColor']]['b'])
                              : Color(misty_rose)),
                          shape: BoxShape.rectangle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: (selectedNote == false
                              ? Text(
                                  notesData['title'][0],
                                  style: TextStyle(
                                    color: Color(light_pink),
                                    fontSize: 21,
                                  ),
                                )
                              : Icon(
                                  Icons.check,
                                  color: Color(light_pink),
                                  size: 21,
                                )),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        notesData['title'] != null ? notesData['title'] : "",
                        style: TextStyle(
                          color: Color(light_yellow),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 4,
                      ),
                      Text(
                        notesData['content'] != null
                            ? notesData['content'].split('\n')[0]
                            : "",
                        style: TextStyle(
                          color: Color(light_blue),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// BottomAction bar contais options like Delete, Share...
class BottomActionBar extends StatelessWidget {
  final VoidCallback handleDelete;
  final VoidCallback handleShare;

  BottomActionBar({
    this.handleDelete,
    this.handleShare,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Material(
          elevation: 2,
          color: Color(light_blue),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Delete
                InkResponse(
                  onTap: () => handleDelete(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.delete,
                        color: Color(light_pink),
                        semanticLabel: 'Delete',
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Color(light_pink),
                        ),
                      ),
                    ],
                  ),
                ),

                // Share
                InkResponse(
                  onTap: () => handleShare(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.share,
                        color: Color(light_pink),
                        semanticLabel: 'Share',
                      ),
                      Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Color(light_pink),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
class AppBarLeading extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Builder(
			builder: (context) => IconButton(
				icon: const Icon(
					Icons.menu,
					color: const Color(turquoise),
				),
				tooltip: 'Menu',
				onPressed: () => Scaffold.of(context).openDrawer(),
			),
		);
	}
}

class DrawerList extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return ListView(
			children: ListTile.divideTiles(
				context: context,
				tiles: [
					Container(
						padding: EdgeInsets.symmetric(vertical: 16.0),
						child: Text(
							'Super Note',
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 29,
								color: Color(light_green
),
							),
						),
					),
					DrawerRow(Icons.share, 'Share App'),
					DrawerRow(Icons.settings, 'About'),
				],
			).toList(),
     );
	}
}

class DrawerRow extends StatelessWidget {
	final leadingIcon, title;

	DrawerRow(this.leadingIcon, this.title);

	@override
	Widget build(BuildContext context) {
		return ListTile(
			leading: Icon(
    		leadingIcon,
    		color: Color(yellow),
    	),
      title: Text(
      	title,
      	style: TextStyle(
      		color: Color(light_yellow),
      		fontSize: 19,
      	),
      ),
      trailing: Icon(
    		Icons.keyboard_arrow_right,
    		color: Color(yellow),
    	),
    	dense: true,
    	onTap: () {},
    	onLongPress: () {},
		);
	}
}
*/