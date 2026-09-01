package com.kh.sajotuna.mds.admin.model.service;

import java.time.LocalDate;
import java.util.List;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;

public interface AdminCouponService {

	List<CouponDTO> getCoupons();

	void registerCoupon(String couponName, int discountPercent, String couponText, LocalDate startDate,
			LocalDate endDate);

	// 선택한 것 중 하나라도 발급 이력이 있으면 전부 미삭제 - IllegalStateException으로 알림
	void deleteCoupons(List<Long> couponIds);
}
