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

	private	String banner;
}
