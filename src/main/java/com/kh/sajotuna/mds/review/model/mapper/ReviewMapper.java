package com.kh.sajotuna.mds.review.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;

@Mapper
public interface ReviewMapper {

	// 주문 상세 번호로 DELIVERY_STATUS:DELIVERED (배송 완료 상태)인지 확인
	String checkDeliveryStatus(Long odId);

	// 리뷰 작성 화면에 보여줄 상품/옵션/가격/썸네일 조회 (odId가 해당 memberId 소유일 때만 조회됨)
	ReviewWriteInfoDTO getReviewWriteInfo(@Param("odId") Long odId, @Param("memberId") Long memberId);

	// 해당 주문상세에 리뷰 작성 권한을 이미 썼는지 확인 (REVIEWHISTORY 기준 - 삭제해도 남음)
	int checkReviewExists(@Param("memberId") Long memberId, @Param("odId") Long odId);

	// 리뷰 본문 등록
	int insertReview(ReviewDTO review);

	// 리뷰 작성 이력 기록 (insertReview와 같은 트랜잭션에서 호출할 것)
	int insertReviewHistory(@Param("odId") Long odId, @Param("memberId") Long memberId,
							@Param("reviewId") Long reviewId, @Param("score") int score);

	// 리뷰 삭제 시 이력을 "삭제됨"으로 표시 (행은 남겨서 재작성을 계속 차단)
	int markReviewHistoryDeleted(@Param("reviewId") Long reviewId, @Param("memberId") Long memberId);

	// 리뷰 이미지 추가
	int insertReviewImages(ReviewImagesDTO reviewImages);

	// 마이페이지 "내가 쓴 리뷰" 목록 조회 (페이징)
	List<ReviewDTO> selectMyReviews(@Param("memberId") Long memberId, @Param("offset") int offset, @Param("pageSize") int pageSize);

	// 위 조회 조건(회원)에 해당하는 전체 리뷰 건수 (페이지네이션 계산용)
	int countMyReviews(@Param("memberId") Long memberId);

	// 위 목록에 속한 리뷰들의 사진을 한 번에 조회 (N+1 방지, review.reviewId 기준으로 자바에서 묶어줌)
	List<ReviewImagesDTO> selectReviewImagesByReviewIds(@Param("reviewIds") List<Long> reviewIds);

	// 삭제 전 디스크에서 같이 지울 이미지 파일명 조회
	List<String> selectReviewImageSaveNamesByReviewId(@Param("reviewId") Long reviewId);

	// 본인이 작성한 리뷰만 삭제되도록 WHERE에 memberId도 같이 검증 (영향받은 행이 0이면 소유자가 아니거나 없는 리뷰)
	int deleteReview(@Param("reviewId") Long reviewId, @Param("memberId") Long memberId);
}
