import 'package:flutter/material.dart';
import 'package:payutc/src/membership.conf.dart';
import 'package:payutc/src/models/ginger_user_infos.dart';
import 'package:payutc/src/services/app.dart';
import 'package:payutc/src/ui/style/color.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MemberShipScreen extends StatefulWidget {
  final GingerUserInfos user;

  const MemberShipScreen({super.key, required this.user});

  @override
  State<MemberShipScreen> createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends State<MemberShipScreen> {
  bool _loading = false;
  final List<String> validTypes = ["etu", "escom"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Vérification de la cotisation..."),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotiser'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.account_balance_wallet, size: 100),
          const SizedBox(height: 20),
          Text(
            "Tu n'es pas encore cotisant !",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: AppColors.orange),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            "Mais pourquoi cotiser ?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Cotiser te permet de payer au PICasso et profiter pleinement de payUTC, de faire partie des associations, de profiter des tarifs préférentiels et de participer aux évènements du BDE UTC !\n"
            "Tu peux aussi bénéficier de réductions dans les commerces partenaires.",
          ),
          const Text("N'hésite plus et cotise dès maintenant."),
          const SizedBox(height: 20),
          if (widget.user.type == "pers") ...[
            const Text(
                "En tant que personnel, la cotisation est de droit, il faut juste demander au BDE !"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //email
                launchUrlString("mailto:bde@assos.utc.fr"
                    "?subject=Demande de cotisation"
                    "&body=Bonjour,\n\n je suis ${widget.user.prenom} ${widget.user.nom} et je souhaite cotiser en tant que personnel UTC. \n(cas: ${widget.user.login}) \n\nMerci ! \nBonne journée !");
              },
              child: const Text("Demander au BDE"),
            ),
          ] else if (validTypes.contains(widget.user.type)) ...[
            ElevatedButton(
              onPressed: () async {
                if ((AppService.instance.userWallet?.credit ?? 0) <
                    membershipPrice) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                        "Tu n'as pas assez d'argent sur ton compte PayUTC !"),
                    action: SnackBarAction(
                      label: "Recharger",
                      onPressed: () async {
                        num amount = membershipPrice -
                            (AppService.instance.userWallet?.credit ?? 0);
                        amount = (amount / 1000).round() * 1000;
                        Navigator.pop(context, amount);
                      },
                    ),
                  ));
                  return;
                }
                _loading = true;
                setState(() {});
                //user have enough money
                final result = await AppService.instance.payMembership();
                if (result != null) {
                  //check cotiz on ginger
                  final checkResult =
                      await AppService.instance.checkMembership();
                  if (!mounted) return;
                  if (checkResult) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(result['message'] ?? "Cotisation réussie !"),
                    ));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['message'] ?? "Erreur inconnue"),
                    ));
                    _loading = false;
                    setState(() {});
                  }
                  return;
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Erreur inconnue"),
                ));
                _loading = false;
                setState(() {});
              },
              child: const Text("Cotiser (${membershipPrice ~/ 100}€)"),
            ),
            Text(
              "Pour pouvoir cotiser, tu dois avoir ${membershipPrice ~/ 100}€ sur ton compte PayUTC !",
              style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              "Oups !",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Text(
              "Tu n'es pas éligible à la cotisation en ligne, passe au bde pour cotiser.",
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}
