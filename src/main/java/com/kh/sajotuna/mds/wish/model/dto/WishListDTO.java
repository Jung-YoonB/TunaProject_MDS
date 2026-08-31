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
}
