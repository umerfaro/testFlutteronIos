import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/converter_provider.dart';

// Conversion logic utility
class UnitConverter {
  static double convertLength(double value, String from, String to) {
    // Convert to meters first
    final toMeters =
        {
          'Inches': value * 0.0254,
          'Centimeters': value * 0.01,
          'Meters': value,
          'Feet': value * 0.3048,
          'Yards': value * 0.9144,
          'Kilometers': value * 1000,
          'Miles': value * 1609.344,
        }[from]!;
    // Convert from meters to target
    final fromMeters =
        {
          'Inches': toMeters / 0.0254,
          'Centimeters': toMeters / 0.01,
          'Meters': toMeters,
          'Feet': toMeters / 0.3048,
          'Yards': toMeters / 0.9144,
          'Kilometers': toMeters / 1000,
          'Miles': toMeters / 1609.344,
        }[to]!;
    return fromMeters;
  }

  static double convertWeight(double value, String from, String to) {
    // Convert to kilograms first
    final toKg =
        {
          'Grams': value / 1000,
          'Kilograms': value,
          'Pounds': value * 0.45359237,
          'Ounces': value * 0.0283495231,
          'Stones': value * 6.35029318,
        }[from]!;
    // Convert from kilograms to target
    final fromKg =
        {
          'Grams': toKg * 1000,
          'Kilograms': toKg,
          'Pounds': toKg / 0.45359237,
          'Ounces': toKg / 0.0283495231,
          'Stones': toKg / 6.35029318,
        }[to]!;
    return fromKg;
  }

  static double convertTemperature(double value, String from, String to) {
    double celsius;
    // Convert to Celsius
    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }
    // Convert from Celsius to target
    if (to == 'Celsius') {
      return celsius;
    } else if (to == 'Fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else {
      return celsius + 273.15;
    }
  }

  static double convertArea(double value, String from, String to) {
    final toSqMeters =
        {
          'Square meters': value,
          'Square kilometers': value * 1e6,
          'Square centimeters': value * 0.0001,
          'Square millimeters': value * 0.000001,
          'Square miles': value * 2.59e+6,
          'Square yards': value * 0.836127,
          'Square feet': value * 0.092903,
          'Square inches': value * 0.00064516,
          'Hectares': value * 10000,
          'Acres': value * 4046.86,
        }[from]!;
    final fromSqMeters =
        {
          'Square meters': toSqMeters,
          'Square kilometers': toSqMeters / 1e6,
          'Square centimeters': toSqMeters / 0.0001,
          'Square millimeters': toSqMeters / 0.000001,
          'Square miles': toSqMeters / 2.59e+6,
          'Square yards': toSqMeters / 0.836127,
          'Square feet': toSqMeters / 0.092903,
          'Square inches': toSqMeters / 0.00064516,
          'Hectares': toSqMeters / 10000,
          'Acres': toSqMeters / 4046.86,
        }[to]!;
    return fromSqMeters;
  }

  static double convertVolume(double value, String from, String to) {
    final toLiters =
        {
          'Liters': value,
          'Milliliters': value * 0.001,
          'Cubic meters': value * 1000,
          'Cubic centimeters': value * 0.001,
          'Cubic inches': value * 0.0163871,
          'Cubic feet': value * 28.3168,
          'Cubic yards': value * 764.555,
          'Gallons': value * 3.78541,
          'Quarts': value * 0.946353,
          'Pints': value * 0.473176,
          'Cups': value * 0.24,
          'Fluid ounces': value * 0.0295735,
        }[from]!;
    final fromLiters =
        {
          'Liters': toLiters,
          'Milliliters': toLiters / 0.001,
          'Cubic meters': toLiters / 1000,
          'Cubic centimeters': toLiters / 0.001,
          'Cubic inches': toLiters / 0.0163871,
          'Cubic feet': toLiters / 28.3168,
          'Cubic yards': toLiters / 764.555,
          'Gallons': toLiters / 3.78541,
          'Quarts': toLiters / 0.946353,
          'Pints': toLiters / 0.473176,
          'Cups': toLiters / 0.24,
          'Fluid ounces': toLiters / 0.0295735,
        }[to]!;
    return fromLiters;
  }

  static double convertSpeed(double value, String from, String to) {
    final toMps =
        {
          'Meters/sec': value,
          'Km/h': value * 0.277778,
          'Miles/h': value * 0.44704,
          'Feet/sec': value * 0.3048,
          'Knots': value * 0.514444,
        }[from]!;
    final fromMps =
        {
          'Meters/sec': toMps,
          'Km/h': toMps / 0.277778,
          'Miles/h': toMps / 0.44704,
          'Feet/sec': toMps / 0.3048,
          'Knots': toMps / 0.514444,
        }[to]!;
    return fromMps;
  }

  static double convertTime(double value, String from, String to) {
    final toSeconds =
        {
          'Seconds': value,
          'Minutes': value * 60,
          'Hours': value * 3600,
          'Days': value * 86400,
          'Weeks': value * 604800,
          'Months': value * 2.628e+6,
          'Years': value * 3.154e+7,
        }[from]!;
    final fromSeconds =
        {
          'Seconds': toSeconds,
          'Minutes': toSeconds / 60,
          'Hours': toSeconds / 3600,
          'Days': toSeconds / 86400,
          'Weeks': toSeconds / 604800,
          'Months': toSeconds / 2.628e+6,
          'Years': toSeconds / 3.154e+7,
        }[to]!;
    return fromSeconds;
  }
}

enum UnitType { length, weight, temperature, area, volume, speed, time }

const unitTypeNames = {
  UnitType.length: 'Length',
  UnitType.weight: 'Weight',
  UnitType.temperature: 'Temperature',
  UnitType.area: 'Area',
  UnitType.volume: 'Volume',
  UnitType.speed: 'Speed',
  UnitType.time: 'Time',
};

const lengthUnits = [
  'Inches',
  'Centimeters',
  'Meters',
  'Feet',
  'Yards',
  'Kilometers',
  'Miles',
];
const weightUnits = ['Grams', 'Kilograms', 'Pounds', 'Ounces', 'Stones'];
const temperatureUnits = ['Celsius', 'Fahrenheit', 'Kelvin'];
const areaUnits = [
  'Square meters',
  'Square kilometers',
  'Square centimeters',
  'Square millimeters',
  'Square miles',
  'Square yards',
  'Square feet',
  'Square inches',
  'Hectares',
  'Acres',
];
const volumeUnits = [
  'Liters',
  'Milliliters',
  'Cubic meters',
  'Cubic centimeters',
  'Cubic inches',
  'Cubic feet',
  'Cubic yards',
  'Gallons',
  'Quarts',
  'Pints',
  'Cups',
  'Fluid ounces',
];
const speedUnits = ['Meters/sec', 'Km/h', 'Miles/h', 'Feet/sec', 'Knots'];
const timeUnits = [
  'Seconds',
  'Minutes',
  'Hours',
  'Days',
  'Weeks',
  'Months',
  'Years',
];

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  @override
  void initState() {
    super.initState();
    // Load history once when screen is initialized
    Future.microtask(() => ref.read(converterProvider.notifier).loadHistory());
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  IconData _iconForUnitType(UnitType type) {
    switch (type) {
      case UnitType.length:
        return Icons.straighten;
      case UnitType.weight:
        return Icons.fitness_center;
      case UnitType.temperature:
        return Icons.thermostat;
      case UnitType.area:
        return Icons.crop_square;
      case UnitType.volume:
        return Icons.local_drink;
      case UnitType.speed:
        return Icons.speed;
      case UnitType.time:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final currentUnits = notifier.unitsForType(state.unitType);

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Converter'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _handleBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Clear History',
              onPressed: state.history.isEmpty ? null : notifier.clearHistory,
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unit type dropdown with icon
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Unit Type',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UnitType>(
                      value: state.unitType,
                      isExpanded: true,
                      items:
                          UnitType.values.map((type) {
                            return DropdownMenuItem<UnitType>(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(_iconForUnitType(type)),
                                  const SizedBox(width: 8),
                                  Text(unitTypeNames[type]!),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (type) {
                        if (type != null) {
                          notifier.setUnitType(type);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // From/To unit dropdowns with swap button
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.fromUnit,
                            isExpanded: true,
                            items:
                                currentUnits.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                            onChanged: (unit) {
                              if (unit != null) {
                                notifier.setFromUnit(unit);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, size: 32),
                      onPressed: notifier.swapUnits,
                      tooltip: 'Swap units',
                    ),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.toUnit,
                            isExpanded: true,
                            items:
                                currentUnits.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                            onChanged: (unit) {
                              if (unit != null) {
                                notifier.setToUnit(unit);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Input field
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Enter value',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.setInputValue,
                ),
                const SizedBox(height: 24),
                // Convert button
                ElevatedButton.icon(
                  onPressed: notifier.convert,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Convert'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Result
                if (state.result.isNotEmpty)
                  Card(
                    color: Colors.black87,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            '${state.inputValue} ${state.fromUnit} =',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${state.result} ${state.toUnit}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // History
                const Divider(),
                const Text(
                  'Conversion History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (state.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (!state.loading)
                  SizedBox(
                    height: 200,
                    child:
                        state.history.isEmpty
                            ? const Center(child: Text('No history yet.'))
                            : ListView.builder(
                              itemCount: state.history.length,
                              itemBuilder: (context, index) {
                                final record = state.history[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${record.inputValue} ${record.fromUnit} → ${record.toUnit}',
                                    ),
                                    subtitle: Text(
                                      '= ${record.result} (${record.unitType})',
                                    ),
                                    trailing: Text(
                                      DateFormat(
                                        'HH:mm:ss',
                                      ).format(record.timestamp),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
