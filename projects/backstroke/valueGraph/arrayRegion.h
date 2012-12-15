#ifndef BACKSTROKE_INTERVAL_H
#define BACKSTROKE_INTERVAL_H

#include "types.h"



namespace Backstroke
{
    
    
enum RegionType
{
    Universal,
    SingleElement,
    ClosedInterval,
    Empty,
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
    
    SgExpression* buildVarExpression() const;
    
    std::string toString() const
    {
        if (constant >= 0)
            return boost::lexical_cast<std::string>(constant);
        return var.toString();
    }
    
    bool isConst() const { return constant >= 0; }
    
    VersionedVariable var;
    int constant;
};

inline std::ostream& operator << (std::ostream& os, const SymbolicRepresentation& sym)
{
    return os << sym.toString();
}

inline bool operator == (const SymbolicRepresentation& s1, const SymbolicRepresentation& s2)
{
    return (s1.var == s2.var) && (s1.constant == s2.constant);
}

inline bool operator != (const SymbolicRepresentation& s1, const SymbolicRepresentation& s2)
{
    return !(s1 == s2);
}


struct ArrayRegion
{
    explicit ArrayRegion(RegionType t = Universal, bool d = false)
    : type(t), diff(d) {}
    
    ArrayRegion(const SymbolicRepresentation& v, bool d = false) 
    : type(SingleElement), diff(d), var1(v)
    {}
    
    ArrayRegion(const SymbolicRepresentation& v1, 
        const SymbolicRepresentation& v2, 
        bool d = false) 
    : type(ClosedInterval), diff(d), var1(v1), var2(v2)
    {}
    
    std::string toString() const;
    
    bool isEmpty() const 
    { return (type == Empty) || ((type == Universal) && diff); }
    
    bool hasSingleElement() const 
    { return (type == SingleElement) && !diff; }
    
    void print() const
    {
        std::cout << type << ' ' << diff << ' ' << var1 << ' ' << var2 << std::endl;
    }
    
    bool isInductionVar() const;
    
    RegionType type;
    bool diff;
    
    SymbolicRepresentation var1;
    SymbolicRepresentation var2;
};

inline std::ostream& operator << (std::ostream& os, const ArrayRegion& region)
{
    return os << region.toString();
}

inline bool operator == (const ArrayRegion& s1, const ArrayRegion& s2)
{
    return (s1.type == s2.type) && (s1.diff == s2.diff) && 
            (s1.var1 == s2.var1) && (s1.var2 == s2.var2);
}

inline bool operator != (const ArrayRegion& s1, const ArrayRegion& s2)
{
    return !(s1 == s2);
}


inline ArrayRegion operator ! (const ArrayRegion& r)
{
    ArrayRegion newRegion = r;
    newRegion.diff = !r.diff;
    return newRegion;
}

ArrayRegion operator & (const ArrayRegion& r1, const ArrayRegion& r2);

ArrayRegion operator | (const ArrayRegion& r1, const ArrayRegion& r2);

inline ArrayRegion operator - (const ArrayRegion& r1, const ArrayRegion& r2)
{
    return r1 & !r2;   
}



} // end of namespace Backstroke


#endif