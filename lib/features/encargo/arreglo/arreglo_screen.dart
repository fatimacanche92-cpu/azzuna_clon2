import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/models/arreglo_model.dart';
import 'package:flutter_app/core/services/encargo_service.dart';

class ArregloScreen extends ConsumerStatefulWidget {
  const ArregloScreen({super.key});

  @override
  ConsumerState<ArregloScreen> createState() => _ArregloScreenState();
}

class _ArregloScreenState extends ConsumerState<ArregloScreen> {
  final _formKey = GlobalKey<FormState>();
  ArregloSize? _size;
  final _colors = <String>{};
  String? _selectedFlowerType;

  // Mapa de flores y sus colores
  final Map<String, List<String>> _flowerColorMap = {
    'Rosas': ['Rojo', 'Rosa', 'Blanco', 'Amarillo', 'Naranja'],
    'Girasoles': ['Amarillo', 'Naranja', 'Marrón'],
    'Tulipanes': ['Morado', 'Rosa', 'Blanco', 'Rojo', 'Amarillo', 'Naranja'],
    'Lirios': ['Blanco', 'Naranja', 'Rosa', 'Amarillo', 'Rojo'],
  };

  List<String> get _availableColors =>
      _flowerColorMap[_selectedFlowerType] ?? [];

  @override
  void initState() {
    super.initState();
    final existingArreglo = ref.read(encargoServiceProvider).arreglo;
    if (existingArreglo != null) {
      _size = existingArreglo.size;
      _selectedFlowerType = existingArreglo.flowerType;
      // Only add colors that are valid for the selected flower type
      if (_selectedFlowerType != null &&
          _flowerColorMap.containsKey(_selectedFlowerType)) {
        _colors.addAll(
          existingArreglo.colors.where((c) => _availableColors.contains(c)),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newArreglo = Arreglo(
        size: _size,
        colors: _colors.toList(),
        flowerType: _selectedFlowerType,
      );
      ref.read(encargoServiceProvider.notifier).updateArreglo(newArreglo);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Arreglo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Size
            Text('Tamaño', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: ArregloSize.values.map((size) {
                return ChoiceChip(
                  label: Text(size.name.toUpperCase()),
                  selected: _size == size,
                  onSelected: (selected) {
                    setState(() => _size = selected ? size : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Flower Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFlowerType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Flor',
                border: OutlineInputBorder(),
              ),
              items: _flowerColorMap.keys.map((String flower) {
                return DropdownMenuItem<String>(
                  value: flower,
                  child: Text(flower),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFlowerType = newValue;
                  // Clear colors when flower type changes
                  _colors.clear();
                });
              },
              validator: (value) =>
                  value == null ? 'Selecciona un tipo de flor' : null,
            ),
            const SizedBox(height: 24),

            // Conditional Colors
            if (_selectedFlowerType != null) ...[
              Text('Colores', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8.0,
                children: _availableColors.map((color) {
                  return FilterChip(
                    label: Text(color),
                    selected: _colors.contains(color),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _colors.add(color);
                        } else {
                          _colors.remove(color);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
