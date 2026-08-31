package com.kh.sajotuna.mds.wish.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.ibatis.type.Alias;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("findWishInfoDTO")
public class findWishInfoDTO {
    private Long memberId;
    private Long productId;
}
