package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

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
@Alias("MyPageCartDTO")
public class MyPageCartDTO {
	
	// 카트 테이블
	private Long cartId;
	private Long qty;
	
	// 프로덕트옵션 테이블
	private Long optionId;
	private String optionName;
	private Long optionPrice;
	private Long optionStock;		// 재고 확인으로 장바구니에 추가 여부
	
	// 프로덕트 테이블
	private Long productId;			// 상품 상세 페이지로 링크 하기 위해
	private String productName;		// 혹시나 [상품명] 옵션명 형태로 하기 위해
	
	// 프로덕트 이미지 테이블
	private String productImagePath;
	private String productImageSaveName;
	
}
