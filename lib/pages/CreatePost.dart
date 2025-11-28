import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/models/location_models.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/repositories/amazon_repository.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/location_service.dart';
import 'package:mudda_frontend/pages/LocationPickerPage.dart';
import 'package:geocoding/geocoding.dart';

class CreateIssuePage extends StatefulWidget {
  const CreateIssuePage({Key? key}) : super(key: key);

  @override
  State<CreateIssuePage> createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends State<CreateIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  // Issue Data
  String? _selectedCategory;
  double _severity = 1.0;
  bool _isUrgent = false;
  LatLng? _selectedLocation;
  List<XFile> _selectedImages = [];

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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a location')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Images
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final amazonRepo = context.read<AmazonImageRepository>();
        final uploadedImages = await amazonRepo.uploadImages(_selectedImages);
        uploadedImageUrls = uploadedImages.map((img) => img.imageUrl).toList();
      }

      // 2. Create Location
      final locationService = context.read<LocationService>();

      // Fetch address details from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      String pinCode = "000000";
      String addressLine = "Unknown Address";
      String state = "Unknown State";
      String city = "Unknown City";

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        pinCode = place.postalCode ?? "000000";
        if (pinCode.isEmpty) pinCode = "000000";
        addressLine =
            "${place.street}, ${place.subLocality}, ${place.locality}";
        state = place.administrativeArea ?? "Unknown State";
        city = place.locality ?? place.subAdministrativeArea ?? "Unknown City";
      }

      final locationResponse = await locationService.createLocation(
        CreateLocationRequest(
          pinCode: pinCode,
          addressLine: addressLine,
          state: state,
          city: city,
          coordinate: CoordinateDTO(
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          ),
        ),
      );

      // 3. Create Issue
      final issueService = context.read<IssueService>();
      final issueRepository = IssueRepository(service: issueService);

      final request = CreateIssueRequest(
        title: _titleController.text.trim(),
        content: _descriptionController.text.trim(),
        mediaUrls: uploadedImageUrls,
        categoryId: _categoryMap[_selectedCategory],
        locationId: locationResponse.id,
        severityScore: _severity.round(),
        urgencyFlag: _isUrgent,
        issueStatus: 'PENDING',
      );

      await issueRepository.createIssue(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Issue created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _submitIssue();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      child: const Text('BACK'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.editing,
              content: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Brief summary of the issue',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Detailed explanation...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categoryMap.keys.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Specifics'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.editing,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Severity Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _severity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _severity.round().toString(),
                    onChanged: (val) => setState(() => _severity = val),
                  ),
                  Text(
                    'Level: ${_severity.round()} - ${_getSeverityLabel(_severity.round())}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Is this urgent?'),
                    subtitle: const Text('Requires immediate attention'),
                    value: _isUrgent,
                    onChanged: (val) => setState(() => _isUrgent = val),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Evidence'),
              isActive: _currentStep >= 2,
              state: StepState.editing,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickLocation,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _selectedLocation == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to select location on map'),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Tap to change',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Images Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
                    ],
                  ),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List>(
                                    future: _selectedImages[index]
                                        .readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSeverityLabel(int score) {
    if (score <= 3) return 'Low';
    if (score <= 7) return 'Medium';
    return 'High';
  }
}
