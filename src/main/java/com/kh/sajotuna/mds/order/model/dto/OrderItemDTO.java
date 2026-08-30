package com.kh.sajotuna.mds.order.model.dto;

import org.apache.ibatis.type.Alias;

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
@Alias("OrderItemDTO")
public class OrderItemDTO {
	
	// 장바구니 테이블
	private Long popId;
	private Long qty;
	
	// 옵션 테이블
	private String optionName;
	private Long optionPrice;
	private Long optionStock;
	
	// 상품 테이블
	private String productName;
	
	// 결제와 검증용
	private Long orderId;
	private Long priceFix;
	private Long gradeDisAmount;
}
