import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Widget _drawerHeader() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        children: [
          Image.asset(
            "assets/app-icon.png",
            height: 65,
          ),
          const SizedBox(height: 5),
          Text(
            "Auth Signer (mobile app)",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            "@arcange, @sagarkothari88",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _webSite() {
    return ListTile(
      leading: const Icon(Icons.public),
      title: const Text('https://hiveauth.com'),
      onTap: () {
        launchUrl(Uri.parse('https://hiveauth.com/'));
      },
    );
  }

  Widget _blog() {
    return ListTile(
      leading: const Icon(Icons.newspaper),
      title: const Text('HiveAuth Blog'),
      onTap: () {
        launchUrl(Uri.parse('https://peakd.com/@hiveauth'));
      },
    );
  }

  Widget _voteForProposal() {
    return ListTile(
      leading: const Icon(Icons.how_to_vote),
      title: const Text('Vote for HiveAuth proposal'),
      onTap: () {
        launchUrl(
          Uri.parse(
              'https://peakd.com/hive-139531/@arcange/hiveauth-proposal-2'),
        );
      },
    );
  }

  Widget _voteForArcange() {
    return ListTile(
      leading: const Icon(Icons.how_to_vote),
      title: const Text('Vote witness @arcange'),
      onTap: () {
        launchUrl(Uri.parse(
            'https://hivesigner.com/sign/account-witness-vote?witness=sagarkothari88&approve=1'));
      },
    );
  }

  Widget _voteForSagar() {
    return ListTile(
      leading: const Icon(Icons.how_to_vote),
      title: const Text('Vote witness @sagarkothari88'),
      onTap: () {
        launchUrl(Uri.parse(
            'https://hivesigner.com/sign/account-witness-vote?witness=sagarkothari88&approve=1'));
      },
    );
  }

  Widget _joinDiscord() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.discord),
      title: const Text('Join us on Discord'),
      onTap: () {
        launchUrl(Uri.parse('https://discord.gg/Tk5dkAgQPh'));
      },
    );
  }

  Widget _joinGithub() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.github),
      title: const Text('Join us on GitHub'),
      onTap: () {
        launchUrl(Uri.parse('https://github.com/hiveauth'));
      },
    );
  }

  Widget _joinTelegram() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.telegram),
      title: const Text('Join us on Telegram'),
      onTap: () {
        launchUrl(Uri.parse('https://t.me/+vdjU673twHRhNjU8'));
      },
    );
  }

  Widget _followTwitter() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.twitter),
      title: const Text('Follow Us on Twitter'),
      onTap: () {
        launchUrl(Uri.parse('https://twitter.com/hiveauth'));
      },
    );
  }

  Widget _documentation() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.file),
      title: const Text('HiveAuth Documentation'),
      onTap: () {
        launchUrl(Uri.parse('https://docs.hiveauth.com/'));
      },
    );
  }

  //

  @override
  Widget build(BuildContext context) {
    var items = [
      _drawerHeader(),
      _webSite(),
      _blog(),
      _joinDiscord(),
      _joinGithub(),
      _joinTelegram(),
      _followTwitter(),
      _documentation(),
      _voteForProposal(),
      _voteForArcange(),
      _voteForSagar(),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ListTile(
          leading: Image.asset(
            'assets/app-icon.png',
            width: 40,
            height: 40,
          ),
          title: const Text('Auth Signer'),
          subtitle: const Text('About'),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: (c, i) => items[i],
          separatorBuilder: (c, i) => const Divider(),
          itemCount: items.length,
        ),
      ),
    );
  }
}
