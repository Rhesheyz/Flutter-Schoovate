// config_model.dart
class ConfigModel {
  String mapLink;
  String? backgroundImageUrl; // URL for the background image

  ConfigModel({
    required this.mapLink,
    this.backgroundImageUrl,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      mapLink: json['map_link'] ?? '',
      backgroundImageUrl:
          json['background_image'], // Adjust according to your API response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'map_link': mapLink,
      'background_image': backgroundImageUrl,
    };
  }
}
