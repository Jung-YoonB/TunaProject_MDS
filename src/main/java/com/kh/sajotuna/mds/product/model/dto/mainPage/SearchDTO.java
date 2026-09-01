package com.kh.sajotuna.mds.product.model.dto.mainPage;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("SearchDTO")
public class SearchDTO {
    private String keyword;
    private Long tag;
    private Long category;
}
