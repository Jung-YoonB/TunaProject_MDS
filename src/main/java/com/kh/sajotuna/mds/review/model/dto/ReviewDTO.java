package com.kh.sajotuna.mds.review.model.dto;

import java.time.LocalDateTime;
import java.util.List;

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
public class ReviewDTO {
	private Long reviewId;
	private Long memberId;
	private Long odId;
	private Long likeCount;
	private Long viewCount;
	private String reviewText;
	private int score;
	private LocalDateTime writeDate;
	
	private String writeDateStr;
	
	private String writerNicname;	// 작성자 닉네임
	private Long popId;				// 상품 조회용 옵션상세 ID
	
	private List<ReviewImageDTO> reviewImages; // 리뷰 상세에서 보여 줄 이미지 목록
	
}
