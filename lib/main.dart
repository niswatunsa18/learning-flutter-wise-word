import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Aplikasiku",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade900,
            secondary: Colors.pinkAccent,
            brightness: Brightness.light,
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    history.add(current);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFav([WordPair? pair]) {
    final wordPair = pair ?? current;
    if (favorites.contains(wordPair)) {
      favorites.remove(wordPair);
      notifyListeners();
    } else {
      favorites.add(wordPair);
      notifyListeners();
    }
  }

  void removeHistoryItem(WordPair pair) {
    history.remove(pair);
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavPage();
        break;
      case 2:
        page = const HisPage();
        break;
      default:
        page = const Placeholder();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 16, 180),
        centerTitle: true,
        title: const Text(
          "Apps Random Word",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
          NavigationDestination(icon: Icon(Icons.history), label: "History"),
        ],
      ),
      body: page,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedIndex = 0;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    String snackBarMessage;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
      snackBarMessage = "Removed from favorites";
    } else {
      icon = Icons.favorite_border;
      snackBarMessage = "Added to favorites";
    }
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "My Random Idea:",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              BigCard(pair: pair),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFav();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(snackBarMessage),
                          ),
                        );
                    },
                    icon: Icon(icon),
                    label: const Text("Favorite"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  const SizedBox(width: 25),
                  ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    child: const Text("Generate"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}

// --------------Halaman Fav---------------
class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                "You have ${appState.favorites.length} favorite words:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...appState.favorites.map((wp) => Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: wp.asPascalCase,
                        child: ListTile(
                          title: Text(wp.asPascalCase),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              appState.toggleFav(wp);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${wp.asPascalCase} removed from favorites'),
                                  ),
                                );
                            },
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------Halaman HIS---------------
class HisPage extends StatefulWidget {
  const HisPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HisPageState createState() => _HisPageState();
}

class _HisPageState extends State<HisPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              appState.clearHistory();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('All history cleared'),
                  ),
                );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  "You have generated ${appState.history.length} words:",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...appState.history.map((wp) => Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: wp.asPascalCase,
                          child: ListTile(
                            title: Text(wp.asPascalCase),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                appState.removeHistoryItem(wp);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${wp.asPascalCase} removed from history'),
                                    ),
                                  );
                              },
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
