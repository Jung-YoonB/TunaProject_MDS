package com.kh.sajotuna.mds.util.dto;

import lombok.Getter;

@Getter
public class PageInfo {
	private int page;
	private int size;
	private int totalCount;
	
	private int totalPages;
	private int startPage;
	private int endPage;
	private boolean hasPrevGroup;
	private boolean hasNextGroup;
	
	private static final int PAGE_GROUP_SIZE = 5;
	
	public PageInfo(int page, int size, int totalCount) {
		this.page = page < 1 ? 1 : page;
		this.size = size;
		this.totalCount = totalCount;
		
		this.totalPages = (int)Math.ceil(totalCount/(double)size);
		
		this.startPage = ((this.page -1)/PAGE_GROUP_SIZE)*PAGE_GROUP_SIZE +1;
		this.endPage = Math.min(startPage + PAGE_GROUP_SIZE -1, totalPages);
		
		this.hasPrevGroup = startPage > 1;
		this.hasNextGroup = endPage < totalPages;
	}
	
	public int getOffset() {
		return (page -1)*size;
	}
}
