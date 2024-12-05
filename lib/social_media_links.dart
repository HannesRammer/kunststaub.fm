import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

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
              _buildSocialMediaIcon('assets/images/sc.png', 'https://soundcloud.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/tg.png', 'https://t.me/kunststaubkiosk'),
              _buildSocialMediaIcon('assets/images/fb.png', 'https://facebook.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/ig.png', 'https://instagram.com/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/radio-de.png', 'https://radio.de/s/kunststaubfm'),
              _buildSocialMediaIcon('assets/images/pp.png', 'https://www.paypal.com/donate/?hosted_button_id=XF2WDPBJEJSHU'),
            ],
          ),
          SizedBox(height: 10),
          Container(
            constraints: BoxConstraints(maxHeight: 25),
            child: Marquee(
              text: "Aantigen, Aerea Negrot, Alle Beide, Amalaya Kholektive, Amelic, Anna Schreit, Annina b2b Papa K, Balou b2b Meakat, BeatCEPS, Beatronic.Berlin, Bee Lincoln, "
                  "Bella Nour, Benno Hoffmann b2b Luc Halal, Berunth, Besimo, Blunaa, Blunaa b2b Sachenmachen, Bäggy, Calin, Camilla Tarantino, Captain Ahoi, Casimir von Oettingen, cee_ohh, "
                  "Const Cash, Daria Cyber, De:tronique, DerBermes, dinaliks, dinaLiks, Diskokatze, DJ Crémant, DJ Feldweg, DJ Travel, DOERTE, Dreiradfahrt, Edithhhhh & Schmandia, Ej Cana, El Sheik,"
                  " Ele Luz, Elli Altenberger, Fabian Drews, Fabrokoli b2b Johnny Legato, Flo Pirke, Funky Fasching, Fusy, Fynn Forster, Galakta, Goldmarie, Gundi, Hannes Hansen, Heggi, Hesselberg, Hit Beat, "
                  "Hovre, Ich Huste Du Niest, Intaktogene, Jacob, Jacob b2b Jazzil, JaFrei Lafoque, Janna Auzina b2b Robert Mertin, Jazzil, Jimm Koerk, Joe Michels, Johannes Froehlich, Johannes Pan, Jose, Juliska, "
                  "Karo Bube, Kash Only, Kaspar Krug, Katja Meier, Katzengold, KBLZ, Kenny Dolo, Kevin Domanski, Khalil, Kommando Bimberle, Konfettipirat, KonKle, KonkleHD, Ksy, Lang & Saftig, Lasse Lambretta, "
                  "Lavender & The Good Times, Laxberger, LeBautzki, Leftear, Leggings, Leo Mertens, Lexy Core, Liebe Grüße, MADAME, Malte Gutmann, Maltech, Maltitz, MANDY3000, Marco Tegui, Matahari, "
                  "Matija, Mav Stone b2b Alex Knapp, MIC, Mirko Sturm, mobit., Modeplex, Moiselle, Moro, N!ckyrella, Nadida, Naika, Nalah, Natalia Martinovna, NGHTCRWLR, Ninefin9ers, Nora Wolkenstein b2b Paul Pattern, "
                  "Norm.S., Numeraki, O. D. D'Ear, Oelex, Oliver Raumklang, Phat Beat, Philipp Kempnich, RC-1113, Rik Laren, Sachenmachen, Sambaké, Sambaké b2b Jonaku, Schmendrik, Sean Steinfeger, Seebo b2b Simml, Shoemade, Skarabi, Slevin Kelevra, Strasse 95, SuTropos, Tiloton, Timish, To Be Bringts Man, Tomotheus, Ton Funke, Tonkind, Tour Of Soul, Trashpanda, UrbnMowgli, Uschi Underground, V, Vabu, Vanita, Viktor Kampf, Vista Shepherd, Waynette, WIEK b2b Yolanda Frei, Will KNS b2b Cyko, YAK, Yamine Eve, Yannic Bartel, Yannick Weineck, Yao Ofosu b2b Meakat, Yao Ofosu b2b Balou, Yao Ofosu b2b Kyttiara, Zimt & Zucker, 71NU5, Überhaupt & Außerdem",
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

  Widget _buildSocialMediaIcon(String assetPath, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
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
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url'); // Better handling here to avoid crashes.
    }
  }

}