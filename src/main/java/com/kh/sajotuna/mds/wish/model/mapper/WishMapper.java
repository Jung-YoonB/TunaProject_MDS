package com.kh.sajotuna.mds.wish.model.mapper;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.wish.model.dto.WishListDTO;
import com.kh.sajotuna.mds.wish.model.dto.findWishInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface WishMapper {
    int insertWish(findWishInfoDTO wishInfoDTO);
    //장바구니에 이미 있는 상품인지 확인
    int findWishById(findWishInfoDTO findWishInfo);

    //장바구니 리스트
    List<WishListDTO> getWishList(Long memberId);

    int removeWish(findWishInfoDTO  findWishInfoDTO);
}
