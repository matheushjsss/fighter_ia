import 'dart:convert';

import 'package:http/http.dart';

/// Base da API do Laravel.
/// 10.0.2.2 é o localhost do host quando rodando no emulador Android.
const String apiBaseUrl = 'http://10.0.2.2:8000/api';

/// GET + decode JSON resiliente. O servidor embutido do PHP (php artisan
/// serve) é single-thread e pode falhar em respostas grandes de duas formas:
///   - entregar o corpo com bytes faltando (JSON quebrado) -> FormatException
///   - fechar a conexão antes de terminar o envio -> ClientException
///     ("Connection closed while receiving data")
/// Em ambos os casos a requisição é refeita automaticamente, com um pequeno
/// backoff progressivo. Retorna o JSON decodificado (List ou Map).
Future<dynamic> getJsonResilient(Client client, Uri url) async {
  const maxAttempts = 5;
  Object? lastError;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final response = await client.get(
        url,
        headers: {'Connection': 'close', 'Accept': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
      // Decodifica os bytes como UTF-8 (o pacote http assume latin1 quando
      // o Content-Type não traz charset, corrompendo acentos).
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      return json.decode(body);
    } on ClientException catch (e) {
      // Conexão fechada/cortada durante a leitura — tenta de novo.
      lastError = e;
    } on FormatException catch (e) {
      // JSON inválido/corrompido — tenta de novo.
      lastError = e;
    }
    if (attempt < maxAttempts) {
      await Future.delayed(Duration(milliseconds: 200 * attempt));
    }
  }
  throw Exception(
    'Não foi possível carregar os dados após $maxAttempts tentativas. '
    'Verifique se o servidor (php artisan serve) está rodando. '
    'Último erro: $lastError',
  );
}
