package com.kh.sajotuna.mds.cart.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CartListDTO {
    private Long cartId;
    private Long memberId;
    private Long popId; // 개별 삭제(CartController.removeCart는 memberId+popId로 지운다) 및 수량 변경용
    private String productTitle;
    private String optionName;
    private int optionPrice;
    private int qty;
    private int totalPrice;
    private String titleImage;
}
