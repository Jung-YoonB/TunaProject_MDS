package com.kh.sajotuna.mds.admin.model.service;

import java.time.LocalDate;
import java.util.List;

import com.kh.sajotuna.mds.admin.model.dto.AdminCouponDTO;
import com.kh.sajotuna.mds.admin.model.dto.CouponDeleteResultDTO;

public interface AdminCouponService {

	List<AdminCouponDTO> getCoupons();

	void registerCoupon(String couponName, int discountPercent, String couponText, LocalDate startDate,
			LocalDate endDate);

	CouponDeleteResultDTO deleteCoupons(List<Long> couponIds);
}
