package com.kh.sajotuna.mds.member.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class MyPageWishDTO {
	
	
	// 위시 테이블
	private Long countWish;  // 전체 유저가 몇 번 찜했는지를 세어 인기순 정렬을 하기 위해
		
	// 프로덕트 테이블
	private String productName;
	
	// 프로덕트 이미지 테이블
	private String productImagePath;
	private String productImageSaveName;
	
	// 리뷰 평점 순 정렬용 (옵션별 리뷰를 상품별 리뷰로 통틀어서 평균 냄) 
	private Long reviewAvg;
	
}