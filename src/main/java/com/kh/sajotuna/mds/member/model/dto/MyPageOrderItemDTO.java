package com.kh.sajotuna.mds.member.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * 주문/배송내역 카드를 펼쳤을 때 보여주는 주문 품목 1건.
 *
 * 목록 쿼리(selectDeliveriesByMemberId)는 주문당 대표 상품 1건만 가져오므로,
 * 한 번에 여러 상품을 산 주문은 나머지를 확인할 방법이 없었다. 이 DTO가 그 나머지를 담는다.
 * 주문 건수만큼 조회하면 N+1이 되므로, 화면에 보이는 주문 ID들을 모아 한 번에 가져온다
 * (MemberMapper.selectOrderItemsByOrderIds).
 */
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("MyPageOrderItemDTO")
public class MyPageOrderItemDTO {

	// 어느 주문의 품목인지. 조회 결과를 주문별로 나눠 담을 때 쓴다
	private Long orderId;

	private Long odId;
	private String productName;
	private String optionName;
	private Integer qty;

	// 주문 시점에 박아 둔 단가. 현재 상품 가격이 아니라 이 값으로 보여줘야 주문서와 맞는다
	private Long priceFix;

	private String productImagePath;
	private String productImageSaveName;

	// 이 품목의 리뷰를 이미 썼는지. 삭제한 리뷰도 "썼음"으로 친다(재작성 차단과 같은 기준, 정책 11번)
	private boolean hasReview;
}
