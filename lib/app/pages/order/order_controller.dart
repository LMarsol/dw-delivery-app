import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dw9_delivery_app/app/dto/order_dto.dart';
import 'package:dw9_delivery_app/app/dto/order_product_dto.dart';
import 'package:dw9_delivery_app/app/pages/order/order_state.dart';
import 'package:dw9_delivery_app/app/repositories/order/order_repository.dart';

class OrderController extends Cubit<OrderState> {
  OrderController(this._repository) : super(const OrderState.initial());

  final OrderRepository _repository;

  void load(List<OrderProductDto> products) async {
    try {
      emit(state.copyWith(status: OrderStatus.loading));

      final paymentTypes = await _repository.getAllPaymentsTypes();

      emit(state.copyWith(
        orderProducts: products,
        paymentTypes: paymentTypes,
        status: OrderStatus.loaded,
      ));
    } catch (e, s) {
      log('Erro ao carregar página', error: e, stackTrace: s);

      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Erro ao carregar página',
      ));
    }
  }

  void incrementProduct(int index) {
    final orders = [...state.orderProducts];
    final order = orders[index];

    orders[index] = order.copyWith(amount: order.amount + 1);

    emit(state.copyWith(
      orderProducts: orders,
      status: OrderStatus.updateOrder,
    ));
  }

  void decrementProduct(int index) {
    final orders = [...state.orderProducts];
    final order = orders[index];

    if (order.amount == 1) {
      if (state.status != OrderStatus.confirmRemoveProduct) {
        emit(OrderConfirmDeleteProductState(
          index: index,
          orderProduct: order,
          paymentTypes: state.paymentTypes,
          orderProducts: state.orderProducts,
          status: OrderStatus.confirmRemoveProduct,
        ));

        return;
      }

      orders.removeAt(index);
    } else {
      orders[index] = order.copyWith(amount: order.amount - 1);
    }

    if (orders.isEmpty) {
      emit(state.copyWith(orderProducts: orders, status: OrderStatus.emptyBag));
      return;
    }

    emit(state.copyWith(
      orderProducts: orders,
      status: OrderStatus.updateOrder,
    ));
  }

  void cancelDeleteProcess() {
    emit(state.copyWith(status: OrderStatus.loaded));
  }

  void emptyBag() {
    emit(state.copyWith(status: OrderStatus.emptyBag));
  }

  void saveOrder({
    required String address,
    required String document,
    required int paymentMethod,
  }) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final order = OrderDto(
        address: address,
        document: document,
        products: state.orderProducts,
        paymentMethodId: paymentMethod,
      );

      await _repository.saveOrder(order);

      emit(state.copyWith(status: OrderStatus.success));
    } catch (e, s) {
      log('Erro ao enviar ordem', error: e, stackTrace: s);

      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Erro ao enviar ordem',
      ));
    }
  }
}
