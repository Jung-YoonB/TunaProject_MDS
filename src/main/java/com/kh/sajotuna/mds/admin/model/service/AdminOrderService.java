package com.kh.sajotuna.mds.admin.model.service;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListResponseDTO;

public interface AdminOrderService {

	AdminOrderListResponseDTO getOrderList();

	void updateDeliveryStatus(Long orderId, String deliveryStatus, String trackingNo, String company);

	void confirmPayment(Long orderId);

	void completeCancel(Long orderId);
}
