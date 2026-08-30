package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;

@Mapper
public interface AdminCouponMapper {

	List<CouponDTO> selectAllCoupons();

	int insertCoupon(CouponDTO coupon);

	// couponIds 중 COUPONHISTORY에 발급 이력이 남아있는 것만 추려서 반환 - 삭제 가능 여부 판단용
	List<Long> selectCouponIdsWithHistory(@Param("couponIds") List<Long> couponIds);

	int deleteCoupons(@Param("couponIds") List<Long> couponIds);
}
