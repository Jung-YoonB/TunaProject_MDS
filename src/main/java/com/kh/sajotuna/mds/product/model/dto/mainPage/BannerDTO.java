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
@Alias("BannerDTO")
public class BannerDTO {

	// banner = PRODUCTIMAGE.PRODUCT_IMAGE_SAVE_NAME (파일명만)
	// imagePath + banner 를 이어붙인 게 실제 이미지 주소다(상품 카드/주문/리뷰 화면과 동일한 규칙).
	private String imagePath;
	private	String banner;
}
