import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mudda_frontend/api/models/category_models.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/models/location_models.dart';

import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/features/issues/application/category_notifier.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/location_picker_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mudda_frontend/shared/utils/snackbar_util.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

enum DictationState {
  idle,
  askingProblem,
  listeningProblem,
  askingTitle,
  listeningTitle,
  confirming
}

const bool _isDemoMode = true;

// ─── Design Tokens ───────────────────────────────────────────────────────────

class _C {
  static const Color primary = Color(0xFF4F46E5);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceLow = Color(0xFFEFF4FF);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color outlineVariant = Color(0xFFC7C4D8);
  static const Color inkBlack = Color(0xFF0F172A);
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class CreateIssuePage extends ConsumerStatefulWidget {
  const CreateIssuePage({super.key});

  @override
  ConsumerState<CreateIssuePage> createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends ConsumerState<CreateIssuePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;

  CategoryResponse? _selectedCategory;
  LatLng? _selectedLocation;
  String _locationLabel = 'Auto-fetching location...';
  String _locationSubLabel = 'Tap Edit to choose on map';
  final List<XFile> _selectedImages = [];

  // Dictation State
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  DictationState _dictationState = DictationState.idle;
  bool get _isListening => _dictationState != DictationState.idle;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    if (_isDemoMode) {
      _initSpeech();
      _initTts();
    }
  }

  void _initTts() async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_dictationState == DictationState.listeningProblem) {
            _askForTitle();
          } else if (_dictationState == DictationState.listeningTitle) {
            _finalizeDictation();
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_speechEnabled) await _initSpeech();
    
    if (_dictationState != DictationState.idle) {
      await _flutterTts.stop();
      await _speechToText.stop();
      setState(() => _dictationState = DictationState.idle);
      return;
    }

    setState(() => _dictationState = DictationState.askingProblem);
    await _flutterTts.speak("कृपया अपनी समस्या बताएं।");
    _listenForProblem();
  }

  void _listenForProblem() async {
    if (!mounted) return;
    setState(() => _dictationState = DictationState.listeningProblem);
    await _speechToText.listen(
      localeId: 'hi_IN',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _descriptionController.text = result.recognizedWords;
        });
        if (result.finalResult && _dictationState == DictationState.listeningProblem) {
          _askForTitle();
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 8),
      listenOptions: stt.SpeechListenOptions(cancelOnError: true),
    );
  }

  Future<void> _askForTitle() async {
    if (_dictationState != DictationState.listeningProblem) return;
    await _speechToText.stop();
    if (!mounted) return;
    setState(() => _dictationState = DictationState.askingTitle);
    await _flutterTts.speak("समस्या का शीर्षक क्या होना चाहिए?");
    _listenForTitle();
  }

  void _listenForTitle() async {
    if (!mounted) return;
    setState(() => _dictationState = DictationState.listeningTitle);
    await _speechToText.listen(
      localeId: 'hi_IN',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _titleController.text = result.recognizedWords;
        });
        if (result.finalResult && _dictationState == DictationState.listeningTitle) {
          _finalizeDictation();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 8),
      listenOptions: stt.SpeechListenOptions(cancelOnError: true),
    );
  }

  Future<void> _finalizeDictation() async {
    if (_dictationState != DictationState.listeningTitle) return;
    await _speechToText.stop();

    if (!mounted) return;
    
    // Auto select first category
    final categoriesAsync = ref.read(categoryNotifierProvider);
    categoriesAsync.whenData((categories) {
      if (categories.isNotEmpty) {
        setState(() => _selectedCategory = categories.first);
      }
    });

    // Auto pick location
    setState(() {
      _selectedLocation = const LatLng(19.0760, 72.8777);
      _locationLabel = "19.0760, 72.8777";
      _locationSubLabel = "Auto-selected via AI";
    });

    setState(() => _dictationState = DictationState.confirming);
    await _flutterTts.setSpeechRate(0.55);
    
    String spokenText = "मैंने आपकी समस्या दर्ज कर ली है। शीर्षक है ${_titleController.text}। "
        "विवरण है ${_descriptionController.text}। "
        "श्रेणी है ${_selectedCategory?.name ?? 'चयनित'}। "
        "स्थान पिन कर दिया गया है। पुष्टि के लिए कृपया नीला बटन दबाएं।";

    await _flutterTts.speak(spokenText);
    if (!mounted) return;
    setState(() => _dictationState = DictationState.idle);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _selectedImages.add(photo));
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MediaBottomSheet(
        onGallery: () {
          Navigator.pop(context);
          _pickImages();
        },
        onCamera: () {
          Navigator.pop(context);
          _takePhoto();
        },
      ),
    );
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerPage()),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _locationLabel =
            '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
        _locationSubLabel = 'Tap Edit to choose again';
      });
    }
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      SnackbarUtil.showError(context, 'Please select a category');
      return;
    }
    if (_selectedLocation == null) {
      SnackbarUtil.showError(context, 'Please select a location');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload images
      List<String> uploadedFileKeys = [];
      if (_selectedImages.isNotEmpty) {
        final amazonRepo = ref.read(amazonImageRepositoryProvider);
        final uploadResult = await amazonRepo.uploadImages(_selectedImages);
        uploadedFileKeys = uploadResult.results
            .where((r) => r.isSuccess)
            .map((r) => r.fileKey)
            .toList();
      }

      // 2. Reverse-geocode location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      String pinCode = '000000';
      String addressLine = 'Unknown Address';
      String state = 'Unknown State';
      String city = 'Unknown City';

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        pinCode = p.postalCode ?? '000000';
        if (pinCode.isEmpty) pinCode = '000000';
        addressLine = '${p.street}, ${p.subLocality}, ${p.locality}';
        state = p.administrativeArea ?? 'Unknown State';
        city = p.locality ?? p.subAdministrativeArea ?? 'Unknown City';
      }

      // 3. Create location
      final locationService = ref.read(locationServiceProvider);
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

      // 4. Create issue
      final issueRepository = ref.read(issueRepositoryProvider);
      final request = CreateIssueRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        mediaUrls: uploadedFileKeys,
        categoryId: _selectedCategory!.id,
        locationId: locationResponse.id,
      );

      final issueResponse = await issueRepository.createIssue(request);

      if (mounted) {
        SnackbarUtil.showSuccess(
          context,
          'Issue submitted! (ID: ${issueResponse.id})',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e, st) {
      debugPrint('Error creating issue: $e\n$st');
      if (mounted) {
        SnackbarUtil.showError(context, 'Failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      backgroundColor: _C.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              if (_isDemoMode)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _buildDictationCard(),
                  ),
                ),

              // ── Evidence & Media ──────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSection(
                  label: 'EVIDENCE & MEDIA',
                  child: _buildMediaUpload(),
                ),
              ),

              // ── Issue Description ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSection(
                  label: 'ISSUE DESCRIPTION',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      _buildTextField(
                        controller: _titleController,
                        hint: 'Brief issue title',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter a title' : null,
                      ),
                      const SizedBox(height: 12),
                      // Description field
                      _buildTextField(
                        controller: _descriptionController,
                        hint: "What's the issue?",
                        maxLines: 5,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter a description'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Select Category ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSection(
                  label: 'SELECT CATEGORY',
                  child: categoriesAsync.when(
                    loading: () => const _CategorySkeleton(),
                    error: (e, _) => _CategoryError(
                      onRetry: () => ref
                          .read(categoryNotifierProvider.notifier)
                          .refresh(),
                    ),
                    data: (categories) => _CategoryChips(
                      categories: categories,
                      selected: _selectedCategory,
                      onSelect: (c) => setState(() => _selectedCategory = c),
                    ),
                  ),
                ),
              ),

              // ── Location Context ──────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSection(
                  label: 'LOCATION CONTEXT',
                  child: _buildLocationCard(),
                ),
              ),

              // ── Submit button + bottom padding ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: _buildSubmitButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: _C.surfaceLowest,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Report an Issue',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _C.inkBlack,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictationCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isListening ? _C.primary.withValues(alpha: 0.1) : _C.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening ? _C.primary.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isListening
                    ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                    : [const Color(0xFF3525CD), const Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _listen,
                child: Icon(
                  _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isListening ? 'Listening...' : 'Dictate with AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.inkBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isListening
                      ? 'Speak your issue clearly'
                      : 'Tap to auto-fill details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _C.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_isListening)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _C.primary,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUpload() {
    if (_selectedImages.isEmpty) {
      return GestureDetector(
        onTap: _showMediaOptions,
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: _C.surfaceLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _C.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
              // Dashed effect via CustomPaint below
            ),
          ),
          child: Stack(
            children: [
              // Dashed border overlay
              Positioned.fill(
                child: CustomPaint(painter: _DashedBorderPainter()),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _C.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: _C.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload or take photo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.inkBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPEG, PNG or MP4 up to 15MB',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.onSurfaceVariant,
                        letterSpacing: 0.4,
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

    // Show selected images grid
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                // "Add more" tile
                return GestureDetector(
                  onTap: _showMediaOptions,
                  child: Container(
                    width: 90,
                    height: 110,
                    decoration: BoxDecoration(
                      color: _C.surfaceLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_rounded, color: _C.primary, size: 28),
                  ),
                );
              }
              return _ImageTile(
                file: _selectedImages[index],
                onRemove: () => setState(() => _selectedImages.removeAt(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _C.inkBlack,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _C.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: _C.surfaceLow,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _C.outlineVariant.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _C.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _C.surfaceLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.inkBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _locationSubLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Edit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: _isLoading
            ? null
            : const LinearGradient(
                colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(135 * 3.14159 / 180),
              ),
        color: _isLoading ? _C.outlineVariant : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading
            ? null
            : [
                BoxShadow(
                  color: _C.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitIssue,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Submit to AI Governance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<CategoryResponse> categories;
  final CategoryResponse? selected;
  final ValueChanged<CategoryResponse> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selected?.id == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : _C.surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _C.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : _C.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Category Loading Skeleton ────────────────────────────────────────────────

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            width: 90,
            height: 44,
            decoration: BoxDecoration(
              color: _C.surfaceLow,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Error ───────────────────────────────────────────────────────────

class _CategoryError extends StatelessWidget {
  final VoidCallback onRetry;
  const _CategoryError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _C.surfaceLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 16, color: _C.primary),
            const SizedBox(width: 8),
            Text(
              'Retry loading categories',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image Tile ────────────────────────────────────────────────────────────────

class _ImageTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _ImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: kIsWeb
              ? FutureBuilder<Uint8List>(
                  future: file.readAsBytes(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return Image.memory(
                        snap.data!,
                        width: 90,
                        height: 110,
                        fit: BoxFit.cover,
                      );
                    }
                    return Container(
                      width: 90,
                      height: 110,
                      color: _C.surfaceLow,
                    );
                  },
                )
              : Image.network(
                  file.path,
                  width: 90,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => FutureBuilder<Uint8List>(
                    future: file.readAsBytes(),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        return Image.memory(
                          snap.data!,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(
                        width: 90,
                        height: 110,
                        color: _C.surfaceLow,
                      );
                    },
                  ),
                ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _C.onSurface.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Media Bottom Sheet ───────────────────────────────────────────────────────

class _MediaBottomSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _MediaBottomSheet({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _C.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Add Evidence',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.inkBlack,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            title: 'Choose from Gallery',
            subtitle: 'Select images from your device',
            onTap: onGallery,
          ),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            title: 'Take a Photo',
            subtitle: 'Use camera to capture evidence',
            onTap: onCamera,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _C.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.inkBlack,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.onSurfaceVariant,
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
}

// ─── Dashed Border Painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _C.outlineVariant.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 6;
    const double radius = 16;

    final path = ui.Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
          const Radius.circular(radius),
        ),
      );

    final ui.PathMetrics metrics = path.computeMetrics();
    for (final metric in metrics) {
      double start = 0;
      while (start < metric.length) {
        canvas.drawPath(
          metric.extractPath(start, start + dashWidth),
          paint,
        );
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
