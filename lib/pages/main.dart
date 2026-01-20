import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart';
import 'package:mudda_frontend/pages/LoginPage.dart';
import 'package:mudda_frontend/pages/createPost.dart';
import 'package:mudda_frontend/pages/ActivityPage.dart';
import 'package:mudda_frontend/pages/ProfilePage.dart';
import 'package:mudda_frontend/pages/DashboardPage.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/repositories/vote_repository.dart';
import 'package:mudda_frontend/api/repositories/comment_repository.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/config/constants.dart';
import 'package:dio/dio.dart';
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_interceptor.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/user_service.dart';
import 'package:mudda_frontend/api/services/category_service.dart';
import 'package:mudda_frontend/api/services/location_service.dart';
import 'package:mudda_frontend/api/services/role_service.dart';
import 'package:mudda_frontend/api/services/amazon_service.dart';
import 'package:mudda_frontend/api/repositories/amazon_repository.dart';

// New Riverpod-based auth (will replace old AuthGate)
import 'package:mudda_frontend/features/auth/presentation/widgets/auth_gate.dart'
    as riverpod_auth;
import 'package:mudda_frontend/features/auth/application/auth_notifier.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/issue_feed_screen.dart';

// New shared theme import (will be used once migration complete)
// import 'package:mudda_frontend/shared/theme/app_theme.dart';

void main() {
  runApp(
    // Wrap with ProviderScope for Riverpod (coexists with Provider during migration)
    ProviderScope(
      child: MultiProvider(
        providers: [
          Provider(create: (_) => StorageService()),
          ProxyProvider<StorageService, AuthInterceptor>(
            update: (_, storage, __) => AuthInterceptor(storage),
          ),
          ProxyProvider<AuthInterceptor, Dio>(
            update: (_, interceptor, __) {
              final dio = Dio(
                BaseOptions(
                  baseUrl: '${AppConstants.baseUrl}/api/v1',
                  connectTimeout: const Duration(seconds: 30),
                  receiveTimeout: const Duration(seconds: 30),
                  contentType: Headers.jsonContentType,
                  validateStatus: (status) => status! < 500,
                ),
              );
              dio.interceptors.add(interceptor);
              return dio;
            },
          ),
          ProxyProvider2<Dio, StorageService, AuthService>(
            update: (_, dio, storage, __) =>
                AuthService(dio: dio, storageService: storage),
          ),
          ProxyProvider<Dio, IssueService>(
            update: (_, dio, __) => IssueService(dio),
          ),
          ProxyProvider<Dio, VoteService>(
            update: (_, dio, __) => VoteService(dio),
          ),
          ProxyProvider<Dio, CommentService>(
            update: (_, dio, __) => CommentService(dio),
          ),
          ProxyProvider<Dio, UserService>(
            update: (_, dio, __) => UserService(dio),
          ),
          ProxyProvider<Dio, CategoryService>(
            update: (_, dio, __) => CategoryService(dio),
          ),
          ProxyProvider<Dio, LocationService>(
            update: (_, dio, __) => LocationService(dio),
          ),
          ProxyProvider<Dio, RoleService>(
            update: (_, dio, __) => RoleService(dio),
          ),
          ProxyProvider<Dio, AmazonImageService>(
            update: (_, dio, __) => AmazonImageService(dio),
          ),
          ProxyProvider<AmazonImageService, AmazonImageRepository>(
            update: (_, service, __) => AmazonImageRepository(service: service),
          ),

          // UserProfileData removed as part of ProfilePage revamp
        ],
        child: const RootApp(),
      ),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mudda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // More modern primary color
        scaffoldBackgroundColor: const Color(
          0xFFF5F7FA,
        ), // Light grey background
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      // Use new Riverpod-based AuthGate
      home: riverpod_auth.AuthGate(
        authenticatedBuilder: (context) => const MainAppScreen(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    try {
      final storage = context.read<StorageService>();
      final token = await storage.getToken();
      if (mounted) {
        setState(() {
          _isLoggedIn = token != null;
          _isLoading = false;
        });

        if (!_isLoggedIn) {
          _showLoginPage();
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        _showLoginPage();
      }
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
    } else if (mounted && !_isLoggedIn) {
      // If user dismissed login without logging in, maybe show it again or show a landing page
      // For now, let's just show login again
      _showLoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
    const IssueFeedScreen(),
    const Center(child: Text('Search Page - To be implemented')),
    const CreateIssuePage(),
    const AccountActivityPage(),
    const ProfilePage(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _openDashboard() {
    Navigator.pop(context);
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
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Mudda'),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _onNavItemTapped(4),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/1.jpg',
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        onProfileTap: () {
          Navigator.pop(context);
          _onNavItemTapped(4);
        },
        onActivityTap: () {
          Navigator.pop(context);
          _onNavItemTapped(3);
        },
        onDashboardTap: _openDashboard,
      ),
      body: IndexedStack(index: _currentNavIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.add_rounded, color: Colors.white),
              ),
              label: 'New',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<IssueResponse> _posts = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  int _selectedCategory = 0;
  IssueResponse? _selectedPost;
  late final IssueRepository _issueRepository;
  late final VoteRepository _voteRepository;
  late final CommentRepository _commentRepository;

  final List<String> _categories = [
    'All',
    'Infrastructure',
    'Safety',
    'Environment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final issueService = context.read<IssueService>();
    final voteService = context.read<VoteService>();
    final commentService = context.read<CommentService>();

    _issueRepository = IssueRepository(service: issueService);
    _voteRepository = VoteRepository(service: voteService);
    _commentRepository = CommentRepository(service: commentService);

    _loadPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
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
        category: _categories[_selectedCategory],
      );
      setState(() {
        _posts.addAll(newPosts);
        _page++;
        _hasMore = newPosts.length == 20;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading posts: $e')));
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
      _page = 0;
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
          voteRepository: _voteRepository,
          commentRepository: _commentRepository,
          issueRepository: _issueRepository,
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
                _page = 0;
                _hasMore = true;
              });
              await _loadPosts();
            },
            child: _posts.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _posts.length) {
                        return PostCard(
                          post: _posts[index],
                          voteRepository: _voteRepository,
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
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => _selectTab(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final IssueResponse post;
  final VoteRepository voteRepository;
  final Function(IssueResponse) onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.voteRepository,
    required this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _isVoting = false;
  late int _localLikes;
  late bool _hasVoted;

  @override
  void initState() {
    super.initState();
    _localLikes = widget.post.voteCount;
    _hasVoted = widget.post.hasUserVoted;
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _handleVote() async {
    if (_isVoting) return;
    setState(() => _isVoting = true);

    try {
      // Optimistic update
      setState(() {
        if (_hasVoted) {
          _localLikes--;
          _hasVoted = false;
        } else {
          _localLikes++;
          _hasVoted = true;
        }
      });

      if (_hasVoted) {
        await widget.voteRepository.createVote(widget.post.id);
      } else {
        await widget.voteRepository.deleteVote(widget.post.id);
      }
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          if (_hasVoted) {
            _localLikes--;
            _hasVoted = false;
          } else {
            _localLikes++;
            _hasVoted = true;
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'SOLVED':
      case 'CLOSED':
        return Colors.green;
      case 'PENDING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.post.status);

    return GestureDetector(
      onTap: () => widget.onTap(widget.post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with User and Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/women/44.jpg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(widget.post.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.post.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (widget.post.firstImageUrl != null)
              Hero(
                tag: 'post_image_${widget.post.id}',
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.post.firstImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.post.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.post.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildActionButton(
                            icon: _hasVoted
                                ? Icons.pan_tool
                                : Icons.pan_tool_outlined,
                            label: '$_localLikes',
                            color: _hasVoted
                                ? Colors.deepPurple
                                : Colors.grey.shade600,
                            onTap: _handleVote,
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${widget.post.comments}',
                            onTap: () => widget.onTap(widget.post),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share_rounded,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailPane extends StatefulWidget {
  final IssueResponse post;
  final VoteRepository voteRepository;
  final CommentRepository commentRepository;
  final IssueRepository issueRepository;
  final VoidCallback onClose;

  const PostDetailPane({
    super.key,
    required this.post,
    required this.voteRepository,
    required this.commentRepository,
    required this.issueRepository,
    required this.onClose,
  });

  @override
  State<PostDetailPane> createState() => _PostDetailPaneState();
}

class _PostDetailPaneState extends State<PostDetailPane> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  double dragStartPosition = 0;

  List<CommentResponse> _comments = [];
  bool _isLoadingComments = false;
  bool _isPostingComment = false;
  IssueResponse? _fullIssue;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _loadIssueDetails();
    _loadComments();
  }

  Future<void> _loadIssueDetails() async {
    try {
      final issue = await widget.issueRepository.getIssue(widget.post.id);
      if (mounted) {
        setState(() {
          _fullIssue = issue;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading issue details: $e');
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
          // Fallback to passed post data if fetch fails
          _fullIssue = widget.post;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final response = await widget.commentRepository.getCommentsByIssue(
        widget.post.id,
      );
      setState(() {
        _comments = response.comments;
      });
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load comments: $e')),
        // );
      }
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      final request = CreateCommentRequest(
        content: _commentController.text.trim(),
      );
      final newComment = await widget.commentRepository.createComment(
        widget.post.id,
        request,
      );

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

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
            BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 0),
          ],
        ),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            // Drag Handle
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Issue Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClose();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.mediaUrls.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: PageView.builder(
                          itemCount: widget.post.mediaUrls.length,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: 'post_image_${widget.post.id}_$index',
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    widget.post.mediaUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _fullIssue?.title ?? widget.post.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingDetails)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Text(
                        _fullIssue?.fullContent.isNotEmpty == true
                            ? _fullIssue!.fullContent
                            : (_fullIssue?.content.isNotEmpty == true
                                  ? _fullIssue!.content
                                  : 'No description provided.'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    const SizedBox(height: 32),

                    const Text(
                      'Discussion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoadingComments)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No comments yet',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      for (var comment in _comments) buildComment(comment),

                    const SizedBox(height: 80), // Space for input field
                  ],
                ),
              ),
            ),

            // Comment Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/41.jpg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isPostingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.deepPurple,
                          ),
                    onPressed: _isPostingComment ? null : _postComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildComment(CommentResponse comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/32.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User', // Placeholder
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      'Just now',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Like',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onActivityTap;
  final VoidCallback onDashboardTap;

  const AppDrawer({
    super.key,
    required this.onProfileTap,
    required this.onActivityTap,
    required this.onDashboardTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.deepPurple),
                ),
                SizedBox(height: 12),
                Text(
                  'Welcome Back',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Mudda User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.dashboard_rounded,
            'Community Dashboard',
            onDashboardTap,
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildDrawerItem(Icons.person_rounded, 'Profile', onProfileTap),
          _buildDrawerItem(
            Icons.local_activity_rounded,
            'Account Activity',
            onActivityTap,
          ),
          _buildDrawerItem(
            Icons.settings_rounded,
            'Settings',
            () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            Icons.help_rounded,
            'Help & Support',
            () => Navigator.pop(context),
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildDrawerItem(Icons.logout_rounded, 'Sign Out', () async {
            Navigator.pop(context); // Close drawer
            await ref.read(authNotifierProvider.notifier).logout();
            // AuthGate handles the redirect automatically
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple.shade400),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
