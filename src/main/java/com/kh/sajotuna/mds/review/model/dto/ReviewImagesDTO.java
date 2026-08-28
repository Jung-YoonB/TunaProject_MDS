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
@NoArgsConstructor
@AllArgsConstructor
@Alias("ReviewImagesDTO")
public class ReviewImagesDTO {
    private Long reviewId;
    private String reviewImage; //REVIEW_IMAGE_SAVE_NAME

    private String reviewImageOriginalName; //리뷰 작성 시 필요 (원본 파일명)
    private String reviewImagePath;         //리뷰 작성 시 필요 (저장 경로)
    private int reviewTitleImage;           //리뷰 작성 시 필요 (대표 이미지 여부 0/1)

}

