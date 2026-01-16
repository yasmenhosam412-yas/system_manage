import 'package:cloudinary/cloudinary.dart';

Future<String> saveToCloudinary(String? path) async {
  if (path == null) throw Exception("File path cannot be null");

  try {
    final cloudinary = Cloudinary.unsignedConfig(cloudName: "dxrgrjjcy");

    final response = await cloudinary.unsignedUpload(
      file: path,
      uploadPreset: "ml_default",
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      return response.secureUrl ?? '';
    } else {
      throw Exception("Upload failed: ${response.error}");
    }
  } catch (e) {
    throw Exception("Cloudinary upload error: $e");
  }
}
