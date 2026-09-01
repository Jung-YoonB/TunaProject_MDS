package com.kh.sajotuna.mds.review.model.dto;

import java.util.List;

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
@Alias("ReviewDTO")
public class ReviewDTO {
    private Long reviewId;  //리뷰 아이디
    private String reviewText;  //내용
    private String writeDate;   //작성일
    private String optionName;  //구매한 옵션
    private String productName; //구매한 상품
    private int optionPrice;    //옵션 별 가격
    private String nickname;    //작성자 닉네임
    private int qty;            //구매 개수
    private int likeCount;      //좋아요 수
    private boolean isLiked;

    private Long memberId;  //작성자 회원 ID (리뷰 작성 시 필요)
    private Long odId;      //주문상세 ID (리뷰 작성 시 필요, ORDERDETAIL.POP_ID로 상품 조회 시 조인 키)
    private int score;      //별점 (리뷰 작성 시 필요)

    List<ReviewImagesDTO> reviewImages;     //리뷰 사진

    // 마이페이지 "내가 쓴 리뷰" 목록에서만 채워지는 상품 대표이미지 (product detail 화면은 이미 상품 페이지 자체에
    // 이미지가 있어서 필요 없었음)
    private String productImagePath;
    private String productImageSaveName;
}

