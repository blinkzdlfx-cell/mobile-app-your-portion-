import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _supabaseService = SupabaseService();
  String? _selectedIdType;
  PlatformFile? _idFile;
  PlatformFile? _faceFile;
  bool _isUploading = false;
  bool _isSubmitted = false;

  final _idTypes = [
    {'key': 'nin', 'label': 'NIN'},
    {'key': 'voter_card', 'label': 'Voter Card'},
    {'key': 'international_passport', 'label': 'International Passport'},
  ];

  Future<void> _pickFile(bool isId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (isId) {
          _idFile = result.files.first;
        } else {
          _faceFile = result.files.first;
        }
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_selectedIdType == null || _idFile == null || _faceFile == null) return;
    setState(() => _isUploading = true);

    try {
      final ext = _idFile!.name.split('.').last;
      String? idDocumentUrl;
      String? faceImageUrl;

      if (kIsWeb) {
        final idBytes = _idFile!.bytes;
        final faceBytes = _faceFile!.bytes;
        if (idBytes == null || faceBytes == null) {
          throw Exception('File data not available');
        }
        idDocumentUrl = await _supabaseService.uploadVerificationDocument(bytes: idBytes, extension: ext);
        faceImageUrl = await _supabaseService.uploadFaceImage(bytes: faceBytes, extension: ext);
      } else {
        final idFilePath = _idFile!.path;
        final faceFilePath = _faceFile!.path;
        if (idFilePath == null || faceFilePath == null) {
          throw Exception('File path not available');
        }
        idDocumentUrl = await _supabaseService.uploadVerificationDocument(filePath: idFilePath);
        faceImageUrl = await _supabaseService.uploadFaceImage(filePath: faceFilePath);
      }

      if (idDocumentUrl == null) throw Exception('Failed to upload ID document');
      if (faceImageUrl == null) throw Exception('Failed to upload face image');

      await _supabaseService.submitVerificationRequest(
        requestType: 'seller',
        idDocumentUrl: idDocumentUrl,
        idType: _selectedIdType,
        faceImageUrl: faceImageUrl,
      );

      if (mounted) {
        setState(() => _isSubmitted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted for review! An admin will verify your seller account.'),
            backgroundColor: AppTheme.primaryContainer,
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        String userMsg = e.toString();
        if (userMsg.contains('42501') || userMsg.contains('row-level security')) {
          userMsg = 'Session expired. Please sign in again and retry.';
        } else if (userMsg.contains('Failed to upload')) {
          userMsg = 'Could not upload files. Check your connection and try again.';
        } else if (userMsg.contains('column') && userMsg.contains('does not exist')) {
          userMsg = 'Setup incomplete — missing database columns. Contact support.';
        } else if (userMsg.contains('relation') && userMsg.contains('does not exist')) {
          userMsg = 'Setup incomplete — database tables missing. Contact support.';
        } else if (userMsg.contains('foreign key')) {
          userMsg = 'Account setup issue. Please sign out and sign in again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMsg),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _skip() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedIdType != null && _idFile != null && _faceFile != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onBackground),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceContainer),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 40,
                  color: AppTheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Your Seller Account',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.onBackground,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Upload a government-issued ID and your face image for admin verification.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // ID Type Selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select ID Type',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _idTypes.map((t) {
                  final isSelected = _selectedIdType == t['key'];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: t['key'] == 'voter_card' ? 8 : 0,
                        right: t['key'] == 'voter_card' ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIdType = t['key']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.08) : AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            t['label']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isSelected ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // ID Document Upload
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upload Government ID',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUploading ? null : () => _pickFile(true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: _idFile != null
                        ? AppTheme.primaryContainer.withValues(alpha: 0.05)
                        : AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _idFile != null ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                      width: _idFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _idFile != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                        size: 40,
                        color: _idFile != null ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _idFile != null ? _idFile!.name : 'Tap to select ID document',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _idFile != null ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_idFile != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(_idFile!.size / 1024 / 1024).toStringAsFixed(1)} MB',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_idFile != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isUploading ? null : () => _pickFile(true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Choose a different file'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 24),
              // Face Image Upload
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upload Face Image',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A clear photo of your face for identity verification.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUploading ? null : () => _pickFile(false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: _faceFile != null
                        ? AppTheme.primaryContainer.withValues(alpha: 0.05)
                        : AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _faceFile != null ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                      width: _faceFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _faceFile != null ? Icons.check_circle_outline : Icons.camera_alt_outlined,
                        size: 40,
                        color: _faceFile != null ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _faceFile != null ? _faceFile!.name : 'Tap to select face image',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _faceFile != null ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_faceFile != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(_faceFile!.size / 1024 / 1024).toStringAsFixed(1)} MB',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_faceFile != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isUploading ? null : () => _pickFile(false),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Choose a different file'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canSubmit && !_isUploading && !_isSubmitted)
                      ? _submitVerification
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (canSubmit && !_isSubmitted)
                        ? AppTheme.primaryContainer
                        : AppTheme.outlineVariant,
                    foregroundColor: (canSubmit && !_isSubmitted)
                        ? AppTheme.onPrimary
                        : AppTheme.onSurfaceVariant,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                          ),
                        )
                      : const Text('Submit for Review'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isUploading ? null : _skip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.onSurfaceVariant,
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: AppTheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Skip for now — verify later from profile'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can complete verification anytime from your profile settings. Until then, you can browse as a buyer.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
