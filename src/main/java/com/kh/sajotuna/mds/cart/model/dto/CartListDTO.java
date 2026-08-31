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
    private String productTitle;
    private String optionName;
    private int optionPrice;
    private int qty;
    private int totalPrice;
}
