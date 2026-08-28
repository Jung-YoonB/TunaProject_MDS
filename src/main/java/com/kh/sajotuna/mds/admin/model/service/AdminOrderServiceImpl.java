package com.kh.sajotuna.mds.admin.model.service;

import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListResponseDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminOrderMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminOrderServiceImpl implements AdminOrderService {

	// DELIVERY.DELIVERY_STATUS CHECK 제약과 동일
	private static final Set<String> VALID_DELIVERY_STATUSES = Set.of(
			"PREPARING", "SHIPPED", "OUT_FOR_DELIVERY", "DELIVERED", "CANCELED");

	private final AdminOrderMapper mapper;

	@Override
	public AdminOrderListResponseDTO getOrderList() {
		return new AdminOrderListResponseDTO(mapper.selectOrderList(), mapper.selectSummary());
	}

	@Override
	@Transactional
	public void updateDeliveryStatus(Long orderId, String deliveryStatus, String trackingNo) {
		if (deliveryStatus == null || !VALID_DELIVERY_STATUSES.contains(deliveryStatus)) {
			throw new IllegalStateException("올바르지 않은 배송 상태입니다.");
		}

		int updated = mapper.updateDeliveryStatus(orderId, deliveryStatus, trackingNo);
		if (updated == 0) {
			throw new IllegalStateException("해당 주문의 배송 정보를 찾을 수 없습니다.");
		}
	}
}
