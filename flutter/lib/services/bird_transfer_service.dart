import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/api_service.dart';
import 'package:app_volailles/services/bird_service.dart';

class BirdTransferService {
  final _apiService = ApiService();
  final _birdService = BirdService();

  /// Marks a bird for sale and makes it available for purchase by other users
  ///
  /// This method updates the bird's status to indicate it's for sale without
  /// immediately transferring ownership
  Future<Bird> markBirdForSale(String birdId, double askingPrice) async {
    try {
      print('🔄 Marking bird $birdId for sale...');
      final response = await _apiService.put('birds/$birdId/mark-for-sale', {
        'forSale': true,
        'askingPrice': askingPrice,
      });

      if (response is Map) {
        final updatedBird = Bird.fromApi(Map<String, dynamic>.from(response));
        print('✅ Bird marked for sale: ${updatedBird.identifier}');
        return updatedBird;
      }

      print('⚠️ Invalid response format: $response');
      throw Exception('Invalid response format');
    } catch (e) {
      print('⚠️ Error marking bird for sale: $e');
      throw Exception('Error marking bird for sale: ${e.toString()}');
    }
  }

  /// Purchases a bird that has been marked for sale
  ///
  /// This transfers the bird from the seller to the buyer and updates the bird's status
  Future<Bird> purchaseBird(
    String birdId,
    String buyerNationalId,
    String buyerFullName, {
    String? buyerPhone,
    double? finalPrice,
  }) async {
    try {
      print('🔄 Purchasing bird $birdId...');
      final response = await _apiService.put('birds/$birdId/purchase', {
        'buyerInfo': {
          'nationalId': buyerNationalId,
          'fullName': buyerFullName,
          'phone': buyerPhone ?? '',
        },
        'finalPrice': finalPrice,
        'forSale': false, // Remove from sale after purchase
        'status': 'Owned', // Update status to owned
      });

      if (response is Map) {
        final updatedBird = Bird.fromApi(Map<String, dynamic>.from(response));
        print('✅ Bird purchased successfully: ${updatedBird.identifier}');
        
      /*   // Remove the bird from the seller's list by marking it as transferred
        await _apiService.put('birds/$birdId/transfer-complete', {
          'transferred': true,
          'transferDate': DateTime.now().toIso8601String(),
        }); */
        
        return updatedBird;
      }

      print('⚠️ Invalid response format: $response');
      throw Exception('Invalid response format');
    } catch (e) {
      print('⚠️ Error purchasing bird: $e');
      throw Exception('Error purchasing bird: ${e.toString()}');
    }
  }

  /// Cancels the sale of a bird that was previously marked for sale
  Future<Bird> cancelSale(String birdId) async {
    try {
      print('🔄 Canceling sale for bird $birdId...');
      final response = await _apiService.put('birds/$birdId/cancel-sale', {
        'forSale': false,
      });

      if (response is Map) {
        final updatedBird = Bird.fromApi(Map<String, dynamic>.from(response));
        print('✅ Sale canceled: ${updatedBird.identifier}');
        return updatedBird;
      }

      print('⚠️ Invalid response format: $response');
      throw Exception('Invalid response format');
    } catch (e) {
      print('⚠️ Error canceling sale: $e');
      throw Exception('Error canceling sale: ${e.toString()}');
    }
  }

  /// Gets all birds that are currently marked for sale
  Future<List<Bird>> getBirdsForSale() async {
    try {
      print('🔄 Getting birds for sale...');
      final response = await _apiService.get('birds/for-sale');

      if (response is List) {
        final birds = response.map((json) => Bird.fromApi(json)).toList();
        print('✅ ${birds.length} birds for sale retrieved');
        return birds;
      } else if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} birds for sale retrieved');
        return birds;
      }

      print('⚠️ Invalid response format: $response');
      return [];
    } catch (e) {
      print('⚠️ Error getting birds for sale: $e');
      return [];
    }
  }
}
