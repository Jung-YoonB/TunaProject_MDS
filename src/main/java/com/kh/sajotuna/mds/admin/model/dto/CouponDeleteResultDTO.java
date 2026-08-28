package com.kh.sajotuna.mds.admin.model.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CouponDeleteResultDTO {
	private List<Long> deletedIds;
	private List<Long> blockedIds; // 발급 이력(COUPONHISTORY)이 남아있어 삭제하지 못한 쿠폰
}
