#include "arrayRegion.h"
#include <boost/lexical_cast.hpp>


namespace Backstroke
{

void SymbolicRepresentation::setValue(SgValueExp* valExp) 
{
    if (SgUnsignedIntVal* uintVal = isSgUnsignedIntVal(valExp))
        constant = (int)uintVal->get_value();
    else if (SgIntVal* intVal = isSgIntVal(valExp))
        constant = (int)intVal->get_value();
    else
        ROSE_ASSERT(false);
}


std::string ArrayRegion::toString() const
{
    switch (type)
    {
    case SingleElement:
        return "{" + var1.toString() + "}";
    case DiffSingleElement:
        return "!{" + var1.toString() + "}";
    case ClosedInterval:
        return "[" + var1.toString() + ", " + var2.toString() + "]";
    case DiffClosedInterval:
        return "![" + var1.toString() + ", " + var2.toString() + "]";
    default:
        return "";
    }
}


} // end of namespace Backstroke
