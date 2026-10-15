import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/share_image.dart';
import '../widgets/carbon_share_card.dart';

/// Shows a preview of the day's carbon-impact card and shares it as a PNG
/// through the OS share sheet. Note what this *doesn't* do: there's no
/// Meta/TikTok SDK integration here, so it can't post automatically or
/// pick a destination for you — it hands the image to the system share
/// sheet, same as sharing a photo from the camera roll, and Instagram,
/// Facebook, or TikTok show up there if installed.
class CarbonShareSheet extends StatefulWidget {
  final String memberName;
  final double totalKg;
  final Map<String, double> breakdown;
  final DateTime date;

  const CarbonShareSheet({
    super.key,
    required this.memberName,
    required this.totalKg,
    required this.breakdown,
    required this.date,
  });

  @override
  State<CarbonShareSheet> createState() => _CarbonShareSheetState();
}

class _CarbonShareSheetState extends State<CarbonShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share your impact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Opens your phone's share sheet — pick Instagram, Facebook, "
              "or TikTok if they're installed.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 220,
              child: RepaintBoundary(
                key: _cardKey,
                child: CarbonShareCard(
                  memberName: widget.memberName,
                  totalKg: widget.totalKg,
                  breakdown: widget.breakdown,
                  date: widget.date,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(_sharing ? 'Preparing…' : 'Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final file = await captureRepaintBoundary(
        _cardKey,
        'carbon_impact_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'I saved ${widget.totalKg.toStringAsFixed(1)} kg of CO2e today 🌍 '
            '#CarbonFootprint #ClimateAction',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}
