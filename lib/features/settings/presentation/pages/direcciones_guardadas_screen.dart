import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';
import '../../models/address_model.dart';
import '../widgets/button_primary.dart';

class DireccionesGuardadasScreen extends ConsumerWidget {
  const DireccionesGuardadasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Direcciones', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: addressState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressState.addresses.isEmpty
          ? Center(
              child: Text(
                'No tienes direcciones guardadas.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressState.addresses.length,
              itemBuilder: (context, index) {
                final address = addressState.addresses[index];
                return AddressCard(
                  address: address,
                  onEdit: () => _showAddressForm(context, ref, address),
                  onDelete: () => ref
                      .read(addressNotifierProvider.notifier)
                      .deleteAddress(address.id),
                  onSetDefault: () => ref
                      .read(addressNotifierProvider.notifier)
                      .setDefaultAddress(address.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(context, ref, null),
        backgroundColor: AppColors.redWine,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddressForm(
    BuildContext context,
    WidgetRef ref,
    AddressModel? address,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => AddEditAddressForm(
          address: address,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class AddEditAddressForm extends ConsumerStatefulWidget {
  final AddressModel? address;
  final ScrollController scrollController;

  const AddEditAddressForm({
    Key? key,
    this.address,
    required this.scrollController,
  }) : super(key: key);

  @override
  _AddEditAddressFormState createState() => _AddEditAddressFormState();
}

class _AddEditAddressFormState extends ConsumerState<AddEditAddressForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _fullAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _fullAddressController = TextEditingController(
      text: widget.address?.fullAddress ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipController = TextEditingController(text: widget.address?.zipCode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        id: widget.address?.id ?? '', // Service will assign new ID if empty
        name: _nameController.text,
        fullAddress: _fullAddressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        isDefault: widget.address?.isDefault ?? false,
      );

      if (widget.address == null) {
        ref.read(addressNotifierProvider.notifier).addAddress(newAddress);
      } else {
        ref.read(addressNotifierProvider.notifier).updateAddress(newAddress);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.oatMilk,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              isEditing ? 'Editar Dirección' : 'Nueva Dirección',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              labelText: 'Nombre (ej. Casa, Oficina)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fullAddressController,
              labelText: 'Dirección Completa',
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _cityController, labelText: 'Ciudad'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    labelText: 'Estado',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _zipController,
                    labelText: 'Código Postal',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ButtonPrimary(text: 'Guardar Dirección', onPressed: _saveAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value!.isEmpty ? 'Este campo no puede estar vacío' : null,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
