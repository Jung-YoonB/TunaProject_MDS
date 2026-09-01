package com.kh.sajotuna.mds.admin.model.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.admin.model.mapper.AdminCouponMapper;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminCouponServiceImpl implements AdminCouponService {

	private final AdminCouponMapper mapper;

	@Override
	public List<CouponDTO> getCoupons() {
		return mapper.selectAllCoupons();
	}

	@Override
	@Transactional
	public void registerCoupon(String couponName, int discountPercent, String couponText, LocalDate startDate,
			LocalDate endDate) {
		// COUPON_NAME은 NOT NULL 컬럼이고, Oracle은 빈 문자열을 NULL로 취급하므로
		// 여기서 막지 않으면 DB 제약조건 위반(ORA-01400)이 그대로 노출된다
		if (couponName == null || couponName.isBlank()) {
			throw new IllegalStateException("쿠폰명은 필수입니다.");
		}
		if (couponName.length() > 50) {
			throw new IllegalStateException("쿠폰명은 50자 이내로 입력해 주세요.");
		}
		// COUPON_TEXT VARCHAR2(300) - 화면에도 maxlength가 있지만 API 직접 호출로 우회 가능해서 서버에도 확인
		if (couponText != null && couponText.length() > 300) {
			throw new IllegalStateException("쿠폰설명은 300자 이내로 입력해 주세요.");
		}
		if (discountPercent < 1 || discountPercent > 100) {
			throw new IllegalStateException("할인율은 1~100 사이의 값이어야 합니다.");
		}

		LocalDate today = LocalDate.now();
		LocalDate effectiveStart = startDate != null ? startDate : today;

		// DEADLINE은 시간 정보 없이 날짜만 가지므로, 종료일을 오늘/발급일과 같은 날로 두면
		// 사실상 발급되자마자 만료되는 것과 같다 - 반드시 그 다음 날 이후여야 함
		if (!endDate.isAfter(today)) {
			throw new IllegalStateException("종료일은 오늘 이후여야 합니다.");
		}
		if (!endDate.isAfter(effectiveStart)) {
			throw new IllegalStateException("종료일은 발급일보다 늦어야 합니다.");
		}

		CouponDTO coupon = new CouponDTO();
		coupon.setCouponName(couponName);
		// discountPercent(1~100)를 소수로 바꿀 때 double 나눗셈 대신 BigDecimal.valueOf(unscaledVal, scale)로
		// 직접 스케일을 지정 - 나눗셈 자체가 없어서 부동소수점 이진 표현 오차가 생길 여지가 없음
		coupon.setCouponValue(BigDecimal.valueOf(discountPercent, 2));
		coupon.setCouponText(couponText);
		coupon.setCreatedAt(effectiveStart);
		coupon.setDeadline(endDate);
		mapper.insertCoupon(coupon);
	}

	@Override
	@Transactional
	public void deleteCoupons(List<Long> couponIds) {
		// COUPONHISTORY에 발급 이력이 남아있으면 FK 제약(CASCADE 없음)으로 삭제가 실패하므로 미리 차단.
		// 선택한 것 중 하나라도 이력이 있으면 나머지도 전부 삭제하지 않는다(전부 삭제 or 전부 미삭제) -
		// 일부만 조용히 삭제되면 관리자가 어떤 게 지워졌는지 헷갈려서 전체 취소가 더 명확함
		List<Long> blockedIds = mapper.selectCouponIdsWithHistory(couponIds);
		if (!blockedIds.isEmpty()) {
			throw new IllegalStateException("발급 이력이 있어 삭제할 수 없는 쿠폰이 포함되어 있습니다.");
		}

		mapper.deleteCoupons(couponIds);
	}
}
