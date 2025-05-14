import 'package:app_volailles/models/product.dart';
import 'package:app_volailles/services/api_service.dart';
import 'package:app_volailles/utils/api_exception.dart';

class ProductService {
  final _apiService = ApiService();

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiService.get('products');
      if (response["success"] == true) {
        final List<dynamic> productsData = response['data'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response["message"]}');
      }
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Error loading products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _apiService.post('products', product.toJson());
      if (response["success"] == true) {
        return Product.fromJson(response['data']);
      } else {
        throw Exception('Failed to create product: ${response["message"]}');
      }
    } catch (e) {
      print('Error in createProduct: $e');
      throw Exception('Error creating product: $e');
    }
  }

  Future<double> getTotalProductValue() async {
    try {
      final response = await _apiService.get('products/total-value');
      if (response["success"] == true) {
        return (response['data'] as num).toDouble();
      } else {
        throw ApiException(response['message'] ?? 'Impossible de récupérer la valeur totale des produits');
      }
    } catch (e) {
      print('Erreur dans getTotalProductValue: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('Erreur lors de la récupération de la valeur totale des produits');
      }
    }
  }
}
