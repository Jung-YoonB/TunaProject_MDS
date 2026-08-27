package com.kh.sajotuna.mds.product.model.dto.mainPage;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ProductListDTO {
	private Long productId;
	private String productTitle;
	private int wishCount;
	private String titleImage;
	private int price;
	private String categoryNames;
	private String tagData;
	private double score;
}
