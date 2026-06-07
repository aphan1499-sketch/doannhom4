import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String _apiKey;

  GeminiService() {
    // Read the Gemini API Key securely from environment variables loaded by flutter_dotenv
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      print("[GeminiService] Error: GEMINI_API_KEY is not defined in .env file.");
    }
  }

  /// Fetches real-time movie listings, genres, prices, locations, and showtimes from Firestore
  /// to feed into the prompt as dynamic context (RAG approach).
  Future<String> fetchMoviesContext() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('movies').get();
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
            "  Phòng chiếu/Cơ sở: $location"
          );
        }
        return movieStrings.join("\n\n");
      }
    } catch (e) {
      print("[GeminiService] Error querying movies from Firestore: $e");
    }

    // 🌟 FALLBACK MOCK DATA IF FIRESTORE IS EMPTY OR NOT SET UP YET
    return 
        "- Tên phim: Lật Mặt 7: Một Điều Ước\n"
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

  /// Combines the system instruction, dynamic context, and user message, then generates the AI response.
  /// Seamlessly falls back through stable model endpoints if a model is overloaded (503).
  Future<String> generateResponse(String userMessage) async {
    try {
      // 1. Fetch real-time data from Firestore
      final String context = await fetchMoviesContext();

      // 2. Build the combined System + Context + User prompt
      final String systemInstruction = 
          "Bạn là một nhân viên hỗ trợ khách hàng vô cùng lịch sự, thân thiện, xưng hô 'HUIT Cinema xin chào' và tự gọi mình là 'tôi' hoặc 'em'.\n"
          "Hãy trả lời các câu hỏi của khách hàng dựa TRÊN VÀ CHỈ DỰA TRÊN thông tin phim đang chiếu thời gian thực của rạp HUIT Cinema được cung cấp dưới đây.\n"
          "Tuyệt đối KHÔNG tự bịa đặt thông tin không có trong dữ liệu. Nếu khách hàng hỏi những câu hỏi ngoài phạm vi dữ liệu được cung cấp hoặc hỏi về các bộ phim khác không có trong danh sách, hãy từ chối trả lời một cách lịch sự, khéo léo và hướng dẫn họ liên hệ với hotline rạp: 1900 1234.\n\n"
          "[Dữ liệu phim thời gian thực của rạp HUIT Cinema]:\n"
          "$context";

      final content = [
        Content.text("$systemInstruction\n\nKhách hàng hỏi: $userMessage"),
      ];

      // 💡 FALLBACK MODEL CHAIN: Try each model sequentially if previous is overloaded
      final List<String> modelsToTry = [
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-1.5-pro',
        'gemini-pro',
      ];

      Object? lastError;
      for (var modelName in modelsToTry) {
        try {
          print("[GeminiService] Attempting generateContent with model: $modelName");
          final model = GenerativeModel(model: modelName, apiKey: _apiKey);
          final response = await model.generateContent(content);
          if (response.text != null && response.text!.isNotEmpty) {
            print("[GeminiService] Generation SUCCESS with model: $modelName");
            return response.text!;
          }
        } catch (e) {
          print("[GeminiService] Model $modelName failed/overloaded: $e");
          lastError = e;
        }
      }

      // If all fallbacks fail, throw the last error
      if (lastError != null) {
        throw lastError;
      }

      return "HUIT Cinema xin lỗi, hiện tại tôi chưa thể phản hồi câu hỏi này. Bạn vui lòng thử lại sau nhé!";
    } catch (e) {
      print("[GeminiService] Exception during Gemini inference: $e");
      return "Hệ thống AI Chatbot hiện tại đang quá tải lượt yêu cầu hoặc mất kết nối. Bạn vui lòng thử lại sau ít phút hoặc liên hệ Hotline: 1900 1234 để được hỗ trợ trực tiếp nhé!";
    }
  }
}
