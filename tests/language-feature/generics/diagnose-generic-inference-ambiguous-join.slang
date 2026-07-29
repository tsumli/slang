//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK):

// A pointer-sized integer may be only 32 bits wide, so `getBaseTypeConversionCost`
// charges `kConversionCost_GeneralConversion` in both directions between it and
// another integer type. Neither type is "better", so the two have no common type
// and the call is rejected whichever order the arguments are written in. Before
// the fix the tie was broken by keeping whichever type was seen first, so
// `pair(u, p)` inferred `T = uint` and `pair(p, u)` `T = intptr_t`.
// See https://github.com/shader-slang/slang/issues/10164.

// The "see declaration" note below is reported once per rejected call.
vector<T, 2> pair<T>(T a, T b)
//CHECK:     ^^^^ see declaration of func pair<T> -> vector<T,2>
//CHECK:     ^^^^ see declaration of func pair<T> -> vector<T,2>
//CHECK:     ^^^^ see declaration of func pair<T> -> vector<T,2>
//CHECK:     ^^^^ see declaration of func pair<T> -> vector<T,2>
{
    return vector<T, 2>(a, b);
}

void test()
{
    uint u = 1;
    intptr_t p = 2;
    int64_t i = 3;
    uintptr_t q = 4;

    pair(u, p);
/*CHECK:
        ^ cannot deduce generic argument
        ^ cannot deduce generic argument for 'T': conflicting requirements 'uint' and 'intptr_t'
*/
    pair(p, u);
/*CHECK:
        ^ cannot deduce generic argument
        ^ cannot deduce generic argument for 'T': conflicting requirements 'intptr_t' and 'uint'
*/
    pair(i, q);
/*CHECK:
        ^ cannot deduce generic argument
        ^ cannot deduce generic argument for 'T': conflicting requirements 'int64_t' and 'uintptr_t'
*/
    pair(q, i);
/*CHECK:
        ^ cannot deduce generic argument
        ^ cannot deduce generic argument for 'T': conflicting requirements 'uintptr_t' and 'int64_t'
*/
}
