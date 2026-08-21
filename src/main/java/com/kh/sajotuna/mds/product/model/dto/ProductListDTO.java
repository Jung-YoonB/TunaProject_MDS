package com.kh.sajotuna.mds.product.model.dto;

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
	private int price;
	private double score;
}
