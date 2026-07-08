/// Versions de maison toggleables (V1 : 2). L'asset PNG est déposé plus tard.
enum HouseVersion {
  cosy('Cosy lofi', 'assets/houses/bg_cosy.png'),
  riad('Riad marocain', 'assets/houses/bg_riad.png');

  const HouseVersion(this.label, this.asset);

  final String label;
  final String asset;
}
