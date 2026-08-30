package com.kh.sajotuna.mds.admin.model.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeleteOrphanFileRequestDTO {
	private String category; // "product" | "review"
	private String fileName;
}
