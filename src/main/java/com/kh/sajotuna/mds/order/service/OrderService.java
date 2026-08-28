package com.kh.sajotuna.mds.order.service;

import java.util.List;

import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;

public interface OrderService {

	// 장바구니 결제 페이지 출력에 필요한 정보 받아오기 
	PaymentViewDTO cartPrepare(Long memberId, List<Long> cartIds);
	
	// 바로 구입 결제 페이지 출력에 필요한 정보 받아오기 
	PaymentViewDTO directPrepare(Long memberId, OrderItemDTO orderItem);
}
