package com.kh.sajotuna.mds.admin.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("ProductImageInsertDTO")
public class ProductImageInsertDTO {
	private Long productId;
	private String originalName;
	private String saveName;
	private String path;
	private int titleImageType; // PRODUCT_TITLE_IMAGE: 0=대표, 1=서브(추가), 2=설명
}
