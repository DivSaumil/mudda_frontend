import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Data model representing a user's profile information.
class UserProfile {
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final String location;
  final String joinedDate;
  final int followingCount;
  final int followersCount;

  const UserProfile({
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.location,
    required this.joinedDate,
    required this.followingCount,
    required this.followersCount,
  });
}

/// Data model representing a single post.
class Post {
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final String timeAgo;
  final int replies;
  final int retweets;
  final int likes;

  const Post({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.timeAgo,
    required this.replies,
    required this.retweets,
    required this.likes,
  });
}

/// Data model representing a single media item (image).
class MediaItem {
  final String imageUrl;

  const MediaItem({required this.imageUrl});
}

/// A ChangeNotifier to manage and provide user profile data, posts, and media.
class UserProfileData extends ChangeNotifier {
  // Initial profile data
  final UserProfile _userProfile = const UserProfile(
    name: 'John Doe',
    username: '@johndoe',
    avatarUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
    bio: 'Flutter enthusiast. Coffee lover. Traveler.',
    location: 'San Francisco, CA',
    joinedDate: 'July 2025',
    followingCount: 180,
    followersCount: 1200,
  );

  // Initial dummy posts
  final List<Post> _posts;

  // Initial dummy media items
  final List<MediaItem> _media;

  UserProfileData()
      : _posts = List<Post>.generate(
    10,
        (int index) => Post(
      authorName: 'John Doe',
      authorAvatarUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
      content: 'This is post #${index + 1} from John Doe. Loving Flutter development!',
      timeAgo: '${(index + 1) * 2}h',
      replies: 5 + index,
      retweets: 10 + index,
      likes: 20 + index,
    ),
  ),
        _media = List<MediaItem>.generate(
          9,
              (int index) => const MediaItem(
            imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
          ),
        );

  UserProfile get userProfile => _userProfile;
  List<Post> get posts => _posts;
  List<MediaItem> get media => _media;

// Add methods to modify data and call notifyListeners() if reactivity is needed later.
}

/// Displays the user profile page with header and tabs for posts and media.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access profile data using Provider
    final UserProfileData profileData = context.watch<UserProfileData>();
    final UserProfile userProfile = profileData.userProfile;
    final List<Post> posts = profileData.posts;
    final List<MediaItem> mediaItems = profileData.media;

    final double appBarBottomHeight = kTextTabBarHeight; // Height of the TabBar

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              // Show title only when scrolled up and collapsed
              title: innerBoxIsScrolled
                  ? Text(userProfile.name, style: Theme.of(context).textTheme.titleLarge)
                  : null,
              centerTitle: true,
              pinned: true, // Keeps the TabBar pinned at the top when scrolled
              floating: false, // Does not float back when scrolling down slightly
              expandedHeight: 350.0, // Adjust this value to fit the ProfileHeader content + AppBar height
              flexibleSpace: FlexibleSpaceBar(
                // The ProfileHeader content that scrolls away
                background: ProfileHeader(userProfile: userProfile),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(appBarBottomHeight),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.blue,
                  // Use theme colors for tab labels
                  labelColor: Theme.of(context).tabBarTheme.labelColor,
                  unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                  tabs: const <Tab>[
                    Tab(text: 'Posts'),
                    Tab(text: 'Media'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            PostList(posts: posts),
            MediaGrid(mediaItems: mediaItems),
          ],
        ),
      ),
    );
  }
}

/// Displays the header section of the user profile.
class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileHeader({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(userProfile.avatarUrl),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  // The button is functional but does not perform any action yet.
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userProfile.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            userProfile.username,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            userProfile.bio,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(userProfile.location, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Joined ${userProfile.joinedDate}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text('${userProfile.followingCount} ', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Following'),
              const SizedBox(width: 16),
              Text('${userProfile.followersCount} ', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Followers'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(), // Keep divider as it separates header content from tab content
        ],
      ),
    );
  }
}

/// Displays a scrollable list of posts.
class PostList extends StatelessWidget {
  final List<Post> posts;

  const PostList({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: posts.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        final Post post = posts[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(post.authorAvatarUrl),
          ),
          title: Text(post.authorName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 4),
              Text(post.content, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(post.replies.toString(), style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.repeat, size: 16),
                  const SizedBox(width: 4),
                  Text(post.retweets.toString(), style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.favorite_border, size: 16),
                  const SizedBox(width: 4),
                  Text(post.likes.toString(), style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.share, size: 16),
                ],
              ),
            ],
          ),
          isThreeLine: true,
        );
      },
    );
  }
}

/// Displays a grid of media items.
class MediaGrid extends StatelessWidget {
  final List<MediaItem> mediaItems;

  const MediaGrid({Key? key, required this.mediaItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (BuildContext context, int index) {
        final MediaItem mediaItem = mediaItems[index];
        return Image.network(
          mediaItem.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        );
      },
    );
  }
}