package com.kh.sajotuna.mds.coupon.model;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("getCouponDTO")
public class getCouponDTO {
    private Long memberId;
    private Long couponId;
}
