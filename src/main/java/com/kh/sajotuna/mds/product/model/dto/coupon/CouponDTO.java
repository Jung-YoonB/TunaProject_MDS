package com.kh.sajotuna.mds.product.model.dto.coupon;

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
    private String createdAt;
    private String deadline;
}
