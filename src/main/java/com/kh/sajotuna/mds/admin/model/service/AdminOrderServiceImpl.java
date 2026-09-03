package com.kh.sajotuna.mds.admin.model.service;

import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListResponseDTO;
import com.kh.sajotuna.mds.admin.model.dto.OrderStatusSnapshotDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminOrderMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminOrderServiceImpl implements AdminOrderService {

	// DELIVERY.DELIVERY_STATUS CHECK 제약과 동일
	private static final Set<String> VALID_DELIVERY_STATUSES = Set.of(
			"PREPARING", "SHIPPED", "OUT_FOR_DELIVERY", "DELIVERED", "CANCELED");

	// PRODUCTORDER.ORDER_STATUS CHECK 제약엔 OUT_FOR_DELIVERY가 없어서 SHIPPED로 합쳐서 동기화
	private static final Map<String, String> DELIVERY_TO_ORDER_STATUS = Map.of(
			"PREPARING", "PREPARING",
			"SHIPPED", "SHIPPED",
			"OUT_FOR_DELIVERY", "SHIPPED",
			"DELIVERED", "DELIVERED",
			"CANCELED", "CANCELED");

	// 택배사에 실제로 넘긴 이후 상태이므로 송장번호/택배사 입력이 필수인 상태들
	private static final Set<String> COURIER_INFO_REQUIRED_STATUSES = Set.of(
			"SHIPPED", "OUT_FOR_DELIVERY", "DELIVERED");

	// DELIVERY.COMPANY엔 DB CHECK 제약이 없어서(자유 입력 VARCHAR2) 애플리케이션 레벨에서 값 목록을 제한함.
	// 프론트 모달의 <select> 옵션과 동일한 목록으로 유지할 것
	private static final Set<String> VALID_COMPANIES = Set.of(
			"CJ대한통운", "한진택배", "롯데택배", "로젠택배", "우체국택배");

	// 배송 단계 순서(역행 방지용). CANCELED는 어느 단계에서든 갈 수 있어야 해서 가장 큰 값
	private static final Map<String, Integer> DELIVERY_STATUS_RANK = Map.of(
			"PREPARING", 0,
			"SHIPPED", 1,
			"OUT_FOR_DELIVERY", 2,
			"DELIVERED", 3,
			"CANCELED", 3);

	private final AdminOrderMapper mapper;

	@Override
	public AdminOrderListResponseDTO getOrderList() {
		return new AdminOrderListResponseDTO(mapper.selectOrderList(), mapper.selectSummary());
	}

	@Override
	@Transactional
	public void updateDeliveryStatus(Long orderId, String deliveryStatus, String trackingNo, String company) {
		if (deliveryStatus == null || !VALID_DELIVERY_STATUSES.contains(deliveryStatus)) {
			throw new IllegalStateException("올바르지 않은 배송 상태입니다.");
		}

		OrderStatusSnapshotDTO snapshot = mapper.selectStatusSnapshot(orderId);
		if (snapshot == null) {
			throw new IllegalStateException("해당 주문을 찾을 수 없습니다.");
		}
		if ("PAYMENT_WAITING".equals(snapshot.getOrderStatus())) {
			throw new IllegalStateException("결제가 완료되지 않은 주문은 배송 상태를 변경할 수 없습니다. 결제 완료 처리를 먼저 진행해주세요.");
		}

		String currentDeliveryStatus = snapshot.getDeliveryStatus();

		if (currentDeliveryStatus == null) {
			// 결제 완료 시점엔 DELIVERY 행이 없다 - 배송준비중으로 바꿀 때 여기서 처음 만든다
			if (!"PREPARING".equals(deliveryStatus) && !"CANCELED".equals(deliveryStatus)) {
				throw new IllegalStateException("배송 정보가 없는 주문은 먼저 '배송준비중'으로 상태를 변경하거나 취소/환불 처리해야 합니다.");
			}
			mapper.insertDelivery(orderId, deliveryStatus, trackingNo, company);
			syncOrderStatus(orderId, deliveryStatus);
			return;
		}

		validateTransition(currentDeliveryStatus, deliveryStatus, trackingNo, company);

		int updated = mapper.updateDeliveryStatus(orderId, deliveryStatus, trackingNo, company);
		if (updated == 0) {
			throw new IllegalStateException("해당 주문의 배송 정보를 찾을 수 없습니다.");
		}

		syncOrderStatus(orderId, deliveryStatus);
	}

	/** DELIVERY 행이 이미 있는 주문의 상태 전이가 허용되는지 검사한다(통과하면 그대로 UPDATE) */
	private void validateTransition(String currentDeliveryStatus, String deliveryStatus,
			String trackingNo, String company) {

		// 취소/환불된 주문은 완전히 끝난 상태 - 더 이상 아무 것도 변경 불가
		if ("CANCELED".equals(currentDeliveryStatus)) {
			throw new IllegalStateException("이미 취소/환불된 주문은 상태를 변경할 수 없습니다.");
		}
		// 배송완료된 주문은 정상적인 다음 단계가 없지만, 취소/환불(반품 등)은 그 이후에도 가능해야 함
		if ("DELIVERED".equals(currentDeliveryStatus) && !"CANCELED".equals(deliveryStatus)) {
			throw new IllegalStateException("배송이 완료된 주문은 취소/환불 처리만 가능합니다.");
		}
		if (DELIVERY_STATUS_RANK.get(deliveryStatus) < DELIVERY_STATUS_RANK.get(currentDeliveryStatus)) {
			throw new IllegalStateException("이전 단계로 되돌릴 수 없습니다.");
		}

		if (COURIER_INFO_REQUIRED_STATUSES.contains(deliveryStatus)) {
			if (trackingNo == null || trackingNo.isBlank() || company == null || company.isBlank()) {
				throw new IllegalStateException("이 상태로 변경하려면 택배사와 송장번호를 입력해야 합니다.");
			}
			if (!VALID_COMPANIES.contains(company)) {
				throw new IllegalStateException("올바르지 않은 택배사입니다.");
			}
		}
	}

	/**
	 * 배송 상태에 맞춰 PRODUCTORDER.ORDER_STATUS를 따라가게 한다.
	 *
	 * 취소/환불만 예외다 - 2단계(대기중 -> 처리완료)라서 여기서 안 맞추고 completeCancel()에서 맞춘다.
	 * DELIVERY 행을 새로 만드는 경로와 UPDATE 경로 양쪽이 똑같이 해야 해서 한 곳으로 모았다.
	 */
	private void syncOrderStatus(Long orderId, String deliveryStatus) {
		if (!"CANCELED".equals(deliveryStatus)) {
			mapper.updateOrderStatus(orderId, DELIVERY_TO_ORDER_STATUS.get(deliveryStatus));
		}
	}

	@Override
	@Transactional
	public void confirmPayment(Long orderId) {
		int updated = mapper.confirmPayment(orderId);
		if (updated == 0) {
			throw new IllegalStateException("결제 대기 상태의 주문이 아니거나 이미 처리되었습니다.");
		}
	}

	// 취소/환불 2단계 중 두 번째 - DELIVERY_STATUS는 이미 CANCELED(대기중)인 주문의 ORDER_STATUS까지
	// CANCELED로 맞춰서 완전히 종료 처리한다. 스키마 변경 없이 기존 두 컬럼을 "대기중/완료" 플래그처럼 씀
	@Override
	@Transactional
	public void completeCancel(Long orderId) {
		OrderStatusSnapshotDTO snapshot = mapper.selectStatusSnapshot(orderId);
		if (snapshot == null) {
			throw new IllegalStateException("해당 주문을 찾을 수 없습니다.");
		}
		if (!"CANCELED".equals(snapshot.getDeliveryStatus())) {
			throw new IllegalStateException("취소/환불 대기 중인 주문이 아닙니다.");
		}
		if ("CANCELED".equals(snapshot.getOrderStatus())) {
			throw new IllegalStateException("이미 취소/환불 처리가 완료된 주문입니다.");
		}

		mapper.updateOrderStatus(orderId, "CANCELED");
	}
}
