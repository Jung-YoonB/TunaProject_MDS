package com.kh.sajotuna.mds.product.model.dto.coupon;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("CouponDTO")
public class CouponDTO {
    private Long couponId;
    private String couponName;
    private String couponText;
    private String createdAtStr; // COUPON.CREATED_AT을 'YYYY-MM-DD' 문자열로 포맷한 것 - 스토어프론트 상세페이지 표시용(기존 필드, 이름만 정리)
    private String deadlineStr; // COUPON.DEADLINE을 'YYYY-MM-DD' 문자열로 포맷한 것 - 〃

    // admin.AdminCouponService의 쿠폰 등록/목록도 같은 COUPON 테이블을 다루는데, 그쪽에 따로
    // AdminCouponDTO가 있어서 이쪽으로 합침(ReviewDTO와 동일한 방식). 아래 4개는 admin 전용 필드.
    // createdAt/deadline은 위 Str 필드와 별개로 admin의 날짜 검증(발급일/종료일 비교)에 실제 LocalDate 연산이
    // 필요해서 새로 추가한 것 - 기존 Str 필드의 타입을 바꾼 게 아니라 용도가 다른 필드를 나란히 둔 것
    private double couponValue; // 0~1 사이 소수 (예: 0.10 = 10%) - admin 등록/표시에서 사용, 등록 시 필수
    private LocalDate createdAt;
    private LocalDate deadline;
    private boolean hasHistory; // COUPONHISTORY 발급 이력 존재 여부(admin 목록 조회 시에만 채워짐, 삭제 가능 여부 판단용) - COUPONHISTORY 자체의 원본 행이 필요하면 CouponHistoryDTO를 쓸 것
}
