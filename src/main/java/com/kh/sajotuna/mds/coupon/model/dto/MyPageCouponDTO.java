package com.kh.sajotuna.mds.coupon.model.dto;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("MyPageCouponDTO")
public class MyPageCouponDTO {

	private Long couponId;
	private String couponName;
	private Long couponValue;
	private String couponText;
	private LocalDate createdAt;
	private LocalDate deadLine;
	
	private Long chistId;
	
	private String createdAtStr;
	private String deadLineStr;
}
