package com.kh.sajotuna.mds.product.model.dto.detail.Review;

import lombok.*;

import java.util.List;

@Getter
@Setter
@ToString
@AllArgsConstructor
@NoArgsConstructor
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

    List<ReviewImagesDTO> reviewImages;     //리뷰 사진
}
