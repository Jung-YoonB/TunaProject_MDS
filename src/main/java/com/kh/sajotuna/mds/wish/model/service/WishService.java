package com.kh.sajotuna.mds.wish.model.service;

import com.kh.sajotuna.mds.wish.model.dto.WishListDTO;
import com.kh.sajotuna.mds.wish.model.dto.findWishInfoDTO;

import java.util.List;

public interface WishService {

    String insertWish(findWishInfoDTO findWishInfoDTO);
    String removeWish(findWishInfoDTO findWishInfoDTO);
    List<WishListDTO> getWishList(Long memberId);
}
