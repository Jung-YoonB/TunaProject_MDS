package com.kh.sajotuna.mds.admin.model.service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.admin.model.dto.AdminCouponDTO;
import com.kh.sajotuna.mds.admin.model.dto.CouponDeleteResultDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminCouponMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminCouponServiceImpl implements AdminCouponService {

	private final AdminCouponMapper mapper;

	@Override
	public List<AdminCouponDTO> getCoupons() {
		return mapper.selectAllCoupons();
	}

	@Override
	@Transactional
	public void registerCoupon(String couponName, int discountPercent, String couponText, LocalDate startDate,
			LocalDate endDate) {
		if (discountPercent < 1 || discountPercent > 100) {
			throw new IllegalStateException("할인율은 1~100 사이의 값이어야 합니다.");
		}

		AdminCouponDTO coupon = new AdminCouponDTO();
		coupon.setCouponName(couponName);
		coupon.setCouponValue(discountPercent / 100.0);
		coupon.setCouponText(couponText);
		coupon.setCreatedAt(startDate != null ? startDate : LocalDate.now());
		coupon.setDeadline(endDate);
		mapper.insertCoupon(coupon);
	}

	@Override
	@Transactional
	public CouponDeleteResultDTO deleteCoupons(List<Long> couponIds) {
		// COUPONHISTORY에 발급 이력이 남아있으면 FK 제약(CASCADE 없음)으로 삭제가 실패하므로 미리 차단
		List<Long> blockedIds = mapper.selectCouponIdsWithHistory(couponIds);
		List<Long> deletedIds = couponIds.stream()
				.filter(id -> !blockedIds.contains(id))
				.collect(Collectors.toList());

		if (!deletedIds.isEmpty()) {
			mapper.deleteCoupons(deletedIds);
		}

		return new CouponDeleteResultDTO(deletedIds, blockedIds);
	}
}
