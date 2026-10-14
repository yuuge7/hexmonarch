/// What the tactical map draws over the basemap. Turf zones and your own
/// position are always on; everything else is a layer the player can switch.
enum MapLayer {
  labels('labels', 'Names', 'Turf names; close in, what each one supplies per hour.'),
  spheres('spheres', 'Supply spheres', 'The ground each hub supplies.'),
  reach('reach', 'Reach outline', 'Open ground you can plant from your turfs.'),
  relays('relays', 'Relays', 'Links between hubs, with traffic running along them.'),
  supplyLines('supply_lines', 'Supply lines', 'A line from every turf to the hub that supplies it.'),
  reachWeb('reach_web', 'Reach web', 'Lines between your turfs that are in plant range of each other.'),
  integrity('integrity', 'Integrity rings', 'How intact each turf is. Red and dashed while under siege.'),
  odds('odds', 'Breach odds', 'Your chance on every rival turf. Grey: nothing of yours reaches it yet.'),
  ground('ground', 'Ground type', 'A dot in each turf: amber pays credits, white materials, blue intel.'),
  events('events', 'Field events', 'Convoys, dead drops, offensives and locked-down districts.');

  const MapLayer(this.key, this.title, this.blurb);
  final String key;
  final String title;
  final String blurb;

  static MapLayer? fromKey(String k) {
    for (final l in MapLayer.values) {
      if (l.key == k) return l;
    }
    return null;
  }
}

/// Ready-made sets of layers. Any other combination is [custom].
enum MapMode {
  clean('Clean', 'Turfs, relays and events. Nothing else on the streets.'),
  tactical('Tactical', 'The everyday view: spheres, reach and relays.'),
  intel('Intel', 'Everything: supply lines, reach web, integrity, odds.'),
  custom('Custom', 'Your own mix.');

  const MapMode(this.title, this.blurb);
  final String title;
  final String blurb;
}

const _clean = {MapLayer.labels, MapLayer.relays, MapLayer.events};
const _tactical = {MapLayer.labels, MapLayer.spheres, MapLayer.reach, MapLayer.relays, MapLayer.events};

Set<MapLayer> layersOf(MapMode m) => switch (m) {
      MapMode.clean => _clean,
      MapMode.tactical => _tactical,
      MapMode.intel || MapMode.custom => MapLayer.values.toSet(),
    };

/// The switched-on layers, kept in the player's settings under 'layers'.
class MapLayers {
  const MapLayers(this.on);
  final Set<MapLayer> on;

  /// Before layers existed the map drew the Tactical set.
  static const standard = MapLayers(_tactical);

  static MapLayers fromSetting(Object? v) {
    if (v is! List) return standard;
    return MapLayers({
      for (final k in v) ?MapLayer.fromKey('$k'),
    });
  }

  List<String> toSetting() => [for (final l in on) l.key];

  bool has(MapLayer l) => on.contains(l);

  MapLayers toggle(MapLayer l) => MapLayers(has(l) ? ({...on}..remove(l)) : {...on, l});

  MapMode get mode {
    for (final m in [MapMode.clean, MapMode.tactical, MapMode.intel]) {
      final set = layersOf(m);
      if (set.length == on.length && set.containsAll(on)) return m;
    }
    return MapMode.custom;
  }
}
