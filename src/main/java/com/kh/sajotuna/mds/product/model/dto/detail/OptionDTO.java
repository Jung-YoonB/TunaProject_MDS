package com.kh.sajotuna.mds.product.model.dto.detail;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
@Alias("OptionDTO")
public class OptionDTO {
	private Long optionId;
	private String optionName;
	private int price;
	private Long popId; // OPTIONDETAIL.POP_ID - 상품 상세페이지 조회 전용, 관리자 등록 흐름에선 안 씀
	private int stock;

	// admin 상품 등록도 이 DTO로 PRODUCTOPTION 행을 만든다(옵션 개수만큼 반복). 같은 테이블을 가리키는
	// DTO가 따로 있어서 이쪽으로 합침(ReviewDTO와 동일한 방식).
	// 등록 시점엔 optionName/price/stock만 채우고 optionId는 selectKey가, popId는 별도 insert가 채운다
}
