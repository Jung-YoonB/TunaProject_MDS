package com.kh.sajotuna.mds.coupon.model.dto;

import java.time.LocalDate;

public class CouponDTO {

	private Long couponId;
	private String couponName;
	private Long couponValue;
	private String couponText;
	private LocalDate createdAt;
	private LocalDate deadLine;
	
	private String createdAtStr;
	private String deadLineStr;
}
