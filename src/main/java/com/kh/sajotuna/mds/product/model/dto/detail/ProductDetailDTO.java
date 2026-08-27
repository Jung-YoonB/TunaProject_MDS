package com.kh.sajotuna.mds.product.model.dto.detail;

import java.util.List;

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
public class ProductDetailDTO {
	private Long productId;
	private String productTitle;
	private String productName;
	private String productContnet;
	private int price;
	private String thumbnail;
	private List<String> image;
	
}
