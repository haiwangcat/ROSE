#ifndef BACKSTROKE_INTERVAL_H
#define BACKSTROKE_INTERVAL_H

#include "types.h"



namespace Backstroke
{
    
    
enum RegionType
{
    Universal,
    SingleElement,
    DiffSingleElement,
    ClosedInterval,
    DiffClosedInterval,
    Other       
};

struct SymbolicRepresentation
{
    SymbolicRepresentation() : constant(-1) {}
    
    SymbolicRepresentation(const VersionedVariable& v) 
    : var(v), constant(-1) {}
    
    SymbolicRepresentation(SgValueExp* valExp) 
    { setValue(valExp); }
    
    SymbolicRepresentation(int c) : constant(c) {}
    
    void setValue(SgValueExp* valExp);
    
    void setVariable(const VersionedVariable& v)
    { var = v; }
    
    std::string toString() const
    {
        if (constant > 0)
            return boost::lexical_cast<std::string>(constant);
        return var.toString();
    }
    
    VersionedVariable var;
    int constant;
};

inline std::ostream& operator << (std::ostream& os, const SymbolicRepresentation& sym)
{
    return os << sym.toString();
}


struct ArrayRegion
{
    ArrayRegion() : type(Universal) {}
    
    ArrayRegion(const SymbolicRepresentation& v, bool diff = false) 
    : type(diff ? DiffSingleElement : SingleElement), var1(v)
    {}
    
    ArrayRegion(const SymbolicRepresentation& v1, 
        const SymbolicRepresentation& v2, 
        bool diff = false) 
    : type(diff ? DiffClosedInterval : ClosedInterval), var1(v1), var2(v2)
    {}
    
    std::string toString() const;
    
    RegionType type;
    
    SymbolicRepresentation var1;
    SymbolicRepresentation var2;
};

inline std::ostream& operator << (std::ostream& os, const ArrayRegion& region)
{
    return os << region.toString();
}


} // end of namespace Backstroke


#endif