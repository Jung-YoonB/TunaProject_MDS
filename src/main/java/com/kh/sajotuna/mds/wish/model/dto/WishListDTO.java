package com.kh.sajotuna.mds.wish.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WishListDTO {

    private Long wishId;
    private Long memberId;
    private Long productId;
    private String productName;
    private String titleImage;

    // 찜 화면 카드가 상품 카드(홈/검색)와 같은 모양이라 같은 값들이 필요하다.
    // imagePath + titleImage 를 이어붙인 게 실제 이미지 주소(다른 화면들과 동일한 규칙).
    private String imagePath;
    private int price;
    private double score;
    private int reviewCount;
}
