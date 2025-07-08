-- 데이터베이스가 존재하지 않으면 생성
CREATE DATABASE IF NOT EXISTS chat_db;
USE chat_db;

-- 사용자 테이블 생성
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 리프레시 토큰 테이블
CREATE TABLE refresh_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(512) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 채팅방 테이블 생성
CREATE TABLE chat_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 채팅 메시지 테이블 생성
CREATE TABLE chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    chat_room_id INT NOT NULL,
    sender_type ENUM('user', 'ai') NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE
);

-- 목 데이터 삽입

-- 사용자 데이터 삽입
INSERT INTO users (username, email, password_hash, nickname, role, is_active, last_login_at) VALUES
('testuser1', 'user1@example.com', 'hashed_password_1', '테스트유저1', 'user', TRUE, '2025-07-07 10:00:00'),
('testuser2', 'user2@example.com', 'hashed_password_2', '테스트유저2', 'user', TRUE, '2025-07-08 11:30:00'),
('testuser3', 'user3@example.com', 'hashed_password_3', '테스트유저3', 'user', TRUE, '2025-07-08 14:20:00'),
('testuser4', 'user4@example.com', 'hashed_password_4', '비활성유저', 'user', FALSE, NULL),
('testuser5', 'admin@example.com', 'hashed_password_admin', '관리자', 'admin', TRUE, '2025-07-08 09:00:00');

-- 리프레시 토큰 데이터 삽입
INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES
(1, 'mock_refresh_token_for_user1', '2025-08-01 00:00:00'),
(2, 'mock_refresh_token_for_user2_revoked', '2025-07-20 00:00:00'),
(3, 'mock_refresh_token_for_user3', '2025-08-05 00:00:00');

-- 채팅방 데이터 삽입 (사용자별로 2개씩)
INSERT INTO chat_rooms (user_id, title) VALUES
(1, '오늘 하루 어땠나요?'),
(1, '요즘 나의 가장 큰 고민'),
(2, '새로운 시작에 대한 생각'),
(2, '최근에 나를 웃게 한 일'),
(3, '미래에 대한 불안감'),
(3, '관계에 대한 고민'),
(4, '직장 스트레스 해소법'),
(4, '나를 위한 작은 성취'),
(5, '여행 계획 세우기'),
(5, '최근에 본 영화 이야기');

-- 채팅 메시지 대량 생성

-- 채팅방 1: 불안감 상담 (testuser1)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(1, 'user', '안녕하세요. 요즘 별일 없는데도 자꾸 불안하고, 밤에 잠을 잘 못 자요.'),
(1, 'ai', '안녕하세요. 마음이 많이 힘드셨겠어요. 그런 감정이 드는 데에는 여러 이유가 있을 수 있어요. 언제부터 그런 느낌을 받으셨나요?'),
(1, 'user', '한 2주 정도 된 것 같아요. 특별한 계기는 없는 것 같은데...'),
(1, 'ai', '그렇군요. 혹시 잠들기 전에 스마트폰을 오래 보시거나, 카페인이 든 음료를 드시지는 않나요? 수면 환경도 중요하거든요.'),
(1, 'user', '생각해보니 자기 직전까지 유튜브를 보는 것 같아요. 그것도 영향이 있을까요?'),
(1, 'ai', '네, 충분히 그럴 수 있습니다. 스마트폰의 블루라이트는 뇌를 각성시켜 수면을 방해할 수 있어요.'),
(1, 'user', '그럼 어떻게 하는 게 좋을까요?'),
(1, 'ai', '잠들기 1시간 전부터는 스마트폰 대신 가벼운 스트레칭이나 명상을 해보시는 건 어떨까요?'),
(1, 'user', '명상이요? 한번도 안 해봤는데... 좋은 방법이네요. 오늘 밤부터 한번 시도해봐야겠어요.'),
(1, 'ai', '작은 시도가 큰 변화를 만들 수 있습니다. 꾸준히 해보시고, 마음이 편안해지셨으면 좋겠어요.');

-- 채팅방 2: 서비스 정책 문의 (testuser1)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(2, 'user', '서비스를 한 달만 사용하고 싶은데, 연간 구독밖에 없나요?'),
(2, 'ai', '현재 정규 플랜은 연간 구독만 제공하고 있습니다. 특별 프로모션으로 월간 플랜이 제공될 때가 있으니 공지사항을 확인해주세요.'),
(2, 'user', '그렇군요. 만약 연간 구독을 하다가 중간에 해지하면 환불받을 수 있나요?'),
(2, 'ai', '네, 사용 기간을 제외한 나머지 기간에 대해 일할 계산되어 환불됩니다. 자세한 내용은 환불 정책 문서를 참고해주세요.'),
(2, 'user', '환불 정책 문서는 어디서 볼 수 있죠?'),
(2, 'ai', '홈페이지 하단의 `이용약관` 메뉴에서 확인하실 수 있습니다.'),
(2, 'user', '알겠습니다. 생각 좀 해봐야겠네요.'),
(2, 'ai', '천천히 살펴보시고 결정하세요.'),
(2, 'user', '친절한 답변 감사합니다.'),
(2, 'ai', '별말씀을요. 궁금한 점이 있다면 언제든 문의해주세요.');

-- 채팅방 3: 일상 대화 (testuser2)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(3, 'user', '오늘 날씨 정말 좋네요.'),
(3, 'ai', '제가 날씨를 직접 느낄 수는 없지만, 좋은 날씨라니 기분이 좋네요! 특별한 계획 있으신가요?'),
(3, 'user', '아니요, 그냥 공원에 가서 좀 걸으려고요.'),
(3, 'ai', '산책은 정말 좋은 생각이에요. 여유로운 시간을 보내시길 바랍니다.'),
(3, 'user', '고마워요. 당신은 오늘 뭐 할 건가요?'),
(3, 'ai', '저는 항상 이곳에서 당신처럼 멋진 분들과 대화하며 데이터를 학습하고 있답니다.'),
(3, 'user', '그것도 재밌겠네요.'),
(3, 'ai', '네, 매일 새로운 것을 배우는 것은 아주 즐거운 일이에요.'),
(3, 'user', '좋은 하루 보내세요!'),
(3, 'ai', '당신도요! 즐거운 산책 되세요.');

-- 채팅방 4: 영화 추천 (testuser2)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(4, 'user', '마음이 따뜻해지는 영화를 보고 싶어요.'),
(4, 'ai', '그렇다면 `리틀 포레스트`나 `패딩턴` 같은 영화는 어떠세요? 보는 내내 미소를 짓게 될 거예요.'),
(4, 'user', '아, 둘 다 들어봤어요. 어떤 내용인가요?'),
(4, 'ai', '`리틀 포레스트`는 도시 생활에 지친 주인공이 고향으로 돌아와 사계절을 보내며 자신을 찾아가는 이야기이고, `패딩턴`은 사랑스러운 곰의 좌충우돌 런던 적응기랍니다.'),
(4, 'user', '둘 다 제 취향일 것 같아요! 오늘은 `리틀 포레스트`를 봐야겠네요.'),
(4, 'ai', '분명 만족하실 거예요. 따뜻한 위로를 받으시길 바랍니다.'),
(4, 'user', '고마워요. 추천 덕분에 기분 좋은 저녁을 보낼 수 있겠어요.'),
(4, 'ai', '별말씀을요. 즐거운 관람 되세요!'),
(4, 'user', '네!'),
(4, 'ai', '다음에 또 다른 영화가 보고 싶어지면 찾아주세요.');

-- 채팅방 5: 요리 레시피 (testuser3)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(5, 'user', '집에 있는 재료로 만들 수 있는 간단한 요리 없을까요?'),
(5, 'ai', '물론이죠! 어떤 재료를 가지고 계신가요?'),
(5, 'user', '계란, 양파, 스팸, 밥이 있어요.'),
(5, 'ai', '그렇다면 맛있는 스팸 계란 볶음밥을 만들 수 있겠네요!'),
(5, 'user', '레시피를 알려주세요.'),
(5, 'ai', '기름을 두른 팬에 양파와 스팸을 볶다가, 밥을 넣고 간장으로 간을 한 뒤 마지막에 계란 스크램블을 섞어주면 완성입니다.'),
(5, 'user', '정말 간단하네요. 파는 넣지 않아도 되나요?'),
(5, 'ai', '파를 넣으면 풍미가 더 좋아지지만, 없어도 충분히 맛있습니다.'),
(5, 'user', '좋아요, 오늘 저녁은 그걸로 해야겠어요. 고마워요!'),
(5, 'ai', '맛있게 만들어 드세요!');

-- 채팅방 6: 관계 상담 (testuser3)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(6, 'user', '친구랑 사소한 일로 다퉜는데, 어떻게 화해해야 할지 모르겠어요. 제가 먼저 연락하기엔 자존심이 상해요.'),
(6, 'ai', '친구와 다툰 후에 먼저 연락하기란 참 어려운 일이죠. 자존심도 상하고, 어떻게 말을 꺼내야 할지 막막하게 느껴지실 거예요.'),
(6, 'user', '맞아요. 그냥 이대로 멀어질까 봐 걱정도 되고요.'),
(6, 'ai', '그 친구분과의 관계를 소중하게 생각하고 계시는군요. 때로는 "그때 이런 점은 내가 미안했어"라는 진솔한 한마디가 어색한 침묵을 깨는 좋은 시작이 될 수 있어요.'),
(6, 'user', '먼저 사과할 용기가 필요하겠네요.'),
(6, 'ai', '용기라기보다는, 그 친구와의 좋은 관계를 이어가고 싶은 마음의 표현이라고 생각해보면 어떨까요? 진심은 분명 통할 거예요.');

-- 채팅방 7: 직장 스트레스 (testuser4)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(7, 'user', '직장 상사 때문에 스트레스가 너무 심해요. 매일 지적만 하고, 제 의견은 들어주지도 않아요.'),
(7, 'ai', '매일 그런 상황을 겪으신다니 정말 힘드시겠어요. 감정적으로 많이 지치셨을 것 같아요.'),
(7, 'user', '네, 이제 회사 가는 게 두려울 정도예요. 제가 잘못하고 있는 건가 하는 자책도 들고요.'),
(7, 'ai', '자신을 탓하지 않으셨으면 좋겠어요. 그런 상황에서는 누구나 위축되고 자신감이 떨어지기 마련이에요.'),
(7, 'user', '어떻게 대처해야 할 지 모르겠어요.'),
(7, 'ai', '우선 스트레스를 해소할 수 있는 자신만의 방법을 찾아보는 건 어떨까요? 퇴근 후에 좋아하는 운동을 하거나, 친구를 만나거나, 완전히 다른 취미에 몰두해보는 거죠.'),
(7, 'user', '계속 스트레스 생각만 했는데, 다른 곳으로 주의를 돌려봐야겠네요.'),
(7, 'ai', '네, 잠시라도 회사와 자신을 분리하는 시간이 꼭 필요해요. 그리고 상사의 피드백은 ''나에 대한 공격''이 아니라, ''업무에 대한 코멘트''라고 객관적으로 생각하려고 노력해보세요.'),
(7, 'user', '객관적으로 생각하기... 쉽진 않겠지만 노력해볼게요. 고마워요.'),
(7, 'ai', '혼자 끙끙 앓는 것보다 이렇게 이야기하는 것만으로도 조금은 도움이 되셨길 바랍니다. 언제든 답답할 때 찾아주세요.');

-- 채팅방 8: 자존감 문제 (testuser4)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(8, 'user', '저는 자존감이 너무 낮은 것 같아요. 남들이랑 자꾸 비교하게 되고, 제가 너무 부족하게 느껴져요.'),
(8, 'ai', '자신을 다른 사람과 비교하며 힘들어하고 계시는군요. 그런 감정 때문에 많이 괴로우셨겠어요.'),
(8, 'user', '네, SNS를 볼 때마다 더 심해지는 것 같아요. 다들 행복하고 대단해 보이는데 저만 초라한 느낌이에요.'),
(8, 'ai', 'SNS는 대부분 다른 사람의 가장 행복하고 좋은 순간만을 보여준다는 점을 기억하는 것이 중요해요. 보이는 것이 전부는 아니랍니다.'),
(8, 'user', '머리로는 아는데, 마음이 잘 안 따라줘요.'),
(8, 'ai', '그렇다면 아주 작은 성공 경험을 매일 기록해보는 건 어떨까요? `아침에 5분 일찍 일어나기`나 `하루에 물 8잔 마시기`처럼 아주 사소한 것이라도 괜찮아요.'),
(8, 'user', '그게 자존감을 높이는 데 도움이 되나요?'),
(8, 'ai', '`나도 할 수 있다`는 작은 성공들이 쌓이면, 스스로에 대한 긍정적인 인식이 생기고 자신감이 붙게 됩니다. `성취 다이어리`를 써보는 거죠.'),
(8, 'user', '성취 다이어리라... 재미있겠는데요? 오늘부터 당장 시작해볼게요.'),
(8, 'ai', '좋은 생각이에요! 꾸준히 기록하다 보면 분명 긍정적인 변화를 느끼실 수 있을 거예요. 응원하겠습니다!');

-- 채팅방 9: 여행 계획 (testuser5)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(9, 'user', '요즘 제주도 날씨는 어떤가요? 다음 주에 여행 가거든요.'),
(9, 'ai', '제가 실시간 날씨 정보는 제공해드릴 수 없지만, 일반적으로 해당 시기 제주도는 따뜻하고 화창한 날이 많습니다. 하지만 일교차가 클 수 있으니 겉옷을 챙기는 것이 좋습니다.'),
(9, 'user', '알겠습니다. 렌터카 없이 뚜벅이로 여행하기 좋은 코스 추천해주세요.'),
(9, 'ai', '뚜벅이 여행이라면 버스 노선이 잘 되어 있는 해안도로를 따라가는 코스를 추천합니다. 예를 들어, 함덕 해변에서 시작해서 월정리, 세화 해변으로 이어지는 동쪽 해안 코스는 경치가 아름답습니다.'),
(9, 'user', '좋은 정보네요. 맛집도 그 근처에 많을까요?'),
(9, 'ai', '네, 해당 코스에는 흑돼지, 해물라면 등 제주 특색 음식을 맛볼 수 있는 유명한 맛집들이 즐비해 있습니다.'),
(9, 'user', '계획 짜는 데 정말 큰 도움이 됐어요.'),
(9, 'ai', '성공적인 여행 계획을 세우는 데 도움이 되어 기쁩니다.'),
(9, 'user', '감사합니다!'),
(9, 'ai', '즐거운 제주 여행 되시길 바랍니다!');

-- 채팅방 10: 오늘의 운세 (testuser5)
INSERT INTO chat_messages (chat_room_id, sender_type, content) VALUES
(10, 'user', '오늘의 운세 좀 봐줘.'),
(10, 'ai', '저는 실제 점성술사는 아니지만, 재미로 생성해 드릴 수는 있어요!'),
(10, 'user', '응, 재미로 보는 거지. 말해줘.'),
(10, 'ai', '오늘은 예상치 못한 곳에서 작은 행운이 찾아올 수 있습니다. 동쪽에서 오는 귀인을 만나면 더욱 좋을 거예요.'),
(10, 'user', '오, 정말? 금전운은 어때?'),
(10, 'ai', '불필요한 지출을 삼가고 계획적인 소비를 한다면, 현재의 재정 상태를 안정적으로 유지할 수 있을 것입니다.'),
(10, 'user', '재미있네. 참고할게.'),
(10, 'ai', '어디까지나 재미로 봐주세요!'),
(10, 'user', '알았어, 고마워.'),
(10, 'ai', '오늘 하루 행운이 가득하시길 바랍니다!'); 