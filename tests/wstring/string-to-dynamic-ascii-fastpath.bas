#include "fbcunit.bi"
SUITE( fbc_tests.wstring_.string_to_dynamic_ascii_fastpath )
TEST( ascii_assign )
 dim s as string = "ASCII-0123456789-xyz": dim w as wstring: w=s
 CU_ASSERT_EQUAL(len(w),len(s))
 for i as integer=1 to len(s): CU_ASSERT_EQUAL(asc(w,i),asc(s,i)): next
END_TEST
TEST( ascii_init )
 dim s as string=chr(1,27,32,65,90,97,122,127): dim w as wstring=s
 CU_ASSERT_EQUAL(len(w),8)
 for i as integer=1 to 8: CU_ASSERT_EQUAL(asc(w,i),asc(s,i)): next
END_TEST
TEST( embedded_nul )
 dim s as string=chr(65,0,66,27,127,10,90): dim w as wstring=s
 CU_ASSERT_EQUAL(len(w),7)
 for i as integer=1 to 7: CU_ASSERT_EQUAL(asc(w,i),asc(s,i)): next
END_TEST
END_SUITE
