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
	private Long productId;
	private String productTitle;
	private String productName;
	private String productContent;
	private int price;
	private String thumbnail;
	private List<String> image;
	private List<String> detailContents;
	
}
