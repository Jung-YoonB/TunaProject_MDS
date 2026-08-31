package com.kh.sajotuna.mds.review.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Alias("ReviewWriteInfoDTO")
public class ReviewWriteInfoDTO {
	private Long odId;
	private String productName;
	private String optionName;
	private int priceFix;
	private String productImagePath;
	private String productImageSaveName;
}
