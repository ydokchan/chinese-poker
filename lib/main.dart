import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
          /*List<String> ranks = [
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
          ];*/
          List<String> ranks = ["3"];
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
  any,
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

  final GlobalKey<_CardRowsState> cardRowsKey = GlobalKey<_CardRowsState>();
  final TextEditingController _chatController = TextEditingController();

  List<Map<String, dynamic>> players = [];
  String? currentTurnPlayer;
  List<String> inPlayArea = [];

  late RealtimeChannel gameChannel;

  bool _chatVisible = false; // initially hidden
  List<Map<String, dynamic>> chatMessages = [];

  // ignore: unused_field
  Key _rebuildKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _subscribeToRealtime();
    _fetchGameState();

  }

    void _subscribeToRealtime() {
    gameChannel = supabase.channel('game_channel_${widget.gameId}');

    gameChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'messages', filter: 'game_id=eq.${widget.gameId}'),
      (payload, [ref]) {
        _fetchMessages(); // refresh whenever an insert/update/delete happens
      },
    );

    gameChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'games', filter: 'id=eq.${widget.gameId}'),
      (payload, [ref]) {
        _fetchGameState(); // refresh whenever an insert/update/delete happens
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

  Future<void> _fetchGameState() async {
    final game = await supabase
        .from('games')
        .select('current_turn_player_username, in_play_area')
        .eq('id', widget.gameId)
        .single();

    final activePlayers = await supabase
        .from('active_players')
        .select('username, cards_remaining')
        .eq('game_id', widget.gameId); // ensures same order everywhere

    if (!mounted) return;

    List<String> fetchedInPlay = game['in_play_area'] != null
        ? List<String>.from(game['in_play_area'])
        : [];

    List<Map<String, dynamic>> fetchedPlayers = List<Map<String, dynamic>>.from(
      activePlayers,
    );

    String? fetchedCurrent = game['current_turn_player_username'] as String?;

    setState(() {
      inPlayArea = fetchedInPlay;
      players = fetchedPlayers;
      currentTurnPlayer = fetchedCurrent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.gameName)),
      body: Stack(
        children: [
          // Main game UI
          Column(
            children: [
              PlayerStatusContainer(gameId: widget.gameId),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: CardRows(
                    key: cardRowsKey,
                    gameId: widget.gameId,
                    playerName: widget.playerName,
                    inPlayArea: inPlayArea,
                  ),
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
                        heroTag: "btn1",
                        onPressed: () {
                          cardRowsKey.currentState?.nextTurn(
                            widget.gameId,
                            true,
                          );
                        },
                        child: const Icon(Icons.cancel_sharp),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "btn3",
                        onPressed: () {
                          _chatVisible = !_chatVisible;
                        },
                        child: const Icon(Icons.chat),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: () {
                          cardRowsKey.currentState?.moveRow3ToRow4();
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
                          heroTag: "btn1",
                          onPressed: () {
                            cardRowsKey.currentState?.nextTurn(
                              widget.gameId,
                              true,
                            );
                          },
                          child: const Icon(Icons.cancel_sharp),
                        ),
                        FloatingActionButton(
                          heroTag: "btn3",
                          onPressed: () {
                            setState(() {
                              _chatVisible = !_chatVisible;
                            });
                          },
                          child: const Icon(Icons.chat),
                        ),
                        FloatingActionButton(
                          heroTag: "btn2",
                          onPressed: () {
                            cardRowsKey.currentState?.moveRow3ToRow4();
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

class CardRows extends StatefulWidget {
  final String gameId;
  final String playerName;
  final List<String> inPlayArea;

  const CardRows({
    super.key,
    required this.gameId,
    required this.playerName,
    required this.inPlayArea,
  });

  @override
  State<CardRows> createState() => _CardRowsState();
}

class _CardRowsState extends State<CardRows> {
  List<String> row1 = [];
  List<String> row2 = [];
  List<String> row3 = []; // selected cards
  List<String> row4 = []; // in play
  List<String> deck = [];

  var currentHandType = HandType.any;
  var startOfRound = true;
  var startOfGame = true;

  final supabase = Supabase.instance.client;

  Timer? _autoPassTimer;

  bool _autoPassTimerStarted = false;
  bool _alreadyRun = false;

  late RealtimeChannel cardRowsChannel;

  final List<String> suits = ['♦', '♣', '♥', '♠'];
  final List<String> ranks = [
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
    'A',
    '2',
  ];

  @override
  void initState() {
    super.initState();
    _loadMyHand();
    _subscribeToRealtime();
    updateInPlayArea();

  }

   void _subscribeToRealtime() {
    cardRowsChannel = supabase.channel('card_rows_channel_${widget.gameId}');

    cardRowsChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'games', filter: 'id=eq.${widget.gameId}'),
      (payload, [ref]) {
        updateInPlayArea(); // refresh whenever an insert/update/delete happens
      },
    );

    cardRowsChannel.subscribe();
  }

  @override
  void dispose() {
    _autoPassTimer?.cancel();
    supabase.removeChannel(cardRowsChannel);
    super.dispose();
  }

  void _startTurnTimer() {
    _autoPassTimer?.cancel(); // cancel existing timer if running
    _autoPassTimer = Timer(const Duration(seconds: 45), () {
      //forceEndTurn(widget.gameId); // force pass after 45s
    });
  }

  void _cancelTurnTimer() {
    _autoPassTimer?.cancel();
    _autoPassTimer = null;
  }

  Future<void> forceEndTurn(String gameId) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Time's up! You have been auto-passed.")),
    );

    // 2) Fetch current turn_order from games
    final game = await supabase
        .from('games')
        .select(
          'turn_order, current_turn_player_username, players_passed, start_of_round, start_of_game',
        )
        .eq('id', gameId)
        .single();

    if (game['current_turn_player_username'] != widget.playerName) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not your turn")));
      return;
    }

    await supabase
        .from('games')
        .update({'start_of_round': false, 'start_of_game': false})
        .eq('id', gameId);

    await supabase
        .from('active_players')
        .update({'passed_current_hand': true})
        .eq('game_id', gameId)
        .eq('username', widget.playerName);

    //Log the pass action
    await supabase.from('all_turns').insert({
      'game_id': gameId,
      'username': widget.playerName,
      'cards_in_hand': row1 + row2, // store as array if column type is array
      'in_play_area': row4,
      'action_taken': "auto-pass",
    });

    List<String> order = List<String>.from(game['turn_order'] ?? []);
    if (order.isEmpty) {
      print('nextTurn: turn_order is empty — nothing to do');
      return;
    }

    // 3) Fetch all players' passed status for this game
    final playersData = await supabase
        .from('active_players')
        .select('username, passed_current_hand')
        .eq('game_id', gameId);

    final List<Map<String, dynamic>> activePlayers =
        List<Map<String, dynamic>>.from(playersData ?? []);

    // 4) Advance once (move to the next player), then skip any who have passed.
    order.add(order.removeAt(0)); // advance to the next player

    int attempts = 0;
    while (attempts < order.length) {
      final candidate = order.first;
      final candidateData = activePlayers.firstWhere(
        (p) => p['username'] == candidate,
        orElse: () => <String, dynamic>{},
      );

      final bool candidateHasPassed =
          candidateData.isNotEmpty &&
          candidateData['passed_current_hand'] == true;

      if (!candidateHasPassed) {
        // found a player who has NOT passed
        break;
      }

      // candidate has passed -> skip them
      order.add(order.removeAt(0));
      attempts++;
    }

    final String nextPlayer = order.first;

    var numPassed = game['players_passed'] + 1;

    // 5) Update the game row in DB
    await supabase
        .from('games')
        .update({
          'turn_order': order,
          'current_turn_player_username': nextPlayer,
          'in_play_area': row4,
          'players_passed': numPassed,
        })
        .eq('id', gameId);

    // 6) If everyone else has passed, reset the round
    if (numPassed >= order.length - 1) {
      await resetGame(gameId, nextPlayer);
    }
  }

  void updateInPlayArea() async {

    final result = await supabase
        .from('games')
        .select(
          'game_name, turn_order, current_turn_player_username, in_play_area, hand_type, start_of_round, start_of_game, winner, next_game_id',
        )
        .eq('id', widget.gameId)
        .single();

    // --- Always update inPlayArea + round/game state for EVERYONE ---
    List<String> newRow4 = result['in_play_area'] != null
        ? List<String>.from(result['in_play_area'])
        : [];

    setState(() {
      row4 = newRow4;
      currentHandType = result['hand_type'] != null
          ? HandType.values.firstWhere(
              (e) => e.toString() == 'HandType.${result['hand_type']}',
              orElse: () => HandType.any,
            )
          : currentHandType;
      startOfRound = result['start_of_round'] ?? startOfRound;
      startOfGame = result['start_of_game'] ?? startOfGame;
    });

    // --- Winner handling (all players should see this) ---
    if (result['winner'] != null && result['winner'] != '') {
      if (_alreadyRun) return;
      _alreadyRun = true; // prevent re-entrance
      final String winnerName = result['winner'];

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("🎊$winnerName wins!🎊", textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LobbyScreen(
                        gameId: result['next_game_id'],
                        gameName: result['game_name'],
                        playerName: widget.playerName,
                      ),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // --- Turn timer handling (only for the current player) ---
    final bool isMyTurn =
        result['current_turn_player_username'] == widget.playerName;

    if (isMyTurn) {
      if (!_autoPassTimerStarted) {
        _startTurnTimer();
        _autoPassTimerStarted = true;
      }
    } else {
      if (_autoPassTimerStarted) {
        _cancelTurnTimer();
        _autoPassTimerStarted = false;
      }
    }

    // --- Hand type evaluation (all players should keep this in sync) ---
    if (row4.isNotEmpty) {
      final evaluatedType = evaluateHand(row4);
      if (evaluatedType != currentHandType) {
        await supabase
            .from('games')
            .update({'hand_type': evaluatedType.toString().split('.').last})
            .eq('id', widget.gameId);
      }
    }
  }

  Future<void> _loadMyHand() async {
    final hand = await getMyHand(widget.gameId, widget.playerName);
    setState(() {
      row1 = hand;
      sortCards();
    });
  }

  Future<void> nextTurn(String gameId, bool pass) async {
    // 2) Fetch current turn_order from games
    final game = await supabase
        .from('games')
        .select(
          'turn_order, current_turn_player_username, players_passed, start_of_round, start_of_game',
        )
        .eq('id', gameId)
        .single();

    if (game['current_turn_player_username'] != widget.playerName) {
      if (!mounted) return;
      return;
    }

    if (startOfGame) {
      startOfGame = game['start_of_game'] ?? true;
    }

    if (startOfRound) {
      startOfRound = game['start_of_round'] ?? true;
    }

    // 1) If the current player chose to pass, mark them as passed first.
    if (pass) {
      if (startOfGame || startOfRound) {
        // first turn of the game, cannot pass
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("You need to play first")));
        return;
      }

      await supabase
          .from('active_players')
          .update({'passed_current_hand': true})
          .eq('game_id', gameId)
          .eq('username', widget.playerName);

      //Log the pass action
      await supabase.from('all_turns').insert({
        'game_id': gameId,
        'username': widget.playerName,
        'cards_in_hand': row1 + row2, // store as array if column type is array
        'in_play_area': row4,
        'action_taken': "passed",
      });
    }

    List<String> order = List<String>.from(game['turn_order'] ?? []);
    if (order.isEmpty) {
      print('nextTurn: turn_order is empty — nothing to do');
      return;
    }

    // 3) Fetch all players' passed status for this game
    final playersData = await supabase
        .from('active_players')
        .select('username, passed_current_hand')
        .eq('game_id', gameId);

    final List<Map<String, dynamic>> activePlayers =
        List<Map<String, dynamic>>.from(playersData ?? []);

    // 4) Advance once (move to the next player), then skip any who have passed.
    order.add(order.removeAt(0)); // advance to the next player

    int attempts = 0;
    while (attempts < order.length) {
      final candidate = order.first;
      final candidateData = activePlayers.firstWhere(
        (p) => p['username'] == candidate,
        orElse: () => <String, dynamic>{},
      );

      final bool candidateHasPassed =
          candidateData.isNotEmpty &&
          candidateData['passed_current_hand'] == true;

      if (!candidateHasPassed) {
        // found a player who has NOT passed
        break;
      }

      // candidate has passed -> skip them
      order.add(order.removeAt(0));
      attempts++;
    }

    // If we tried order.length times and didn't find a non-passed player, everyone passed.
    if (attempts >= order.length) {
      print(
        'nextTurn: all players appear to have passed. handle reset elsewhere.',
      );
      // For now, set nextPlayer to the current head to avoid null, but do NOT try to
      // continually skip because everyone passed. You said you'll reset later.
    }

    final String nextPlayer = order.first;
    print('nextTurn: advancing to nextPlayer=$nextPlayer (attempts=$attempts)');

    var numPassed = 0;
    if (pass) {
      numPassed = game['players_passed'] + 1;
    } else {
      numPassed = game['players_passed'];
    }

    // 5) Update the game row in DB
    await supabase
        .from('games')
        .update({
          'turn_order': order,
          'current_turn_player_username': nextPlayer,
          'in_play_area': row4,
          'players_passed': numPassed,
        })
        .eq('id', gameId);

    // 6) If everyone else has passed, reset the round
    if (numPassed >= order.length - 1) {
      await resetGame(gameId, nextPlayer);
    }
  }

  Future<void> resetGame(String gameId, String startingPlayer) async {
    // 1) Fetch players for this game
    final playersResponse = await supabase
        .from('active_players')
        .select('username')
        .eq('game_id', gameId);

    List<String> playerNames = List<String>.from(
      playersResponse.map((p) => p['username']),
    );

    if (playerNames.isEmpty) {
      print('resetGame: no players found, skipping reset');
      return;
    }

    // 2) Rotate so startingPlayer is first
    while (playerNames.isNotEmpty && playerNames.first != startingPlayer) {
      playerNames.add(playerNames.removeAt(0));
    }

    // 3) Reset all players' passed_current_hand to false
    await supabase
        .from('active_players')
        .update({'passed_current_hand': false})
        .eq('game_id', gameId);

    // 4) Update games table with corrected turn order + first player
    await supabase
        .from('games')
        .update({
          'turn_order': playerNames,
          'current_turn_player_username':
              playerNames.first, // now always correct
          'in_play_area': [],
          'players_passed': 0,
          'start_of_round': true,
          'hand_type': 'any',
        })
        .eq('id', gameId);

    print(
      'resetGame: turn_order=$playerNames current_turn=${playerNames.first}',
    );
  }

  Future<List<String>> getMyHand(String gameId, String username) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('active_players')
        .select('cards_in_hand')
        .eq('game_id', gameId)
        .eq('username', username)
        .maybeSingle();

    if (response == null || response['cards_in_hand'] == null) return [];

    return List<String>.from(response['cards_in_hand']);
  }

  void sortCards() {
    int rankValue(String card) => ranks.indexOf(card.split(' ')[0]);
    int suitValue(String card) => suits.indexOf(card.split(' ')[1]);

    int compare(String a, String b) {
      int rankComp = rankValue(a).compareTo(rankValue(b));
      if (rankComp != 0) return rankComp;
      return suitValue(a).compareTo(suitValue(b));
    }

    // Combine row1 and row2
    List<String> allCards = [...row1, ...row2];
    allCards.sort(compare);

    int half = allCards.length ~/ 2;
    row1 = allCards.sublist(0, half);
    row2 = allCards.sublist(half);

    row3.sort(compare);
    row4.sort(compare);
  }

  // Poker hand evaluation
  HandType evaluateHand(List<String> cards) {
    if (cards.isEmpty) return HandType.invalid;

    List<String> ranksInHand = cards.map((c) => c.split(' ')[0]).toList();
    List<String> suitsInHand = cards.map((c) => c.split(' ')[1]).toList();

    Map<String, int> rankCounts = {};
    for (var r in ranksInHand) {
      rankCounts[r] = (rankCounts[r] ?? 0) + 1;
    }

    bool isFlush = suitsInHand.toSet().length == 1;

    List<int> rankIndices = ranksInHand.map((r) => ranks.indexOf(r)).toList()
      ..sort();
    bool isStraight = true;
    for (int i = 1; i < rankIndices.length; i++) {
      if (rankIndices[i] != rankIndices[i - 1] + 1) {
        isStraight = false;
        break;
      }
    }
    if (cards.length > 5) return HandType.invalid;
    if (cards.length == 1) return HandType.single;
    if (cards.length == 2 && rankCounts.length == 1) return HandType.pair;
    // ✅ CUSTOM HAND: "6 and 7"
    if (cards.length == 2 &&
        ranksInHand.contains("6") &&
        ranksInHand.contains("7")) {
      return HandType.custom67; // Add this to your HandType enum
    }
    if (cards.length == 3 && rankCounts.length == 1) return HandType.triple;
    if (cards.length == 4) {
      // Two Pair check
      if (rankCounts.values.where((v) => v == 2).length == 2) {
        return HandType.twoPair;
      } else if (rankCounts.values.contains(4)) {
        return HandType.fourOfAKind;
      }
    }
    if (cards.length == 5 && isStraight && !isFlush) return HandType.straight;
    if (cards.length == 5 && isFlush && !isStraight) return HandType.flush;
    if (cards.length == 5 && isStraight && isFlush) return HandType.straightFlush;
    if (rankCounts.length == 2) {
      if (rankCounts.values.contains(3)) return HandType.fullHouse;
    }

    return HandType.invalid;
  }

  List<String> sortRows(
    List<String> row1,
    List<String> row2,
    List<String> row3,
  ) {
    int rankValue(String card) => ranks.indexOf(card.split(' ')[0]);
    int suitValue(String card) => suits.indexOf(card.split(' ')[1]);

    int compare(String a, String b) {
      int rankComp = rankValue(a).compareTo(rankValue(b));
      if (rankComp != 0) return rankComp;
      return suitValue(a).compareTo(suitValue(b));
    }

    // Combine row1 and row2
    List<String> allCards = [...row1, ...row2, ...row3];
    allCards.sort(compare);

    return allCards;
  }

  // Move row3 → row4 only if a valid poker hand
  void moveRow3ToRow4() async {

    // --- Check if it's the player's turn ---
    final result = await supabase
        .from('games')
        .select(
          'turn_order, current_turn_player_username, start_of_game, hand_type, game_name, password',
        )
        .eq('id', widget.gameId)
        .single();

    if (result['current_turn_player_username'] != widget.playerName) {
      print("Not your turn");
      return;
    }

    var currentHand = evaluateHand(row3);

    if (startOfGame) {
      startOfGame = result['start_of_game'];
    }

    // --- first move must include 3♦ ---
    if (startOfGame) {
      if (currentHand == HandType.invalid) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("invalid hand")));
        return;
      }
      if (!row3.contains("3 ♦")) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("first move must contain 3 ♦")),
        );
        return;
      }
    } else {
      // after first move, hand must match type of current play
      //  --- Update current hand type in DB ---
      currentHandType = evaluateHand(row3);

      if (currentHandType == HandType.invalid) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("invalid hand")));
        return;
      }
      await supabase
          .from('games')
          .update({'hand_type': currentHandType.toString().split('.').last})
          .eq('id', widget.gameId);

      if (currentHand != currentHandType) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Play rejected: hand type is not the same as current",
            ),
          ),
        );
        return;
      }
    }

    // --- Must beat the current highest card in row4 ---
    if (row4.isNotEmpty) {
      int rankValue(String card) => ranks.indexOf(card.split(' ')[0]);
      int suitValue(String card) => suits.indexOf(card.split(' ')[1]);

      // highest card in row4
      row4.sort((a, b) {
        int rankComp = rankValue(a).compareTo(rankValue(b));
        if (rankComp != 0) return rankComp;
        return suitValue(a).compareTo(suitValue(b));
      });
      String highestRow4 = row4.last;

      // highest card in row3
      row3.sort((a, b) {
        int rankComp = rankValue(a).compareTo(rankValue(b));
        if (rankComp != 0) return rankComp;
        return suitValue(a).compareTo(suitValue(b));
      });
      String highestRow3 = row3.last;

      // compare highestRow3 vs highestRow4
      int compareCards(String a, String b) {
        int rankComp = rankValue(a).compareTo(rankValue(b));
        if (rankComp != 0) return rankComp;
        return suitValue(a).compareTo(suitValue(b));
      }

      if (compareCards(highestRow3, highestRow4) <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Play rejected: must beat current hand"),
          ),
        );
        return;
      }
    }

    //Log the turn taken
    await supabase.from('all_turns').insert({
      'game_id': widget.gameId,
      'username': widget.playerName,
      'cards_in_hand': sortRows(
        row1,
        row2,
        row3,
      ), // store as array if column type is array
      'in_play_area': row4,
      'action_taken': row3,
    });

    // --- Move to row4 ---
    setState(() {
      row4.clear();
      row4.addAll(row3);
      row3.clear();
      sortCards();
    });

    // --- Update Database ---
    await supabase
        .from('active_players')
        .update({
          'cards_in_hand': row1 + row2, // full hand still in hand
          'cards_remaining': (row1.length + row2.length),
        })
        .eq('game_id', widget.gameId)
        .eq('username', widget.playerName);

    bool hasWon = row1.isEmpty && row2.isEmpty && row3.isEmpty;
    if (hasWon) {
      // --- Create new game ---
      final newGameResponse = await supabase
          .from('games')
          .insert({
            'game_name': result['game_name'],
            'password': result['password'],
          })
          .select('id')
          .single();

      // --- Update current game ---
      await supabase
          .from('games')
          .update({
            'winner': widget.playerName,
            'status': 'finished',
            'next_game_id': newGameResponse['id'],
          })
          .eq('id', widget.gameId);

      //delete all messages from this game
      await supabase.from('messages').delete().eq('game_id', widget.gameId);

      //update user stats
      final playersResponse = await supabase
          .from('games')
          .select('turn_order')
          .eq('id', widget.gameId)
          .single();

      final List<String> players = List<String>.from(
        playersResponse['turn_order'] ?? [],
      );

      for (final playerName in players) {
        final user = await supabase
            .from('users')
            .select('total_games, total_wins')
            .eq('username', playerName)
            .single();

        int totalGames = (user['total_games'] != null)
            ? int.parse(user['total_games'].toString())
            : 0;
        int totalWins = (user['total_wins'] != null)
            ? int.parse(user['total_wins'].toString())
            : 0;

        totalGames += 1;
        if (playerName == widget.playerName) {
          totalWins += 1;
        }

        await supabase
            .from('users')
            .update({'total_games': totalGames, 'total_wins': totalWins})
            .eq('username', playerName);
      }

      // add method here to begin end game process
      if (!mounted) return;
    }
    nextTurn(widget.gameId, false);

    if (startOfGame) {
      startOfGame = false;

      await supabase
          .from('games')
          .update({'start_of_game': false})
          .eq('id', widget.gameId);
    }

    // --- Update hand type ---
    if (startOfRound) {
      currentHandType = evaluateHand(row4);
      startOfRound = false;
      await supabase
          .from('games')
          .update({'start_of_round': false})
          .eq('id', widget.gameId);
    }

    await supabase
        .from('games')
        .update({'start_of_game': false})
        .eq('id', widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 10),
        const Text("In Play"),
        buildRow(row4, 4),

        const Spacer(flex: 5),
        const Text("Selected Cards"),
        buildRow(row3, 3),
        const Spacer(flex: 5),
        buildRow(row1, 1),
        const SizedBox(height: 5),
        buildRow(row2, 2),
        const Spacer(flex: 12),
      ],
    );
  }

  Widget buildRow(List<String> thisRow, int rowNum) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // spacing between cards
        const spacing = 3.0;
        final totalSpacing = spacing * (thisRow.length - 1);

        // dynamic card width
        final cardWidth =
            (maxWidth - totalSpacing) / (thisRow.isEmpty ? 1 : thisRow.length);

        // clamp to reasonable min/max
        final adjustedCardWidth = cardWidth.clamp(20.0, 40.0);

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: 4.0,
          children: thisRow.map((card) {
            String suit = card.split(' ')[1];
            Color textColor = (suit == '♥' || suit == '♦')
                ? Colors.red
                : Colors.black;

            return SizedBox(
              width: adjustedCardWidth,
              height: adjustedCardWidth * 1.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 235, 235),
                  foregroundColor: textColor,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: textColor, width: 2),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (rowNum == 3) {
                      thisRow.remove(card);
                      row1.add(card);
                    } else if (rowNum == 1 || rowNum == 2) {
                      thisRow.remove(card);
                      row3.add(card);
                    }
                    sortCards();
                  });
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    card,
                    style: TextStyle(
                      fontSize: adjustedCardWidth / 3,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class PlayerStatusBar extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final String? currentTurnPlayer;

  const PlayerStatusBar({
    super.key,
    required this.players,
    required this.currentTurnPlayer,
  });

  Color adjustForTheme(Color base, BuildContext context) {
    final hsl = HSLColor.fromColor(base);
    final brightness = Theme.of(context).brightness;

    final double amount = brightness == Brightness.light ? -0.15 : 0.15;
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: adjustForTheme(Theme.of(context).scaffoldBackgroundColor, context),

      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // center all players
        children: players.map((player) {
          bool isTurn = player['username'] == currentTurnPlayer;
          bool hasPassed =
              player['passed_current_hand'] == true; // ✅ read from map

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (hasPassed)
                      const Icon(Icons.cancel_sharp, color: Colors.red),
                    if (isTurn)
                      const Icon(Icons.arrow_right_sharp, color: Colors.green),

                    Text(
                      player['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text("${player['cards_remaining']} cards"),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PlayerStatusContainer extends StatefulWidget {
  final String gameId;

  const PlayerStatusContainer({super.key, required this.gameId});

  @override
  State<PlayerStatusContainer> createState() => _PlayerStatusContainerState();
}

class _PlayerStatusContainerState extends State<PlayerStatusContainer> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> players = [];
  String? currentTurnPlayer;

  late RealtimeChannel playerStatusChannel;

  @override
  void initState() {
    super.initState();
    _subscribeToRealtime();
    _fetchPlayers();

  }

     void _subscribeToRealtime() {
    playerStatusChannel = supabase.channel('player_status_channel_${widget.gameId}');

    playerStatusChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'games', filter: 'id=eq.${widget.gameId}'),
      (payload, [ref]) {
        _fetchPlayers(); // refresh whenever an insert/update/delete happens
      },
    );

    playerStatusChannel.subscribe();
  }

  @override
  void dispose() {
    supabase.removeChannel(playerStatusChannel);
    super.dispose();
  }

  Future<void> _fetchPlayers() async {
    try {
      final game = await supabase
          .from('games')
          .select('current_turn_player_username')
          .eq('id', widget.gameId)
          .single();

      final activePlayers = await supabase
          .from('active_players')
          .select('username, cards_remaining, passed_current_hand')
          .eq('game_id', widget.gameId);

      if (!mounted) return;
      setState(() {
        currentTurnPlayer = game['current_turn_player_username'] as String?;
        players = List<Map<String, dynamic>>.from(activePlayers);
      });
    } catch (error, stack) {
      print("❌ Error fetching players: $error");
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlayerStatusBar(
      players: players,
      currentTurnPlayer: currentTurnPlayer,
    );
  }
}