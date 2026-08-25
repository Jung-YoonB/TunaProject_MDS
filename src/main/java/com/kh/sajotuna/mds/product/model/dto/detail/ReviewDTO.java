package com.kh.sajotuna.mds.product.model.dto.detail;

import lombok.*;

import java.util.List;

@Getter
@Setter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class ReviewDTO {
    private Long reviewId;
    private String reviewText;
    private String writeDate;
    private String optionName;
    private String productName;
    private int optionPrice;
    private String nickname;
    private int qty;

    List<ReviewImagesDTO> reviewImages;
}
