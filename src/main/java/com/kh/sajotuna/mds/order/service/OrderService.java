package com.kh.sajotuna.mds.order.service;

import java.util.List;

import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;

public interface OrderService {

	// 장바구니 결제 페이지 출력에 필요한 정보 받아오기 
	PaymentViewDTO cartPrepare(Long memberId, List<Long> cartIds);
	
	// 바로 구입 결제 페이지 출력에 필요한 정보 받아오기 
	PaymentViewDTO directPrepare(Long memberId, OrderItemDTO orderItem);
	
	// 정보 받아서 결제하기
	CheckoutDTO checkout(CheckoutDTO checkoutInputData);
	
	// 로그인 회원이 실제 주문한건지 확인
	Long getOrderIdForMember(Long orderId, Long memberId);

}