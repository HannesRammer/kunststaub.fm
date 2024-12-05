import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'marquee_artist_names.dart';

class SocialMediaLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialMediaIcon('assets/images/sc.png', 'soundcloud://users/kunststaubfm', 'https://soundcloud.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/tg.png', 'tg://resolve?domain=kunststaubkiosk', 'https://t.me/kunststaubkiosk'),
              _buildSocialMediaIcon('assets/images/fb.png', 'fb://page/kunststaubfm', 'https://facebook.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/ig.png', 'instagram://user?username=kunststaubfm', 'https://instagram.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/radio-de.png', 'https://radio.de/s/kunststaubfm', 'https://radio.de/s/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/pp.png', 'https://www.paypal.com/donate/?hosted_button_id=XF2WDPBJEJSHU', 'https://www.paypal.com/donate/?hosted_button_id=XF2WDPBJEJSHU'),
            ],
          ),
          SizedBox(height: 10),
          Container(
            constraints: BoxConstraints(maxHeight: 25),
            child: Marquee(
              text: MarqueeArtistNames.artistNames,
              style: TextStyle(color: Colors.white),
              scrollAxis: Axis.horizontal,
              blankSpace: 20.0,
              velocity: 50.0,
              pauseAfterRound: Duration(seconds: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(String assetPath, String appUrl, String webUrl) {
    return GestureDetector(
      onTap: () => _launchURL(appUrl, webUrl),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          assetPath,
          height: 40,
          width: 40,
        ),
      ),
    );
  }

  void _launchURL(String appUrl, String webUrl) async {
    final Uri appUri = Uri.parse(appUrl);
    final Uri webUri = Uri.parse(webUrl);
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch $appUrl or fallback $webUrl');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
