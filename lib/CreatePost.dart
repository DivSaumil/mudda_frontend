import 'package:flutter/material.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();

  bool _hasContent = false;
  List<String> _attachedImages = <String>[];
  List<String> _tags = <String>[];
  String? _selectedCategory;

  final List<String> _availableCategories = <String>[
    'Sanitation',
    'Electricity',
    'Water',
    'Road',
    'Infra',
    'Corruption',
    'Municipality',
    'Administrative',
    'Education',
    'Other',
  ];

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
    _tagInputController.dispose();
    super.dispose();
  }

  void _updateContentStatus() {
    setState(() {
      _hasContent = _headlineController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty ||
          _attachedImages.isNotEmpty ||
          _tags.isNotEmpty ||
          _selectedCategory != null;
    });
  }

  void _handlePost() {
    final String headline = _headlineController.text.trim();
    final String content = _contentController.text.trim();

    if (headline.isNotEmpty ||
        content.isNotEmpty ||
        _attachedImages.isNotEmpty ||
        _tags.isNotEmpty ||
        _selectedCategory != null) {
      final StringBuffer snackBarMessage = StringBuffer('Post submitted!\n');
      if (headline.isNotEmpty) {
        snackBarMessage.write('Headline: $headline\n');
      }
      if (content.isNotEmpty) {
        snackBarMessage.write('Content: $content\n');
      }
      if (_attachedImages.isNotEmpty) {
        snackBarMessage.write('Images: ${_attachedImages.length}\n');
      }
      if (_tags.isNotEmpty) {
        snackBarMessage.write('Tags: ${_tags.join(', ')}\n');
      }
      if (_selectedCategory != null) {
        snackBarMessage.write('Category: $_selectedCategory\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage.toString())),
      );
    }
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

  void _addTag(String tag) {
    final String trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagInputController.clear();
        _updateContentStatus();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _updateContentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: <Widget>[
          TextButton(
            onPressed: _hasContent ? _handlePost : null,
            child: Text(
              'Post',
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
                      hintText: "What's happening?",
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

            // Tags Input and Display
            TextField(
              controller: _tagInputController,
              decoration: InputDecoration(
                hintText: "Add tags (e.g., #flutter #ui)",
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onSubmitted: (String value) => _addTag(value),
              textInputAction: TextInputAction.done,
            ),
            if (_tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _tags.map<Widget>((String tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  );
                }).toList(),
              ),
            ],
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
                  items: _availableCategories
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
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  // TODO: Implement location functionality
                },
                tooltip: 'Add Location',
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