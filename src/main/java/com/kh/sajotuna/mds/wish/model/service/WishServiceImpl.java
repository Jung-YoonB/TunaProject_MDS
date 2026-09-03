package com.kh.sajotuna.mds.wish.model.service;

import com.kh.sajotuna.mds.wish.model.dto.WishListDTO;
import com.kh.sajotuna.mds.wish.model.dto.findWishInfoDTO;
import com.kh.sajotuna.mds.wish.model.mapper.WishMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@Transactional
@RequiredArgsConstructor
public class WishServiceImpl implements WishService{
    private final WishMapper mapper;
    @Override
    public String insertWish(findWishInfoDTO findWishInfoDTO) {

        int find = mapper.findWishById(findWishInfoDTO);
        if(find>0){
            return "찜 목록에 등록이 되어있는 상품입니다.";
        }
        int result = mapper.insertWish(findWishInfoDTO);
        if(result>0){
            return "상품이 찜 목록에 추가되었습니다.";
        }else {
            return "찜 목록 추가에 실패했습니다.";
        }
    }
    @Override
    public String removeWish(findWishInfoDTO findWishInfoDTO) {
        int remove = mapper.removeWish(findWishInfoDTO);
        if(remove>0){
            return "찜 목록에서 제거되었습니다.";
        }else {
            return "찜 목록 제거에 실패하였습니다.";
        }
    }

    @Override
    public List<WishListDTO> getWishList(Long memberId) {
        List<WishListDTO> list = mapper.getWishList(memberId);

        return  list;
    }
}
