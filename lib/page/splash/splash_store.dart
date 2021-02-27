/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:math';

import 'package:mobx/mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/onezero_response.dart';
import 'package:pixez/network/onezero_client.dart';

part 'splash_store.g.dart';

class SplashStore = _SplashStoreBase with _$SplashStore;

abstract class _SplashStoreBase with Store {
  final OnezeroClient onezeroClient;
  final String OK_TEXT = '♪^∀^●)ノ';
  List<String> _hardCoreArray = ["210.140.92.143", "210.140.92.145"];
  @observable
  String helloWord = "= w =";
  String host = ImageHost;
  @observable
  OnezeroResponse onezeroResponse;

  _SplashStoreBase(this.onezeroClient);

  @action
  hello() async {
    maybeFetch();
    Future.delayed(Duration(seconds: 2), () {
      helloWord = ' w(ﾟДﾟ)w ';
    });
  }

  maybeFetch() {
    if (userSetting.disableBypassSni || helloWord == OK_TEXT) return;
    fetch();
  }

  @action
  fetch() async {
    if (helloWord == OK_TEXT) return;
    try {
      onezeroClient.httpClient.lock();
      onezeroClient.queryDns(ImageHost).then((value) {
        value.answer.sort((l, r) => r.ttl.compareTo(l.ttl));
        final host = value.answer.first.data;
        LPrinter.d(host);
        if (host != null && host.isNotEmpty && int.tryParse(host[0]) != null)
          this.host = host;
      }).catchError((e) {
        this.host = _hardCoreArray[Random().nextInt(_hardCoreArray.length)];
        helloWord = OK_TEXT;
      });
    } catch (e) {
      this.host = _hardCoreArray[Random().nextInt(_hardCoreArray.length)];
      helloWord = OK_TEXT;
    } finally {
      onezeroClient.httpClient.unlock();
    }
    try {
      fetcher.notify(this.host);
    } catch (e) {}
  }

  setHost(String value) {
    host = value;
    if (host != ImageHost) {
      try {
        fetcher.notify(this.host);
      } catch (e) {}
    } else {
      helloWord = ' w(ﾟДﾟ)w ';
      maybeFetch();
    }
  }
}
