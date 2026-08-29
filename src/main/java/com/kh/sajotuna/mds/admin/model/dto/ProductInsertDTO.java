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
@Alias("ProductInsertDTO")
public class ProductInsertDTO {
	private Long productId;
	private String productName;
	private String productContent;
}
