package com.kh.sajotuna.mds.cart.model.service;


import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.ResponseCartListDTO;

import java.util.List;

public interface CartService {

    String insertCartInfo(CartDTO cart);

    ResponseCartListDTO getCartList(Long memberId);
}
