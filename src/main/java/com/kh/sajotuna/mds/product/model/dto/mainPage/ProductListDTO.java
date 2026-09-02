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
}
