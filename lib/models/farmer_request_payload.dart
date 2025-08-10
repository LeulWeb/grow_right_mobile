class FarmerRequestPayload {
  final double lat;
  final double lng;
  final String address;
  final int soilId;
  final int seasonId;
  final String goalValue; // e.g. "Livestock Feed Production"
  final bool hasIrrigation;

  FarmerRequestPayload({
    required this.lat,
    required this.lng,
    required this.address,
    required this.soilId,
    required this.seasonId,
    required this.goalValue,
    required this.hasIrrigation,
  });

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "address": address,
    "soil_id": soilId,
    "season_id": seasonId,
    "goals": goalValue,
    "has_irrigation": hasIrrigation,
  };
}
