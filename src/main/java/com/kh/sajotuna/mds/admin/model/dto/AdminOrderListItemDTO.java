package com.kh.sajotuna.mds.admin.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// adminOrderDelivery.jsp의 목업 ORDERS 배열 항목과 동일한 필드 이름을 사용
// (프론트 filter/render 로직을 그대로 재사용하기 위함)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("AdminOrderListItemDTO")
public class AdminOrderListItemDTO {
	private Long orderId;
	private String orderDateISO;
	private String orderDateDisplay;
	private String ordererName;
	private String productName; // 대표 상품 1건 (여러 상품 중 첫 번째)
	private Integer qty;
	private Integer productCount; // 주문에 포함된 상품 건수
	private Long paymentAmount;
	private String orderStatus; // DB 값 그대로(대문자): PAYMENT_WAITING 등
	private String deliveryStatus; // DB 값 그대로(대문자): PREPARING 등, 배송 정보 없으면 null
	private String trackingNo;
}
