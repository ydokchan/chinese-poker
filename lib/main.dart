//hey

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:reorderables/reorderables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vbnvtknezwabovbrrknw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZibnZ0a25lendhYm92YnJya253Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNDM3MTgsImV4cCI6MjA3MTkxOTcxOH0.8bp3don3rUivXmKD8so3x9Niz8imCoUUyBjmvcafPxQ',
  );

  final prefs = await SharedPreferences.getInstance();
  final loggedInUser = prefs.getString('loggedInUser');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // switches automatically
      // LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey, // primary color for your app
        scaffoldBackgroundColor: Colors.white, // background for screens
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey, // AppBar color
          foregroundColor: Color.fromARGB(
            255,
            0,
            0,
            0,
          ), // AppBar text/icon color
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              225,
              225,
              225,
            ), // inside color
            foregroundColor: const Color.fromARGB(
              255,
              0,
              0,
              0,
            ), // text/icon color
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 43, 43, 43),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 43, 43, 43),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              43,
              43,
              43,
            ), // inside color
            foregroundColor: const Color.fromARGB(
              255,
              255,
              255,
              255,
            ), // text/icon color
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
          brightness: Brightness.dark,
        ),
      ),

      home: HomeScreen(isLoggedIn: loggedInUser != null),
    ),
  );
}

// =================== HOME SCREEN ===================
class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;

  const HomeScreen({super.key, required this.isLoggedIn});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('loggedInUser');
    });
  }

  Future<void> preGameCheck() async {
    if (_currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGameScreen()),
    ).then((_) => _loadCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chinese Poker"), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ).then((_) => _loadCurrentUser());
                      },
                      child: const Text("Login"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: preGameCheck,
                      child: const Text("Join Game"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StatsScreen(currentUser: _currentUser),
                          ),
                        ).then((_) => _loadCurrentUser());
                      },
                      child: const Text("Stats"),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _currentUser != null
                    ? "Logged in as: $_currentUser"
                    : "Not logged in",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedInUser'); // remove saved user
        setState(() {
          _currentUser = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signed out successfully")),
        );
      },
      child: const Icon(Icons.logout),
      tooltip: "Sign Out",
    ),*/
    );
  }
}

// =================== LOGIN SCREEN ===================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> saveUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> _login() async {
    final supabase = Supabase.instance.client;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }
    try {
      // response will be a Map<String, dynamic>
      final response = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The username does not exist")),
        );
        return;
      }

      // check password match
      if (response['password'] != password) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Incorrect password")));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInUser', username);

      // ✅ successful login
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error logging in")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 4),
              ElevatedButton(onPressed: _login, child: const Text("Confirm")),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountScreen(),
                    ),
                  );
                },
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== CREATE ACCOUNT SCREEN ===================
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _createAccount() async {
    final supabase = Supabase.instance.client;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // show error if either field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    final response = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    // check password match
    if (response == null) {
    } else if (response['username'] == username) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username already exists, pick another one"),
        ),
      );
      return;
    }

    await supabase.from('users').insert({
      'username': username,
      'total_wins': 0,
      'total_games': 0,
      'password': password,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created! Please login with your new account"),
      ),
    );

    Navigator.pop(context); // go back after success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => {_createAccount()},
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== STATS SCREEN ===================
class StatsScreen extends StatefulWidget {
  final String? currentUser;
  const StatsScreen({super.key, this.currentUser});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? totalGames;
  int? totalWins;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (widget.currentUser == null) return;

    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('users')
        .select()
        .eq('username', widget.currentUser)
        .maybeSingle();

    if (response != null) {
      setState(() {
        totalGames = response['total_games'];
        totalWins = response['total_wins'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Games: ${totalGames ?? 0}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Wins: ${totalWins ?? 0}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== JOIN GAME SCREEN ===================
class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final supabase = Supabase.instance.client;

  late RealtimeChannel gamesChannel;
  List<Map<String, dynamic>> games = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _finishStaleGames();
    await _fetchGames();
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    gamesChannel = supabase.channel('join_games_channel');

    // Listen for all Postgres changes
    gamesChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'games'),
      (payload, [ref]) {
        _fetchGames(); // refresh whenever an insert/update/delete happens
      },
    );

    gamesChannel.subscribe();
  }

  @override
  void dispose() {
    supabase.removeChannel(gamesChannel);
    super.dispose();
  }

  Future<void> _finishStaleGames() async {
    final twentyMinutesAgo = DateTime.now().toUtc().subtract(
      const Duration(minutes: 20),
    );

    await supabase
        .from('games')
        .update({'status': 'finished'})
        .lt('updated_at', twentyMinutesAgo.toIso8601String())
        .in_('status', ['open', 'running']);

    await supabase
        .from('active_players')
        .delete()
        .lt('updated_at', twentyMinutesAgo.toIso8601String());

    await supabase
        .from('messages')
        .delete()
        .lt('sent_at', twentyMinutesAgo.toIso8601String());
  }

  Future<void> _fetchGames() async {
    final response = await supabase
        .from('games')
        .select('id, game_name, status, created_at, password')
        .neq('status', 'finished')
        .neq('status', 'running');

    final fetchedGames = List<Map<String, dynamic>>.from(
      response as List<dynamic>,
    );

    // Sort manually: open -> running -> finished
    fetchedGames.sort((a, b) {
      const order = {'open': 0, 'running': 1, 'finished': 2};
      final aValue = order[a['status']] ?? 3;
      final bValue = order[b['status']] ?? 3;
      return aValue.compareTo(bValue);
    });

    setState(() {
      games = fetchedGames;
    });
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enter Game Password"),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: "Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Game"), centerTitle: true),
      body: games.isEmpty
          ? const Center(child: Text("No games available"))
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final gameName = game['game_name'] ?? "Unnamed Game";
                final status = game['status'] ?? "unknown";
                final hasPassword = (game['password'] ?? '').isNotEmpty;
                final gameId = game['id'];

                return Center(
                  child: SizedBox(
                    width: 300,
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(gameName, textAlign: TextAlign.center),
                            const SizedBox(width: 6),
                            if (hasPassword) const Icon(Icons.lock, size: 18),
                          ],
                        ),
                        subtitle: Text(
                          "Status: $status",
                          textAlign: TextAlign.center,
                        ),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final currentUser =
                              prefs.getString('loggedInUser') ?? 'Guest';

                          if (hasPassword) {
                            if (!context.mounted) return;
                            final entered = await _showPasswordDialog(context);
                            if (entered == null) return; // cancelled
                            if (entered != game['password']) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Wrong password")),
                              );
                              return;
                            }
                          }

                          // Check if player already exists
                          final existingPlayer = await supabase
                              .from('active_players')
                              .select('username')
                              .eq('game_id', gameId)
                              .eq('username', currentUser)
                              .maybeSingle();

                          if (existingPlayer != null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("You are already in this game"),
                              ),
                            );
                            return;
                          }

                          await supabase.from('active_players').insert({
                            'game_id': gameId,
                            'username': currentUser,
                            'updated_at': DateTime.now()
                                .toUtc()
                                .toIso8601String(),
                            'cards_remaining': -1,
                            'passed_current_hand': false,
                          });

                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LobbyScreen(
                                gameId: gameId.toString(),
                                gameName: gameName,
                                playerName: currentUser,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "createBtn",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGameScreen()),
          );
        },
        child: const Icon(Icons.add_circle_outline_outlined),
      ),
    );
  }
}

// =================== CREATE ROOM SCREEN ===================
class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _requirePassword = false;

  void _confirm() async {
    final gameName = _gameNameController.text.trim();
    final password = _passwordController.text.trim();

    if (gameName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Game name cannot be empty")),
      );
      return;
    }

    if (_requirePassword && password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password cannot be empty")));
      return;
    }

    await supabase.from('games').insert({
      'game_name': gameName,
      'password': password,
    });

    // For now, just pop back with the data
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Game"),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game name
            TextField(
              controller: _gameNameController,
              decoration: const InputDecoration(
                labelText: "Game Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Require password checkbox
            Row(
              children: [
                Checkbox(
                  value: _requirePassword,
                  onChanged: (value) {
                    setState(() {
                      _requirePassword = value ?? false;
                    });
                  },
                ),
                const Text("Require Password"),
              ],
            ),

            // Password field (only shows if checked)
            if (_requirePassword) ...[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Confirm button (bottom center)
            Center(
              child: ElevatedButton(
                onPressed: _confirm,
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== LOBBY SCREEN ===================
class LobbyScreen extends StatefulWidget {
  final String gameId;
  final String gameName;
  final String playerName;

  const LobbyScreen({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.playerName,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final SupabaseClient supabase;
  List<dynamic> players = [];
  late RealtimeChannel lobbyChannel;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;

    _joinGame();
    _fetchPlayers();
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    lobbyChannel = supabase.channel('lobby_channel_${widget.gameId}');

    lobbyChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'active_players'),
      (payload, [ref]) {
        _fetchPlayers(); // refresh whenever an insert/update/delete happens
        _loadAllPlayers();
      },
    );

    lobbyChannel.subscribe();
  }

  Future<void> _joinGame() async {
    final exists = await supabase
        .from('active_players')
        .select()
        .eq('game_id', widget.gameId)
        .eq('username', widget.playerName)
        .maybeSingle();

    if (exists == null) {
      await supabase.from('active_players').insert({
        'game_id': widget.gameId,
        'username': widget.playerName,
      });
    }
  }

  Future<void> _loadAllPlayers() async {
    if (_hasStarted) return;
    final game = await supabase
        .from('games')
        .select()
        .eq('id', widget.gameId)
        .single();

    if (game['status'] == 'running' && !_hasStarted) {
      _startGame();
    }
  }

  Future<void> _fetchPlayers() async {
    final response = await supabase
        .from('active_players')
        .select()
        .eq('game_id', widget.gameId);

    setState(() {
      players = response;
    });
  }

  Future<void> _startGame() async {
    if (_hasStarted) return; // ✅ double protection
    _hasStarted = true;
    try {
      // 1️⃣ Fetch players in this game from the DB
      final response = await supabase
          .from('active_players')
          .select()
          .eq('game_id', widget.gameId);

      if (!mounted) return;

      final playerCount = response.length;

      if (playerCount >= 0) {
        // 2️⃣ Enough players: start the game

        final response = await supabase
            .from('games')
            .select()
            .eq('id', widget.gameId)
            .single();

        if (response['status'] == 'running') {
          // already running
          // Navigate to GameScreen
        } else {
          // not running yet, generate cards
          await supabase
              .from('games')
              .update({'status': 'running'})
              .eq('id', widget.gameId);

          // Generate and assign cards to each player
          // 1️⃣ Full deck
          List<String> suits = ["♦", "♣", "♥", "♠"];
          List<String> ranks = [
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "J",
            "Q",
            "K",
            "A",
            "2",
          ];
          List<String> deck = [
            for (var s in suits)
              for (var r in ranks) "$r $s",
          ];

          // 2️⃣ Shuffle
          deck.shuffle();

          // 3️⃣ Even distribution with extras
          int baseCount = deck.length ~/ players.length;
          int extra = deck.length % players.length;
          int index = 0;

          for (int i = 0; i < players.length; i++) {
            int count = baseCount + (i < extra ? 1 : 0);
            List<String> hand = deck.sublist(index, index + count);
            index += count;

            String player = players[i]['username'];

            // update that player’s row
            await supabase
                .from('active_players')
                .update({'cards_remaining': count, 'cards_in_hand': hand})
                .eq('game_id', widget.gameId)
                .eq('username', player);
          }
          // 6️⃣ Initialize turn order
          await initializeTurnOrder(widget.gameId);
        }

        supabase.removeChannel(lobbyChannel);

        // Navigate to GameScreen
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              gameId: widget.gameId,
              playerName: widget.playerName,
              gameName: widget.gameName,
            ),
          ),
        );
      } else {
        // 3️⃣ Not enough players
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Need at least 2 players to start")),
        );
      }
    } catch (e) {
      print('Error starting game: $e');
    }
  }

  Future<void> initializeTurnOrder(String gameId) async {
    final rows = await supabase
        .from('active_players')
        .select('username, cards_in_hand')
        .eq('game_id', gameId);

    final players = List<Map<String, dynamic>>.from(rows);

    if (players.isEmpty) return;

    // Find who has 3 ♦
    int startIdx = players.indexWhere((p) {
      final hand = (p['cards_in_hand'] as List?)?.cast<String>() ?? const [];
      return hand.contains('3 ♦');
    });

    if (startIdx == -1) startIdx = 0; // fallback if no “3 ♦” found yet

    final orderedUsernames = [
      ...players.sublist(startIdx).map((p) => p['username'] as String),
      ...players.sublist(0, startIdx).map((p) => p['username'] as String),
    ];

    await supabase
        .from('games')
        .update({
          'turn_order': orderedUsernames,
          'current_turn_player_username': orderedUsernames.first,
        })
        .eq('id', gameId);
  }

  Future<void> _leaveGame({bool navigateBack = true}) async {
    await supabase
        .from('active_players')
        .delete()
        .eq('game_id', widget.gameId)
        .eq('username', widget.playerName);

    if (navigateBack && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _leaveGame(navigateBack: false); // cleanup only
    supabase.removeChannel(lobbyChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game: ${widget.gameName}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveGame,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          const Text(
            "Players:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: players.isEmpty
                ? const Center(child: Text("No players yet"))
                : ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return ListTile(title: Text(player['username']));
                    },
                  ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _startGame,
            child: const Text("Start Game"),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// =================== HAND TYPE ENUM ===================
enum HandType {
  invalid,
  empty,
  single,
  pair,
  custom67,
  twoPair,
  triple,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
}

class PlayingCard {
  final String rank;
  final String suit;
  bool selected;

  PlayingCard({required this.rank, required this.suit, this.selected = false});

  factory PlayingCard.fromString(String s) {
    final parts = s.split(" ");
    return PlayingCard(rank: parts[0], suit: parts[1]);
  }

  @override
  String toString() => "$rank $suit";
}
// =================== GAME SCREEN ===================

class GameScreen extends StatefulWidget {
  final String gameId;
  final String gameName;
  final String playerName;

  const GameScreen({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.playerName,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> players = [];

  Map<String, int> cardsRemaining = {};
  List<String> turnOrder = [];
  String? currentTurnPlayer;

  List<String> inPlayArea = [];
  List<PlayingCard> myHand = [];

  List<PlayingCard> get selectedCards =>
      myHand.where((c) => c.selected).toList();

  bool initialSort = false;
  bool startOfGame = true;
  bool startOfRound = true;

  int playersPassedThisHand = 0;
  int numberOfPlayers = 0;

  late RealtimeChannel gameChannel;

  bool _chatVisible = false; // initially hidden
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];

  static const rankOrder = [
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K",
    "A",
    "2",
  ];

  static const suitOrder = ["♦", "♣", "♥", "♠"];

  @override
  void initState() {
    super.initState();
    _subscribeToRealtime();

    // Load this player's hand from Supabase and sort it
    _loadMyHand();

    // Load turn order and current turn player
    _loadTurnOrder();
    _loadCardsRemainingAndPassedState();

    //Reload play area
    _loadPlayArea();


    // Load number of players
    _loadNumberOfPlayers();
  }

  Future<void> _loadNumberOfPlayers() async {
    final rows = await supabase
        .from('active_players')
        .select('username')
        .eq('game_id', widget.gameId);

    setState(() {
      numberOfPlayers = rows.length;
    });
  }

  // Realtime handling
  void _subscribeToRealtime() {
    gameChannel = supabase.channel('game_channel_${widget.gameId}');

    gameChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'messages',
        filter: 'game_id=eq.${widget.gameId}',
      ),
      (payload, [ref]) {
        _fetchMessages(); // refresh whenever an insert/update/delete happens
      },
    );

    gameChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'games',
        filter: 'id=eq.${widget.gameId}',
      ),
      (payload, [ref]) {
        _reloadGameState();
      },
    );

    gameChannel.subscribe();
  }

  @override
  void dispose() {
    _chatController.dispose();
    supabase.removeChannel(gameChannel);
    super.dispose();
  }

  //
  void _reloadGameState() {
    // Reload other players and turn info
    _loadTurnOrder();
    _loadCardsRemainingAndPassedState();

    //Reload play area
    _loadPlayArea();

    // Check for end of round/game
    _checkEndOfRoundOrGame();
  }

  Future<void> _checkEndOfRoundOrGame() async {

    playersPassedThisHand = await supabase.from('games').select('players_passed').eq('id', widget.gameId).single().then((res) => res['players_passed'] ?? 0);

    if (myHand.isEmpty) {
      // This player has won the game
      print("${widget.playerName} has won the game!");
    } else if (playersPassedThisHand >= numberOfPlayers - 1) {
      // All other players have passed, round over
      print("${widget.playerName} has won the game!");

      Future<String?> nextPlayer = returnNextPlayer(currentTurnPlayer!);

      // Reset for next round, but keep the same turn order
      await supabase.from('games').update({
        'start_of_round': true,
        'players_passed': 0,
        'current_turn_player_username': await nextPlayer,
        'in_play_area': [],
      }).eq('id', widget.gameId);

      await supabase.from('active_players').update({
        'passed_current_hand': false,
      }).eq('game_id', widget.gameId);

      print('Round reset');
    }
  }

  //Message logic
  Future<void> _fetchMessages() async {
    final msgs = await supabase
        .from('messages')
        .select()
        .eq('game_id', widget.gameId)
        .order('sent_at');

    if (!mounted) return;

    setState(() {
      chatMessages = List<Map<String, dynamic>>.from(msgs);
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    await supabase.from('messages').insert({
      'game_id': widget.gameId,
      'username': widget.playerName,
      'content': message.trim(),
      'sent_at': DateTime.now().toUtc().toIso8601String(), // safe to provide
    });

    _chatController.clear();

    if (!mounted) return;
    FocusScope.of(context).unfocus(); // close keyboard

    // Refresh immediately after sending
    _fetchMessages();
  }

  // Other players' UI Widget
  Widget _buildOtherPlayers() {
    if (turnOrder.isEmpty) {
      return const SizedBox(height: 50);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      height: 50,
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: turnOrder.map((player) {
          final isTurn = (player == currentTurnPlayer);
          final cardCount = cardsRemaining[player] ?? 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isTurn ? Colors.yellow.shade700 : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isTurn ? Colors.orange : Colors.white30,
                width: isTurn ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: isTurn ? Colors.black : Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  player,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTurn ? Colors.black : Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "$cardCount",
                  style: TextStyle(
                    color: isTurn ? Colors.black87 : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _loadTurnOrder() async {
    // Load turn order and current turn player from Supabase
    var data = {};

    if (startOfGame) {
      data = await supabase
          .from('games')
          .select(
            'turn_order, current_turn_player_username, start_of_game, start_of_round, players_passed',
          )
          .eq('id', widget.gameId)
          .single();

      startOfGame = data['start_of_game'] ?? true;
      playersPassedThisHand = data['players_passed'] ?? 0;
    } else {
      data = await supabase
          .from('games')
          .select('turn_order, current_turn_player_username, start_of_round, players_passed')
          .eq('id', widget.gameId)
          .single();
    }
    startOfRound = data['start_of_round'] ?? false;
    playersPassedThisHand = data['players_passed'] ?? 0;


    if (!mounted) return;

    setState(() {
      turnOrder = List<String>.from(data['turn_order']);
      currentTurnPlayer = data['current_turn_player_username'];
    });
  }

  Future<void> _loadCardsRemainingAndPassedState() async {
    final data = await supabase
        .from('active_players')
        .select('username, cards_remaining, passed_current_hand')
        .eq('game_id', widget.gameId);

    if (!mounted) return;

    
    setState(() {
      cardsRemaining = {
        for (var p in data) p['username']: p['cards_remaining'] as int,
      };
    });
  }

  // In-play area widget
  Widget _buildPlayArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Text(
            "Play Area",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          //const SizedBox(height: 2),
          Center(
            child: Wrap(
              spacing: 8, // space between cards
              runSpacing: 8, // space between rows if cards wrap
              alignment: WrapAlignment.center, // horizontal centering
              children: inPlayArea.map((c) {
                return CardWidget(
                  card: PlayingCard.fromString(c),
                  onTap: () => {},
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _playSelectedCards() async {
    final selected = myHand
        .where((c) => c.selected)
        .map((c) => c.toString())
        .toList();

    if (selected.isEmpty) return;

    // Check if it's this player's turn
    if (currentTurnPlayer != widget.playerName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid play: not your turn!")),
      );
      return;
    }

    // Check if the play is valid
    if (!canPlay(selected, inPlayArea)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid play: must match type and be higher than the play area!",
          ),
        ),
      );
      return;
    }

    // Check if start of game and must play 3 ♦
    if (startOfGame) {
      if (!selected.contains('3 ♦')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid play: first play must include 3 ♦"),
          ),
        );
        return;
      } else {
        startOfGame = false; // only for the very first play
        startOfRound = false; // reset start of round as well
      }
    } else if (startOfRound) {
      startOfRound = false; // reset start of round after the first play
    }

    //Sort selected cards before playing
    selected.sort(
      (a, b) => cardValueFromString(a).compareTo(cardValueFromString(b)),
    );

    setState(() {
      inPlayArea.clear();
      inPlayArea.addAll(selected);
      myHand.removeWhere((c) => c.selected);
      for (var c in myHand) {
        c.selected = false;
      }
    });

    //Move Turn to next player
    Future<String?> nextPlayer = returnNextPlayer(currentTurnPlayer!);
    //Supabase updates
    await supabase
        .from('games')
        .update({
          'in_play_area': inPlayArea,
          'current_turn_player_username': await nextPlayer,
          'start_of_game': startOfGame,
          'start_of_round': startOfRound,
        })
        .eq('id', widget.gameId);

    await supabase
        .from('active_players')
        .update({'cards_remaining': myHand.length})
        .eq('game_id', widget.gameId)
        .eq('username', widget.playerName);
  }

  int cardValueFromString(String card) {
    final parts = card.split(" "); // ["3", "♣"]
    final rank = parts[0];
    var suit = parts[1];

    // normalize suit in case there are hidden variation selectors
    suit = suit.replaceAll('\uFE0F', '').replaceAll('\uFE0E', '');

    final rankIndex = rankOrder.indexOf(rank);
    final suitIndex = suitOrder.indexOf(suit);

    if (rankIndex == -1 || suitIndex == -1) {
      throw Exception("Invalid card: $card");
    }

    return rankIndex * 4 + suitIndex;
  }

  bool canPlay(List<String> selected, List<String> playArea) {
    if (selected.isEmpty) return false;

    final selectedType = getHandTypeFromStrings(selected);
    final inPlayType = getHandTypeFromStrings(playArea);

    // Invalid hand → cannot play
    if (selectedType == HandType.invalid) return false;

    // Empty play area → any valid hand allowed
    if (inPlayType == HandType.empty) return true;

    // Type mismatch → invalid play
    if (selectedType != inPlayType) return false;

    // Same type → compare by highest card
    return handValue(selected) > handValue(playArea);
  }

  int handValue(List<String> cards) {
    // Highest card in the hand determines strength
    return cards.map(cardValueFromString).reduce((a, b) => a > b ? a : b);
  }

  void _loadPlayArea() async {
    final data = await supabase
        .from('games')
        .select('in_play_area')
        .eq('id', widget.gameId)
        .single();

    if (!mounted) return;

    setState(() {
      inPlayArea = List<String>.from(data['in_play_area'] ?? []);
    });
  }

  // Determine hand type from list of card strings
  HandType getHandTypeFromStrings(List<String> cards) {
    switch (cards.length) {
      case 0:
        return HandType.empty;
      case 1:
        return HandType.single;
      case 2:
        if (_isPair(cards)) return HandType.pair;
        break;
      case 3:
        if (_isTriple(cards)) return HandType.triple;
        break;
      case 4:
        if (_isFourOfAKind(cards)) return HandType.fourOfAKind;
        if (_isTwoPair(cards)) return HandType.twoPair;
        break;
      case 5:
        if (_isStraightFlush(cards)) return HandType.straightFlush;
        if (_isFullHouse(cards)) return HandType.fullHouse;
        if (_isStraight(cards)) return HandType.straight;
        if (_isFlush(cards)) return HandType.flush;
        break;
    }

    return HandType.invalid;
  }

  bool _isPair(List<String> cards) {
    if (cards.length != 2) return false;
    final rank1 = cards[0].split(" ")[0];
    final rank2 = cards[1].split(" ")[0];
    return rank1 == rank2;
  }

  bool _isTriple(List<String> cards) {
    if (cards.length != 3) return false;
    final rank = cards[0].split(" ")[0];
    return cards.every((c) => c.split(" ")[0] == rank);
  }

  bool _isFourOfAKind(List<String> cards) {
    if (cards.length != 4) return false;
    final rank = cards[0].split(" ")[0];
    return cards.every((c) => c.split(" ")[0] == rank);
  }

  bool _isTwoPair(List<String> cards) {
    if (cards.length != 4) return false;
    final ranks = cards.map((c) => c.split(" ")[0]).toList();
    final uniqueRanks = ranks.toSet();
    if (uniqueRanks.length != 2) return false;
    final rankCounts = uniqueRanks
        .map((r) => ranks.where((x) => x == r).length)
        .toList();
    return rankCounts.every((count) => count == 2);
  }

  bool _isStraight(List<String> cards) {
    if (cards.length != 5) return false;
    final ranks = cards.map((c) => c.split(" ")[0]).toList();
    final rankIndices = ranks.map((r) => rankOrder.indexOf(r)).toList();
    rankIndices.sort();
    for (int i = 0; i < rankIndices.length - 1; i++) {
      if (rankIndices[i + 1] != rankIndices[i] + 1) {
        return false;
      }
    }
    return true;
  }

  bool _isFlush(List<String> cards) {
    if (cards.length != 5) return false;
    final suit = cards[0].split(" ")[1];
    return cards.every((c) => c.split(" ")[1] == suit);
  }

  bool _isFullHouse(List<String> cards) {
    if (cards.length != 5) return false;
    final ranks = cards.map((c) => c.split(" ")[0]).toList();
    final uniqueRanks = ranks.toSet();
    if (uniqueRanks.length != 2) return false;
    final rankCounts = uniqueRanks
        .map((r) => ranks.where((x) => x == r).length)
        .toList();
    return (rankCounts.contains(3) && rankCounts.contains(2));
  }

  bool _isStraightFlush(List<String> cards) {
    return _isStraight(cards) && _isFlush(cards);
  }

  void _passTurn() async{
    if (currentTurnPlayer != widget.playerName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid action: not your turn!")),
      );
      return;
    }

    // If start of round, cannot pass
    if (startOfRound) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid action: cannot pass at start of round!"),
        ),
      );
      return;
    }
    //Supabase updates
    Future<String?> nextPlayer = returnNextPlayer(currentTurnPlayer!);
    await supabase.from('games').update({
      'current_turn_player_username': await nextPlayer,
      'players_passed': playersPassedThisHand + 1,
    }).eq('id', widget.gameId);

    await supabase.from('active_players').update({
      'passed_current_hand': true,
    }).eq('game_id', widget.gameId).eq('username', widget.playerName);
    // Move turn to next player
    setState(() {
    });
  }

Future<String?> returnNextPlayer(String currentPlayer) async {
  // Load turn order
  final gameRow = await supabase
      .from('games')
      .select('turn_order')
      .eq('id', widget.gameId)
      .single();

  final List<dynamic> turnOrder = gameRow['turn_order'];

  // Load player pass states
  final passRows = await supabase
      .from('active_players')
      .select('username, passed_current_hand')
      .eq('game_id', widget.gameId);  // <-- FIXED HERE

  // Build map: username -> has passed
  final Map<String, bool> passedMap = {};
  for (final row in passRows) {
    passedMap[row['username']] = (row['passed_current_hand'] == true);
  }

  // Find index of current player in turn order
  final int currentIndex = turnOrder.indexOf(currentPlayer);
  if (currentIndex == -1) return null;

  // Find the next player who has NOT passed
  for (int i = 1; i <= turnOrder.length; i++) {
    final int checkIndex = (currentIndex + i) % turnOrder.length;
    final String nextCandidate = turnOrder[checkIndex];

    final hasPassed = passedMap[nextCandidate] ?? false;

    if (!hasPassed) {
      return nextCandidate;
    }
  }

  // All players passed → end of round
  return null;
}



  //Player's hand
  Widget _buildPlayerHand() {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ReorderableWrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          needsLongPressDraggable: false, // or false if you want instant drag
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final card = myHand.removeAt(oldIndex);
              myHand.insert(newIndex, card);
            });
          },
          children: myHand.map((card) {
            return CardWidget(
              key: ValueKey(
                '${card.suit}${card.rank}',
              ), // must have unique key!
              card: card,
              onTap: () {
                setState(() {
                  card.selected = !card.selected;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _loadMyHand() async {
    final data = await supabase
        .from('active_players')
        .select('cards_in_hand')
        .eq('game_id', widget.gameId)
        .eq('username', widget.playerName)
        .single();

    final List<dynamic> array = data['cards_in_hand'];

    setState(() {
      myHand = array.map((s) => PlayingCard.fromString(s.toString())).toList();
    });

    if (!initialSort) {
      _sortHand();
      initialSort = true;
    }
  }

  void _sortHand() {
    setState(() {
      myHand.sort((a, b) {
        final r = rankOrder
            .indexOf(a.rank)
            .compareTo(rankOrder.indexOf(b.rank));
        if (r != 0) return r;
        return suitOrder.indexOf(a.suit).compareTo(suitOrder.indexOf(b.suit));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.gameName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Main game UI
          Column(
            children: [
              _buildOtherPlayers(),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        const Spacer(flex: 3),

                        // --- In-play area (center) ---
                        Align(
                          alignment: Alignment.center,
                          child: _buildPlayArea(),
                        ),

                        const Spacer(flex: 1),

                        // --- Your hand (centered) ---
                        Align(
                          alignment: Alignment.center,
                          child: _buildPlayerHand(),
                        ),

                        // --- Space reserved for FABs ---
                        const Spacer(flex: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // --- FABs go here (behind chat panel) ---
          // Inside your Stack in the body
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 24,
            left: _chatVisible ? null : 16,
            right: _chatVisible ? 16 : null,
            child: _chatVisible
                // Stack vertically on the right
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: "passButton",
                        onPressed: () {
                          _passTurn();
                        },
                        child: const Icon(Icons.cancel_sharp),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "chatButton",
                        onPressed: () {
                          setState(() {
                            _chatVisible = !_chatVisible;
                          });
                        },
                        child: const Icon(Icons.chat),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "playButton",
                        onPressed: () {
                          _playSelectedCards();
                        },
                        child: const Icon(Icons.double_arrow),
                      ),
                    ],
                  )
                // Spread evenly across screen
                : SizedBox(
                    width: MediaQuery.of(context).size.width - 32, // padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingActionButton(
                          heroTag: "passButton",
                          onPressed: () {
                            _passTurn();
                          },
                          child: const Icon(Icons.cancel_sharp),
                        ),
                        FloatingActionButton(
                          heroTag: "chatButton",
                          onPressed: () {
                            setState(() {
                              _chatVisible = !_chatVisible;
                            });
                          },
                          child: const Icon(Icons.chat),
                        ),
                        FloatingActionButton(
                          heroTag: "playButton",
                          onPressed: () {
                            _playSelectedCards();
                          },
                          child: const Icon(Icons.double_arrow),
                        ),
                      ],
                    ),
                  ),
          ),

          // --- Chat panel on top ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _chatVisible ? 0 : -MediaQuery.of(context).size.width * 0.6,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.6,
            child: Container(
              color: Colors.black87,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatMessages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final msg = chatMessages[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            msg['username'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            msg['content'] ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type message...",
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            onSubmitted: sendMessage,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => sendMessage(_chatController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final VoidCallback onTap;

  const CardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(
          top: card.selected ? 0 : 16,
          bottom: card.selected ? 16 : 0,
        ),
        width: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: card.selected ? Colors.blue : Colors.black,
            width: card.selected ? 2 : 1,
          ),
          boxShadow: card.selected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.rank,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _suitColor(card.suit),
              ),
            ),
            Text(
              card.suit,
              style: TextStyle(fontSize: 18, color: _suitColor(card.suit)),
            ),
          ],
        ),
      ),
    );
  }

  Color _suitColor(String suit) {
    return (suit == '♥' || suit == '♦') ? Colors.red : Colors.black;
  }
}
