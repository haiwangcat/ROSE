#include "types.h"

namespace Backstroke
{

using namespace std;

#define foreach         BOOST_FOREACH


SgMemberFunctionSymbol* getMemFuncSymbol(SgClassType* t, const string& name)
{
    // Search the symbol of the member function "at".
    SgDeclarationStatement* decl = 
            t->get_declaration()->get_definingDeclaration();
    SgClassDeclaration* classDecl = isSgClassDeclaration(decl);
    ROSE_ASSERT(classDecl);
    SgClassDefinition* classDef = classDecl->get_definition();

    foreach (SgDeclarationStatement* d, classDef->get_members())
    {
        if (SgMemberFunctionDeclaration* memFuncDecl = isSgMemberFunctionDeclaration(d))
        {
            if (name == memFuncDecl->get_name().str())
                return isSgMemberFunctionSymbol(memFuncDecl->get_symbol_from_symbol_table());
        }
    }

    return NULL;
}


std::string VersionedVariable::toString() const
{
	if (name.empty())
		return "TEMP";
    string str;
    foreach (SgInitializedName* n, name)
        str += n->get_name() + "_";
    str += boost::lexical_cast<string>(version);
    return str;
}

SgExpression* VersionedVariable::getVarRefExp() const
{
    if (name.empty())
        return NULL;
    //ROSE_ASSERT(!name.empty());
    
    SgExpression* var = SageBuilder::buildVarRefExp(name[0]);
    
    for (int i = 1, s = name.size(); i < s; ++i)
    {
        SgType* type = var->get_type();
        
        SgExpression* exp = SageBuilder::buildVarRefExp(name[i]);
        if (isSgPointerType(type))
            var = SageBuilder::buildArrowExp(var, exp);
        else
            var = SageBuilder::buildDotExp(var, exp);
    }
    
    return var;
}


PathInfo PathInfo::operator&(const PathInfo& p) const
{
    PathInfo path = *this;
    path &= p;
    return path;
}

PathInfo& PathInfo::operator&=(const PathInfo& p)
{
    if (p.empty())
    {
        this->reset();
        return *this;
    }

    if (this->is_subset_of(p))
    {
        // Empty body.
    }
    else if (p.is_subset_of(*this))
    {
        *this = p;
    }
    else
    {
        this->PathSet::operator&=(p);
        pathCond.insert(pathCond.end(), p.pathCond.begin(), p.pathCond.end());
    }
    return *this;
}


PathInfo& PathInfo::operator|=(const PathInfo& p)
{
    if (p.empty())
    {
        this->reset();
        return *this;
    }

    if (this->is_subset_of(p))
    {
        *this = p;
    }
    else if (p.is_subset_of(*this))
    {
        // Empty body.
    }
    else
    {
        this->PathSet::operator|=(p);
        //pathCond.insert(pathCond.end(), p.pathCond.begin(), p.pathCond.end());
    }
    return *this;
}

PathInfo& PathInfo::operator-=(const PathInfo& p)
{
    this->PathSet::operator-=(p);
    pathCond.clear();
    return *this;
}

ostream& operator<<(ostream& os, const PathInfo& path)
{
    os << dynamic_cast<const PathSet&>(path);
    for (int i = 0, s = path.pathCond.size(); i < s; ++i)
    {
        os << ' ';
        for (int j = 0, t = path.pathCond[i].size(); j < t; ++j)
        {
            os << path.pathCond[i][j].first << ":" << path.pathCond[i][j].second;
        }
    }
    return os;
}

PathInfos operator&(const PathInfos& path1, const PathInfos& path2)
{
    PathInfos paths;
    PathInfos::const_iterator
        first1 = path1.begin(),
        last1 = path1.end(),
        first2 = path2.begin(),
        last2 = path2.end();

    while (first1!=last1 && first2!=last2)
    {
        if (first1->first < first2->first) ++first1;
        else if (first2->first < first1->first) ++first2;
        else 
        {
            paths[first1->first] = first1->second & first2->second;
            ++first1; ++first2; 
        }
    }
    return paths;
}

PathInfos operator|(const PathInfos& path1, const PathInfos& path2)
{
    PathInfos paths = path1;
    
    foreach (const PathInfos::value_type& idxPaths, path2)
    {
        PathInfos::iterator iter = paths.find(idxPaths.first);
        if (iter != paths.end())
            iter->second |= idxPaths.second;
        else
            paths.insert(iter, idxPaths);
    }
    
    return paths;
}

bool PathInfos::hasPath(int dagIdx, int pathIdx) const
{
    const_iterator iter = find(dagIdx);
    if (iter != end())
        return iter->second[pathIdx];
    return false;
}

std::string PathInfos::toString() const 
{
    std::string str;
    for (const_iterator iter = begin(), iterEnd = end();
            iter != iterEnd; ++iter)
    {
        std::stringstream ss;
        ss << iter->second;
        std::string s = ss.str();
        s = boost::lexical_cast<std::string>(iter->first) + ":" + s;
        str += "\\n" + s;
    }
    return str;
}


} // end of namespace Backstroke
