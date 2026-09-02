package com.kh.sajotuna.mds.order.model.dto;

import java.io.Serializable;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * 진행 중인 결제 - "무엇을 사려던 중인지"만 담는다 (세션 보관용).
 *
 * 결제 화면은 흐름의 한 단계라 선택한 상품 없이는 열 수 없다. 그래서 결제 화면에 들어올 때
 * 이 선택을 세션에 남겨두고, 헤더의 결제 아이콘(GET /order/payment)으로 돌아오면 같은 선택으로
 * 화면을 다시 만든다.
 *
 * 화면(PaymentViewDTO)이 아니라 선택만 저장하는 이유: 돌아왔을 때 가격·재고·보유 포인트·쿠폰을
 * 그 시점 기준으로 다시 조회해야 한다. 만들어둔 화면을 그대로 되살리면 값이 낡는다.
 */
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PendingCheckoutDTO implements Serializable {

	private static final long serialVersionUID = 1L;

	// 장바구니에서 넘어온 경우
	private List<Long> cartIds;

	// 바로구매로 넘어온 경우
	private Long popId;
	private Long qty;

	// 담긴 시각(epoch ms). 너무 오래된 결제는 되살리지 않는다
	private long savedAt;

	public boolean isFromCart() {
		return cartIds != null && !cartIds.isEmpty();
	}

	public boolean isExpired(long ttlMillis) {
		return System.currentTimeMillis() - savedAt > ttlMillis;
	}
}
