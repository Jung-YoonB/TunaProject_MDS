package com.kh.sajotuna.mds.product.model.dto.detail;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

// 상품 상세 페이지의 "등급 할인" 표시용. GRADE.DISCOUNT_RATE를 order 도메인(OrderMapper의
// selectByMemberIdForPay/selectByMemberIdForCheckout)과 같은 방식으로 조회하되, 상세 페이지는
// 주문/결제와 무관하게 그냥 "지금 로그인한 회원의 등급/할인율"만 필요해서 이 도메인에 따로 둔다.
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("MemberGradeDTO")
public class MemberGradeDTO {

    private String gradeName;
    private double discountRate;
}
