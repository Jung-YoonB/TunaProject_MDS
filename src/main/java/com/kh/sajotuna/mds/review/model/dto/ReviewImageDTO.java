package com.kh.sajotuna.mds.review.model.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class ReviewImageDTO {
	private Long reviewImageId;
	private Long reviewId;
	private String reviewImageOriginalName;
	private String reviewImageSaveName;
	private String reviewImagePath;
	private int reviewTitleImage;
	private LocalDateTime reviewImageCreateAt;
	
	private String reviewImageCreateAtStr;

}
