const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const EMAIL_KEY = 'EMAIL';
const NAME_KEY = 'NAME';
const SOCIAL_TYPE_KEY = 'SOCIAL_TYPE';
const MEMBER_ID_KEY = 'MEMBER_ID';
const STUDENT_NAME_KEY = 'STUDENT_NAME';
const SCHOOL_KEY = 'SCHOOL';
const AGE_KEY = 'AGE';
const GENDER_KEY = 'GENDER';

const Map<String, List<String>> SCHOOL_GRADE_MAP = {
  "근화초등학교": ["1학년", "2학년", "3학년", "4학년", "5학년", "6학년"],
  "동면청소년문화의집": [
    "8세", "9세", "10세", "11세", "12세", "13세", "14세",
    "15세", "16세", "17세", "18세", "19세", "20세", "21세"
  ],
  "영월군청소년문화의집": [
    "8세", "9세", "10세", "11세", "12세", "13세", "14세",
    "15세", "16세", "17세", "18세", "19세", "20세", "21세"
  ],
  "버들중학교": ["1학년", "2학년", "3학년"],
};

const ip = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
