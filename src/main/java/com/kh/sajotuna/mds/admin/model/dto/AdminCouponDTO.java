package com.kh.sajotuna.mds.admin.model.dto;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("AdminCouponDTO")
public class AdminCouponDTO {
	private Long couponId;
	private String couponName;
	private double couponValue; // 0~1 사이 소수 (예: 0.10 = 10%)
	private String couponText;
	private LocalDate createdAt;
	private LocalDate deadline;
}
