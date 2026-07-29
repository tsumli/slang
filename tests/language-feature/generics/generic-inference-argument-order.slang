//TEST:INTERPRET(filecheck=CHECK):

// Inferring a generic argument from several call arguments must not depend on
// the order in which those arguments are written. The solver combines the type
// required by each argument with `TryJoinTypes`, folding over the constraints
// in argument order, so the join has to be commutative for the result to be
// stable. See https://github.com/shader-slang/slang/issues/10164.

vector<T, 2> pair<T>(T a, T b)
{
    return vector<T, 2>(a, b);
}

void main()
{
    // `T` must come out as `float` here whichever way round the arguments are
    // written, so the fractional part of `1.5` survives both times. The
    // asymmetry that decides this is `float` -> `bool` costing
    // `kConversionCost_FloatToBoolConversion`, above the general conversion cost
    // that `bool` -> `float` keeps. Inferring `bool` collapses `1.5` to `true`.
    //CHECK: 15 15
    printf("%d %d\n", int(pair(1.5f, false).x * 10.0f), int(pair(false, 1.5f).y * 10.0f));

    // `?:` is declared as a generic `operator?:<T>`, so its result type is
    // inferred through the very same path. Both spellings below select the
    // `float` operand, so both must produce `1.5`.
    bool b = true;
    float f = 1.5f;
    bool cond = true;
    //CHECK: 15 15
    printf("%d %d\n", int((cond ? f : b) * 10.0f), int((!cond ? b : f) * 10.0f));
}
