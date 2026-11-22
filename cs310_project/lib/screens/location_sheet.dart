import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ledger.dart';
import '../widgets/common.dart';

class LocationMap extends StatelessWidget {
  final ExpenseLocation location;
  final void Function(LatLng)? onTap;
  const LocationMap({super.key, required this.location, this.onTap});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: 250,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(location.latitude, location.longitude),
          initialZoom: 14,
          onTap: (_, point) => onTap?.call(point),
          interactionOptions: InteractionOptions(
            flags: onTap == null ? InteractiveFlag.none : InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'edu.sabanci.group31.splitmate',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(location.latitude, location.longitude),
                width: 46,
                height: 46,
                child: const Icon(
                  Icons.location_pin,
                  size: 46,
                  color: Color(0xff216451),
                ),
              ),
            ],
          ),
          const IgnorePointer(
            child: Align(
              alignment: Alignment.bottomRight,
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class LocationSheet extends StatefulWidget {
  final ExpenseLocation? initial;
  const LocationSheet({super.key, this.initial});
  @override
  State<LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<LocationSheet> {
  late ExpenseLocation location;
  late final TextEditingController name;
  final form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    location =
        widget.initial ?? const ExpenseLocation('Istanbul', 41.0082, 28.9784);
    name = TextEditingController(text: widget.initial?.label ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SheetBody(
    title: 'Where was it?',
    children: [
      const Text(
        'Move the map and tap a place to drop a pin. No GPS permission needed.',
      ),
      const SizedBox(height: 16),
      LocationMap(
        location: location,
        onTap: (p) => setState(
          () => location = ExpenseLocation(name.text, p.latitude, p.longitude),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 16),
      Form(
        key: form,
        child: TextFormField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Place name',
            hintText: 'e.g. Dinner in Karaköy',
          ),
          validator: requiredText,
          maxLength: 70,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Map tiles need internet. You can keep or remove the optional location.',
        style: TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 16),
      PrimaryAction(
        'Use this location',
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(
              context,
              ExpenseLocation(
                name.text.trim(),
                location.latitude,
                location.longitude,
              ),
            );
          }
        },
      ),
    ],
  );
}
