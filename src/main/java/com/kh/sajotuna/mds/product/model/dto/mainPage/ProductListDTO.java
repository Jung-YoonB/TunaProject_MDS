package com.kh.sajotuna.mds.product.model.dto.mainPage;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Alias("ProductListDTO")
public class ProductListDTO {
	private Long productId;
	private String productTitle;
	private int wishCount;
	// imagePath + titleImage 를 이어붙인 게 실제 이미지 주소다(주문/리뷰 화면과 동일한 규칙).
	// titleImage만으로는 경로가 없어 이미지가 깨진다.
	private String imagePath;
	private String titleImage;
	private int price;
	private String categoryNames;
	private String tagData;
	private double score;
	// 검색결과 카드의 "장바구니 담기" 퀵버튼이 옵션 선택 없이 바로 담을 때 쓸 대표 옵션
	// (상세 페이지와 같은 기준: OPTION_ID가 가장 작은 옵션 - PRICE와 동일한 행에서 뽑는다).
	private Long popId;
	// 로그인 회원이 이미 찜한 상품인지 - 카드 하트 아이콘 초기 상태용(비로그인/게스트는 항상 false).
	private boolean wished;
}
