###############################################################################
#
# Quadratic function solver
#
###############################################################################
"""
    lower_quadratic(a::FT, b::FT, c::FT) where {FT<:AbstractFloat}

Return the lower quadratic solution or NaN, given
- `a` Parameter in `a*x^2 + b*x + c = 0`
- `b` Parameter in `a*x^2 + b*x + c = 0`
- `c` Parameter in `a*x^2 + b*x + c = 0`
"""
function lower_quadratic(a::FT, b::FT, c::FT) where {FT<:AbstractFloat}
    discr = b^2 - 4*a*c;

    if discr >= 0
        return (-b - sqrt(discr))/2a
    else
        return FT(NaN)
    end
end
