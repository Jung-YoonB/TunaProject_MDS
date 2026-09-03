// 배송지 추가 화면(utill/deliveryAddress.jsp) - 우편번호 검색 팝업 연동.
// zipcode/address 입력칸은 readonly라 이 팝업으로만 채울 수 있다.
// 이 JS가 빠지면 버튼이 무반응이 되어 배송지 등록 자체가 불가능해진다.
(function () {

    var searchButton = document.getElementById('address-search-button');
    if (!searchButton) return;

    var zipcodeInput = document.getElementById('zipcode');
    var addressInput = document.getElementById('address');
    var detailAddressInput = document.getElementById('detail-address');

    searchButton.addEventListener('click', function () {

        if (typeof daum === 'undefined' || !daum.Postcode) {
            alert('우편번호 검색 서비스를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
            return;
        }

        new daum.Postcode({
            oncomplete: function (data) {
                zipcodeInput.value = data.zonecode;
                addressInput.value = data.address;
                if (detailAddressInput) {
                    detailAddressInput.focus();
                }
            }
        }).open();
    });

})();
