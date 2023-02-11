import 'package:dw9_delivery_app/app/dto/order_product_dto.dart';

class OrderDto {
  final String address;
  final String document;
  final int paymentMethodId;
  final List<OrderProductDto> products;

  OrderDto({
    required this.address,
    required this.document,
    required this.paymentMethodId,
    required this.products,
  });
}
