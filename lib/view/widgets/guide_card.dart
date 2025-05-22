import 'package:flutter/material.dart';
import '../../core/models/guide.dart';
import '../../utils/Router/const_router_names.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home_screen_widgets/home_screen.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;

  const GuideCard({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(guideDetailsRoute, arguments: guide),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF2196F3).withOpacity(0.15),
                  child: const Icon(Icons.person, size: 32, color: Color(0xFF2196F3)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                guide.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      guide.city,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      guide.mobile,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Color(0xFF2196F3), size: 18),
                    tooltip: 'Call',
                    onPressed: () async {
                      final url = Uri.parse('tel:${guide.mobile}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),
              if (guide.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: TourismColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      guide.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: TourismColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 