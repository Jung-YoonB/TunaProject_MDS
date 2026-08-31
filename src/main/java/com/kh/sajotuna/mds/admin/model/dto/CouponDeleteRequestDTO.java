package com.kh.sajotuna.mds.admin.model.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CouponDeleteRequestDTO {
	private List<Long> couponIds;
}
