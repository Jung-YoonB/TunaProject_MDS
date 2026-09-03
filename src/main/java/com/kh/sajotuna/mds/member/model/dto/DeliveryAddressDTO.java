package com.kh.sajotuna.mds.member.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

// DELIVERYADDRESS 테이블. 스키마엔 ADDRESS_NAME/DETAIL_ADDRESS 두 컬럼뿐이라(수취인/전화번호/
// 우편번호 컬럼 없음), utill/deliveryAddress.jsp의 우편번호+기본주소+상세주소는 서비스 계층에서
// detailAddress 한 문자열로 합쳐서 저장한다.
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("DeliveryAddressDTO")
public class DeliveryAddressDTO {

	private Long addId;
	private Long memberId;
	private String addressName;
	private String detailAddress;
	private String isDefault; // 'Y'/'N' - CK_ADD_IS_DEFAULT
}
