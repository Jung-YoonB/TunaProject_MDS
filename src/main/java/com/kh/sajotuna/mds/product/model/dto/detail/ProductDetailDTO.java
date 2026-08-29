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
	
}
