// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class HexNodes extends Table with TableInfo<HexNodes, HexRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  HexNodes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _h3IndexMeta = const VerificationMeta(
    'h3Index',
  );
  late final GeneratedColumn<String> h3Index = GeneratedColumn<String>(
    'h3_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _districtRes6Meta = const VerificationMeta(
    'districtRes6',
  );
  late final GeneratedColumn<String> districtRes6 = GeneratedColumn<String>(
    'district_res6',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _biomeTypeMeta = const VerificationMeta(
    'biomeType',
  );
  late final GeneratedColumn<String> biomeType = GeneratedColumn<String>(
    'biome_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _anomalyTraitMeta = const VerificationMeta(
    'anomalyTrait',
  );
  late final GeneratedColumn<String> anomalyTrait = GeneratedColumn<String>(
    'anomaly_trait',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'neutral\'',
    defaultValue: const CustomExpression('\'neutral\''),
  );
  static const VerificationMeta _garrisonLevelMeta = const VerificationMeta(
    'garrisonLevel',
  );
  late final GeneratedColumn<int> garrisonLevel = GeneratedColumn<int>(
    'garrison_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _structuralIntegrityMeta =
      const VerificationMeta('structuralIntegrity');
  late final GeneratedColumn<double> structuralIntegrity =
      GeneratedColumn<double>(
        'structural_integrity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT 100.0',
        defaultValue: const CustomExpression('100.0'),
      );
  static const VerificationMeta _isAnchorHubMeta = const VerificationMeta(
    'isAnchorHub',
  );
  late final GeneratedColumn<bool> isAnchorHub = GeneratedColumn<bool>(
    'is_anchor_hub',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _connectedRelayTargetMeta =
      const VerificationMeta('connectedRelayTarget');
  late final GeneratedColumn<String> connectedRelayTarget =
      GeneratedColumn<String>(
        'connected_relay_target',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _lastTickTimestampMeta = const VerificationMeta(
    'lastTickTimestamp',
  );
  late final GeneratedColumn<int> lastTickTimestamp = GeneratedColumn<int>(
    'last_tick_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _turfLatMeta = const VerificationMeta(
    'turfLat',
  );
  late final GeneratedColumn<double> turfLat = GeneratedColumn<double>(
    'turf_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _turfLngMeta = const VerificationMeta(
    'turfLng',
  );
  late final GeneratedColumn<double> turfLng = GeneratedColumn<double>(
    'turf_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _turfNameMeta = const VerificationMeta(
    'turfName',
  );
  late final GeneratedColumn<String> turfName = GeneratedColumn<String>(
    'turf_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isStationMeta = const VerificationMeta(
    'isStation',
  );
  late final GeneratedColumn<bool> isStation = GeneratedColumn<bool>(
    'is_station',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _hubLevelMeta = const VerificationMeta(
    'hubLevel',
  );
  late final GeneratedColumn<int> hubLevel = GeneratedColumn<int>(
    'hub_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    h3Index,
    districtRes6,
    biomeType,
    anomalyTrait,
    owner,
    garrisonLevel,
    structuralIntegrity,
    isAnchorHub,
    connectedRelayTarget,
    lastTickTimestamp,
    turfLat,
    turfLng,
    turfName,
    isStation,
    hubLevel,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hex_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HexRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('h3_index')) {
      context.handle(
        _h3IndexMeta,
        h3Index.isAcceptableOrUnknown(data['h3_index']!, _h3IndexMeta),
      );
    } else if (isInserting) {
      context.missing(_h3IndexMeta);
    }
    if (data.containsKey('district_res6')) {
      context.handle(
        _districtRes6Meta,
        districtRes6.isAcceptableOrUnknown(
          data['district_res6']!,
          _districtRes6Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_districtRes6Meta);
    }
    if (data.containsKey('biome_type')) {
      context.handle(
        _biomeTypeMeta,
        biomeType.isAcceptableOrUnknown(data['biome_type']!, _biomeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_biomeTypeMeta);
    }
    if (data.containsKey('anomaly_trait')) {
      context.handle(
        _anomalyTraitMeta,
        anomalyTrait.isAcceptableOrUnknown(
          data['anomaly_trait']!,
          _anomalyTraitMeta,
        ),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('garrison_level')) {
      context.handle(
        _garrisonLevelMeta,
        garrisonLevel.isAcceptableOrUnknown(
          data['garrison_level']!,
          _garrisonLevelMeta,
        ),
      );
    }
    if (data.containsKey('structural_integrity')) {
      context.handle(
        _structuralIntegrityMeta,
        structuralIntegrity.isAcceptableOrUnknown(
          data['structural_integrity']!,
          _structuralIntegrityMeta,
        ),
      );
    }
    if (data.containsKey('is_anchor_hub')) {
      context.handle(
        _isAnchorHubMeta,
        isAnchorHub.isAcceptableOrUnknown(
          data['is_anchor_hub']!,
          _isAnchorHubMeta,
        ),
      );
    }
    if (data.containsKey('connected_relay_target')) {
      context.handle(
        _connectedRelayTargetMeta,
        connectedRelayTarget.isAcceptableOrUnknown(
          data['connected_relay_target']!,
          _connectedRelayTargetMeta,
        ),
      );
    }
    if (data.containsKey('last_tick_timestamp')) {
      context.handle(
        _lastTickTimestampMeta,
        lastTickTimestamp.isAcceptableOrUnknown(
          data['last_tick_timestamp']!,
          _lastTickTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastTickTimestampMeta);
    }
    if (data.containsKey('turf_lat')) {
      context.handle(
        _turfLatMeta,
        turfLat.isAcceptableOrUnknown(data['turf_lat']!, _turfLatMeta),
      );
    } else if (isInserting) {
      context.missing(_turfLatMeta);
    }
    if (data.containsKey('turf_lng')) {
      context.handle(
        _turfLngMeta,
        turfLng.isAcceptableOrUnknown(data['turf_lng']!, _turfLngMeta),
      );
    } else if (isInserting) {
      context.missing(_turfLngMeta);
    }
    if (data.containsKey('turf_name')) {
      context.handle(
        _turfNameMeta,
        turfName.isAcceptableOrUnknown(data['turf_name']!, _turfNameMeta),
      );
    } else if (isInserting) {
      context.missing(_turfNameMeta);
    }
    if (data.containsKey('is_station')) {
      context.handle(
        _isStationMeta,
        isStation.isAcceptableOrUnknown(data['is_station']!, _isStationMeta),
      );
    }
    if (data.containsKey('hub_level')) {
      context.handle(
        _hubLevelMeta,
        hubLevel.isAcceptableOrUnknown(data['hub_level']!, _hubLevelMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {h3Index};
  @override
  HexRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HexRow(
      h3Index: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}h3_index'],
      )!,
      districtRes6: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district_res6'],
      )!,
      biomeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biome_type'],
      )!,
      anomalyTrait: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anomaly_trait'],
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      garrisonLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garrison_level'],
      )!,
      structuralIntegrity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}structural_integrity'],
      )!,
      isAnchorHub: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_anchor_hub'],
      )!,
      connectedRelayTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connected_relay_target'],
      ),
      lastTickTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_tick_timestamp'],
      )!,
      turfLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}turf_lat'],
      )!,
      turfLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}turf_lng'],
      )!,
      turfName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}turf_name'],
      )!,
      isStation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_station'],
      )!,
      hubLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hub_level'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      ),
    );
  }

  @override
  HexNodes createAlias(String alias) {
    return HexNodes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class HexRow extends DataClass implements Insertable<HexRow> {
  final String h3Index;
  final String districtRes6;
  final String biomeType;
  final String? anomalyTrait;
  final String owner;
  final int garrisonLevel;
  final double structuralIntegrity;
  final bool isAnchorHub;
  final String? connectedRelayTarget;
  final int lastTickTimestamp;
  final double turfLat;

  /// ext: exact turf center
  final double turfLng;

  /// ext
  final String turfName;

  /// ext: auto-named after the nearest station/street
  final bool isStation;

  /// ext: planted at a transit station
  final int hubLevel;

  /// ext: anchor hub tier (0 = not a hub)
  final int? capturedAt;
  const HexRow({
    required this.h3Index,
    required this.districtRes6,
    required this.biomeType,
    this.anomalyTrait,
    required this.owner,
    required this.garrisonLevel,
    required this.structuralIntegrity,
    required this.isAnchorHub,
    this.connectedRelayTarget,
    required this.lastTickTimestamp,
    required this.turfLat,
    required this.turfLng,
    required this.turfName,
    required this.isStation,
    required this.hubLevel,
    this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['h3_index'] = Variable<String>(h3Index);
    map['district_res6'] = Variable<String>(districtRes6);
    map['biome_type'] = Variable<String>(biomeType);
    if (!nullToAbsent || anomalyTrait != null) {
      map['anomaly_trait'] = Variable<String>(anomalyTrait);
    }
    map['owner'] = Variable<String>(owner);
    map['garrison_level'] = Variable<int>(garrisonLevel);
    map['structural_integrity'] = Variable<double>(structuralIntegrity);
    map['is_anchor_hub'] = Variable<bool>(isAnchorHub);
    if (!nullToAbsent || connectedRelayTarget != null) {
      map['connected_relay_target'] = Variable<String>(connectedRelayTarget);
    }
    map['last_tick_timestamp'] = Variable<int>(lastTickTimestamp);
    map['turf_lat'] = Variable<double>(turfLat);
    map['turf_lng'] = Variable<double>(turfLng);
    map['turf_name'] = Variable<String>(turfName);
    map['is_station'] = Variable<bool>(isStation);
    map['hub_level'] = Variable<int>(hubLevel);
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<int>(capturedAt);
    }
    return map;
  }

  HexNodesCompanion toCompanion(bool nullToAbsent) {
    return HexNodesCompanion(
      h3Index: Value(h3Index),
      districtRes6: Value(districtRes6),
      biomeType: Value(biomeType),
      anomalyTrait: anomalyTrait == null && nullToAbsent
          ? const Value.absent()
          : Value(anomalyTrait),
      owner: Value(owner),
      garrisonLevel: Value(garrisonLevel),
      structuralIntegrity: Value(structuralIntegrity),
      isAnchorHub: Value(isAnchorHub),
      connectedRelayTarget: connectedRelayTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(connectedRelayTarget),
      lastTickTimestamp: Value(lastTickTimestamp),
      turfLat: Value(turfLat),
      turfLng: Value(turfLng),
      turfName: Value(turfName),
      isStation: Value(isStation),
      hubLevel: Value(hubLevel),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
    );
  }

  factory HexRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HexRow(
      h3Index: serializer.fromJson<String>(json['h3_index']),
      districtRes6: serializer.fromJson<String>(json['district_res6']),
      biomeType: serializer.fromJson<String>(json['biome_type']),
      anomalyTrait: serializer.fromJson<String?>(json['anomaly_trait']),
      owner: serializer.fromJson<String>(json['owner']),
      garrisonLevel: serializer.fromJson<int>(json['garrison_level']),
      structuralIntegrity: serializer.fromJson<double>(
        json['structural_integrity'],
      ),
      isAnchorHub: serializer.fromJson<bool>(json['is_anchor_hub']),
      connectedRelayTarget: serializer.fromJson<String?>(
        json['connected_relay_target'],
      ),
      lastTickTimestamp: serializer.fromJson<int>(json['last_tick_timestamp']),
      turfLat: serializer.fromJson<double>(json['turf_lat']),
      turfLng: serializer.fromJson<double>(json['turf_lng']),
      turfName: serializer.fromJson<String>(json['turf_name']),
      isStation: serializer.fromJson<bool>(json['is_station']),
      hubLevel: serializer.fromJson<int>(json['hub_level']),
      capturedAt: serializer.fromJson<int?>(json['captured_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'h3_index': serializer.toJson<String>(h3Index),
      'district_res6': serializer.toJson<String>(districtRes6),
      'biome_type': serializer.toJson<String>(biomeType),
      'anomaly_trait': serializer.toJson<String?>(anomalyTrait),
      'owner': serializer.toJson<String>(owner),
      'garrison_level': serializer.toJson<int>(garrisonLevel),
      'structural_integrity': serializer.toJson<double>(structuralIntegrity),
      'is_anchor_hub': serializer.toJson<bool>(isAnchorHub),
      'connected_relay_target': serializer.toJson<String?>(
        connectedRelayTarget,
      ),
      'last_tick_timestamp': serializer.toJson<int>(lastTickTimestamp),
      'turf_lat': serializer.toJson<double>(turfLat),
      'turf_lng': serializer.toJson<double>(turfLng),
      'turf_name': serializer.toJson<String>(turfName),
      'is_station': serializer.toJson<bool>(isStation),
      'hub_level': serializer.toJson<int>(hubLevel),
      'captured_at': serializer.toJson<int?>(capturedAt),
    };
  }

  HexRow copyWith({
    String? h3Index,
    String? districtRes6,
    String? biomeType,
    Value<String?> anomalyTrait = const Value.absent(),
    String? owner,
    int? garrisonLevel,
    double? structuralIntegrity,
    bool? isAnchorHub,
    Value<String?> connectedRelayTarget = const Value.absent(),
    int? lastTickTimestamp,
    double? turfLat,
    double? turfLng,
    String? turfName,
    bool? isStation,
    int? hubLevel,
    Value<int?> capturedAt = const Value.absent(),
  }) => HexRow(
    h3Index: h3Index ?? this.h3Index,
    districtRes6: districtRes6 ?? this.districtRes6,
    biomeType: biomeType ?? this.biomeType,
    anomalyTrait: anomalyTrait.present ? anomalyTrait.value : this.anomalyTrait,
    owner: owner ?? this.owner,
    garrisonLevel: garrisonLevel ?? this.garrisonLevel,
    structuralIntegrity: structuralIntegrity ?? this.structuralIntegrity,
    isAnchorHub: isAnchorHub ?? this.isAnchorHub,
    connectedRelayTarget: connectedRelayTarget.present
        ? connectedRelayTarget.value
        : this.connectedRelayTarget,
    lastTickTimestamp: lastTickTimestamp ?? this.lastTickTimestamp,
    turfLat: turfLat ?? this.turfLat,
    turfLng: turfLng ?? this.turfLng,
    turfName: turfName ?? this.turfName,
    isStation: isStation ?? this.isStation,
    hubLevel: hubLevel ?? this.hubLevel,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
  );
  HexRow copyWithCompanion(HexNodesCompanion data) {
    return HexRow(
      h3Index: data.h3Index.present ? data.h3Index.value : this.h3Index,
      districtRes6: data.districtRes6.present
          ? data.districtRes6.value
          : this.districtRes6,
      biomeType: data.biomeType.present ? data.biomeType.value : this.biomeType,
      anomalyTrait: data.anomalyTrait.present
          ? data.anomalyTrait.value
          : this.anomalyTrait,
      owner: data.owner.present ? data.owner.value : this.owner,
      garrisonLevel: data.garrisonLevel.present
          ? data.garrisonLevel.value
          : this.garrisonLevel,
      structuralIntegrity: data.structuralIntegrity.present
          ? data.structuralIntegrity.value
          : this.structuralIntegrity,
      isAnchorHub: data.isAnchorHub.present
          ? data.isAnchorHub.value
          : this.isAnchorHub,
      connectedRelayTarget: data.connectedRelayTarget.present
          ? data.connectedRelayTarget.value
          : this.connectedRelayTarget,
      lastTickTimestamp: data.lastTickTimestamp.present
          ? data.lastTickTimestamp.value
          : this.lastTickTimestamp,
      turfLat: data.turfLat.present ? data.turfLat.value : this.turfLat,
      turfLng: data.turfLng.present ? data.turfLng.value : this.turfLng,
      turfName: data.turfName.present ? data.turfName.value : this.turfName,
      isStation: data.isStation.present ? data.isStation.value : this.isStation,
      hubLevel: data.hubLevel.present ? data.hubLevel.value : this.hubLevel,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HexRow(')
          ..write('h3Index: $h3Index, ')
          ..write('districtRes6: $districtRes6, ')
          ..write('biomeType: $biomeType, ')
          ..write('anomalyTrait: $anomalyTrait, ')
          ..write('owner: $owner, ')
          ..write('garrisonLevel: $garrisonLevel, ')
          ..write('structuralIntegrity: $structuralIntegrity, ')
          ..write('isAnchorHub: $isAnchorHub, ')
          ..write('connectedRelayTarget: $connectedRelayTarget, ')
          ..write('lastTickTimestamp: $lastTickTimestamp, ')
          ..write('turfLat: $turfLat, ')
          ..write('turfLng: $turfLng, ')
          ..write('turfName: $turfName, ')
          ..write('isStation: $isStation, ')
          ..write('hubLevel: $hubLevel, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    h3Index,
    districtRes6,
    biomeType,
    anomalyTrait,
    owner,
    garrisonLevel,
    structuralIntegrity,
    isAnchorHub,
    connectedRelayTarget,
    lastTickTimestamp,
    turfLat,
    turfLng,
    turfName,
    isStation,
    hubLevel,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HexRow &&
          other.h3Index == this.h3Index &&
          other.districtRes6 == this.districtRes6 &&
          other.biomeType == this.biomeType &&
          other.anomalyTrait == this.anomalyTrait &&
          other.owner == this.owner &&
          other.garrisonLevel == this.garrisonLevel &&
          other.structuralIntegrity == this.structuralIntegrity &&
          other.isAnchorHub == this.isAnchorHub &&
          other.connectedRelayTarget == this.connectedRelayTarget &&
          other.lastTickTimestamp == this.lastTickTimestamp &&
          other.turfLat == this.turfLat &&
          other.turfLng == this.turfLng &&
          other.turfName == this.turfName &&
          other.isStation == this.isStation &&
          other.hubLevel == this.hubLevel &&
          other.capturedAt == this.capturedAt);
}

class HexNodesCompanion extends UpdateCompanion<HexRow> {
  final Value<String> h3Index;
  final Value<String> districtRes6;
  final Value<String> biomeType;
  final Value<String?> anomalyTrait;
  final Value<String> owner;
  final Value<int> garrisonLevel;
  final Value<double> structuralIntegrity;
  final Value<bool> isAnchorHub;
  final Value<String?> connectedRelayTarget;
  final Value<int> lastTickTimestamp;
  final Value<double> turfLat;
  final Value<double> turfLng;
  final Value<String> turfName;
  final Value<bool> isStation;
  final Value<int> hubLevel;
  final Value<int?> capturedAt;
  final Value<int> rowid;
  const HexNodesCompanion({
    this.h3Index = const Value.absent(),
    this.districtRes6 = const Value.absent(),
    this.biomeType = const Value.absent(),
    this.anomalyTrait = const Value.absent(),
    this.owner = const Value.absent(),
    this.garrisonLevel = const Value.absent(),
    this.structuralIntegrity = const Value.absent(),
    this.isAnchorHub = const Value.absent(),
    this.connectedRelayTarget = const Value.absent(),
    this.lastTickTimestamp = const Value.absent(),
    this.turfLat = const Value.absent(),
    this.turfLng = const Value.absent(),
    this.turfName = const Value.absent(),
    this.isStation = const Value.absent(),
    this.hubLevel = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HexNodesCompanion.insert({
    required String h3Index,
    required String districtRes6,
    required String biomeType,
    this.anomalyTrait = const Value.absent(),
    this.owner = const Value.absent(),
    this.garrisonLevel = const Value.absent(),
    this.structuralIntegrity = const Value.absent(),
    this.isAnchorHub = const Value.absent(),
    this.connectedRelayTarget = const Value.absent(),
    required int lastTickTimestamp,
    required double turfLat,
    required double turfLng,
    required String turfName,
    this.isStation = const Value.absent(),
    this.hubLevel = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : h3Index = Value(h3Index),
       districtRes6 = Value(districtRes6),
       biomeType = Value(biomeType),
       lastTickTimestamp = Value(lastTickTimestamp),
       turfLat = Value(turfLat),
       turfLng = Value(turfLng),
       turfName = Value(turfName);
  static Insertable<HexRow> custom({
    Expression<String>? h3Index,
    Expression<String>? districtRes6,
    Expression<String>? biomeType,
    Expression<String>? anomalyTrait,
    Expression<String>? owner,
    Expression<int>? garrisonLevel,
    Expression<double>? structuralIntegrity,
    Expression<bool>? isAnchorHub,
    Expression<String>? connectedRelayTarget,
    Expression<int>? lastTickTimestamp,
    Expression<double>? turfLat,
    Expression<double>? turfLng,
    Expression<String>? turfName,
    Expression<bool>? isStation,
    Expression<int>? hubLevel,
    Expression<int>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (h3Index != null) 'h3_index': h3Index,
      if (districtRes6 != null) 'district_res6': districtRes6,
      if (biomeType != null) 'biome_type': biomeType,
      if (anomalyTrait != null) 'anomaly_trait': anomalyTrait,
      if (owner != null) 'owner': owner,
      if (garrisonLevel != null) 'garrison_level': garrisonLevel,
      if (structuralIntegrity != null)
        'structural_integrity': structuralIntegrity,
      if (isAnchorHub != null) 'is_anchor_hub': isAnchorHub,
      if (connectedRelayTarget != null)
        'connected_relay_target': connectedRelayTarget,
      if (lastTickTimestamp != null) 'last_tick_timestamp': lastTickTimestamp,
      if (turfLat != null) 'turf_lat': turfLat,
      if (turfLng != null) 'turf_lng': turfLng,
      if (turfName != null) 'turf_name': turfName,
      if (isStation != null) 'is_station': isStation,
      if (hubLevel != null) 'hub_level': hubLevel,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HexNodesCompanion copyWith({
    Value<String>? h3Index,
    Value<String>? districtRes6,
    Value<String>? biomeType,
    Value<String?>? anomalyTrait,
    Value<String>? owner,
    Value<int>? garrisonLevel,
    Value<double>? structuralIntegrity,
    Value<bool>? isAnchorHub,
    Value<String?>? connectedRelayTarget,
    Value<int>? lastTickTimestamp,
    Value<double>? turfLat,
    Value<double>? turfLng,
    Value<String>? turfName,
    Value<bool>? isStation,
    Value<int>? hubLevel,
    Value<int?>? capturedAt,
    Value<int>? rowid,
  }) {
    return HexNodesCompanion(
      h3Index: h3Index ?? this.h3Index,
      districtRes6: districtRes6 ?? this.districtRes6,
      biomeType: biomeType ?? this.biomeType,
      anomalyTrait: anomalyTrait ?? this.anomalyTrait,
      owner: owner ?? this.owner,
      garrisonLevel: garrisonLevel ?? this.garrisonLevel,
      structuralIntegrity: structuralIntegrity ?? this.structuralIntegrity,
      isAnchorHub: isAnchorHub ?? this.isAnchorHub,
      connectedRelayTarget: connectedRelayTarget ?? this.connectedRelayTarget,
      lastTickTimestamp: lastTickTimestamp ?? this.lastTickTimestamp,
      turfLat: turfLat ?? this.turfLat,
      turfLng: turfLng ?? this.turfLng,
      turfName: turfName ?? this.turfName,
      isStation: isStation ?? this.isStation,
      hubLevel: hubLevel ?? this.hubLevel,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (h3Index.present) {
      map['h3_index'] = Variable<String>(h3Index.value);
    }
    if (districtRes6.present) {
      map['district_res6'] = Variable<String>(districtRes6.value);
    }
    if (biomeType.present) {
      map['biome_type'] = Variable<String>(biomeType.value);
    }
    if (anomalyTrait.present) {
      map['anomaly_trait'] = Variable<String>(anomalyTrait.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (garrisonLevel.present) {
      map['garrison_level'] = Variable<int>(garrisonLevel.value);
    }
    if (structuralIntegrity.present) {
      map['structural_integrity'] = Variable<double>(structuralIntegrity.value);
    }
    if (isAnchorHub.present) {
      map['is_anchor_hub'] = Variable<bool>(isAnchorHub.value);
    }
    if (connectedRelayTarget.present) {
      map['connected_relay_target'] = Variable<String>(
        connectedRelayTarget.value,
      );
    }
    if (lastTickTimestamp.present) {
      map['last_tick_timestamp'] = Variable<int>(lastTickTimestamp.value);
    }
    if (turfLat.present) {
      map['turf_lat'] = Variable<double>(turfLat.value);
    }
    if (turfLng.present) {
      map['turf_lng'] = Variable<double>(turfLng.value);
    }
    if (turfName.present) {
      map['turf_name'] = Variable<String>(turfName.value);
    }
    if (isStation.present) {
      map['is_station'] = Variable<bool>(isStation.value);
    }
    if (hubLevel.present) {
      map['hub_level'] = Variable<int>(hubLevel.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HexNodesCompanion(')
          ..write('h3Index: $h3Index, ')
          ..write('districtRes6: $districtRes6, ')
          ..write('biomeType: $biomeType, ')
          ..write('anomalyTrait: $anomalyTrait, ')
          ..write('owner: $owner, ')
          ..write('garrisonLevel: $garrisonLevel, ')
          ..write('structuralIntegrity: $structuralIntegrity, ')
          ..write('isAnchorHub: $isAnchorHub, ')
          ..write('connectedRelayTarget: $connectedRelayTarget, ')
          ..write('lastTickTimestamp: $lastTickTimestamp, ')
          ..write('turfLat: $turfLat, ')
          ..write('turfLng: $turfLng, ')
          ..write('turfName: $turfName, ')
          ..write('isStation: $isStation, ')
          ..write('hubLevel: $hubLevel, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class InstalledModules extends Table
    with TableInfo<InstalledModules, InstalledModuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  InstalledModules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _hexH3IndexMeta = const VerificationMeta(
    'hexH3Index',
  );
  late final GeneratedColumn<String> hexH3Index = GeneratedColumn<String>(
    'hex_h3_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES hex_nodes(h3_index)ON DELETE CASCADE',
  );
  static const VerificationMeta _socketIndexMeta = const VerificationMeta(
    'socketIndex',
  );
  late final GeneratedColumn<int> socketIndex = GeneratedColumn<int>(
    'socket_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _moduleNameMeta = const VerificationMeta(
    'moduleName',
  );
  late final GeneratedColumn<String> moduleName = GeneratedColumn<String>(
    'module_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statCashMultMeta = const VerificationMeta(
    'statCashMult',
  );
  late final GeneratedColumn<double> statCashMult = GeneratedColumn<double>(
    'stat_cash_mult',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _statDefMultMeta = const VerificationMeta(
    'statDefMult',
  );
  late final GeneratedColumn<double> statDefMult = GeneratedColumn<double>(
    'stat_def_mult',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _specialPerkMeta = const VerificationMeta(
    'specialPerk',
  );
  late final GeneratedColumn<String> specialPerk = GeneratedColumn<String>(
    'special_perk',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _perkValueMeta = const VerificationMeta(
    'perkValue',
  );
  late final GeneratedColumn<double> perkValue = GeneratedColumn<double>(
    'perk_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _itemLevelMeta = const VerificationMeta(
    'itemLevel',
  );
  late final GeneratedColumn<int> itemLevel = GeneratedColumn<int>(
    'item_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hexH3Index,
    socketIndex,
    moduleName,
    rarity,
    statCashMult,
    statDefMult,
    specialPerk,
    perkValue,
    itemLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledModuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hex_h3_index')) {
      context.handle(
        _hexH3IndexMeta,
        hexH3Index.isAcceptableOrUnknown(
          data['hex_h3_index']!,
          _hexH3IndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hexH3IndexMeta);
    }
    if (data.containsKey('socket_index')) {
      context.handle(
        _socketIndexMeta,
        socketIndex.isAcceptableOrUnknown(
          data['socket_index']!,
          _socketIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_socketIndexMeta);
    }
    if (data.containsKey('module_name')) {
      context.handle(
        _moduleNameMeta,
        moduleName.isAcceptableOrUnknown(data['module_name']!, _moduleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleNameMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('stat_cash_mult')) {
      context.handle(
        _statCashMultMeta,
        statCashMult.isAcceptableOrUnknown(
          data['stat_cash_mult']!,
          _statCashMultMeta,
        ),
      );
    }
    if (data.containsKey('stat_def_mult')) {
      context.handle(
        _statDefMultMeta,
        statDefMult.isAcceptableOrUnknown(
          data['stat_def_mult']!,
          _statDefMultMeta,
        ),
      );
    }
    if (data.containsKey('special_perk')) {
      context.handle(
        _specialPerkMeta,
        specialPerk.isAcceptableOrUnknown(
          data['special_perk']!,
          _specialPerkMeta,
        ),
      );
    }
    if (data.containsKey('perk_value')) {
      context.handle(
        _perkValueMeta,
        perkValue.isAcceptableOrUnknown(data['perk_value']!, _perkValueMeta),
      );
    }
    if (data.containsKey('item_level')) {
      context.handle(
        _itemLevelMeta,
        itemLevel.isAcceptableOrUnknown(data['item_level']!, _itemLevelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstalledModuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledModuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hexH3Index: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_h3_index'],
      )!,
      socketIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socket_index'],
      )!,
      moduleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_name'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      statCashMult: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stat_cash_mult'],
      )!,
      statDefMult: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stat_def_mult'],
      )!,
      specialPerk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_perk'],
      ),
      perkValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perk_value'],
      )!,
      itemLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_level'],
      )!,
    );
  }

  @override
  InstalledModules createAlias(String alias) {
    return InstalledModules(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class InstalledModuleRow extends DataClass
    implements Insertable<InstalledModuleRow> {
  final String id;
  final String hexH3Index;
  final int socketIndex;
  final String moduleName;
  final String rarity;
  final double statCashMult;
  final double statDefMult;
  final String? specialPerk;
  final double perkValue;

  /// ext: magnitude of special_perk
  final int itemLevel;
  const InstalledModuleRow({
    required this.id,
    required this.hexH3Index,
    required this.socketIndex,
    required this.moduleName,
    required this.rarity,
    required this.statCashMult,
    required this.statDefMult,
    this.specialPerk,
    required this.perkValue,
    required this.itemLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hex_h3_index'] = Variable<String>(hexH3Index);
    map['socket_index'] = Variable<int>(socketIndex);
    map['module_name'] = Variable<String>(moduleName);
    map['rarity'] = Variable<String>(rarity);
    map['stat_cash_mult'] = Variable<double>(statCashMult);
    map['stat_def_mult'] = Variable<double>(statDefMult);
    if (!nullToAbsent || specialPerk != null) {
      map['special_perk'] = Variable<String>(specialPerk);
    }
    map['perk_value'] = Variable<double>(perkValue);
    map['item_level'] = Variable<int>(itemLevel);
    return map;
  }

  InstalledModulesCompanion toCompanion(bool nullToAbsent) {
    return InstalledModulesCompanion(
      id: Value(id),
      hexH3Index: Value(hexH3Index),
      socketIndex: Value(socketIndex),
      moduleName: Value(moduleName),
      rarity: Value(rarity),
      statCashMult: Value(statCashMult),
      statDefMult: Value(statDefMult),
      specialPerk: specialPerk == null && nullToAbsent
          ? const Value.absent()
          : Value(specialPerk),
      perkValue: Value(perkValue),
      itemLevel: Value(itemLevel),
    );
  }

  factory InstalledModuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledModuleRow(
      id: serializer.fromJson<String>(json['id']),
      hexH3Index: serializer.fromJson<String>(json['hex_h3_index']),
      socketIndex: serializer.fromJson<int>(json['socket_index']),
      moduleName: serializer.fromJson<String>(json['module_name']),
      rarity: serializer.fromJson<String>(json['rarity']),
      statCashMult: serializer.fromJson<double>(json['stat_cash_mult']),
      statDefMult: serializer.fromJson<double>(json['stat_def_mult']),
      specialPerk: serializer.fromJson<String?>(json['special_perk']),
      perkValue: serializer.fromJson<double>(json['perk_value']),
      itemLevel: serializer.fromJson<int>(json['item_level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hex_h3_index': serializer.toJson<String>(hexH3Index),
      'socket_index': serializer.toJson<int>(socketIndex),
      'module_name': serializer.toJson<String>(moduleName),
      'rarity': serializer.toJson<String>(rarity),
      'stat_cash_mult': serializer.toJson<double>(statCashMult),
      'stat_def_mult': serializer.toJson<double>(statDefMult),
      'special_perk': serializer.toJson<String?>(specialPerk),
      'perk_value': serializer.toJson<double>(perkValue),
      'item_level': serializer.toJson<int>(itemLevel),
    };
  }

  InstalledModuleRow copyWith({
    String? id,
    String? hexH3Index,
    int? socketIndex,
    String? moduleName,
    String? rarity,
    double? statCashMult,
    double? statDefMult,
    Value<String?> specialPerk = const Value.absent(),
    double? perkValue,
    int? itemLevel,
  }) => InstalledModuleRow(
    id: id ?? this.id,
    hexH3Index: hexH3Index ?? this.hexH3Index,
    socketIndex: socketIndex ?? this.socketIndex,
    moduleName: moduleName ?? this.moduleName,
    rarity: rarity ?? this.rarity,
    statCashMult: statCashMult ?? this.statCashMult,
    statDefMult: statDefMult ?? this.statDefMult,
    specialPerk: specialPerk.present ? specialPerk.value : this.specialPerk,
    perkValue: perkValue ?? this.perkValue,
    itemLevel: itemLevel ?? this.itemLevel,
  );
  InstalledModuleRow copyWithCompanion(InstalledModulesCompanion data) {
    return InstalledModuleRow(
      id: data.id.present ? data.id.value : this.id,
      hexH3Index: data.hexH3Index.present
          ? data.hexH3Index.value
          : this.hexH3Index,
      socketIndex: data.socketIndex.present
          ? data.socketIndex.value
          : this.socketIndex,
      moduleName: data.moduleName.present
          ? data.moduleName.value
          : this.moduleName,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      statCashMult: data.statCashMult.present
          ? data.statCashMult.value
          : this.statCashMult,
      statDefMult: data.statDefMult.present
          ? data.statDefMult.value
          : this.statDefMult,
      specialPerk: data.specialPerk.present
          ? data.specialPerk.value
          : this.specialPerk,
      perkValue: data.perkValue.present ? data.perkValue.value : this.perkValue,
      itemLevel: data.itemLevel.present ? data.itemLevel.value : this.itemLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModuleRow(')
          ..write('id: $id, ')
          ..write('hexH3Index: $hexH3Index, ')
          ..write('socketIndex: $socketIndex, ')
          ..write('moduleName: $moduleName, ')
          ..write('rarity: $rarity, ')
          ..write('statCashMult: $statCashMult, ')
          ..write('statDefMult: $statDefMult, ')
          ..write('specialPerk: $specialPerk, ')
          ..write('perkValue: $perkValue, ')
          ..write('itemLevel: $itemLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hexH3Index,
    socketIndex,
    moduleName,
    rarity,
    statCashMult,
    statDefMult,
    specialPerk,
    perkValue,
    itemLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledModuleRow &&
          other.id == this.id &&
          other.hexH3Index == this.hexH3Index &&
          other.socketIndex == this.socketIndex &&
          other.moduleName == this.moduleName &&
          other.rarity == this.rarity &&
          other.statCashMult == this.statCashMult &&
          other.statDefMult == this.statDefMult &&
          other.specialPerk == this.specialPerk &&
          other.perkValue == this.perkValue &&
          other.itemLevel == this.itemLevel);
}

class InstalledModulesCompanion extends UpdateCompanion<InstalledModuleRow> {
  final Value<String> id;
  final Value<String> hexH3Index;
  final Value<int> socketIndex;
  final Value<String> moduleName;
  final Value<String> rarity;
  final Value<double> statCashMult;
  final Value<double> statDefMult;
  final Value<String?> specialPerk;
  final Value<double> perkValue;
  final Value<int> itemLevel;
  final Value<int> rowid;
  const InstalledModulesCompanion({
    this.id = const Value.absent(),
    this.hexH3Index = const Value.absent(),
    this.socketIndex = const Value.absent(),
    this.moduleName = const Value.absent(),
    this.rarity = const Value.absent(),
    this.statCashMult = const Value.absent(),
    this.statDefMult = const Value.absent(),
    this.specialPerk = const Value.absent(),
    this.perkValue = const Value.absent(),
    this.itemLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledModulesCompanion.insert({
    required String id,
    required String hexH3Index,
    required int socketIndex,
    required String moduleName,
    required String rarity,
    this.statCashMult = const Value.absent(),
    this.statDefMult = const Value.absent(),
    this.specialPerk = const Value.absent(),
    this.perkValue = const Value.absent(),
    this.itemLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hexH3Index = Value(hexH3Index),
       socketIndex = Value(socketIndex),
       moduleName = Value(moduleName),
       rarity = Value(rarity);
  static Insertable<InstalledModuleRow> custom({
    Expression<String>? id,
    Expression<String>? hexH3Index,
    Expression<int>? socketIndex,
    Expression<String>? moduleName,
    Expression<String>? rarity,
    Expression<double>? statCashMult,
    Expression<double>? statDefMult,
    Expression<String>? specialPerk,
    Expression<double>? perkValue,
    Expression<int>? itemLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hexH3Index != null) 'hex_h3_index': hexH3Index,
      if (socketIndex != null) 'socket_index': socketIndex,
      if (moduleName != null) 'module_name': moduleName,
      if (rarity != null) 'rarity': rarity,
      if (statCashMult != null) 'stat_cash_mult': statCashMult,
      if (statDefMult != null) 'stat_def_mult': statDefMult,
      if (specialPerk != null) 'special_perk': specialPerk,
      if (perkValue != null) 'perk_value': perkValue,
      if (itemLevel != null) 'item_level': itemLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledModulesCompanion copyWith({
    Value<String>? id,
    Value<String>? hexH3Index,
    Value<int>? socketIndex,
    Value<String>? moduleName,
    Value<String>? rarity,
    Value<double>? statCashMult,
    Value<double>? statDefMult,
    Value<String?>? specialPerk,
    Value<double>? perkValue,
    Value<int>? itemLevel,
    Value<int>? rowid,
  }) {
    return InstalledModulesCompanion(
      id: id ?? this.id,
      hexH3Index: hexH3Index ?? this.hexH3Index,
      socketIndex: socketIndex ?? this.socketIndex,
      moduleName: moduleName ?? this.moduleName,
      rarity: rarity ?? this.rarity,
      statCashMult: statCashMult ?? this.statCashMult,
      statDefMult: statDefMult ?? this.statDefMult,
      specialPerk: specialPerk ?? this.specialPerk,
      perkValue: perkValue ?? this.perkValue,
      itemLevel: itemLevel ?? this.itemLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hexH3Index.present) {
      map['hex_h3_index'] = Variable<String>(hexH3Index.value);
    }
    if (socketIndex.present) {
      map['socket_index'] = Variable<int>(socketIndex.value);
    }
    if (moduleName.present) {
      map['module_name'] = Variable<String>(moduleName.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (statCashMult.present) {
      map['stat_cash_mult'] = Variable<double>(statCashMult.value);
    }
    if (statDefMult.present) {
      map['stat_def_mult'] = Variable<double>(statDefMult.value);
    }
    if (specialPerk.present) {
      map['special_perk'] = Variable<String>(specialPerk.value);
    }
    if (perkValue.present) {
      map['perk_value'] = Variable<double>(perkValue.value);
    }
    if (itemLevel.present) {
      map['item_level'] = Variable<int>(itemLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModulesCompanion(')
          ..write('id: $id, ')
          ..write('hexH3Index: $hexH3Index, ')
          ..write('socketIndex: $socketIndex, ')
          ..write('moduleName: $moduleName, ')
          ..write('rarity: $rarity, ')
          ..write('statCashMult: $statCashMult, ')
          ..write('statDefMult: $statDefMult, ')
          ..write('specialPerk: $specialPerk, ')
          ..write('perkValue: $perkValue, ')
          ..write('itemLevel: $itemLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ModuleStash extends Table with TableInfo<ModuleStash, StashRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ModuleStash(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _moduleNameMeta = const VerificationMeta(
    'moduleName',
  );
  late final GeneratedColumn<String> moduleName = GeneratedColumn<String>(
    'module_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statCashMultMeta = const VerificationMeta(
    'statCashMult',
  );
  late final GeneratedColumn<double> statCashMult = GeneratedColumn<double>(
    'stat_cash_mult',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _statDefMultMeta = const VerificationMeta(
    'statDefMult',
  );
  late final GeneratedColumn<double> statDefMult = GeneratedColumn<double>(
    'stat_def_mult',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _specialPerkMeta = const VerificationMeta(
    'specialPerk',
  );
  late final GeneratedColumn<String> specialPerk = GeneratedColumn<String>(
    'special_perk',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _perkValueMeta = const VerificationMeta(
    'perkValue',
  );
  late final GeneratedColumn<double> perkValue = GeneratedColumn<double>(
    'perk_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _itemLevelMeta = const VerificationMeta(
    'itemLevel',
  );
  late final GeneratedColumn<int> itemLevel = GeneratedColumn<int>(
    'item_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  late final GeneratedColumn<int> acquiredAt = GeneratedColumn<int>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    moduleName,
    rarity,
    statCashMult,
    statDefMult,
    specialPerk,
    perkValue,
    itemLevel,
    acquiredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_stash';
  @override
  VerificationContext validateIntegrity(
    Insertable<StashRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('module_name')) {
      context.handle(
        _moduleNameMeta,
        moduleName.isAcceptableOrUnknown(data['module_name']!, _moduleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleNameMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('stat_cash_mult')) {
      context.handle(
        _statCashMultMeta,
        statCashMult.isAcceptableOrUnknown(
          data['stat_cash_mult']!,
          _statCashMultMeta,
        ),
      );
    }
    if (data.containsKey('stat_def_mult')) {
      context.handle(
        _statDefMultMeta,
        statDefMult.isAcceptableOrUnknown(
          data['stat_def_mult']!,
          _statDefMultMeta,
        ),
      );
    }
    if (data.containsKey('special_perk')) {
      context.handle(
        _specialPerkMeta,
        specialPerk.isAcceptableOrUnknown(
          data['special_perk']!,
          _specialPerkMeta,
        ),
      );
    }
    if (data.containsKey('perk_value')) {
      context.handle(
        _perkValueMeta,
        perkValue.isAcceptableOrUnknown(data['perk_value']!, _perkValueMeta),
      );
    }
    if (data.containsKey('item_level')) {
      context.handle(
        _itemLevelMeta,
        itemLevel.isAcceptableOrUnknown(data['item_level']!, _itemLevelMeta),
      );
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StashRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StashRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      moduleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_name'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      statCashMult: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stat_cash_mult'],
      )!,
      statDefMult: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stat_def_mult'],
      )!,
      specialPerk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_perk'],
      ),
      perkValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perk_value'],
      )!,
      itemLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_level'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acquired_at'],
      )!,
    );
  }

  @override
  ModuleStash createAlias(String alias) {
    return ModuleStash(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class StashRow extends DataClass implements Insertable<StashRow> {
  final String id;
  final String moduleName;
  final String rarity;
  final double statCashMult;
  final double statDefMult;
  final String? specialPerk;
  final double perkValue;
  final int itemLevel;
  final int acquiredAt;
  const StashRow({
    required this.id,
    required this.moduleName,
    required this.rarity,
    required this.statCashMult,
    required this.statDefMult,
    this.specialPerk,
    required this.perkValue,
    required this.itemLevel,
    required this.acquiredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['module_name'] = Variable<String>(moduleName);
    map['rarity'] = Variable<String>(rarity);
    map['stat_cash_mult'] = Variable<double>(statCashMult);
    map['stat_def_mult'] = Variable<double>(statDefMult);
    if (!nullToAbsent || specialPerk != null) {
      map['special_perk'] = Variable<String>(specialPerk);
    }
    map['perk_value'] = Variable<double>(perkValue);
    map['item_level'] = Variable<int>(itemLevel);
    map['acquired_at'] = Variable<int>(acquiredAt);
    return map;
  }

  ModuleStashCompanion toCompanion(bool nullToAbsent) {
    return ModuleStashCompanion(
      id: Value(id),
      moduleName: Value(moduleName),
      rarity: Value(rarity),
      statCashMult: Value(statCashMult),
      statDefMult: Value(statDefMult),
      specialPerk: specialPerk == null && nullToAbsent
          ? const Value.absent()
          : Value(specialPerk),
      perkValue: Value(perkValue),
      itemLevel: Value(itemLevel),
      acquiredAt: Value(acquiredAt),
    );
  }

  factory StashRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StashRow(
      id: serializer.fromJson<String>(json['id']),
      moduleName: serializer.fromJson<String>(json['module_name']),
      rarity: serializer.fromJson<String>(json['rarity']),
      statCashMult: serializer.fromJson<double>(json['stat_cash_mult']),
      statDefMult: serializer.fromJson<double>(json['stat_def_mult']),
      specialPerk: serializer.fromJson<String?>(json['special_perk']),
      perkValue: serializer.fromJson<double>(json['perk_value']),
      itemLevel: serializer.fromJson<int>(json['item_level']),
      acquiredAt: serializer.fromJson<int>(json['acquired_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'module_name': serializer.toJson<String>(moduleName),
      'rarity': serializer.toJson<String>(rarity),
      'stat_cash_mult': serializer.toJson<double>(statCashMult),
      'stat_def_mult': serializer.toJson<double>(statDefMult),
      'special_perk': serializer.toJson<String?>(specialPerk),
      'perk_value': serializer.toJson<double>(perkValue),
      'item_level': serializer.toJson<int>(itemLevel),
      'acquired_at': serializer.toJson<int>(acquiredAt),
    };
  }

  StashRow copyWith({
    String? id,
    String? moduleName,
    String? rarity,
    double? statCashMult,
    double? statDefMult,
    Value<String?> specialPerk = const Value.absent(),
    double? perkValue,
    int? itemLevel,
    int? acquiredAt,
  }) => StashRow(
    id: id ?? this.id,
    moduleName: moduleName ?? this.moduleName,
    rarity: rarity ?? this.rarity,
    statCashMult: statCashMult ?? this.statCashMult,
    statDefMult: statDefMult ?? this.statDefMult,
    specialPerk: specialPerk.present ? specialPerk.value : this.specialPerk,
    perkValue: perkValue ?? this.perkValue,
    itemLevel: itemLevel ?? this.itemLevel,
    acquiredAt: acquiredAt ?? this.acquiredAt,
  );
  StashRow copyWithCompanion(ModuleStashCompanion data) {
    return StashRow(
      id: data.id.present ? data.id.value : this.id,
      moduleName: data.moduleName.present
          ? data.moduleName.value
          : this.moduleName,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      statCashMult: data.statCashMult.present
          ? data.statCashMult.value
          : this.statCashMult,
      statDefMult: data.statDefMult.present
          ? data.statDefMult.value
          : this.statDefMult,
      specialPerk: data.specialPerk.present
          ? data.specialPerk.value
          : this.specialPerk,
      perkValue: data.perkValue.present ? data.perkValue.value : this.perkValue,
      itemLevel: data.itemLevel.present ? data.itemLevel.value : this.itemLevel,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StashRow(')
          ..write('id: $id, ')
          ..write('moduleName: $moduleName, ')
          ..write('rarity: $rarity, ')
          ..write('statCashMult: $statCashMult, ')
          ..write('statDefMult: $statDefMult, ')
          ..write('specialPerk: $specialPerk, ')
          ..write('perkValue: $perkValue, ')
          ..write('itemLevel: $itemLevel, ')
          ..write('acquiredAt: $acquiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    moduleName,
    rarity,
    statCashMult,
    statDefMult,
    specialPerk,
    perkValue,
    itemLevel,
    acquiredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StashRow &&
          other.id == this.id &&
          other.moduleName == this.moduleName &&
          other.rarity == this.rarity &&
          other.statCashMult == this.statCashMult &&
          other.statDefMult == this.statDefMult &&
          other.specialPerk == this.specialPerk &&
          other.perkValue == this.perkValue &&
          other.itemLevel == this.itemLevel &&
          other.acquiredAt == this.acquiredAt);
}

class ModuleStashCompanion extends UpdateCompanion<StashRow> {
  final Value<String> id;
  final Value<String> moduleName;
  final Value<String> rarity;
  final Value<double> statCashMult;
  final Value<double> statDefMult;
  final Value<String?> specialPerk;
  final Value<double> perkValue;
  final Value<int> itemLevel;
  final Value<int> acquiredAt;
  final Value<int> rowid;
  const ModuleStashCompanion({
    this.id = const Value.absent(),
    this.moduleName = const Value.absent(),
    this.rarity = const Value.absent(),
    this.statCashMult = const Value.absent(),
    this.statDefMult = const Value.absent(),
    this.specialPerk = const Value.absent(),
    this.perkValue = const Value.absent(),
    this.itemLevel = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleStashCompanion.insert({
    required String id,
    required String moduleName,
    required String rarity,
    this.statCashMult = const Value.absent(),
    this.statDefMult = const Value.absent(),
    this.specialPerk = const Value.absent(),
    this.perkValue = const Value.absent(),
    this.itemLevel = const Value.absent(),
    required int acquiredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       moduleName = Value(moduleName),
       rarity = Value(rarity),
       acquiredAt = Value(acquiredAt);
  static Insertable<StashRow> custom({
    Expression<String>? id,
    Expression<String>? moduleName,
    Expression<String>? rarity,
    Expression<double>? statCashMult,
    Expression<double>? statDefMult,
    Expression<String>? specialPerk,
    Expression<double>? perkValue,
    Expression<int>? itemLevel,
    Expression<int>? acquiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleName != null) 'module_name': moduleName,
      if (rarity != null) 'rarity': rarity,
      if (statCashMult != null) 'stat_cash_mult': statCashMult,
      if (statDefMult != null) 'stat_def_mult': statDefMult,
      if (specialPerk != null) 'special_perk': specialPerk,
      if (perkValue != null) 'perk_value': perkValue,
      if (itemLevel != null) 'item_level': itemLevel,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleStashCompanion copyWith({
    Value<String>? id,
    Value<String>? moduleName,
    Value<String>? rarity,
    Value<double>? statCashMult,
    Value<double>? statDefMult,
    Value<String?>? specialPerk,
    Value<double>? perkValue,
    Value<int>? itemLevel,
    Value<int>? acquiredAt,
    Value<int>? rowid,
  }) {
    return ModuleStashCompanion(
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      rarity: rarity ?? this.rarity,
      statCashMult: statCashMult ?? this.statCashMult,
      statDefMult: statDefMult ?? this.statDefMult,
      specialPerk: specialPerk ?? this.specialPerk,
      perkValue: perkValue ?? this.perkValue,
      itemLevel: itemLevel ?? this.itemLevel,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (moduleName.present) {
      map['module_name'] = Variable<String>(moduleName.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (statCashMult.present) {
      map['stat_cash_mult'] = Variable<double>(statCashMult.value);
    }
    if (statDefMult.present) {
      map['stat_def_mult'] = Variable<double>(statDefMult.value);
    }
    if (specialPerk.present) {
      map['special_perk'] = Variable<String>(specialPerk.value);
    }
    if (perkValue.present) {
      map['perk_value'] = Variable<double>(perkValue.value);
    }
    if (itemLevel.present) {
      map['item_level'] = Variable<int>(itemLevel.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<int>(acquiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleStashCompanion(')
          ..write('id: $id, ')
          ..write('moduleName: $moduleName, ')
          ..write('rarity: $rarity, ')
          ..write('statCashMult: $statCashMult, ')
          ..write('statDefMult: $statDefMult, ')
          ..write('specialPerk: $specialPerk, ')
          ..write('perkValue: $perkValue, ')
          ..write('itemLevel: $itemLevel, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ActiveWorldEvents extends Table
    with TableInfo<ActiveWorldEvents, WorldEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActiveWorldEvents(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetH3IndexMeta = const VerificationMeta(
    'targetH3Index',
  );
  late final GeneratedColumn<String> targetH3Index = GeneratedColumn<String>(
    'target_h3_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    eventType,
    targetH3Index,
    expiresAt,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_world_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorldEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('target_h3_index')) {
      context.handle(
        _targetH3IndexMeta,
        targetH3Index.isAcceptableOrUnknown(
          data['target_h3_index']!,
          _targetH3IndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetH3IndexMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  WorldEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorldEventRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      targetH3Index: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_h3_index'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  ActiveWorldEvents createAlias(String alias) {
    return ActiveWorldEvents(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class WorldEventRow extends DataClass implements Insertable<WorldEventRow> {
  final String eventId;
  final String eventType;
  final String targetH3Index;
  final int expiresAt;
  final String payloadJson;
  const WorldEventRow({
    required this.eventId,
    required this.eventType,
    required this.targetH3Index,
    required this.expiresAt,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['event_type'] = Variable<String>(eventType);
    map['target_h3_index'] = Variable<String>(targetH3Index);
    map['expires_at'] = Variable<int>(expiresAt);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  ActiveWorldEventsCompanion toCompanion(bool nullToAbsent) {
    return ActiveWorldEventsCompanion(
      eventId: Value(eventId),
      eventType: Value(eventType),
      targetH3Index: Value(targetH3Index),
      expiresAt: Value(expiresAt),
      payloadJson: Value(payloadJson),
    );
  }

  factory WorldEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorldEventRow(
      eventId: serializer.fromJson<String>(json['event_id']),
      eventType: serializer.fromJson<String>(json['event_type']),
      targetH3Index: serializer.fromJson<String>(json['target_h3_index']),
      expiresAt: serializer.fromJson<int>(json['expires_at']),
      payloadJson: serializer.fromJson<String>(json['payload_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'event_id': serializer.toJson<String>(eventId),
      'event_type': serializer.toJson<String>(eventType),
      'target_h3_index': serializer.toJson<String>(targetH3Index),
      'expires_at': serializer.toJson<int>(expiresAt),
      'payload_json': serializer.toJson<String>(payloadJson),
    };
  }

  WorldEventRow copyWith({
    String? eventId,
    String? eventType,
    String? targetH3Index,
    int? expiresAt,
    String? payloadJson,
  }) => WorldEventRow(
    eventId: eventId ?? this.eventId,
    eventType: eventType ?? this.eventType,
    targetH3Index: targetH3Index ?? this.targetH3Index,
    expiresAt: expiresAt ?? this.expiresAt,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  WorldEventRow copyWithCompanion(ActiveWorldEventsCompanion data) {
    return WorldEventRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      targetH3Index: data.targetH3Index.present
          ? data.targetH3Index.value
          : this.targetH3Index,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorldEventRow(')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('targetH3Index: $targetH3Index, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(eventId, eventType, targetH3Index, expiresAt, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorldEventRow &&
          other.eventId == this.eventId &&
          other.eventType == this.eventType &&
          other.targetH3Index == this.targetH3Index &&
          other.expiresAt == this.expiresAt &&
          other.payloadJson == this.payloadJson);
}

class ActiveWorldEventsCompanion extends UpdateCompanion<WorldEventRow> {
  final Value<String> eventId;
  final Value<String> eventType;
  final Value<String> targetH3Index;
  final Value<int> expiresAt;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ActiveWorldEventsCompanion({
    this.eventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.targetH3Index = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveWorldEventsCompanion.insert({
    required String eventId,
    required String eventType,
    required String targetH3Index,
    required int expiresAt,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       eventType = Value(eventType),
       targetH3Index = Value(targetH3Index),
       expiresAt = Value(expiresAt),
       payloadJson = Value(payloadJson);
  static Insertable<WorldEventRow> custom({
    Expression<String>? eventId,
    Expression<String>? eventType,
    Expression<String>? targetH3Index,
    Expression<int>? expiresAt,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (eventType != null) 'event_type': eventType,
      if (targetH3Index != null) 'target_h3_index': targetH3Index,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveWorldEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? eventType,
    Value<String>? targetH3Index,
    Value<int>? expiresAt,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ActiveWorldEventsCompanion(
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      targetH3Index: targetH3Index ?? this.targetH3Index,
      expiresAt: expiresAt ?? this.expiresAt,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (targetH3Index.present) {
      map['target_h3_index'] = Variable<String>(targetH3Index.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveWorldEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('targetH3Index: $targetH3Index, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlayerState extends Table with TableInfo<PlayerState, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlayerState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (id = 1)',
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1000.0',
    defaultValue: const CustomExpression('1000.0'),
  );
  static const VerificationMeta _materialsMeta = const VerificationMeta(
    'materials',
  );
  late final GeneratedColumn<double> materials = GeneratedColumn<double>(
    'materials',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 250.0',
    defaultValue: const CustomExpression('250.0'),
  );
  static const VerificationMeta _intelMeta = const VerificationMeta('intel');
  late final GeneratedColumn<double> intel = GeneratedColumn<double>(
    'intel',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 50.0',
    defaultValue: const CustomExpression('50.0'),
  );
  static const VerificationMeta _prestigeKeysMeta = const VerificationMeta(
    'prestigeKeys',
  );
  late final GeneratedColumn<int> prestigeKeys = GeneratedColumn<int>(
    'prestige_keys',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastKnownLatMeta = const VerificationMeta(
    'lastKnownLat',
  );
  late final GeneratedColumn<double> lastKnownLat = GeneratedColumn<double>(
    'last_known_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastKnownLngMeta = const VerificationMeta(
    'lastKnownLng',
  );
  late final GeneratedColumn<double> lastKnownLng = GeneratedColumn<double>(
    'last_known_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastSyncTimestampMeta = const VerificationMeta(
    'lastSyncTimestamp',
  );
  late final GeneratedColumn<int> lastSyncTimestamp = GeneratedColumn<int>(
    'last_sync_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monotonicUptimeMeta = const VerificationMeta(
    'monotonicUptime',
  );
  late final GeneratedColumn<int> monotonicUptime = GeneratedColumn<int>(
    'monotonic_uptime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _worldSeedMeta = const VerificationMeta(
    'worldSeed',
  );
  late final GeneratedColumn<int> worldSeed = GeneratedColumn<int>(
    'world_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bootCountMeta = const VerificationMeta(
    'bootCount',
  );
  late final GeneratedColumn<int> bootCount = GeneratedColumn<int>(
    'boot_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT (-1)',
    defaultValue: const CustomExpression('-1'),
  );
  static const VerificationMeta _wallAtSyncMeta = const VerificationMeta(
    'wallAtSync',
  );
  late final GeneratedColumn<int> wallAtSync = GeneratedColumn<int>(
    'wall_at_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _tamperStrikesMeta = const VerificationMeta(
    'tamperStrikes',
  );
  late final GeneratedColumn<int> tamperStrikes = GeneratedColumn<int>(
    'tamper_strikes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _blueprintsMeta = const VerificationMeta(
    'blueprints',
  );
  late final GeneratedColumn<int> blueprints = GeneratedColumn<int>(
    'blueprints',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _liquidationsMeta = const VerificationMeta(
    'liquidations',
  );
  late final GeneratedColumn<int> liquidations = GeneratedColumn<int>(
    'liquidations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lifetimeCreditsMeta = const VerificationMeta(
    'lifetimeCredits',
  );
  late final GeneratedColumn<double> lifetimeCredits = GeneratedColumn<double>(
    'lifetime_credits',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _lastEventDayMeta = const VerificationMeta(
    'lastEventDay',
  );
  late final GeneratedColumn<int> lastEventDay = GeneratedColumn<int>(
    'last_event_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT (-1)',
    defaultValue: const CustomExpression('-1'),
  );
  static const VerificationMeta _threatHeatMeta = const VerificationMeta(
    'threatHeat',
  );
  late final GeneratedColumn<double> threatHeat = GeneratedColumn<double>(
    'threat_heat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  late final GeneratedColumn<double> energy = GeneratedColumn<double>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 30.0',
    defaultValue: const CustomExpression('30.0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    credits,
    materials,
    intel,
    prestigeKeys,
    level,
    xp,
    lastKnownLat,
    lastKnownLng,
    lastSyncTimestamp,
    monotonicUptime,
    worldSeed,
    bootCount,
    wallAtSync,
    tamperStrikes,
    blueprints,
    liquidations,
    lifetimeCredits,
    lastEventDay,
    threatHeat,
    createdAt,
    settingsJson,
    energy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('materials')) {
      context.handle(
        _materialsMeta,
        materials.isAcceptableOrUnknown(data['materials']!, _materialsMeta),
      );
    }
    if (data.containsKey('intel')) {
      context.handle(
        _intelMeta,
        intel.isAcceptableOrUnknown(data['intel']!, _intelMeta),
      );
    }
    if (data.containsKey('prestige_keys')) {
      context.handle(
        _prestigeKeysMeta,
        prestigeKeys.isAcceptableOrUnknown(
          data['prestige_keys']!,
          _prestigeKeysMeta,
        ),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('last_known_lat')) {
      context.handle(
        _lastKnownLatMeta,
        lastKnownLat.isAcceptableOrUnknown(
          data['last_known_lat']!,
          _lastKnownLatMeta,
        ),
      );
    }
    if (data.containsKey('last_known_lng')) {
      context.handle(
        _lastKnownLngMeta,
        lastKnownLng.isAcceptableOrUnknown(
          data['last_known_lng']!,
          _lastKnownLngMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_timestamp')) {
      context.handle(
        _lastSyncTimestampMeta,
        lastSyncTimestamp.isAcceptableOrUnknown(
          data['last_sync_timestamp']!,
          _lastSyncTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncTimestampMeta);
    }
    if (data.containsKey('monotonic_uptime')) {
      context.handle(
        _monotonicUptimeMeta,
        monotonicUptime.isAcceptableOrUnknown(
          data['monotonic_uptime']!,
          _monotonicUptimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monotonicUptimeMeta);
    }
    if (data.containsKey('world_seed')) {
      context.handle(
        _worldSeedMeta,
        worldSeed.isAcceptableOrUnknown(data['world_seed']!, _worldSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_worldSeedMeta);
    }
    if (data.containsKey('boot_count')) {
      context.handle(
        _bootCountMeta,
        bootCount.isAcceptableOrUnknown(data['boot_count']!, _bootCountMeta),
      );
    }
    if (data.containsKey('wall_at_sync')) {
      context.handle(
        _wallAtSyncMeta,
        wallAtSync.isAcceptableOrUnknown(
          data['wall_at_sync']!,
          _wallAtSyncMeta,
        ),
      );
    }
    if (data.containsKey('tamper_strikes')) {
      context.handle(
        _tamperStrikesMeta,
        tamperStrikes.isAcceptableOrUnknown(
          data['tamper_strikes']!,
          _tamperStrikesMeta,
        ),
      );
    }
    if (data.containsKey('blueprints')) {
      context.handle(
        _blueprintsMeta,
        blueprints.isAcceptableOrUnknown(data['blueprints']!, _blueprintsMeta),
      );
    }
    if (data.containsKey('liquidations')) {
      context.handle(
        _liquidationsMeta,
        liquidations.isAcceptableOrUnknown(
          data['liquidations']!,
          _liquidationsMeta,
        ),
      );
    }
    if (data.containsKey('lifetime_credits')) {
      context.handle(
        _lifetimeCreditsMeta,
        lifetimeCredits.isAcceptableOrUnknown(
          data['lifetime_credits']!,
          _lifetimeCreditsMeta,
        ),
      );
    }
    if (data.containsKey('last_event_day')) {
      context.handle(
        _lastEventDayMeta,
        lastEventDay.isAcceptableOrUnknown(
          data['last_event_day']!,
          _lastEventDayMeta,
        ),
      );
    }
    if (data.containsKey('threat_heat')) {
      context.handle(
        _threatHeatMeta,
        threatHeat.isAcceptableOrUnknown(data['threat_heat']!, _threatHeatMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      )!,
      materials: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}materials'],
      )!,
      intel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}intel'],
      )!,
      prestigeKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prestige_keys'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      lastKnownLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_known_lat'],
      ),
      lastKnownLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_known_lng'],
      ),
      lastSyncTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_timestamp'],
      )!,
      monotonicUptime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monotonic_uptime'],
      )!,
      worldSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}world_seed'],
      )!,
      bootCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boot_count'],
      )!,
      wallAtSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wall_at_sync'],
      )!,
      tamperStrikes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tamper_strikes'],
      )!,
      blueprints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}blueprints'],
      )!,
      liquidations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}liquidations'],
      )!,
      lifetimeCredits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lifetime_credits'],
      )!,
      lastEventDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_event_day'],
      )!,
      threatHeat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}threat_heat'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy'],
      )!,
    );
  }

  @override
  PlayerState createAlias(String alias) {
    return PlayerState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final int id;
  final double credits;
  final double materials;
  final double intel;
  final int prestigeKeys;
  final int level;
  final int xp;
  final double? lastKnownLat;
  final double? lastKnownLng;
  final int lastSyncTimestamp;
  final int monotonicUptime;
  final int worldSeed;

  /// ext: hidden WorldSeed for hex genetics
  final int bootCount;

  /// ext: Settings.Global.BOOT_COUNT at last sync
  final int wallAtSync;

  /// ext: raw device wall clock at last sync
  final int tamperStrikes;

  /// ext
  final int blueprints;

  /// ext: convoy loot, crafts guaranteed Rare+ modules
  final int liquidations;

  /// ext: completed prestige cycles
  final double lifetimeCredits;

  /// ext
  final int lastEventDay;

  /// ext: day index of last Event Deck roll
  final double threatHeat;

  /// ext: AI pressure; spikes when the map is quiet
  final int createdAt;

  /// ext
  final String settingsJson;

  /// ext: patrol mode, haptics, auto-claim
  final double energy;
  const PlayerRow({
    required this.id,
    required this.credits,
    required this.materials,
    required this.intel,
    required this.prestigeKeys,
    required this.level,
    required this.xp,
    this.lastKnownLat,
    this.lastKnownLng,
    required this.lastSyncTimestamp,
    required this.monotonicUptime,
    required this.worldSeed,
    required this.bootCount,
    required this.wallAtSync,
    required this.tamperStrikes,
    required this.blueprints,
    required this.liquidations,
    required this.lifetimeCredits,
    required this.lastEventDay,
    required this.threatHeat,
    required this.createdAt,
    required this.settingsJson,
    required this.energy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credits'] = Variable<double>(credits);
    map['materials'] = Variable<double>(materials);
    map['intel'] = Variable<double>(intel);
    map['prestige_keys'] = Variable<int>(prestigeKeys);
    map['level'] = Variable<int>(level);
    map['xp'] = Variable<int>(xp);
    if (!nullToAbsent || lastKnownLat != null) {
      map['last_known_lat'] = Variable<double>(lastKnownLat);
    }
    if (!nullToAbsent || lastKnownLng != null) {
      map['last_known_lng'] = Variable<double>(lastKnownLng);
    }
    map['last_sync_timestamp'] = Variable<int>(lastSyncTimestamp);
    map['monotonic_uptime'] = Variable<int>(monotonicUptime);
    map['world_seed'] = Variable<int>(worldSeed);
    map['boot_count'] = Variable<int>(bootCount);
    map['wall_at_sync'] = Variable<int>(wallAtSync);
    map['tamper_strikes'] = Variable<int>(tamperStrikes);
    map['blueprints'] = Variable<int>(blueprints);
    map['liquidations'] = Variable<int>(liquidations);
    map['lifetime_credits'] = Variable<double>(lifetimeCredits);
    map['last_event_day'] = Variable<int>(lastEventDay);
    map['threat_heat'] = Variable<double>(threatHeat);
    map['created_at'] = Variable<int>(createdAt);
    map['settings_json'] = Variable<String>(settingsJson);
    map['energy'] = Variable<double>(energy);
    return map;
  }

  PlayerStateCompanion toCompanion(bool nullToAbsent) {
    return PlayerStateCompanion(
      id: Value(id),
      credits: Value(credits),
      materials: Value(materials),
      intel: Value(intel),
      prestigeKeys: Value(prestigeKeys),
      level: Value(level),
      xp: Value(xp),
      lastKnownLat: lastKnownLat == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownLat),
      lastKnownLng: lastKnownLng == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownLng),
      lastSyncTimestamp: Value(lastSyncTimestamp),
      monotonicUptime: Value(monotonicUptime),
      worldSeed: Value(worldSeed),
      bootCount: Value(bootCount),
      wallAtSync: Value(wallAtSync),
      tamperStrikes: Value(tamperStrikes),
      blueprints: Value(blueprints),
      liquidations: Value(liquidations),
      lifetimeCredits: Value(lifetimeCredits),
      lastEventDay: Value(lastEventDay),
      threatHeat: Value(threatHeat),
      createdAt: Value(createdAt),
      settingsJson: Value(settingsJson),
      energy: Value(energy),
    );
  }

  factory PlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      id: serializer.fromJson<int>(json['id']),
      credits: serializer.fromJson<double>(json['credits']),
      materials: serializer.fromJson<double>(json['materials']),
      intel: serializer.fromJson<double>(json['intel']),
      prestigeKeys: serializer.fromJson<int>(json['prestige_keys']),
      level: serializer.fromJson<int>(json['level']),
      xp: serializer.fromJson<int>(json['xp']),
      lastKnownLat: serializer.fromJson<double?>(json['last_known_lat']),
      lastKnownLng: serializer.fromJson<double?>(json['last_known_lng']),
      lastSyncTimestamp: serializer.fromJson<int>(json['last_sync_timestamp']),
      monotonicUptime: serializer.fromJson<int>(json['monotonic_uptime']),
      worldSeed: serializer.fromJson<int>(json['world_seed']),
      bootCount: serializer.fromJson<int>(json['boot_count']),
      wallAtSync: serializer.fromJson<int>(json['wall_at_sync']),
      tamperStrikes: serializer.fromJson<int>(json['tamper_strikes']),
      blueprints: serializer.fromJson<int>(json['blueprints']),
      liquidations: serializer.fromJson<int>(json['liquidations']),
      lifetimeCredits: serializer.fromJson<double>(json['lifetime_credits']),
      lastEventDay: serializer.fromJson<int>(json['last_event_day']),
      threatHeat: serializer.fromJson<double>(json['threat_heat']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      settingsJson: serializer.fromJson<String>(json['settings_json']),
      energy: serializer.fromJson<double>(json['energy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'credits': serializer.toJson<double>(credits),
      'materials': serializer.toJson<double>(materials),
      'intel': serializer.toJson<double>(intel),
      'prestige_keys': serializer.toJson<int>(prestigeKeys),
      'level': serializer.toJson<int>(level),
      'xp': serializer.toJson<int>(xp),
      'last_known_lat': serializer.toJson<double?>(lastKnownLat),
      'last_known_lng': serializer.toJson<double?>(lastKnownLng),
      'last_sync_timestamp': serializer.toJson<int>(lastSyncTimestamp),
      'monotonic_uptime': serializer.toJson<int>(monotonicUptime),
      'world_seed': serializer.toJson<int>(worldSeed),
      'boot_count': serializer.toJson<int>(bootCount),
      'wall_at_sync': serializer.toJson<int>(wallAtSync),
      'tamper_strikes': serializer.toJson<int>(tamperStrikes),
      'blueprints': serializer.toJson<int>(blueprints),
      'liquidations': serializer.toJson<int>(liquidations),
      'lifetime_credits': serializer.toJson<double>(lifetimeCredits),
      'last_event_day': serializer.toJson<int>(lastEventDay),
      'threat_heat': serializer.toJson<double>(threatHeat),
      'created_at': serializer.toJson<int>(createdAt),
      'settings_json': serializer.toJson<String>(settingsJson),
      'energy': serializer.toJson<double>(energy),
    };
  }

  PlayerRow copyWith({
    int? id,
    double? credits,
    double? materials,
    double? intel,
    int? prestigeKeys,
    int? level,
    int? xp,
    Value<double?> lastKnownLat = const Value.absent(),
    Value<double?> lastKnownLng = const Value.absent(),
    int? lastSyncTimestamp,
    int? monotonicUptime,
    int? worldSeed,
    int? bootCount,
    int? wallAtSync,
    int? tamperStrikes,
    int? blueprints,
    int? liquidations,
    double? lifetimeCredits,
    int? lastEventDay,
    double? threatHeat,
    int? createdAt,
    String? settingsJson,
    double? energy,
  }) => PlayerRow(
    id: id ?? this.id,
    credits: credits ?? this.credits,
    materials: materials ?? this.materials,
    intel: intel ?? this.intel,
    prestigeKeys: prestigeKeys ?? this.prestigeKeys,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    lastKnownLat: lastKnownLat.present ? lastKnownLat.value : this.lastKnownLat,
    lastKnownLng: lastKnownLng.present ? lastKnownLng.value : this.lastKnownLng,
    lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    monotonicUptime: monotonicUptime ?? this.monotonicUptime,
    worldSeed: worldSeed ?? this.worldSeed,
    bootCount: bootCount ?? this.bootCount,
    wallAtSync: wallAtSync ?? this.wallAtSync,
    tamperStrikes: tamperStrikes ?? this.tamperStrikes,
    blueprints: blueprints ?? this.blueprints,
    liquidations: liquidations ?? this.liquidations,
    lifetimeCredits: lifetimeCredits ?? this.lifetimeCredits,
    lastEventDay: lastEventDay ?? this.lastEventDay,
    threatHeat: threatHeat ?? this.threatHeat,
    createdAt: createdAt ?? this.createdAt,
    settingsJson: settingsJson ?? this.settingsJson,
    energy: energy ?? this.energy,
  );
  PlayerRow copyWithCompanion(PlayerStateCompanion data) {
    return PlayerRow(
      id: data.id.present ? data.id.value : this.id,
      credits: data.credits.present ? data.credits.value : this.credits,
      materials: data.materials.present ? data.materials.value : this.materials,
      intel: data.intel.present ? data.intel.value : this.intel,
      prestigeKeys: data.prestigeKeys.present
          ? data.prestigeKeys.value
          : this.prestigeKeys,
      level: data.level.present ? data.level.value : this.level,
      xp: data.xp.present ? data.xp.value : this.xp,
      lastKnownLat: data.lastKnownLat.present
          ? data.lastKnownLat.value
          : this.lastKnownLat,
      lastKnownLng: data.lastKnownLng.present
          ? data.lastKnownLng.value
          : this.lastKnownLng,
      lastSyncTimestamp: data.lastSyncTimestamp.present
          ? data.lastSyncTimestamp.value
          : this.lastSyncTimestamp,
      monotonicUptime: data.monotonicUptime.present
          ? data.monotonicUptime.value
          : this.monotonicUptime,
      worldSeed: data.worldSeed.present ? data.worldSeed.value : this.worldSeed,
      bootCount: data.bootCount.present ? data.bootCount.value : this.bootCount,
      wallAtSync: data.wallAtSync.present
          ? data.wallAtSync.value
          : this.wallAtSync,
      tamperStrikes: data.tamperStrikes.present
          ? data.tamperStrikes.value
          : this.tamperStrikes,
      blueprints: data.blueprints.present
          ? data.blueprints.value
          : this.blueprints,
      liquidations: data.liquidations.present
          ? data.liquidations.value
          : this.liquidations,
      lifetimeCredits: data.lifetimeCredits.present
          ? data.lifetimeCredits.value
          : this.lifetimeCredits,
      lastEventDay: data.lastEventDay.present
          ? data.lastEventDay.value
          : this.lastEventDay,
      threatHeat: data.threatHeat.present
          ? data.threatHeat.value
          : this.threatHeat,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      energy: data.energy.present ? data.energy.value : this.energy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('id: $id, ')
          ..write('credits: $credits, ')
          ..write('materials: $materials, ')
          ..write('intel: $intel, ')
          ..write('prestigeKeys: $prestigeKeys, ')
          ..write('level: $level, ')
          ..write('xp: $xp, ')
          ..write('lastKnownLat: $lastKnownLat, ')
          ..write('lastKnownLng: $lastKnownLng, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp, ')
          ..write('monotonicUptime: $monotonicUptime, ')
          ..write('worldSeed: $worldSeed, ')
          ..write('bootCount: $bootCount, ')
          ..write('wallAtSync: $wallAtSync, ')
          ..write('tamperStrikes: $tamperStrikes, ')
          ..write('blueprints: $blueprints, ')
          ..write('liquidations: $liquidations, ')
          ..write('lifetimeCredits: $lifetimeCredits, ')
          ..write('lastEventDay: $lastEventDay, ')
          ..write('threatHeat: $threatHeat, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('energy: $energy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    credits,
    materials,
    intel,
    prestigeKeys,
    level,
    xp,
    lastKnownLat,
    lastKnownLng,
    lastSyncTimestamp,
    monotonicUptime,
    worldSeed,
    bootCount,
    wallAtSync,
    tamperStrikes,
    blueprints,
    liquidations,
    lifetimeCredits,
    lastEventDay,
    threatHeat,
    createdAt,
    settingsJson,
    energy,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.id == this.id &&
          other.credits == this.credits &&
          other.materials == this.materials &&
          other.intel == this.intel &&
          other.prestigeKeys == this.prestigeKeys &&
          other.level == this.level &&
          other.xp == this.xp &&
          other.lastKnownLat == this.lastKnownLat &&
          other.lastKnownLng == this.lastKnownLng &&
          other.lastSyncTimestamp == this.lastSyncTimestamp &&
          other.monotonicUptime == this.monotonicUptime &&
          other.worldSeed == this.worldSeed &&
          other.bootCount == this.bootCount &&
          other.wallAtSync == this.wallAtSync &&
          other.tamperStrikes == this.tamperStrikes &&
          other.blueprints == this.blueprints &&
          other.liquidations == this.liquidations &&
          other.lifetimeCredits == this.lifetimeCredits &&
          other.lastEventDay == this.lastEventDay &&
          other.threatHeat == this.threatHeat &&
          other.createdAt == this.createdAt &&
          other.settingsJson == this.settingsJson &&
          other.energy == this.energy);
}

class PlayerStateCompanion extends UpdateCompanion<PlayerRow> {
  final Value<int> id;
  final Value<double> credits;
  final Value<double> materials;
  final Value<double> intel;
  final Value<int> prestigeKeys;
  final Value<int> level;
  final Value<int> xp;
  final Value<double?> lastKnownLat;
  final Value<double?> lastKnownLng;
  final Value<int> lastSyncTimestamp;
  final Value<int> monotonicUptime;
  final Value<int> worldSeed;
  final Value<int> bootCount;
  final Value<int> wallAtSync;
  final Value<int> tamperStrikes;
  final Value<int> blueprints;
  final Value<int> liquidations;
  final Value<double> lifetimeCredits;
  final Value<int> lastEventDay;
  final Value<double> threatHeat;
  final Value<int> createdAt;
  final Value<String> settingsJson;
  final Value<double> energy;
  const PlayerStateCompanion({
    this.id = const Value.absent(),
    this.credits = const Value.absent(),
    this.materials = const Value.absent(),
    this.intel = const Value.absent(),
    this.prestigeKeys = const Value.absent(),
    this.level = const Value.absent(),
    this.xp = const Value.absent(),
    this.lastKnownLat = const Value.absent(),
    this.lastKnownLng = const Value.absent(),
    this.lastSyncTimestamp = const Value.absent(),
    this.monotonicUptime = const Value.absent(),
    this.worldSeed = const Value.absent(),
    this.bootCount = const Value.absent(),
    this.wallAtSync = const Value.absent(),
    this.tamperStrikes = const Value.absent(),
    this.blueprints = const Value.absent(),
    this.liquidations = const Value.absent(),
    this.lifetimeCredits = const Value.absent(),
    this.lastEventDay = const Value.absent(),
    this.threatHeat = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.energy = const Value.absent(),
  });
  PlayerStateCompanion.insert({
    this.id = const Value.absent(),
    this.credits = const Value.absent(),
    this.materials = const Value.absent(),
    this.intel = const Value.absent(),
    this.prestigeKeys = const Value.absent(),
    this.level = const Value.absent(),
    this.xp = const Value.absent(),
    this.lastKnownLat = const Value.absent(),
    this.lastKnownLng = const Value.absent(),
    required int lastSyncTimestamp,
    required int monotonicUptime,
    required int worldSeed,
    this.bootCount = const Value.absent(),
    this.wallAtSync = const Value.absent(),
    this.tamperStrikes = const Value.absent(),
    this.blueprints = const Value.absent(),
    this.liquidations = const Value.absent(),
    this.lifetimeCredits = const Value.absent(),
    this.lastEventDay = const Value.absent(),
    this.threatHeat = const Value.absent(),
    required int createdAt,
    this.settingsJson = const Value.absent(),
    this.energy = const Value.absent(),
  }) : lastSyncTimestamp = Value(lastSyncTimestamp),
       monotonicUptime = Value(monotonicUptime),
       worldSeed = Value(worldSeed),
       createdAt = Value(createdAt);
  static Insertable<PlayerRow> custom({
    Expression<int>? id,
    Expression<double>? credits,
    Expression<double>? materials,
    Expression<double>? intel,
    Expression<int>? prestigeKeys,
    Expression<int>? level,
    Expression<int>? xp,
    Expression<double>? lastKnownLat,
    Expression<double>? lastKnownLng,
    Expression<int>? lastSyncTimestamp,
    Expression<int>? monotonicUptime,
    Expression<int>? worldSeed,
    Expression<int>? bootCount,
    Expression<int>? wallAtSync,
    Expression<int>? tamperStrikes,
    Expression<int>? blueprints,
    Expression<int>? liquidations,
    Expression<double>? lifetimeCredits,
    Expression<int>? lastEventDay,
    Expression<double>? threatHeat,
    Expression<int>? createdAt,
    Expression<String>? settingsJson,
    Expression<double>? energy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (credits != null) 'credits': credits,
      if (materials != null) 'materials': materials,
      if (intel != null) 'intel': intel,
      if (prestigeKeys != null) 'prestige_keys': prestigeKeys,
      if (level != null) 'level': level,
      if (xp != null) 'xp': xp,
      if (lastKnownLat != null) 'last_known_lat': lastKnownLat,
      if (lastKnownLng != null) 'last_known_lng': lastKnownLng,
      if (lastSyncTimestamp != null) 'last_sync_timestamp': lastSyncTimestamp,
      if (monotonicUptime != null) 'monotonic_uptime': monotonicUptime,
      if (worldSeed != null) 'world_seed': worldSeed,
      if (bootCount != null) 'boot_count': bootCount,
      if (wallAtSync != null) 'wall_at_sync': wallAtSync,
      if (tamperStrikes != null) 'tamper_strikes': tamperStrikes,
      if (blueprints != null) 'blueprints': blueprints,
      if (liquidations != null) 'liquidations': liquidations,
      if (lifetimeCredits != null) 'lifetime_credits': lifetimeCredits,
      if (lastEventDay != null) 'last_event_day': lastEventDay,
      if (threatHeat != null) 'threat_heat': threatHeat,
      if (createdAt != null) 'created_at': createdAt,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (energy != null) 'energy': energy,
    });
  }

  PlayerStateCompanion copyWith({
    Value<int>? id,
    Value<double>? credits,
    Value<double>? materials,
    Value<double>? intel,
    Value<int>? prestigeKeys,
    Value<int>? level,
    Value<int>? xp,
    Value<double?>? lastKnownLat,
    Value<double?>? lastKnownLng,
    Value<int>? lastSyncTimestamp,
    Value<int>? monotonicUptime,
    Value<int>? worldSeed,
    Value<int>? bootCount,
    Value<int>? wallAtSync,
    Value<int>? tamperStrikes,
    Value<int>? blueprints,
    Value<int>? liquidations,
    Value<double>? lifetimeCredits,
    Value<int>? lastEventDay,
    Value<double>? threatHeat,
    Value<int>? createdAt,
    Value<String>? settingsJson,
    Value<double>? energy,
  }) {
    return PlayerStateCompanion(
      id: id ?? this.id,
      credits: credits ?? this.credits,
      materials: materials ?? this.materials,
      intel: intel ?? this.intel,
      prestigeKeys: prestigeKeys ?? this.prestigeKeys,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      lastKnownLat: lastKnownLat ?? this.lastKnownLat,
      lastKnownLng: lastKnownLng ?? this.lastKnownLng,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      monotonicUptime: monotonicUptime ?? this.monotonicUptime,
      worldSeed: worldSeed ?? this.worldSeed,
      bootCount: bootCount ?? this.bootCount,
      wallAtSync: wallAtSync ?? this.wallAtSync,
      tamperStrikes: tamperStrikes ?? this.tamperStrikes,
      blueprints: blueprints ?? this.blueprints,
      liquidations: liquidations ?? this.liquidations,
      lifetimeCredits: lifetimeCredits ?? this.lifetimeCredits,
      lastEventDay: lastEventDay ?? this.lastEventDay,
      threatHeat: threatHeat ?? this.threatHeat,
      createdAt: createdAt ?? this.createdAt,
      settingsJson: settingsJson ?? this.settingsJson,
      energy: energy ?? this.energy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (materials.present) {
      map['materials'] = Variable<double>(materials.value);
    }
    if (intel.present) {
      map['intel'] = Variable<double>(intel.value);
    }
    if (prestigeKeys.present) {
      map['prestige_keys'] = Variable<int>(prestigeKeys.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (lastKnownLat.present) {
      map['last_known_lat'] = Variable<double>(lastKnownLat.value);
    }
    if (lastKnownLng.present) {
      map['last_known_lng'] = Variable<double>(lastKnownLng.value);
    }
    if (lastSyncTimestamp.present) {
      map['last_sync_timestamp'] = Variable<int>(lastSyncTimestamp.value);
    }
    if (monotonicUptime.present) {
      map['monotonic_uptime'] = Variable<int>(monotonicUptime.value);
    }
    if (worldSeed.present) {
      map['world_seed'] = Variable<int>(worldSeed.value);
    }
    if (bootCount.present) {
      map['boot_count'] = Variable<int>(bootCount.value);
    }
    if (wallAtSync.present) {
      map['wall_at_sync'] = Variable<int>(wallAtSync.value);
    }
    if (tamperStrikes.present) {
      map['tamper_strikes'] = Variable<int>(tamperStrikes.value);
    }
    if (blueprints.present) {
      map['blueprints'] = Variable<int>(blueprints.value);
    }
    if (liquidations.present) {
      map['liquidations'] = Variable<int>(liquidations.value);
    }
    if (lifetimeCredits.present) {
      map['lifetime_credits'] = Variable<double>(lifetimeCredits.value);
    }
    if (lastEventDay.present) {
      map['last_event_day'] = Variable<int>(lastEventDay.value);
    }
    if (threatHeat.present) {
      map['threat_heat'] = Variable<double>(threatHeat.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (energy.present) {
      map['energy'] = Variable<double>(energy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateCompanion(')
          ..write('id: $id, ')
          ..write('credits: $credits, ')
          ..write('materials: $materials, ')
          ..write('intel: $intel, ')
          ..write('prestigeKeys: $prestigeKeys, ')
          ..write('level: $level, ')
          ..write('xp: $xp, ')
          ..write('lastKnownLat: $lastKnownLat, ')
          ..write('lastKnownLng: $lastKnownLng, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp, ')
          ..write('monotonicUptime: $monotonicUptime, ')
          ..write('worldSeed: $worldSeed, ')
          ..write('bootCount: $bootCount, ')
          ..write('wallAtSync: $wallAtSync, ')
          ..write('tamperStrikes: $tamperStrikes, ')
          ..write('blueprints: $blueprints, ')
          ..write('liquidations: $liquidations, ')
          ..write('lifetimeCredits: $lifetimeCredits, ')
          ..write('lastEventDay: $lastEventDay, ')
          ..write('threatHeat: $threatHeat, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('energy: $energy')
          ..write(')'))
        .toString();
  }
}

class Factions extends Table with TableInfo<Factions, FactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Factions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _factionIdMeta = const VerificationMeta(
    'factionId',
  );
  late final GeneratedColumn<String> factionId = GeneratedColumn<String>(
    'faction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  late final GeneratedColumn<int> archetype = GeneratedColumn<int>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _aggressionMeta = const VerificationMeta(
    'aggression',
  );
  late final GeneratedColumn<double> aggression = GeneratedColumn<double>(
    'aggression',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nemesisRankMeta = const VerificationMeta(
    'nemesisRank',
  );
  late final GeneratedColumn<int> nemesisRank = GeneratedColumn<int>(
    'nemesis_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  late final GeneratedColumn<int> wins = GeneratedColumn<int>(
    'wins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lossesMeta = const VerificationMeta('losses');
  late final GeneratedColumn<int> losses = GeneratedColumn<int>(
    'losses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    factionId,
    archetype,
    aggression,
    nemesisRank,
    wins,
    losses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('faction_id')) {
      context.handle(
        _factionIdMeta,
        factionId.isAcceptableOrUnknown(data['faction_id']!, _factionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_factionIdMeta);
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    } else if (isInserting) {
      context.missing(_archetypeMeta);
    }
    if (data.containsKey('aggression')) {
      context.handle(
        _aggressionMeta,
        aggression.isAcceptableOrUnknown(data['aggression']!, _aggressionMeta),
      );
    } else if (isInserting) {
      context.missing(_aggressionMeta);
    }
    if (data.containsKey('nemesis_rank')) {
      context.handle(
        _nemesisRankMeta,
        nemesisRank.isAcceptableOrUnknown(
          data['nemesis_rank']!,
          _nemesisRankMeta,
        ),
      );
    }
    if (data.containsKey('wins')) {
      context.handle(
        _winsMeta,
        wins.isAcceptableOrUnknown(data['wins']!, _winsMeta),
      );
    }
    if (data.containsKey('losses')) {
      context.handle(
        _lossesMeta,
        losses.isAcceptableOrUnknown(data['losses']!, _lossesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {factionId};
  @override
  FactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactionRow(
      factionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faction_id'],
      )!,
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archetype'],
      )!,
      aggression: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aggression'],
      )!,
      nemesisRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nemesis_rank'],
      )!,
      wins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wins'],
      )!,
      losses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}losses'],
      )!,
    );
  }

  @override
  Factions createAlias(String alias) {
    return Factions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class FactionRow extends DataClass implements Insertable<FactionRow> {
  final String factionId;
  final int archetype;
  final double aggression;
  final int nemesisRank;
  final int wins;
  final int losses;
  const FactionRow({
    required this.factionId,
    required this.archetype,
    required this.aggression,
    required this.nemesisRank,
    required this.wins,
    required this.losses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['faction_id'] = Variable<String>(factionId);
    map['archetype'] = Variable<int>(archetype);
    map['aggression'] = Variable<double>(aggression);
    map['nemesis_rank'] = Variable<int>(nemesisRank);
    map['wins'] = Variable<int>(wins);
    map['losses'] = Variable<int>(losses);
    return map;
  }

  FactionsCompanion toCompanion(bool nullToAbsent) {
    return FactionsCompanion(
      factionId: Value(factionId),
      archetype: Value(archetype),
      aggression: Value(aggression),
      nemesisRank: Value(nemesisRank),
      wins: Value(wins),
      losses: Value(losses),
    );
  }

  factory FactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactionRow(
      factionId: serializer.fromJson<String>(json['faction_id']),
      archetype: serializer.fromJson<int>(json['archetype']),
      aggression: serializer.fromJson<double>(json['aggression']),
      nemesisRank: serializer.fromJson<int>(json['nemesis_rank']),
      wins: serializer.fromJson<int>(json['wins']),
      losses: serializer.fromJson<int>(json['losses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'faction_id': serializer.toJson<String>(factionId),
      'archetype': serializer.toJson<int>(archetype),
      'aggression': serializer.toJson<double>(aggression),
      'nemesis_rank': serializer.toJson<int>(nemesisRank),
      'wins': serializer.toJson<int>(wins),
      'losses': serializer.toJson<int>(losses),
    };
  }

  FactionRow copyWith({
    String? factionId,
    int? archetype,
    double? aggression,
    int? nemesisRank,
    int? wins,
    int? losses,
  }) => FactionRow(
    factionId: factionId ?? this.factionId,
    archetype: archetype ?? this.archetype,
    aggression: aggression ?? this.aggression,
    nemesisRank: nemesisRank ?? this.nemesisRank,
    wins: wins ?? this.wins,
    losses: losses ?? this.losses,
  );
  FactionRow copyWithCompanion(FactionsCompanion data) {
    return FactionRow(
      factionId: data.factionId.present ? data.factionId.value : this.factionId,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      aggression: data.aggression.present
          ? data.aggression.value
          : this.aggression,
      nemesisRank: data.nemesisRank.present
          ? data.nemesisRank.value
          : this.nemesisRank,
      wins: data.wins.present ? data.wins.value : this.wins,
      losses: data.losses.present ? data.losses.value : this.losses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactionRow(')
          ..write('factionId: $factionId, ')
          ..write('archetype: $archetype, ')
          ..write('aggression: $aggression, ')
          ..write('nemesisRank: $nemesisRank, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(factionId, archetype, aggression, nemesisRank, wins, losses);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactionRow &&
          other.factionId == this.factionId &&
          other.archetype == this.archetype &&
          other.aggression == this.aggression &&
          other.nemesisRank == this.nemesisRank &&
          other.wins == this.wins &&
          other.losses == this.losses);
}

class FactionsCompanion extends UpdateCompanion<FactionRow> {
  final Value<String> factionId;
  final Value<int> archetype;
  final Value<double> aggression;
  final Value<int> nemesisRank;
  final Value<int> wins;
  final Value<int> losses;
  final Value<int> rowid;
  const FactionsCompanion({
    this.factionId = const Value.absent(),
    this.archetype = const Value.absent(),
    this.aggression = const Value.absent(),
    this.nemesisRank = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactionsCompanion.insert({
    required String factionId,
    required int archetype,
    required double aggression,
    this.nemesisRank = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : factionId = Value(factionId),
       archetype = Value(archetype),
       aggression = Value(aggression);
  static Insertable<FactionRow> custom({
    Expression<String>? factionId,
    Expression<int>? archetype,
    Expression<double>? aggression,
    Expression<int>? nemesisRank,
    Expression<int>? wins,
    Expression<int>? losses,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (factionId != null) 'faction_id': factionId,
      if (archetype != null) 'archetype': archetype,
      if (aggression != null) 'aggression': aggression,
      if (nemesisRank != null) 'nemesis_rank': nemesisRank,
      if (wins != null) 'wins': wins,
      if (losses != null) 'losses': losses,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactionsCompanion copyWith({
    Value<String>? factionId,
    Value<int>? archetype,
    Value<double>? aggression,
    Value<int>? nemesisRank,
    Value<int>? wins,
    Value<int>? losses,
    Value<int>? rowid,
  }) {
    return FactionsCompanion(
      factionId: factionId ?? this.factionId,
      archetype: archetype ?? this.archetype,
      aggression: aggression ?? this.aggression,
      nemesisRank: nemesisRank ?? this.nemesisRank,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (factionId.present) {
      map['faction_id'] = Variable<String>(factionId.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<int>(archetype.value);
    }
    if (aggression.present) {
      map['aggression'] = Variable<double>(aggression.value);
    }
    if (nemesisRank.present) {
      map['nemesis_rank'] = Variable<int>(nemesisRank.value);
    }
    if (wins.present) {
      map['wins'] = Variable<int>(wins.value);
    }
    if (losses.present) {
      map['losses'] = Variable<int>(losses.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactionsCompanion(')
          ..write('factionId: $factionId, ')
          ..write('archetype: $archetype, ')
          ..write('aggression: $aggression, ')
          ..write('nemesisRank: $nemesisRank, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class VaultUpgrades extends Table
    with TableInfo<VaultUpgrades, VaultUpgradeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  VaultUpgrades(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _upgradeIdMeta = const VerificationMeta(
    'upgradeId',
  );
  late final GeneratedColumn<String> upgradeId = GeneratedColumn<String>(
    'upgrade_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [upgradeId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_upgrades';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultUpgradeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('upgrade_id')) {
      context.handle(
        _upgradeIdMeta,
        upgradeId.isAcceptableOrUnknown(data['upgrade_id']!, _upgradeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_upgradeIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {upgradeId};
  @override
  VaultUpgradeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultUpgradeRow(
      upgradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upgrade_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  VaultUpgrades createAlias(String alias) {
    return VaultUpgrades(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class VaultUpgradeRow extends DataClass implements Insertable<VaultUpgradeRow> {
  final String upgradeId;
  final int rank;
  const VaultUpgradeRow({required this.upgradeId, required this.rank});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['upgrade_id'] = Variable<String>(upgradeId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  VaultUpgradesCompanion toCompanion(bool nullToAbsent) {
    return VaultUpgradesCompanion(
      upgradeId: Value(upgradeId),
      rank: Value(rank),
    );
  }

  factory VaultUpgradeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultUpgradeRow(
      upgradeId: serializer.fromJson<String>(json['upgrade_id']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'upgrade_id': serializer.toJson<String>(upgradeId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  VaultUpgradeRow copyWith({String? upgradeId, int? rank}) => VaultUpgradeRow(
    upgradeId: upgradeId ?? this.upgradeId,
    rank: rank ?? this.rank,
  );
  VaultUpgradeRow copyWithCompanion(VaultUpgradesCompanion data) {
    return VaultUpgradeRow(
      upgradeId: data.upgradeId.present ? data.upgradeId.value : this.upgradeId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultUpgradeRow(')
          ..write('upgradeId: $upgradeId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(upgradeId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultUpgradeRow &&
          other.upgradeId == this.upgradeId &&
          other.rank == this.rank);
}

class VaultUpgradesCompanion extends UpdateCompanion<VaultUpgradeRow> {
  final Value<String> upgradeId;
  final Value<int> rank;
  final Value<int> rowid;
  const VaultUpgradesCompanion({
    this.upgradeId = const Value.absent(),
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultUpgradesCompanion.insert({
    required String upgradeId,
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : upgradeId = Value(upgradeId);
  static Insertable<VaultUpgradeRow> custom({
    Expression<String>? upgradeId,
    Expression<int>? rank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (upgradeId != null) 'upgrade_id': upgradeId,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultUpgradesCompanion copyWith({
    Value<String>? upgradeId,
    Value<int>? rank,
    Value<int>? rowid,
  }) {
    return VaultUpgradesCompanion(
      upgradeId: upgradeId ?? this.upgradeId,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (upgradeId.present) {
      map['upgrade_id'] = Variable<String>(upgradeId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultUpgradesCompanion(')
          ..write('upgradeId: $upgradeId, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class StreetPerks extends Table with TableInfo<StreetPerks, StreetPerkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  StreetPerks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _perkIdMeta = const VerificationMeta('perkId');
  late final GeneratedColumn<String> perkId = GeneratedColumn<String>(
    'perk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [perkId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'street_perks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreetPerkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('perk_id')) {
      context.handle(
        _perkIdMeta,
        perkId.isAcceptableOrUnknown(data['perk_id']!, _perkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_perkIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {perkId};
  @override
  StreetPerkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreetPerkRow(
      perkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perk_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  StreetPerks createAlias(String alias) {
    return StreetPerks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class StreetPerkRow extends DataClass implements Insertable<StreetPerkRow> {
  final String perkId;
  final int rank;
  const StreetPerkRow({required this.perkId, required this.rank});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['perk_id'] = Variable<String>(perkId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  StreetPerksCompanion toCompanion(bool nullToAbsent) {
    return StreetPerksCompanion(perkId: Value(perkId), rank: Value(rank));
  }

  factory StreetPerkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreetPerkRow(
      perkId: serializer.fromJson<String>(json['perk_id']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'perk_id': serializer.toJson<String>(perkId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  StreetPerkRow copyWith({String? perkId, int? rank}) =>
      StreetPerkRow(perkId: perkId ?? this.perkId, rank: rank ?? this.rank);
  StreetPerkRow copyWithCompanion(StreetPerksCompanion data) {
    return StreetPerkRow(
      perkId: data.perkId.present ? data.perkId.value : this.perkId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreetPerkRow(')
          ..write('perkId: $perkId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(perkId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreetPerkRow &&
          other.perkId == this.perkId &&
          other.rank == this.rank);
}

class StreetPerksCompanion extends UpdateCompanion<StreetPerkRow> {
  final Value<String> perkId;
  final Value<int> rank;
  final Value<int> rowid;
  const StreetPerksCompanion({
    this.perkId = const Value.absent(),
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreetPerksCompanion.insert({
    required String perkId,
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : perkId = Value(perkId);
  static Insertable<StreetPerkRow> custom({
    Expression<String>? perkId,
    Expression<int>? rank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (perkId != null) 'perk_id': perkId,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreetPerksCompanion copyWith({
    Value<String>? perkId,
    Value<int>? rank,
    Value<int>? rowid,
  }) {
    return StreetPerksCompanion(
      perkId: perkId ?? this.perkId,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (perkId.present) {
      map['perk_id'] = Variable<String>(perkId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreetPerksCompanion(')
          ..write('perkId: $perkId, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class JobProgress extends Table with TableInfo<JobProgress, JobProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JobProgress(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _runsMeta = const VerificationMeta('runs');
  late final GeneratedColumn<int> runs = GeneratedColumn<int>(
    'runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [jobId, runs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('runs')) {
      context.handle(
        _runsMeta,
        runs.isAcceptableOrUnknown(data['runs']!, _runsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jobId};
  @override
  JobProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobProgressRow(
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      runs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs'],
      )!,
    );
  }

  @override
  JobProgress createAlias(String alias) {
    return JobProgress(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class JobProgressRow extends DataClass implements Insertable<JobProgressRow> {
  final String jobId;
  final int runs;
  const JobProgressRow({required this.jobId, required this.runs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_id'] = Variable<String>(jobId);
    map['runs'] = Variable<int>(runs);
    return map;
  }

  JobProgressCompanion toCompanion(bool nullToAbsent) {
    return JobProgressCompanion(jobId: Value(jobId), runs: Value(runs));
  }

  factory JobProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobProgressRow(
      jobId: serializer.fromJson<String>(json['job_id']),
      runs: serializer.fromJson<int>(json['runs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'job_id': serializer.toJson<String>(jobId),
      'runs': serializer.toJson<int>(runs),
    };
  }

  JobProgressRow copyWith({String? jobId, int? runs}) =>
      JobProgressRow(jobId: jobId ?? this.jobId, runs: runs ?? this.runs);
  JobProgressRow copyWithCompanion(JobProgressCompanion data) {
    return JobProgressRow(
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      runs: data.runs.present ? data.runs.value : this.runs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobProgressRow(')
          ..write('jobId: $jobId, ')
          ..write('runs: $runs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(jobId, runs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobProgressRow &&
          other.jobId == this.jobId &&
          other.runs == this.runs);
}

class JobProgressCompanion extends UpdateCompanion<JobProgressRow> {
  final Value<String> jobId;
  final Value<int> runs;
  final Value<int> rowid;
  const JobProgressCompanion({
    this.jobId = const Value.absent(),
    this.runs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobProgressCompanion.insert({
    required String jobId,
    this.runs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId);
  static Insertable<JobProgressRow> custom({
    Expression<String>? jobId,
    Expression<int>? runs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jobId != null) 'job_id': jobId,
      if (runs != null) 'runs': runs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobProgressCompanion copyWith({
    Value<String>? jobId,
    Value<int>? runs,
    Value<int>? rowid,
  }) {
    return JobProgressCompanion(
      jobId: jobId ?? this.jobId,
      runs: runs ?? this.runs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (runs.present) {
      map['runs'] = Variable<int>(runs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobProgressCompanion(')
          ..write('jobId: $jobId, ')
          ..write('runs: $runs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class EventLog extends Table with TableInfo<EventLog, LogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EventLog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, ts, kind, message];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
    );
  }

  @override
  EventLog createAlias(String alias) {
    return EventLog(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LogRow extends DataClass implements Insertable<LogRow> {
  final int id;
  final int ts;
  final String kind;
  final String message;
  const LogRow({
    required this.id,
    required this.ts,
    required this.kind,
    required this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ts'] = Variable<int>(ts);
    map['kind'] = Variable<String>(kind);
    map['message'] = Variable<String>(message);
    return map;
  }

  EventLogCompanion toCompanion(bool nullToAbsent) {
    return EventLogCompanion(
      id: Value(id),
      ts: Value(ts),
      kind: Value(kind),
      message: Value(message),
    );
  }

  factory LogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogRow(
      id: serializer.fromJson<int>(json['id']),
      ts: serializer.fromJson<int>(json['ts']),
      kind: serializer.fromJson<String>(json['kind']),
      message: serializer.fromJson<String>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ts': serializer.toJson<int>(ts),
      'kind': serializer.toJson<String>(kind),
      'message': serializer.toJson<String>(message),
    };
  }

  LogRow copyWith({int? id, int? ts, String? kind, String? message}) => LogRow(
    id: id ?? this.id,
    ts: ts ?? this.ts,
    kind: kind ?? this.kind,
    message: message ?? this.message,
  );
  LogRow copyWithCompanion(EventLogCompanion data) {
    return LogRow(
      id: data.id.present ? data.id.value : this.id,
      ts: data.ts.present ? data.ts.value : this.ts,
      kind: data.kind.present ? data.kind.value : this.kind,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogRow(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('kind: $kind, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ts, kind, message);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogRow &&
          other.id == this.id &&
          other.ts == this.ts &&
          other.kind == this.kind &&
          other.message == this.message);
}

class EventLogCompanion extends UpdateCompanion<LogRow> {
  final Value<int> id;
  final Value<int> ts;
  final Value<String> kind;
  final Value<String> message;
  const EventLogCompanion({
    this.id = const Value.absent(),
    this.ts = const Value.absent(),
    this.kind = const Value.absent(),
    this.message = const Value.absent(),
  });
  EventLogCompanion.insert({
    this.id = const Value.absent(),
    required int ts,
    required String kind,
    required String message,
  }) : ts = Value(ts),
       kind = Value(kind),
       message = Value(message);
  static Insertable<LogRow> custom({
    Expression<int>? id,
    Expression<int>? ts,
    Expression<String>? kind,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ts != null) 'ts': ts,
      if (kind != null) 'kind': kind,
      if (message != null) 'message': message,
    });
  }

  EventLogCompanion copyWith({
    Value<int>? id,
    Value<int>? ts,
    Value<String>? kind,
    Value<String>? message,
  }) {
    return EventLogCompanion(
      id: id ?? this.id,
      ts: ts ?? this.ts,
      kind: kind ?? this.kind,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventLogCompanion(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('kind: $kind, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

abstract class _$HexDatabase extends GeneratedDatabase {
  _$HexDatabase(QueryExecutor e) : super(e);
  $HexDatabaseManager get managers => $HexDatabaseManager(this);
  late final HexNodes hexNodes = HexNodes(this);
  late final Index hexOwnerIdx = Index(
    'hex_owner_idx',
    'CREATE INDEX hex_owner_idx ON hex_nodes (owner)',
  );
  late final Index hexDistrictIdx = Index(
    'hex_district_idx',
    'CREATE INDEX hex_district_idx ON hex_nodes (district_res6)',
  );
  late final InstalledModules installedModules = InstalledModules(this);
  late final Index moduleHexIdx = Index(
    'module_hex_idx',
    'CREATE INDEX module_hex_idx ON installed_modules (hex_h3_index)',
  );
  late final ModuleStash moduleStash = ModuleStash(this);
  late final ActiveWorldEvents activeWorldEvents = ActiveWorldEvents(this);
  late final PlayerState playerState = PlayerState(this);
  late final Factions factions = Factions(this);
  late final VaultUpgrades vaultUpgrades = VaultUpgrades(this);
  late final StreetPerks streetPerks = StreetPerks(this);
  late final JobProgress jobProgress = JobProgress(this);
  late final EventLog eventLog = EventLog(this);
  Selectable<HexRow> persistedHexes() {
    return customSelect(
      'SELECT * FROM hex_nodes WHERE owner <> \'neutral\'',
      variables: [],
      readsFrom: {this.hexNodes},
    ).asyncMap(this.hexNodes.mapFromRow);
  }

  Selectable<InstalledModuleRow> allInstalled() {
    return customSelect(
      'SELECT * FROM installed_modules',
      variables: [],
      readsFrom: {this.installedModules},
    ).asyncMap(this.installedModules.mapFromRow);
  }

  Selectable<StashRow> allStash() {
    return customSelect(
      'SELECT * FROM module_stash ORDER BY acquired_at DESC',
      variables: [],
      readsFrom: {this.moduleStash},
    ).asyncMap(this.moduleStash.mapFromRow);
  }

  Selectable<WorldEventRow> allEvents() {
    return customSelect(
      'SELECT * FROM active_world_events',
      variables: [],
      readsFrom: {this.activeWorldEvents},
    ).asyncMap(this.activeWorldEvents.mapFromRow);
  }

  Selectable<LogRow> recentLog({required int lim}) {
    return customSelect(
      'SELECT * FROM event_log ORDER BY id DESC LIMIT ?1',
      variables: [Variable<int>(lim)],
      readsFrom: {this.eventLog},
    ).asyncMap(this.eventLog.mapFromRow);
  }

  Future<int> trimLog() {
    return customUpdate(
      'DELETE FROM event_log WHERE id <= (SELECT MAX(id) FROM event_log) - 400',
      variables: [],
      updates: {this.eventLog},
      updateKind: UpdateKind.delete,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hexNodes,
    hexOwnerIdx,
    hexDistrictIdx,
    installedModules,
    moduleHexIdx,
    moduleStash,
    activeWorldEvents,
    playerState,
    factions,
    vaultUpgrades,
    streetPerks,
    jobProgress,
    eventLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hex_nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('installed_modules', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $HexNodesCreateCompanionBuilder = HexNodesCompanion Function({
  required String h3Index,
  required String districtRes6,
  required String biomeType,
  Value<String?> anomalyTrait,
  Value<String> owner,
  Value<int> garrisonLevel,
  Value<double> structuralIntegrity,
  Value<bool> isAnchorHub,
  Value<String?> connectedRelayTarget,
  required int lastTickTimestamp,
  required double turfLat,
  required double turfLng,
  required String turfName,
  Value<bool> isStation,
  Value<int> hubLevel,
  Value<int?> capturedAt,
  Value<int> rowid,
});
typedef $HexNodesUpdateCompanionBuilder = HexNodesCompanion Function({
  Value<String> h3Index,
  Value<String> districtRes6,
  Value<String> biomeType,
  Value<String?> anomalyTrait,
  Value<String> owner,
  Value<int> garrisonLevel,
  Value<double> structuralIntegrity,
  Value<bool> isAnchorHub,
  Value<String?> connectedRelayTarget,
  Value<int> lastTickTimestamp,
  Value<double> turfLat,
  Value<double> turfLng,
  Value<String> turfName,
  Value<bool> isStation,
  Value<int> hubLevel,
  Value<int?> capturedAt,
  Value<int> rowid,
});

final class $HexNodesReferences
    extends BaseReferences<_$HexDatabase, HexNodes, HexRow> {
  $HexNodesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<InstalledModules, List<InstalledModuleRow>>
  _installedModulesRefsTable(_$HexDatabase db) => MultiTypedResultKey.fromTable(
    db.installedModules,
    aliasName: 'hex_nodes__h3_index__installed_modules__hex_h3_index',
  );

  $InstalledModulesProcessedTableManager get installedModulesRefs {
    final manager = $InstalledModulesTableManager($_db, $_db.installedModules)
        .filter(
          (f) =>
              f.hexH3Index.h3Index.sqlEquals($_itemColumn<String>('h3_index')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _installedModulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $HexNodesFilterComposer extends Composer<_$HexDatabase, HexNodes> {
  $HexNodesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get h3Index => $composableBuilder(
    column: $table.h3Index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get districtRes6 => $composableBuilder(
    column: $table.districtRes6,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biomeType => $composableBuilder(
    column: $table.biomeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anomalyTrait => $composableBuilder(
    column: $table.anomalyTrait,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get garrisonLevel => $composableBuilder(
    column: $table.garrisonLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get structuralIntegrity => $composableBuilder(
    column: $table.structuralIntegrity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAnchorHub => $composableBuilder(
    column: $table.isAnchorHub,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectedRelayTarget => $composableBuilder(
    column: $table.connectedRelayTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTickTimestamp => $composableBuilder(
    column: $table.lastTickTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get turfLat => $composableBuilder(
    column: $table.turfLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get turfLng => $composableBuilder(
    column: $table.turfLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get turfName => $composableBuilder(
    column: $table.turfName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStation => $composableBuilder(
    column: $table.isStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hubLevel => $composableBuilder(
    column: $table.hubLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> installedModulesRefs(
    Expression<bool> Function($InstalledModulesFilterComposer f) f,
  ) {
    final $InstalledModulesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.h3Index,
      referencedTable: $db.installedModules,
      getReferencedColumn: (t) => t.hexH3Index,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $InstalledModulesFilterComposer(
            $db: $db,
            $table: $db.installedModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $HexNodesOrderingComposer extends Composer<_$HexDatabase, HexNodes> {
  $HexNodesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get h3Index => $composableBuilder(
    column: $table.h3Index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get districtRes6 => $composableBuilder(
    column: $table.districtRes6,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biomeType => $composableBuilder(
    column: $table.biomeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anomalyTrait => $composableBuilder(
    column: $table.anomalyTrait,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get garrisonLevel => $composableBuilder(
    column: $table.garrisonLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get structuralIntegrity => $composableBuilder(
    column: $table.structuralIntegrity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAnchorHub => $composableBuilder(
    column: $table.isAnchorHub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectedRelayTarget => $composableBuilder(
    column: $table.connectedRelayTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTickTimestamp => $composableBuilder(
    column: $table.lastTickTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get turfLat => $composableBuilder(
    column: $table.turfLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get turfLng => $composableBuilder(
    column: $table.turfLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get turfName => $composableBuilder(
    column: $table.turfName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStation => $composableBuilder(
    column: $table.isStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hubLevel => $composableBuilder(
    column: $table.hubLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $HexNodesAnnotationComposer extends Composer<_$HexDatabase, HexNodes> {
  $HexNodesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get h3Index =>
      $composableBuilder(column: $table.h3Index, builder: (column) => column);

  GeneratedColumn<String> get districtRes6 => $composableBuilder(
    column: $table.districtRes6,
    builder: (column) => column,
  );

  GeneratedColumn<String> get biomeType =>
      $composableBuilder(column: $table.biomeType, builder: (column) => column);

  GeneratedColumn<String> get anomalyTrait => $composableBuilder(
    column: $table.anomalyTrait,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<int> get garrisonLevel => $composableBuilder(
    column: $table.garrisonLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get structuralIntegrity => $composableBuilder(
    column: $table.structuralIntegrity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAnchorHub => $composableBuilder(
    column: $table.isAnchorHub,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectedRelayTarget => $composableBuilder(
    column: $table.connectedRelayTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastTickTimestamp => $composableBuilder(
    column: $table.lastTickTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get turfLat =>
      $composableBuilder(column: $table.turfLat, builder: (column) => column);

  GeneratedColumn<double> get turfLng =>
      $composableBuilder(column: $table.turfLng, builder: (column) => column);

  GeneratedColumn<String> get turfName =>
      $composableBuilder(column: $table.turfName, builder: (column) => column);

  GeneratedColumn<bool> get isStation =>
      $composableBuilder(column: $table.isStation, builder: (column) => column);

  GeneratedColumn<int> get hubLevel =>
      $composableBuilder(column: $table.hubLevel, builder: (column) => column);

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  Expression<T> installedModulesRefs<T extends Object>(
    Expression<T> Function($InstalledModulesAnnotationComposer a) f,
  ) {
    final $InstalledModulesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.h3Index,
      referencedTable: $db.installedModules,
      getReferencedColumn: (t) => t.hexH3Index,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $InstalledModulesAnnotationComposer(
            $db: $db,
            $table: $db.installedModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $HexNodesTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          HexNodes,
          HexRow,
          $HexNodesFilterComposer,
          $HexNodesOrderingComposer,
          $HexNodesAnnotationComposer,
          $HexNodesCreateCompanionBuilder,
          $HexNodesUpdateCompanionBuilder,
          (HexRow, $HexNodesReferences),
          HexRow,
          PrefetchHooks Function({bool installedModulesRefs})
        > {
  $HexNodesTableManager(_$HexDatabase db, HexNodes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $HexNodesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $HexNodesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $HexNodesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> h3Index = const Value.absent(),
                Value<String> districtRes6 = const Value.absent(),
                Value<String> biomeType = const Value.absent(),
                Value<String?> anomalyTrait = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> garrisonLevel = const Value.absent(),
                Value<double> structuralIntegrity = const Value.absent(),
                Value<bool> isAnchorHub = const Value.absent(),
                Value<String?> connectedRelayTarget = const Value.absent(),
                Value<int> lastTickTimestamp = const Value.absent(),
                Value<double> turfLat = const Value.absent(),
                Value<double> turfLng = const Value.absent(),
                Value<String> turfName = const Value.absent(),
                Value<bool> isStation = const Value.absent(),
                Value<int> hubLevel = const Value.absent(),
                Value<int?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HexNodesCompanion(
                h3Index: h3Index,
                districtRes6: districtRes6,
                biomeType: biomeType,
                anomalyTrait: anomalyTrait,
                owner: owner,
                garrisonLevel: garrisonLevel,
                structuralIntegrity: structuralIntegrity,
                isAnchorHub: isAnchorHub,
                connectedRelayTarget: connectedRelayTarget,
                lastTickTimestamp: lastTickTimestamp,
                turfLat: turfLat,
                turfLng: turfLng,
                turfName: turfName,
                isStation: isStation,
                hubLevel: hubLevel,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String h3Index,
                required String districtRes6,
                required String biomeType,
                Value<String?> anomalyTrait = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> garrisonLevel = const Value.absent(),
                Value<double> structuralIntegrity = const Value.absent(),
                Value<bool> isAnchorHub = const Value.absent(),
                Value<String?> connectedRelayTarget = const Value.absent(),
                required int lastTickTimestamp,
                required double turfLat,
                required double turfLng,
                required String turfName,
                Value<bool> isStation = const Value.absent(),
                Value<int> hubLevel = const Value.absent(),
                Value<int?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HexNodesCompanion.insert(
                h3Index: h3Index,
                districtRes6: districtRes6,
                biomeType: biomeType,
                anomalyTrait: anomalyTrait,
                owner: owner,
                garrisonLevel: garrisonLevel,
                structuralIntegrity: structuralIntegrity,
                isAnchorHub: isAnchorHub,
                connectedRelayTarget: connectedRelayTarget,
                lastTickTimestamp: lastTickTimestamp,
                turfLat: turfLat,
                turfLng: turfLng,
                turfName: turfName,
                isStation: isStation,
                hubLevel: hubLevel,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<HexNodes, HexRow>(table),
                  $HexNodesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({installedModulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (installedModulesRefs) db.installedModules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (installedModulesRefs)
                    await $_getPrefetchedData<
                      HexRow,
                      HexNodes,
                      InstalledModuleRow
                    >(
                      currentTable: table,
                      referencedTable: $HexNodesReferences
                          ._installedModulesRefsTable(db),
                      managerFromTypedResult: (p0) => $HexNodesReferences(
                        db,
                        table,
                        p0,
                      ).installedModulesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.hexH3Index == item.h3Index,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $HexNodesProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      HexNodes,
      HexRow,
      $HexNodesFilterComposer,
      $HexNodesOrderingComposer,
      $HexNodesAnnotationComposer,
      $HexNodesCreateCompanionBuilder,
      $HexNodesUpdateCompanionBuilder,
      (HexRow, $HexNodesReferences),
      HexRow,
      PrefetchHooks Function({bool installedModulesRefs})
    >;
typedef $InstalledModulesCreateCompanionBuilder =
    InstalledModulesCompanion Function({
      required String id,
      required String hexH3Index,
      required int socketIndex,
      required String moduleName,
      required String rarity,
      Value<double> statCashMult,
      Value<double> statDefMult,
      Value<String?> specialPerk,
      Value<double> perkValue,
      Value<int> itemLevel,
      Value<int> rowid,
    });
typedef $InstalledModulesUpdateCompanionBuilder =
    InstalledModulesCompanion Function({
      Value<String> id,
      Value<String> hexH3Index,
      Value<int> socketIndex,
      Value<String> moduleName,
      Value<String> rarity,
      Value<double> statCashMult,
      Value<double> statDefMult,
      Value<String?> specialPerk,
      Value<double> perkValue,
      Value<int> itemLevel,
      Value<int> rowid,
    });

final class $InstalledModulesReferences
    extends
        BaseReferences<_$HexDatabase, InstalledModules, InstalledModuleRow> {
  $InstalledModulesReferences(super.$_db, super.$_table, super.$_typedResult);

  static HexNodes _hexH3IndexTable(_$HexDatabase db) => db.hexNodes.createAlias(
    'installed_modules__hex_h3_index__hex_nodes__h3_index',
  );

  $HexNodesProcessedTableManager get hexH3Index {
    final $_column = $_itemColumn<String>('hex_h3_index')!;

    final manager = $HexNodesTableManager(
      $_db,
      $_db.hexNodes,
    ).filter((f) => f.h3Index.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hexH3IndexTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $InstalledModulesFilterComposer
    extends Composer<_$HexDatabase, InstalledModules> {
  $InstalledModulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socketIndex => $composableBuilder(
    column: $table.socketIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perkValue => $composableBuilder(
    column: $table.perkValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemLevel => $composableBuilder(
    column: $table.itemLevel,
    builder: (column) => ColumnFilters(column),
  );

  $HexNodesFilterComposer get hexH3Index {
    final $HexNodesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hexH3Index,
      referencedTable: $db.hexNodes,
      getReferencedColumn: (t) => t.h3Index,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HexNodesFilterComposer(
            $db: $db,
            $table: $db.hexNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $InstalledModulesOrderingComposer
    extends Composer<_$HexDatabase, InstalledModules> {
  $InstalledModulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socketIndex => $composableBuilder(
    column: $table.socketIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perkValue => $composableBuilder(
    column: $table.perkValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemLevel => $composableBuilder(
    column: $table.itemLevel,
    builder: (column) => ColumnOrderings(column),
  );

  $HexNodesOrderingComposer get hexH3Index {
    final $HexNodesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hexH3Index,
      referencedTable: $db.hexNodes,
      getReferencedColumn: (t) => t.h3Index,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HexNodesOrderingComposer(
            $db: $db,
            $table: $db.hexNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $InstalledModulesAnnotationComposer
    extends Composer<_$HexDatabase, InstalledModules> {
  $InstalledModulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get socketIndex => $composableBuilder(
    column: $table.socketIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => column,
  );

  GeneratedColumn<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => column,
  );

  GeneratedColumn<double> get perkValue =>
      $composableBuilder(column: $table.perkValue, builder: (column) => column);

  GeneratedColumn<int> get itemLevel =>
      $composableBuilder(column: $table.itemLevel, builder: (column) => column);

  $HexNodesAnnotationComposer get hexH3Index {
    final $HexNodesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hexH3Index,
      referencedTable: $db.hexNodes,
      getReferencedColumn: (t) => t.h3Index,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HexNodesAnnotationComposer(
            $db: $db,
            $table: $db.hexNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $InstalledModulesTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          InstalledModules,
          InstalledModuleRow,
          $InstalledModulesFilterComposer,
          $InstalledModulesOrderingComposer,
          $InstalledModulesAnnotationComposer,
          $InstalledModulesCreateCompanionBuilder,
          $InstalledModulesUpdateCompanionBuilder,
          (InstalledModuleRow, $InstalledModulesReferences),
          InstalledModuleRow,
          PrefetchHooks Function({bool hexH3Index})
        > {
  $InstalledModulesTableManager(_$HexDatabase db, InstalledModules table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $InstalledModulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $InstalledModulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $InstalledModulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hexH3Index = const Value.absent(),
                Value<int> socketIndex = const Value.absent(),
                Value<String> moduleName = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<double> statCashMult = const Value.absent(),
                Value<double> statDefMult = const Value.absent(),
                Value<String?> specialPerk = const Value.absent(),
                Value<double> perkValue = const Value.absent(),
                Value<int> itemLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledModulesCompanion(
                id: id,
                hexH3Index: hexH3Index,
                socketIndex: socketIndex,
                moduleName: moduleName,
                rarity: rarity,
                statCashMult: statCashMult,
                statDefMult: statDefMult,
                specialPerk: specialPerk,
                perkValue: perkValue,
                itemLevel: itemLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hexH3Index,
                required int socketIndex,
                required String moduleName,
                required String rarity,
                Value<double> statCashMult = const Value.absent(),
                Value<double> statDefMult = const Value.absent(),
                Value<String?> specialPerk = const Value.absent(),
                Value<double> perkValue = const Value.absent(),
                Value<int> itemLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledModulesCompanion.insert(
                id: id,
                hexH3Index: hexH3Index,
                socketIndex: socketIndex,
                moduleName: moduleName,
                rarity: rarity,
                statCashMult: statCashMult,
                statDefMult: statDefMult,
                specialPerk: specialPerk,
                perkValue: perkValue,
                itemLevel: itemLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<InstalledModules, InstalledModuleRow>(table),
                  $InstalledModulesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hexH3Index = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (hexH3Index) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.hexH3Index,
                        referencedTable: $InstalledModulesReferences
                            ._hexH3IndexTable(db),
                        referencedColumn: $InstalledModulesReferences
                            ._hexH3IndexTable(db)
                            .h3Index,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $InstalledModulesProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      InstalledModules,
      InstalledModuleRow,
      $InstalledModulesFilterComposer,
      $InstalledModulesOrderingComposer,
      $InstalledModulesAnnotationComposer,
      $InstalledModulesCreateCompanionBuilder,
      $InstalledModulesUpdateCompanionBuilder,
      (InstalledModuleRow, $InstalledModulesReferences),
      InstalledModuleRow,
      PrefetchHooks Function({bool hexH3Index})
    >;
typedef $ModuleStashCreateCompanionBuilder = ModuleStashCompanion Function({
  required String id,
  required String moduleName,
  required String rarity,
  Value<double> statCashMult,
  Value<double> statDefMult,
  Value<String?> specialPerk,
  Value<double> perkValue,
  Value<int> itemLevel,
  required int acquiredAt,
  Value<int> rowid,
});
typedef $ModuleStashUpdateCompanionBuilder = ModuleStashCompanion Function({
  Value<String> id,
  Value<String> moduleName,
  Value<String> rarity,
  Value<double> statCashMult,
  Value<double> statDefMult,
  Value<String?> specialPerk,
  Value<double> perkValue,
  Value<int> itemLevel,
  Value<int> acquiredAt,
  Value<int> rowid,
});

class $ModuleStashFilterComposer extends Composer<_$HexDatabase, ModuleStash> {
  $ModuleStashFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perkValue => $composableBuilder(
    column: $table.perkValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemLevel => $composableBuilder(
    column: $table.itemLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ModuleStashOrderingComposer
    extends Composer<_$HexDatabase, ModuleStash> {
  $ModuleStashOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perkValue => $composableBuilder(
    column: $table.perkValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemLevel => $composableBuilder(
    column: $table.itemLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ModuleStashAnnotationComposer
    extends Composer<_$HexDatabase, ModuleStash> {
  $ModuleStashAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleName => $composableBuilder(
    column: $table.moduleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<double> get statCashMult => $composableBuilder(
    column: $table.statCashMult,
    builder: (column) => column,
  );

  GeneratedColumn<double> get statDefMult => $composableBuilder(
    column: $table.statDefMult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialPerk => $composableBuilder(
    column: $table.specialPerk,
    builder: (column) => column,
  );

  GeneratedColumn<double> get perkValue =>
      $composableBuilder(column: $table.perkValue, builder: (column) => column);

  GeneratedColumn<int> get itemLevel =>
      $composableBuilder(column: $table.itemLevel, builder: (column) => column);

  GeneratedColumn<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );
}

class $ModuleStashTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          ModuleStash,
          StashRow,
          $ModuleStashFilterComposer,
          $ModuleStashOrderingComposer,
          $ModuleStashAnnotationComposer,
          $ModuleStashCreateCompanionBuilder,
          $ModuleStashUpdateCompanionBuilder,
          (StashRow, BaseReferences<_$HexDatabase, ModuleStash, StashRow>),
          StashRow,
          PrefetchHooks Function()
        > {
  $ModuleStashTableManager(_$HexDatabase db, ModuleStash table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ModuleStashFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ModuleStashOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ModuleStashAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> moduleName = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<double> statCashMult = const Value.absent(),
                Value<double> statDefMult = const Value.absent(),
                Value<String?> specialPerk = const Value.absent(),
                Value<double> perkValue = const Value.absent(),
                Value<int> itemLevel = const Value.absent(),
                Value<int> acquiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModuleStashCompanion(
                id: id,
                moduleName: moduleName,
                rarity: rarity,
                statCashMult: statCashMult,
                statDefMult: statDefMult,
                specialPerk: specialPerk,
                perkValue: perkValue,
                itemLevel: itemLevel,
                acquiredAt: acquiredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String moduleName,
                required String rarity,
                Value<double> statCashMult = const Value.absent(),
                Value<double> statDefMult = const Value.absent(),
                Value<String?> specialPerk = const Value.absent(),
                Value<double> perkValue = const Value.absent(),
                Value<int> itemLevel = const Value.absent(),
                required int acquiredAt,
                Value<int> rowid = const Value.absent(),
              }) => ModuleStashCompanion.insert(
                id: id,
                moduleName: moduleName,
                rarity: rarity,
                statCashMult: statCashMult,
                statDefMult: statDefMult,
                specialPerk: specialPerk,
                perkValue: perkValue,
                itemLevel: itemLevel,
                acquiredAt: acquiredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ModuleStash, StashRow>(table),
                  BaseReferences<_$HexDatabase, ModuleStash, StashRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ModuleStashProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      ModuleStash,
      StashRow,
      $ModuleStashFilterComposer,
      $ModuleStashOrderingComposer,
      $ModuleStashAnnotationComposer,
      $ModuleStashCreateCompanionBuilder,
      $ModuleStashUpdateCompanionBuilder,
      (StashRow, BaseReferences<_$HexDatabase, ModuleStash, StashRow>),
      StashRow,
      PrefetchHooks Function()
    >;
typedef $ActiveWorldEventsCreateCompanionBuilder =
    ActiveWorldEventsCompanion Function({
      required String eventId,
      required String eventType,
      required String targetH3Index,
      required int expiresAt,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $ActiveWorldEventsUpdateCompanionBuilder =
    ActiveWorldEventsCompanion Function({
      Value<String> eventId,
      Value<String> eventType,
      Value<String> targetH3Index,
      Value<int> expiresAt,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $ActiveWorldEventsFilterComposer
    extends Composer<_$HexDatabase, ActiveWorldEvents> {
  $ActiveWorldEventsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetH3Index => $composableBuilder(
    column: $table.targetH3Index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $ActiveWorldEventsOrderingComposer
    extends Composer<_$HexDatabase, ActiveWorldEvents> {
  $ActiveWorldEventsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetH3Index => $composableBuilder(
    column: $table.targetH3Index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ActiveWorldEventsAnnotationComposer
    extends Composer<_$HexDatabase, ActiveWorldEvents> {
  $ActiveWorldEventsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get targetH3Index => $composableBuilder(
    column: $table.targetH3Index,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $ActiveWorldEventsTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          ActiveWorldEvents,
          WorldEventRow,
          $ActiveWorldEventsFilterComposer,
          $ActiveWorldEventsOrderingComposer,
          $ActiveWorldEventsAnnotationComposer,
          $ActiveWorldEventsCreateCompanionBuilder,
          $ActiveWorldEventsUpdateCompanionBuilder,
          (
            WorldEventRow,
            BaseReferences<_$HexDatabase, ActiveWorldEvents, WorldEventRow>,
          ),
          WorldEventRow,
          PrefetchHooks Function()
        > {
  $ActiveWorldEventsTableManager(_$HexDatabase db, ActiveWorldEvents table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActiveWorldEventsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActiveWorldEventsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActiveWorldEventsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> targetH3Index = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorldEventsCompanion(
                eventId: eventId,
                eventType: eventType,
                targetH3Index: targetH3Index,
                expiresAt: expiresAt,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String eventType,
                required String targetH3Index,
                required int expiresAt,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorldEventsCompanion.insert(
                eventId: eventId,
                eventType: eventType,
                targetH3Index: targetH3Index,
                expiresAt: expiresAt,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActiveWorldEvents, WorldEventRow>(table),
                  BaseReferences<
                    _$HexDatabase,
                    ActiveWorldEvents,
                    WorldEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ActiveWorldEventsProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      ActiveWorldEvents,
      WorldEventRow,
      $ActiveWorldEventsFilterComposer,
      $ActiveWorldEventsOrderingComposer,
      $ActiveWorldEventsAnnotationComposer,
      $ActiveWorldEventsCreateCompanionBuilder,
      $ActiveWorldEventsUpdateCompanionBuilder,
      (
        WorldEventRow,
        BaseReferences<_$HexDatabase, ActiveWorldEvents, WorldEventRow>,
      ),
      WorldEventRow,
      PrefetchHooks Function()
    >;
typedef $PlayerStateCreateCompanionBuilder = PlayerStateCompanion Function({
  Value<int> id,
  Value<double> credits,
  Value<double> materials,
  Value<double> intel,
  Value<int> prestigeKeys,
  Value<int> level,
  Value<int> xp,
  Value<double?> lastKnownLat,
  Value<double?> lastKnownLng,
  required int lastSyncTimestamp,
  required int monotonicUptime,
  required int worldSeed,
  Value<int> bootCount,
  Value<int> wallAtSync,
  Value<int> tamperStrikes,
  Value<int> blueprints,
  Value<int> liquidations,
  Value<double> lifetimeCredits,
  Value<int> lastEventDay,
  Value<double> threatHeat,
  required int createdAt,
  Value<String> settingsJson,
  Value<double> energy,
});
typedef $PlayerStateUpdateCompanionBuilder = PlayerStateCompanion Function({
  Value<int> id,
  Value<double> credits,
  Value<double> materials,
  Value<double> intel,
  Value<int> prestigeKeys,
  Value<int> level,
  Value<int> xp,
  Value<double?> lastKnownLat,
  Value<double?> lastKnownLng,
  Value<int> lastSyncTimestamp,
  Value<int> monotonicUptime,
  Value<int> worldSeed,
  Value<int> bootCount,
  Value<int> wallAtSync,
  Value<int> tamperStrikes,
  Value<int> blueprints,
  Value<int> liquidations,
  Value<double> lifetimeCredits,
  Value<int> lastEventDay,
  Value<double> threatHeat,
  Value<int> createdAt,
  Value<String> settingsJson,
  Value<double> energy,
});

class $PlayerStateFilterComposer extends Composer<_$HexDatabase, PlayerState> {
  $PlayerStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get materials => $composableBuilder(
    column: $table.materials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intel => $composableBuilder(
    column: $table.intel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prestigeKeys => $composableBuilder(
    column: $table.prestigeKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastKnownLat => $composableBuilder(
    column: $table.lastKnownLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastKnownLng => $composableBuilder(
    column: $table.lastKnownLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monotonicUptime => $composableBuilder(
    column: $table.monotonicUptime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get worldSeed => $composableBuilder(
    column: $table.worldSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bootCount => $composableBuilder(
    column: $table.bootCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wallAtSync => $composableBuilder(
    column: $table.wallAtSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tamperStrikes => $composableBuilder(
    column: $table.tamperStrikes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blueprints => $composableBuilder(
    column: $table.blueprints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liquidations => $composableBuilder(
    column: $table.liquidations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lifetimeCredits => $composableBuilder(
    column: $table.lifetimeCredits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastEventDay => $composableBuilder(
    column: $table.lastEventDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get threatHeat => $composableBuilder(
    column: $table.threatHeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlayerStateOrderingComposer
    extends Composer<_$HexDatabase, PlayerState> {
  $PlayerStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get materials => $composableBuilder(
    column: $table.materials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intel => $composableBuilder(
    column: $table.intel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prestigeKeys => $composableBuilder(
    column: $table.prestigeKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastKnownLat => $composableBuilder(
    column: $table.lastKnownLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastKnownLng => $composableBuilder(
    column: $table.lastKnownLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monotonicUptime => $composableBuilder(
    column: $table.monotonicUptime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get worldSeed => $composableBuilder(
    column: $table.worldSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bootCount => $composableBuilder(
    column: $table.bootCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wallAtSync => $composableBuilder(
    column: $table.wallAtSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tamperStrikes => $composableBuilder(
    column: $table.tamperStrikes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blueprints => $composableBuilder(
    column: $table.blueprints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liquidations => $composableBuilder(
    column: $table.liquidations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lifetimeCredits => $composableBuilder(
    column: $table.lifetimeCredits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastEventDay => $composableBuilder(
    column: $table.lastEventDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get threatHeat => $composableBuilder(
    column: $table.threatHeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlayerStateAnnotationComposer
    extends Composer<_$HexDatabase, PlayerState> {
  $PlayerStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<double> get materials =>
      $composableBuilder(column: $table.materials, builder: (column) => column);

  GeneratedColumn<double> get intel =>
      $composableBuilder(column: $table.intel, builder: (column) => column);

  GeneratedColumn<int> get prestigeKeys => $composableBuilder(
    column: $table.prestigeKeys,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<double> get lastKnownLat => $composableBuilder(
    column: $table.lastKnownLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastKnownLng => $composableBuilder(
    column: $table.lastKnownLng,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monotonicUptime => $composableBuilder(
    column: $table.monotonicUptime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get worldSeed =>
      $composableBuilder(column: $table.worldSeed, builder: (column) => column);

  GeneratedColumn<int> get bootCount =>
      $composableBuilder(column: $table.bootCount, builder: (column) => column);

  GeneratedColumn<int> get wallAtSync => $composableBuilder(
    column: $table.wallAtSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tamperStrikes => $composableBuilder(
    column: $table.tamperStrikes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get blueprints => $composableBuilder(
    column: $table.blueprints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get liquidations => $composableBuilder(
    column: $table.liquidations,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lifetimeCredits => $composableBuilder(
    column: $table.lifetimeCredits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastEventDay => $composableBuilder(
    column: $table.lastEventDay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get threatHeat => $composableBuilder(
    column: $table.threatHeat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);
}

class $PlayerStateTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          PlayerState,
          PlayerRow,
          $PlayerStateFilterComposer,
          $PlayerStateOrderingComposer,
          $PlayerStateAnnotationComposer,
          $PlayerStateCreateCompanionBuilder,
          $PlayerStateUpdateCompanionBuilder,
          (PlayerRow, BaseReferences<_$HexDatabase, PlayerState, PlayerRow>),
          PlayerRow,
          PrefetchHooks Function()
        > {
  $PlayerStateTableManager(_$HexDatabase db, PlayerState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlayerStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlayerStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlayerStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> credits = const Value.absent(),
                Value<double> materials = const Value.absent(),
                Value<double> intel = const Value.absent(),
                Value<int> prestigeKeys = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<double?> lastKnownLat = const Value.absent(),
                Value<double?> lastKnownLng = const Value.absent(),
                Value<int> lastSyncTimestamp = const Value.absent(),
                Value<int> monotonicUptime = const Value.absent(),
                Value<int> worldSeed = const Value.absent(),
                Value<int> bootCount = const Value.absent(),
                Value<int> wallAtSync = const Value.absent(),
                Value<int> tamperStrikes = const Value.absent(),
                Value<int> blueprints = const Value.absent(),
                Value<int> liquidations = const Value.absent(),
                Value<double> lifetimeCredits = const Value.absent(),
                Value<int> lastEventDay = const Value.absent(),
                Value<double> threatHeat = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<double> energy = const Value.absent(),
              }) => PlayerStateCompanion(
                id: id,
                credits: credits,
                materials: materials,
                intel: intel,
                prestigeKeys: prestigeKeys,
                level: level,
                xp: xp,
                lastKnownLat: lastKnownLat,
                lastKnownLng: lastKnownLng,
                lastSyncTimestamp: lastSyncTimestamp,
                monotonicUptime: monotonicUptime,
                worldSeed: worldSeed,
                bootCount: bootCount,
                wallAtSync: wallAtSync,
                tamperStrikes: tamperStrikes,
                blueprints: blueprints,
                liquidations: liquidations,
                lifetimeCredits: lifetimeCredits,
                lastEventDay: lastEventDay,
                threatHeat: threatHeat,
                createdAt: createdAt,
                settingsJson: settingsJson,
                energy: energy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> credits = const Value.absent(),
                Value<double> materials = const Value.absent(),
                Value<double> intel = const Value.absent(),
                Value<int> prestigeKeys = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<double?> lastKnownLat = const Value.absent(),
                Value<double?> lastKnownLng = const Value.absent(),
                required int lastSyncTimestamp,
                required int monotonicUptime,
                required int worldSeed,
                Value<int> bootCount = const Value.absent(),
                Value<int> wallAtSync = const Value.absent(),
                Value<int> tamperStrikes = const Value.absent(),
                Value<int> blueprints = const Value.absent(),
                Value<int> liquidations = const Value.absent(),
                Value<double> lifetimeCredits = const Value.absent(),
                Value<int> lastEventDay = const Value.absent(),
                Value<double> threatHeat = const Value.absent(),
                required int createdAt,
                Value<String> settingsJson = const Value.absent(),
                Value<double> energy = const Value.absent(),
              }) => PlayerStateCompanion.insert(
                id: id,
                credits: credits,
                materials: materials,
                intel: intel,
                prestigeKeys: prestigeKeys,
                level: level,
                xp: xp,
                lastKnownLat: lastKnownLat,
                lastKnownLng: lastKnownLng,
                lastSyncTimestamp: lastSyncTimestamp,
                monotonicUptime: monotonicUptime,
                worldSeed: worldSeed,
                bootCount: bootCount,
                wallAtSync: wallAtSync,
                tamperStrikes: tamperStrikes,
                blueprints: blueprints,
                liquidations: liquidations,
                lifetimeCredits: lifetimeCredits,
                lastEventDay: lastEventDay,
                threatHeat: threatHeat,
                createdAt: createdAt,
                settingsJson: settingsJson,
                energy: energy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlayerState, PlayerRow>(table),
                  BaseReferences<_$HexDatabase, PlayerState, PlayerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlayerStateProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      PlayerState,
      PlayerRow,
      $PlayerStateFilterComposer,
      $PlayerStateOrderingComposer,
      $PlayerStateAnnotationComposer,
      $PlayerStateCreateCompanionBuilder,
      $PlayerStateUpdateCompanionBuilder,
      (PlayerRow, BaseReferences<_$HexDatabase, PlayerState, PlayerRow>),
      PlayerRow,
      PrefetchHooks Function()
    >;
typedef $FactionsCreateCompanionBuilder = FactionsCompanion Function({
  required String factionId,
  required int archetype,
  required double aggression,
  Value<int> nemesisRank,
  Value<int> wins,
  Value<int> losses,
  Value<int> rowid,
});
typedef $FactionsUpdateCompanionBuilder = FactionsCompanion Function({
  Value<String> factionId,
  Value<int> archetype,
  Value<double> aggression,
  Value<int> nemesisRank,
  Value<int> wins,
  Value<int> losses,
  Value<int> rowid,
});

class $FactionsFilterComposer extends Composer<_$HexDatabase, Factions> {
  $FactionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get factionId => $composableBuilder(
    column: $table.factionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nemesisRank => $composableBuilder(
    column: $table.nemesisRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wins => $composableBuilder(
    column: $table.wins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get losses => $composableBuilder(
    column: $table.losses,
    builder: (column) => ColumnFilters(column),
  );
}

class $FactionsOrderingComposer extends Composer<_$HexDatabase, Factions> {
  $FactionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get factionId => $composableBuilder(
    column: $table.factionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nemesisRank => $composableBuilder(
    column: $table.nemesisRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wins => $composableBuilder(
    column: $table.wins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get losses => $composableBuilder(
    column: $table.losses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FactionsAnnotationComposer extends Composer<_$HexDatabase, Factions> {
  $FactionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get factionId =>
      $composableBuilder(column: $table.factionId, builder: (column) => column);

  GeneratedColumn<int> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<double> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nemesisRank => $composableBuilder(
    column: $table.nemesisRank,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<int> get losses =>
      $composableBuilder(column: $table.losses, builder: (column) => column);
}

class $FactionsTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          Factions,
          FactionRow,
          $FactionsFilterComposer,
          $FactionsOrderingComposer,
          $FactionsAnnotationComposer,
          $FactionsCreateCompanionBuilder,
          $FactionsUpdateCompanionBuilder,
          (FactionRow, BaseReferences<_$HexDatabase, Factions, FactionRow>),
          FactionRow,
          PrefetchHooks Function()
        > {
  $FactionsTableManager(_$HexDatabase db, Factions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FactionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FactionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FactionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> factionId = const Value.absent(),
                Value<int> archetype = const Value.absent(),
                Value<double> aggression = const Value.absent(),
                Value<int> nemesisRank = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> losses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactionsCompanion(
                factionId: factionId,
                archetype: archetype,
                aggression: aggression,
                nemesisRank: nemesisRank,
                wins: wins,
                losses: losses,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String factionId,
                required int archetype,
                required double aggression,
                Value<int> nemesisRank = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> losses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactionsCompanion.insert(
                factionId: factionId,
                archetype: archetype,
                aggression: aggression,
                nemesisRank: nemesisRank,
                wins: wins,
                losses: losses,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Factions, FactionRow>(table),
                  BaseReferences<_$HexDatabase, Factions, FactionRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FactionsProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      Factions,
      FactionRow,
      $FactionsFilterComposer,
      $FactionsOrderingComposer,
      $FactionsAnnotationComposer,
      $FactionsCreateCompanionBuilder,
      $FactionsUpdateCompanionBuilder,
      (FactionRow, BaseReferences<_$HexDatabase, Factions, FactionRow>),
      FactionRow,
      PrefetchHooks Function()
    >;
typedef $VaultUpgradesCreateCompanionBuilder = VaultUpgradesCompanion Function({
  required String upgradeId,
  Value<int> rank,
  Value<int> rowid,
});
typedef $VaultUpgradesUpdateCompanionBuilder = VaultUpgradesCompanion Function({
  Value<String> upgradeId,
  Value<int> rank,
  Value<int> rowid,
});

class $VaultUpgradesFilterComposer
    extends Composer<_$HexDatabase, VaultUpgrades> {
  $VaultUpgradesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );
}

class $VaultUpgradesOrderingComposer
    extends Composer<_$HexDatabase, VaultUpgrades> {
  $VaultUpgradesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VaultUpgradesAnnotationComposer
    extends Composer<_$HexDatabase, VaultUpgrades> {
  $VaultUpgradesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get upgradeId =>
      $composableBuilder(column: $table.upgradeId, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);
}

class $VaultUpgradesTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          VaultUpgrades,
          VaultUpgradeRow,
          $VaultUpgradesFilterComposer,
          $VaultUpgradesOrderingComposer,
          $VaultUpgradesAnnotationComposer,
          $VaultUpgradesCreateCompanionBuilder,
          $VaultUpgradesUpdateCompanionBuilder,
          (
            VaultUpgradeRow,
            BaseReferences<_$HexDatabase, VaultUpgrades, VaultUpgradeRow>,
          ),
          VaultUpgradeRow,
          PrefetchHooks Function()
        > {
  $VaultUpgradesTableManager(_$HexDatabase db, VaultUpgrades table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VaultUpgradesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VaultUpgradesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VaultUpgradesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> upgradeId = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultUpgradesCompanion(
                upgradeId: upgradeId,
                rank: rank,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String upgradeId,
                Value<int> rank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultUpgradesCompanion.insert(
                upgradeId: upgradeId,
                rank: rank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<VaultUpgrades, VaultUpgradeRow>(table),
                  BaseReferences<_$HexDatabase, VaultUpgrades, VaultUpgradeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $VaultUpgradesProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      VaultUpgrades,
      VaultUpgradeRow,
      $VaultUpgradesFilterComposer,
      $VaultUpgradesOrderingComposer,
      $VaultUpgradesAnnotationComposer,
      $VaultUpgradesCreateCompanionBuilder,
      $VaultUpgradesUpdateCompanionBuilder,
      (
        VaultUpgradeRow,
        BaseReferences<_$HexDatabase, VaultUpgrades, VaultUpgradeRow>,
      ),
      VaultUpgradeRow,
      PrefetchHooks Function()
    >;
typedef $StreetPerksCreateCompanionBuilder = StreetPerksCompanion Function({
  required String perkId,
  Value<int> rank,
  Value<int> rowid,
});
typedef $StreetPerksUpdateCompanionBuilder = StreetPerksCompanion Function({
  Value<String> perkId,
  Value<int> rank,
  Value<int> rowid,
});

class $StreetPerksFilterComposer extends Composer<_$HexDatabase, StreetPerks> {
  $StreetPerksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );
}

class $StreetPerksOrderingComposer
    extends Composer<_$HexDatabase, StreetPerks> {
  $StreetPerksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StreetPerksAnnotationComposer
    extends Composer<_$HexDatabase, StreetPerks> {
  $StreetPerksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get perkId =>
      $composableBuilder(column: $table.perkId, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);
}

class $StreetPerksTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          StreetPerks,
          StreetPerkRow,
          $StreetPerksFilterComposer,
          $StreetPerksOrderingComposer,
          $StreetPerksAnnotationComposer,
          $StreetPerksCreateCompanionBuilder,
          $StreetPerksUpdateCompanionBuilder,
          (
            StreetPerkRow,
            BaseReferences<_$HexDatabase, StreetPerks, StreetPerkRow>,
          ),
          StreetPerkRow,
          PrefetchHooks Function()
        > {
  $StreetPerksTableManager(_$HexDatabase db, StreetPerks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StreetPerksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StreetPerksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StreetPerksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> perkId = const Value.absent(),
            Value<int> rank = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StreetPerksCompanion(perkId: perkId, rank: rank, rowid: rowid),
          createCompanionCallback:
              ({
                required String perkId,
                Value<int> rank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreetPerksCompanion.insert(
                perkId: perkId,
                rank: rank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<StreetPerks, StreetPerkRow>(table),
                  BaseReferences<_$HexDatabase, StreetPerks, StreetPerkRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $StreetPerksProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      StreetPerks,
      StreetPerkRow,
      $StreetPerksFilterComposer,
      $StreetPerksOrderingComposer,
      $StreetPerksAnnotationComposer,
      $StreetPerksCreateCompanionBuilder,
      $StreetPerksUpdateCompanionBuilder,
      (
        StreetPerkRow,
        BaseReferences<_$HexDatabase, StreetPerks, StreetPerkRow>,
      ),
      StreetPerkRow,
      PrefetchHooks Function()
    >;
typedef $JobProgressCreateCompanionBuilder = JobProgressCompanion Function({
  required String jobId,
  Value<int> runs,
  Value<int> rowid,
});
typedef $JobProgressUpdateCompanionBuilder = JobProgressCompanion Function({
  Value<String> jobId,
  Value<int> runs,
  Value<int> rowid,
});

class $JobProgressFilterComposer extends Composer<_$HexDatabase, JobProgress> {
  $JobProgressFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnFilters(column),
  );
}

class $JobProgressOrderingComposer
    extends Composer<_$HexDatabase, JobProgress> {
  $JobProgressOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $JobProgressAnnotationComposer
    extends Composer<_$HexDatabase, JobProgress> {
  $JobProgressAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<int> get runs =>
      $composableBuilder(column: $table.runs, builder: (column) => column);
}

class $JobProgressTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          JobProgress,
          JobProgressRow,
          $JobProgressFilterComposer,
          $JobProgressOrderingComposer,
          $JobProgressAnnotationComposer,
          $JobProgressCreateCompanionBuilder,
          $JobProgressUpdateCompanionBuilder,
          (
            JobProgressRow,
            BaseReferences<_$HexDatabase, JobProgress, JobProgressRow>,
          ),
          JobProgressRow,
          PrefetchHooks Function()
        > {
  $JobProgressTableManager(_$HexDatabase db, JobProgress table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JobProgressFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JobProgressOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $JobProgressAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> jobId = const Value.absent(),
            Value<int> runs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => JobProgressCompanion(jobId: jobId, runs: runs, rowid: rowid),
          createCompanionCallback:
              ({
                required String jobId,
                Value<int> runs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobProgressCompanion.insert(
                jobId: jobId,
                runs: runs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<JobProgress, JobProgressRow>(table),
                  BaseReferences<_$HexDatabase, JobProgress, JobProgressRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $JobProgressProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      JobProgress,
      JobProgressRow,
      $JobProgressFilterComposer,
      $JobProgressOrderingComposer,
      $JobProgressAnnotationComposer,
      $JobProgressCreateCompanionBuilder,
      $JobProgressUpdateCompanionBuilder,
      (
        JobProgressRow,
        BaseReferences<_$HexDatabase, JobProgress, JobProgressRow>,
      ),
      JobProgressRow,
      PrefetchHooks Function()
    >;
typedef $EventLogCreateCompanionBuilder = EventLogCompanion Function({
  Value<int> id,
  required int ts,
  required String kind,
  required String message,
});
typedef $EventLogUpdateCompanionBuilder = EventLogCompanion Function({
  Value<int> id,
  Value<int> ts,
  Value<String> kind,
  Value<String> message,
});

class $EventLogFilterComposer extends Composer<_$HexDatabase, EventLog> {
  $EventLogFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );
}

class $EventLogOrderingComposer extends Composer<_$HexDatabase, EventLog> {
  $EventLogOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );
}

class $EventLogAnnotationComposer extends Composer<_$HexDatabase, EventLog> {
  $EventLogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);
}

class $EventLogTableManager
    extends
        RootTableManager<
          _$HexDatabase,
          EventLog,
          LogRow,
          $EventLogFilterComposer,
          $EventLogOrderingComposer,
          $EventLogAnnotationComposer,
          $EventLogCreateCompanionBuilder,
          $EventLogUpdateCompanionBuilder,
          (LogRow, BaseReferences<_$HexDatabase, EventLog, LogRow>),
          LogRow,
          PrefetchHooks Function()
        > {
  $EventLogTableManager(_$HexDatabase db, EventLog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EventLogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EventLogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EventLogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ts = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> message = const Value.absent(),
          }) => EventLogCompanion(id: id, ts: ts, kind: kind, message: message),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ts,
                required String kind,
                required String message,
              }) => EventLogCompanion.insert(
                id: id,
                ts: ts,
                kind: kind,
                message: message,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<EventLog, LogRow>(table),
                  BaseReferences<_$HexDatabase, EventLog, LogRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $EventLogProcessedTableManager =
    ProcessedTableManager<
      _$HexDatabase,
      EventLog,
      LogRow,
      $EventLogFilterComposer,
      $EventLogOrderingComposer,
      $EventLogAnnotationComposer,
      $EventLogCreateCompanionBuilder,
      $EventLogUpdateCompanionBuilder,
      (LogRow, BaseReferences<_$HexDatabase, EventLog, LogRow>),
      LogRow,
      PrefetchHooks Function()
    >;

class $HexDatabaseManager {
  final _$HexDatabase _db;
  $HexDatabaseManager(this._db);
  $HexNodesTableManager get hexNodes =>
      $HexNodesTableManager(_db, _db.hexNodes);
  $InstalledModulesTableManager get installedModules =>
      $InstalledModulesTableManager(_db, _db.installedModules);
  $ModuleStashTableManager get moduleStash =>
      $ModuleStashTableManager(_db, _db.moduleStash);
  $ActiveWorldEventsTableManager get activeWorldEvents =>
      $ActiveWorldEventsTableManager(_db, _db.activeWorldEvents);
  $PlayerStateTableManager get playerState =>
      $PlayerStateTableManager(_db, _db.playerState);
  $FactionsTableManager get factions =>
      $FactionsTableManager(_db, _db.factions);
  $VaultUpgradesTableManager get vaultUpgrades =>
      $VaultUpgradesTableManager(_db, _db.vaultUpgrades);
  $StreetPerksTableManager get streetPerks =>
      $StreetPerksTableManager(_db, _db.streetPerks);
  $JobProgressTableManager get jobProgress =>
      $JobProgressTableManager(_db, _db.jobProgress);
  $EventLogTableManager get eventLog =>
      $EventLogTableManager(_db, _db.eventLog);
}
