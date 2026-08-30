package com.kh.sajotuna.mds.product.model.dto.mainPage;

import java.util.List;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Setter
@Alias("MainPageDTO")
public class MainPageDTO {

	private List<ProductListDTO> product;
	private List<BannerDTO> banner;
}
