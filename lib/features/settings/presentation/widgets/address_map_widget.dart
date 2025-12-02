import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/address_model.dart';

class AddressMapWidget extends StatelessWidget {
  final AddressModel address;
  final double height;

  const AddressMapWidget({
    Key? key,
    required this.address,
    this.height = 200,
  }) : super(key: key);

  Future<void> _launchMapsUrl() async {
    final String mapsUrl =
        'https://www.google.com/maps/search/${Uri.encodeComponent('${address.fullAddress}, ${address.city}, ${address.state}')}';
    
    try {
      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $mapsUrl');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Stack(
        children: [
          // Placeholder for map
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa de ubicación',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          // Overlay button
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton(
              onPressed: _launchMapsUrl,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.map),
            ),
          ),
        ],
      ),
    );
  }
}
