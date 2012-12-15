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


SgExpression* SymbolicRepresentation::buildVarExpression() const
{
    if (constant >= 0)
        return SageBuilder::buildIntVal(constant);
    return var.getVarRefExp();
}

std::string ArrayRegion::toString() const
{
    switch (type)
    {
    case Universal:
        return "U";
    case SingleElement:
        return (diff ? "!{" : "{") + var1.toString() + "}";
    case ClosedInterval:
        return (diff ? "![" : "[") + var1.toString() + ", " + var2.toString() + "]";
    case Empty:
        return "Empty";
    default:
        return "Unknown";
    }
}


bool ArrayRegion::isInductionVar() const
{
    if (type != SingleElement || diff) return false;
    
    std::string name = var1.var.name[0]->get_name();
    
    if (name == "i" || name == "j" || name == "k")
        return true;
    
    return false;
}

ArrayRegion operator & (const ArrayRegion& r1, const ArrayRegion& r2)
{
    if (r1 == r2)
        return r1;
    if (r1.isEmpty() || r2.isEmpty())
        return ArrayRegion(Empty);
    if (r1.type == Universal && !r1.diff)
        return r2;
    if (r2.type == Universal && !r2.diff)
        return r1;
    if (r1.type == SingleElement && r2.type == SingleElement &&
        r2.diff != r1.diff)
    {
        if (r1.var1 == r2.var1)
            return ArrayRegion(Empty);
        else
        {
            if (r2.diff)
                return r1;
            else
                return r2;
        }
    }
    //ROSE_ASSERT(false);    
    return ArrayRegion(Empty);
}

ArrayRegion operator | (const ArrayRegion& r1, const ArrayRegion& r2)
{
    if (r1 == r2)
        return r1;
    if (r1.isEmpty())
        return r2;
    if (r2.isEmpty())
        return r1;
    if ((r1.type == Universal && !r1.diff) ||
        (r2.type == Universal && !r2.diff))
        return ArrayRegion();
    
    if (r1 == !r2 || r2 == !r1)
        return ArrayRegion();
    
    if (r1.type == SingleElement && r2.type == SingleElement &&
        r2.diff != r1.diff)
    {
        if (r1.var1 == r2.var1)
            return ArrayRegion();
        else
        {
            if (r2.diff)
                return r2;
            else
                return r1;
        }
    }
    
    if (r1.type == SingleElement && r2.type == SingleElement &&
        !r2.diff && !r1.diff)
    {
        if (r1.var1 == r2.var1)
            return r1;
        else
            return ArrayRegion(Empty);
    }
    
    std::cout << r1 << ' ' << r2 << std::endl;
    ROSE_ASSERT(false);    
    return ArrayRegion(Empty);
}



} // end of namespace Backstroke
