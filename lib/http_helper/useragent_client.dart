import 'package:http/http.dart';

class UserAgentClient extends BaseClient {
  UserAgentClient(this.userAgent, this._inner);

  final String userAgent;
  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}
