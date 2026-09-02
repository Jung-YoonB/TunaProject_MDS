package com.kh.sajotuna.mds.order.model.dto;

import java.math.BigDecimal;
import java.util.List;

import org.apache.ibatis.type.Alias;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;

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
@Alias("PaymentViewDTO")
public class PaymentViewDTO {
	
	// 멤버 테이블
	private String memberName;		// 회원 이름
	private Long point;				// 회원이 가진 포인트
	
	// 등급 테이블
	private String gradeName;		// 회원의 등급
	private BigDecimal discountRate;		// 회원의 할인율
	
	// 배달주소 테이블
	private String addressName;		// 회원이 저장한 기본 주소 이름
	private String detailAddress;	// 회원이 저장한 기본 주소
	
	// 총 가격
	private long totalPrice;		// 결제창에 띄울 총 가격
	
	// 리스트
	private List<OrderItemDTO> itemList;		// 구매할 것들 정보 (옵션id, 수량, 옵션 이름, 옵션가격, 상품 이름)
	private List<CouponDTO> couponList;	// 사용자가 가지고 있는 쿠폰 목록
	private List<Long> cartIds;
}
