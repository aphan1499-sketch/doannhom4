import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String _apiKey;
  late final String _proxyUrl;

  GeminiService() {
    // Prefer AI_PROXY_URL in production so the mobile app never exposes an AI API key.
    _proxyUrl = dotenv.env['AI_PROXY_URL'] ?? '';
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_proxyUrl.isEmpty && _apiKey.isEmpty) {
      debugPrint(
        "[GeminiService] No AI_PROXY_URL or GEMINI_API_KEY configured. Local replies will still work.",
      );
    }
  }

  String _normalize(String input) {
    var text = input.toLowerCase().trim();
    const replacements = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
    };

    replacements.forEach((source, target) {
      text = text.replaceAll(source, target);
    });
    return text;
  }

  bool _hasAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  bool _hasAnyWord(String text, List<String> words) {
    final tokens = text
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toSet();
    return words.any(tokens.contains);
  }

  String? _buildLocalResponse(String userMessage) {
    final text = _normalize(userMessage);

    if (_hasAny(text, ['hello', 'helo', 'xin chao']) ||
        _hasAnyWord(text, ['hi', 'chao', 'alo'])) {
      return 'HUIT Cinema xin chào! Em có thể hỗ trợ nhanh về lịch chiếu, giá vé, gói VIP, thanh toán hoặc liên hệ CSKH. Anh/Chị muốn hỏi phần nào ạ?';
    }

    if (_hasAny(text, ['gia ve', 'bao nhieu tien', 've phim', 'gia phim'])) {
      return 'Giá vé tham khảo tại HUIT Cinema thường từ 75.000đ đến 95.000đ tùy phim, suất chiếu và loại phòng. Với suất đặc biệt hoặc phòng VIP, giá có thể cao hơn. Anh/Chị có thể vào chi tiết phim để xem giá chính xác trước khi đặt vé.';
    }

    if (_hasAny(text, [
      'lich chieu',
      'suat chieu',
      'gio chieu',
      'phim dang chieu',
      'phim dang duoc chieu',
      'phim nao dang chieu',
      'ten phim',
      'co phim gi',
      'rap chieu',
    ])) {
      return 'Hiện HUIT Cinema có các phim: Lật Mặt 7: Một Điều Ước, Dune: Cát Đấu Phần Hai, Kung Fu Panda 4 và Mai. Anh/Chị có thể vào chi tiết phim để xem suất chiếu, phòng chiếu và giá vé chính xác.';
    }

    if (_hasAny(text, ['vip', 'premium', 'goi phim', 'goi xem phim'])) {
      return 'Gói VIP Streaming giúp nâng cấp tài khoản để xem nội dung Premium. Anh/Chị vào Cá nhân > Đăng ký Gói VIP Streaming để chọn gói và thanh toán.';
    }

    if (_hasAny(text, [
      'thanh toan',
      'momo',
      'zalopay',
      'zalo pay',
      'visa',
      'mastercard',
      'the ngan hang',
      'phuong thuc',
    ])) {
      return 'Phần thanh toán hiện hỗ trợ thẻ quốc tế và ví điện tử. Anh/Chị có thể vào Cá nhân > Phương thức thanh toán để quản lý thẻ/ví, hoặc vào Đăng ký Gói VIP Streaming để thực hiện thanh toán gói.';
    }

    if (_hasAny(text, [
      'lien he',
      'ho tro',
      'hotline',
      'tong dai',
      'cskh',
      'email',
      'gap nhan vien',
    ])) {
      return 'Anh/Chị có thể liên hệ CSKH qua tổng đài 1900 1234 từ 8:00 đến 22:00, hoặc gửi email tới support@xemphim.vn. Trong màn Hỗ trợ khách hàng, hai mục này đã mở trực tiếp trình gọi điện và ứng dụng email.';
    }

    if (_hasAny(text, [
      'dang nhap',
      'dang ky',
      'quen mat khau',
      'mat khau',
      'tai khoan',
      'google',
      'facebook',
    ])) {
      return 'Về tài khoản, Anh/Chị có thể đăng ký bằng email, đăng nhập bằng email hoặc Google/Facebook. Nếu quên mật khẩu, hãy chọn Quên mật khẩu ở màn đăng nhập để nhận email đặt lại mật khẩu.';
    }

    if (_hasAny(text, ['cam on', 'thanks', 'thank you', 'ok', 'duoc roi'])) {
      return 'Dạ không có gì ạ. Anh/Chị cần thêm thông tin về phim, vé, VIP hay thanh toán thì cứ nhắn em nhé.';
    }

    if (_hasAnyWord(text, ['khac']) || _hasAny(text, ['phan khac'])) {
      return 'Dạ được ạ. Ngoài các mục nhanh, Anh/Chị có thể hỏi thêm về tài khoản, đổi mật khẩu, phương thức thanh toán, lịch sử giao dịch hoặc cách liên hệ CSKH.';
    }

    return null;
  }

  String _buildFallbackResponse() {
    return 'Hiện em chưa kết nối được AI để trả lời câu hỏi phức tạp này. Anh/Chị có thể hỏi nhanh các mục: lịch chiếu, giá vé, gói VIP, thanh toán, đăng nhập hoặc liên hệ CSKH qua 1900 1234.';
  }

  /// Fetches real-time movie listings, genres, prices, locations, and showtimes from Firestore
  /// to feed into the prompt as dynamic context (RAG approach).
  Future<String> fetchMoviesContext() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('movies')
          .get();
      if (snapshot.docs.isNotEmpty) {
        final List<String> movieStrings = [];
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          final String title = data['title'] ?? 'Chưa rõ tên';
          final String genre = data['genre'] ?? 'Chưa rõ thể loại';
          final String showtimes = data['showtimes'] ?? 'Chưa rõ lịch chiếu';
          final dynamic price = data['price'] ?? 'Chưa rõ giá';
          final String location = data['location'] ?? 'Chưa rõ rạp';

          movieStrings.add(
            "- Tên phim: $title\n"
            "  Thể loại: $genre\n"
            "  Lịch chiếu: $showtimes\n"
            "  Giá vé: $price VNĐ\n"
            "  Phòng chiếu/Cơ sở: $location",
          );
        }
        return movieStrings.join("\n\n");
      }
    } catch (e) {
      debugPrint("[GeminiService] Error querying movies from Firestore: $e");
    }

    // 🌟 FALLBACK MOCK DATA IF FIRESTORE IS EMPTY OR NOT SET UP YET
    return "- Tên phim: Lật Mặt 7: Một Điều Ước\n"
        "  Thể loại: Gia đình, Kịch tính, Cảm động\n"
        "  Lịch chiếu: 09:00, 13:30, 16:15, 20:00, 22:30 hàng ngày\n"
        "  Giá vé: 85.000 VNĐ\n"
        "  Phòng chiếu/Cơ sở: Phòng chiếu số 1 (IMAX VIP) - HUIT Cinema Tân Phú\n\n"
        "- Tên phim: Dune: Cát Đấu Phần Hai\n"
        "  Thể loại: Khoa học viễn tưởng, Hành động, Kỳ ảo\n"
        "  Lịch chiếu: 10:30, 14:00, 18:00, 21:30 hàng ngày\n"
        "  Giá vé: 95.000 VNĐ\n"
        "  Phòng chiếu/Cơ sở: Phòng chiếu số 3 (3D Dolby Atmos) - HUIT Cinema Tân Phú\n\n"
        "- Tên phim: Kung Fu Panda 4\n"
        "  Thể loại: Hoạt hình, Hài hước, Phiêu lưu\n"
        "  Lịch chiếu: 08:30, 11:00, 15:00, 17:30 hàng ngày\n"
        "  Giá vé: 75.000 VNĐ\n"
        "  Phòng chiếu/Cơ sở: Phòng chiếu số 2 (Phòng Tiêu Chuẩn) - HUIT Cinema Tân Phú\n\n"
        "- Tên phim: Phim Mai\n"
        "  Thể loại: Tâm lý, Tình cảm, Gia đình\n"
        "  Lịch chiếu: 12:00, 16:00, 19:30, 21:00 hàng ngày\n"
        "  Giá vé: 80.000 VNĐ\n"
        "  Phòng chiếu/Cơ sở: Phòng chiếu số 4 - HUIT Cinema Tân Phú";
  }

  Future<String> generateResponse(String userMessage) async {
    final localResponse = _buildLocalResponse(userMessage);
    if (localResponse != null) {
      return localResponse;
    }

    try {
      final String context = await fetchMoviesContext();
      final proxyResponse = await _generateViaProxy(userMessage, context);
      if (proxyResponse != null) {
        return proxyResponse;
      }

      final geminiResponse = await _generateViaGemini(userMessage, context);
      if (geminiResponse != null) {
        return geminiResponse;
      }

      return _buildFallbackResponse();
    } catch (e) {
      debugPrint("[GeminiService] Exception during AI response: $e");
      return _buildFallbackResponse();
    }
  }

  Future<String?> _generateViaProxy(String userMessage, String context) async {
    if (_proxyUrl.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse(_proxyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userMessage,
              'context': context,
              'app': 'HUIT Cinema',
            }),
          )
          .timeout(const Duration(seconds: 18));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          "[GeminiService] AI proxy failed with status ${response.statusCode}",
        );
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final text =
            decoded['reply'] ??
            decoded['response'] ??
            decoded['message'] ??
            decoded['answer'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
      }

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } catch (e) {
      debugPrint("[GeminiService] AI proxy unavailable: $e");
    }

    return null;
  }

  Future<String?> _generateViaGemini(String userMessage, String context) async {
    if (_apiKey.isEmpty) return null;

    final String systemInstruction =
        "Bạn là nhân viên hỗ trợ khách hàng lịch sự, thân thiện của HUIT Cinema, xưng 'em' và gọi người dùng là Anh/Chị.\n"
        "Chỉ trả lời trong phạm vi rạp phim, lịch chiếu, giá vé, tài khoản, VIP, thanh toán và hỗ trợ khách hàng.\n"
        "Nếu không có đủ dữ liệu, hãy nói rõ và hướng dẫn liên hệ hotline 1900 1234.\n\n"
        "[Dữ liệu phim thời gian thực của rạp HUIT Cinema]:\n"
        "$context";

    final content = [
      Content.text("$systemInstruction\n\nKhách hàng hỏi: $userMessage"),
    ];

    final List<String> modelsToTry = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-pro',
      'gemini-pro',
    ];

    for (var modelName in modelsToTry) {
      try {
        debugPrint(
          "[GeminiService] Attempting generateContent with model: $modelName",
        );
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);
        final response = await model.generateContent(content);
        if (response.text != null && response.text!.trim().isNotEmpty) {
          debugPrint(
            "[GeminiService] Generation SUCCESS with model: $modelName",
          );
          return response.text!.trim();
        }
      } catch (e) {
        debugPrint("[GeminiService] Model $modelName failed: $e");
      }
    }

    return null;
  }
}
