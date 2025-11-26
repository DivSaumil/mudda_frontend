import 'package:flutter/material.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/config/constants.dart';

class CreateIssuePage extends StatefulWidget {
  const CreateIssuePage({Key? key}) : super(key: key);

  @override
  State<CreateIssuePage> createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends State<CreateIssuePage> {
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // Removed tag input controller (hashtags feature removed)

  bool _hasContent = false;
  List<String> _attachedImages = <String>[];
  // Removed tags list (hashtags feature removed)
  String? _selectedCategory;

  final Map<String, int> _categoryMap = {
  'Sanitation': 1,
  'Electricity': 2,
  'Water': 3,
  'Road': 4,
  'Infra': 5,
  'Corruption': 6,
  'Municipality': 7,
  'Administrative': 8,
  'Education': 9,
  'Other': 10,
};

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateContentStatus);
    _headlineController.addListener(_updateContentStatus);
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _contentController.dispose();
  // _tagInputController.dispose();
    super.dispose();
  }

  void _updateContentStatus() {
    setState(() {
      _hasContent = _headlineController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty ||
          _attachedImages.isNotEmpty ||
          // _tags.isNotEmpty ||
          _selectedCategory != null;
    });
  }

  void _handlePost() async{

    final String headline = _headlineController.text.trim();
    final String content = _contentController.text.trim();

    if (_hasContent) {
      try {
        // Build CreateIssueRequest object
        CreateIssueRequest request = CreateIssueRequest(
          title: headline.isNotEmpty ? headline : content,
          content: content.isNotEmpty ? content : headline,
          imageUrl: _attachedImages.isNotEmpty ? _attachedImages.first : null,
        );

        // Initialize service and repository
        final IssueService service = IssueService(baseUrl: AppConstants.baseUrl);
        final IssueRepository repository = IssueRepository(service: service);
        
        // Create issue
        await repository.createIssue(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Issue created successfully")),
          );
          Navigator.pop(context); // close the page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to create issue: ${e.toString()}")),
          );
        }
      }
    }


  //   final String headline = _headlineController.text.trim();
  //   final String content = _contentController.text.trim();

  //   if (headline.isNotEmpty ||
  //       content.isNotEmpty ||
  //       _attachedImages.isNotEmpty ||
  // // _tags.isNotEmpty ||
  //       _selectedCategory != null) {
  //     final StringBuffer snackBarMessage = StringBuffer('Post submitted!\n');
  //     if (headline.isNotEmpty) {
  //       snackBarMessage.write('Headline: $headline\n');
  //     }
  //     if (content.isNotEmpty) {
  //       snackBarMessage.write('Content: $content\n');
  //     }
  //     if (_attachedImages.isNotEmpty) {
  //       snackBarMessage.write('Images: ${_attachedImages.length}\n');
  //     }
  // // Removed tags from snackbar
  //     if (_selectedCategory != null) {
  //       snackBarMessage.write('Category: $_selectedCategory\n');
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(snackBarMessage.toString())),
  //     );
  //   }
  }

  void _addImage() {
    setState(() {
      _attachedImages
          .add('https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg');
      _updateContentStatus();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
      _updateContentStatus();
    });
  }

  // Removed tag add/remove methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Create Issue'),
        actions: <Widget>[
          TextButton(
            onPressed: _hasContent ? _handlePost : null,
            child: Text(
              'Submit',
              style: TextStyle(
                color: _hasContent ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Headline Input
            TextField(
              controller: _headlineController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Add a headline (optional)",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 24),
            // Main Content Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Description",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Attached Images
            if (_attachedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(_attachedImages.length, (int index) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _attachedImages[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Tags input and display removed
            const SizedBox(height: 16),

            // Category Selection
            InputDecorator(
              decoration: InputDecoration(
                // Removed labelText to avoid overlap with DropdownButton's hint
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.category),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              isEmpty: _selectedCategory == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text('Select a category'),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _updateContentStatus();
                    });
                  },
                  items: _categoryMap.keys
                      .map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _addImage,
                tooltip: 'Add Image',
              ),
              IconButton(
                icon: const Icon(Icons.tag_faces),
                onPressed: () {
                  // TODO: Implement emoji/sticker functionality
                },
                tooltip: 'Add Emoji',
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Add Location', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // TODO: Implement location functionality
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  // TODO: Implement more options
                },
                tooltip: 'More Options',
              ),
            ],
          ),
        ),
      ),
    );
  }
}