package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

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
	
	// 대표 상품 정보
	private String productName;
	private String productImagePath; 
	private String productImageSaveName;
}
