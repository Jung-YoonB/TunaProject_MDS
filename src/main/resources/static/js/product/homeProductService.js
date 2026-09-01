// 홈 "인기 선물" 목록 데이터 조회 - 아직 실제 상품 목록 API가 없어서(홈페이지 자체가
// 정적 목업 단계), 아래 목업 배열을 페이지 단위로 잘라서 반환하는 방식으로 대체한다.
// 나중에 실제 백엔드(ProductService)가 준비되면 fetchProducts()의 내부 구현만
// fetch('/api/products?offset=...&limit=...') 같은 실제 호출로 교체하면 되고,
// Promise를 반환하는 시그니처는 그대로 유지되므로 호출부(views/home.js)는 안 건드려도 된다.
(function () {

    var PAGE_SIZE = 8;

    var MOCK_PRODUCTS = [
        { name: '프리미엄 선물세트', desc: '정성을 담은 특별한 구성', price: '49,000원', rating: '4.9', reviewCount: '1,245', wishCount: '342', alt: false },
        { name: '한우 선물세트', desc: '소중한 분께 전하는 깊은 맛', price: '89,000원', rating: '4.9', reviewCount: '892', wishCount: '567', alt: true },
        { name: '건강 선물세트', desc: '매일의 건강을 위한 따뜻한 선택', price: '35,000원', rating: '4.8', reviewCount: '652', wishCount: '218', alt: false },
        { name: '프리미엄 디저트', desc: '달콤한 마음을 담은 디저트', price: '28,000원', rating: '4.9', reviewCount: '1,103', wishCount: '489', alt: true },
        { name: '명품 향수 세트', desc: '은은하게 남는 특별한 순간', price: '120,000원', rating: '4.7', reviewCount: '341', wishCount: '205', alt: false },
        { name: '수제 베이커리 세트', desc: '갓 구운 듯한 정성 가득 구성', price: '32,000원', rating: '4.8', reviewCount: '567', wishCount: '178', alt: true },
        { name: '홍삼 정과 세트', desc: '몸을 생각한 건강한 선물', price: '65,000원', rating: '4.9', reviewCount: '789', wishCount: '312', alt: false },
        { name: '와인 선물세트', desc: '특별한 날을 더 특별하게', price: '95,000원', rating: '4.6', reviewCount: '234', wishCount: '156', alt: true }
    ];

    // offset/limit 기반 - 실제 상품 수를 넘어가면 목업 배열을 순환(modulo)해서 채운다.
    // (진짜 무한 카탈로그가 아니라 목업 8종을 반복 노출하는 임시 방편임에 유의)
    function fetchProducts(offset, limit) {
        var items = [];
        for (var i = 0; i < limit; i++) {
            items.push(MOCK_PRODUCTS[(offset + i) % MOCK_PRODUCTS.length]);
        }
        return Promise.resolve(items);
    }

    window.HomeProductService = {
        PAGE_SIZE: PAGE_SIZE,
        fetchProducts: fetchProducts
    };

})();
