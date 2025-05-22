class SystemConfig {
  final AdsConfig adsConfig;

  SystemConfig({required this.adsConfig});

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
        adsConfig: AdsConfig.fromJson(json['adsConfig'])
    );
  }

  factory SystemConfig.defaultValue() {
    return SystemConfig(
      adsConfig: AdsConfig.defaultValue()
    )  ;
  }
}

class AdsConfig {
  final double adProbability;

  //in seconds
  final int minTimeBetweenAds;

  AdsConfig({
    required this.adProbability,
    required this.minTimeBetweenAds,
  });

  factory AdsConfig.fromJson(Map<String, dynamic> json) {
    return AdsConfig(
      adProbability: json['adProbability']?.toDouble() ?? 0.0,
      minTimeBetweenAds: json['minTimeBetweenAds']?.toInt() ?? 0,
    );
  }

  factory AdsConfig.defaultValue() {
    return AdsConfig(adProbability: 1, minTimeBetweenAds: 0);
  }
}