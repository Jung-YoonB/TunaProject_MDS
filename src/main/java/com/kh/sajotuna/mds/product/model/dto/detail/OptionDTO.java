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

	// admin.AdminProductService의 상품 등록도 PRODUCTOPTION 테이블에 기본 옵션 1개를 만드는데,
	// 같은 테이블을 참조하는 DTO(ProductOptionInsertDTO)가 따로 있어서 이쪽으로 합침(ReviewDTO와 동일한 방식).
	// 등록 시점엔 optionId/optionName/price/stock만 채우고 popId는 비워둠(OPTIONDETAIL 연결은 별도 insert)
}
