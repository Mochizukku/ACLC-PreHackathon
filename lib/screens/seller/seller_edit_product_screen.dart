import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/store_repository.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF9CA3AF);
const _border = Color(0xFFE5E7EB);

class SellerEditProductScreen extends StatefulWidget {
  final SellerProductItem product;

  const SellerEditProductScreen({super.key, required this.product});

  @override
  State<SellerEditProductScreen> createState() =>
      _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late bool _isAvailable;

  Uint8List? _pickedImageBytes;
  String? _selectedImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
        text: widget.product.price.toStringAsFixed(2));
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _stockController =
        TextEditingController(text: '${widget.product.stock}');
    _isAvailable = widget.product.isAvailable;
    if (widget.product.imageBytes != null) {
      _pickedImageBytes = Uint8List.fromList(widget.product.imageBytes!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _selectedImagePath = picked.path;
      });
    } catch (e) {
      // image_picker may not be available in all envs — show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open gallery. Please try again.'),
        ),
      );
    }
  }

  void _saveChanges() {
    final name = _nameController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? widget.product.stock;
    final price = double.tryParse(_priceController.text.trim()) ?? widget.product.price;
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name cannot be empty.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = StoreRepository.instance;
    final index = repo.products.indexWhere((p) => p.id == widget.product.id);
    if (index != -1) {
      repo.products[index].name = name;
      repo.products[index].stock = stock;
      repo.products[index].price = price;
      repo.products[index].description = description;
      repo.products[index].isAvailable = _isAvailable;
      if (_pickedImageBytes != null) {
        repo.products[index].imageBytes = _pickedImageBytes!.toList();
        repo.products[index].imageUrl = '';
      }
      repo.notifyAll();
    }

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$name" updated successfully.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Upload Block (matching Image 3 layout)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: _pickedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.memory(
                            _pickedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : widget.product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    widget.product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(),
                                  ),
                                  Container(
                                    color: Colors.black26,
                                    child: const Center(
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _imagePlaceholder(),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Upload / Change Photo'),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Name
              _FieldLabel(label: 'Product Name'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameController,
                hintText: 'e.g. Siomai',
              ),
              const SizedBox(height: 16),

              // Price
              _FieldLabel(label: 'Price per Piece (₱)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _priceController,
                hintText: 'e.g. 7.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Stock
              _FieldLabel(label: 'Stock (pieces)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _stockController,
                hintText: 'e.g. 30',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Description
              _FieldLabel(label: 'Description'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'e.g. Usually paired with rice.',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Availability Toggle
              _FieldLabel(label: 'Availability'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isAvailable
                            ? const Color(0xFF00C714)
                            : Colors.red,
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      activeColor: const Color(0xFF00C714),
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_outlined, size: 48, color: Color(0xFFBBBBBB)),
        SizedBox(height: 8),
        Text(
          'Product\nImage',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _ink, width: 1.2),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }
}
