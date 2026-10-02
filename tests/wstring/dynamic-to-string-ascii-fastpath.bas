#include "fbcunit.bi"
SUITE( fbc_tests.wstring_.dynamic_to_string_ascii_fastpath )
TEST( ascii_assign )
 dim a as string=string(64,65): dim w as wstring=a: dim s as string: s=w
 CU_ASSERT_EQUAL(len(s),64)
 for i as integer=1 to len(s): CU_ASSERT_EQUAL(asc(s,i),65): next
END_TEST
TEST( ascii_init )
 dim a as string=chr(1,27,32,65,90,97,122,127): dim w as wstring=a: dim s as string=w
 CU_ASSERT_EQUAL(len(s),8)
 for i as integer=1 to 8: CU_ASSERT_EQUAL(asc(s,i),asc(a,i)): next
END_TEST
TEST( embedded_nul )
 dim w as wstring=wchr(65,0,66,27,127,10,90): dim s as string=w
 dim expect(0 to 6) as integer={65,0,66,27,127,10,90}
 CU_ASSERT_EQUAL(len(s),7)
 for i as integer=0 to 6: CU_ASSERT_EQUAL(asc(s,i+1),expect(i)): next
END_TEST
END_SUITE
