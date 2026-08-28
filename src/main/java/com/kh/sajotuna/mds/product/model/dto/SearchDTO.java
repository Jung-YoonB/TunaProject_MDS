package com.kh.sajotuna.mds.product.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SearchDTO {
    private String keyword;
    private Long tag;
    private Long category;
}
