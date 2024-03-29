import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:payutc/generated/l10n.dart';
import 'package:payutc/src/models/user.dart';
import 'package:payutc/src/ui/screen/transfert_select_amount.dart';
import 'package:payutc/src/ui/style/color.dart';

class PushUrlNavigationDelegate extends NavigationDelegate {
  PushUrlNavigationDelegate()
      : super(onNavigationRequest: (navigationState) async {
          launchUrlString(navigationState.url,
              mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        });
}

void showWebView(BuildContext context, String fileUrl, String name) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (ctx) {
        WebViewController controller = WebViewController();
        controller.setNavigationDelegate(PushUrlNavigationDelegate());
        return Scaffold(
          appBar: AppBar(
            title: Text(name),
          ),
          body: WebViewWidget(
            controller: WebViewController(),
          ),
        );
      },
    ),
  );
}

void showUserCard(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (_) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.white),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Translate.of(context).userFound,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    child: Text(user.maj),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "@${user.subName}",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (builder) => SelectTransfertAmountScreen(
                        target: user,
                      ),
                    ),
                  ).then((value) {
                    if ((value ?? false) && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                },
                child: Text(Translate.of(context).beginTransfert),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(Translate.of(context).annuler),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget btnAccount(String text, GestureTapCallback onTap) => Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color: AppColors.scaffoldDark,
          borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
