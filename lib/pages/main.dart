import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mudda_frontend/pages/LoginPage.dart';
import 'package:mudda_frontend/pages/createPost.dart';
import 'package:mudda_frontend/pages/ActivityPage.dart';
import 'package:mudda_frontend/pages/ProfilePage.dart';
import 'package:mudda_frontend/pages/DashboardPage.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/config/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider<UserProfileData>(
      create: (BuildContext context) => UserProfileData(),
      child: const RootApp(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mudda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Set to false to enable the login flow.
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    // For development, we can bypass the login screen.
    // To enable login, set _isLoggedIn to false.
    if (!_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginPage();
      });
    }
  }

  void _showLoginPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    if (result == true && mounted) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator until login flow is complete, then show the main app.
    return _isLoggedIn
        ? const MainAppScreen()
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final List<Widget> _screens = [
    const HomePage(), // Index 0: Home (from main.dart)
    const Center(child: Text('Search Page - To be implemented')), // Index 1: Search
    const CreateIssuePage(), // Index 2: New Post
    const AccountActivityPage(), // Index 3: Alerts
    const ProfilePage(), // Index 4: Profile
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _openDashboard() {
    // Close the drawer first
    Navigator.pop(context);
    // Navigate to the Dashboard Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('Mudda', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/1.jpg'), // Static image for now
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawer(
        onProfileTap: () {
          Navigator.pop(context); // Close the drawer
          _onNavItemTapped(4); // Navigate to ProfilePage
        },
        onActivityTap: () {
          Navigator.pop(context); // Close the drawer
          _onNavItemTapped(3); // Navigate to ActivityPage
        },
        onDashboardTap: _openDashboard, // Pass the dashboard callback
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Post class removed - using IssueResponse from API models instead

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<IssueResponse> _posts = [];
  int _page = 0; // API uses 0-based pagination
  bool _hasMore = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  int _selectedCategory = 1;
  IssueResponse? _selectedPost;
  late final IssueRepository _issueRepository;

  @override
  void initState() {
    super.initState();
    // Initialize API services
    final issueService = IssueService(baseUrl: AppConstants.baseUrl);
    _issueRepository = IssueRepository(service: issueService);
    _loadPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newPosts = await _issueRepository.fetchIssues(
        page: _page,
        size: 20,
      );
      setState(() {
        _posts.addAll(newPosts);
        _page++;
        _hasMore = newPosts.length == 20; // Check if there are more pages
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedCategory = index;
      _posts.clear();
      _page = 0; // Reset to first page
      _hasMore = true;
      _loadPosts();
    });
  }

  void _openPostDetail(IssueResponse post) {
    setState(() => _selectedPost = post);
    _showDetailPane();
  }

  void _closeDetailPane() {
    setState(() => _selectedPost = null);
  }

  void _showDetailPane() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PostDetailPane(
          post: _selectedPost!,
          onClose: _closeDetailPane,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _posts.clear();
                _page = 0; // Reset to first page
                _hasMore = true;
              });
              await _loadPosts();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _posts.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _posts.length) {
                  return PostCard(
                    post: _posts[index],
                    onTap: _openPostDetail,
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _hasMore
                          ? const CircularProgressIndicator()
                          : const Text('No more posts'),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (int i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('Category ${i + 1}'),
                selected: _selectedCategory == i,
                onSelected: (_) => _selectTab(i),
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final IssueResponse post;
  final Function(IssueResponse) onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(post),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null) _buildImageSection(),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        post.imageUrl!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.pan_tool, size: 20),
                const SizedBox(width: 4),
                Text('${post.likes}'),
              ]),
              Row(children: [
                const Icon(Icons.chat_bubble_outline, size: 20),
                const SizedBox(width: 4),
                Text('${post.comments}'),
              ]),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showCardMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCardMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}

class PostDetailPane extends StatefulWidget {
  final IssueResponse post;
  final VoidCallback onClose;

  const PostDetailPane({super.key, required this.post, required this.onClose});

  @override
  State<PostDetailPane> createState() => _PostDetailPaneState();
}

class _PostDetailPaneState extends State<PostDetailPane> {
  final ScrollController scrollController = ScrollController();
  double dragStartPosition = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        dragStartPosition = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        if (details.globalPosition.dy - dragStartPosition > 20) {
          Navigator.pop(context);
          widget.onClose();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClose();
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.post.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.post.fullContent,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildActionButton(Icons.pan_tool, '${widget.post.likes}'), // Updated to raised fist icon
                        buildActionButton(Icons.share, 'Share'),
                        buildActionButton(Icons.bookmark_border, 'Save'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < 3; i++) buildComment(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/41.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget buildComment() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/32.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jane Doe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This is a sample comment on the post. It provides additional insight into the topic.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '2h ago',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pan_tool, size: 18), // Raised Fist alternative
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onActivityTap;
  final VoidCallback onDashboardTap; // Added callback for dashboard

  const AppDrawer({
    super.key,
    required this.onProfileTap,
    required this.onActivityTap,
    required this.onDashboardTap, // Required in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Mudda Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          // New Dashboard Item
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Community Dashboard'),
            onTap: onDashboardTap,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: onProfileTap,
          ),
          ListTile(
            leading: const Icon(Icons.local_activity),
            title: const Text('Account Activity'),
            onTap: onActivityTap,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context), // Close the drawer
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pop(context), // Close the drawer
          ),
        ],
      ),
    );
  }
} 