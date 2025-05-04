import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/converter_screen.dart';
import '../providers/conversion_database_helper.dart';

part 'converter_provider.g.dart';

class ConverterState {
  final UnitType unitType;
  final String fromUnit;
  final String toUnit;
  final String inputValue;
  final String result;
  final List<ConversionRecord> history;
  final bool loading;

  ConverterState({
    this.unitType = UnitType.length,
    required this.fromUnit,
    required this.toUnit,
    this.inputValue = '',
    this.result = '',
    this.history = const [],
    this.loading = false,
  });

  ConverterState copyWith({
    UnitType? unitType,
    String? fromUnit,
    String? toUnit,
    String? inputValue,
    String? result,
    List<ConversionRecord>? history,
    bool? loading,
  }) {
    return ConverterState(
      unitType: unitType ?? this.unitType,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      inputValue: inputValue ?? this.inputValue,
      result: result ?? this.result,
      history: history ?? this.history,
      loading: loading ?? this.loading,
    );
  }
}

@Riverpod(keepAlive: true)
class Converter extends _$Converter {
  @override
  ConverterState build() {
    // Always load history from DB when provider is created
    Future.microtask(() => loadHistory());
    return ConverterState(
      fromUnit: lengthUnits[0],
      toUnit: lengthUnits[1],
      loading: true,
    );
  }

  Future<void> loadHistory() async {
    try {
      state = state.copyWith(loading: true);
      final history =
          await ConversionDatabaseHelper.instance.getAllConversions();
      state = state.copyWith(history: history, loading: false);
    } catch (e, st) {
      print('Error loading conversion history: $e\n$st');
      state = state.copyWith(loading: false);
    }
  }

  void setUnitType(UnitType type) {
    final units = unitsForType(type);
    state = state.copyWith(
      unitType: type,
      fromUnit: units.isNotEmpty ? units[0] : '',
      toUnit: units.length > 1 ? units[1] : (units.isNotEmpty ? units[0] : ''),
      inputValue: '',
      result: '',
    );
  }

  void setFromUnit(String unit) {
    state = state.copyWith(fromUnit: unit);
  }

  void setToUnit(String unit) {
    state = state.copyWith(toUnit: unit);
  }

  void swapUnits() {
    state = state.copyWith(fromUnit: state.toUnit, toUnit: state.fromUnit);
  }

  void setInputValue(String value) {
    state = state.copyWith(inputValue: value);
  }

  Future<void> convert() async {
    if (state.inputValue.isEmpty) return;
    double? value = double.tryParse(state.inputValue);
    if (value == null) {
      state = state.copyWith(result: 'Invalid input');
      return;
    }
    double resultValue;
    try {
      switch (state.unitType) {
        case UnitType.length:
          resultValue = UnitConverter.convertLength(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.weight:
          resultValue = UnitConverter.convertWeight(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.temperature:
          resultValue = UnitConverter.convertTemperature(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.area:
          resultValue = UnitConverter.convertArea(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.volume:
          resultValue = UnitConverter.convertVolume(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.speed:
          resultValue = UnitConverter.convertSpeed(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
        case UnitType.time:
          resultValue = UnitConverter.convertTime(
            value,
            state.fromUnit,
            state.toUnit,
          );
          break;
      }
      final record = ConversionRecord(
        fromUnit: state.fromUnit,
        toUnit: state.toUnit,
        inputValue: state.inputValue,
        result: resultValue.toStringAsPrecision(10),
        unitType: unitTypeNames[state.unitType]!,
        timestamp: DateTime.now(),
      );
      await ConversionDatabaseHelper.instance.insertConversion(record);
      await loadHistory();
      state = state.copyWith(result: record.result);
    } catch (e, st) {
      print('Error during conversion: $e\n$st');
      state = state.copyWith(result: 'Error');
    }
  }

  Future<void> clearHistory() async {
    try {
      await ConversionDatabaseHelper.instance.clearConversionHistory();
      await loadHistory();
    } catch (e, st) {
      print('Error clearing conversion history: $e\n$st');
    }
  }

  List<String> unitsForType(UnitType type) {
    switch (type) {
      case UnitType.length:
        return lengthUnits;
      case UnitType.weight:
        return weightUnits;
      case UnitType.temperature:
        return temperatureUnits;
      case UnitType.area:
        return areaUnits;
      case UnitType.volume:
        return volumeUnits;
      case UnitType.speed:
        return speedUnits;
      case UnitType.time:
        return timeUnits;
    }
  }
}
