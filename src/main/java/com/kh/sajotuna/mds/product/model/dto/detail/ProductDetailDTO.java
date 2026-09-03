package com.kh.sajotuna.mds.product.model.dto.detail;

import java.util.List;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Setter
@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Alias("ProductDetailDTO")
public class ProductDetailDTO {
	private Long productId;		//상품 id
	private String productTitle;	//상품 이름
	private String productName;		//상품 상세 이름?
	private String productContent;	//상품 설명
	private int price;				//가격
	private double avgScore;		//평균 평점
	private int reviewCount;		//리뷰 수
	private int wishCount;			//상품 찜 횟수
	private String thumbnail;		//상품 썸네일 (대표이미지)
	private List<String> image;		//상품 이미지
	private List<String> detailContents;	//상품 설명 이미지
	private String categoryNames;	//카테고리명(다중, " · "로 연결) - 상세 페이지 카테고리 표시/이동경로용
	private boolean wished;	//로그인 회원이 이미 찜한 상품인지 - 찜 버튼 초기 상태용(비로그인은 항상 false)

	// admin.AdminProductService의 상품 등록도 같은 PRODUCT 테이블에 행을 하나 추가하는데,
	// 같은 테이블을 참조하는 DTO(ProductInsertDTO)가 따로 있어서 이쪽으로 합침(ReviewDTO와 동일한 방식).
	// 등록 시점엔 productId/productTitle/productName/productContent만 채우고 나머지(가격/평점/이미지 등
	// 전부 조회 전용 조인·집계 필드)는 비워둠
}
