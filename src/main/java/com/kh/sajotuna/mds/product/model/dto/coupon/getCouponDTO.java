package com.kh.sajotuna.mds.product.model.dto.coupon;

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
