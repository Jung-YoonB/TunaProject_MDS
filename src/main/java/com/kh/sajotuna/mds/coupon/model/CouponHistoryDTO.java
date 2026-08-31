package com.kh.sajotuna.mds.coupon.model;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// COUPONHISTORY 테이블(쿠폰 발급/사용 이력)을 표현하는 DTO.
// 현재는 어느 쿼리도 이 DTO 전체를 조회하지 않음 - admin 쿠폰 목록은 "이력이 있는지" 여부만 필요해서
// CouponDTO.hasHistory(boolean)로 충분하고, selectCouponIdsWithHistory도 COUPON_ID만 필요해서 List<Long>을 씀.
// 나중에 "이 쿠폰을 누가 언제 어떻게 썼는지" 같은 실제 이력 조회 화면이 생기면 이 DTO를 쓰면 됨.
@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("CouponHistoryDTO")
public class CouponHistoryDTO {
    private Long chistId;
    private Long memberId;
    private Long couponId;
    private Long orderId; // 발급만 되고 아직 주문에 안 쓰였으면 null
    private String type; // ISSUE, USE, EXPIRE, CANCELED 중 하나
    private LocalDate createdAt;
}
