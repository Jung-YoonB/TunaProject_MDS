// 관리자 - 상품 등록: 서버 통신을 담당하는 비즈니스 로직.
// DOM을 직접 건드리지 않고, addProduct.jsp가 쓰는 인터랙션 스크립트(views/addProduct.js)에서
// window.AdminProductService를 통해 호출한다.
(function () {

    function registerProduct(url, formData) {
        return fetch(url, {
            method: 'POST',
            body: formData
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '상품 등록에 실패했습니다.');
                }
                return result;
            });
    }

    window.AdminProductService = {
        registerProduct: registerProduct
    };

})();
