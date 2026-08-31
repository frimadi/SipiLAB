import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class UjiPhotoCaptureWidget extends StatefulWidget {
  final List<String> initialPhotos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;
  final String title;

  const UjiPhotoCaptureWidget({
    super.key,
    required this.initialPhotos,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
    this.title = 'Foto Dokumentasi Pengujian', 
  });

  @override
  State<UjiPhotoCaptureWidget> createState() => _UjiPhotoCaptureWidgetState(); 
}

class _UjiPhotoCaptureWidgetState extends State<UjiPhotoCaptureWidget> {
  final ImagePicker _picker = ImagePicker();
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    
    _photoPaths = List.from(widget.initialPhotos);
  }

  
  Future<String> _savePhotoToAppDir(String sourcePath) async {
    
    final Directory appDir = await getApplicationDocumentsDirectory();
    
    
    final String fileName = 
        '${widget.title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    
    final String targetPath = path.join(appDir.path, 'photos', fileName);
    
    
    final Directory photosDir = Directory(path.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    
    
    final File sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);
    
   
    return targetPath;
  }

  
  Future<void> _takePhoto() async {
    if (_photoPaths.length >= widget.maxPhotos) {
      _showMaxPhotosDialog();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        
        final String savedPath = await _savePhotoToAppDir(photo.path);
        
        setState(() {
          _photoPaths.add(savedPath);
        });
        
        widget.onPhotosChanged(_photoPaths);
        _showSuccessSnackBar('Foto berhasil ditambahkan');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_photoPaths.length >= widget.maxPhotos) {
      _showMaxPhotosDialog();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
       
        final String savedPath = await _savePhotoToAppDir(photo.path);
        
        setState(() {
          _photoPaths.add(savedPath);
        });
        
        widget.onPhotosChanged(_photoPaths);
        _showSuccessSnackBar('Foto berhasil ditambahkan');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih foto dari galeri: $e');
    }
  }

  
  void _deletePhoto(int index) {
   
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: const Text('Hapus Foto?'),
        content: const Text('Foto yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
               
                try {
                  File(_photoPaths[index]).deleteSync();
                } catch (e) {
                  debugPrint('Error deleting file: $e');
                }
                _photoPaths.removeAt(index);
              });
              
              widget.onPhotosChanged(_photoPaths);
              Navigator.pop(context);
              _showSuccessSnackBar('Foto berhasil dihapus');
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  
  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(
          photoPath: _photoPaths[index],
          photoIndex: index + 1,
          totalPhotos: _photoPaths.length,
        ),
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
             
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${_photoPaths.length}/${widget.maxPhotos} foto',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          
          if (_photoPaths.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _photoPaths.length,
              itemBuilder: (context, index) {
                return _buildPhotoThumbnail(index);
              },
            ),
          
          if (_photoPaths.isNotEmpty) const SizedBox(height: 16),

         
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text('Ambil Foto'),
                 
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                  label: const Text('Galeri'),
                 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    return GestureDetector(
      onTap: () => _viewPhoto(index),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              
              child: Image.file(
                File(_photoPaths[index]), 
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
               
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Gagal memuat foto dari path: ${_photoPaths[index]}. Error: $error');
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40)
                  );
                },
              ),
            ),
          ),
          
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _deletePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  
  void _showMaxPhotosDialog() { }
  void _showSuccessSnackBar(String message) { 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  void _showErrorSnackBar(String message) { 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}


class PhotoViewScreen extends StatelessWidget {
  final String photoPath;
  final int photoIndex;
  final int totalPhotos;

  const PhotoViewScreen({
    super.key,
    required this.photoPath,
    required this.photoIndex,
    required this.totalPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Foto $photoIndex dari $totalPhotos'),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
         
          child: Image.file(File(photoPath)),
        ),
      ),
    );
  }
}