import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../models/address_model.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    Key? key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  address.name.toLowerCase() == 'casa'
                      ? Icons.home
                      : Icons.work,
                  color: AppColors.redWine,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                    if (value == 'setDefault') onSetDefault();
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                        if (!address.isDefault)
                          const PopupMenuItem<String>(
                            value: 'setDefault',
                            child: Text('Marcar como predeterminada'),
                          ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            Text(
              '${address.city}, ${address.state} ${address.zipCode}',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            if (address.isDefault) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  'Dirección por defecto',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: AppColors.blush,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
