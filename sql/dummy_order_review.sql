-- ======================================================================
--  주문 / 배송 / 리뷰 테스트 더미 데이터
--  작성: 2026-09-02
--
--  목적
--    현재 DB에 이미 등록된 상품(PRODUCT 130건 / CATEGORY 15개)만 사용해서
--    화면 확인용 회원·주문·배송·리뷰를 만든다.
--    상품 / 카테고리 / 태그 / 등급 / 결제수단은 조회만 하고 절대 건드리지 않는다.
--
--  만들어지는 것
--    1) 카테고리별 대표 상품 1개씩(총 15개)에 리뷰 2~6개   ... 리뷰어 6명
--    2) dummy_buyer : 주문/배송 상태를 전부 훑는 유저       ... 주문 8건
--    3) dummy_zero  : 배송완료 12건 / 리뷰 0건             ... 리뷰 배지 12
--       dummy_many  : 배송완료 12건 / 리뷰 12건 전부 작성   ... 리뷰 배지 0
--
--  계정
--    아이디  dummy_rv01 ~ dummy_rv06 / dummy_buyer / dummy_zero / dummy_many
--    비밀번호는 전부 1234
--    (기존 admin·user01 이 쓰고 있는 BCrypt 해시를 그대로 재사용해서
--     애플리케이션의 PasswordEncoder 설정과 어긋날 여지를 없앴다)
--
--  특징
--    - 상품 ID를 하드코딩하지 않는다. 실행 시점의 CATEGORYDETAIL / OPTIONDETAIL 을
--      조회해서 대표 상품을 고르므로, 상품이 더 늘어난 뒤 다시 돌려도 동작한다.
--    - 0번 정리 블록이 'dummy_' 로 시작하는 계정의 데이터만 지우므로 몇 번이든
--      다시 실행할 수 있다. 실제 회원(admin / user01 / ggdggd)은 건드리지 않는다.
--
--  삭제 순서 근거 (schema.sql 의 FK 삭제 규칙 - reset_category_tag.sql 과 같은 기준)
--    - REVIEW 는 ORDERDETAIL 을 NO ACTION 으로 참조한다
--      → PRODUCTORDER 보다 반드시 먼저 지워야 한다.
--    - POINTHISTORY / COUPONHISTORY 는 PRODUCTORDER 를 NO ACTION 으로 참조한다
--      → 이 둘도 PRODUCTORDER 보다 먼저 지운다.
--    - CART 는 OPTIONDETAIL 을 NO ACTION 으로 참조하지만 여기서는 OPTIONDETAIL 을
--      지우지 않으므로 회원 기준으로만 정리하면 된다.
--
--  실행 : 파일 전체를 한 번에 실행 → 맨 끝 5번 검증 쿼리로 결과 확인
-- ======================================================================


-- 문자열 안의 '&' 를 치환 변수로 해석하지 않도록 (schema.sql 과 동일)
SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;


-- ======================================================================
-- 0. 기존 더미 정리 (재실행 가능하게)
--
--    CASCADE 로 따라 지워지는 것들도 순서를 드러내려고 명시적으로 적었다.
-- ======================================================================

DELETE FROM REVIEWLIKE
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!')
    OR REVIEW_ID IN (SELECT REVIEW_ID FROM REVIEW
                      WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER
                                           WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'));

DELETE FROM REVIEWIMAGE
 WHERE REVIEW_ID IN (SELECT REVIEW_ID FROM REVIEW
                      WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER
                                           WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'));

DELETE FROM REVIEW
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM POINTHISTORY
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM COUPONHISTORY
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM CART
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM WISH
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM DELIVERY
 WHERE ORDER_ID IN (SELECT ORDER_ID FROM PRODUCTORDER
                     WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER
                                          WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'));

DELETE FROM ORDERDETAIL
 WHERE ORDER_ID IN (SELECT ORDER_ID FROM PRODUCTORDER
                     WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER
                                          WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'));

DELETE FROM PRODUCTORDER
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM DELIVERYADDRESS
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM MEMBERPOINT
 WHERE MEMBER_ID IN (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!');

DELETE FROM MEMBER
 WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!';

COMMIT;


-- ======================================================================
-- 1 ~ 4. 더미 생성
-- ======================================================================

DECLARE

    -- ---- 상수 ----------------------------------------------------------

    -- 평문 "1234" 의 BCrypt 해시 (기존 admin / user01 과 동일한 값)
    C_PW        CONSTANT VARCHAR2(100) := '$2a$10$9xqG6JYscfoXl47UMOmseOZDg5F9FX0lDIRQ9x4Rl/C5hzeeYWx8i';

    C_ADDR_NAME CONSTANT VARCHAR2(50)  := '집';
    C_ADDR      CONSTANT VARCHAR2(200) := '서울특별시 강남구 테헤란로 123 메종빌딩 4층';

    -- 주문 시점 등급을 BRONZE(2%)로 가정하고 ORDERDETAIL.GRADE_DIS_AMOUNT 에 넣는다
    C_DIS_RATE  CONSTANT NUMBER := 0.02;


    -- ---- 타입 / 변수 ---------------------------------------------------

    TYPE t_ids   IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_texts IS TABLE OF VARCHAR2(1500);

    v_rv        t_ids;                  -- 리뷰어 6명의 MEMBER_ID
    v_pool      t_ids;                  -- 2·3번 유저가 쓸 POP_ID 풀
    v_pool_n    PLS_INTEGER := 0;       -- 풀에서 몇 개까지 썼는지

    v_buyer     NUMBER;
    v_nick8     NUMBER;
    v_zero      NUMBER;
    v_many      NUMBER;

    v_order     NUMBER;
    v_od        NUMBER;
    v_first_od  NUMBER;
    v_seq       PLS_INTEGER := 0;       -- 리뷰 문구/점수를 돌려쓰기 위한 카운터
    v_cat_cnt   PLS_INTEGER;
    v_rep_cnt   PLS_INTEGER;

    -- 리뷰 본문. REVIEW_TEXT 는 VARCHAR2(1500 BYTE) 라 한글 500자까지 들어간다
    v_txt       t_texts := t_texts(
        '포장이 꼼꼼해서 선물용으로 딱 좋았어요. 받는 분도 아주 만족하셨습니다.',
        '배송이 생각보다 빨라서 좋았습니다. 다음에도 여기서 주문할게요.',
        '사진이랑 실물이 거의 똑같아요. 색감도 화면이랑 차이가 없네요.',
        '가격 대비 구성이 알차요. 부모님 선물로 드렸는데 계속 자랑하십니다.',
        '무난하게 잘 썼습니다. 특별히 흠잡을 데는 없었어요.',
        '기대했던 것보다는 조금 작았지만 품질은 괜찮습니다.',
        '재구매 의사 있습니다. 마감 처리가 깔끔해요.',
        '선물 포장 옵션이 있어서 따로 포장할 필요가 없었어요. 편했습니다.',
        '상자가 살짝 눌려서 왔는데 내용물은 멀쩡했습니다. 배송만 조금 아쉬워요.',
        '주변에서 어디서 샀냐고 많이 물어봤어요. 추천합니다.',
        '설명에 적힌 그대로였습니다. 과장 없이 정직한 상품이에요.',
        '가성비 좋습니다. 하나 더 주문할까 고민 중이에요.'
    );


    -- ---- 헬퍼 ----------------------------------------------------------

    -- 회원 1명 + 포인트 행 + 기본 배송지.
    -- MEMBERPOINT 는 회원가입 로직(MemberMapper.insertPoint)이 항상 같이 만드는 행이라
    -- 없으면 마이페이지 포인트가 NULL 로 나온다.
    FUNCTION new_member(p_login VARCHAR2, p_name VARCHAR2, p_nick VARCHAR2,
                        p_phone VARCHAR2, p_gender CHAR) RETURN NUMBER IS
        v_id NUMBER;
    BEGIN
        SELECT SEQ_MEMBER_ID.NEXTVAL INTO v_id FROM DUAL;

        INSERT INTO MEMBER (MEMBER_ID, MEMBER_NAME, BIRTH, GENDER, LOGIN_ID, LOGIN_PW,
                            NICKNAME, EMAIL, PHONE, ROLE)
        VALUES (v_id, p_name, DATE '1995-03-15', p_gender, p_login, C_PW,
                p_nick, p_login || '@test.local', p_phone, 'USER');

        INSERT INTO MEMBERPOINT (POINT_ID, MEMBER_ID, POINT)
        VALUES (SEQ_POINT_ID.NEXTVAL, v_id, 3000);

        -- 기본 배송지는 회원당 1개만 'Y' 가 허용된다(UX_DELIVERYADDRESS_IS_DEFAULT)
        INSERT INTO DELIVERYADDRESS (ADD_ID, MEMBER_ID, ADDRESS_NAME, DETAIL_ADDRESS, IS_DEFAULT)
        VALUES (SEQ_ADD_ID.NEXTVAL, v_id, C_ADDR_NAME, C_ADDR, 'Y');

        RETURN v_id;
    END;


    FUNCTION new_order(p_member NUMBER, p_status VARCHAR2, p_days_ago NUMBER) RETURN NUMBER IS
        v_id NUMBER;
    BEGIN
        SELECT SEQ_ORDER_ID.NEXTVAL INTO v_id FROM DUAL;

        -- TOTAL_PRICE 는 0으로 넣고 add_item 이 품목을 더할 때마다 누적한다
        INSERT INTO PRODUCTORDER (ORDER_ID, MEMBER_ID, TOTAL_PRICE, ORDER_STATUS, ORDER_DATE,
                                  USED_POINT, PAYMENT_ID, ADDRESS_NAME_FIX, DETAIL_ADDRESS_FIX)
        VALUES (v_id, p_member, 0, p_status, SYSDATE - p_days_ago,
                0,
                1 + MOD(v_id, 3),       -- PAYMENT_ID 1~3 (KAKAOPAY / NAVERPAY / MASTERCARD)
                C_ADDR_NAME, C_ADDR);

        RETURN v_id;
    END;


    -- 주문에 품목 1건 추가. 주문 시점 가격을 PRICE_FIX 에 박아 둔다
    -- (상품 가격이 나중에 바뀌어도 지난 주문서는 그대로 유지되어야 하므로)
    FUNCTION add_item(p_order NUMBER, p_pop NUMBER, p_qty NUMBER) RETURN NUMBER IS
        v_id    NUMBER;
        v_price NUMBER;
        v_dis   NUMBER;
    BEGIN
        SELECT po.OPTION_PRICE INTO v_price
          FROM OPTIONDETAIL od
          JOIN PRODUCTOPTION po ON po.OPTION_ID = od.OPTION_ID
         WHERE od.POP_ID = p_pop;

        v_dis := ROUND(v_price * p_qty * C_DIS_RATE);

        SELECT SEQ_OD_ID.NEXTVAL INTO v_id FROM DUAL;

        INSERT INTO ORDERDETAIL (OD_ID, ORDER_ID, POP_ID, QTY, PRICE_FIX, GRADE_DIS_AMOUNT)
        VALUES (v_id, p_order, p_pop, p_qty, v_price, v_dis);

        UPDATE PRODUCTORDER
           SET TOTAL_PRICE = TOTAL_PRICE + (v_price * p_qty - v_dis)
         WHERE ORDER_ID = p_order;

        RETURN v_id;
    END;


    PROCEDURE set_delivery(p_order NUMBER, p_status VARCHAR2) IS
    BEGIN
        INSERT INTO DELIVERY (DELIVERY_ID, ORDER_ID, COMPANY, TRACKING_NO, DELIVERY_STATUS)
        VALUES (SEQ_DELIVERY_ID.NEXTVAL, p_order,
                CASE MOD(p_order, 3)
                     WHEN 0 THEN 'CJ대한통운'
                     WHEN 1 THEN '한진택배'
                     ELSE        '롯데택배'
                END,
                '1' || LPAD(TO_CHAR(p_order), 11, '0'),
                p_status);
    END;


    -- 2~5점을 섞되 4~5점이 많게(평균 4점대). 별점 평균/분포 표시를 확인하기 위함
    PROCEDURE write_review(p_member NUMBER, p_od NUMBER, p_days_ago NUMBER) IS
        v_score NUMBER;
        v_body  VARCHAR2(1500);
    BEGIN
        v_seq := v_seq + 1;

        v_score := CASE MOD(v_seq, 8)
                        WHEN 0 THEN 2
                        WHEN 1 THEN 3
                        WHEN 2 THEN 5
                        WHEN 3 THEN 4
                        WHEN 4 THEN 5
                        WHEN 5 THEN 3
                        WHEN 6 THEN 5
                        ELSE        4
                   END;

        -- 컬렉션 원소를 INSERT 문 안에서 바로 꺼내면 안 된다.
        -- SQL 엔진은 v_txt(...) 를 함수 호출로 보고(ORA-00904), v_txt.COUNT 는
        -- PL/SQL 전용이라 PLS-00425 가 난다. 먼저 스칼라 변수로 꺼내서 넘긴다.
        v_body := v_txt(1 + MOD(v_seq, v_txt.COUNT));

        INSERT INTO REVIEW (REVIEW_ID, MEMBER_ID, OD_ID, REVIEW_STATUS, VIEW_COUNT,
                            REVIEW_TEXT, SCORE, WRITE_DATE)
        VALUES (SEQ_REVIEW_ID.NEXTVAL, p_member, p_od, 1, MOD(v_seq * 7, 90),
                v_body,
                v_score,
                SYSTIMESTAMP - NUMTODSINTERVAL(p_days_ago, 'DAY'));
    END;


    -- 풀에서 아직 안 쓴 POP_ID 를 하나 꺼낸다.
    -- ORDERDETAIL 에 UK(ORDER_ID, POP_ID) 가 걸려 있어 한 주문 안에 같은 옵션이 두 번
    -- 들어가면 안 된다. 전부 다른 값을 나눠주면 그 제약을 신경 쓸 필요가 없다.
    FUNCTION next_pop RETURN NUMBER IS
    BEGIN
        v_pool_n := v_pool_n + 1;

        IF v_pool_n > v_pool.COUNT THEN
            RAISE_APPLICATION_ERROR(-20001,
                'POP_ID 풀이 부족합니다. 사용 가능한 상품 옵션이 ' || v_pool.COUNT || '개뿐입니다.');
        END IF;

        RETURN v_pool(v_pool_n);
    END;

BEGIN

    -- ------------------------------------------------------------------
    -- 사전 확인 - 상품이 없으면 아래 로직이 조용히 아무것도 안 만들고 끝난다
    -- ------------------------------------------------------------------

    SELECT COUNT(*) INTO v_cat_cnt FROM CATEGORY;

    SELECT COUNT(*) INTO v_rep_cnt
      FROM (SELECT CATEGORY_ID, MIN(PRODUCT_ID) PID FROM CATEGORYDETAIL GROUP BY CATEGORY_ID) x
      JOIN (SELECT PRODUCT_ID, MIN(POP_ID) MPOP FROM OPTIONDETAIL GROUP BY PRODUCT_ID) y
        ON y.PRODUCT_ID = x.PID;

    IF v_rep_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            '등록된 상품(또는 상품 옵션)이 없습니다. 상품 등록 후 다시 실행해 주세요.');
    END IF;

    IF v_rep_cnt < v_cat_cnt THEN
        DBMS_OUTPUT.PUT_LINE('[경고] 카테고리 ' || v_cat_cnt || '개 중 ' || v_rep_cnt ||
                             '개에만 상품+옵션이 있습니다. 나머지 카테고리엔 리뷰가 생기지 않습니다.');
    END IF;

    -- 2·3번 유저가 쓸 POP_ID 풀.
    -- 1번(카테고리 대표 상품)이 쓰는 POP_ID 는 제외한다. 안 그러면 대표 상품의 리뷰 수가
    -- 2~6개를 넘어가서 "카테고리별 2~6개" 조건이 깨진다.
    SELECT POP_ID BULK COLLECT INTO v_pool
      FROM (SELECT od.POP_ID
              FROM OPTIONDETAIL od
             WHERE od.POP_ID NOT IN (
                       SELECT y.MPOP
                         FROM (SELECT CATEGORY_ID, MIN(PRODUCT_ID) PID
                                 FROM CATEGORYDETAIL GROUP BY CATEGORY_ID) x
                         JOIN (SELECT PRODUCT_ID, MIN(POP_ID) MPOP
                                 FROM OPTIONDETAIL GROUP BY PRODUCT_ID) y
                           ON y.PRODUCT_ID = x.PID)
             ORDER BY od.POP_ID)
     WHERE ROWNUM <= 80;


    -- ==================================================================
    -- 1. 카테고리별 대표 상품 1개에 리뷰 2~6개
    --
    --    리뷰어 6명을 만들고, "카테고리마다 정해진 리뷰 수" 이하의 번호를 가진
    --    리뷰어가 그 상품을 산다. 예를 들어 리뷰 5개짜리 카테고리는 리뷰어 1~5번이 산다.
    --    리뷰어 1명당 주문 1건에 여러 품목을 담으므로 다품목 주문 화면도 같이 확인된다.
    -- ==================================================================

    FOR i IN 1 .. 6 LOOP
        v_rv(i) := new_member(
            'dummy_rv0' || i,
            '리뷰어' || i,
            '리뷰어' || i || '호',
            '010-9900-000' || i,            -- PHONE 은 VARCHAR2(13) + UNIQUE
            CASE WHEN MOD(i, 2) = 0 THEN 'F' ELSE 'M' END);
    END LOOP;

    FOR i IN 1 .. 6 LOOP

        v_order := new_order(v_rv(i), 'DELIVERED', 30 + i);

        FOR c IN (
            SELECT y.MPOP AS POP_ID,
                   -- 카테고리 순번에 따라 2,3,4,5,6 을 돌려가며 리뷰 수를 정한다
                   2 + MOD(ROW_NUMBER() OVER (ORDER BY x.CATEGORY_ID) - 1, 5) AS REVIEW_CNT
              FROM (SELECT CATEGORY_ID, MIN(PRODUCT_ID) PID
                      FROM CATEGORYDETAIL GROUP BY CATEGORY_ID) x
              JOIN (SELECT PRODUCT_ID, MIN(POP_ID) MPOP
                      FROM OPTIONDETAIL GROUP BY PRODUCT_ID) y
                ON y.PRODUCT_ID = x.PID
             ORDER BY x.CATEGORY_ID
        ) LOOP

            IF c.REVIEW_CNT >= i THEN
                v_od := add_item(v_order, c.POP_ID, 1 + MOD(i, 2));
                write_review(v_rv(i), v_od, 20 + i);
            END IF;

        END LOOP;

        -- 리뷰를 쓰려면 배송완료여야 한다(ReviewMapper.checkDeliveryStatus)
        set_delivery(v_order, 'DELIVERED');

    END LOOP;


    -- ==================================================================
    -- 2. dummy_buyer - 주문/배송 상태를 전부 훑는 유저
    --
    --    주문 8건으로 아래를 모두 만든다.
    --      - DELIVERY 행이 아예 없는 주문(결제대기 / 결제완료) ... 목록의 LEFT JOIN 경로
    --      - PREPARING / SHIPPED / OUT_FOR_DELIVERY / DELIVERED / CANCELED
    --      - 품목 3개짜리 배송완료 주문 중 1개만 리뷰 작성      ... AUDIT 17번 케이스
    --      - ORDER_STATUS='CART' 주문                          ... 목록에서 빠져야 하는 음성 케이스
    -- ==================================================================

    v_buyer := new_member('dummy_buyer', '상태확인', '상태확인러', '010-9900-0011', 'M');

    -- (1) 결제대기 - DELIVERY 행 없음
    v_order := new_order(v_buyer, 'PAYMENT_WAITING', 1);
    v_od    := add_item(v_order, next_pop, 1);

    -- (2) 결제완료 - DELIVERY 행 없음 (관리자가 아직 배송준비중으로 안 바꾼 상태)
    v_order := new_order(v_buyer, 'PAYMENT_COMPLETED', 2);
    v_od    := add_item(v_order, next_pop, 1);
    v_od    := add_item(v_order, next_pop, 2);

    -- (3) 배송준비중
    v_order := new_order(v_buyer, 'PREPARING', 4);
    v_od    := add_item(v_order, next_pop, 1);
    set_delivery(v_order, 'PREPARING');

    -- (4) 배송중
    v_order := new_order(v_buyer, 'SHIPPED', 6);
    v_od    := add_item(v_order, next_pop, 1);
    v_od    := add_item(v_order, next_pop, 1);
    set_delivery(v_order, 'SHIPPED');

    -- (5) 배송출발
    v_order := new_order(v_buyer, 'SHIPPED', 7);
    v_od    := add_item(v_order, next_pop, 3);
    set_delivery(v_order, 'OUT_FOR_DELIVERY');

    -- (6) 배송완료 + 품목 3개 중 1개만 리뷰 작성
    --     → 주문/배송 목록의 "리뷰 쓰기" 링크가 남은 품목으로 이어져야 한다(AUDIT 17번)
    v_order    := new_order(v_buyer, 'DELIVERED', 15);
    v_first_od := add_item(v_order, next_pop, 1);
    v_od       := add_item(v_order, next_pop, 1);
    v_od       := add_item(v_order, next_pop, 2);
    set_delivery(v_order, 'DELIVERED');
    write_review(v_buyer, v_first_od, 10);

    -- (7) 취소 / 환불
    v_order := new_order(v_buyer, 'CANCELED', 20);
    v_od    := add_item(v_order, next_pop, 1);
    set_delivery(v_order, 'CANCELED');

    -- (8) 장바구니 상태 주문 - 목록 쿼리가 ORDER_STATUS != 'CART' 로 걸러내는지 확인용.
    --     이 주문은 마이페이지 어디에도 보이면 안 된다.
    v_order := new_order(v_buyer, 'CART', 0);
    v_od    := add_item(v_order, next_pop, 1);


    -- ==================================================================
    -- 3. dummy_zero / dummy_many - 리뷰 작성 배지 두 갈래 확인
    --
    --    마이페이지 빠른메뉴 "리뷰 작성" 타일은 쓸 리뷰가 있으면 작성 화면으로,
    --    없으면 주문·배송 목록으로 간다. 두 갈래를 각각 확인할 계정을 만든다.
    --
    --      dummy_zero : 배송완료 12건 / 리뷰 0건  → 배지 12, 타일은 리뷰 작성 화면으로
    --      dummy_many : 배송완료 12건 / 리뷰 12건 → 배지 0,  타일은 주문·배송 목록으로
    --                   (동시에 "내가 쓴 리뷰"가 12건이라 목록/페이징도 확인된다)
    -- ==================================================================

    v_zero := new_member('dummy_zero', '리뷰없음', '리뷰없음이', '010-9900-0012', 'F');

    FOR o IN 1 .. 3 LOOP
        v_order := new_order(v_zero, 'DELIVERED', 40 + o * 3);
        FOR k IN 1 .. 4 LOOP
            v_od := add_item(v_order, next_pop, 1);
        END LOOP;
        set_delivery(v_order, 'DELIVERED');
    END LOOP;

    v_many := new_member('dummy_many', '리뷰다씀', '리뷰다쓴이', '010-9900-0013', 'F');

    FOR o IN 1 .. 3 LOOP
        v_order := new_order(v_many, 'DELIVERED', 60 + o * 3);
        FOR k IN 1 .. 4 LOOP
            v_od := add_item(v_order, next_pop, 1);
            write_review(v_many, v_od, 50 + o);
        END LOOP;
        set_delivery(v_order, 'DELIVERED');
    END LOOP;


    -- ==================================================================
    -- 3-1. dummy_nick8 - 닉네임 최대 길이(8자) 화면 확인용
    --
    --    헤더가 "OOO님"으로 노출하는 값이 이름이 아니라 닉네임이라(#TB006_TC-12),
    --    닉네임이 최대 길이일 때 헤더가 밀리지 않는지 볼 계정이 필요하다.
    --    닉네임 규칙은 MemberDTO / signUp.js / nicknameUpdate 세 곳이 같은 정규식을 쓴다:
    --      ^[가-힣a-zA-Z0-9_]{2,8}$   → 최대 8자
    --    한글이 가장 넓으므로 8자 전부 한글로 채운 것이 최악의 경우다.
    --    주문은 만들지 않는다(헤더/마이페이지 표시만 보면 되므로).
    -- ==================================================================

    v_nick8 := new_member('dummy_nick8', '김여덟', '최대여덟자닉네임', '010-9900-0014', 'F');


    -- ==================================================================
    -- 3-2. 리뷰 좋아요(REVIEWLIKE)
    --
    --    상품 상세의 좋아요 수와 하트 활성 상태는 REVIEWLIKE 를 그대로 읽는다
    --    (detailPage.xml 의 like_count / is_liked). 이 표가 비어 있으면 화면이 전부
    --    0·빈 하트로만 보여서 기능이 죽은 것처럼 보인다.
    --
    --    살아있는 리뷰(REVIEW_STATUS=1)마다 0~6명이 누른 것으로 만든다.
    --    - 누르는 사람은 더미 회원만 쓴다(정리 블록이 더미 기준으로 지우므로).
    --    - UK_REVIEWLIKE(REVIEW_ID, MEMBER_ID) 때문에 같은 사람이 같은 리뷰를 두 번 누르면 안 된다.
    --      한 리뷰당 최대 6명인데 더미 회원은 그보다 많아 서로 겹치지 않는다.
    --    - 자기가 쓴 리뷰에는 누르지 않는다(현실적이지 않아서).
    -- ==================================================================

    DECLARE
        TYPE t_likers IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
        v_likers  t_likers;
        v_idx     PLS_INTEGER;
        v_howmany PLS_INTEGER;
    BEGIN
        SELECT MEMBER_ID BULK COLLECT INTO v_likers
          FROM (SELECT MEMBER_ID FROM MEMBER
                 WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'
                 ORDER BY MEMBER_ID);

        IF v_likers.COUNT < 7 THEN
            RAISE_APPLICATION_ERROR(-20003,
                '좋아요를 누를 더미 회원이 부족합니다(최소 7명 필요).');
        END IF;

        FOR r IN (SELECT REVIEW_ID, MEMBER_ID,
                         ROW_NUMBER() OVER (ORDER BY REVIEW_ID) AS RN
                    FROM REVIEW
                   WHERE REVIEW_STATUS = 1
                   ORDER BY REVIEW_ID) LOOP

            -- 0~6개로 흩는다. 리뷰마다 좋아요 수가 달라야 정렬/표시를 확인할 수 있다
            v_howmany := MOD(r.RN, 7);

            FOR i IN 1 .. v_howmany LOOP
                v_idx := 1 + MOD(r.RN + i, v_likers.COUNT);

                IF v_likers(v_idx) != r.MEMBER_ID THEN
                    INSERT INTO REVIEWLIKE (LIKE_ID, REVIEW_ID, MEMBER_ID)
                    VALUES (SEQ_REVIEW_LIKE_ID.NEXTVAL, r.REVIEW_ID, v_likers(v_idx));
                END IF;
            END LOOP;

        END LOOP;
    END;


    -- ==================================================================
    -- 4. 누적 구매금액 / 등급 맞추기
    --
    --    MEMBER.TOTAL_AMOUNT 와 GRADE_ID 를 실제 주문 합계에 맞춰 둔다.
    --    그래야 마이페이지 등급 배지와 등급 할인율이 데이터와 어긋나지 않는다.
    --    장바구니(CART)와 취소(CANCELED) 주문은 구매금액에서 뺀다.
    -- ==================================================================

    UPDATE MEMBER m
       SET m.TOTAL_AMOUNT = NVL((SELECT SUM(po.TOTAL_PRICE)
                                   FROM PRODUCTORDER po
                                  WHERE po.MEMBER_ID = m.MEMBER_ID
                                    AND po.ORDER_STATUS NOT IN ('CART', 'CANCELED')), 0)
     WHERE m.LOGIN_ID LIKE 'dummy!_%' ESCAPE '!';

    UPDATE MEMBER m
       SET m.GRADE_ID = NVL((SELECT MIN(g.GRADE_ID)
                               FROM GRADE g
                              WHERE m.TOTAL_AMOUNT BETWEEN g.MIN_VAL AND g.MAX_VAL),
                            -- 최고 등급 상한(MAX_VAL)을 넘으면 가장 높은 등급으로
                            (SELECT MAX(GRADE_ID) FROM GRADE))
     WHERE m.LOGIN_ID LIKE 'dummy!_%' ESCAPE '!';


    DBMS_OUTPUT.PUT_LINE('더미 생성 완료. POP_ID 풀 ' || v_pool_n || ' / ' || v_pool.COUNT || ' 사용.');

END;
/

COMMIT;


-- ======================================================================
-- 5. 검증 - 아래 5개 쿼리로 의도대로 들어갔는지 확인한다
-- ======================================================================

-- (A) 만들어진 계정 요약. 배지 두 개는 마이페이지 쿼리와 같은 조건으로 계산한다
SELECT m.LOGIN_ID,
       m.NICKNAME,
       m.TOTAL_AMOUNT,
       g.GRADE_NAME,
       (SELECT COUNT(*) FROM PRODUCTORDER po
         WHERE po.MEMBER_ID = m.MEMBER_ID AND po.ORDER_STATUS != 'CART')       AS 주문건수,
       (SELECT COUNT(*) FROM REVIEW r
         WHERE r.MEMBER_ID = m.MEMBER_ID AND r.REVIEW_STATUS = 1)              AS 작성리뷰,
       -- MemberMapper.countReviewableOrderDetails 와 동일 조건
       (SELECT COUNT(*)
          FROM ORDERDETAIL od
          JOIN PRODUCTORDER po ON po.ORDER_ID = od.ORDER_ID
          JOIN DELIVERY d      ON d.ORDER_ID  = po.ORDER_ID
         WHERE po.MEMBER_ID = m.MEMBER_ID
           AND d.DELIVERY_STATUS = 'DELIVERED'
           AND NOT EXISTS (SELECT 1 FROM REVIEW rv WHERE rv.OD_ID = od.OD_ID)) AS 리뷰배지,
       -- MemberMapper.countActiveDeliveries 와 동일 조건
       (SELECT COUNT(*)
          FROM PRODUCTORDER po
          LEFT JOIN DELIVERY d ON d.ORDER_ID = po.ORDER_ID
         WHERE po.MEMBER_ID = m.MEMBER_ID
           AND po.ORDER_STATUS != 'CART'
           AND (d.DELIVERY_STATUS IS NULL
                OR d.DELIVERY_STATUS NOT IN ('DELIVERED', 'CANCELED')))        AS 진행중배지
  FROM MEMBER m
  LEFT JOIN GRADE g ON g.GRADE_ID = m.GRADE_ID
 WHERE m.LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'
 ORDER BY m.MEMBER_ID;


-- (B) 카테고리별 대표 상품의 리뷰 수와 평균 별점 (리뷰수가 2~6 사이여야 정상)
SELECT c.CATEGORY_ID,
       c.CATEGORY_NAME,
       p.PRODUCT_ID,
       p.PRODUCT_NAME,
       COUNT(r.REVIEW_ID)     AS 리뷰수,
       ROUND(AVG(r.SCORE), 1) AS 평균별점
  FROM CATEGORY c
  JOIN (SELECT CATEGORY_ID, MIN(PRODUCT_ID) PID FROM CATEGORYDETAIL GROUP BY CATEGORY_ID) x
    ON x.CATEGORY_ID = c.CATEGORY_ID
  JOIN PRODUCT p        ON p.PRODUCT_ID   = x.PID
  JOIN OPTIONDETAIL opd ON opd.PRODUCT_ID = p.PRODUCT_ID
  JOIN ORDERDETAIL od   ON od.POP_ID      = opd.POP_ID
  JOIN REVIEW r         ON r.OD_ID = od.OD_ID AND r.REVIEW_STATUS = 1
 GROUP BY c.CATEGORY_ID, c.CATEGORY_NAME, p.PRODUCT_ID, p.PRODUCT_NAME
 ORDER BY c.CATEGORY_ID;


-- (C) dummy_buyer 의 주문별 상태. CART 주문은 화면 목록에 나오면 안 된다
SELECT po.ORDER_ID,
       po.ORDER_STATUS,
       NVL(d.DELIVERY_STATUS, '(배송행 없음)')                                  AS DELIVERY_STATUS,
       po.TOTAL_PRICE,
       (SELECT COUNT(*) FROM ORDERDETAIL od WHERE od.ORDER_ID = po.ORDER_ID)    AS 품목수,
       (SELECT COUNT(*) FROM ORDERDETAIL od JOIN REVIEW r ON r.OD_ID = od.OD_ID
         WHERE od.ORDER_ID = po.ORDER_ID)                                       AS 작성리뷰,
       TO_CHAR(po.ORDER_DATE, 'YYYY-MM-DD')                                     AS 주문일
  FROM PRODUCTORDER po
  LEFT JOIN DELIVERY d ON d.ORDER_ID = po.ORDER_ID
 WHERE po.MEMBER_ID = (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID = 'dummy_buyer')
 ORDER BY po.ORDER_ID;


-- (D) 전체 건수
SELECT (SELECT COUNT(*) FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!')  AS 더미회원,
       (SELECT COUNT(*) FROM PRODUCTORDER po WHERE po.MEMBER_ID IN
              (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'))
                                                                                AS 주문,
       (SELECT COUNT(*) FROM ORDERDETAIL od WHERE od.ORDER_ID IN
              (SELECT ORDER_ID FROM PRODUCTORDER po WHERE po.MEMBER_ID IN
                    (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!')))
                                                                                AS 주문상세,
       (SELECT COUNT(*) FROM REVIEW r WHERE r.MEMBER_ID IN
              (SELECT MEMBER_ID FROM MEMBER WHERE LOGIN_ID LIKE 'dummy!_%' ESCAPE '!'))
                                                                                AS 리뷰
  FROM DUAL;


-- (E) 상품 상세 페이지(detailPage.xml)와 같은 방식의 집계 - 리뷰 많은 상위 10개
SELECT p.PRODUCT_ID,
       p.PRODUCT_NAME,
       COUNT(r.REVIEW_ID)     AS REVIEW_COUNT,
       ROUND(AVG(r.SCORE), 1) AS AVG_SCORE
  FROM PRODUCT p
  JOIN OPTIONDETAIL opd ON opd.PRODUCT_ID = p.PRODUCT_ID
  JOIN ORDERDETAIL od   ON od.POP_ID      = opd.POP_ID
  JOIN REVIEW r         ON r.OD_ID = od.OD_ID
 GROUP BY p.PRODUCT_ID, p.PRODUCT_NAME
 ORDER BY COUNT(r.REVIEW_ID) DESC, p.PRODUCT_ID
 FETCH FIRST 10 ROWS ONLY;


-- ======================================================================
--  추가: 시연용 - 주문/배송 상태 8종 전량 커버 + 관리자 쿠폰 카드 4색 전량 커버
--  작성: 2026-09-03
--
--  목적
--    위 더미로도 채워지지 않는 상태들을 시연 직전에 보강한다.
--    - 결제대기(PAYMENT_WAITING)는 실제 checkout()이 절대 만들지 않는 상태라
--      (곧바로 PAYMENT_COMPLETED로 INSERT함) 이 스크립트로만 만들 수 있다.
--    - 관리자 쿠폰 카드의 "만료" 2색도 등록 API가 과거 종료일을 막아서
--      (AdminCouponServiceImpl.registerCoupon) 마찬가지로 직접 INSERT만 가능하다.
--    - "진행중·미사용" 쿠폰은 아무 제약이 없는 정상 경로라(그냥 등록 후 아무도 안 받으면 됨)
--      실제 관리자 화면(admin/coupon/add)에서 등록했다. 이 파일엔 재현용 INSERT를 안 뒀다 -
--      /admin/coupon/add 에서 종료일만 미래로 아무 쿠폰이나 등록하면 이 상태가 나온다.
--
--  주의: 이 블록은 dummy_rv01~06/dummy_buyer/dummy_zero/dummy_many/dummy_nick8/
--  dummy_admin2/dummy_phonefmt/dummy_dupphone/dummy_sgok 계정이 이미 있어야 한다
--  (본 파일 위쪽 0~3번 블록, 그리고 이후 세션에서 추가된 계정들을 먼저 실행할 것).
--  재고는 위 add_item()과 같은 이유로 건드리지 않는다.
-- ======================================================================

-- 시연용: 주문 상태 8종(결제대기/결제완료/배송준비중/배송중/배송출발/배송완료/취소환불대기중/취소환불완료)
-- 각각 예시를 추가한다. 재고는 dummy_order_review.sql의 add_item()과 동일하게 손대지 않는다
-- (더미 주문은 실제 재고를 갉아먹지 않는 게 이 프로젝트의 기존 관례).
DECLARE
    C_ADDR_NAME CONSTANT VARCHAR2(20) := '집';
    C_ADDR      CONSTANT VARCHAR2(60) := '서울특별시 강남구 테스트로 100, 101동 202호';
    v_order NUMBER; -- PL/SQL 규칙: 서브프로그램 선언 뒤에는 변수 선언을 둘 수 없어 맨 위로 옮김

    FUNCTION mid(p_login VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT MEMBER_ID INTO v FROM MEMBER WHERE LOGIN_ID = p_login;
        RETURN v;
    END;

    -- PAYMENT_ID는 실제 checkout()처럼 1~3(카카오/네이버/마스터카드)을 돌아가며 씀
    FUNCTION new_order(p_member NUMBER, p_status VARCHAR2, p_days_ago NUMBER) RETURN NUMBER IS
        v_id NUMBER;
    BEGIN
        SELECT SEQ_ORDER_ID.NEXTVAL INTO v_id FROM DUAL;
        INSERT INTO PRODUCTORDER (ORDER_ID, MEMBER_ID, TOTAL_PRICE, ORDER_STATUS, ORDER_DATE,
                                  USED_POINT, PAYMENT_ID, ADDRESS_NAME_FIX, DETAIL_ADDRESS_FIX)
        VALUES (v_id, p_member, 0, p_status, SYSDATE - p_days_ago,
                0, 1 + MOD(v_id, 3), C_ADDR_NAME, C_ADDR);
        RETURN v_id;
    END;

    -- 품목 추가. 재고는 안 건드림(dummy_order_review.sql과 동일 관례).
    -- PROCEDURE인 이유: FUNCTION으로 두고 "add_item(v_order,...)"처럼 부르면
    -- 반환값(OD_ID)이 v_order를 덮어써서 다음 add_item이 엉뚱한 ORDER_ID를 참조하게 된다
    -- (실제로 한 번 이렇게 틀려서 ORA-02291 FK 위반이 났다) - 아예 반환값을 없애 원천 차단.
    PROCEDURE add_item(p_order NUMBER, p_pop NUMBER, p_qty NUMBER) IS
        v_id NUMBER; v_price NUMBER;
    BEGIN
        SELECT po.OPTION_PRICE INTO v_price
          FROM OPTIONDETAIL od JOIN PRODUCTOPTION po ON po.OPTION_ID = od.OPTION_ID
         WHERE od.POP_ID = p_pop;

        SELECT SEQ_OD_ID.NEXTVAL INTO v_id FROM DUAL;
        INSERT INTO ORDERDETAIL (OD_ID, ORDER_ID, POP_ID, QTY, PRICE_FIX, GRADE_DIS_AMOUNT)
        VALUES (v_id, p_order, p_pop, p_qty, v_price, 0);

        UPDATE PRODUCTORDER SET TOTAL_PRICE = TOTAL_PRICE + (v_price * p_qty) WHERE ORDER_ID = p_order;
    END;

    PROCEDURE set_delivery(p_order NUMBER, p_status VARCHAR2, p_company VARCHAR2, p_tracking VARCHAR2) IS
    BEGIN
        INSERT INTO DELIVERY (DELIVERY_ID, ORDER_ID, COMPANY, TRACKING_NO, DELIVERY_STATUS)
        VALUES (SEQ_DELIVERY_ID.NEXTVAL, p_order, p_company, p_tracking, p_status);
    END;

BEGIN
    -- ===== 결제대기 5건 (checkout()은 항상 PAYMENT_COMPLETED로 바로 넣어서 실제 앱으로는
    -- 절대 못 만드는 상태 - 결제 PG 확인 대기를 흉내내는 순수 더미) =====
    v_order := new_order(mid('dummy_rv01'), 'PAYMENT_WAITING', 0); add_item(v_order, 71, 1);
    v_order := new_order(mid('dummy_rv02'), 'PAYMENT_WAITING', 0); add_item(v_order, 89, 2);
    v_order := new_order(mid('dummy_rv03'), 'PAYMENT_WAITING', 0); add_item(v_order, 90, 1); add_item(v_order, 101, 1);
    v_order := new_order(mid('dummy_rv04'), 'PAYMENT_WAITING', 0); add_item(v_order, 138, 1);
    v_order := new_order(mid('dummy_rv05'), 'PAYMENT_WAITING', 0); add_item(v_order, 139, 1);

    -- ===== 결제완료 2건 (배송 행 없음 - 관리자가 "결제 완료 처리" 누르기 전 상태) =====
    v_order := new_order(mid('dummy_rv06'), 'PAYMENT_COMPLETED', 1); add_item(v_order, 154, 1);
    v_order := new_order(mid('dummy_buyer'), 'PAYMENT_COMPLETED', 1); add_item(v_order, 49, 2); add_item(v_order, 50, 1);

    -- ===== 배송준비중 2건 =====
    v_order := new_order(mid('dummy_zero'), 'PREPARING', 2); add_item(v_order, 190, 1);
    set_delivery(v_order, 'PREPARING', NULL, NULL);
    v_order := new_order(mid('dummy_many'), 'PREPARING', 2); add_item(v_order, 71, 1); add_item(v_order, 86, 1);
    set_delivery(v_order, 'PREPARING', NULL, NULL);

    -- ===== 배송중 2건 =====
    v_order := new_order(mid('dummy_nick8'), 'SHIPPED', 3); add_item(v_order, 125, 3);
    set_delivery(v_order, 'SHIPPED', 'CJ대한통운', '111122223333');
    v_order := new_order(mid('dummy_admin2'), 'SHIPPED', 3); add_item(v_order, 89, 1); add_item(v_order, 90, 2);
    set_delivery(v_order, 'SHIPPED', '한진택배', '222233334444');

    -- ===== 배송출발 2건 (ORDER_STATUS는 SHIPPED로 합쳐짐 - AdminOrderServiceImpl.DELIVERY_TO_ORDER_STATUS) =====
    v_order := new_order(mid('dummy_phonefmt'), 'SHIPPED', 4); add_item(v_order, 101, 1);
    set_delivery(v_order, 'OUT_FOR_DELIVERY', '롯데택배', '333344445555');
    v_order := new_order(mid('dummy_dupphone'), 'SHIPPED', 4); add_item(v_order, 138, 1); add_item(v_order, 139, 1);
    set_delivery(v_order, 'OUT_FOR_DELIVERY', '로젠택배', '444455556666');

    -- ===== 배송완료 2건 =====
    v_order := new_order(mid('dummy_sgok'), 'DELIVERED', 6); add_item(v_order, 154, 2);
    set_delivery(v_order, 'DELIVERED', '우체국택배', '555566667777');
    v_order := new_order(mid('dummy_rv01'), 'DELIVERED', 6); add_item(v_order, 49, 1); add_item(v_order, 190, 1);
    set_delivery(v_order, 'DELIVERED', 'CJ대한통운', '666677778888');

    -- ===== 취소/환불 대기중 2건 (DELIVERY_STATUS=CANCELED, ORDER_STATUS는 취소 직전 단계로 남음
    -- - admin/order/{id}/complete-cancel을 눌러야 완료로 넘어감) =====
    v_order := new_order(mid('dummy_rv02'), 'SHIPPED', 5); add_item(v_order, 86, 1);
    set_delivery(v_order, 'CANCELED', 'CJ대한통운', '777788889999'); -- 배송 중에 취소 접수, 송장 남아있음
    v_order := new_order(mid('dummy_rv03'), 'PREPARING', 5); add_item(v_order, 88, 1); add_item(v_order, 125, 1);
    set_delivery(v_order, 'CANCELED', NULL, NULL); -- 준비중에 취소, 아직 택배사 배정 전

    -- ===== 취소/환불 완료 2건 =====
    v_order := new_order(mid('dummy_rv04'), 'CANCELED', 7); add_item(v_order, 90, 1);
    set_delivery(v_order, 'CANCELED', NULL, NULL);
    v_order := new_order(mid('dummy_rv05'), 'CANCELED', 7); add_item(v_order, 138, 1); add_item(v_order, 154, 1);
    set_delivery(v_order, 'CANCELED', NULL, NULL);

    COMMIT;
END;
/

-- 시연용: 쿠폰 관리 카드 색상 4종 중 이미 없던 2종(만료-미사용/만료-이력있음)을 채운다.
-- 관리자 등록 API(AdminCouponServiceImpl.registerCoupon)는 "종료일은 오늘 이후여야 한다"고
-- 명시적으로 막고 있어(정상 검증) 만료 쿠폰은 API로는 절대 못 만든다 - 직접 INSERT로만 가능.
DECLARE
    v_coupon_expired_nohist NUMBER;
    v_coupon_expired_hist   NUMBER;
    v_member NUMBER;
BEGIN
    SELECT SEQ_COUPON_ID.NEXTVAL INTO v_coupon_expired_nohist FROM DUAL;
    INSERT INTO COUPON (COUPON_ID, COUPON_NAME, COUPON_VALUE, COUPON_TEXT, CREATED_AT, DEADLINE)
    VALUES (v_coupon_expired_nohist, '시연용 만료 쿠폰(미사용)', 0.1,
            '시연 확인용 - 만료됐고 아무도 받지 않은 쿠폰', SYSDATE - 60, SYSDATE - 30);

    SELECT SEQ_COUPON_ID.NEXTVAL INTO v_coupon_expired_hist FROM DUAL;
    INSERT INTO COUPON (COUPON_ID, COUPON_NAME, COUPON_VALUE, COUPON_TEXT, CREATED_AT, DEADLINE)
    VALUES (v_coupon_expired_hist, '시연용 만료 쿠폰(이력있음)', 0.2,
            '시연 확인용 - 만료됐지만 발급 이력이 남아있는 쿠폰(할인 이력 보존 목적으로 안 지움)',
            SYSDATE - 60, SYSDATE - 30);

    SELECT MEMBER_ID INTO v_member FROM MEMBER WHERE LOGIN_ID = 'dummy_rv06';
    INSERT INTO COUPONHISTORY (CHIST_ID, MEMBER_ID, COUPON_ID, TYPE, CREATED_AT)
    VALUES (SEQ_CHIST_ID.NEXTVAL, v_member, v_coupon_expired_hist, 'ISSUE', SYSDATE - 45);

    COMMIT;
END;
/
