//基於Dio進行二次封裝

import 'package:dio/dio.dart';
import 'package:yolo_text/stores/TokenManager.dart';
import '../contants/index.dart';

class DioRequest {
  final _dio = Dio();

  //基礎地址攔截器
  DioRequest() {
    _dio.options
      ..baseUrl = GlobalConstants.BASE_URL
      ..connectTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..sendTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..receiveTimeout = Duration(seconds: GlobalConstants.TIME_OUT);
    //攔截器
    _addInterceptors();
  }

  //添加攔截器
  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          //請求攔截
          // 取得 token
          String token = tokenmanager.getToken();
          //注入token request headers Authorization = "Bearer token"
          if (token.isNotEmpty) {
            request.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(request);
        },
        onResponse: (response, handler) {
          //http狀態碼 200 300
          if (response.statusCode! >= 200 && response.statusCode! < 300) {
            return handler.next(response);
            return;
          }
          handler.reject(DioException(requestOptions: response.requestOptions));
        },
        onError: (error, handler) {
          // 取得後端回傳的錯誤訊息 (如果有)
          String errorMsg = error.response?.data["message"] ?? error.message ?? "未知錯誤";

          // 如果是 422 錯誤，嘗試印出詳細的驗證失敗原因
          if (error.response?.statusCode == 422) {
            print("後端 422 錯誤詳情: ${error.response?.data}");

          }
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              message: error.response?.data["message"] ?? "未知錯誤",
            ),
          );
        },
      ),
    );
  }

  //作用是將 _dio.post 的結果傳遞給 _handleResponse 進行數據解構與業務狀態碼（例如 code == 1）的驗證。
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.post(url, data: data));
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.get(url, data: data));
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.put(url, data: data));
  }

  Future<dynamic> delete(String url, {Map<String, dynamic>? data,Map<String, dynamic>? queryParameters}) {
    return _handleResponse(_dio.delete(url, data: data, queryParameters: queryParameters));
  }

  // 新增專門處理帶有 Query 參數與 Multipart 檔案的 put 方法
  Future<dynamic> putWithParams(
    String url, {
    dynamic data, // 使用 dynamic 以支援 FormData 檔案上傳
    Map<String, dynamic>? queryParameters, // 支援 FastAPI 的 Query 參數 (?key=value)
  }) {
    return _handleResponse(
      _dio.put(url, data: data, queryParameters: queryParameters),
    );
  }

  //對get到的數據進一步處理
  //dio請求工具發出請求 返回數據 Response<aynamic>.data
  //把所有接口的data解構出來 拿到真正資料 和判斷業務狀態碼是否等於"1"
  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async {
    try {
      // 1. 等待 Dio 請求完成
      Response<dynamic> res = await task;
      // 2. 將 res.data 強制轉型為 Map（後端返回的 JSON 根對象）
      final data = res.data as Map<String, dynamic>; //data為真正資料
      // 3. 判斷業務狀態碼
      if (data["code"].toString() == GlobalConstants.SUCCESS_CODE) {
        //http狀態碼和業務狀態碼正常 才返回數據
        // 成功：返回 JSON 中的 "data" 欄位
        print("API 回傳給 _handleResponse() 的原始內容: $data");
        return data["data"]; //返回數據
      }
      //拋出異常
      //throw Exception(data["message"] ?? "未知錯誤");
      throw DioException(
        requestOptions: res.requestOptions,
        message: data["message"] ?? "未知錯誤",
      );
    } catch (e) {
      //throw Exception(e);
      // 這裡直接 throw e，不需要再包一層 Exception(e)，
      // 這樣在 LoginPage 抓到的 e.toString() 會比較乾淨
      rethrow;
    }
  }
}

//單例對象
final dioRequest = DioRequest();
