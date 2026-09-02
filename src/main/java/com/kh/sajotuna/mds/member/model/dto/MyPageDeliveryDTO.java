package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.type.Alias;
import org.springframework.format.annotation.DateTimeFormat;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("MyPageDeliveryDTO")
public class MyPageDeliveryDTO {

	// 딜리버리 테이블
	private Long deliveryId;
	private String company;
	private String trackingNo;
	private String deliveryStatus;
	private String detailAddressFix;
	private String addressNameFix;
	
	// 주문 테이블
	private Long orderId;
	private Long totalPrice;
	private String orderStatus;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate orderDate;

	private String orderDateStr;

	// 대표 상품 정보 (ORDERDETAIL 중 OD_ID가 가장 작은 1건)
	private Long odId; // 리뷰 작성 연결용 - 아직 리뷰를 안 쓴 첫 주문상세(다 썼으면 대표)
	private String productName;
	private String productImagePath;
	private String productImageSaveName;
	private Integer qty;
	private Integer productCount; // 주문에 포함된 상품 건수 (2건 이상이면 "외 N건" 표시용)
	private boolean hasReview; // 이 주문의 모든 상품을 다 썼는지 (하나라도 남으면 false)

	// 주문 전체 수량 합계. qty는 대표 상품 1건의 수량이라 여러 상품을 산 주문에서는
	// 화면에 "수량: 2개"처럼 실제보다 적게 보인다
	private Integer totalQty;

	// 카드를 펼쳤을 때 보여줄 이 주문의 전체 품목. MemberServiceImpl.listDelivery가 채운다
	private List<MyPageOrderItemDTO> items;
}
